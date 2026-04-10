import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';
import '../../classification/data/services/supabase_function_service.dart';
import '../../social/data/models/user_profile_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final allUsersProvider = StreamProvider<List<UserProfile>>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllUsers();
});

final totalUsersCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getTotalUsers();
});

final totalSubmissionsCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getTotalSubmissions();
});

final adminPendingDisputesCountProvider = StreamProvider<int>((ref) {
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
        supabaseFunctionService: SupabaseFunctionService(),
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
