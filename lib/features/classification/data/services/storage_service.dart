import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/utils/image_utils.dart';

class StorageService {
  final SupabaseClient _client;

  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int minFileSize = 100; // 100 bytes

  StorageService({SupabaseClient? client})
      : _client = client ?? SupabaseConstants.client;

  Future<bool> _isValidImage(List<int> bytes) async {
    if (bytes.length < 4) {
      return false;
    }
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }
    return false;
  }

  Future<({String imageUrl, String storagePath})> uploadImage({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('Unauthorized: Invalid user');
    }

    final file = File(filePath);
    final size = await file.length();
    if (size > maxFileSize) {
      throw Exception('File size exceeds maximum allowed size of 10MB');
    }
    if (size < minFileSize) {
      throw Exception('File too small. Minimum 100 bytes required.');
    }

    final storagePath = ImageUtils.generateStoragePath(userId, fileName);
    final compressedBytes = await _compressImageFile(filePath);
    final bytes = Uint8List.fromList(compressedBytes);

    if (!await _isValidImage(bytes)) {
      throw Exception('Invalid image format. Only JPEG and PNG are supported.');
    }

    await _client.storage.from(SupabaseStorage.submissionsBucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    final imageUrl = _client.storage
        .from(SupabaseStorage.submissionsBucket)
        .getPublicUrl(storagePath);

    return (imageUrl: imageUrl, storagePath: storagePath);
  }

  Future<String> uploadImageBytes({
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('Unauthorized: Invalid user');
    }

    if (bytes.length > maxFileSize) {
      throw Exception('File size exceeds maximum allowed size of 10MB');
    } else if (bytes.length < minFileSize) {
      throw Exception('File too small. Minimum 100 bytes required.');
    }

    if (!await _isValidImage(bytes)) {
      throw Exception('Invalid image format. Only JPEG and PNG are supported.');
    }

    final storagePath = ImageUtils.generateStoragePath(userId, fileName);

    await _client.storage.from(SupabaseStorage.submissionsBucket).uploadBinary(
          storagePath,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    return _client.storage
        .from(SupabaseStorage.submissionsBucket)
        .getPublicUrl(storagePath);
  }

  Future<void> deleteImage(String storagePath) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Unauthorized: User not authenticated');
    }

    final pathParts = storagePath.split('/');
    if (pathParts.length < 3 || pathParts[0] != 'submissions') {
      throw Exception('Invalid storage path format');
    }

    final ownerId = pathParts[1];
    final userRoleResponse = await _client
        .from(SupabaseTables.profiles)
        .select('role')
        .eq('uid', user.id)
        .maybeSingle();
    final userRole = userRoleResponse?['role'] as String? ?? '';

    if (ownerId != user.id && userRole != 'admin') {
      throw Exception('Unauthorized: You can only delete your own images');
    }

    await _client.storage.from(SupabaseStorage.submissionsBucket).remove([
      storagePath,
    ]);
  }

  Future<List<int>> _compressImageFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return await ImageUtils.compressForUploadAsync(bytes);
  }
}
