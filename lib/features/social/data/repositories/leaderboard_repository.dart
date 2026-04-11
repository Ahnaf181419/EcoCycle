import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/constants/app_constants.dart';

class LeaderboardRepository {
  final SupabaseClient _client;

  LeaderboardRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<List<UserProfile>> getLeaderboard({
    int limit = AppConstants.leaderboardLimit,
  }) {
    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('is_private', false)
        .order('points', ascending: false)
        .limit(limit)
        .map(
          (rows) =>
              rows.map((row) => UserProfile.fromJson(row)).toList(),
        );
  }

  Stream<int> currentUserRank() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(-1);

    return _client
        .from(SupabaseTables.profiles)
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .limit(1)
        .asyncMap((rows) async {
          if (rows.isEmpty) return -1;
          final userPoints = (rows.first['points'] as num?)?.toInt() ?? 0;

          final countResponse = await _client
              .from(SupabaseTables.profiles)
              .select('uid')
              .eq('is_private', false)
              .gt('points', userPoints);

          return countResponse.length + 1;
        });
  }
}
