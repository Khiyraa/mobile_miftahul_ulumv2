import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors (The Serene Guardian)
  static const Color primary = Color(0xFF0D631B);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  static const Color secondaryContainer = Color(0xFFB7F481);
  static const Color onSecondaryContainer = Color(0xFF3E7109);
  
  static const Color tertiary = Color(0xFF923357); // For critical alerts
  static const Color onTertiary = Color(0xFFFFFFFF);
  
  static const Color background = Color(0xFFF8FAF8);
  static const Color onBackground = Color(0xFF191C1B);
  
  static const Color surface = Color(0xFFF8FAF8);
  static const Color onSurface = Color(0xFF191C1B);
  static const Color onSurfaceVariant = Color(0xFF40493D);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F2);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E7);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E1);

  static const Color outlineVariant = Color(0xFFBFCABA);

  // Text Styles
  static TextStyle get displayMd => GoogleFonts.manrope(
        fontSize: 36, // Adjust as needed
        fontWeight: FontWeight.bold,
        color: onSurface,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySm => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      );

  static TextStyle get titleMd => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onSurface,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      );

  // Shadows
  static List<BoxShadow> get ambientShadow => [
        BoxShadow(
          color: onSurface.withOpacity(0.06),
          blurRadius: 24,
          spreadRadius: -4,
          offset: const Offset(0, 8),
        )
      ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayMedium: displayMd,
        displaySmall: displaySm,
        headlineSmall: headlineSm,
        titleMedium: titleMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelMedium: labelMd,
      ),
      // Glass & Gradient rules can be implemented in specific widgets
    );
  }
}
