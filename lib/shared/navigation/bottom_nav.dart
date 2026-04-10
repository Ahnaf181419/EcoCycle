import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String userRole;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userRole = 'citizen',
  });

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
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
      const BottomNavigationBarItem(
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
      const BottomNavigationBarItem(
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
      const BottomNavigationBarItem(
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
    ];

    if (userRole == 'moderator' || userRole == 'admin') {
      items.insert(
        3,
        const BottomNavigationBarItem(
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
      );
    }

    if (userRole == 'admin') {
      items.insert(
        items.length - 1,
        const BottomNavigationBarItem(
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
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
    );
  }

  static int getTabCount(String role) {
    int count = 4;
    if (role == 'moderator' || role == 'admin') count++;
    if (role == 'admin') count++;
    return count;
  }
}
