import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const BorderRadius radiusNone = BorderRadius.zero;
  static const BorderRadius radius4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radius32 = BorderRadius.all(Radius.circular(32));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));

  static OutlinedBorder squircle([double radius = 16]) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );
  }
}
