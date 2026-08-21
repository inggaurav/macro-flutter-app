import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class AppColors {
  // Dark Base Palette
  static const Color backgroundDark = Color(0xFF090A0F);
  static const Color surfaceDark = Color(0xFF12141D);
  static const Color surfaceElevated = Color(0xFF1A1D2B);
  static const Color surfaceOverlay = Color(0xFF222638);

  static const Color borderDark = Color(0xFF24283B);
  static const Color borderStrong = Color(0xFF3B4261);

  // Text Semantic Scale
  static const Color textPrimary = Color(0xFFF7F8F8);
  static const Color textSecondary = Color(0xFFC0CAF5);
  static const Color textMuted = Color(0xFF767B9D);

  // Status & Accents
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // AI & Relationship Badges
  static const Color aiPurple = Color(0xFFA855F7);
  static const Color aiCyan = Color(0xFF06B6D4);

  // App Factory Brand Color Resolvers
  static Color brandPrimary(AppConfig config) => config.primaryColor;
  static Color brandAccent(AppConfig config) => config.accentColor;
}
