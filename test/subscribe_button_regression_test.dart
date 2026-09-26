// Regression tests for App Store rejection of 1.0 (34):
// Guideline 2.1(a) — "The subscribe button was unresponsive."
//
// Root cause: the StoreKit purchase-stream listener was registered inside
// `if (_isStoreAvailable)` in SubscriptionManager.init(). On a device where
// `InAppPurchase.isAvailable()` returned false at launch, the listener was never
// attached and never recovered, so `_isPurchasing` latched true after the first
// buy attempt and the paywall CTA (disabled while `isPurchasing`) stayed dead.
//
// The fix is that the listener is attached synchronously, as the first statement
// of init(), before any await and with no availability check. These tests pin
// that, plus the recovery paths that keep the CTA reachable.
//
// Note on the host: the flutter test host has no in_app_purchase platform
// implementation, and the plugin's `isAvailable()` future never completes there
// (it errors on its internal channel instead of resolving). So these tests
// deliberately never await init(); awaiting it would deadlock the suite. That is
// a property of the plugin under test hosts, not of the code under test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapbeat_flutter/services/subscription_manager.dart';
import 'package:snapbeat_flutter/ui/components/retro_subscription_dialog.dart';

/// Absorbs the in_app_purchase / google_fonts errors the test host produces.
/// Fails if anything other than known host noise shows up.
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

  testWidgets('init() attaches the purchase listener synchronously, before any availability check',
      (WidgetTester tester) async {
    final sm = SubscriptionManager.instance;

    // Not awaited on purpose (see header). The assertion below is the point:
    // the listener must exist the instant init() is entered, so it cannot be
    // skipped by an unavailable store or lost to an await that never returns.
    sm.init();

    expect(sm.hasPurchaseListener, isTrue,
        reason: 'purchase listener must be attached synchronously and '
            'unconditionally; if it is gated on store availability the '
            'subscribe button can latch into a dead state');
    expect(sm.isPurchasing, isFalse,
        reason: 'init() must not leave the paywall CTA locked');

    await tester.pump(const Duration(milliseconds: 50));
    expect(sm.hasPurchaseListener, isTrue);

    drainHostNoise(tester);
  });

  testWidgets('a stuck purchase lock is released on demand', (WidgetTester tester) async {
    final sm = SubscriptionManager.instance;
    sm.init();

    sm.simulateStuckPurchaseLock();
    expect(sm.isPurchasing, isTrue);

    // Presenting the paywall means no StoreKit sheet is on screen, so the lock
    // is stale by definition.
    sm.resetPurchaseUiLock();
    expect(sm.isPurchasing, isFalse);

    drainHostNoise(tester);
  });

  test('only products that exist in the stores are queried', () {
    expect(
      SubscriptionManager.activeProductIds,
      {
        SubscriptionManager.idWeekly,
        SubscriptionManager.idMonthly,
        SubscriptionManager.idAnnual,
        SubscriptionManager.legacyIdWeekly,
        SubscriptionManager.legacyIdMonthly,
        SubscriptionManager.legacyIdAnnual,
      },
      reason: 'the consumable credit top-ups were never created in App Store '
          'Connect / Play Console; querying them produced dead UI',
    );

    // Guard the specific IDs that must not come back.
    for (final absent in [
      SubscriptionManager.idTopUp10,
      SubscriptionManager.idTopUp50,
      SubscriptionManager.legacyIdTopUp10,
      SubscriptionManager.legacyIdTopUp50,
      SubscriptionManager.idDaily,
      SubscriptionManager.legacyIdDaily,
    ]) {
      expect(SubscriptionManager.activeProductIds.contains(absent), isFalse,
          reason: '$absent is not a live store product');
    }
  });

  testWidgets('paywall CTA is tappable and no top-up section renders when the store is down',
      (WidgetTester tester) async {
    final sm = SubscriptionManager.instance;
    sm.init();
    // Reproduce the rejected state: store never became available and a previous
    // attempt left the purchase lock set.
    expect(sm.isStoreAvailable, isFalse);
    sm.simulateStuckPurchaseLock();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RetroSubscriptionDialog(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // The CTA label must be on screen rather than replaced by a spinner.
    final cta = find.text('UPGRADE TO PRO');
    expect(cta, findsOneWidget,
        reason: 'CTA renders its spinner instead of its label, i.e. it is '
            'disabled — this is what the reviewer saw');

    // And the gesture handler behind it must be wired.
    final detector = tester.widget<GestureDetector>(
      find.ancestor(of: cta, matching: find.byType(GestureDetector)).first,
    );
    expect(detector.onTap, isNotNull,
        reason: 'subscribe button has no tap handler');

    // The removed top-up UI must not come back while the products do not exist.
    expect(find.text('CREDIT TOP-UP PACKS'), findsNothing);
    expect(find.text('10 CREDITS'), findsNothing);
    expect(find.text('50 CREDITS'), findsNothing);

    drainHostNoise(tester);
  });
}
