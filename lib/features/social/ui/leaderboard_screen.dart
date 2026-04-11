// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../auth/logic/auth_provider.dart';
import '../logic/leaderboard_provider.dart';
import '../data/models/user_profile_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../shared/widgets/rank_badge.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final rankAsync = ref.watch(currentUserRankProvider);
    // Narrow: only need the viewer's uid to highlight their row.
    final currentUid =
        ref.watch(authProvider.select((s) => s.user?.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
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
                              icon: HugeIcons.strokeRoundedMedal01,
                              color: Colors.white,
                              size: 32,
                              strokeWidth: 1.5,
                            ),
                            const SizedBox(width: AppSpacing.spaceSM),
                            Text(
                              'Leaderboard',
                              style: AppTypography.headlineLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceLG),
                        rankAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (rank) {
                            if (rank <= 0) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.spaceLG,
                                vertical: AppSpacing.spaceSM,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const HugeIcon(
                                    icon: HugeIcons.strokeRoundedUserCircle,
                                    color: Colors.white,
                                    size: 16,
                                    strokeWidth: 1.5,
                                  ),
                                  const SizedBox(width: AppSpacing.spaceXS),
                                  Text(
                                    'Your rank: #$rank',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          leaderboardAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Could not load leaderboard',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            data: (users) {
              if (users.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedMedal01,
                          color: AppColors.textTertiary,
                          size: 48,
                          strokeWidth: 1.5,
                        ),
                        const SizedBox(height: AppSpacing.spaceLG),
                        Text(
                          'No users yet',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final topThree = users.take(3).toList();
              final rest = users.skip(topThree.length).toList();

              return SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (topThree.isNotEmpty)
                      _PodiumSection(
                        topThree: topThree,
                        currentUid: currentUid,
                      ),
                    if (rest.isNotEmpty)
                      _LeaderboardList(
                        users: rest,
                        startIndex: topThree.length + 1,
                        currentUid: currentUid,
                      ),
                    const SizedBox(height: AppSpacing.space3XL),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PodiumSection extends StatelessWidget {
  final List<UserProfile> topThree;
  final String? currentUid;

  const _PodiumSection({required this.topThree, this.currentUid});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.spaceLG),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.spaceXL,
        horizontal: AppSpacing.spaceLG,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topThree.length >= 2)
            _PodiumCard(
              user: topThree[1],
              rank: 2,
              isCurrentUser: topThree[1].uid == currentUid,
            ),
          if (topThree.isNotEmpty)
            _PodiumCard(
              user: topThree[0],
              rank: 1,
              isCurrentUser: topThree[0].uid == currentUid,
              isCenter: true,
            ),
          if (topThree.length >= 3)
            _PodiumCard(
              user: topThree[2],
              rank: 3,
              isCurrentUser: topThree[2].uid == currentUid,
            ),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final UserProfile user;
  final int rank;
  final bool isCurrentUser;
  final bool isCenter;

  const _PodiumCard({
    required this.user,
    required this.rank,
    this.isCurrentUser = false,
    this.isCenter = false,
  });

  Color get _medalColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarRadius = isCenter ? 32.0 : 26.0;

    return GestureDetector(
      onTap: () => context.go('/profile/${user.uid}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank == 1)
            HugeIcon(
              icon: HugeIcons.strokeRoundedCrown,
              color: _medalColor,
              size: 28,
              strokeWidth: 1.5,
            )
          else
            const SizedBox(height: 28),
          const SizedBox(height: AppSpacing.spaceXS),
          Stack(
            children: [
              UserAvatar(
                photoUrl: user.photoUrl,
                username: user.username,
                radius: avatarRadius,
              ),
              if (isCurrentUser)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSM),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _medalColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTypography.statSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXS),
          SizedBox(
            width: 80,
            child: Text(
              user.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${user.points} pts',
            style: AppTypography.statSmall.copyWith(
              fontSize: 13,
              color: _medalColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<UserProfile> users;
  final int startIndex;
  final String? currentUid;

  const _LeaderboardList({
    required this.users,
    required this.startIndex,
    this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLG),
      child: Column(
        children: users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final rank = startIndex + index;
          final isCurrent = user.uid == currentUid;

          return _LeaderboardTile(
            user: user,
            rank: rank,
            isCurrentUser: isCurrent,
          );
        }).toList(),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final UserProfile user;
  final int rank;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.user,
    required this.rank,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSM),
      child: Material(
        color: isCurrentUser
            ? AppColors.primaryLight.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.go('/profile/${user.uid}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceLG,
              vertical: AppSpacing.spaceMD,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isCurrentUser
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
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
                RankBadge(rank: rank, isCurrentUser: isCurrentUser),
                const SizedBox(width: AppSpacing.spaceLG),
                UserAvatar(
                  photoUrl: user.photoUrl,
                  username: user.username,
                  radius: 20,
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMD,
                    vertical: AppSpacing.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${user.points}',
                    style: AppTypography.statSmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
