import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../logic/admin_provider.dart';
import '../../social/data/models/user_profile_model.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/error_view.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

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
                        Text('User Management',
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
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spaceLG),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: AppColors.textTertiary,
                    size: 20,
                    strokeWidth: 1.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ),
          ),
          ...usersAsync.when(
            loading: () => [
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) => [
              SliverFillRemaining(
                child: ErrorView(
                  message: 'Could not load users',
                  onRetry: () => ref.invalidate(allUsersProvider),
                ),
              ),
            ],
            data: (users) {
              final filtered = _searchQuery.isEmpty
                  ? users
                  : users
                      .where(
                        (u) =>
                            u.displayName.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                            u.username.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                            u.email.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                      )
                      .toList();

              if (filtered.isEmpty) {
                return [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No users found',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ];
              }

              return [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLG,
                  ),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _UserManagementTile(
                        user: filtered[index],
                        onRoleChanged: (newRole) {
                          _showRoleConfirmDialog(
                            context,
                            filtered[index],
                            newRole,
                          );
                        },
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  void _showRoleConfirmDialog(
    BuildContext context,
    UserProfile user,
    String newRole,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Text(
          'Change role of ${user.displayName} from "${user.role}" to "$newRole"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(roleUpdateProvider.notifier)
                  .updateRole(user.uid, newRole);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role updated successfully')),
                );
              } else if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update role')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _UserManagementTile extends StatelessWidget {
  final UserProfile user;
  final ValueChanged<String> onRoleChanged;

  const _UserManagementTile({required this.user, required this.onRoleChanged});

  Color get _roleColor {
    switch (user.role) {
      case 'admin':
        return AppColors.error;
      case 'moderator':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

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
          UserAvatar(
            photoUrl: user.photoUrl,
            username: user.username,
            radius: 22,
          ),
          const SizedBox(width: AppSpacing.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${user.username}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2XS),
                Row(
                  children: [
                    Text(
                      '${user.points} pts',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSM),
                    Text(
                      '${user.classificationCount} classified',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
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
              color: _roleColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: user.role,
              isDense: true,
              dropdownColor: AppColors.surface,
              underline: const SizedBox.shrink(),
              icon: const SizedBox.shrink(),
              style: AppTypography.labelSmall.copyWith(
                color: _roleColor,
                fontWeight: FontWeight.w600,
              ),
              items: ['citizen', 'moderator', 'admin']
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(
                        role.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: _roleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (newRole) {
                if (newRole != null && newRole != user.role) {
                  onRoleChanged(newRole);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
