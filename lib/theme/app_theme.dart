import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  /// The one theme the app ships.
  ///
  /// It is a **light** theme. Every surface in SnapBeat is either Ceramic White
  /// or a Piano Black card drawn on top of it, and the black cards style their
  /// own text explicitly. Declaring `Brightness.dark` here (as this file used to)
  /// made Material hand out light-on-light defaults for anything not styled by
  /// hand, and left the status bar icons white on a near-white background.
  static ThemeData get ceramicLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ceramicWhite,
      primaryColor: AppColors.textInkBlack,
      colorScheme: const ColorScheme.light(
        primary: AppColors.textInkBlack,
        secondary: AppColors.textInkSecondary,
        surface: AppColors.ceramicWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textInkBlack,
      ),
      cardColor: AppColors.ceramicWhite,
      dividerColor: AppColors.chassisBevelLight,
      // No font family is declared on purpose. Montserrat is not bundled (there
      // is no `flutter: fonts:` block in pubspec.yaml), so naming it here only
      // produced a silent fallback to the platform default — SF Pro on iOS,
      // Roboto on Android — while making the code look as though the design
      // font were in use. Bundling Montserrat changes the metrics of every
      // string in the app, so it is a deliberate post-submission change.
    );
  }

  /// Status bar / navigation bar styling for the ceramic surface.
  ///
  /// iOS reads `statusBarBrightness` (the brightness of the *background* behind
  /// the bar) and Android reads `statusBarIconBrightness` (the brightness of the
  /// *icons*). They are inverses of each other, and setting only the Android one
  /// — as `main.dart` used to — left white icons on Ceramic White.
  static const SystemUiOverlayStyle ceramicOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light, // iOS: light background
    statusBarIconBrightness: Brightness.dark, // Android: dark icons
    systemNavigationBarColor: AppColors.ceramicWhite,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  /// Overlay styling for the dark splash screen.
  static const SystemUiOverlayStyle splashOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark, // iOS: dark background
    statusBarIconBrightness: Brightness.light, // Android: light icons
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // Kept so existing call sites and any external tooling keep compiling.
  static ThemeData get retroMetalClassic => ceramicLight;
  static ThemeData get darkTheme => ceramicLight;
}
