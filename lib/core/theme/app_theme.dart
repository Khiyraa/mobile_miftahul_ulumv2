import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tailwind Colors
  static const Color surfaceDim = Color(0xFFD8DAD9);
  static const Color onSecondaryFixedVariant = Color(0xFF285000);
  static const Color onSurfaceVariant = Color(0xFF40493D);
  static const Color tertiaryFixed = Color(0xFFFFD9E2);
  static const Color surfaceContainer = Color(0xFFECEEEC);
  static const Color onPrimaryFixed = Color(0xFF00201A);
  static const Color primaryContainer = Color(0xFF0F766E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondaryFixedDim = Color(0xFF9CD769);
  static const Color onTertiaryContainer = Color(0xFFFFEDF0);
  static const Color onTertiaryFixed = Color(0xFF3F001C);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E1);
  static const Color onSurface = Color(0xFF191C1B);
  static const Color onTertiaryFixedVariant = Color(0xFF7F2448);
  static const Color error = Color(0xFFBA1A1A);
  static const Color secondaryContainer = Color(0xFFB7F481);
  static const Color onPrimaryFixedVariant = Color(0xFF005312);
  static const Color surfaceBright = Color(0xFFF8FAF8);
  static const Color surface = Color(0xFFF8FAF8);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color inverseSurface = Color(0xFF2E3130);
  static const Color secondary = Color(0xFF386B01);
  static const Color tertiaryContainer = Color(0xFFB14B6F);
  static const Color inversePrimary = Color(0xFF88D982);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color secondaryFixed = Color(0xFFB7F481);
  static const Color background = Color(0xFFF8FAF8);
  static const Color surfaceContainerLow = Color(0xFFF2F4F2);
  static const Color primaryFixed = Color(0xFFA3F69C);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E7);
  static const Color primaryFixedDim = Color(0xFF88D982);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onSecondaryFixed = Color(0xFF0D2000);
  static const Color outline = Color(0xFF707A6C);
  static const Color surfaceTint = Color(0xFF1B6D24);
  static const Color tertiaryFixedDim = Color(0xFFFFB1C7);
  static const Color inverseOnSurface = Color(0xFFEFF1EF);
  static const Color onPrimaryContainer = Color(0xFFCBFFC2);
  static const Color primary = Color(0xFF0D9488);
  static const Color outlineVariant = Color(0xFFCBD5E1);
  static const Color onSecondaryContainer = Color(0xFF334155);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFF923357);
  static const Color onBackground = Color(0xFF191C1B);
  static const Color surfaceVariant = Color(0xFFE1E3E1);

  // Typography
  static TextStyle get headline => GoogleFonts.manrope();
  static TextStyle get body => GoogleFonts.inter();
  static TextStyle get label => GoogleFonts.inter();

  // Shared Box Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: onSurface.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        )
      ];
      
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: primary.withValues(alpha: 0.1),
          blurRadius: 15,
          offset: const Offset(0, 10),
          spreadRadius: -3,
        ),
        BoxShadow(
          color: primary.withValues(alpha: 0.1),
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        )
      ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
    );
  }

  // Backward compatibility for unmigrated screens
  static TextStyle get displayMd => GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold);
  static TextStyle get headlineSm => GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle get titleMd => GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700);
  static TextStyle get bodyLg => GoogleFonts.inter(fontSize: 16);
  static TextStyle get bodyMd => GoogleFonts.inter(fontSize: 14);
  static TextStyle get labelMd => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500);
  static List<BoxShadow> get ambientShadow => shadowSm;
}
