import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/route_constants.dart';
import 'core/constants/user_role.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/auth/logic/auth_state.dart';
import 'shared/widgets/error_view.dart';
import 'features/auth/ui/splash_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
import 'features/home/ui/home_screen.dart';
import 'features/classification/ui/camera_screen.dart';
import 'features/classification/ui/classification_result_screen.dart';
import 'features/classification/ui/submission_history_screen.dart';
import 'features/rewards/ui/rewards_screen.dart';
import 'features/rewards/ui/redeem_screen.dart';
import 'features/social/ui/leaderboard_screen.dart';
import 'features/social/ui/own_profile_screen.dart';
import 'features/social/ui/user_profile_screen.dart';
import 'features/social/ui/feed_screen.dart';
import 'features/settings/ui/settings_screen.dart';
import 'features/disputes/ui/dispute_queue_screen.dart';
import 'features/disputes/ui/dispute_detail_screen.dart';
import 'features/admin/ui/admin_dashboard_screen.dart';
import 'features/admin/ui/user_management_screen.dart';
import 'shared/navigation/app_shell.dart';

/// ChangeNotifier that bridges Riverpod's [authProvider] into GoRouter's
/// `refreshListenable`. Owns a [ProviderSubscription] so it must be disposed
/// explicitly — see `routerProvider.onDispose` below.
class _AuthStateListener extends ChangeNotifier {
  _AuthStateListener(this._ref) {
    _sub = _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _sub;

  AuthState get state => _ref.read(authProvider);

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authListener = _AuthStateListener(ref);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    refreshListenable: authListener,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      final isPublicRoute = [
        RouteConstants.splash,
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

      final userRole = UserRole.fromString(authState.user?.role);

      if (state.matchedLocation.startsWith(RouteConstants.disputes) &&
          !userRole.canModerateDisputes) {
        return RouteConstants.home;
      }

      if (state.matchedLocation.startsWith(RouteConstants.admin) &&
          !userRole.isAdmin) {
        return RouteConstants.home;
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: ErrorView(
        message: state.error?.toString() ?? 'Page not found',
      ),
    ),
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
      GoRoute(
        path: '${RouteConstants.result}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) {
            return const Scaffold(
              body: ErrorView(message: 'Invalid submission link'),
            );
          }
          return ClassificationResultScreen(submissionId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final role = ref.watch(authProvider.select((s) => s.user?.role));
          return AppShell(
            navigationShell: navigationShell,
            userRole: UserRole.fromString(role).value,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.classify,
                builder: (context, state) => const CameraScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.leaderboard,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.profile,
                builder: (context, state) => const OwnProfileScreen(),
                routes: [
                  GoRoute(
                    path: ':uid',
                    builder: (context, state) {
                      final uid = state.pathParameters['uid'];
                      if (uid == null || uid.isEmpty) {
                        return const Scaffold(
                          body: ErrorView(message: 'Invalid profile link'),
                        );
                      }
                      return UserProfileScreen(uid: uid);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.disputes,
                builder: (context, state) => const DisputeQueueScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      if (id == null || id.isEmpty) {
                        return const Scaffold(
                          body: ErrorView(message: 'Invalid dispute link'),
                        );
                      }
                      return DisputeDetailScreen(disputeId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.admin,
                builder: (context, state) => const AdminDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'users',
                    builder: (context, state) => const UserManagementScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.history,
                builder: (context, state) => const SubmissionHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.rewards,
                builder: (context, state) => const RewardsScreen(),
                routes: [
                  GoRoute(
                    path: 'redeem',
                    builder: (context, state) => const RedeemScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authListener.dispose();
  });
  return router;
});
