import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/core/services/media/image_optimizer.dart';
import 'package:yandex_dance/core/services/media/video_optimizer.dart';
import 'package:yandex_dance/core/services/storage/storage_service.dart';
import 'package:yandex_dance/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:yandex_dance/features/profile/data/models/user_profile_model.dart';
import 'package:yandex_dance/features/profile/domain/entities/user_profile.dart';
import 'package:yandex_dance/features/profile/domain/repositories/profile_repository.dart';
import 'package:uuid/uuid.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required StorageService storageService,
    required ImageOptimizer imageOptimizer,
    required VideoOptimizer videoOptimizer,
  }) : _remote = remote,
       _storageService = storageService,
       _imageOptimizer = imageOptimizer,
       _videoOptimizer = videoOptimizer;

  final ProfileRemoteDataSource _remote;
  final StorageService _storageService;
  final ImageOptimizer _imageOptimizer;
  final VideoOptimizer _videoOptimizer;

  final _uuid = const Uuid();

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _remote.watchProfile(uid).map((model) => model?.toEntity());
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final model = await _remote.getProfile(uid);
    return model?.toEntity();
  }

  @override
  Future<void> createProfileIfNeeded({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    final model = UserProfileModel(
      uid: uid,
      displayName: displayName ?? email?.split('@').first,
      bio: null,
      city: null,
      age: null,
      rating: null,
      avatarUrl: photoUrl,
      avatarThumbUrl: photoUrl,
      avatarStoragePath: null,
      avatarThumbStoragePath: null,
      introVideoUrl: null,
      introVideoThumbUrl: null,
      introVideoStoragePath: null,
      introVideoThumbStoragePath: null,
      danceStyles: const [],
      onboardingCompleted: false,
      createdAt: null,
      updatedAt: null,
    );

    await _remote.createProfileIfNeeded(model);
  }

  @override
  Future<void> updateDanceStyles({
    required String uid,
    required List<DanceStyle> danceStyles,
  }) async {
    await _remote.updateFields(
      uid: uid,
      fields: {
        'danceStyles': danceStyles.map((e) => e.code).toList(),
        'onboardingCompleted': danceStyles.isNotEmpty,
      },
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await _remote.updateProfile(model);
  }

  @override
  Future<UserProfile> uploadAvatar({
    required String uid,
    required UserProfile currentProfile,
    required String sourcePath,
  }) async {
    try {
      final optimized = await _imageOptimizer.optimizeAvatar(sourcePath);

      final mainPath = 'user_avatars/$uid/avatar_${_uuid.v4()}.jpg';
      final thumbPath = 'user_avatars/$uid/avatar_thumb_${_uuid.v4()}.jpg';

      final uploadedMain = await _storageService.uploadFile(
        storagePath: mainPath,
        file: optimized.mainFile,
        contentType: optimized.contentType,
      );

      final uploadedThumb = await _storageService.uploadFile(
        storagePath: thumbPath,
        file: optimized.thumbFile,
        contentType: optimized.contentType,
      );

      await _storageService.deleteIfExists(currentProfile.avatarStoragePath);
      await _storageService.deleteIfExists(
        currentProfile.avatarThumbStoragePath,
      );

      final updated = currentProfile.copyWith(
        avatarUrl: uploadedMain.downloadUrl,
        avatarThumbUrl: uploadedThumb.downloadUrl,
        avatarStoragePath: uploadedMain.storagePath,
        avatarThumbStoragePath: uploadedThumb.storagePath,
      );

      await saveProfile(updated);
      return updated;
    } catch (_) {
      throw const AppException.unknown('Не удалось загрузить аватар');
    }
  }

  @override
  Future<UserProfile> uploadIntroVideo({
    required String uid,
    required UserProfile currentProfile,
    required String sourcePath,
  }) async {
    try {
      final optimized = await _videoOptimizer.optimizeIntroVideo(sourcePath);

      final videoPath = 'user_videos/$uid/intro_${_uuid.v4()}.mp4';
      final thumbPath = 'user_videos/$uid/intro_thumb_${_uuid.v4()}.jpg';

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

      await _storageService.deleteIfExists(
        currentProfile.introVideoStoragePath,
      );
      await _storageService.deleteIfExists(
        currentProfile.introVideoThumbStoragePath,
      );

      final updated = currentProfile.copyWith(
        introVideoUrl: uploadedVideo.downloadUrl,
        introVideoThumbUrl: uploadedThumb.downloadUrl,
        introVideoStoragePath: uploadedVideo.storagePath,
        introVideoThumbStoragePath: uploadedThumb.storagePath,
      );

      await saveProfile(updated);
      return updated;
    } catch (_) {
      throw const AppException.unknown('Не удалось загрузить видео');
    } finally {
      await _videoOptimizer.clearCache();
    }
  }
}
