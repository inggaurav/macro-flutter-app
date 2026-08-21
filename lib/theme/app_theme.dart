import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Theme Palette matching Macro UI
  static const Color bgDark = Color(0xFF0B0D12);
  static const Color surfaceDark = Color(0xFF141720);
  static const Color surfaceLightDark = Color(0xFF1C212E);
  static const Color borderDark = Color(0xFF282F42);

  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryHover = Color(0xFF4F46E5);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFFA855F7);

  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryIndigo,
        surface: surfaceDark,
        secondary: accentEmerald,
        error: accentRose,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: GoogleFonts.inter(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.inter(color: textPrimary),
            bodyMedium: GoogleFonts.inter(color: textSecondary),
            bodySmall: GoogleFonts.inter(color: textMuted),
          ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: borderDark, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderDark, thickness: 1),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
