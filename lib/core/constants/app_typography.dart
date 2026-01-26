import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Font Families
  static String get primaryFont => 'Nunito';
  static String get secondaryFont => 'Quicksand';

  // Display - Large peso amounts
  static TextStyle get display => GoogleFonts.quicksand(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayWhite => display.copyWith(color: Colors.white);

  // H1 - Screen titles
  static TextStyle get h1 => GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // H2 - Section headers
  static TextStyle get h2 => GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // H3 - Card titles
  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Body - Regular text
  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // Body Bold
  static TextStyle get bodyBold => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // Caption - Labels, timestamps
  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Small - Hints, footnotes
  static TextStyle get small => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  // Button Text
  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  // Input Text
  static TextStyle get input => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // Input Hint
  static TextStyle get inputHint => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  // Amount Display (for peso)
  static TextStyle get amountLarge => GoogleFonts.quicksand(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get amountMedium => GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get amountSmall => GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
