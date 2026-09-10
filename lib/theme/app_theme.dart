import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get retroMetalClassic {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvasChassis,
      primaryColor: AppColors.brassGold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brassGold,
        secondary: AppColors.brassHighlight,
        surface: AppColors.panelCream,
        onPrimary: AppColors.hardwareGunmetal,
        onSecondary: AppColors.hardwareGunmetal,
        onSurface: AppColors.textEngraved,
      ),
      cardColor: AppColors.panelCream,
      dividerColor: AppColors.chassisBevelLight,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.textEngraved,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textEngraved,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textEngraved,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
