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

          final items = <FeedItem>[];
          for (final row in submissionsSnapshot) {
            final submission = Submission.fromJson(row);
            final userResponse = await _client
                .from(SupabaseTables.profiles)
                .select()
                .eq('uid', submission.userId)
                .maybeSingle();

            if (userResponse != null) {
              final user = UserProfile.fromJson(userResponse);
              if (!user.isPrivate) {
                items.add(FeedItem(submission: submission, user: user));
              }
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

    final items = <FeedItem>[];
    for (final row in snapshot) {
      final submission = Submission.fromJson(row);
      final userResponse = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('uid', submission.userId)
          .maybeSingle();

      if (userResponse != null) {
        final user = UserProfile.fromJson(userResponse);
        if (!user.isPrivate) {
          items.add(FeedItem(submission: submission, user: user));
        }
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
