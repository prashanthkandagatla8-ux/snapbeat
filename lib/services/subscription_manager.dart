
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Result of backend receipt verification.
enum BackendVerificationResult {
  valid,
  invalid,
  transportError,
}

/// Supported Pro subscription tier identifiers.
enum ProTier {
  daily,
  weekly,
  monthly,
  annual,
}

extension ProTierExtension on ProTier {
  String get productId {
    switch (this) {
      case ProTier.daily:
        return SubscriptionManager.idDaily;
      case ProTier.weekly:
        return SubscriptionManager.idWeekly;
      case ProTier.monthly:
        return SubscriptionManager.idMonthly;
      case ProTier.annual:
        return SubscriptionManager.idAnnual;
    }
  }

  String get legacyProductId {
    switch (this) {
      case ProTier.daily:
        return SubscriptionManager.legacyIdDaily;
      case ProTier.weekly:
        return SubscriptionManager.legacyIdWeekly;
      case ProTier.monthly:
        return SubscriptionManager.legacyIdMonthly;
      case ProTier.annual:
        return SubscriptionManager.legacyIdAnnual;
    }
  }

  String get displayName {
    switch (this) {
      case ProTier.daily:
        return 'Daily Pass';
      case ProTier.weekly:
        return 'Weekly Pass';
      case ProTier.monthly:
        return 'Monthly VIP';
      case ProTier.annual:
        return 'Annual VIP';
    }
  }

  String get fallbackPriceInr {
    switch (this) {
      case ProTier.daily:
        return '₹99';
      case ProTier.weekly:
        // Verified against App Store Connect 2026-09-25: India (INR) = ₹199.00
        return '₹199';
      case ProTier.monthly:
        return '₹499';
      case ProTier.annual:
        return '₹2,499';
    }
  }

  String get fallbackPriceUsd {
    switch (this) {
      case ProTier.daily:
        return '\$0.99';
      case ProTier.weekly:
        return '\$1.99';
      case ProTier.monthly:
        return '\$4.99';
      case ProTier.annual:
        return '\$24.99';
    }
  }

  String get billingUnit {
    switch (this) {
      case ProTier.daily:
        return '/day';
      case ProTier.weekly:
        return '/week';
      case ProTier.monthly:
        return '/mo';
      case ProTier.annual:
        return '/yr';
    }
  }

  String get defaultDisplayPrice => '$fallbackPriceInr$billingUnit';

  String get badgeText {
    switch (this) {
      case ProTier.daily:
        return 'QUICK ACCESS';
      case ProTier.weekly:
        return 'FLEXIBLE';
      case ProTier.monthly:
        return 'POPULAR';
      case ProTier.annual:
        // Derived from the surviving fallback table, both currencies agree:
        // INR 499*12 = 5,988 -> 2,499 = 58.3% off
        // USD 4.99*12 = 59.88 -> 24.99 = 58.3% off
        // (50% came from a since-deleted $29.99; 57% was the older, near-correct value)
        return 'SAVE 58%';
    }
  }
}

/// Consumable credit top-up tiers for extra renders.
enum CreditTopUp {
  pack10,
  pack50,
}

extension CreditTopUpExtension on CreditTopUp {
  String get productId {
    switch (this) {
      case CreditTopUp.pack10:
        return SubscriptionManager.idTopUp10;
      case CreditTopUp.pack50:
        return SubscriptionManager.idTopUp50;
    }
  }

  String get legacyProductId {
    switch (this) {
      case CreditTopUp.pack10:
        return SubscriptionManager.legacyIdTopUp10;
      case CreditTopUp.pack50:
        return SubscriptionManager.legacyIdTopUp50;
    }
  }

  int get credits {
    switch (this) {
      case CreditTopUp.pack10:
        return 10;
      case CreditTopUp.pack50:
        return 50;
    }
  }

  String get displayName {
    switch (this) {
      case CreditTopUp.pack10:
        return '10 Extra Credits';
      case CreditTopUp.pack50:
        return '50 Extra Credits';
    }
  }

  String get fallbackPriceInr {
    switch (this) {
      case CreditTopUp.pack10:
        return '₹69';
      case CreditTopUp.pack50:
        return '₹269';
    }
  }

  String get fallbackPriceUsd {
    switch (this) {
      case CreditTopUp.pack10:
        return '\$1.99';
      case CreditTopUp.pack50:
        return '\$4.99';
    }
  }
}

/// Centralized In-App Purchase and Entitlement Manager for SnapBeat Pro.
class SubscriptionManager with ChangeNotifier {
  // Store Product Identifiers (Updated to snapbeat_studio_* because Apple permanently reserves deleted IDs)
  static const String idDaily = 'snapbeat_studio_pro_daily';
  static const String idWeekly = 'snapbeat_studio_pro_weekly';
  static const String idMonthly = 'snapbeat_studio_pro_monthly';
  static const String idAnnual = 'snapbeat_studio_pro_yearly';

  // Legacy fallback identifiers
  static const String legacyIdDaily = 'snapbeat_pro_daily';
  static const String legacyIdWeekly = 'snapbeat_pro_weekly';
  static const String legacyIdMonthly = 'snapbeat_pro_monthly';
  static const String legacyIdAnnual = 'snapbeat_pro_yearly';

  // Consumable Top-Up Product Identifiers
  static const String idTopUp10 = 'snapbeat_studio_credits_10';
  static const String idTopUp50 = 'snapbeat_studio_credits_50';
  static const String legacyIdTopUp10 = 'snapbeat_credits_10';
  static const String legacyIdTopUp50 = 'snapbeat_credits_50';

  static const Set<String> allProductIds = {
    idDaily,
    idWeekly,
    idMonthly,
    idAnnual,
    legacyIdDaily,
    legacyIdWeekly,
    legacyIdMonthly,
    legacyIdAnnual,
    idTopUp10,
    idTopUp50,
    legacyIdTopUp10,
    legacyIdTopUp50,
  };

  /// Product IDs enabled for store queries on current platform.
  ///
  /// Only the three auto-renewable subscriptions exist in App Store Connect /
  /// Play Console. The consumable credit top-up packs were never created, so
  /// querying them returned them in `notFoundIDs` and the top-up UI rendered
  /// buttons that could not transact. Per the settled monetization model there
  /// are no top-ups at launch, so they are excluded here.
  /// Legacy IDs are retained in the query only as a read-only migration path for
  /// installs that transacted against the pre-rename identifiers.
  static Set<String> get activeProductIds => {
        idWeekly, idMonthly, idAnnual,
        legacyIdWeekly, legacyIdMonthly, legacyIdAnnual,
      };

  /// Available subscription tiers for current platform.
  /// Strictly unified across iOS and Android: Annual VIP, Monthly VIP, and Weekly Pass.
  static List<ProTier> get availableTiers => [
        ProTier.annual,
        ProTier.monthly,
        ProTier.weekly,
      ];

  // Preference Storage Keys
  static const String _keyIsPro = 'snapbeat_iap_is_pro_active';
  static const String _keyTier = 'snapbeat_iap_active_tier';
  static const String _keyExpiresAt = 'snapbeat_iap_expires_at_ms';
  static const String _keyOriginalTxId = 'snapbeat_iap_original_tx_id';
  static const String _keyToken = 'snapbeat_iap_signed_token';
  static const String _keyChecksum = 'snapbeat_iap_integrity_hash';
  static const String _keyCreditBalance = 'snapbeat_user_credit_balance';
  static const String _keyIsGrace = 'snapbeat_iap_is_grace_entitlement';
  static const String _keyGraceGrantedAt = 'snapbeat_iap_grace_granted_at_ms';
  int _creditBalance = 10;
  static const String _salt = 'SnapBeat_v105_SecuritySalt_#99824';

  static final SubscriptionManager instance = SubscriptionManager._internal();
  SubscriptionManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  @visibleForTesting
  Dio? dioOverride;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Upper bound on how long the paywall CTA may stay in its spinner state.
  /// StoreKit's own sheet can legitimately sit open for a while, so this is
  /// generous; it exists only to guarantee the button is never permanently dead.
  static const Duration purchaseWatchdogTimeout = Duration(seconds: 90);

  @visibleForTesting
  Future<void> handlePurchaseUpdateForTesting(PurchaseDetails purchase) async {
    await _onPurchaseUpdates([purchase]);
  }
  Timer? _purchaseWatchdog;

  // Local Entitlement State
  bool _isPro = false;
  bool _isGraceEntitlement = false;
  ProTier? _activeTier;
  DateTime? _expiresAt;
  String? _originalTransactionId;
  String? _signedEntitlementToken;

  // Store & Purchase State
  bool _isStoreAvailable = false;
  bool _isLoadingProducts = false;
  bool _isPurchasing = false;
  String? _statusMessage;
  final Map<String, ProductDetails> _products = {};

  // Getters
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isPurchasing => _isPurchasing;
  String? get statusMessage => _statusMessage;
  Map<String, ProductDetails> get products => _products;

  // Credit Balance Management
  int get creditBalance => _creditBalance;
  /// Label for the entitlement chip.
  ///
  /// Deliberately does NOT show a credit count for free users. Credits are
  /// granted with a subscription and are held on the server ledger; the local
  /// `_creditBalance` is never spent (`deductCredit` has no caller), so showing
  /// "10 CREDITS" to a free user promised a currency that does not exist for
  /// them. The free tier's real constraint is the daily render allowance, which
  /// `home_screen` supplies via [freeTierDisplay].
  String get creditBalanceDisplay => _isPro ? "PRO UNLIMITED" : "FREE 360p";

  /// Free-tier chip label showing the remaining daily allowance.
  static String freeTierDisplay(int rendersRemaining) =>
      rendersRemaining <= 0 ? "DAILY LIMIT REACHED" : "$rendersRemaining OF 3 FREE TODAY";

  Future<void> deductCredit([int amount = 1]) async {
    if (_isPro) return;
    _creditBalance = (_creditBalance - amount) < 0 ? 0 : (_creditBalance - amount);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCreditBalance, _creditBalance);
    notifyListeners();
  }

  Future<void> addCredits(int amount) async {
    _creditBalance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCreditBalance, _creditBalance);
    notifyListeners();
  }

  /// Resolves the store product for a Pro tier, checking modern ID first then legacy ID.
  ProductDetails? productForTier(ProTier tier) {
    return _products[tier.productId] ?? _products[tier.legacyProductId];
  }

  /// Resolves the store product for a Top-Up pack.
  ProductDetails? productForTopUp(CreditTopUp topUp) {
    return _products[topUp.productId] ?? _products[topUp.legacyProductId];
  }

  /// Returns live StoreKit / Play Store price, falling back to canonical price table.
  String formattedPrice(ProTier tier) {
    final product = productForTier(tier);
    if (product != null && product.price.isNotEmpty) {
      return product.price;
    }
    final locale = PlatformDispatcher.instance.locale;
    if (locale.countryCode == 'IN') {
      return tier.fallbackPriceInr;
    }
    return tier.fallbackPriceUsd;
  }

  /// Returns live StoreKit / Play Store price for a top-up pack.
  String formattedTopUpPrice(CreditTopUp topUp) {
    final product = productForTopUp(topUp);
    if (product != null && product.price.isNotEmpty) {
      return product.price;
    }
    final locale = PlatformDispatcher.instance.locale;
    if (locale.countryCode == 'IN') {
      return topUp.fallbackPriceInr;
    }
    return topUp.fallbackPriceUsd;
  }

  /// Effective Pro status (checks local active flag AND expiry timestamp).
  bool get isPro {
    if (!_isPro) return false;
    if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
      _isPro = false;
      return false;
    }
    return true;
  }

  ProTier? get activeTier => isPro ? _activeTier : null;
  DateTime? get expiresAt => _expiresAt;
  String? get originalTransactionId => _originalTransactionId;

  /// Whether the user is currently in a temporary offline grace window.
  bool get isGraceEntitlement => _isGraceEntitlement;

  /// Whether the user has cryptographic server-verified Pro render entitlements.
  /// Offline grace window unlocks UI paywall dismissal only, NOT unwatermarked/1080p renders.
  bool get hasRenderEntitlement =>
      isPro && !_isGraceEntitlement && (_signedEntitlementToken != null && _signedEntitlementToken!.isNotEmpty);

  String? get signedEntitlementToken => hasRenderEntitlement ? _signedEntitlementToken : null;

  // Pro Feature Gate Entitlements
  bool get shouldWatermark => !hasRenderEntitlement;
  // 360p is the free standard for everyone; credits only buy upscales.
  String get defaultQuality => hasRenderEntitlement ? '1080p' : '360p';
  String get renderType => hasRenderEntitlement ? 'priority_queue' : 'free_queue';
  bool get canBuyTopUps => isPro;

  /// Whether a product ID belongs to a consumable credit top-up.
  bool isTopUpProductId(String id) {
    return id == idTopUp10 || id == legacyIdTopUp10 || id == idTopUp50 || id == legacyIdTopUp50;
  }

  /// Registers the StoreKit / Play Billing transaction listener.
  ///
  /// MUST be callable independently of store availability. Apple review 1.0 (34)
  /// failed (Guideline 2.1(a), "subscribe button was unresponsive") because this
  /// was nested inside `if (_isStoreAvailable)`: on a fresh install where
  /// `isAvailable()` returned false, the listener was never registered and never
  /// recovered, so `_isPurchasing` latched true and the CTA stayed disabled.
  void _ensurePurchaseListener() {
    if (_subscription != null) return;
    try {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onDone: () {
          _subscription?.cancel();
          _subscription = null;
        },
        onError: (error) {
          debugPrint('[SubscriptionManager] Purchase stream error: $error');
          _cancelPurchaseWatchdog();
          _isPurchasing = false;
          _statusMessage = 'Store connection interrupted. Please try again.';
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('[SubscriptionManager] Failed to attach purchase stream: $e');
    }
  }

  /// Arms a watchdog so the CTA can never stay spinning forever if StoreKit
  /// delivers no terminal event for an initiated purchase.
  void _armPurchaseWatchdog() {
    _cancelPurchaseWatchdog();
    _purchaseWatchdog = Timer(purchaseWatchdogTimeout, () {
      if (!_isPurchasing) return;
      debugPrint('[SubscriptionManager] Purchase watchdog fired; releasing UI lock.');
      _isPurchasing = false;
      _statusMessage =
          'The store did not respond. No charge was made. Please try again.';
      notifyListeners();
    });
  }

  void _cancelPurchaseWatchdog() {
    _purchaseWatchdog?.cancel();
    _purchaseWatchdog = null;
  }

  /// Initializes IAP listeners, restores securely cached entitlement, and queries store products.
  Future<void> init() async {
    // First statement, before any await: the listener is the only path by which
    // a purchase result can arrive, and StoreKit may replay queued transactions
    // immediately. Never gate it on isAvailable(), never defer it behind an await.
    _ensurePurchaseListener();

    try {
      await _loadCachedEntitlements();
    } catch (e) {
      debugPrint('[SubscriptionManager] Cached entitlement load failed: $e');
    }

    try {
      _isStoreAvailable = await _iap.isAvailable();
    } catch (e) {
      debugPrint('[SubscriptionManager] isAvailable() threw: $e');
      _isStoreAvailable = false;
    }

    if (_isStoreAvailable) {
      await loadProducts();
    } else {
      debugPrint('[SubscriptionManager] In-App Purchase service unavailable at launch; will retry on demand.');
    }
    notifyListeners();
  }

  /// Clears the purchase *UI* lock only. Never touches entitlement state.
  ///
  /// Called when the paywall is (re)opened: if the paywall is being presented,
  /// no StoreKit sheet is on screen, so a lingering `_isPurchasing` is stale and
  /// would render the subscribe button permanently untappable. Any real
  /// transaction still resolves through [_onPurchaseUpdates] regardless.
  void resetPurchaseUiLock() {
    _cancelPurchaseWatchdog();
    if (!_isPurchasing) return;
    debugPrint('[SubscriptionManager] Clearing stale purchase UI lock.');
    _isPurchasing = false;
    notifyListeners();
  }

  /// Clears the transient status line so a stale error does not persist.
  void clearStatusMessage() {
    if (_statusMessage == null) return;
    _statusMessage = null;
    notifyListeners();
  }

  /// Queries App Store / Google Play for the Pro subscriptions and top-up products.
  Future<void> loadProducts() async {
    try {
      _isLoadingProducts = true;
      notifyListeners();

      if (!_isStoreAvailable) {
        _isStoreAvailable = await _iap.isAvailable();
      }
      if (!_isStoreAvailable) {
        _isLoadingProducts = false;
        notifyListeners();
        return;
      }

      final response = await _iap.queryProductDetails(activeProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[SubscriptionManager] Products not found in store: ${response.notFoundIDs}');
      }

      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
    } catch (e) {
      debugPrint('[SubscriptionManager] Failed to load store products: $e');
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Initiates purchase of the chosen subscription tier.
  Future<bool> buySubscription(ProductDetails product) async {
    // The listener must exist before buyNonConsumable is called, otherwise the
    // result of the purchase has nowhere to land.
    _ensurePurchaseListener();

    if (!_isStoreAvailable) {
      try {
        _isStoreAvailable = await _iap.isAvailable();
      } catch (_) {
        _isStoreAvailable = false;
      }
      if (!_isStoreAvailable) {
        _statusMessage = 'Store is currently unavailable. Please verify network and App Store connection.';
        notifyListeners();
        return false;
      }
    }

    _isPurchasing = true;
    _statusMessage = 'Contacting ${Platform.isIOS ? "App Store" : "Google Play"}...';
    _armPurchaseWatchdog();
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      // Auto-renewable subscriptions use non-consumable flow
      final started = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!started) {
        // StoreKit refused to even present the sheet: release the UI now rather
        // than waiting for the watchdog.
        _cancelPurchaseWatchdog();
        _isPurchasing = false;
        _statusMessage = 'The store declined to start the purchase. Please try again.';
        notifyListeners();
      }
      return started;
    } catch (e) {
      debugPrint('[SubscriptionManager] buySubscription error: $e');
      _cancelPurchaseWatchdog();
      _isPurchasing = false;
      _statusMessage = 'Purchase failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Initiates purchase of a consumable credit top-up pack.
  Future<bool> buyTopUp(ProductDetails product) async {
    _ensurePurchaseListener();

    if (!_isStoreAvailable) {
      try {
        _isStoreAvailable = await _iap.isAvailable();
      } catch (_) {
        _isStoreAvailable = false;
      }
      if (!_isStoreAvailable) {
        _statusMessage = 'Store is currently unavailable. Please verify network and App Store connection.';
        notifyListeners();
        return false;
      }
    }

    _isPurchasing = true;
    _statusMessage = 'Contacting ${Platform.isIOS ? "App Store" : "Google Play"}...';
    _armPurchaseWatchdog();
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      final started = await _iap.buyConsumable(purchaseParam: purchaseParam);
      if (!started) {
        _cancelPurchaseWatchdog();
        _isPurchasing = false;
        _statusMessage = 'The store declined to start the purchase. Please try again.';
        notifyListeners();
      }
      return started;
    } catch (e) {
      debugPrint('[SubscriptionManager] buyTopUp error: $e');
      _cancelPurchaseWatchdog();
      _isPurchasing = false;
      _statusMessage = 'Top-up purchase failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Restores previous purchases across devices or after reinstallation.
  Future<bool> restorePurchases() async {
    // Restored transactions arrive on the same stream; without the listener the
    // restore silently does nothing.
    _ensurePurchaseListener();

    if (!_isStoreAvailable) {
      try {
        _isStoreAvailable = await _iap.isAvailable();
      } catch (_) {
        _isStoreAvailable = false;
      }
      if (!_isStoreAvailable) {
        _statusMessage = 'Store is currently unavailable. Please verify network and App Store connection.';
        notifyListeners();
        return false;
      }
    }

    _isPurchasing = true;
    _statusMessage = 'Restoring previous purchases...';
    _armPurchaseWatchdog();
    notifyListeners();

    try {
      await _iap.restorePurchases();
      _cancelPurchaseWatchdog();
      _isPurchasing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[SubscriptionManager] restorePurchases error: $e');
      _cancelPurchaseWatchdog();
      _isPurchasing = false;
      _statusMessage = 'Failed to restore purchases: $e';
      notifyListeners();
      return false;
    }
  }

  /// Handles incoming purchases from stream.
  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _isPurchasing = true;
          _statusMessage = 'Transaction pending approval...';
          // A pending transaction can outlive the watchdog window (Ask to Buy,
          // SCA), so re-arm rather than leave a stale timer running.
          _armPurchaseWatchdog();
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _isPurchasing = true;
          _statusMessage = 'Verifying receipt with server...';
          notifyListeners();

          final verificationResult = await _verifyWithBackend(purchase);
          final bool isTopUp = isTopUpProductId(purchase.productID);

          if (verificationResult == BackendVerificationResult.valid) {
            _isGraceEntitlement = false;
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_keyIsGrace);
            await prefs.remove(_keyGraceGrantedAt);
            _statusMessage = isTopUp
                ? 'Credits added to your account!'
                : 'Pro Subscription activated!';
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } else if (verificationResult == BackendVerificationResult.transportError) {
            // Network transport error or timeout: allow short 48h grace window
            if (isTopUp) {
              _statusMessage = 'Network error during verification. Will retry when connection is restored.';
            } else {
              final prefs = await SharedPreferences.getInstance();
              final lastGraceMs = prefs.getInt(_keyGraceGrantedAt) ?? 0;
              final nowMs = DateTime.now().millisecondsSinceEpoch;
              final bool isInsideExistingGrace = (lastGraceMs > 0) &&
                  (nowMs - lastGraceMs < const Duration(hours: 48).inMilliseconds);

              if (isInsideExistingGrace) {
                _statusMessage =
                    'Network error during verification. Grace window already active; reconnect to complete verification.';
              } else {
                final tier = _tierFromProductId(purchase.productID) ?? ProTier.monthly;
                final expires = DateTime.now().add(const Duration(hours: 48));
                await prefs.setInt(_keyGraceGrantedAt, nowMs);
                _isGraceEntitlement = true;
                await prefs.setBool(_keyIsGrace, true);
                await _persistEntitlements(
                  isPro: true,
                  tier: tier,
                  expiresAt: expires,
                  originalTxId: purchase.purchaseID ?? 'offline_${DateTime.now().millisecondsSinceEpoch}',
                  signedToken: null,
                );
                _statusMessage = 'Pro Subscription active (verifying with server in background).';
              }
            }

            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } else {
            // Backend explicitly rejected the receipt (is_valid == false)
            _isGraceEntitlement = false;
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_keyIsGrace);
            await prefs.remove(_keyGraceGrantedAt);
            await _persistEntitlements(
              isPro: false,
              tier: null,
              expiresAt: null,
              originalTxId: null,
              signedToken: null,
            );
            _isPro = false;
            _statusMessage = 'Subscription verification failed: receipt was rejected by the server.';
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          }

          _cancelPurchaseWatchdog();
          _isPurchasing = false;
          notifyListeners();
          break;

        case PurchaseStatus.error:
          _cancelPurchaseWatchdog();
          _isPurchasing = false;
          _statusMessage = purchase.error?.message ?? 'Transaction encountered an error.';
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          _cancelPurchaseWatchdog();
          _isPurchasing = false;
          _statusMessage = 'Purchase cancelled.';
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          notifyListeners();
          break;
      }
    }
  }

  @visibleForTesting
  Future<BackendVerificationResult> Function(PurchaseDetails purchase)? verifyWithBackendOverride;

  /// Sends receipt data to backend API to validate cryptographic signature and anti-fraud ledger.
  Future<BackendVerificationResult> _verifyWithBackend(PurchaseDetails purchase) async {
    if (verifyWithBackendOverride != null) {
      return await verifyWithBackendOverride!(purchase);
    }
    try {
      final dio = dioOverride ?? Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final payload = {
        'platform': Platform.isIOS ? 'ios' : 'android',
        'product_id': purchase.productID,
        'transaction_id': purchase.purchaseID ?? '',
        'receipt_data': purchase.verificationData.serverVerificationData,
        'source': purchase.verificationData.source,
      };

      final response = await dio.post(
        '/api/billing/verify-receipt',
        data: payload,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final isValid = data['is_valid'] == true;
        final isProUser = data['is_pro'] == true;

        if (isValid && isProUser) {
          final tierStr = data['tier']?.toString() ?? _tierFromProductId(purchase.productID)?.name;
          final expMs = data['expires_at_ms'] as int?;
          final token = data['entitlement_token']?.toString();

          final tier = _parseTier(tierStr);
          final expires = expMs != null ? DateTime.fromMillisecondsSinceEpoch(expMs) : _calcFallbackExpiry(tier);

          await _persistEntitlements(
            isPro: true,
            tier: tier,
            expiresAt: expires,
            originalTxId: purchase.purchaseID,
            signedToken: token,
          );
          return BackendVerificationResult.valid;
        } else {
          return BackendVerificationResult.invalid;
        }
      }
      return BackendVerificationResult.invalid;
    } on DioException catch (e) {
      debugPrint('[SubscriptionManager] Backend verification DioException: $e');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return BackendVerificationResult.transportError;
      }
      if (e.response != null) {
        return BackendVerificationResult.invalid;
      }
      return BackendVerificationResult.transportError;
    } catch (e) {
      debugPrint('[SubscriptionManager] Backend verification call failed: $e');
      return BackendVerificationResult.transportError;
    }
  }



  DateTime _calcFallbackExpiry(ProTier? tier) {
    final now = DateTime.now();
    switch (tier) {
      case ProTier.daily:
        return now.add(const Duration(days: 1));
      case ProTier.weekly:
        return now.add(const Duration(days: 7));
      case ProTier.monthly:
        return now.add(const Duration(days: 31));
      case ProTier.annual:
      default:
        return now.add(const Duration(days: 366));
    }
  }

  ProTier? _tierFromProductId(String id) {
    if (id == idDaily || id == legacyIdDaily) return ProTier.daily;
    if (id == idWeekly || id == legacyIdWeekly) return ProTier.weekly;
    if (id == idMonthly || id == legacyIdMonthly) return ProTier.monthly;
    if (id == idAnnual || id == legacyIdAnnual) return ProTier.annual;
    return null;
  }

  ProTier? _parseTier(String? tierName) {
    if (tierName == null) return null;
    for (final t in ProTier.values) {
      if (t.name.toLowerCase() == tierName.toLowerCase()) return t;
    }
    return null;
  }

  /// Saves entitlement locally with an SHA-256 integrity hash to prevent tampering.
  Future<void> _persistEntitlements({
    required bool isPro,
    required ProTier? tier,
    required DateTime? expiresAt,
    required String? originalTxId,
    required String? signedToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _isPro = isPro;
    _activeTier = tier;
    _expiresAt = expiresAt;
    _originalTransactionId = originalTxId;
    _signedEntitlementToken = signedToken;

    final expMs = expiresAt?.millisecondsSinceEpoch ?? 0;
    final checksum = _computeChecksum(isPro, tier?.name ?? '', expMs, originalTxId ?? '');

    await prefs.setBool(_keyIsPro, isPro);
    await prefs.setString(_keyTier, tier?.name ?? '');
    await prefs.setInt(_keyExpiresAt, expMs);
    await prefs.setString(_keyOriginalTxId, originalTxId ?? '');
    if (signedToken != null) {
      await prefs.setString(_keyToken, signedToken);
    } else {
      await prefs.remove(_keyToken);
    }
    await prefs.setString(_keyChecksum, checksum);

    notifyListeners();
  }

  /// Restores entitlement from persistent storage and verifies tamper-proof hash.
  
  /// Self-heals when entitlement token is rejected by backend (Task 3b Rule 2).
  Future<bool> selfHealEntitlement() async {
    try {
      debugPrint('[SubscriptionManager] Self-healing rejected entitlement token...');
      await restorePurchases();
      return _signedEntitlementToken != null && _signedEntitlementToken!.isNotEmpty;
    } catch (e) {
      debugPrint('[SubscriptionManager] Self-heal failed: $e');
      return false;
    }
  }

  Future<void> _loadCachedEntitlements() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIsPro = prefs.getBool(_keyIsPro) ?? false;
    final savedTierStr = prefs.getString(_keyTier) ?? '';
    final savedExpMs = prefs.getInt(_keyExpiresAt) ?? 0;
    final savedTxId = prefs.getString(_keyOriginalTxId) ?? '';
    final savedToken = prefs.getString(_keyToken);
    final savedChecksum = prefs.getString(_keyChecksum) ?? '';
    _creditBalance = prefs.getInt(_keyCreditBalance) ?? 10;

    // Verify hash integrity
    final expectedChecksum = _computeChecksum(savedIsPro, savedTierStr, savedExpMs, savedTxId);
    if (savedChecksum != expectedChecksum && savedIsPro) {
      debugPrint('[SubscriptionManager] Tampered preferences detected! Resetting entitlements.');
      _isPro = false;
      _activeTier = null;
      _expiresAt = null;
      notifyListeners();
      return;
    }

    if (savedIsPro && savedExpMs > 0) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(savedExpMs);
      if (DateTime.now().isBefore(expiry)) {
        _isPro = true;
        _activeTier = _parseTier(savedTierStr);
        _expiresAt = expiry;
        _originalTransactionId = savedTxId;
        _signedEntitlementToken = savedToken;
      } else {
        // Expired subscription
        _isPro = false;
        _activeTier = null;
        _expiresAt = null;
      }
    } else {
      _isPro = false;
      _activeTier = null;
    }

    final savedIsGrace = prefs.getBool(_keyIsGrace) ?? false;
    final savedGraceMs = prefs.getInt(_keyGraceGrantedAt) ?? 0;
    if (savedIsGrace) {
      if (DateTime.now().millisecondsSinceEpoch - savedGraceMs > const Duration(hours: 48).inMilliseconds) {
        _isGraceEntitlement = false;
        _isPro = false;
        await prefs.remove(_keyIsGrace);
        await prefs.remove(_keyGraceGrantedAt);
      } else {
        _isGraceEntitlement = true;
      }
    } else {
      _isGraceEntitlement = false;
    }

    notifyListeners();
  }

  String _computeChecksum(bool isPro, String tier, int expMs, String txId) {
    final input = '$isPro:$tier:$expMs:$txId:$_salt';
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Whether the StoreKit / Play Billing transaction listener is attached.
  ///
  /// Exposed so a regression test can assert the listener exists even when the
  /// store reported itself unavailable — the exact condition that made the
  /// subscribe button unresponsive in the build Apple rejected.
  @visibleForTesting
  bool get hasPurchaseListener => _subscription != null;

  /// Forces the UI into the stuck state the rejected build could reach, so the
  /// recovery path can be tested.
  @visibleForTesting
  void simulateStuckPurchaseLock() {
    _isPurchasing = true;
    notifyListeners();
  }

  /// Manual diagnostic reset (used for testing environments).
  @visibleForTesting
  Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsPro);
    await prefs.remove(_keyTier);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keyOriginalTxId);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyChecksum);
    await prefs.remove(_keyIsGrace);
    await prefs.remove(_keyGraceGrantedAt);
    _isPro = false;
    _isGraceEntitlement = false;
    _activeTier = null;
    _expiresAt = null;
    _signedEntitlementToken = null;
    notifyListeners();
  }

  /// Exposes cached entitlement loading to test simulated app relaunch.
  @visibleForTesting
  Future<void> loadCachedEntitlementsForTesting() async {
    await _loadCachedEntitlements();
  }

  /// Sets active Pro status with valid checksum for unit testing.
  @visibleForTesting
  Future<void> setProForTesting({
    ProTier tier = ProTier.monthly,
    Duration duration = const Duration(days: 30),
    String token = 'valid_test_token',
  }) async {
    final expires = DateTime.now().add(duration);
    await _persistEntitlements(
      isPro: true,
      tier: tier,
      expiresAt: expires,
      originalTxId: 'tx_valid_test',
      signedToken: token,
    );
  }

  @override
  void dispose() {
    _cancelPurchaseWatchdog();
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
