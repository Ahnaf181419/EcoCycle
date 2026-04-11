// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/models/submission_model.dart';
import '../logic/classification_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../shared/widgets/points_display.dart';
import '../../../shared/widgets/error_view.dart';

class SubmissionHistoryScreen extends ConsumerWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(submissionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
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
                        Row(
                          children: [
                            HugeIcon(
                                icon: HugeIcons.strokeRoundedTime01,
                                color: Colors.white,
                                size: 24,
                                strokeWidth: 1.5),
                            const SizedBox(width: AppSpacing.spaceSM),
                            Text('Submission History',
                                style: AppTypography.headlineSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...historyAsync.when(
            loading: () => [
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            ],
            error: (e, _) => [
              SliverFillRemaining(
                  child: ErrorView(
                message: 'Failed to load history',
                onRetry: () => ref.invalidate(submissionHistoryProvider),
              ))
            ],
            data: (submissions) {
              if (submissions.isEmpty) {
                return [SliverFillRemaining(child: _buildEmpty(context))];
              }
              return [_buildSliverList(context, ref, submissions)];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedArchive01,
              color: AppColors.textTertiary,
              size: 64,
              strokeWidth: 1.5,
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            Text(
              'No submissions yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'Start classifying waste to see your history here!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            FilledButton.icon(
              onPressed: () => context.go(RouteConstants.classify),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Classifying'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceXL,
                  vertical: AppSpacing.spaceLG,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverList(
    BuildContext context,
    WidgetRef ref,
    List<Submission> submissions,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index.isOdd) return const SizedBox(height: AppSpacing.spaceSM);
            final itemIndex = index ~/ 2;
            return _SubmissionCard(submission: submissions[itemIndex]);
          },
          childCount: submissions.length * 2 - 1,
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final Submission submission;

  const _SubmissionCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.go('${RouteConstants.result}/${submission.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: AppSpacing.spaceLG),
              Expanded(child: _buildInfo(context)),
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CachedNetworkImage(
          imageUrl: submission.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (_, __, ___) => const Center(
            child: Icon(
              Icons.broken_image,
              color: AppColors.textTertiary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (submission.category != null)
          CategoryBadge(
            category: submission.category!,
            subcategory: submission.subcategory,
            compact: true,
          )
        else
          Text(
            submission.state.name.stateDisplayName,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        const SizedBox(height: AppSpacing.spaceXS),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _stateColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              submission.state.name.stateDisplayName,
              style: AppTypography.bodySmall.copyWith(
                color: _stateColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space2XS),
        Text(
          submission.createdAt.timeAgo,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    if (submission.pointsAwarded > 0) {
      return PointsDisplay(
        points: submission.pointsAwarded,
        animate: false,
        isLarge: false,
      );
    }
    if (submission.state == SubmissionState.flaggedDuplicate) {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedCancel01,
        color: AppColors.error,
        size: 20,
        strokeWidth: 1.5,
      );
    }
    if (submission.state == SubmissionState.disputed) {
      return HugeIcon(
        icon: HugeIcons.strokeRoundedAlert01,
        color: AppColors.warning,
        size: 20,
        strokeWidth: 1.5,
      );
    }
    return const SizedBox.shrink();
  }

  Color get _stateColor {
    switch (submission.state) {
      case SubmissionState.rewarded:
        return AppColors.success;
      case SubmissionState.disputed:
        return AppColors.warning;
      case SubmissionState.flaggedDuplicate:
      case SubmissionState.rejected:
        return AppColors.error;
      case SubmissionState.resolved:
        return AppColors.info;
      default:
        return AppColors.textTertiary;
    }
  }
}
