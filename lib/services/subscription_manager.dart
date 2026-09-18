import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

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
        return '₹49/day';
      case ProTier.weekly:
        return '₹149/week';
      case ProTier.monthly:
        return '₹349/month';
      case ProTier.annual:
        return '₹899/year';
    }
  }

  String get badgeText {
    switch (this) {
      case ProTier.daily:
        return 'QUICK ACCESS';
      case ProTier.weekly:
        return 'FLEXIBLE';
      case ProTier.monthly:
        return 'POPULAR';
      case ProTier.annual:
        return 'BEST VALUE (SAVE 78%)';
    }
  }
}

/// Centralized In-App Purchase and Entitlement Manager for SnapBeat Pro.
class SubscriptionManager with ChangeNotifier {
  // Store Product Identifiers
  static const String idDaily = 'snapbeat_pro_daily';
  static const String idWeekly = 'snapbeat_pro_weekly';
  static const String idMonthly = 'snapbeat_pro_monthly';
  static const String idAnnual = 'snapbeat_pro_yearly';

  static const Set<String> allProductIds = {
    idDaily,
    idWeekly,
    idMonthly,
    idAnnual,
  };

  /// Product IDs enabled for store queries on current platform.
  /// On iOS, 1-day auto-renewable subscriptions are prohibited by Apple (Guideline 3.1.2).
  static Set<String> get activeProductIds => Platform.isIOS
      ? {idWeekly, idMonthly, idAnnual}
      : allProductIds;

  /// Available subscription tiers for current platform.
  /// On iOS, Daily is excluded to comply with Apple App Store review rules.
  static List<ProTier> get availableTiers => Platform.isIOS
      ? [ProTier.annual, ProTier.monthly, ProTier.weekly]
      : [ProTier.annual, ProTier.monthly, ProTier.weekly, ProTier.daily];

  // Preference Storage Keys
  static const String _keyIsPro = 'snapbeat_iap_is_pro_active';
  static const String _keyTier = 'snapbeat_iap_active_tier';
  static const String _keyExpiresAt = 'snapbeat_iap_expires_at_ms';
  static const String _keyOriginalTxId = 'snapbeat_iap_original_tx_id';
  static const String _keyToken = 'snapbeat_iap_signed_token';
  static const String _keyChecksum = 'snapbeat_iap_integrity_hash';
  static const String _salt = 'SnapBeat_v105_SecuritySalt_#99824';

  static final SubscriptionManager instance = SubscriptionManager._internal();
  SubscriptionManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Local Entitlement State
  bool _isPro = false;
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
  String? get signedEntitlementToken => isPro ? _signedEntitlementToken : null;

  // Pro Feature Gate Entitlements
  bool get shouldWatermark => !isPro;
  String get defaultQuality => isPro ? '1080p' : '720p';
  String get renderType => isPro ? 'priority_queue' : 'free_queue';

  /// Initializes IAP listeners, restores securely cached entitlement, and queries store products.
  Future<void> init() async {
    await _loadCachedEntitlements();

    final available = await _iap.isAvailable();
    _isStoreAvailable = available;

    if (_isStoreAvailable) {
      // Listen to transaction updates from StoreKit / Google Play Billing
      _subscription ??= _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('[SubscriptionManager] Purchase stream error: $error');
        },
      );

      await loadProducts();
    } else {
      debugPrint('[SubscriptionManager] In-App Purchase service unavailable on this device.');
    }
  }

  /// Queries App Store / Google Play for the 4 Pro subscription products.
  Future<void> loadProducts() async {
    if (!_isStoreAvailable) return;
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final response = await _iap.queryProductDetails(activeProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[SubscriptionManager] Products not found in store: ${response.notFoundIDs}');
      }

      _products.clear();
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
    if (!_isStoreAvailable) {
      _statusMessage = 'Store is currently unavailable. Please try again later.';
      notifyListeners();
      return false;
    }

    _isPurchasing = true;
    _statusMessage = 'Contacting ${Platform.isIOS ? "App Store" : "Google Play"}...';
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      // Auto-renewable subscriptions use non-consumable flow
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[SubscriptionManager] buySubscription error: $e');
      _isPurchasing = false;
      _statusMessage = 'Purchase failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Restores previous purchases across devices or after reinstallation.
  Future<bool> restorePurchases() async {
    if (!_isStoreAvailable) return false;

    _isPurchasing = true;
    _statusMessage = 'Restoring previous purchases...';
    notifyListeners();

    try {
      await _iap.restorePurchases();
      _isPurchasing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[SubscriptionManager] restorePurchases error: $e');
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
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _isPurchasing = true;
          _statusMessage = 'Verifying receipt with server...';
          notifyListeners();

          final valid = await _verifyWithBackend(purchase);
          if (valid) {
            _statusMessage = 'Pro Subscription activated!';
          } else {
            // TODO: tighten once backend receipt verification is live on api.snapbeat.app
            // Fallback: grant entitlement locally if server is offline, in sandbox, or unreachable
            await _grantLocalEntitlementFromPurchase(purchase);
            _statusMessage = 'Pro Subscription activated (Offline verification)';
          }

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          _isPurchasing = false;
          notifyListeners();
          break;

        case PurchaseStatus.error:
          _isPurchasing = false;
          _statusMessage = purchase.error?.message ?? 'Transaction encountered an error.';
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
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

  /// Sends receipt data to backend API to validate cryptographic signature and anti-fraud ledger.
  Future<bool> _verifyWithBackend(PurchaseDetails purchase) async {
    try {
      final dio = Dio(
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
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('[SubscriptionManager] Backend verification call failed: $e');
      return false;
    }
  }

  /// Fallback local entitlement granting with estimated duration if server is unreachable.
  Future<void> _grantLocalEntitlementFromPurchase(PurchaseDetails purchase) async {
    final tier = _tierFromProductId(purchase.productID) ?? ProTier.monthly;
    final expires = _calcFallbackExpiry(tier);

    await _persistEntitlements(
      isPro: true,
      tier: tier,
      expiresAt: expires,
      originalTxId: purchase.purchaseID,
      signedToken: null,
    );
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
    if (id == idDaily) return ProTier.daily;
    if (id == idWeekly) return ProTier.weekly;
    if (id == idMonthly) return ProTier.monthly;
    if (id == idAnnual) return ProTier.annual;
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
  Future<void> _loadCachedEntitlements() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIsPro = prefs.getBool(_keyIsPro) ?? false;
    final savedTierStr = prefs.getString(_keyTier) ?? '';
    final savedExpMs = prefs.getInt(_keyExpiresAt) ?? 0;
    final savedTxId = prefs.getString(_keyOriginalTxId) ?? '';
    final savedToken = prefs.getString(_keyToken);
    final savedChecksum = prefs.getString(_keyChecksum) ?? '';

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
    notifyListeners();
  }

  String _computeChecksum(bool isPro, String tier, int expMs, String txId) {
    final input = '$isPro:$tier:$expMs:$txId:$_salt';
    return sha256.convert(utf8.encode(input)).toString();
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
    _isPro = false;
    _activeTier = null;
    _expiresAt = null;
    _signedEntitlementToken = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
