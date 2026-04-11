import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/leaderboard_repository.dart';
import '../../auth/logic/auth_provider.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

final leaderboardProvider =
    StreamProvider.autoDispose<List<UserProfile>>((ref) {
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.getLeaderboard();
});

final currentUserRankProvider = StreamProvider.autoDispose<int>((ref) {
  ref.watch(authProvider.select((s) => s.user?.uid));
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.currentUserRank();
});
