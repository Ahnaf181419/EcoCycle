import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';

class FollowRepository {
  final SupabaseClient _client;

  FollowRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<bool> isFollowing(String targetUid) {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(false);

    return _client
        .from(SupabaseTables.follows)
        .stream(primaryKey: ['follower_id', 'followee_id'])
        .eq('follower_id', uid)
        .map((rows) {
          return rows.any((row) => row['followee_id'] == targetUid);
        });
  }

  Future<bool> checkFollowStatus(String targetUid) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;

    final response = await _client
        .from(SupabaseTables.follows)
        .select()
        .eq('follower_id', uid)
        .eq('followee_id', targetUid)
        .maybeSingle();

    return response != null;
  }

  Stream<List<String>> getFollowingIds() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value([]);

    return _client
        .from(SupabaseTables.follows)
        .stream(primaryKey: ['follower_id', 'followee_id'])
        .eq('follower_id', uid)
        .map(
          (rows) => rows.map((row) => row['followee_id'] as String).toList(),
        );
  }
}
