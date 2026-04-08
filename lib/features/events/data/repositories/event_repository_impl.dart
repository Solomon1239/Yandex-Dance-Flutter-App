import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/core/errors/media_optimization_exception.dart';
import 'package:yandex_dance/core/services/media/image_optimizer.dart';
import 'package:yandex_dance/core/services/media/video_optimizer.dart';
import 'package:yandex_dance/core/services/storage/storage_service.dart';
import 'package:yandex_dance/features/events/data/datasources/event_remote_data_source.dart';
import 'package:yandex_dance/features/events/data/models/dance_event_model.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';
import 'package:uuid/uuid.dart';

/// Реализация [EventRepository]. Склеивает Firestore
/// (через [EventRemoteDataSource]) с Firebase Storage (обложки и промо-видео
/// через [StorageService]) и оптимизаторами медиа. Контракт и подробные
/// описания методов — в [EventRepository].
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({
    required EventRemoteDataSource remote,
    required StorageService storageService,
    required ImageOptimizer imageOptimizer,
    required VideoOptimizer videoOptimizer,
  }) : _remote = remote,
       _storageService = storageService,
       _imageOptimizer = imageOptimizer,
       _videoOptimizer = videoOptimizer;

  final EventRemoteDataSource _remote;
  final StorageService _storageService;
  final ImageOptimizer _imageOptimizer;
  final VideoOptimizer _videoOptimizer;

  final _uuid = const Uuid();

  @override
  Stream<List<DanceEvent>> watchAllEvents() {
    return _remote.watchAllEvents().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Stream<List<DanceEvent>> watchUserEvents(String uid) {
    return _remote
        .watchUserEvents(uid)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<DanceEvent?> getEvent(String eventId) async {
    final model = await _remote.getEvent(eventId);
    return model?.toEntity();
  }

  @override
  Future<DanceEvent> createEvent({
    required String title,
    required String description,
    required DanceStyle danceStyle,
    required DateTime dateTime,
    required String address,
    double? latitude,
    double? longitude,
    required int maxParticipants,
    required String ageRestriction,
    required String creatorId,
    String? coverSourcePath,
    String? promoVideoSourcePath,
  }) async {
    try {
      String? coverUrl;
      String? coverThumbUrl;
      String? coverStoragePath;
      String? coverThumbStoragePath;
      String? promoVideoUrl;
      String? promoVideoThumbUrl;
      String? promoVideoStoragePath;
      String? promoVideoThumbStoragePath;

      // Префикс с uid лучше совпадает с логикой Storage-правил, как у профиля.
      final tempId = _uuid.v4();

      if (coverSourcePath != null) {
        final uploaded = await _uploadCoverWithFallback(
          sourcePath: coverSourcePath,
          folderPath: 'event_covers/$creatorId/$tempId',
        );
        coverUrl = uploaded.main.downloadUrl;
        coverThumbUrl = uploaded.thumb.downloadUrl;
        coverStoragePath = uploaded.main.storagePath;
        coverThumbStoragePath = uploaded.thumb.storagePath;
      }

      if (promoVideoSourcePath != null) {
        try {
          final optimized = await _videoOptimizer.optimizeIntroVideo(
            promoVideoSourcePath,
          );

          final videoPath =
              'event_videos/$creatorId/$tempId/promo_${_uuid.v4()}.mp4';
          final thumbPath =
              'event_videos/$creatorId/$tempId/promo_thumb_${_uuid.v4()}.jpg';

          final uploadedVideo = await _storageService.uploadFile(
            storagePath: videoPath,
            file: optimized.videoFile,
            contentType: optimized.contentType,
          );
          final uploadedThumb = await _storageService.uploadFile(
            storagePath: thumbPath,
            file: optimized.thumbFile,
            contentType: 'image/jpeg',
          );

          promoVideoUrl = uploadedVideo.downloadUrl;
          promoVideoThumbUrl = uploadedThumb.downloadUrl;
          promoVideoStoragePath = uploadedVideo.storagePath;
          promoVideoThumbStoragePath = uploadedThumb.storagePath;
        } catch (_) {
          // Если нет доступа к Storage, не срываем создание события в Firestore.
        } finally {
          await _videoOptimizer.clearCache();
        }
      }

      // id пустой — Firestore сам сгенерит его при .add()
      final model = DanceEventModel(
        id: '',
        title: title,
        description: description,
        coverUrl: coverUrl,
        coverThumbUrl: coverThumbUrl,
        coverStoragePath: coverStoragePath,
        coverThumbStoragePath: coverThumbStoragePath,
        danceStyle: danceStyle.code,
        dateTime: dateTime,
        address: address,
        latitude: latitude,
        longitude: longitude,
        maxParticipants: maxParticipants,
        participantIds: const [],
        ageRestriction: ageRestriction,
        promoVideoUrl: promoVideoUrl,
        promoVideoThumbUrl: promoVideoThumbUrl,
        promoVideoStoragePath: promoVideoStoragePath,
        promoVideoThumbStoragePath: promoVideoThumbStoragePath,
        creatorId: creatorId,
      );

      final docId = await _remote.createEvent(model);
      final created = await _remote.getEvent(docId);
      return created!.toEntity();
    } catch (e, stackTrace) {
      debugPrint('createEvent failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (e is AppException) rethrow;
      if (e is FirebaseException) {
        final message = e.message?.trim();
        if (message == null || message.isEmpty) {
          throw AppException.unknown('Firebase ошибка: ${e.code}');
        }
        throw AppException.unknown('Firebase ошибка (${e.code}): $message');
      }
      if (e is MediaOptimizationException) {
        throw AppException.unknown(e.message);
      }
      throw const AppException.unknown('Не удалось создать мероприятие');
    }
  }

  @override
  Future<void> updateEvent(DanceEvent event) async {
    final model = DanceEventModel.fromEntity(event);
    await _remote.updateEvent(model);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    // сначала достаём мероприятие, чтобы знать пути к его файлам —
    // после удаления документа узнать их будет неоткуда
    final event = await getEvent(eventId);
    if (event != null) {
      await _storageService.deleteIfExists(event.coverStoragePath);
      await _storageService.deleteIfExists(event.coverThumbStoragePath);
      await _storageService.deleteIfExists(event.promoVideoStoragePath);
      await _storageService.deleteIfExists(event.promoVideoThumbStoragePath);
    }
    await _remote.deleteEvent(eventId);
  }

  @override
  Future<DanceEvent> joinEvent({
    required String eventId,
    required String uid,
  }) async {
    await _remote.addParticipant(eventId: eventId, uid: uid);
    final updated = await _remote.getEvent(eventId);
    return updated!.toEntity();
  }

  @override
  Future<DanceEvent> leaveEvent({
    required String eventId,
    required String uid,
  }) async {
    await _remote.removeParticipant(eventId: eventId, uid: uid);
    final updated = await _remote.getEvent(eventId);
    return updated!.toEntity();
  }

  @override
  Future<DanceEvent> uploadCover({
    required String eventId,
    required DanceEvent currentEvent,
    required String sourcePath,
  }) async {
    try {
      final uploaded = await _uploadCoverWithFallback(
        sourcePath: sourcePath,
        folderPath: 'event_covers/${currentEvent.creatorId}/$eventId',
      );

      await _storageService.deleteIfExists(currentEvent.coverStoragePath);
      await _storageService.deleteIfExists(currentEvent.coverThumbStoragePath);

      final updated = currentEvent.copyWith(
        coverUrl: uploaded.main.downloadUrl,
        coverThumbUrl: uploaded.thumb.downloadUrl,
        coverStoragePath: uploaded.main.storagePath,
        coverThumbStoragePath: uploaded.thumb.storagePath,
      );

      await updateEvent(updated);
      return updated;
    } catch (_) {
      throw const AppException.unknown('Не удалось загрузить обложку');
    }
  }

  @override
  Future<DanceEvent> uploadPromoVideo({
    required String eventId,
    required DanceEvent currentEvent,
    required String sourcePath,
  }) async {
    try {
      final optimized = await _videoOptimizer.optimizeIntroVideo(sourcePath);

      final videoPath =
          'event_videos/${currentEvent.creatorId}/$eventId/promo_${_uuid.v4()}.mp4';
      final thumbPath =
          'event_videos/${currentEvent.creatorId}/$eventId/promo_thumb_${_uuid.v4()}.jpg';

      final uploadedVideo = await _storageService.uploadFile(
        storagePath: videoPath,
        file: optimized.videoFile,
        contentType: optimized.contentType,
      );
      final uploadedThumb = await _storageService.uploadFile(
        storagePath: thumbPath,
        file: optimized.thumbFile,
        contentType: 'image/jpeg',
      );

      await _storageService.deleteIfExists(currentEvent.promoVideoStoragePath);
      await _storageService.deleteIfExists(
        currentEvent.promoVideoThumbStoragePath,
      );

      final updated = currentEvent.copyWith(
        promoVideoUrl: uploadedVideo.downloadUrl,
        promoVideoThumbUrl: uploadedThumb.downloadUrl,
        promoVideoStoragePath: uploadedVideo.storagePath,
        promoVideoThumbStoragePath: uploadedThumb.storagePath,
      );

      await updateEvent(updated);
      return updated;
    } catch (_) {
      throw const AppException.unknown('Не удалось загрузить промо-видео');
    } finally {
      await _videoOptimizer.clearCache();
    }
  }

  Future<({UploadedFileData main, UploadedFileData thumb})>
  _uploadCoverWithFallback({
    required String sourcePath,
    required String folderPath,
  }) async {
    final optimizedMainPath = '$folderPath/cover_${_uuid.v4()}.jpg';
    final optimizedThumbPath = '$folderPath/cover_thumb_${_uuid.v4()}.jpg';

    try {
      final optimized = await _imageOptimizer.optimizeCover(sourcePath);

      final main = await _storageService.uploadFile(
        storagePath: optimizedMainPath,
        file: optimized.mainFile,
        contentType: optimized.contentType,
      );
      final thumb = await _storageService.uploadFile(
        storagePath: optimizedThumbPath,
        file: optimized.thumbFile,
        contentType: optimized.contentType,
      );
      return (main: main, thumb: thumb);
    } on MediaOptimizationException {
      final originalFile = File(sourcePath);
      if (!await originalFile.exists()) {
        throw const AppException.unknown('Файл обложки не найден');
      }

      final extension = _normalizedImageExtension(sourcePath);
      final main = await _storageService.uploadFile(
        storagePath: '$folderPath/cover_original_${_uuid.v4()}$extension',
        file: originalFile,
        contentType: _imageContentType(sourcePath),
      );

      // Если не смогли сделать thumbnail, используем основной файл.
      return (main: main, thumb: main);
    }
  }

  String _normalizedImageExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.heic')) return '.heic';
    if (lower.endsWith('.heif')) return '.heif';
    return '.jpg';
  }

  String _imageContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }
}
