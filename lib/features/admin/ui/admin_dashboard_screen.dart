import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../logic/admin_provider.dart';
import '../data/repositories/admin_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/datetime_extensions.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersCountAsync = ref.watch(totalUsersCountProvider);
    final submissionsCountAsync = ref.watch(totalSubmissionsCountProvider);
    final disputesCountAsync = ref.watch(adminPendingDisputesCountProvider);
    final auditLogAsync = ref.watch(recentAuditLogProvider);

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
                              icon: HugeIcons.strokeRoundedShield01,
                              color: Colors.white,
                              size: 28,
                              strokeWidth: 1.5,
                            ),
                            const SizedBox(width: AppSpacing.spaceSM),
                            Text(
                              'Admin Dashboard',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AdminStatCard(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          label: 'Users',
                          asyncValue: usersCountAsync,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceSM),
                      Expanded(
                        child: _AdminStatCard(
                          icon: HugeIcons.strokeRoundedRecycle01,
                          label: 'Submissions',
                          asyncValue: submissionsCountAsync,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spaceSM),
                      Expanded(
                        child: _AdminStatCard(
                          icon: HugeIcons.strokeRoundedAlert01,
                          label: 'Disputes',
                          asyncValue: disputesCountAsync,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceXL),
                  _AdminQuickLink(
                    icon: HugeIcons.strokeRoundedUserGroup,
                    label: 'User Management',
                    description: 'View and manage user roles',
                    color: AppColors.primary,
                    onTap: () => context.go(RouteConstants.adminUsers),
                  ),
                  const SizedBox(height: AppSpacing.spaceXL),
                  Text(
                    'Recent Audit Log',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceMD),
                ],
              ),
            ),
          ),
          auditLogAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.spaceXL),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (entries) {
              if (entries.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spaceXL),
                    child: Center(
                      child: Text(
                        'No audit entries yet',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
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
                    (context, index) => _AuditLogTile(entry: entries[index]),
                    childCount: entries.length,
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

class _AdminStatCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final AsyncValue<int> asyncValue;
  final Color color;

  const _AdminStatCard({
    required this.icon,
    required this.label,
    required this.asyncValue,
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
          asyncValue.when(
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => Text(
              '-',
              style: AppTypography.statMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            data: (value) => Text(
              '$value',
              style: AppTypography.statMedium.copyWith(
                color: AppColors.textPrimary,
              ),
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

class _AdminQuickLink extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _AdminQuickLink({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.spaceLG),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: color,
                  size: 24,
                  strokeWidth: 1.5,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceLG),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
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
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: AppColors.textTertiary,
                size: 20,
                strokeWidth: 1.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLogEntry entry;

  const _AuditLogTile({required this.entry});

  Color get _eventColor {
    switch (entry.eventType) {
      case 'ROLE_UPDATE':
        return AppColors.info;
      case 'CONFIG_UPDATE':
        return AppColors.warning;
      case 'DISPUTE_RESOLVE':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  List<List<dynamic>> get _eventIcon {
    switch (entry.eventType) {
      case 'ROLE_UPDATE':
        return HugeIcons.strokeRoundedUserGroup;
      case 'CONFIG_UPDATE':
        return HugeIcons.strokeRoundedSettings01;
      case 'DISPUTE_RESOLVE':
        return HugeIcons.strokeRoundedJudge;
      default:
        return HugeIcons.strokeRoundedInformationCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spaceSM),
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: _eventIcon,
            color: _eventColor,
            size: 20,
            strokeWidth: 1.5,
          ),
          const SizedBox(width: AppSpacing.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.eventType.replaceAll('_', ' '),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  entry.timestamp.timeAgo,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSM,
              vertical: AppSpacing.space2XS,
            ),
            decoration: BoxDecoration(
              color: _eventColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.actorRole,
              style: AppTypography.labelSmall.copyWith(color: _eventColor),
            ),
          ),
        ],
      ),
    );
  }
}
