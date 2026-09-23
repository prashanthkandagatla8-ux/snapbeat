import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get retroMetalClassic => darkTheme;
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ceramicWhite,
      primaryColor: AppColors.pianoBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.pianoBlack,
        secondary: AppColors.amberGold,
        surface: AppColors.pianoBlack,
        onPrimary: AppColors.textPureWhite,
        onSecondary: AppColors.textPureWhite,
        onSurface: AppColors.textPureWhite,
      ),
      cardColor: AppColors.pianoBlack,
      dividerColor: AppColors.ceramicWell,
      fontFamily: 'Montserrat',
      fontFamilyFallback: const ['Montserrat', 'Segoe UI', 'Roboto'],
    );
  }
}
