import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle display(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle titleLarge(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle title(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle sectionTitle(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: color,
    );
  }

  static TextStyle bodyLarge(
    BuildContext context, {
    Color color = AppColors.textSecondary,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle body(
    BuildContext context, {
    Color color = AppColors.textSecondary,
  }) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color,
    );
  }

  static TextStyle bodySmall(
    BuildContext context, {
    Color color = AppColors.textMuted,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.35,
      color: color,
    );
  }

  static TextStyle label(
    BuildContext context, {
    Color color = AppColors.textMuted,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static TextStyle caption(
    BuildContext context, {
    Color color = AppColors.textMuted,
  }) {
    return GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
