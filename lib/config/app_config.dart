import 'dart:io';

/// Platform-specific configuration for App Store and Play Store compliance
class AppConfig {
  // Detect if we're building for iOS App Store
  static bool get isAppStoreBuild => Platform.isIOS;
  
  // Feature flags based on platform
  static bool get showBetaFeatures => !isAppStoreBuild;
  static bool get showTesterFeedback => !isAppStoreBuild;
  static bool get showStoreDialog => false; // Disabled for App Store submission (IAP paywall is the only monetization path)
  
  // API configuration
  static String get apiBaseUrl => "https://api.snapbeat.app";
  
  // Platform-specific settings
  static bool get allowInsecureNetwork => false; // Now using HTTPS
  
  // App version info
  static const String appVersion = "1.0.6";
  static const String buildNumber = "14";
}
