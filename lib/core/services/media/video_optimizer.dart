import 'dart:io';

import 'package:video_compress/video_compress.dart';

class VideoOptimizer {
  Future<OptimizedVideoResult> optimizeIntroVideo(String sourcePath) async {
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

    if (info == null || info.file == null || thumb == null) {
      throw const MediaOptimizationException('Не удалось сжать видео');
    }

    return OptimizedVideoResult(
      videoFile: info.file!,
      thumbFile: thumb,
      contentType: 'video/mp4',
    );
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

class MediaOptimizationException implements Exception {
  const MediaOptimizationException(this.message);

  final String message;
}
