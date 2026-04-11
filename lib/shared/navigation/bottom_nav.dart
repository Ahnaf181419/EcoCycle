import 'package:flutter/material.dart';
import 'nav_tabs.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavTab> tabs;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).bottomNavigationBarTheme;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: tabs.map((t) => t.item).toList(),
      type: theme.type ?? BottomNavigationBarType.fixed,
      backgroundColor: theme.backgroundColor,
      selectedItemColor: theme.selectedItemColor,
      unselectedItemColor: theme.unselectedItemColor,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
    );
  }
}
