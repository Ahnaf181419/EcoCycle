import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/logic/auth_provider.dart';
import '../../home/ui/home_screen.dart' show recentSubmissionsProvider;
import '../../classification/data/models/submission_model.dart';
import '../../rewards/logic/reward_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/category_badge.dart';

class OwnProfileScreen extends ConsumerWidget {
  const OwnProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final balance = ref.watch(rewardBalanceProvider);
    final recentAsync = ref.watch(recentSubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () => context.go(RouteConstants.settings),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: Colors.white,
                  size: 24,
                  strokeWidth: 1.5,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.spaceXL,
                      AppSpacing.space3XL,
                      AppSpacing.spaceXL,
                      0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.spaceXL),
                        UserAvatar(
                          photoUrl: user?.photoUrl,
                          username: user?.displayName ?? 'U',
                          radius: 44,
                        ),
                        const SizedBox(height: AppSpacing.spaceMD),
                        Text(
                          user?.displayName ?? 'User',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '@${user?.username ?? "user"}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceLG),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileStat(
                              label: 'Points',
                              value: '${balance?.available ?? 0}',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _ProfileStat(
                              label: 'Classified',
                              value: '${user?.classificationCount ?? 0}',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _ProfileStat(
                              label: 'Followers',
                              value: '${user?.followerCount ?? 0}',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            _ProfileStat(
                              label: 'Following',
                              value: '${user?.followingCount ?? 0}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.spaceLG),
                _buildQuickStats(context, user, balance),
                const SizedBox(height: AppSpacing.spaceXL),
                _buildSectionHeader(context, 'Recent Submissions', () {
                  context.go(RouteConstants.history);
                }),
              ],
            ),
          ),
          recentAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.space3XL),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (submissions) {
              if (submissions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space3XL),
                    child: Column(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedRecycle01,
                          color: AppColors.textTertiary,
                          size: 48,
                          strokeWidth: 1.5,
                        ),
                        const SizedBox(height: AppSpacing.spaceLG),
                        Text(
                          'No submissions yet',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLG,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _SubmissionTile(submission: submissions[index]),
                    childCount: submissions.length,
                  ),
                ),
              );
            },
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.space3XL),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, user, RewardBalance? balance) {
    final accuracy = user?.accuracyRate ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              icon: HugeIcons.strokeRoundedTarget01,
              label: 'Accuracy',
              value: '${(accuracy * 100).toInt()}%',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: _QuickStatCard(
              icon: HugeIcons.strokeRoundedCoins01,
              label: 'Total Earned',
              value: '${balance?.totalEarned ?? 0}',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceLG,
        vertical: AppSpacing.spaceSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.statMedium.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(
              icon: icon,
              color: color,
              size: 20,
              strokeWidth: 1.5,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.statMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final Submission submission;

  const _SubmissionTile({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSM),
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (submission.category != null)
            CategoryBadge(
              category: submission.category!,
              compact: true,
              iconSize: 20,
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedHelpCircle,
                color: AppColors.textTertiary,
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
                  submission.category?.categoryDisplayName ?? 'Processing...',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  submission.createdAt.timeAgo,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (submission.pointsAwarded > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSM,
                vertical: AppSpacing.space2XS,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${submission.pointsAwarded}',
                style: AppTypography.statSmall.copyWith(
                  color: AppColors.accent,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
