import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../classification/data/models/submission_model.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/constants/app_constants.dart';

class FeedRepository {
  final SupabaseClient _client;

  FeedRepository({SupabaseClient? client})
    : _client = client ?? SupabaseConstants.client;

  Stream<List<FeedItem>> getFeed({int limit = AppConstants.feedPageSize}) {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value([]);

    return _client
        .from(SupabaseTables.follows)
        .stream(primaryKey: ['follower_id', 'followee_id'])
        .eq('follower_id', uid)
        .asyncMap((followRows) async {
          final followedIds = followRows
              .map((row) => row['followee_id'] as String)
              .toList();

          if (followedIds.isEmpty) return <FeedItem>[];

          final submissionsSnapshot = await _client
              .from(SupabaseTables.submissions)
              .select()
              .inFilter('user_id', followedIds)
              .inFilter('state', ['CLASSIFIED', 'VERIFIED', 'REWARDED'])
              .order('created_at', ascending: false)
              .limit(limit);

          final submissions = submissionsSnapshot
              .map((row) => Submission.fromJson(row))
              .toList();

          final userIds = submissions
              .map((s) => s.userId)
              .toSet()
              .toList();

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

    final followedIds = followsSnapshot
        .map((row) => row['followee_id'] as String)
        .toList();

    if (followedIds.isEmpty) return [];

    final snapshot = await _client
        .from(SupabaseTables.submissions)
        .select()
        .inFilter('user_id', followedIds)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final submissions = snapshot
        .map((row) => Submission.fromJson(row))
        .toList();

    final userIds = submissions
        .map((s) => s.userId)
        .toSet()
        .toList();

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
