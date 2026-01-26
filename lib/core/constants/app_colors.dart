import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Lavender Theme
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5046E5);
  static const Color primarySoft = Color(0xFFE8E6FF);

  // Accent Colors
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentMint = Color(0xFF4ECDC4);
  static const Color accentSunshine = Color(0xFFFFE66D);
  static const Color accentPeach = Color(0xFFFFB4A2);

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFD5F5E3);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF5E7);
  static const Color danger = Color(0xFFE74C3C);
  static const Color dangerLight = Color(0xFFFDEDEC);

  // Neutrals
  static const Color bgPrimary = Color(0xFFFAFBFF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSoft = Color(0xFFF0F2FF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textMuted = Color(0xFFB2BEC3);
  static const Color border = Color(0xFFE8ECF4);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark, Color(0xFF4834D4)],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accentCoral],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentMint, accentSunshine],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [warning, accentSunshine],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [danger, accentCoral],
  );

  // Category Colors
  static const Color categoryFood = Color(0xFFFFF3E0);
  static const Color categoryTransport = Color(0xFFE3F2FD);
  static const Color categoryShopping = Color(0xFFFCE4EC);
  static const Color categoryBills = Color(0xFFE8F5E9);
  static const Color categoryEntertainment = Color(0xFFF3E5F5);
  static const Color categoryHealthcare = Color(0xFFE0F7FA);
  static const Color categoryPersonalCare = Color(0xFFFFF8E1);
  static const Color categoryOthers = Color(0xFFECEFF1);
}
