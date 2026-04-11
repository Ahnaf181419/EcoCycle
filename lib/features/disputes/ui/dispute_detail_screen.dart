import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../logic/dispute_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../shared/widgets/confidence_bar.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/models/dispute_model.dart';

class DisputeDetailScreen extends ConsumerStatefulWidget {
  final String disputeId;

  const DisputeDetailScreen({super.key, required this.disputeId});

  @override
  ConsumerState<DisputeDetailScreen> createState() =>
      _DisputeDetailScreenState();
}

class _DisputeDetailScreenState extends ConsumerState<DisputeDetailScreen> {
  final _noteController = TextEditingController();
  String? _selectedCategory;
  String _selectedResolution = 'APPROVE';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disputeAsync = ref.watch(disputeProvider(widget.disputeId));
    final resolutionState = ref.watch(disputeResolutionProvider);

    return LoadingOverlay(
      isLoading: resolutionState.isLoading,
      message: 'Resolving dispute...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Dispute Detail'),
          backgroundColor: AppColors.surface,
        ),
        body: disputeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            message: 'Could not load dispute',
            onRetry: () => ref.invalidate(disputeProvider(widget.disputeId)),
          ),
          data: (dispute) {
            if (dispute == null) {
              return const ErrorView(message: 'Dispute not found');
            }

            if (dispute.status != 'PENDING') {
              return _ResolvedView(dispute: dispute);
            }

            return _PendingView(
              dispute: dispute,
              noteController: _noteController,
              selectedCategory: _selectedCategory,
              selectedResolution: _selectedResolution,
              onCategoryChanged: (v) => setState(() => _selectedCategory = v),
              onResolutionChanged: (v) =>
                  setState(() => _selectedResolution = v),
              onResolve: _handleResolve,
            );
          },
        ),
      ),
    );
  }

  void _handleResolve() {
    if (_selectedResolution == 'OVERRIDE' && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for override'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String? category;
    if (_selectedResolution == 'OVERRIDE') {
      category = _selectedCategory;
    }

    ref
        .read(disputeResolutionProvider.notifier)
        .resolve(
          disputeId: widget.disputeId,
          resolution: _selectedResolution,
          category: category,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        )
        .then((success) {
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dispute resolved successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (!success && mounted) {
            final error = ref.read(disputeResolutionProvider).error;
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        });
  }
}

class _PendingView extends StatelessWidget {
  final Dispute dispute;
  final TextEditingController noteController;
  final String? selectedCategory;
  final String selectedResolution;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onResolutionChanged;
  final VoidCallback onResolve;

  const _PendingView({
    required this.dispute,
    required this.noteController,
    required this.selectedCategory,
    required this.selectedResolution,
    required this.onCategoryChanged,
    required this.onResolutionChanged,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original Classification',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryBadge(category: dispute.originalCategory),
                const SizedBox(height: AppSpacing.spaceMD),
                ConfidenceBar(
                  confidence: dispute.originalConfidence,
                  label: 'Confidence',
                  animate: false,
                ),
              ],
            ),
          ),
          if (dispute.secondaryCategory != null) ...[
            const SizedBox(height: AppSpacing.spaceXL),
            Text(
              'Secondary Classification',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(category: dispute.secondaryCategory!),
                  const SizedBox(height: AppSpacing.spaceMD),
                  if (dispute.secondaryConfidence != null)
                    ConfidenceBar(
                      confidence: dispute.secondaryConfidence!,
                      label: 'Confidence',
                      animate: false,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.spaceXL),
          Text(
            'Resolution',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ResolutionOption(
                  label: 'Approve Original',
                  description: 'Confirm the original classification',
                  value: 'APPROVE',
                  groupValue: selectedResolution,
                  color: AppColors.success,
                  onChanged: onResolutionChanged,
                ),
                const SizedBox(height: AppSpacing.spaceSM),
                _ResolutionOption(
                  label: 'Override',
                  description: 'Change to a different category',
                  value: 'OVERRIDE',
                  groupValue: selectedResolution,
                  color: AppColors.warning,
                  onChanged: onResolutionChanged,
                ),
                const SizedBox(height: AppSpacing.spaceSM),
                _ResolutionOption(
                  label: 'Reject',
                  description: 'Reject the submission',
                  value: 'REJECT',
                  groupValue: selectedResolution,
                  color: AppColors.error,
                  onChanged: onResolutionChanged,
                ),
              ],
            ),
          ),
          if (selectedResolution == 'OVERRIDE') ...[
            const SizedBox(height: AppSpacing.spaceMD),
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceSM),
                  Wrap(
                    spacing: AppSpacing.spaceSM,
                    runSpacing: AppSpacing.spaceSM,
                    children: ['recyclable', 'organic', 'e_waste', 'hazardous']
                        .map(
                          (cat) => ChoiceChip(
                            label: Text(cat.categoryDisplayName),
                            selected: selectedCategory == cat,
                            onSelected: (_) => onCategoryChanged(cat),
                            selectedColor: AppColors.categoryLightColor(cat),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.spaceMD),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onResolve,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Submit Resolution',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolutionOption extends StatelessWidget {
  final String label;
  final String description;
  final String value;
  final String groupValue;
  final Color color;
  final ValueChanged<String> onChanged;

  const _ResolutionOption({
    required this.label,
    required this.description,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : AppColors.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedView extends StatelessWidget {
  final Dispute dispute;

  const _ResolvedView({required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
              color: AppColors.success,
              size: 64,
              strokeWidth: 1.2,
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            Text(
              'Already Resolved',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'Resolution: ${dispute.resolution}',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (dispute.resolvedCategory != null) ...[
              const SizedBox(height: AppSpacing.spaceMD),
              CategoryBadge(category: dispute.resolvedCategory!),
            ],
          ],
        ),
      ),
    );
  }
}
