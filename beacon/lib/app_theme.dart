import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2F7A4E);
  static const accent = Color(0xFF3E9B6E);
  static const warning = Color(0xFFF59E0B);
  static const destructive = Colors.red;
  static const error = Colors.redAccent;
  static const background = Color(0xFFE6E8EB);
  static const navBar = Color(0xFFD9DDE2);
  static const heroTint = Color(0xFFDCE0E5);
  static const title = Color(0xFF1F2937);
  static const subtle = Color(0xFF4B5563);
  static const card = Colors.white;
  static const ink = Colors.black;
  static const onPrimary = Colors.white;
  static const border = Color(0xFFC6CBD3);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

class AppRadii {
  static const xs = 2.0;
  static const sm = 8.0;
  static const control = 10.0;
  static const md = 12.0;
  static const panel = 14.0;
  static const lg = 16.0;
  static const card = 18.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const pill = 999.0;
}

class AppAssets {
  static const stemLogoPlaceholder = 'assets/stem_logo_placeholder.jpg';
  static const googleLogo = 'assets/google_logo.png';
  static const microsoftLogo = 'assets/ms_logo.png';
  static const appleLogo = 'assets/apple_logo.png';
}

class AppLayout {
  static const desktopBreakpoint = 960.0;
  static const tabletBreakpoint = 720.0;
  static const providerMarkSize = 20.0;
  static const navBarActionButtonHeight = 40.0;
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.card,
          outline: AppColors.border,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navBar,
      foregroundColor: AppColors.title,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: AppColors.title,
          letterSpacing: -1.2,
          height: 1.08,
        ),
        headlineMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.title,
          height: 1.12,
        ),
        headlineSmall: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: AppColors.title,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.title,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.title,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.title,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.subtle,
          height: 1.45,
        ),
        bodySmall: TextStyle(fontSize: 13, color: AppColors.subtle),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.title,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        side: const BorderSide(color: AppColors.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: AppColors.subtle, fontSize: 13),
      labelStyle: const TextStyle(color: AppColors.subtle),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
    ),
  );
}
