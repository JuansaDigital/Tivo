import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/tivo_colors.dart';

class TivoTheme {
  TivoTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme();
    final bodyTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TivoColors.bgDeepNavy,
      primaryColor: TivoColors.primaryIceBlue,
      colorScheme: const ColorScheme.dark(
        primary: TivoColors.primaryIceBlue,
        secondary: TivoColors.accentElectricCyan,
        surface: TivoColors.bgCard,
        error: TivoColors.statusExpenseRose,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: TivoColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: TivoColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: TivoColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: TivoColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TivoColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TivoColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TivoColors.textPrimary,
        ),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(
          fontSize: 15,
          color: TivoColors.textPrimary,
        ),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: TivoColors.textSecondary,
        ),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: TivoColors.textTertiary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: TivoColors.textPrimary),
      ),
    );
  }
}
