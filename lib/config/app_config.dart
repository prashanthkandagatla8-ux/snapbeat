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
  static String get apiBaseUrl => const String.fromEnvironment("SNAPBEAT_API_BASE", defaultValue: "https://api.snapbeat.app");
  
  // Platform-specific settings
  static bool get allowInsecureNetwork => false; // Now using HTTPS
  
  // App version info
  static const String appVersion = "1.0.7";
  static const String buildNumber = "27";

  // Live privacy policy (verified reachable 2026-09-20). Apple requires a working link on the
  // paywall and in App Store Connect metadata; a null here made the paywall Privacy link a
  // silent no-op, which is a guideline 5.1.1 rejection.
  static const String privacyPolicyUrl = "https://snapbeat.app/privacy";
}
