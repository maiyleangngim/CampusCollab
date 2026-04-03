import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppTheme — Single source of truth for colors, text styles, shadows,
/// radii, spacing, and the MaterialTheme.
///
/// HOW TO USE:
///   Colors  : AppTheme.primary, AppTheme.error, etc.
///   Shadows : AppTheme.shadowSm, AppTheme.shadowMd, AppTheme.shadowLg
///   Radii   : AppTheme.radiusSm / radiusMd / radiusLg / radiusFull
///   Spacing : AppTheme.spacingXs … spacingXl  (4 / 8 / 12 / 16 / 24 / 32 / 48)
///   Styles  : AppTheme.displayStyle, headlineStyle, titleStyle, bodyStyle …
///   Theme   : AppTheme.light
/// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Brand & semantic colors ──────────────────────────────────────────────────
  static const Color primary      = Color(0xFF2563EB); // vibrant blue — more energetic for students
  static const Color primaryLight = Color(0xFF3B82F6); // lighter blue for buttons / interactive
  static const Color primaryDark  = Color(0xFF1D4ED8); // pressed / active states
  static const Color accent       = Color(0xFF60A5FA); // highlights, chips

  // Semantic feedback colors
  static const Color error        = Color(0xFFDC2626);
  static const Color errorLight   = Color(0xFFFEE2E2);
  static const Color success      = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning      = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info         = Color(0xFF0891B2);
  static const Color infoLight    = Color(0xFFE0F2FE);

  // Surfaces & backgrounds
  static const Color background   = Color(0xFFF5F6FA); // slightly warmer gray-blue tint
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF0F2FF); // tinted surface for cards/chips
  static const Color overlay      = Color(0x66000000); // modal scrim ~40%

  // Text
  static const Color textPrimary   = Color(0xFF111827); // near-black, warm
  static const Color textSecondary = Color(0xFF6B7280); // medium gray
  static const Color textTertiary  = Color(0xFF9CA3AF); // placeholder / hint
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dividers & borders
  static const Color divider       = Color(0xFFE5E7EB);
  static const Color border        = Color(0xFFD1D5DB);
  static const Color borderFocused = primary;

  // Status
  static const Color onlineGreen   = Color(0xFF22C55E);

  // ── Spacing scale (4dp base) ─────────────────────────────────────────────────
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

  // ── Type scale ───────────────────────────────────────────────────────────────
  // Sizes: 12 / 13 / 14 / 16 / 18 / 22 / 28 / 34
  // Weights: Regular 400 / Medium 500 / SemiBold 600 / Bold 700

  static const TextStyle displayStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.18,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle headingStyle = TextStyle(   // screen headings
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle titleLgStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLgStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.55,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.55,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle overlineStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textTertiary,
    height: 1.4,
    letterSpacing: 0.8,
  );

  // ── Material theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
    );
    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.nunito(textStyle: displayStyle),
        headlineMedium: GoogleFonts.nunito(textStyle: headlineStyle),
        titleLarge:    GoogleFonts.nunito(textStyle: headingStyle),
        titleMedium:   GoogleFonts.nunito(textStyle: titleLgStyle),
        titleSmall:    GoogleFonts.nunito(textStyle: titleStyle),
        bodyLarge:     GoogleFonts.nunito(textStyle: bodyLgStyle),
        bodyMedium:    GoogleFonts.nunito(textStyle: bodyStyle),
        labelLarge:    GoogleFonts.nunito(textStyle: labelStyle),
        labelSmall:    GoogleFonts.nunito(textStyle: captionStyle),
      ),

        // App bar
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Color(0x18000000),
          scrolledUnderElevation: 1,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: titleStyle,
        ),

        // Elevated button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textOnPrimary,
            disabledBackgroundColor: Color(0xFFBFD7FF),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMd)),
            padding: const EdgeInsets.symmetric(
                horizontal: spacingLg, vertical: spacingMd - 2),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            elevation: 0,
          ),
        ),

        // Outlined button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMd)),
            padding: const EdgeInsets.symmetric(
                horizontal: spacingLg, vertical: spacingMd - 2),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Text button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusSm)),
          ),
        ),

        // Input fields — filled with subtle border; focused shows blue border
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: spacingMd, vertical: spacingMd - 2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: error, width: 2),
          ),
          hintStyle: const TextStyle(
              color: textTertiary, fontSize: 14, fontWeight: FontWeight.w400),
          labelStyle:
              const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
          errorStyle:
              const TextStyle(color: error, fontSize: 12, height: 1.4),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            side: const BorderSide(color: divider, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: surfaceAlt,
          selectedColor: primary.withValues(alpha: 0.12),
          labelStyle: labelStyle,
          side: const BorderSide(color: divider),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusFull)),
          padding: const EdgeInsets.symmetric(horizontal: spacingXs),
        ),

        // Divider
        dividerColor: divider,
        dividerTheme: const DividerThemeData(color: divider, thickness: 1),

        // Bottom nav
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLg)),
          elevation: 24,
        ),

        // Bottom sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(radiusXl)),
          ),
          showDragHandle: true,
          dragHandleColor: border,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F2937),
          contentTextStyle: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusSm)),
          elevation: 6,
        ),
      );
  }
}
