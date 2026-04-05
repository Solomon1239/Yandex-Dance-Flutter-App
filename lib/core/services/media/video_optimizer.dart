import 'dart:io';

import 'package:video_compress/video_compress.dart';
import 'package:yandex_dance/core/errors/media_optimization_exception.dart';

class VideoOptimizer {
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const Duration maxDuration = Duration(minutes: 5);

  Future<OptimizedVideoResult> optimizeIntroVideo(String sourcePath) async {
    await _validateVideo(sourcePath);

    final info = await VideoCompress.compressVideo(
      sourcePath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    final thumb = await VideoCompress.getFileThumbnail(
      sourcePath,
      quality: 70,
      position: -1,
    );

    if (info == null || info.file == null) {
      throw const MediaOptimizationException('Не удалось сжать видео');
    }

    return OptimizedVideoResult(
      videoFile: info.file!,
      thumbFile: thumb,
      contentType: 'video/mp4',
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

    final mediaInfo = await VideoCompress.getMediaInfo(sourcePath);
    if (mediaInfo.duration != null) {
      final duration = Duration(milliseconds: mediaInfo.duration!.toInt());
      if (duration > maxDuration) {
        throw const MediaOptimizationException(
          'Видео слишком длинное. Максимальная длительность — 5 минут',
        );
      }
    }
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
  final File thumbFile;
  final String contentType;
}
