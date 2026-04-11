import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_provider.dart';
import '../logic/auth_state.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _redirected = false;

  void _redirect(AuthState authState) {
    if (_redirected || !mounted) return;
    if (authState.isLoading) return;
    _redirected = true;
    if (authState.isAuthenticated) {
      context.go(RouteConstants.home);
    } else {
      context.go(RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      _redirect(next);
    });

    final currentAuth = ref.read(authProvider);
    if (!currentAuth.isLoading && !_redirected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _redirect(currentAuth);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'EcoCycle',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Classify. Earn. Sustain.',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
