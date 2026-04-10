import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../data/models/submission_model.dart';
import '../logic/classification_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../shared/widgets/category_badge.dart';
import '../../../../shared/widgets/points_display.dart';
import '../../../../shared/widgets/error_view.dart';

class SubmissionHistoryScreen extends ConsumerWidget {
  const SubmissionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(submissionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Failed to load history',
          onRetry: () => ref.invalidate(submissionHistoryProvider),
        ),
        data: (submissions) {
          if (submissions.isEmpty) return _buildEmpty(context);
          return _buildList(context, ref, submissions);
        },
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

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Submission> submissions,
  ) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(submissionHistoryProvider),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        itemCount: submissions.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.spaceSM),
        itemBuilder: (context, index) {
          return _SubmissionCard(submission: submissions[index]);
        },
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
        child: Image.network(
          submission.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
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
