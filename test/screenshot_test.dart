import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapbeat_flutter/models/models.dart';
import 'package:snapbeat_flutter/services/queue_manager.dart';
import 'package:snapbeat_flutter/theme/app_colors.dart';
import 'package:snapbeat_flutter/ui/components/metal_chassis_scaffold.dart';
import 'package:snapbeat_flutter/ui/components/retro_mechanical_button.dart';
import 'package:snapbeat_flutter/ui/components/snaps_reorder_strip.dart';
import 'package:snapbeat_flutter/ui/components/retro_subscription_dialog.dart';
import 'package:snapbeat_flutter/ui/components/sound_library_dialog.dart';
import 'package:snapbeat_flutter/ui/screens/home_screen.dart';

Future<void> loadFont(String family, String path) async {
  final file = File(path);
  if (!file.existsSync()) return;
  final bytes = file.readAsBytesSync();
  final fontLoader = FontLoader(family);
  fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
  await fontLoader.load();
}

Future<void> capturePng(WidgetTester tester, GlobalKey key, String filename) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.625);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final file = File('store_assets/screenshots/$filename');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(byteData.buffer.asUint8List());
      // ignore: avoid_print
      print('SAVED_SCREENSHOT: $filename');
    }
  });
}

ThemeData get testTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.canvasChassis,
  primaryColor: AppColors.brassGold,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.brassGold,
    secondary: AppColors.brassHighlight,
    surface: AppColors.panelCream,
    onPrimary: AppColors.hardwareGunmetal,
    onSecondary: AppColors.hardwareGunmetal,
    onSurface: AppColors.textEngraved,
  ),
  cardColor: AppColors.panelCream,
  dividerColor: AppColors.chassisBevelLight,
  fontFamily: 'Montserrat', fontFamilyFallback: const ['Montserrat', 'Segoe UI', 'Roboto'], 
);

List<PhotoItem> getSamplePhotos() {
  const basePath = r'C:\MyProjects\snapbeat_flutter\assets\sample_photos';
  return List.generate(8, (i) {
    final idx = i + 1;
    return PhotoItem(
      id: 'sample_$idx',
      path: '$basePath\\sample_0$idx.jpg',
      order: idx,
    );
  });
}

final dummyMusicFile = File(r'C:\MyProjects\snapbeat_flutter\assets\audio\funk_smooth_party.mp3');

Future<void> preloadAllAssets(WidgetTester tester) async {
  await tester.runAsync(() async {
    // 1. Retro buttons
    for (final variant in RetroButtonVariant.values) {
      if (RetroMechanicalButton.uiImageCache.containsKey(variant)) continue;
      final file = File('C:\\MyProjects\\snapbeat_flutter\\${variant.assetPath.replaceAll('/', '\\')}');
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        RetroMechanicalButton.uiImageCache[variant] = frame.image;
      }
    }

    // 2. Sample photos
    for (int i = 1; i <= 8; i++) {
      final p = 'C:\\MyProjects\\snapbeat_flutter\\assets\\sample_photos\\sample_0$i.jpg';
      if (SnapsReorderStrip.photoImageCache.containsKey(p)) continue;
      final file = File(p);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        SnapsReorderStrip.photoImageCache[p] = frame.image;
      }
    }

    // 3. Logo
    if (HomeScreen.logoUiImage == null) {
      final file = File(r'C:\MyProjects\snapbeat_flutter\assets\images\snapbeat_app_icon.png');
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        HomeScreen.logoUiImage = frame.image;
      }
    }

    // 4. Background texture
    if (MetalChassisScaffold.backgroundUiImage == null) {
      final file = File(r'C:\MyProjects\snapbeat_flutter\assets\images\brushed_metal_background.jpg');
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        MetalChassisScaffold.backgroundUiImage = frame.image;
      }
    }
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock channels
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channels = [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers/events',
      'xyz.luan/audioplayers.global/events',
      'plugins.flutter.io/google_mobile_ads',
      'plugins.flutter.io/path_provider',
      'plugins.flutter.io/path_provider_macos',
    ];
    for (final ch in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(ch), (call) async {
        if (ch == 'plugins.flutter.io/google_mobile_ads') {
          return null;
        }
        if (ch.contains('path_provider')) {
          return r'C:\MyProjects\snapbeat_flutter\_data';
        }
        return 1;
      });
    }

    // Material icons
    await loadFont('MaterialIcons', r'C:\src\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf');

    // Cupertino icons
    final cupertinoPath = r'C:\Users\prash\AppData\Local\Pub\Cache\hosted\pub.dev\cupertino_icons-1.0.9\assets\CupertinoIcons.ttf';
    await loadFont('CupertinoIcons', cupertinoPath);
    await loadFont('packages/cupertino_icons/CupertinoIcons', cupertinoPath);

    // Typography
    final segoePath = r'C:\Windows\Fonts\segoeui.ttf';
    final segoeBoldPath = r'C:\Windows\Fonts\segoeuib.ttf';
    final courPath = r'C:\Windows\Fonts\cour.ttf';
    final courBoldPath = r'C:\Windows\Fonts\courbd.ttf';
    final robotoPath = r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-regular.ttf';
    final robotoBoldPath = r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-bold.ttf';

    await loadFont('Roboto', robotoPath);
    await loadFont('Roboto-Bold', robotoBoldPath);
    await loadFont('Montserrat', segoeBoldPath);
    for (final variant in [
      'Montserrat_regular',
      'Montserrat_medium',
      'Montserrat_semiBold',
      'Montserrat_bold',
      'Montserrat_extraBold',
      'Montserrat_black',
      'Montserrat_400',
      'Montserrat_500',
      'Montserrat_600',
      'Montserrat_700',
      'Montserrat_800',
      'Montserrat_900',
    ]) {
      await loadFont(variant, segoeBoldPath);
    }
    await loadFont('Inter', segoePath);
    await loadFont('Inter-Regular', segoePath);
    await loadFont('Inter-Bold', segoeBoldPath);
    await loadFont('Inter-Medium', segoePath);
    await loadFont('Inter-SemiBold', segoeBoldPath);
    for (final variant in [
      'Inter_regular',
      'Inter_medium',
      'Inter_semiBold',
      'Inter_bold',
      'Inter_extraBold',
      'Inter_black',
      'Inter_300',
      'Inter_400',
      'Inter_500',
      'Inter_600',
      'Inter_700',
      'Inter_800',
      'Inter_900',
    ]) {
      await loadFont(variant, segoeBoldPath);
    }
    await loadFont('Courier', courPath);
    await loadFont('Courier New', courPath);
    await loadFont('Courier_bold', courBoldPath);
    await loadFont('Segoe UI', segoePath);
    await loadFont('Segoe UI Bold', segoeBoldPath);
    await loadFont('sans-serif', segoePath);
    await loadFont('monospace', r'C:\Windows\Fonts\consolab.ttf');
    await loadFont('Monospace', r'C:\Windows\Fonts\consolab.ttf');
    await loadFont('Ahem', segoeBoldPath);
    await loadFont('packages/flutter_test/Ahem', segoeBoldPath);
    await loadFont('.AppleSystemUIFont', segoeBoldPath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('generate_all_ui_screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await preloadAllAssets(tester);

    final key = GlobalKey();
    // 1. Music Deck
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: key,
          child: HomeScreen(
            initialTab: "music",
            initialMusic: dummyMusicFile,
            initialMusicTitle: "Funk Smooth Party (124 BPM)",
          ),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '01_music_deck.png');

    // 2. Photos Stage
    final homeState = tester.state<HomeScreenState>(find.byType(HomeScreen));
    homeState.setScreenshotState(currentTab: "photos", photos: getSamplePhotos());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '02_photos_stage.png');

    // 3. Title Stage (Dedicated stage with ON/OFF switch & Live Typography Preview)
    homeState.setScreenshotState(currentTab: "title", isTitleCardEnabled: true);
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '03_title_stage.png');

    // 4. Render Manual / Pro Stage (Available when MANUAL mode is toggled)
    homeState.setScreenshotState(currentTab: "render", isManualMode: true, renderMode: "pro");
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '04_render_pro.png');

    // 5. Queue Vault
    final qm = QueueManager.instance;
    await qm.addJob(QueueJobItem(
      id: "rec_job_01",
      templateName: "Kinetic Cine Zoom • Urban Boom Bap",
      status: "READY",
      videoPath: r"C:\MyProjects\snapbeat_flutter\assets\videos\splash_screen.mp4",
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      quality: "1080p (9:16)",
      progress: 1.0,
    ));
    await qm.addJob(QueueJobItem(
      id: "rec_job_02",
      templateName: "Beat Cut • Funk Smooth Party",
      status: "PROCESSING",
      videoPath: null,
      createdAt: DateTime.now().subtract(const Duration(seconds: 40)),
      quality: "1080p (9:16)",
      progress: 0.68,
    ));
    homeState.setScreenshotState(currentTab: "queue");
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '05_queue_vault.png');

    // 6. Subscription Paywall Dialog
    final paywallKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: paywallKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "render",
                initialRenderMode: "pro",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 220,
                child: RetroSubscriptionDialog(),
              ),
            ],
          ),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, paywallKey, '06_subscription_review.png');

    // 7. Sound Library Dialog (High-Contrast Buttons)
    final soundKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: soundKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "music",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 80,
                bottom: 80,
                child: SoundLibraryDialog(
                  currentTrackTitle: "Funk Smooth Party",
                  onSelectTrack: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, soundKey, '07_sound_library_contrast.png');
  });
}
