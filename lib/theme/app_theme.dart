import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppTheme — Central place for all colors, text styles, and the MaterialTheme.
///
/// HOW TO USE:
///   - Colors  : AppTheme.primary, AppTheme.background, etc.
///   - Styles  : AppTheme.titleStyle, AppTheme.bodyStyle, etc.
///   - In main : theme: AppTheme.light
/// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Brand colors ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0);       // deep blue
  static const Color primaryLight = Color(0xFF1976D2);  // medium blue (bubbles, buttons)
  static const Color accent = Color(0xFF42A5F5);        // light blue (highlights)
  static const Color background = Color(0xFFF3F4F6);    // page background
  static const Color surface = Colors.white;            // cards, app bars
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color onlineGreen = Color(0xFF22C55E);

  // ── Text styles ─────────────────────────────────────────────────────────────
  static const TextStyle headingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // ── Material theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0.5,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: titleStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerColor: divider,
      );
}
