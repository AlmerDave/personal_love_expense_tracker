import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double full = 9999.0;

  // BorderRadius presets
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get extraLargeRadius => BorderRadius.circular(xl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);

  // Bottom sheet radius
  static BorderRadius get bottomSheetRadius => const BorderRadius.only(
        topLeft: Radius.circular(lg),
        topRight: Radius.circular(lg),
      );
}
