import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionService {
  final FirebaseFunctions _functions;

  CloudFunctionService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  Future<Map<String, dynamic>> classifySubmission({
    required String imageUrl,
    required String storagePath,
    required String idempotencyKey,
    Map<String, dynamic>? tfliteResult,
  }) async {
    final callable = _functions.httpsCallable('classifySubmission');
    final result = await callable.call({
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'idempotencyKey': idempotencyKey,
      if (tfliteResult != null) 'tfliteResult': tfliteResult,
    });
    return result.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> redeemPoints({
    required int points,
    required String idempotencyKey,
  }) async {
    final callable = _functions.httpsCallable('redeemPoints');
    final result = await callable.call({
      'points': points,
      'idempotencyKey': idempotencyKey,
    });
    return result.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resolveDispute({
    required String disputeId,
    required String resolution,
    String? category,
    String? note,
  }) async {
    final callable = _functions.httpsCallable('resolveDispute');
    final result = await callable.call({
      'disputeId': disputeId,
      'resolution': resolution,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
    });
    return result.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> followUser({
    required String targetUserId,
  }) async {
    final callable = _functions.httpsCallable('followUser');
    final result = await callable.call({'targetUserId': targetUserId});
    return result.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> unfollowUser({
    required String targetUserId,
  }) async {
    final callable = _functions.httpsCallable('unfollowUser');
    final result = await callable.call({'targetUserId': targetUserId});
    return result.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateRole({
    required String targetUserId,
    required String newRole,
  }) async {
    final callable = _functions.httpsCallable('updateRole');
    final result = await callable.call({
      'targetUserId': targetUserId,
      'newRole': newRole,
    });
    return result.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateConfig(Map<String, dynamic> config) async {
    final callable = _functions.httpsCallable('updateConfig');
    final result = await callable.call(config);
    return result.data as Map<String, dynamic>;
  }
}
