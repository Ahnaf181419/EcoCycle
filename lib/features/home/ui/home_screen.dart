import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/logic/auth_provider.dart';
import '../../social/data/models/user_profile_model.dart';
import '../../classification/logic/classification_provider.dart';
import '../../classification/data/models/submission_model.dart';
import '../../rewards/logic/reward_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../shared/widgets/user_avatar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
          _buildSliverAppBar(context, user),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsRow(balance),
                const SizedBox(height: AppSpacing.spaceXL),
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.spaceXL),
                _buildRecentHeader(context),
              ],
            ),
          ),
          _buildRecentList(recentAsync),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.space3XL),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserProfile? user) {
    return SliverAppBar(
      expandedHeight: 160,
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
                AppSpacing.spaceXL,
                AppSpacing.space3XL,
                AppSpacing.spaceXL,
                AppSpacing.spaceLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        radius: 24,
                        photoUrl: user?.photoUrl,
                        username: user?.displayName ?? 'U',
                      ),
                      const SizedBox(width: AppSpacing.spaceLG),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.displayName ?? "User"}!',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@${user?.username ?? "user"}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(RewardBalance? balance) {
    final available = balance?.available ?? 0;
    final earned = balance?.totalEarned ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: HugeIcons.strokeRoundedCoins01,
              label: 'Points',
              value: '$available',
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: _StatCard(
              icon: HugeIcons.strokeRoundedTarget01,
              label: 'Earned',
              value: '$earned',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: _StatCard(
              icon: HugeIcons.strokeRoundedRecycle01,
              label: 'Classified',
              value: (balance?.totalEarned ?? 0) > 0 ? 'Active' : 'New',
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Row(
            children: [
              _QuickActionCard(
                icon: HugeIcons.strokeRoundedCamera01,
                label: 'Classify',
                color: AppColors.primary,
                onTap: () => context.go(RouteConstants.classify),
              ),
              const SizedBox(width: AppSpacing.spaceSM),
              _QuickActionCard(
                icon: HugeIcons.strokeRoundedTime01,
                label: 'History',
                color: AppColors.info,
                onTap: () => context.go(RouteConstants.history),
              ),
              const SizedBox(width: AppSpacing.spaceSM),
              _QuickActionCard(
                icon: HugeIcons.strokeRoundedCoins01,
                label: 'Rewards',
                color: AppColors.accent,
                onTap: () => context.go(RouteConstants.rewards),
              ),
              const SizedBox(width: AppSpacing.spaceSM),
              _QuickActionCard(
                icon: HugeIcons.strokeRoundedMedal01,
                label: 'Board',
                color: AppColors.success,
                onTap: () => context.go(RouteConstants.leaderboard),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Activity',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.history),
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList(AsyncValue<List<Submission>> recentAsync) {
    return recentAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space3XL),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceXL),
          child: Text(
            'Could not load recent activity',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (submissions) {
        if (submissions.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3XL),
              child: Column(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedRecycle01,
                    color: AppColors.textTertiary,
                    size: 48,
                    strokeWidth: 1.5,
                  ),
                  const SizedBox(height: AppSpacing.spaceLG),
                  Text(
                    'Start your eco journey!',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceSM),
                  Text(
                    'Classify waste to earn points and track your impact',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _RecentTile(submission: submissions[index]),
              childCount: submissions.length,
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
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
      child: Column(
        children: [
          HugeIcon(icon: icon, color: color, size: 24, strokeWidth: 1.5),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            value,
            style: AppTypography.statMedium.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.spaceLG,
              horizontal: AppSpacing.spaceSM,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: HugeIcon(
                    icon: icon,
                    color: color,
                    size: 22,
                    strokeWidth: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSM),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final Submission submission;

  const _RecentTile({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.go('${RouteConstants.result}/${submission.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceLG,
            vertical: AppSpacing.spaceMD,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    submission.state.name.stateDisplayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const Spacer(),
              if (submission.pointsAwarded > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${submission.pointsAwarded}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.spaceSM),
              Text(
                submission.createdAt.timeAgo,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
