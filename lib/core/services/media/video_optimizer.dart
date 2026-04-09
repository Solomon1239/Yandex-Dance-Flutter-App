import 'dart:io';

import 'package:video_compress/video_compress.dart';
import 'package:yandex_dance/core/errors/media_optimization_exception.dart';

class VideoOptimizer {
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const Duration maxDuration = Duration(minutes: 5);

  Future<OptimizedVideoResult> optimizeIntroVideo(String sourcePath) async {
    await _validateVideo(sourcePath);

    final originalFile = File(sourcePath);

    File optimizedVideoFile = originalFile;
    String contentType = _videoContentType(sourcePath);

    try {
      final info = await VideoCompress.compressVideo(
        sourcePath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info?.file != null) {
        optimizedVideoFile = info!.file!;
        contentType = 'video/mp4';
      }
    } catch (_) {
      optimizedVideoFile = originalFile;
    }

    File? thumb;
    try {
      thumb = await VideoCompress.getFileThumbnail(
        sourcePath,
        quality: 70,
        position: 1000,
      );
    } catch (_) {
      thumb = null;
    }

    return OptimizedVideoResult(
      videoFile: optimizedVideoFile,
      thumbFile: thumb,
      contentType: contentType,
    );
  }

  Future<void> _validateVideo(String sourcePath) async {
    final file = File(sourcePath);
    final fileSize = await file.length();

    if (fileSize > maxFileSizeBytes) {
      throw const MediaOptimizationException(
        'Видео слишком большое. Максимальный размер — 100 МБ',
      );
    }

    try {
      final mediaInfo = await VideoCompress.getMediaInfo(sourcePath);
      if (mediaInfo.duration != null) {
        final duration = Duration(milliseconds: mediaInfo.duration!.toInt());
        if (duration > maxDuration) {
          throw const MediaOptimizationException(
            'Видео слишком длинное. Максимальная длительность — 5 минут',
          );
        }
      }
    } catch (_) {
      // Некоторые форматы/устройства падают внутри video_compress при чтении
      // метаданных. В этом случае продолжаем без проверки длительности.
    }
  }

  String _videoContentType(String sourcePath) {
    final lower = sourcePath.toLowerCase();
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.m4v')) return 'video/x-m4v';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }

  Future<void> clearCache() async {
    await VideoCompress.deleteAllCache();
  }
}

class OptimizedVideoResult {
  const OptimizedVideoResult({
    required this.videoFile,
    required this.thumbFile,
    required this.contentType,
  });

  final File videoFile;
  final File? thumbFile;
  final String contentType;
}
