import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_provider.dart';
import '../logic/auth_state.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

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

    // Handle the "already loaded" case on first build.
    final currentAuth = ref.read(authProvider);
    if (!currentAuth.isLoading && !_redirected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirect(currentAuth);
      });
    }

    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'EcoCycle',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Outfit',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Classify. Earn. Sustain.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'DM Sans',
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
