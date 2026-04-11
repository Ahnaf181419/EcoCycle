import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dispute_model.dart';
import '../data/repositories/dispute_repository.dart';
import '../../classification/data/services/supabase_function_service.dart';
import '../../classification/logic/classification_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/constants/user_role.dart';

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  return DisputeRepository();
});

final pendingDisputesProvider =
    StreamProvider.autoDispose<List<Dispute>>((ref) {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getPendingDisputes();
});

final disputeProvider = StreamProvider.autoDispose.family<Dispute?, String>((
  ref,
  disputeId,
) {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getDispute(disputeId);
});

final submissionImageUrlProvider = FutureProvider.family<String?, String>((
  ref,
  submissionId,
) {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getSubmissionImageUrl(submissionId);
});

final pendingDisputeCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getPendingDisputeCount();
});

final disputeResolutionProvider =
    StateNotifierProvider<DisputeResolutionNotifier, DisputeResolutionState>((
  ref,
) {
  final userRole = ref.watch(authProvider.select((s) => s.user?.role));
  return DisputeResolutionNotifier(
    supabaseFunctionService: ref.watch(supabaseFunctionServiceProvider),
    userRole: UserRole.fromString(userRole),
  );
});

class DisputeResolutionState {
  final bool isLoading;
  final String? error;
  final bool success;

  const DisputeResolutionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  DisputeResolutionState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return DisputeResolutionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class DisputeResolutionNotifier extends StateNotifier<DisputeResolutionState> {
  final SupabaseFunctionService _supabaseFunctionService;
  final UserRole _userRole;

  /// Server-side enum of allowed categories. Keep in sync with the DB CHECK
  /// constraint / edge-function validator.
  static const _validCategories = {
    'recyclable',
    'organic',
    'ewaste',
    'hazardous',
  };

  static const _validResolutions = {'approve', 'reject', 'reclassify'};
  static const _maxNoteLength = 500;

  DisputeResolutionNotifier({
    required SupabaseFunctionService supabaseFunctionService,
    required UserRole userRole,
  })  : _supabaseFunctionService = supabaseFunctionService,
        _userRole = userRole,
        super(const DisputeResolutionState());

  Future<bool> resolve({
    required String disputeId,
    required String resolution,
    String? category,
    String? note,
  }) async {
    if (!_userRole.canModerateDisputes) {
      state = state.copyWith(
        isLoading: false,
        error: 'Only moderators or admins can resolve disputes',
        success: false,
      );
      return false;
    }

    if (!_validResolutions.contains(resolution)) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid resolution "$resolution"',
        success: false,
      );
      return false;
    }

    if (category != null && !_validCategories.contains(category)) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid category "$category"',
        success: false,
      );
      return false;
    }

    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.length > _maxNoteLength) {
      state = state.copyWith(
        isLoading: false,
        error: 'Note must be $_maxNoteLength characters or fewer',
        success: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _supabaseFunctionService.resolveDispute(
        disputeId: disputeId,
        resolution: resolution,
        category: category,
        note: trimmedNote?.isEmpty == true ? null : trimmedNote,
      );
      if (!mounted) return true;
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const DisputeResolutionState();
  }
}
