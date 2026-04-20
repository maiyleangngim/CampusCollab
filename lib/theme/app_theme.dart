import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand & semantic colors ──────────────────────────────────────────────────
  static const Color primary      = Color(0xFF2563EB); 
  static const Color primaryLight = Color(0xFF3B82F6); 
  static const Color primaryDark  = Color(0xFF1D4ED8); 
  static const Color accent       = Color(0xFF60A5FA); 

  static const Color error        = Color(0xFFDC2626);
  static const Color errorLight   = Color(0xFFFEE2E2);
  static const Color success      = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning      = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info         = Color(0xFF0891B2);
  static const Color infoLight    = Color(0xFFE0F2FE);

  // Light theme colors
  static const Color background   = Color(0xFFF5F6FA);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary  = Color(0xFF9CA3AF);
  static const Color divider       = Color(0xFFE5E7EB);
  static const Color border        = Color(0xFFD1D5DB);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface    = Color(0xFF111827);
  static const Color darkDivider    = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // System (Warm/Night) theme colors
  static const Color warmBackground = Color(0xFFFAF7F2); 
  static const Color warmSurface    = Color(0xFFFFFDF9);
  static const Color warmPrimary    = Color(0xFFD97706); 
  static const Color warmText       = Color(0xFF451A03); 

  static const Color onlineGreen   = Color(0xFF22C55E);

  // ── Spacing scale ─────────────────────────────────────────────────────────────
  static const double spacingXxs = 4.0;
  static const double spacingXs  = 8.0;
  static const double spacingSm  = 12.0;
  static const double spacingMd  = 16.0;
  static const double spacingLg  = 24.0;
  static const double spacingXl  = 32.0;
  static const double spacingXxl = 48.0;

  // ── Border radii ─────────────────────────────────────────────────────────────
  static const double radiusXs   = 6.0;
  static const double radiusSm   = 10.0;
  static const double radiusMd   = 14.0;
  static const double radiusLg   = 20.0;
  static const double radiusXl   = 28.0;
  static const double radiusFull = 999.0;

  // ── Shadow / elevation scale ─────────────────────────────────────────────────
  static const List<BoxShadow> shadowXs = [
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8,  offset: Offset(0, 2)),
    BoxShadow(color: Color(0x06000000), blurRadius: 3,  offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 6,  offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x18000000), blurRadius: 32, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // ── Type styles ──────────────────────────────────────────────────────────────
  static const TextStyle displayStyle = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700, height: 1.18, letterSpacing: -0.5);
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3);
  static const TextStyle headingStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle titleLgStyle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle titleStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle bodyLgStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.55);
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.55);
  static const TextStyle labelStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  // ── Material themes ──────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: surface,
        onSurface: textPrimary,
        surfaceVariant: Color(0xFFE5E7EB), // Grey for profile icons & OTP boxes
        onSurfaceVariant: textPrimary,
        error: error,
      ),
      scaffoldBackgroundColor: background,
    );

    return _applyShared(base).copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: surface,
        foregroundColor: textPrimary,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primaryLight,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceVariant: Color(0xFF334155), // Lighter grey circle for Dark Mode
        onSurfaceVariant: Colors.white,
        error: const Color(0xFFF87171),
      ),
      scaffoldBackgroundColor: darkBackground,
    );

    return _applyShared(base).copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
      ),
      dividerTheme: base.dividerTheme.copyWith(color: darkDivider),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: darkSurface,
        selectedItemColor: primaryLight,
        unselectedItemColor: darkTextTertiary,
      ),
    );
  }

  static ThemeData get system {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: warmPrimary,
        primary: warmPrimary,
        surface: warmSurface,
        onSurface: warmText,
        surfaceVariant: Color(0xFFEFE6D5), // Warmer grey for System Mode
        onSurfaceVariant: warmText,
        error: error,
      ),
      scaffoldBackgroundColor: warmBackground,
    );

    return _applyShared(base).copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: warmSurface,
        foregroundColor: warmText,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: warmSurface,
        selectedItemColor: warmPrimary,
        unselectedItemColor: warmText.withValues(alpha: 0.5),
      ),
    );
  }

  static ThemeData _applyShared(ThemeData base) {
    final isDark = base.brightness == Brightness.dark;
    final isWarm = base.scaffoldBackgroundColor == warmBackground;
    
    final txtColor = isDark ? darkTextPrimary : (isWarm ? warmText : textPrimary);
    final secondaryTxtColor = isDark ? darkTextSecondary : (isWarm ? warmText.withValues(alpha: 0.7) : textSecondary);
    final activePrimary = isDark ? primaryLight : (isWarm ? warmPrimary : primary);

    return base.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.roboto(textStyle: displayStyle.copyWith(color: txtColor)),
        headlineMedium: GoogleFonts.roboto(textStyle: headlineStyle.copyWith(color: txtColor)),
        titleLarge:    GoogleFonts.roboto(textStyle: headingStyle.copyWith(color: txtColor)),
        titleMedium:   GoogleFonts.roboto(textStyle: titleLgStyle.copyWith(color: txtColor)),
        titleSmall:    GoogleFonts.roboto(textStyle: titleStyle.copyWith(color: txtColor)),
        bodyLarge:     GoogleFonts.roboto(textStyle: bodyLgStyle.copyWith(color: txtColor)),
        bodyMedium:    GoogleFonts.roboto(textStyle: bodyStyle.copyWith(color: txtColor)),
        labelLarge:    GoogleFonts.roboto(textStyle: labelStyle.copyWith(color: txtColor)),
        labelSmall:    GoogleFonts.roboto(textStyle: captionStyle.copyWith(color: secondaryTxtColor)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd - 2),
          textStyle: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: base.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd - 2),
        hintStyle: GoogleFonts.roboto(color: secondaryTxtColor.withValues(alpha: 0.5), fontSize: 14),
        labelStyle: GoogleFonts.roboto(color: txtColor, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: isDark ? darkDivider : (isWarm ? warmPrimary.withValues(alpha: 0.2) : border), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: isDark ? darkDivider : (isWarm ? warmPrimary.withValues(alpha: 0.2) : border), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: activePrimary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: base.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: isDark ? darkDivider : (isWarm ? warmPrimary.withValues(alpha: 0.1) : divider), width: 1),
        ),
      ),
    );
  }
}
