import 'package:flutter/material.dart';

class AppElevation {
  AppElevation._();

  static List<BoxShadow> get none => [];

  static List<BoxShadow> get sm => [
    const BoxShadow(
      color: Color(0x1A1A1A1A),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static List<BoxShadow> get md => [
    const BoxShadow(
      color: Color(0x1A1A1A1A),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
    const BoxShadow(
      color: Color(0x0D1A1A1A),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get lg => [
    const BoxShadow(
      color: Color(0x1A1A1A1A),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    const BoxShadow(
      color: Color(0x0D1A1A1A),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static List<BoxShadow> get xl => [
    const BoxShadow(
      color: Color(0x1A1A1A1A),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    const BoxShadow(
      color: Color(0x0D1A1A1A),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> get floating => [
    const BoxShadow(
      color: Color(0x261A1A1A),
      offset: Offset(0, 12),
      blurRadius: 36,
      spreadRadius: -6,
    ),
    const BoxShadow(
      color: Color(0x0D1A1A1A),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
