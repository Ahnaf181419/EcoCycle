import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';
import '../../auth/logic/auth_provider.dart';
import '../../classification/data/services/supabase_function_service.dart';
import '../../classification/logic/classification_provider.dart';
import '../../social/data/models/user_profile_model.dart';
import '../../../core/constants/user_role.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

/// Admin-only user list. `autoDispose` ensures the Supabase realtime channel
/// closes as soon as the admin dashboard leaves the navigation stack.
/// Non-admin callers get a stream error instead of silently relying on RLS.
final allUsersProvider =
    StreamProvider.autoDispose<List<UserProfile>>((ref) {
  final role = UserRole.fromString(ref.watch(authProvider).user?.role);
  if (!role.isAdmin) {
    return Stream.error(StateError('Not authorized'));
  }
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllUsers();
});

final totalUsersCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getTotalUsers();
});

final totalSubmissionsCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getTotalSubmissions();
});

final adminPendingDisputesCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPendingDisputesCount();
});

final recentAuditLogProvider = StreamProvider<List<AuditLogEntry>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getRecentAuditLog();
});

final roleUpdateProvider =
    StateNotifierProvider<RoleUpdateNotifier, RoleUpdateState>((ref) {
  return RoleUpdateNotifier(
    supabaseFunctionService: ref.watch(supabaseFunctionServiceProvider),
  );
});

class RoleUpdateState {
  final bool isLoading;
  final String? error;
  final bool success;

  const RoleUpdateState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  RoleUpdateState copyWith({bool? isLoading, String? error, bool? success}) {
    return RoleUpdateState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class RoleUpdateNotifier extends StateNotifier<RoleUpdateState> {
  final SupabaseFunctionService _supabaseFunctionService;

  RoleUpdateNotifier({required SupabaseFunctionService supabaseFunctionService})
      : _supabaseFunctionService = supabaseFunctionService,
        super(const RoleUpdateState());

  Future<bool> updateRole(String targetUserId, String newRole) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _supabaseFunctionService.updateRole(
        targetUserId: targetUserId,
        newRole: newRole,
      );
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const RoleUpdateState();
  }
}
