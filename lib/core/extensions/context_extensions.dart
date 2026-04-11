import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  EdgeInsets get padding => MediaQuery.of(this).padding;

  bool get isSmallScreen => screenWidth < 360;

  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;

  double responsiveHeight(double base, {double? small}) {
    if (isSmallScreen) return small ?? base * 0.9;
    return base;
  }

  double clampedHeight(double base,
      {double minMul = 0.85, double maxMul = 1.15}) {
    return (base * (screenWidth / 400)).clamp(base * minMul, base * maxMul);
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.spaceLG),
        ),
      );
  }

  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}
