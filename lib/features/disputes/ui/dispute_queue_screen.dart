// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../logic/dispute_provider.dart';
import '../data/models/dispute_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../core/constants/route_constants.dart';

class DisputeQueueScreen extends ConsumerWidget {
  const DisputeQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputesAsync = ref.watch(pendingDisputesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
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
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedJudge,
                              color: Colors.white,
                              size: 28,
                              strokeWidth: 1.5,
                            ),
                            const SizedBox(width: AppSpacing.spaceSM),
                            Text(
                              'Dispute Queue',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceSM),
                        disputesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (disputes) => Text(
                            '${disputes.length} pending',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          disputesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorView(
                message: 'Could not load disputes',
                onRetry: () => ref.invalidate(pendingDisputesProvider),
              ),
            ),
            data: (disputes) {
              if (disputes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space3XL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                            color: AppColors.success,
                            size: 56,
                            strokeWidth: 1.2,
                          ),
                          const SizedBox(height: AppSpacing.spaceXL),
                          Text(
                            'All clear!',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceSM),
                          Text(
                            'No pending disputes to review',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceLG,
                  vertical: AppSpacing.spaceSM,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _DisputeCard(dispute: disputes[index]),
                    childCount: disputes.length,
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
}

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;

  const _DisputeCard({required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.go('${RouteConstants.disputes}/${dispute.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceSM,
                        vertical: AppSpacing.space2XS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dispute.status,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dispute.createdAt.timeAgo,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                Text(
                  'Disputed Classification',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceSM),
                Row(
                  children: [
                    CategoryBadge(
                      category: dispute.originalCategory,
                      compact: true,
                      iconSize: 16,
                    ),
                    const SizedBox(width: AppSpacing.spaceSM),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.textTertiary,
                      size: 16,
                      strokeWidth: 1.5,
                    ),
                    const SizedBox(width: AppSpacing.spaceSM),
                    if (dispute.secondaryCategory != null)
                      CategoryBadge(
                        category: dispute.secondaryCategory!,
                        compact: true,
                        iconSize: 16,
                      )
                    else
                      Text(
                        '?',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceMD),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Review',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceXS),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.primary,
                      size: 16,
                      strokeWidth: 1.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
