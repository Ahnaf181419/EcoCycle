import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../data/models/reward_model.dart';
import '../logic/reward_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/error_view.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(rewardBalanceProvider);
    final historyAsync = ref.watch(rewardHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(rewardHistoryProvider);
          ref.invalidate(totalEarnedProvider);
          ref.invalidate(totalRedeemedProvider);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: context.responsiveHeight(130, small: 145),
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.spaceLG,
                        AppSpacing.spaceLG,
                        AppSpacing.spaceLG,
                        AppSpacing.spaceSM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(children: [
                            HugeIcon(
                                icon: HugeIcons.strokeRoundedCoins01,
                                color: Colors.white,
                                size: 24,
                                strokeWidth: 1.5),
                            const SizedBox(width: AppSpacing.spaceSM),
                            Text('Rewards',
                                style: AppTypography.headlineSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildBalanceCard(context, ref, balanceAsync),
                  const SizedBox(height: AppSpacing.spaceXL),
                  _buildRedeemButton(context, balanceAsync),
                  const SizedBox(height: AppSpacing.spaceXL),
                  _buildHistoryHeader(),
                  const SizedBox(height: AppSpacing.spaceMD),
                  _buildHistoryList(historyAsync, ref),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WidgetRef ref,
    RewardBalance? balance,
  ) {
    final available = balance?.available ?? 0;
    final totalEarned = balance?.totalEarned ?? 0;
    final totalRedeemed = balance?.totalRedeemed ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Available Points',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            '$available',
            style: AppTypography.statLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Earned', totalEarned),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatColumn('Redeemed', totalRedeemed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTypography.statMedium.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRedeemButton(BuildContext context, RewardBalance? balance) {
    final available = balance?.available ?? 0;
    return FilledButton.icon(
      onPressed:
          available > 0 ? () => context.push(RouteConstants.redeem) : null,
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedCoins01,
        color: Colors.white,
        size: 20,
        strokeWidth: 1.5,
      ),
      label: const Text('Redeem Points'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        disabledBackgroundColor: AppColors.surfaceVariant,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activity',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(
    AsyncValue<List<Reward>> historyAsync,
    WidgetRef ref,
  ) {
    return historyAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ErrorView(
        message: 'Failed to load rewards',
        onRetry: () => ref.invalidate(rewardHistoryProvider),
      ),
      data: (rewards) {
        if (rewards.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.space3XL),
            child: Column(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCoins01,
                  color: AppColors.textTertiary,
                  size: 48,
                  strokeWidth: 1.5,
                ),
                const SizedBox(height: AppSpacing.spaceLG),
                Text(
                  'No rewards yet',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: rewards.map((r) => _RewardTile(reward: r)).toList(),
        );
      },
    );
  }
}

class _RewardTile extends StatelessWidget {
  final Reward reward;
  const _RewardTile({required this.reward});

  @override
  Widget build(BuildContext context) {
    final isRedemption = reward.type == 'redemption';
    final displayPoints = reward.points;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isRedemption ? AppColors.error : AppColors.success)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                icon: isRedemption
                    ? HugeIcons.strokeRoundedArrowDown01
                    : HugeIcons.strokeRoundedArrowUp01,
                color: isRedemption ? AppColors.error : AppColors.success,
                size: 20,
                strokeWidth: 1.5,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceLG),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRedemption ? 'Points Redeemed' : 'Classification Reward',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reward.createdAt.timeAgo,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isRedemption ? "-" : "+"}$displayPoints',
              style: AppTypography.statMedium.copyWith(
                color: isRedemption ? AppColors.error : AppColors.success,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
