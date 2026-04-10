import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/route_constants.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/auth/ui/splash_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
import 'shared/navigation/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final isPublicRoute = [
        RouteConstants.login,
        RouteConstants.register,
      ].contains(state.matchedLocation);

      if (authState.isLoading) return null;

      if (!authState.isAuthenticated && !isPublicRoute) {
        return RouteConstants.login;
      }

      if (authState.isAuthenticated && isPublicRoute) {
        return RouteConstants.home;
      }

      final userRole = authState.user?.role ?? 'citizen';

      if (state.matchedLocation.startsWith(RouteConstants.disputes) &&
          userRole != 'moderator' &&
          userRole != 'admin') {
        return RouteConstants.home;
      }

      if (state.matchedLocation.startsWith(RouteConstants.admin) &&
          userRole != 'admin') {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final authState = ref.read(authProvider);
          return AppShell(
            navigationShell: navigationShell,
            userRole: authState.user?.role ?? 'citizen',
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.classify,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Classify'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.leaderboard,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Leaderboard'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.profile,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Profile'),
                routes: [
                  GoRoute(
                    path: ':uid',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'User Profile'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.disputes,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Dispute Queue'),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'Dispute Detail'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.admin,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Admin Dashboard'),
                routes: [
                  GoRoute(
                    path: 'users',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'User Management'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '${RouteConstants.result}/:id',
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Result'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.history,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'History'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.rewards,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Rewards'),
                routes: [
                  GoRoute(
                    path: 'redeem',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'Redeem'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.feed,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Activity Feed'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.settings,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Settings'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
