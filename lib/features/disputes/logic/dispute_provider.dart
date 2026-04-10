import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dispute_model.dart';
import '../data/repositories/dispute_repository.dart';
import '../../classification/data/services/supabase_function_service.dart';

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  return DisputeRepository();
});

final pendingDisputesProvider = StreamProvider<List<Dispute>>((ref) {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getPendingDisputes();
});

final disputeProvider = StreamProvider.family<Dispute?, String>((
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

final pendingDisputeCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(disputeRepositoryProvider);
  return repo.getPendingDisputeCount();
});

final disputeResolutionProvider =
    StateNotifierProvider<DisputeResolutionNotifier, DisputeResolutionState>((
      ref,
    ) {
      return DisputeResolutionNotifier(
        supabaseFunctionService: SupabaseFunctionService(),
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

  DisputeResolutionNotifier({
    required SupabaseFunctionService supabaseFunctionService,
  }) : _supabaseFunctionService = supabaseFunctionService,
       super(const DisputeResolutionState());

  Future<bool> resolve({
    required String disputeId,
    required String resolution,
    String? category,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await _supabaseFunctionService.resolveDispute(
        disputeId: disputeId,
        resolution: resolution,
        category: category,
        note: note,
      );
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const DisputeResolutionState();
  }
}
