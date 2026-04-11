// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/logic/auth_provider.dart';
import '../logic/settings_provider.dart';
import '../../social/logic/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/route_constants.dart';
import '../../../shared/widgets/loading_overlay.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Narrow: this screen only cares about the profile object, not the
    // transient loading/error fields on AuthState.
    final user = ref.watch(authProvider.select((s) => s.user));
    final privacyState = ref.watch(privacyToggleProvider);

    return LoadingOverlay(
      isLoading: privacyState.isLoading,
      message: 'Updating...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: AppColors.surface,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceLG),
          children: [
            _SettingsSection(
              title: 'Profile',
              children: [
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedUserSquare,
                    color: AppColors.primary,
                    size: 24,
                    strokeWidth: 1.5,
                  ),
                  title: Text(
                    'Edit Display Name',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    user?.displayName ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  trailing: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: AppColors.textTertiary,
                    size: 20,
                    strokeWidth: 1.5,
                  ),
                  onTap: () => _showEditNameDialog(context),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Privacy',
              children: [
                SwitchListTile(
                  secondary: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLockPassword,
                    color: AppColors.primary,
                    size: 24,
                    strokeWidth: 1.5,
                  ),
                  title: Text(
                    'Private Profile',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Hide your activity from other users',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  value: user?.isPrivate ?? false,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) {
                    ref
                        .read(privacyToggleProvider.notifier)
                        .togglePrivacy(value);
                  },
                ),
              ],
            ),
            _SettingsSection(
              title: 'Account',
              children: [
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLogout01,
                    color: AppColors.error,
                    size: 24,
                    strokeWidth: 1.5,
                  ),
                  title: Text(
                    'Sign Out',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () => _showSignOutDialog(context),
                ),
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete01,
                    color: AppColors.error,
                    size: 24,
                    strokeWidth: 1.5,
                  ),
                  title: Text(
                    'Delete Account',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: Text(
                    'Permanently delete your account and data',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
            _SettingsSection(
              title: 'About',
              children: [
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    color: AppColors.primary,
                    size: 24,
                    strokeWidth: 1.5,
                  ),
                  title: Text(
                    'App Version',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final initial = ref.read(authProvider).user?.displayName ?? '';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _EditNameDialog(
        initial: initial,
        onSave: (name) {
          ref.read(profileEditProvider.notifier).updateDisplayName(name);
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RouteConstants.login);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. '
          'All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(deleteAccountProvider.notifier)
                  .deleteAccount();
              if (success && mounted) {
                context.go(RouteConstants.login);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Owns its own [TextEditingController] via `dispose()` rather than relying
/// on `showDialog().then(...)`, which can drop the disposal on OS-driven
/// process kill / Activity recreate.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initial, required this.onSave});

  final String initial;
  final ValueChanged<String> onSave;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Display Name'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Display Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            Navigator.pop(context);
            if (name.isNotEmpty) widget.onSave(name);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceXL,
            vertical: AppSpacing.spaceSM,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
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
          child: Column(children: children),
        ),
        const SizedBox(height: AppSpacing.spaceLG),
      ],
    );
  }
}
