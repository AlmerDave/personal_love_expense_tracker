import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(0.16),
          blurRadius: 40,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
}
