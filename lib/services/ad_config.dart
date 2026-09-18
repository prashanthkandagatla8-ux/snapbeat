import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration constants, ad unit IDs, and daily quota manager for AdMob Rewarded Video.
class AdConfig {
  AdConfig._();

  // ---------------------------------------------------------------------------
  // ADMOB PRODUCTION APP IDs (REPLACE_BEFORE_RELEASE)
  // ---------------------------------------------------------------------------
  // iOS App ID: Must also be placed in ios/Runner/Info.plist under GADApplicationIdentifier
  static const String prodIosAppId = 'ca-app-pub-2850833794586490~5758165037';
  static const String prodAndroidAppId = 'ca-app-pub-3940256099942544~3347511713'; // REPLACE_BEFORE_RELEASE: e.g. ca-app-pub-XXXXXXXXXX~ZZZZZZZZZZ

  // ---------------------------------------------------------------------------
  // REWARDED VIDEO AD UNIT IDs
  // ---------------------------------------------------------------------------
  // Official Google AdMob Test Rewarded Ad Unit IDs
  static const String testIosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  static const String testAndroidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Production Rewarded Ad Unit IDs
  static const String prodIosRewardedAdUnitId = 'ca-app-pub-2850833794586490/6137081169';
  static const String prodAndroidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // REPLACE_BEFORE_RELEASE: your Android Rewarded Ad Unit ID

  /// True during development/debug, false in release builds.
  /// When true, official Google sample test ads are served.
  static bool get useTestAds => kDebugMode;

  /// Returns active rewarded ad unit ID based on platform and build mode.
  static String get rewardedAdUnitId {
    if (useTestAds) {
      return Platform.isIOS ? testIosRewardedAdUnitId : testAndroidRewardedAdUnitId;
    }
    return Platform.isIOS ? prodIosRewardedAdUnitId : prodAndroidRewardedAdUnitId;
  }

  // ---------------------------------------------------------------------------
  // FAIR UX FREQUENCY CAPPING (MAX 5 CLEAN PASSES PER DAY)
  // ---------------------------------------------------------------------------
  static const int maxDailyAdCleanDownloads = 5;
  static const String _keyDailyDate = 'snapbeat_ad_pass_date';
  static const String _keyDailyCount = 'snapbeat_ad_pass_count';

  /// Returns the number of ad clean passes remaining for today (0..maxDailyAdCleanDownloads).
  static Future<int> getRemainingPassesToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayKey();
    final storedDate = prefs.getString(_keyDailyDate) ?? '';

    if (storedDate != todayStr) {
      // New day: reset counter
      await prefs.setString(_keyDailyDate, todayStr);
      await prefs.setInt(_keyDailyCount, 0);
      return maxDailyAdCleanDownloads;
    }

    final used = prefs.getInt(_keyDailyCount) ?? 0;
    return (maxDailyAdCleanDownloads - used).clamp(0, maxDailyAdCleanDownloads);
  }

  /// Checks if the user still has at least 1 ad clean pass remaining today.
  static Future<bool> hasPassesRemainingToday() async {
    final remaining = await getRemainingPassesToday();
    return remaining > 0;
  }

  /// Consumes 1 ad clean pass for today upon successfully watching the ad.
  static Future<int> consumeDailyPass() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayKey();
    final storedDate = prefs.getString(_keyDailyDate) ?? '';

    int used = 0;
    if (storedDate == todayStr) {
      used = prefs.getInt(_keyDailyCount) ?? 0;
    }

    used += 1;
    await prefs.setString(_keyDailyDate, todayStr);
    await prefs.setInt(_keyDailyCount, used);
    return (maxDailyAdCleanDownloads - used).clamp(0, maxDailyAdCleanDownloads);
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
