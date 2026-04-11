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
    try {
      final category = tfliteResult?['category'] as String? ?? 'unclassified';
      final confidence =
          (tfliteResult?['confidence'] as num?)?.toDouble() ?? 0.0;
      final points = _calculatePoints(confidence);
      final now = DateTime.now().toIso8601String();

      final submissionId = await _client
          .from(SupabaseTables.submissions)
          .insert({
            'user_id': userId,
            'username': username,
            'image_url': imageUrl,
            'storage_path': storagePath,
            'category': category,
            'confidence': confidence,
            'state': 'SUBMITTED',
            'points_awarded': points,
            'idempotency_key': idempotencyKey,
            'classified_at': now,
          })
          .select()
          .then((rows) => rows.first['id'] as String);

      if (points > 0) {
        try {
          final profile = await _client
              .from(SupabaseTables.profiles)
              .select('points')
              .eq('uid', userId)
              .maybeSingle();

          if (profile != null) {
            final currentPoints = (profile['points'] as int?) ?? 0;
            await _client.from(SupabaseTables.profiles).update({
              'points': currentPoints + points,
            }).eq('uid', userId);
          }
        } catch (e) {
          // Log but continue - points are already awarded in submission
        }
      }

      return {
        'submissionId': submissionId,
        'state': 'SUBMITTED',
        'category': category,
        'confidence': confidence,
        'pointsAwarded': points,
      };
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  int _calculatePoints(double confidence) {
    if (confidence >= 0.9) return 10;
    if (confidence >= 0.7) return 7;
    if (confidence >= 0.5) return 5;
    return 3;
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
      // Direct update since RPC with params not supported in this version
      final profile = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (profile == null) {
        throw Exception('Profile not found');
      }

      final currentPoints = (profile['points'] as int?) ?? 0;
      final redeemedPoints = (profile['redeemed_points'] as int?) ?? 0;
      final available = currentPoints - redeemedPoints;

      if (available < points) {
        throw Exception('Insufficient points. Available: $available');
      }

      await _client.from(SupabaseTables.profiles).update({
        'redeemed_points': redeemedPoints + points,
      }).eq('uid', user.id);

      // Log reward record
      await _client.from(SupabaseTables.rewards).insert({
        'user_id': user.id,
        'points': -points,
        'type': 'REDEMPTION',
        'idempotency_key': idempotencyKey,
      });

      final newAvailable = available - points;
      return {'availableBalance': newAvailable, 'success': true};
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

      // Update follower count
      final followerProfile = await _client
          .from(SupabaseTables.profiles)
          .select('follower_count')
          .eq('uid', user.id)
          .maybeSingle();
      if (followerProfile != null) {
        final count = (followerProfile['follower_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'follower_count': count + 1,
        }).eq('uid', user.id);
      }

      // Update following count for target
      final targetProfile = await _client
          .from(SupabaseTables.profiles)
          .select('following_count')
          .eq('uid', targetUserId)
          .maybeSingle();
      if (targetProfile != null) {
        final count = (targetProfile['following_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'following_count': count + 1,
        }).eq('uid', targetUserId);
      }

      return {'success': true, 'following': true};
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

      // Update follower count
      final followerProfile = await _client
          .from(SupabaseTables.profiles)
          .select('follower_count')
          .eq('uid', user.id)
          .maybeSingle();
      if (followerProfile != null) {
        final count = (followerProfile['follower_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'follower_count': (count - 1).clamp(0, count),
        }).eq('uid', user.id);
      }

      // Update following count for target
      final targetProfile = await _client
          .from(SupabaseTables.profiles)
          .select('following_count')
          .eq('uid', targetUserId)
          .maybeSingle();
      if (targetProfile != null) {
        final count = (targetProfile['following_count'] as int?) ?? 0;
        await _client.from(SupabaseTables.profiles).update({
          'following_count': (count - 1).clamp(0, count),
        }).eq('uid', targetUserId);
      }

      return {'success': true, 'following': false};
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
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

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
      final newValue = {...currentValue, ...config};

      await _client.from(SupabaseTables.config).upsert({
        'key': 'system',
        'value': newValue,
      });

      return {'success': true, 'config': newValue};
    } catch (e) {
      throw Exception('Failed to update config: $e');
    }
  }
}
