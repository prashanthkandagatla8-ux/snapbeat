import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'subscription_manager.dart';

/// Centralized lifecycle manager for Google AdMob Interstitial Video ads and UMP consent.
class AdManager with ChangeNotifier {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isShowing = false;
  InterstitialAd? _interstitialAd;
  int _loadRetryAttempt = 0;
  DateTime? _lastAdShownTime;

  bool get isAdReady => _interstitialAd != null;
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

      // Start preloading the first interstitial ad
      preloadInterstitial();
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

  /// Preloads an interstitial video ad in the background with exponential retry.
  void preloadInterstitial() {
    if (_interstitialAd != null || _isLoading) return;

    // Skip ad loading if user already has an active Pro subscription
    if (SubscriptionManager.instance.isPro) {
      debugPrint('[AdManager] User is Pro. Skipping ad preload.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final adUnitId = AdConfig.interstitialAdUnitId;
    debugPrint('[AdManager] Preloading InterstitialAd with ID: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdManager] InterstitialAd successfully loaded.');
          _interstitialAd = ad;
          _isLoading = false;
          _loadRetryAttempt = 0;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] InterstitialAd failed to load: ${error.message} (Code: ${error.code})');
          _interstitialAd = null;
          _isLoading = false;
          notifyListeners();

          // Exponential backoff retry (up to 3 attempts, max 30s)
          _loadRetryAttempt++;
          if (_loadRetryAttempt <= 3) {
            final delaySeconds = (1 << _loadRetryAttempt) * 2;
            debugPrint('[AdManager] Retrying ad load in ${delaySeconds}s (attempt $_loadRetryAttempt)...');
            Timer(Duration(seconds: delaySeconds), preloadInterstitial);
          }
        },
      ),
    );
  }

  /// Shows the pre-roll interstitial, then runs [onDone] exactly once.
  ///
  /// [onDone] runs whatever happens: Pro user, ad dismissed, ad failed to load, ad failed to
  /// show. There is no path where the user taps PLAY and nothing happens, and no path where
  /// [onDone] runs twice.
  Future<void> showBeforePlayback({
    required BuildContext context,
    required VoidCallback onDone,
  }) async {
    // 1. Pro subscribers bypass all ads
    if (SubscriptionManager.instance.isPro) {
      debugPrint('[AdManager] Pro user detected. Bypassing ad.');
      onDone();
      return;
    }
    
    // Check gap
    if (_lastAdShownTime != null) {
      final diff = DateTime.now().difference(_lastAdShownTime!);
      if (diff < AdConfig.minGapBetweenAds) {
        debugPrint('[AdManager] Minimum gap between ads not reached. Skipping ad.');
        onDone();
        return;
      }
    }

    // 2. If ad is not loaded, gracefully fall back (never block user download!)
    if (_interstitialAd == null) {
      debugPrint('[AdManager] No ad ready. Falling back gracefully to playback.');
      preloadInterstitial();
      onDone();
      return;
    }

    _isShowing = true;
    notifyListeners();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdManager] Ad showing full screen.');
        _lastAdShownTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdManager] Ad dismissed.');
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        notifyListeners();

        // Immediately preload next ad
        preloadInterstitial();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdManager] Ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        notifyListeners();

        // Gracefully grant playback on display failure
        preloadInterstitial();
        onDone();
      },
    );

    // Show ad
    await _interstitialAd!.show();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
