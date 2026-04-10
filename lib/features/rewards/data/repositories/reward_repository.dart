import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reward_model.dart';
import '../../../../core/constants/supabase_constants.dart';

class RewardRepository {
  final SupabaseClient _client;

  RewardRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<List<Reward>> getRewardHistory({int limit = 20}) {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value([]);

    return _client
        .from(SupabaseTables.rewards)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .limit(limit)
        .map(
          (rows) => rows.reversed.map((row) => Reward.fromJson(row)).toList(),
        );
  }

  Future<List<Reward>> getRewardsPaginated({
    int limit = 20,
    int offset = 0,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final response = await _client
        .from(SupabaseTables.rewards)
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map((row) => Reward.fromJson(row)).toList();
  }

  Stream<int> getTotalEarnedPoints() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(0);

    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return 0;
          return (rows.first['points'] as num?)?.toInt() ?? 0;
        });
  }

  Stream<int> getTotalRedeemedPoints() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(0);

    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .limit(1)
        .map((rows) {
          if (rows.isEmpty) return 0;
          return (rows.first['redeemed_points'] as num?)?.toInt() ?? 0;
        });
  }
}
