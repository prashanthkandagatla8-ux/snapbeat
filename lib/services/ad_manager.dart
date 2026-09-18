import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'subscription_manager.dart';

/// Centralized lifecycle manager for Google AdMob Rewarded Video ads and UMP consent.
class AdManager with ChangeNotifier {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isShowing = false;
  RewardedAd? _rewardedAd;
  int _loadRetryAttempt = 0;

  bool get isAdReady => _rewardedAd != null;
  bool get isLoading => _isLoading;
  bool get isShowing => _isShowing;

  /// Initializes MobileAds SDK and requests UMP consent before preloading.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final initStatus = await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdManager] MobileAds initialized: ${initStatus.adapterStatuses}');

      // Request UMP GDPR / ATT consent form if needed
      await _requestConsent();

      // Start preloading the first rewarded ad
      preloadRewardedAd();
    } catch (e) {
      debugPrint('[AdManager] Initialization error: $e');
      _isInitialized = true;
    }
  }

  /// Handles User Messaging Platform (UMP) consent information and displays form if required.
  Future<void> _requestConsent() async {
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        ConsentForm.loadAndShowConsentFormIfRequired(
          (formError) {
            if (formError != null) {
              debugPrint('[AdManager] Consent form error: ${formError.message}');
            }
          },
        );
      },
      (formError) {
        debugPrint('[AdManager] Consent info update error: ${formError.message}');
      },
    );
  }

  /// Preloads a rewarded video ad in the background with exponential retry.
  void preloadRewardedAd() {
    if (_rewardedAd != null || _isLoading) return;

    // Skip ad loading if user already has an active Pro subscription
    if (SubscriptionManager.instance.isPro) {
      debugPrint('[AdManager] User is Pro. Skipping ad preload.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final adUnitId = AdConfig.rewardedAdUnitId;
    debugPrint('[AdManager] Preloading RewardedAd with ID: $adUnitId');

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] RewardedAd successfully loaded.');
          _rewardedAd = ad;
          _isLoading = false;
          _loadRetryAttempt = 0;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] RewardedAd failed to load: ${error.message} (Code: ${error.code})');
          _rewardedAd = null;
          _isLoading = false;
          notifyListeners();

          // Exponential backoff retry (up to 3 attempts, max 30s)
          _loadRetryAttempt++;
          if (_loadRetryAttempt <= 3) {
            final delaySeconds = (1 << _loadRetryAttempt) * 2;
            debugPrint('[AdManager] Retrying ad load in ${delaySeconds}s (attempt $_loadRetryAttempt)...');
            Timer(Duration(seconds: delaySeconds), preloadRewardedAd);
          }
        },
      ),
    );
  }

  /// Displays the rewarded video ad to unlock a clean download or export.
  ///
  /// - If user is Pro: bypasses ads immediately and invokes [onRewardEarned].
  /// - If ad is not ready or fails to display: invokes [onFallbackGranted] so the user is NEVER blocked!
  /// - If user completes the ad: invokes [onRewardEarned] and preloads the next ad.
  Future<void> showRewardedAd({
    required BuildContext context,
    required VoidCallback onRewardEarned,
    VoidCallback? onDismissed,
    required VoidCallback onFallbackGranted,
  }) async {
    // 1. Pro subscribers bypass all ads
    if (SubscriptionManager.instance.isPro) {
      debugPrint('[AdManager] Pro user detected. Bypassing ad.');
      onRewardEarned();
      return;
    }

    // 2. If ad is not loaded, gracefully fall back (never block user download!)
    if (_rewardedAd == null) {
      debugPrint('[AdManager] No ad ready. Falling back gracefully to grant clean export.');
      preloadRewardedAd();
      onFallbackGranted();
      return;
    }

    _isShowing = true;
    notifyListeners();

    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdManager] Ad showing full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdManager] Ad dismissed.');
        ad.dispose();
        _rewardedAd = null;
        _isShowing = false;
        notifyListeners();

        // Immediately preload next ad
        preloadRewardedAd();

        if (userEarnedReward) {
          onRewardEarned();
        } else {
          onDismissed?.call();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdManager] Ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isShowing = false;
        notifyListeners();

        // Gracefully grant reward on display failure
        preloadRewardedAd();
        onFallbackGranted();
      },
    );

    // Show ad and capture reward callback
    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('[AdManager] User earned reward: ${reward.amount} ${reward.type}');
        userEarnedReward = true;
      },
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}
