import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import 'bottom_nav.dart';

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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        userRole: userRole,
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    bool hasDisputes = userRole == 'moderator' || userRole == 'admin';
    bool hasAdmin = userRole == 'admin';

    if (location.startsWith(RouteConstants.home)) return 0;
    if (location.startsWith(RouteConstants.classify)) return 1;
    if (location.startsWith(RouteConstants.leaderboard)) return 2;

    if (location.startsWith(RouteConstants.disputes) && hasDisputes) {
      return 3;
    }
    if (location.startsWith(RouteConstants.admin) && hasAdmin) {
      return hasDisputes ? 4 : 3;
    }

    if (location.startsWith(RouteConstants.profile) ||
        location.startsWith(RouteConstants.settings) ||
        location.startsWith(RouteConstants.history) ||
        location.startsWith(RouteConstants.rewards) ||
        location.startsWith(RouteConstants.feed)) {
      if (hasAdmin) return 5;
      if (hasDisputes) return 4;
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    bool hasDisputes = userRole == 'moderator' || userRole == 'admin';
    bool hasAdmin = userRole == 'admin';

    int disputesIndex = hasDisputes ? 3 : -1;
    int adminIndex = hasAdmin ? (hasDisputes ? 4 : 3) : -1;
    String route;
    if (index == 0) {
      route = RouteConstants.home;
    } else if (index == 1) {
      route = RouteConstants.classify;
    } else if (index == 2) {
      route = RouteConstants.leaderboard;
    } else if (index == disputesIndex && hasDisputes) {
      route = RouteConstants.disputes;
    } else if (index == adminIndex && hasAdmin) {
      route = RouteConstants.admin;
    } else {
      route = RouteConstants.profile;
    }

    context.go(route);
  }
}
