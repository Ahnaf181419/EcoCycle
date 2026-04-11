import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import 'bottom_nav.dart';
import 'nav_tabs.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final String userRole;

  const AppShell({
    super.key,
    required this.navigationShell,
    this.userRole = 'citizen',
  });

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    final bool isResultRoute = location.startsWith(RouteConstants.result);
    final tabs = buildNavTabs(userRole);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isResultRoute
          ? null
          : BottomNav(
              currentIndex: _calculateSelectedIndex(context, tabs),
              onTap: (index) => _onItemTapped(index, context, tabs),
              tabs: tabs,
            ),
    );
  }

  int _calculateSelectedIndex(BuildContext context, List<NavTab> tabs) {
    final String location = GoRouterState.of(context).matchedLocation;

    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].route)) return i;
    }

    // Fallback: routes that map to Profile tab (settings, history, rewards, feed)
    final profileIndex = tabs.indexWhere(
      (t) => t.route == RouteConstants.profile,
    );
    if (profileIndex != -1 &&
        (location.startsWith(RouteConstants.settings) ||
            location.startsWith(RouteConstants.history) ||
            location.startsWith(RouteConstants.rewards) ||
            location.startsWith(RouteConstants.feed))) {
      return profileIndex;
    }

    return 0;
  }

  void _onItemTapped(int index, BuildContext context, List<NavTab> tabs) {
    if (index >= 0 && index < tabs.length) {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }
}
