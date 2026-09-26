import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapbeat_flutter/services/subscription_manager.dart';

class TestPurchaseDetails extends PurchaseDetails {
  TestPurchaseDetails({
    required super.productID,
    required super.purchaseID,
    required super.status,
    required super.transactionDate,
    required super.verificationData,
  }) {
    pendingCompletePurchase = false;
  }
}

void drainHostNoise(WidgetTester tester) {
  for (var i = 0; i < 64; i++) {
    final e = tester.takeException();
    if (e == null) return;
    final text = e.toString();
    final isHostNoise = text.contains('channel-error') ||
        text.contains('MissingPluginException') ||
        text.contains('Unable to establish connection on channel') ||
        text.contains('fonts.gstatic.com');
    expect(isHostNoise, isTrue, reason: 'unexpected exception: $text');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    SubscriptionManager.instance.verifyWithBackendOverride = null;
    SubscriptionManager.instance.dioOverride = null;
  });

  testWidgets('Grace window unlocks UI dismissal but does not grant render entitlements',
      (WidgetTester tester) async {
    final sm = SubscriptionManager.instance;
    sm.init();
    await sm.resetForTesting();
    expect(sm.isPro, isFalse);

    // Mock network transport error (connection failure / timeout)
    sm.verifyWithBackendOverride = (purchase) async => BackendVerificationResult.transportError;

    final purchase = TestPurchaseDetails(
      productID: SubscriptionManager.idMonthly,
      purchaseID: 'tx_offline_test',
      status: PurchaseStatus.purchased,
      transactionDate: '2026-09-26T12:00:00Z',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'dummy_local',
        serverVerificationData: 'dummy_server',
        source: 'test_source',
      ),
    );

    await sm.handlePurchaseUpdateForTesting(purchase);

    // UI access is granted (paywall dismissed)
    expect(sm.isPro, isTrue, reason: 'Transport error unlocks UI during grace period');
    expect(sm.isGraceEntitlement, isTrue, reason: 'isGraceEntitlement must be flagged true');

    // Render entitlements must NOT be granted: no unwatermarked/1080p output and no fake token
    expect(sm.hasRenderEntitlement, isFalse, reason: 'Grace period must NOT grant server render entitlements');
    expect(sm.signedEntitlementToken, isNull, reason: 'Grace period must NOT supply fake signed token to server');
    expect(sm.shouldWatermark, isTrue, reason: 'Grace renders must enforce watermark');
    expect(sm.defaultQuality, equals('360p'), reason: 'Grace renders must clamp to 360p');
    expect(sm.renderType, equals('free_queue'), reason: 'Grace renders must route to free_queue');

    await tester.pump(const Duration(milliseconds: 50));
    drainHostNoise(tester);
  });

  testWidgets('An explicit server rejection survives a simulated relaunch',
      (WidgetTester tester) async {
    final sm = SubscriptionManager.instance;
    sm.init();
    await sm.resetForTesting();

    // First simulate existing Pro state in memory/prefs with valid tamper hash
    await sm.setProForTesting(tier: ProTier.monthly, duration: const Duration(days: 30));
    expect(sm.isPro, isTrue, reason: 'Initial Pro state should be active before test');
    expect(sm.hasRenderEntitlement, isTrue);

    // Mock server explicitly answering is_valid: false (refunded, expired, or fraudulent)
    sm.verifyWithBackendOverride = (purchase) async => BackendVerificationResult.invalid;

    final purchase = TestPurchaseDetails(
      productID: SubscriptionManager.idMonthly,
      purchaseID: 'tx_rejected_test',
      status: PurchaseStatus.purchased,
      transactionDate: '2026-09-26T12:00:00Z',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'dummy_local',
        serverVerificationData: 'dummy_server',
        source: 'test_source',
      ),
    );

    await sm.handlePurchaseUpdateForTesting(purchase);

    expect(sm.isPro, isFalse, reason: 'Explicit server rejection must immediately revoke Pro');
    expect(sm.hasRenderEntitlement, isFalse);
    expect(sm.statusMessage, contains('rejected by the server'));

    // Simulate app relaunch from SharedPreferences
    await sm.loadCachedEntitlementsForTesting();

    expect(sm.isPro, isFalse, reason: 'Relaunch must NOT restore Pro after explicit server rejection');
    expect(sm.hasRenderEntitlement, isFalse);

    await tester.pump(const Duration(milliseconds: 50));
    drainHostNoise(tester);
  });

  testWidgets('A second grace request inside the window is refused',
      (WidgetTester tester) async {
    final sm = SubscriptionManager.instance;
    sm.init();
    await sm.resetForTesting();
    expect(sm.isPro, isFalse);

    // Mock transport error
    sm.verifyWithBackendOverride = (purchase) async => BackendVerificationResult.transportError;

    final purchase1 = TestPurchaseDetails(
      productID: SubscriptionManager.idMonthly,
      purchaseID: 'tx_grace_1',
      status: PurchaseStatus.purchased,
      transactionDate: '2026-09-26T12:00:00Z',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'dummy_local',
        serverVerificationData: 'dummy_server',
        source: 'test_source',
      ),
    );

    // First request: grants grace
    await sm.handlePurchaseUpdateForTesting(purchase1);
    expect(sm.isPro, isTrue);
    expect(sm.isGraceEntitlement, isTrue);
    expect(sm.statusMessage, contains('active'));

    // Second request within the same 48h window (e.g. restorePurchases() with network blocked)
    final purchase2 = TestPurchaseDetails(
      productID: SubscriptionManager.idMonthly,
      purchaseID: 'tx_grace_2',
      status: PurchaseStatus.restored,
      transactionDate: '2026-09-26T12:05:00Z',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'dummy_local',
        serverVerificationData: 'dummy_server',
        source: 'test_source',
      ),
    );

    await sm.handlePurchaseUpdateForTesting(purchase2);

    // Second request is refused another grace window
    expect(sm.statusMessage, contains('already active'));

    await tester.pump(const Duration(milliseconds: 50));
    drainHostNoise(tester);
  });
}
