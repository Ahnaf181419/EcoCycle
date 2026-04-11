import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/logic/auth_provider.dart';
import '../logic/profile_provider.dart';
import '../logic/follow_provider.dart';
import '../data/models/user_profile_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/user_avatar.dart';
import 'own_profile_screen.dart';
import '../../../shared/widgets/error_view.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUid = authState.user?.uid;

    if (uid == currentUid) {
      return const OwnProfileScreen();
    }

    final userAsync = ref.watch(userProfileProvider(uid));
    final followAsync = ref.watch(isFollowingProvider(uid));
    final followState = ref.watch(followActionProvider(uid));

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorView(
          message: 'Could not load profile',
          onRetry: () => ref.invalidate(userProfileProvider(uid)),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: ErrorView(
              message: 'User not found',
              icon: Icons.person_off_outlined,
            ),
          );
        }

        if (user.isPrivate) {
          return _PrivateProfile(user: user);
        }

        return _PublicProfile(
          user: user,
          isFollowing: followAsync.valueOrNull ?? false,
          isFollowLoading: followState.isLoading,
          onFollowToggle: () async {
            if (ref.read(followActionProvider(uid)).isLoading) return;
            final notifier = ref.read(followActionProvider(uid).notifier);
            bool success;
            if (followAsync.valueOrNull ?? false) {
              success = await notifier.unfollow();
            } else {
              success = await notifier.follow();
            }
            if (success) {
              ref.invalidate(isFollowingProvider(uid));
            }
          },
        );
      },
    );
  }
}

class _PrivateProfile extends StatelessWidget {
  final UserProfile user;

  const _PrivateProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.displayName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3XL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserAvatar(
                photoUrl: user.photoUrl,
                username: user.username,
                radius: 44,
              ),
              const SizedBox(height: AppSpacing.spaceLG),
              Text(
                user.displayName,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXL),
              Container(
                padding: const EdgeInsets.all(AppSpacing.spaceXL),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedLockPassword,
                      color: AppColors.textTertiary,
                      size: 40,
                      strokeWidth: 1.5,
                    ),
                    const SizedBox(height: AppSpacing.spaceMD),
                    Text(
                      'This profile is private',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicProfile extends StatelessWidget {
  final UserProfile user;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback onFollowToggle;

  const _PublicProfile({
    required this.user,
    required this.isFollowing,
    required this.isFollowLoading,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.spaceXL,
                    AppSpacing.space3XL,
                    AppSpacing.spaceXL,
                    0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.spaceXL),
                      UserAvatar(
                        photoUrl: user.photoUrl,
                        username: user.username,
                        radius: 44,
                      ),
                      const SizedBox(height: AppSpacing.spaceMD),
                      Text(
                        user.displayName,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceLG),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ProfileStatColumn(
                            label: 'Points',
                            value: '${user.points}',
                          ),
                          _ProfileStatColumn(
                            label: 'Classified',
                            value: '${user.classificationCount}',
                          ),
                          _ProfileStatColumn(
                            label: 'Followers',
                            value: '${user.followerCount}',
                          ),
                          _ProfileStatColumn(
                            label: 'Following',
                            value: '${user.followingCount}',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spaceLG),
                      _FollowButton(
                        isFollowing: isFollowing,
                        isLoading: isFollowLoading,
                        onTap: onFollowToggle,
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
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: HugeIcons.strokeRoundedTarget01,
                        label: 'Accuracy',
                        value: '${(user.accuracyRate * 100).toInt()}%',
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSM),
                    Expanded(
                      child: _StatCard(
                        icon: HugeIcons.strokeRoundedCoins01,
                        label: 'Available',
                        value: '${user.availablePoints}',
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3XL),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final bool isLoading;
  final VoidCallback onTap;

  const _FollowButton({
    required this.isFollowing,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 40,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: isFollowing
              ? AppColors.surfaceVariant
              : AppColors.accent,
          foregroundColor: isFollowing ? AppColors.textPrimary : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: isFollowing
                        ? HugeIcons.strokeRoundedUserRemove01
                        : HugeIcons.strokeRoundedUserAdd01,
                    size: 18,
                    strokeWidth: 1.5,
                    color: isFollowing ? AppColors.textPrimary : Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.spaceSM),
                  Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: AppTypography.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileStatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.statMedium.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(
              icon: icon,
              color: color,
              size: 20,
              strokeWidth: 1.5,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.statMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
