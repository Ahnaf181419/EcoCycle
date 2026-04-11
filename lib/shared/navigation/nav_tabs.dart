import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';

class NavTab {
  final String route;
  final BottomNavigationBarItem item;
  const NavTab({required this.route, required this.item});
}

List<NavTab> buildNavTabs(String role) {
  final tabs = <NavTab>[
    NavTab(
      route: RouteConstants.home,
      item: const BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          color: AppColors.textTertiary,
          size: 24,
          strokeWidth: 1.5,
        ),
        activeIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedHome01,
          color: AppColors.primary,
          size: 24,
          strokeWidth: 2.0,
        ),
        label: 'Home',
      ),
    ),
    NavTab(
      route: RouteConstants.classify,
      item: const BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedCamera01,
          color: AppColors.textTertiary,
          size: 24,
          strokeWidth: 1.5,
        ),
        activeIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedCamera01,
          color: AppColors.primary,
          size: 24,
          strokeWidth: 2.0,
        ),
        label: 'Classify',
      ),
    ),
    NavTab(
      route: RouteConstants.leaderboard,
      item: const BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedMedal01,
          color: AppColors.textTertiary,
          size: 24,
          strokeWidth: 1.5,
        ),
        activeIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedMedal01,
          color: AppColors.primary,
          size: 24,
          strokeWidth: 2.0,
        ),
        label: 'Leaderboard',
      ),
    ),
  ];

  if (role == 'moderator' || role == 'admin') {
    tabs.add(
      NavTab(
        route: RouteConstants.disputes,
        item: const BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedJudge,
            color: AppColors.textTertiary,
            size: 24,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedJudge,
            color: AppColors.primary,
            size: 24,
            strokeWidth: 2.0,
          ),
          label: 'Disputes',
        ),
      ),
    );
  }

  if (role == 'admin') {
    tabs.add(
      NavTab(
        route: RouteConstants.admin,
        item: const BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedShield01,
            color: AppColors.textTertiary,
            size: 24,
            strokeWidth: 1.5,
          ),
          activeIcon: HugeIcon(
            icon: HugeIcons.strokeRoundedShield01,
            color: AppColors.primary,
            size: 24,
            strokeWidth: 2.0,
          ),
          label: 'Admin',
        ),
      ),
    );
  }

  tabs.add(
    NavTab(
      route: RouteConstants.profile,
      item: const BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedUserCircle,
          color: AppColors.textTertiary,
          size: 24,
          strokeWidth: 1.5,
        ),
        activeIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedUserCircle,
          color: AppColors.primary,
          size: 24,
          strokeWidth: 2.0,
        ),
        label: 'Profile',
      ),
    ),
  );

  return tabs;
}
