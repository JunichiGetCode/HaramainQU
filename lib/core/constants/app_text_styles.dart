import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // ─── Display / Hero Texts ─────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  // ─── Headings ─────────────────────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ─── Gold Headings ────────────────────────────────────────────────────────
  static TextStyle get h1Gold => h1.copyWith(color: AppColors.textGold);
  static TextStyle get h2Gold => h2.copyWith(color: AppColors.textGold);
  static TextStyle get h3Gold => h3.copyWith(color: AppColors.textGold);

  // ─── Body Texts ───────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  // ─── Special Body ─────────────────────────────────────────────────────────
  static TextStyle get bodyMuted =>
      bodyMedium.copyWith(color: AppColors.textSecondary);
  static TextStyle get bodyGold =>
      bodyMedium.copyWith(color: AppColors.textGold);

  // ─── Labels ───────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  // ─── Button Texts ─────────────────────────────────────────────────────────
  static TextStyle get buttonPrimary => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonOutlined => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textGold,
        letterSpacing: 0.5,
      );

  // ─── App Bar / Navigation ─────────────────────────────────────────────────
  static TextStyle get appBarTitle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textGold,
      );

  static TextStyle get navLabel => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // ─── Brand / Logo ─────────────────────────────────────────────────────────
  static TextStyle get brandName => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
        letterSpacing: 2,
      );

  static TextStyle get tagline => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  // ─── Countdown / Numeric ──────────────────────────────────────────────────
  static TextStyle get countdown => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
      );

  // ─── Arabic Text Support ──────────────────────────────────────────────────
  static TextStyle get arabicMedium => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.8,
      );

  static TextStyle get arabicLarge => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 24,
        color: AppColors.accent,
        height: 2.0,
      );
}
