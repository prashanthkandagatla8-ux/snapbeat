import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapbeat_flutter/ui/components/retro_subscription_dialog.dart';

Future<void> loadFont(String family, String path) async {
  final file = File(path);
  if (!file.existsSync()) return;
  final bytes = file.readAsBytesSync();
  final fontLoader = FontLoader(family);
  fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
  await fontLoader.load();
}

/// Rasterises [key] to a PNG.
///
/// Must run inside [WidgetTester.runAsync]: `toImage` needs a real event loop,
/// and calling it in the fake-async zone leaves the test framework unable to
/// complete the test.
Future<void> capturePng(WidgetTester tester, GlobalKey key, String filename) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData != null) {
      final file = File(filename);
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(byteData.buffer.asUint8List());
      // ignore: avoid_print
      print('SAVED_PAYWALL_SCREENSHOT: $filename');
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadFont('MaterialIcons', r'C:\src\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf');
    await loadFont('Roboto', r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-regular.ttf');
    await loadFont('Roboto-Bold', r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-bold.ttf');
    await loadFont('Segoe UI', r'C:\Windows\Fonts\segoeui.ttf');
    await loadFont('Segoe UI Bold', r'C:\Windows\Fonts\segoeuib.ttf');
    await loadFont('Montserrat', r'C:\Windows\Fonts\segoeuib.ttf');
  });

  testWidgets('RetroSubscriptionDialog renders and interacts properly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repaintKey = GlobalKey();

    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000),
          fontFamily: 'Segoe UI',
        ),
        home: Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: RepaintBoundary(
            key: repaintKey,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: RetroSubscriptionDialog(),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify key titles
    expect(find.text('STUDIO PRO'), findsOneWidget);
    expect(find.text('Unlock 1080p Master & Zero Watermark'), findsOneWidget);
    expect(find.text('Weekly Pass'), findsOneWidget);
    expect(find.text('Monthly VIP'), findsOneWidget);
    expect(find.text('Annual VIP'), findsOneWidget);
    expect(find.text('Best Value'), findsOneWidget);
    // Annual discount, derived from INR 499*12 -> 2,499 and USD 4.99*12 -> 24.99.
    expect(find.text('SAVE 58%'), findsOneWidget);
    expect(find.text('UPGRADE TO PRO'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Restore Purchase'), findsOneWidget);

    // Every tier advertises the same four entitlements, one row per card.
    for (final feature in const [
      '1080p Master export',
      'No watermark',
      'Priority render queue',
      'Unlimited exports',
    ]) {
      expect(find.text(feature), findsNWidgets(3), reason: 'missing: $feature');
    }

    // Credit top-up packs are intentionally gone: the consumable products do
    // not exist in App Store Connect / Play Console.
    expect(find.text('CREDIT TOP-UP PACKS'), findsNothing);

    // Selecting a tier must retarget the App Store 3.1.2 auto-renewal
    // disclaimer, since that is the text stating what the user is charged.
    String disclaimer() {
      final hit = find.textContaining('at confirmation of purchase');
      expect(hit, findsOneWidget, reason: 'auto-renewal disclaimer missing');
      return tester.widget<Text>(hit.first).data ?? '';
    }

    expect(disclaimer(), contains('/ Month'),
        reason: 'default selection should be Monthly');

    await tester.tap(find.text('Weekly Pass'), warnIfMissed: false);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(disclaimer(), contains('/ Week'),
        reason: 'disclaimer did not follow the Weekly selection');

    // Back to Monthly for the captured screenshot.
    await tester.tap(find.text('Monthly VIP'), warnIfMissed: false);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(disclaimer(), contains('/ Month'));

    // Capture last: rasterising perturbs the TestAsyncUtils guard stack, so any
    // tester interaction after it deadlocks.
    await capturePng(tester, repaintKey, 'store_assets/screenshots/paywall_screenshot.png');
  });
}
