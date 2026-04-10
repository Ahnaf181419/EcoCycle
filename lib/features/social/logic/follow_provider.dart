import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/follow_repository.dart';
import '../../classification/data/services/supabase_function_service.dart';
import '../../auth/logic/auth_provider.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository();
});

final isFollowingProvider = StreamProvider.family<bool, String>((
  ref,
  targetUid,
) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.isFollowing(targetUid);
});

final followingIdsProvider = StreamProvider<List<String>>((ref) {
  ref.watch(authProvider);
  final repo = ref.watch(followRepositoryProvider);
  return repo.getFollowingIds();
});

final followActionProvider =
    StateNotifierProvider<FollowActionNotifier, FollowActionState>((ref) {
      return FollowActionNotifier(
        supabaseFunctionService: SupabaseFunctionService(),
      );
    });

class FollowActionState {
  final bool isLoading;
  final String? error;

  const FollowActionState({this.isLoading = false, this.error});

  FollowActionState copyWith({bool? isLoading, String? error}) {
    return FollowActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FollowActionNotifier extends StateNotifier<FollowActionState> {
  final SupabaseFunctionService _supabaseFunctionService;

  FollowActionNotifier({
    required SupabaseFunctionService supabaseFunctionService,
  }) : _supabaseFunctionService = supabaseFunctionService,
       super(const FollowActionState());

  Future<bool> follow(String targetUserId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseFunctionService.followUser(targetUserId: targetUserId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> unfollow(String targetUserId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseFunctionService.unfollowUser(targetUserId: targetUserId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
