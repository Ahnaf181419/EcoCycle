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
    required String userId,
    required String username,
    Map<String, dynamic>? tfliteResult,
  }) async {
    // Delegate to the `classify` edge function, which runs Gemini for the
    // real ML call, cross-validates against any tflite hint, applies the
    // config-driven confidence threshold, writes submissions/classifications/
    // disputes/rewards, and handles idempotency. Doing this on the client
    // would require inlining all of that logic (and shipping the Gemini key).
    try {
      final response = await _client.functions.invoke(
        EdgeFunctionNames.classify,
        body: {
          'action': 'classify',
          'imageUrl': imageUrl,
          'storagePath': storagePath,
          'idempotencyKey': idempotencyKey,
          if (tfliteResult != null) 'tfliteResult': tfliteResult,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw Exception('Unexpected response from classify function');
      }
      final map = Map<String, dynamic>.from(data);
      if (map['error'] != null) {
        throw Exception(map['error'].toString());
      }
      return map;
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to classify submission: $e');
    }
  }

  Future<Map<String, dynamic>> redeemPoints({
    required int points,
    required String idempotencyKey,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final result = await _client.rpc(
        'atomic_redeem_points',
        params: {'target_uid': user.id, 'redeem_amount': points},
      );

      final success = result['success'] as bool? ?? false;
      if (!success) {
        final message = result['message'] as String? ?? 'Redemption failed';
        throw Exception(message);
      }

      final newAvailable = result['new_balance'] as int? ?? 0;
      return {'availableBalance': newAvailable, 'success': true};
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to redeem points: $e');
    }
  }

  Future<Map<String, dynamic>> resolveDispute({
    required String disputeId,
    required String resolution,
    String? category,
    String? note,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _client.from(SupabaseTables.disputes).update({
        'resolution': resolution,
        'resolved_by': user.id,
        'resolution_note': note,
        'resolved_at': DateTime.now().toIso8601String(),
        'status': resolution == 'APPROVED'
            ? 'APPROVED'
            : resolution == 'OVERRIDDEN'
                ? 'OVERRIDDEN'
                : 'REJECTED',
      }).eq('id', disputeId);

      if (resolution == 'OVERRIDDEN' && category != null) {
        final dispute = await _client
            .from(SupabaseTables.disputes)
            .select('submission_id')
            .eq('id', disputeId)
            .maybeSingle();

        if (dispute != null) {
          await _client.from(SupabaseTables.submissions).update({
            'category': category,
            'state': 'RESOLVED',
          }).eq('id', dispute['submission_id']);
        }
      }

      return {
        'success': true,
        'disputeId': disputeId,
        'resolution': resolution
      };
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to resolve dispute: $e');
    }
  }

  Future<Map<String, dynamic>> followUser({
    required String targetUserId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _client.from(SupabaseTables.follows).insert({
        'follower_id': user.id,
        'followee_id': targetUserId,
      });

      // Increment following_count on follower (user.id)
      final followerProfile = await _client
          .from(SupabaseTables.profiles)
          .select('following_count')
          .eq('uid', user.id)
          .maybeSingle();
      if (followerProfile != null) {
        final count = (followerProfile['following_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'following_count': count + 1,
        }).eq('uid', user.id);
      }

      // Increment follower_count on followee (targetUserId)
      final targetProfile = await _client
          .from(SupabaseTables.profiles)
          .select('follower_count')
          .eq('uid', targetUserId)
          .maybeSingle();
      if (targetProfile != null) {
        final count = (targetProfile['follower_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'follower_count': count + 1,
        }).eq('uid', targetUserId);
      }

      return {'success': true, 'following': true};
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  Future<Map<String, dynamic>> unfollowUser({
    required String targetUserId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _client
          .from(SupabaseTables.follows)
          .delete()
          .eq('follower_id', user.id)
          .eq('followee_id', targetUserId);

      // Decrement following_count on follower (user.id)
      final followerProfile = await _client
          .from(SupabaseTables.profiles)
          .select('following_count')
          .eq('uid', user.id)
          .maybeSingle();
      if (followerProfile != null) {
        final count = (followerProfile['following_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'following_count': (count - 1).clamp(0, count),
        }).eq('uid', user.id);
      }

      // Decrement follower_count on followee (targetUserId)
      final targetProfile = await _client
          .from(SupabaseTables.profiles)
          .select('follower_count')
          .eq('uid', targetUserId)
          .maybeSingle();
      if (targetProfile != null) {
        final count = (targetProfile['follower_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'follower_count': (count - 1).clamp(0, count),
        }).eq('uid', targetUserId);
      }

      return {'success': true, 'following': false};
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  Future<Map<String, dynamic>> updateRole({
    required String targetUserId,
    required String newRole,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userProfile = await _client
          .from(SupabaseTables.profiles)
          .select('role')
          .eq('uid', user.id)
          .maybeSingle();

      if (userProfile?['role'] != 'admin') {
        throw Exception('Unauthorized: Admin access required');
      }

      await _client.from(SupabaseTables.profiles).update({
        'role': newRole,
      }).eq('uid', targetUserId);

      return {'success': true, 'userId': targetUserId, 'role': newRole};
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  static const _allowedConfigKeys = {
    'pointsPerClassification',
    'maxDailySubmissions',
    'duplicateThreshold',
  };

  Future<Map<String, dynamic>> updateConfig(Map<String, dynamic> config) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userProfile = await _client
          .from(SupabaseTables.profiles)
          .select('role')
          .eq('uid', user.id)
          .maybeSingle();

      if (userProfile?['role'] != 'admin') {
        throw Exception('Unauthorized: Admin access required');
      }

      final current = await _client
          .from(SupabaseTables.config)
          .select('value')
          .eq('key', 'system')
          .maybeSingle();

      final currentValue = (current?['value'] as Map<String, dynamic>?) ?? {};
      final filtered = Map.fromEntries(
        config.entries.where((e) => _allowedConfigKeys.contains(e.key)),
      );
      final newValue = {...currentValue, ...filtered};

      await _client.from(SupabaseTables.config).upsert({
        'key': 'system',
        'value': newValue,
      });

      return {'success': true, 'config': newValue};
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update config: $e');
    }
  }
}
