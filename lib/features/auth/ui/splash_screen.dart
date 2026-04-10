import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRedirect();
    });
  }

  void _tryRedirect() {
    if (_redirected || !mounted) return;
    final authState = ref.read(authProvider);
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
      if (!next.isLoading && !_redirected && mounted) {
        _redirected = true;
        if (next.isAuthenticated) {
          context.go(RouteConstants.home);
        } else {
          context.go(RouteConstants.login);
        }
      }
    });

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
