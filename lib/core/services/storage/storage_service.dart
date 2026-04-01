import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  Future<UploadedFileData> uploadFile({
    required String storagePath,
    required File file,
    required String contentType,
  }) async {
    final ref = _storage.ref(storagePath);

    final task = ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );

    final snapshot = await task;
    final url = await snapshot.ref.getDownloadURL();

    return UploadedFileData(
      storagePath: storagePath,
      downloadUrl: url,
    );
  }

  Future<void> deleteIfExists(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) return;

    try {
      await _storage.ref(storagePath).delete();
    } catch (_) {
      // ignore missing file
    }
  }
}

class UploadedFileData {
  const UploadedFileData({
    required this.storagePath,
    required this.downloadUrl,
  });

  final String storagePath;
  final String downloadUrl;
}
