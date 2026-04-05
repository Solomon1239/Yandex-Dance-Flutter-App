import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:yandex_dance/core/errors/media_optimization_exception.dart';

class ImageOptimizer {
  final _uuid = const Uuid();

  Future<OptimizedImageResult> optimizeAvatar(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final id = _uuid.v4();

    final mainPath = p.join(tempDir.path, 'avatar_main_$id.jpg');
    final thumbPath = p.join(tempDir.path, 'avatar_thumb_$id.jpg');

    final mainFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      mainPath,
      quality: 82,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    final thumbFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      thumbPath,
      quality: 70,
      minWidth: 256,
      minHeight: 256,
      format: CompressFormat.jpeg,
    );

    if (mainFile == null || thumbFile == null) {
      throw const MediaOptimizationException('Не удалось сжать изображение');
    }

    return OptimizedImageResult(
      mainFile: File(mainFile.path),
      thumbFile: File(thumbFile.path),
      contentType: 'image/jpeg',
    );
  }

  Future<OptimizedImageResult> optimizeCover(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final id = _uuid.v4();

    final mainPath = p.join(tempDir.path, 'cover_main_$id.jpg');
    final thumbPath = p.join(tempDir.path, 'cover_thumb_$id.jpg');

    final mainFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      mainPath,
      quality: 80,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    final thumbFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      thumbPath,
      quality: 70,
      minWidth: 512,
      minHeight: 288,
      format: CompressFormat.jpeg,
    );

    if (mainFile == null || thumbFile == null) {
      throw const MediaOptimizationException('Не удалось сжать обложку');
    }

    return OptimizedImageResult(
      mainFile: File(mainFile.path),
      thumbFile: File(thumbFile.path),
      contentType: 'image/jpeg',
    );
  }
}

class OptimizedImageResult {
  const OptimizedImageResult({
    required this.mainFile,
    required this.thumbFile,
    required this.contentType,
  });

  final File mainFile;
  final File thumbFile;
  final String contentType;
}
