// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../logic/reward_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';

class RedeemScreen extends ConsumerStatefulWidget {
  const RedeemScreen({super.key});

  @override
  ConsumerState<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends ConsumerState<RedeemScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedPreset = 0;

  static const _presets = [10, 25, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(rewardBalanceProvider);
    final redeemState = ref.watch(redeemProvider);
    final available = balance?.available ?? 0;

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
                        Text('Redeem Points',
                            style: AppTypography.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvailableCard(available),
                    const SizedBox(height: AppSpacing.spaceXL),
                    _buildPresetSelector(available),
                    const SizedBox(height: AppSpacing.spaceXL),
                    _buildCustomInput(),
                    const SizedBox(height: AppSpacing.spaceXL),
                    _buildInfoSection(),
                    const SizedBox(height: AppSpacing.space3XL),
                    _buildRedeemButton(redeemState, available),
                    if (redeemState.error != null)
                      _buildError(redeemState.error!),
                    if (redeemState.redeemedPoints != null)
                      _buildSuccess(redeemState),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableCard(int available) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Available to Redeem',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Text(
            '$available',
            style: AppTypography.statLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.spaceXS),
          Text(
            'points',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector(int available) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        Row(
          children: _presets.map((preset) {
            final isSelected = _selectedPreset == preset;
            final isEnabled = preset <= available;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.spaceSM),
                child: ChoiceChip(
                  label: Text('$preset'),
                  selected: isSelected && isEnabled,
                  onSelected: isEnabled
                      ? (_) {
                          setState(() {
                            _selectedPreset = preset;
                            _amountController.text = '$preset';
                          });
                        }
                      : null,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: isSelected && isEnabled
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  labelStyle: AppTypography.labelLarge.copyWith(
                    color: isSelected && isEnabled
                        ? AppColors.primary
                        : isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Custom Amount',
        hintText: 'Enter points to redeem',
        prefixIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedCoins01,
          color: AppColors.textTertiary,
          size: 20,
          strokeWidth: 1.5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter an amount';
        final amount = int.tryParse(value);
        if (amount == null || amount <= 0) return 'Enter a valid amount';
        return null;
      },
      onChanged: (value) {
        final amount = int.tryParse(value);
        if (amount != null) {
          setState(() {
            _selectedPreset = _presets.contains(amount) ? amount : 0;
          });
        }
      },
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedInformationCircle,
            color: AppColors.info,
            size: 20,
            strokeWidth: 1.5,
          ),
          const SizedBox(width: AppSpacing.spaceSM),
          Expanded(
            child: Text(
              'Redeemed points are final and cannot be reversed. '
              'Point values: Recyclable=${AppConstants.pointsRecyclable}, '
              'Organic=${AppConstants.pointsOrganic}, '
              'E-Waste=${AppConstants.pointsEWaste}, '
              'Hazardous=${AppConstants.pointsHazardous}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemButton(RedeemState redeemState, int available) {
    return FilledButton.icon(
      onPressed: redeemState.isRedeeming ? null : _onRedeem,
      icon: redeemState.isRedeeming
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const HugeIcon(
              icon: HugeIcons.strokeRoundedCoins01,
              color: Colors.white,
              size: 20,
              strokeWidth: 1.5,
            ),
      label: Text(redeemState.isRedeeming ? 'Processing...' : 'Redeem Points'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.surfaceVariant,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.spaceLG),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLG),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(error, style: const TextStyle(color: AppColors.error)),
      ),
    );
  }

  Widget _buildSuccess(redeemState) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.spaceLG),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceXL),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
              color: AppColors.success,
              size: 48,
              strokeWidth: 1.5,
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            Text(
              '${redeemState.redeemedPoints} points redeemed!',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.success,
              ),
            ),
            if (redeemState.newBalance != null) ...[
              const SizedBox(height: AppSpacing.spaceSM),
              Text(
                'New balance: ${redeemState.newBalance} points',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.spaceLG),
            FilledButton(
              onPressed: () => context.pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRedeem() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(_amountController.text);
    if (amount == null) return;

    final balance = ref.read(rewardBalanceProvider);
    if (balance == null) return;

    // Capture messenger BEFORE the async gap.
    final messenger = ScaffoldMessenger.of(context);

    if (amount > balance.available) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Insufficient points'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await ref.read(redeemProvider.notifier).redeemPoints(amount);
    if (!mounted) return;

    if (!result.success) {
      final err = result.error ?? 'Redeem failed';
      messenger.showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
