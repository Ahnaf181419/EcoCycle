import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/follow_repository.dart';
import '../../classification/data/services/supabase_function_service.dart';
import '../../classification/logic/classification_provider.dart';
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

final followActionProvider = StateNotifierProvider.family<FollowActionNotifier,
    FollowActionState, String>((ref, targetUid) {
  return FollowActionNotifier(
    supabaseFunctionService: ref.watch(supabaseFunctionServiceProvider),
    targetUid: targetUid,
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
  final String targetUid;

  FollowActionNotifier({
    required SupabaseFunctionService supabaseFunctionService,
    required this.targetUid,
  })  : _supabaseFunctionService = supabaseFunctionService,
        super(const FollowActionState());

  Future<bool> follow() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseFunctionService.followUser(targetUserId: targetUid);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> unfollow() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseFunctionService.unfollowUser(targetUserId: targetUid);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
