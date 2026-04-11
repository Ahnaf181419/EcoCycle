import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../classification/data/models/submission_model.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/constants/app_constants.dart';

class FeedRepository {
  final SupabaseClient _client;

  FeedRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConstants.client;

  /// Streams the feed of followed users' submissions.
  ///
  /// Strategy:
  /// - The follow-set is read ONCE when the stream is subscribed, not on every
  ///   emission. A realtime subscription on `follows` would otherwise re-run
  ///   an expensive two-query pipeline for every mutation in the follow graph.
  /// - The `submissions` realtime stream is then filtered in-memory against
  ///   that set, and profiles are batch-loaded per emission in a single
  ///   `inFilter('uid', ...)` call — no N+1.
  /// - Users who add/remove follows will see the change after re-subscribing
  ///   (e.g. pull-to-refresh / invalidate).
  Stream<List<FeedItem>> getFeed(
      {int limit = AppConstants.feedPageSize}) async* {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      yield const [];
      return;
    }

    final followRows = await _client
        .from(SupabaseTables.follows)
        .select('followee_id')
        .eq('follower_id', uid);

    final followedIds =
        followRows.map<String>((row) => row['followee_id'] as String).toSet();

    if (followedIds.isEmpty) {
      yield const [];
      return;
    }

    const allowedStates = {'CLASSIFIED', 'VERIFIED', 'REWARDED'};

    yield* _client
        .from(SupabaseTables.submissions)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(limit * 2)
        .asyncMap<List<FeedItem>>((rows) async {
          final filtered = rows
              .where((r) => followedIds.contains(r['user_id']))
              .where((r) => allowedStates.contains(r['state']))
              .take(limit)
              .map((r) => Submission.fromJson(r))
              .toList();

          if (filtered.isEmpty) return const [];

          final userIds = filtered.map((s) => s.userId).toSet().toList();

          final userRows = await _client
              .from(SupabaseTables.profiles)
              .select()
              .inFilter('uid', userIds);

          final userMap = <String, UserProfile>{
            for (final row in userRows)
              (row['uid'] as String): UserProfile.fromJson(row),
          };

          final items = <FeedItem>[];
          for (final submission in filtered) {
            final user = userMap[submission.userId];
            if (user != null && !user.isPrivate) {
              items.add(FeedItem(submission: submission, user: user));
            }
          }
          return items;
        });
  }

  Future<List<FeedItem>> getFeedPaginated({
    int limit = AppConstants.feedPageSize,
    int offset = 0,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final followsSnapshot = await _client
        .from(SupabaseTables.follows)
        .select('followee_id')
        .eq('follower_id', uid);

    final followedIds =
        followsSnapshot.map((row) => row['followee_id'] as String).toList();

    if (followedIds.isEmpty) return [];

    final snapshot = await _client
        .from(SupabaseTables.submissions)
        .select()
        .inFilter('user_id', followedIds)
        .inFilter('state', ['CLASSIFIED', 'VERIFIED', 'REWARDED'])
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final submissions =
        snapshot.map((row) => Submission.fromJson(row)).toList();

    final userIds = submissions.map((s) => s.userId).toSet().toList();

    if (userIds.isEmpty) return [];

    final usersSnapshot = await _client
        .from(SupabaseTables.profiles)
        .select()
        .inFilter('uid', userIds);

    final userMap = <String, UserProfile>{};
    for (final row in usersSnapshot) {
      final user = UserProfile.fromJson(row);
      userMap[user.uid] = user;
    }

    final items = <FeedItem>[];
    for (final submission in submissions) {
      final user = userMap[submission.userId];
      if (user != null && !user.isPrivate) {
        items.add(FeedItem(submission: submission, user: user));
      }
    }
    return items;
  }
}

class FeedItem {
  final Submission submission;
  final UserProfile user;

  const FeedItem({required this.submission, required this.user});
}
