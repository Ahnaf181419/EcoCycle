import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF14794B);
  static const Color primaryLight = Color(0xFF1FA06A);
  static const Color primaryDark = Color(0xFF0E5434);

  static const Color accent = Color(0xFFF5A623);
  static const Color accentLight = Color(0xFFFFD080);
  static const Color accentDark = Color(0xFFC7841A);

  static const Color background = Color(0xFFF7F4EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDE9E0);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFD9D4CC);
  static const Color divider = Color(0xFFE8E4DC);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  static const Color recyclable = Color(0xFF1976D2);
  static const Color recyclableLight = Color(0xFFE3F2FD);
  static const Color recyclableDark = Color(0xFF0D47A1);

  static const Color organic = Color(0xFF388E3C);
  static const Color organicLight = Color(0xFFE8F5E9);
  static const Color organicDark = Color(0xFF1B5E20);

  static const Color eWaste = Color(0xFFF57F17);
  static const Color eWasteLight = Color(0xFFFFF8E1);
  static const Color eWasteDark = Color(0xFFE65100);

  static const Color hazardous = Color(0xFFC62828);
  static const Color hazardousLight = Color(0xFFFFEBEE);
  static const Color hazardousDark = Color(0xFFB71C1C);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFE8E4DC);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkPrimary = Color(0xFF2ECC71);
  static const Color darkAccent = Color(0xFFFFB84D);
  static const Color darkBorder = Color(0xFF3A3A3A);

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'recyclable':
        return recyclable;
      case 'organic':
        return organic;
      case 'e_waste':
      case 'ewaste':
        return eWaste;
      case 'hazardous':
        return hazardous;
      default:
        return textSecondary;
    }
  }

  static Color categoryLightColor(String category) {
    switch (category.toLowerCase()) {
      case 'recyclable':
        return recyclableLight;
      case 'organic':
        return organicLight;
      case 'e_waste':
      case 'ewaste':
        return eWasteLight;
      case 'hazardous':
        return hazardousLight;
      default:
        return surfaceVariant;
    }
  }

  static Color categoryDarkColor(String category) {
    switch (category.toLowerCase()) {
      case 'recyclable':
        return recyclableDark;
      case 'organic':
        return organicDark;
      case 'e_waste':
      case 'ewaste':
        return eWasteDark;
      case 'hazardous':
        return hazardousDark;
      default:
        return textPrimary;
    }
  }
}
