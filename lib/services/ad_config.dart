import 'dart:io';

import 'package:flutter/foundation.dart';

/// Configuration constants, ad unit IDs for AdMob Interstitial.
class AdConfig {
  AdConfig._();

  // ---------------------------------------------------------------------------
  // ADMOB PRODUCTION APP IDs (REPLACE_BEFORE_RELEASE)
  // ---------------------------------------------------------------------------
  // iOS App ID: Must also be placed in ios/Runner/Info.plist under GADApplicationIdentifier
  static const String prodIosAppId = 'ca-app-pub-2850833794586490~5758165037';
  static const String prodAndroidAppId = 'ca-app-pub-2850833794586490~7105482242';

  // ---------------------------------------------------------------------------
  // INTERSTITIAL AD UNIT IDs
  // ---------------------------------------------------------------------------
  // Google's official test interstitial units. Safe to ship in debug only.
  static const String testAndroidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialAdUnitId     = 'ca-app-pub-3940256099942544/4411468910';

  // Live interstitial units, created 2026-09-20. "SnapBeat Android Interstitial Preroll" sits
  // under the Android app (~7105482242) and "SnapBeat iOS Interstitial Preroll" under the iOS app
  // (~5758165037) -- a unit only serves for the app it belongs to, so crossing these over yields
  // no fill rather than an error, which is a slow thing to notice. The pairing was confirmed
  // against the existing rewarded units already listed under each app.
  static const String prodAndroidInterstitialAdUnitId = 'ca-app-pub-2850833794586490/2423468375';
  static const String prodIosInterstitialAdUnitId     = 'ca-app-pub-2850833794586490/6557145349';

  /// True during development/debug, false in release builds.
  /// When true, official Google sample test ads are served.
  static bool get useTestAds => kDebugMode;

  /// Returns active interstitial ad unit ID based on platform and build mode.
  ///
  /// Falls back to the test unit if a production ID is ever blank. An empty ad unit ID makes
  /// every load fail silently, which looks identical to having no fill, so it is better to serve
  /// a test ad and complain loudly in the log than to ship a dead ad slot.
  static String get interstitialAdUnitId {
    final testId =
        Platform.isIOS ? testIosInterstitialAdUnitId : testAndroidInterstitialAdUnitId;
    if (useTestAds) return testId;

    final prodId =
        Platform.isIOS ? prodIosInterstitialAdUnitId : prodAndroidInterstitialAdUnitId;
    if (prodId.isEmpty) {
      debugPrint('[AdConfig] WARNING: production interstitial unit is blank for '
          '${Platform.isIOS ? "iOS" : "Android"}. Falling back to the test unit.');
      return testId;
    }
    return prodId;
  }

  /// Minimum gap between two pre-roll interstitials. The user asked for an ad on every play;
  /// AdMob penalises interstitials shown in quick succession, so a short floor protects the
  /// account without changing the intent. Set to Duration.zero to show one on literally every
  /// play.
  static const Duration minGapBetweenAds = Duration(seconds: 45);
}
