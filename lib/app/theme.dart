
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFFEC4899);
  static const Color background = Color(0xFF111827);
  static const Color surface = Color(0xFF1F2937);
  static const Color textWhite = Color(0xFFF9FAFB);
  static const Color mutedText = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
}

class AppTextStyles {
  static final TextStyle h1 = GoogleFonts.outfit(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static final TextStyle h2 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static final TextStyle body = GoogleFonts.notoSansKr(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textWhite,
  );

  static final TextStyle caption = GoogleFonts.notoSansKr(
    fontSize: 12,
    color: AppColors.mutedText,
  );
  
  static final TextStyle handwriting = GoogleFonts.nanumPenScript();
}

ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.textWhite,
    onSecondary: AppColors.textWhite,
    onBackground: AppColors.textWhite,
    onSurface: AppColors.textWhite,
    onError: AppColors.textWhite,
  ),
  textTheme: TextTheme(
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
  ),
  // more theme properties
);
