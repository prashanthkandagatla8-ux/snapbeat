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

Future<void> capturePng(GlobalKey key, String filename) async {
  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    final file = File(filename);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(byteData.buffer.asUint8List());
    // ignore: avoid_print
    print('SAVED_PAYWALL_SCREENSHOT: $filename');
  }
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

    // Verify key titles and features
    expect(find.text('SnapBeat Pro'), findsOneWidget);
    expect(find.text('Unlock Your Creative Potential'), findsOneWidget);
    expect(find.text('Weekly Pass'), findsOneWidget);
    expect(find.text('Monthly VIP'), findsOneWidget);
    expect(find.text('Annual VIP'), findsOneWidget);
    expect(find.text('Best Value'), findsOneWidget);
    expect(find.text('Save 57%'), findsOneWidget);
    expect(find.text('Subscribe'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Restore Purchase'), findsOneWidget);

    // Verify features
    expect(find.text('Unlimited Exports'), findsOneWidget);
    expect(find.text('No Watermarks'), findsOneWidget);
    expect(find.text('100+ Pro Filters'), findsOneWidget);
    expect(find.text('All Weekly Features'), findsOneWidget);
    expect(find.text('Premium Transitions'), findsOneWidget);
    expect(find.text('Gold Assets & Music'), findsOneWidget);
    expect(find.text('Complete Creative Suite'), findsOneWidget);
    expect(find.text('Priority Support'), findsOneWidget);
    expect(find.text('Cloud Sync'), findsOneWidget);

    // Capture screenshot for visual inspection with Monthly VIP selected
    await capturePng(repaintKey, 'store_assets/screenshots/paywall_screenshot.png');

    // Tap Weekly Pass to verify selection change
    await tester.tap(find.text('Weekly Pass'), warnIfMissed: false);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Tap Monthly VIP back
    await tester.tap(find.text('Monthly VIP'), warnIfMissed: false);
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
}
