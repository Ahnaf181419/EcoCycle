// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/models/submission_model.dart';
import '../logic/classification_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/category_badge.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../../../shared/widgets/points_display.dart';

class ClassificationResultScreen extends ConsumerWidget {
  final String submissionId;

  const ClassificationResultScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionAsync = ref.watch(submissionDetailProvider(submissionId));

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
                        Text(
                          'Classification Result',
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: submissionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (submission) {
                if (submission == null) {
                  return const Center(child: Text('Submission not found'));
                }
                return _buildResult(context, ref, submission);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(
      BuildContext context, WidgetRef ref, Submission submission) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusBanner(submission),
          const SizedBox(height: AppSpacing.spaceXL),
          if (submission.category != null)
            _buildCategoryResult(context, submission),
          if (submission.state == SubmissionState.flaggedDuplicate)
            _buildDuplicateBanner(),
          if (submission.state == SubmissionState.disputed)
            _buildDisputedBanner(),
          if (submission.pointsAwarded > 0) ...[
            const SizedBox(height: AppSpacing.spaceLG),
            _buildPointsCard(submission),
          ],
          const SizedBox(height: AppSpacing.spaceXL),
          _buildImagePreview(submission),
          const SizedBox(height: AppSpacing.spaceXL),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Submission submission) {
    Color bannerColor;
    String statusText;
    List<List<dynamic>> statusIcon;

    switch (submission.state) {
      case SubmissionState.rewarded:
        bannerColor = AppColors.success;
        statusText = 'Classification Complete!';
        statusIcon = HugeIcons.strokeRoundedCheckmarkCircle01;
        break;
      case SubmissionState.resolved:
        bannerColor = AppColors.success;
        statusText = 'Dispute Resolved!';
        statusIcon = HugeIcons.strokeRoundedCheckmarkCircle01;
        break;
      case SubmissionState.disputed:
        bannerColor = AppColors.warning;
        statusText = 'Under Review';
        statusIcon = HugeIcons.strokeRoundedAlert01;
        break;
      case SubmissionState.flaggedDuplicate:
        bannerColor = AppColors.error;
        statusText = 'Duplicate Detected';
        statusIcon = HugeIcons.strokeRoundedCancel01;
        break;
      case SubmissionState.rejected:
        bannerColor = AppColors.error;
        statusText = 'Rejected';
        statusIcon = HugeIcons.strokeRoundedCancel01;
        break;
      default:
        bannerColor = AppColors.info;
        statusText = 'Processing...';
        statusIcon = HugeIcons.strokeRoundedLoading03;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: statusIcon, color: bannerColor, size: 32),
          const SizedBox(width: AppSpacing.spaceMD),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryResult(BuildContext context, Submission submission) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Classification',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSpacing.spaceLG),
          CategoryBadge(
            category: submission.category!,
            subcategory: submission.subcategory,
            iconSize: 48,
          ),
          if (submission.confidence != null) ...[
            const SizedBox(height: AppSpacing.spaceLG),
            ConfidenceBar(confidence: submission.confidence!),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsCard(Submission submission) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: AppColors.accent, size: 32),
          const SizedBox(width: AppSpacing.spaceMD),
          PointsDisplay(points: submission.pointsAwarded, isLarge: true),
          const SizedBox(width: AppSpacing.spaceSM),
          const Text(
            'Points Earned!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.error),
          SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: Text(
              'This image was flagged as a duplicate of a recent submission.',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputedBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning),
          SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: Text(
              'Low confidence result. A moderator will review this classification.',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(Submission submission) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
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
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () {
            ref.read(classificationProvider.notifier).reset();
            context.go(RouteConstants.classify);
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Classify Another'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSM),
        TextButton(
          onPressed: () => context.go(RouteConstants.history),
          child: const Text('View History'),
        ),
      ],
    );
  }
}
