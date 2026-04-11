import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/reward_model.dart';
import '../data/repositories/reward_repository.dart';
import '../../classification/data/services/supabase_function_service.dart';
import '../../classification/logic/classification_provider.dart';
import '../../auth/logic/auth_provider.dart';

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository();
});

final rewardHistoryProvider = StreamProvider.autoDispose<List<Reward>>((ref) {
  final repo = ref.watch(rewardRepositoryProvider);
  return repo.getRewardHistory();
});

final totalEarnedProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.watch(rewardRepositoryProvider);
  return repo.getTotalEarnedPoints();
});

final totalRedeemedProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.watch(rewardRepositoryProvider);
  return repo.getTotalRedeemedPoints();
});

final rewardBalanceProvider = Provider<RewardBalance?>((ref) {
  final earned = ref.watch(totalEarnedProvider);
  final redeemed = ref.watch(totalRedeemedProvider);

  if (earned.isLoading || redeemed.isLoading) return null;

  final earnedValue = earned.valueOrNull ?? 0;
  final redeemedValue = redeemed.valueOrNull ?? 0;

  return RewardBalance(
    totalEarned: earnedValue,
    totalRedeemed: redeemedValue,
    available:
        earnedValue - redeemedValue < 0 ? 0 : earnedValue - redeemedValue,
  );
});

class RewardBalance {
  final int totalEarned;
  final int totalRedeemed;
  final int available;

  const RewardBalance({
    required this.totalEarned,
    required this.totalRedeemed,
    required this.available,
  });
}

final redeemProvider = StateNotifierProvider<RedeemNotifier, RedeemState>((
  ref,
) {
  return RedeemNotifier(
    supabaseFunctionService: ref.watch(supabaseFunctionServiceProvider),
    userId: ref.watch(authProvider.select((s) => s.user?.uid)),
  );
});

class RedeemState {
  static const _sentinel = Object();

  final bool isRedeeming;
  final int? redeemedPoints;
  final int? newBalance;
  final String? error;

  const RedeemState({
    this.isRedeeming = false,
    this.redeemedPoints,
    this.newBalance,
    this.error,
  });

  RedeemState copyWith({
    bool? isRedeeming,
    Object? redeemedPoints = _sentinel,
    Object? newBalance = _sentinel,
    Object? error = _sentinel,
  }) {
    return RedeemState(
      isRedeeming: isRedeeming ?? this.isRedeeming,
      redeemedPoints: redeemedPoints == _sentinel
          ? this.redeemedPoints
          : redeemedPoints as int?,
      newBalance:
          newBalance == _sentinel ? this.newBalance : newBalance as int?,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

class RedeemNotifier extends StateNotifier<RedeemState> {
  final SupabaseFunctionService _supabaseFunctionService;
  final String? _userId;
  final _uuid = const Uuid();

  RedeemNotifier({
    required SupabaseFunctionService supabaseFunctionService,
    required String? userId,
  })  : _supabaseFunctionService = supabaseFunctionService,
        _userId = userId,
        super(const RedeemState());

  Future<({bool success, String? error})> redeemPoints(int points) async {
    if (_userId == null) {
      state = state.copyWith(
        isRedeeming: false,
        error: 'You must be signed in to redeem points.',
      );
      return (success: false, error: 'You must be signed in to redeem points.');
    }
    if (points <= 0) return (success: false, error: 'Invalid points amount');

    state = state.copyWith(
      isRedeeming: true,
      error: null,
      redeemedPoints: null,
      newBalance: null,
    );

    try {
      final idempotencyKey = _uuid.v4();
      final result = await _supabaseFunctionService.redeemPoints(
        points: points,
        idempotencyKey: idempotencyKey,
      );
      if (!mounted) return (success: true, error: null);

      state = state.copyWith(
        isRedeeming: false,
        redeemedPoints: points,
        newBalance: result['availableBalance'] as int?,
      );
      return (success: true, error: null);
    } catch (e) {
      if (!mounted) return (success: false, error: e.toString());
      final errorMsg = e.toString();
      state = state.copyWith(isRedeeming: false, error: errorMsg);
      return (success: false, error: errorMsg);
    }
  }

  void reset() {
    state = const RedeemState();
  }
}
