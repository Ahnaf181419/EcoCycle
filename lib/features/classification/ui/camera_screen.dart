import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hugeicons/hugeicons.dart';
import '../logic/classification_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/route_constants.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Narrow via `.select` so intermediate-state writes (category, confidence,
    // tfliteResult, etc.) during `classifyImage` don't churn the capture/
    // preview branches. The sub-widgets pull detail state themselves.
    final isProcessing =
        ref.watch(classificationProvider.select((s) => s.isProcessing));
    final hasImage = ref.watch(
      classificationProvider.select((s) => s.imagePath != null),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classify Waste'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: isProcessing
          ? _buildProcessingState(context, ref.watch(classificationProvider))
          : hasImage
          ? _buildPreviewState(
              context, ref, ref.watch(classificationProvider))
          : _buildCaptureState(context, ref),
    );
  }

  Widget _buildCaptureState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCamera01,
                  color: AppColors.primary,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            Text(
              'Snap or Pick',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'Take a photo or choose from gallery\nto classify your waste item',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space3XL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionChip(
                  icon: HugeIcons.strokeRoundedCamera01,
                  label: 'Camera',
                  onTap: () => ref
                      .read(classificationProvider.notifier)
                      .captureImage(ImageSource.camera),
                ),
                const SizedBox(width: AppSpacing.spaceLG),
                _ActionChip(
                  icon: HugeIcons.strokeRoundedImage01,
                  label: 'Gallery',
                  onTap: () => ref
                      .read(classificationProvider.notifier)
                      .captureImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewState(BuildContext context, WidgetRef ref, state) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceLG),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Image.file(File(state.imagePath!), fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(classificationProvider.notifier).reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(classificationProvider.notifier)
                        .classifyImage();
                    final newState = ref.read(classificationProvider);
                    if (newState.submissionId != null && context.mounted) {
                      context.go(
                        '${RouteConstants.result}/${newState.submissionId}',
                      );
                    } else if (newState.error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(newState.error!)),
                      );
                    }
                  },
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Classify'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState(BuildContext context, state) {
    String message;
    double progress;
    if (state.isCapturing) {
      message = 'Capturing image...';
      progress = 0.2;
    } else if (state.isUploading) {
      message = 'Uploading image...';
      progress = 0.5;
    } else {
      message = 'Analyzing your waste...';
      progress = 0.8;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedRecycle01,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXL),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSM),
            Text(
              'This may take a few seconds',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: AppColors.primary, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
