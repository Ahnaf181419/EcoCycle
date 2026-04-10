import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/leaderboard_repository.dart';
import '../../auth/logic/auth_provider.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

final leaderboardProvider = StreamProvider<List<UserProfile>>((ref) {
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.getLeaderboard();
});

final currentUserRankProvider = StreamProvider<int>((ref) {
  ref.watch(authProvider);
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.currentUserRank();
});
