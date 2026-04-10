// ignore_for_file: use_null_aware_elements

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';

class SupabaseFunctionService {
  final SupabaseClient _client;

  SupabaseFunctionService({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Future<Map<String, dynamic>> classifySubmission({
    required String imageUrl,
    required String storagePath,
    required String idempotencyKey,
    Map<String, dynamic>? tfliteResult,
  }) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.classify,
      body: {
        'action': 'classify',
        'imageUrl': imageUrl,
        'storagePath': storagePath,
        'idempotencyKey': idempotencyKey,
        if (tfliteResult != null) 'tfliteResult': tfliteResult,
      },
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> redeemPoints({
    required int points,
    required String idempotencyKey,
  }) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.rewards,
      body: {
        'action': 'redeem',
        'points': points,
        'idempotencyKey': idempotencyKey,
      },
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> resolveDispute({
    required String disputeId,
    required String resolution,
    String? category,
    String? note,
  }) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.disputes,
      body: {
        'action': 'resolve',
        'disputeId': disputeId,
        'resolution': resolution,
        if (category != null) 'category': category,
        if (note != null) 'note': note,
      },
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> followUser({
    required String targetUserId,
  }) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.social,
      body: {'action': 'follow', 'targetUserId': targetUserId},
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> unfollowUser({
    required String targetUserId,
  }) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.social,
      body: {'action': 'unfollow', 'targetUserId': targetUserId},
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> updateRole({
    required String targetUserId,
    required String newRole,
  }) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.admin,
      body: {
        'action': 'updateRole',
        'targetUserId': targetUserId,
        'newRole': newRole,
      },
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> updateConfig(Map<String, dynamic> config) async {
    final response = await _client.functions.invoke(
      SupabaseFunctions.admin,
      body: {'action': 'updateConfig', ...config},
    );
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(FunctionResponse response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      throw Exception('Edge function error: $data');
    }
    return {'data': data};
  }
}
