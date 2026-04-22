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

class AppOpacity {
  static const faint = 0.04;
  static const hairline = 0.05;
  static const soft = 0.08;
  static const weak = 0.1;
  static const chip = 0.15;
  static const subtle = 0.12;
  static const muted = 0.16;
  static const medium = 0.2;
  static const accent = 0.35;
  static const strong = 0.4;
  static const emphatic = 0.45;
  static const focus = 0.48;
  static const borderStrong = 0.55;
  static const borderMuted = 0.7;
  static const overlay = 0.72;
  static const pronounced = 0.75;
  static const heavy = 0.8;
}

class AppInsets {
  static const button = EdgeInsets.symmetric(vertical: 14, horizontal: 22);

  static const textButton = EdgeInsets.symmetric(horizontal: 14, vertical: 10);

  static const inputContent = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.lg,
  );

  static const inputDense = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: 14,
  );

  static const newsletterInput = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: 14,
  );

  static const authCard = EdgeInsets.fromLTRB(16, 16, 16, 14);
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
  static const homeHorizontalPaddingDesktop = 48.0;
  static const homeHorizontalPaddingTablet = 28.0;
  static const homeHorizontalPaddingMobile = AppSpacing.lg;
  static const homeScreenVerticalPadding = 28.0;
  static const navBarActionButtonHeight = 40.0;

  static const authWideBreakpoint = 760.0;
  static const authHorizontalPaddingWide = 28.0;
  static const authHorizontalPaddingNarrow = AppSpacing.lg;
  static const authContentMaxWidth = 680.0;
  static const authChoiceCardMaxWidth = 420.0;
  static const authScreenTopPadding = AppSpacing.lg;
  static const authScreenBottomPadding = AppSpacing.xxl;
  static const authScreenBottomGap = 18.0;
  static const authLogoWidth = 180.0;
  static const authLogoHeight = 110.0;
  static const providerMarkSize = 20.0;
}

class AppTextStyles {
  static const dialogTitle = TextStyle(
    fontWeight: FontWeight.w800,
    color: AppColors.title,
  );

  static const authPanelMessage = TextStyle(
    fontSize: 15,
    color: AppColors.subtle,
    height: 1.45,
  );

  static const dividerCaption = TextStyle(
    color: AppColors.subtle,
    fontSize: 13,
  );

  static const subtleAction = TextStyle(color: AppColors.subtle, fontSize: 14);

  static const subtleActionSmall = TextStyle(
    color: AppColors.subtle,
    fontSize: 12,
  );

  static const helperBody = TextStyle(
    fontSize: 13,
    color: AppColors.subtle,
    height: 1.5,
  );

  static const authHeroSubtitle = TextStyle(
    fontSize: 17,
    color: AppColors.subtle,
    height: 1.4,
  );
}

class AppSurfaces {
  static final authInfoPanel = BoxDecoration(
    color: AppColors.heroTint.withValues(alpha: AppOpacity.heavy),
    borderRadius: BorderRadius.circular(AppRadii.panel),
    border: Border.all(color: AppColors.border),
  );

  static final authFormCard = BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(AppRadii.lg),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: AppColors.ink.withValues(alpha: AppOpacity.hairline),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static final authLogoPlaceholder = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppRadii.md),
  );
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
        padding: AppInsets.button,
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
        padding: AppInsets.button,
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
        padding: AppInsets.textButton,
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
      contentPadding: AppInsets.inputContent,
    ),
  );
}
