import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/utils/image_utils.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Future<String> uploadImage({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    final storagePath = ImageUtils.generateStoragePath(userId, fileName);
    final compressedBytes = await _compressImageFile(filePath);

    await _client.storage
        .from(SupabaseStorage.submissionsBucket)
        .uploadBinary(
          storagePath,
          Uint8List.fromList(compressedBytes),
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    final downloadUrl = _client.storage
        .from(SupabaseStorage.submissionsBucket)
        .getPublicUrl(storagePath);

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
    await _client.storage.from(SupabaseStorage.submissionsBucket).remove([
      storagePath,
    ]);
  }

  Future<List<int>> _compressImageFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return ImageUtils.compressForUpload(bytes);
  }
}
