import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/utils/image_utils.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadImage({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    final storagePath = ImageUtils.generateStoragePath(userId, fileName);

    final compressedBytes = await _compressImageFile(filePath);

    final ref = _storage.ref().child(storagePath);
    final uploadTask = ref.putData(
      Uint8List.fromList(compressedBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> uploadImageBytes({
    required String userId,
    required String fileName,
  }) async {
    final storagePath = ImageUtils.generateStoragePath(userId, fileName);
    return storagePath;
  }

  Future<void> deleteImage(String storagePath) async {
    final ref = _storage.ref().child(storagePath);
    await ref.delete();
  }

  Future<List<int>> _compressImageFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return ImageUtils.compressForUpload(bytes);
  }
}
