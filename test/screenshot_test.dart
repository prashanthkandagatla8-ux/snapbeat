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
import 'package:snapbeat_flutter/ui/components/account_plan_dialog.dart';
import 'package:snapbeat_flutter/ui/components/privacy_policy_dialog.dart';
import 'package:snapbeat_flutter/ui/components/video_preview_dialog.dart';
import 'package:snapbeat_flutter/ui/screens/home_screen.dart';
import 'package:snapbeat_flutter/ui/screens/sample_reel_showcase_screen.dart';
import 'package:snapbeat_flutter/ui/screens/splash_screen.dart';

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
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
      try {
        file.writeAsBytesSync(byteData.buffer.asUint8List());
      } catch (_) {
        try {
          final raf = file.openSync(mode: FileMode.writeOnly);
          raf.writeFromSync(byteData.buffer.asUint8List());
          raf.closeSync();
        } catch (_) {}
      }
      // ignore: avoid_print
      print('SAVED_SCREENSHOT: $filename');
    }
  });
}

ThemeData get testTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.ceramicWhite,
  primaryColor: AppColors.textInkBlack,
  colorScheme: const ColorScheme.light(
    primary: AppColors.textInkBlack,
    secondary: AppColors.textInkSecondary,
    surface: AppColors.ceramicWhite,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textInkBlack,
  ),
  cardColor: AppColors.ceramicWhite,
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

    // 3. Logo & Wordmark
    if (HomeScreen.logoUiImage == null) {
      final file = File(r'C:\MyProjects\snapbeat_flutter\assets\images\snapbeat_app_icon.png');
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        HomeScreen.logoUiImage = frame.image;
      }
    }
    if (HomeScreen.wordmarkUiImage == null) {
      final file = File(r'C:\MyProjects\snapbeat_flutter\assets\images\snapbeat_wordmark_black.png');
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        HomeScreen.wordmarkUiImage = frame.image;
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

    // 5. Splash screen image
    if (SplashScreen.splashUiImage == null) {
      final file = File(r'C:\MyProjects\snapbeat_flutter\assets\images\splash_screen_ios.jpg');
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        SplashScreen.splashUiImage = frame.image;
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
    // 1. Unified Home Screen (Photo Reels Studio)
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: key,
          child: HomeScreen(
            initialTab: "home",
            initialMusic: dummyMusicFile,
            initialMusicTitle: "Funk Smooth Party (124 BPM)",
          ),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '01_home_screen.png');

    // 2. Photos Stage
    final homeState = tester.state<HomeScreenState>(find.byType(HomeScreen));
    homeState.setScreenshotState(currentTab: "photos", photos: getSamplePhotos());
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, key, '02_photos_stage.png');

    // 3. Title Stage (Dedicated stage with ON/OFF switch & Live Typography Preview)
    homeState.setScreenshotState(
      currentTab: "title",
      isTitleCardEnabled: true,
      titleAudioTiming: "with_music",
      titleBgSurface: "video_overlay",
    );
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

    // 8. Splash Screen
    final splashKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: splashKey,
          child: const SplashScreen(autoNavigate: false),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, splashKey, '08_splash_screen.png');

    // 9. Sample Reel Showcase Screen
    final showcaseKey = GlobalKey();
    final samplePhotoUi = SnapsReorderStrip.photoImageCache[r'C:\MyProjects\snapbeat_flutter\assets\sample_photos\sample_01.jpg'];
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: showcaseKey,
          child: SampleReelShowcaseScreen(
            autoNavigate: false,
            placeholderPreview: samplePhotoUi != null
                ? RawImage(image: samplePhotoUi, fit: BoxFit.cover)
                : Container(color: Colors.black),
          ),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await capturePng(tester, showcaseKey, '09_showcase_screen.png');

    // 10. Rename Reel Dialog
    final renameKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: renameKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "queue",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.65)),
              ),
              Center(
                child: AlertDialog(
                  backgroundColor: AppColors.panelCream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.chassisBevelLight, width: 1.5),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.brassGold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Rename Reel",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.textEngraved,
                        ),
                      ),
                    ],
                  ),
                  content: TextField(
                    controller: TextEditingController(text: "Kinetic Cine Zoom • Urban Boom Bap"),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textEngraved,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter reel title...",
                      filled: true,
                      fillColor: AppColors.panelInset,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.chassisBevelDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.brassGold, width: 2),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text("CANCEL", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1218),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8)),
                    ),
                  ],
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
    await capturePng(tester, renameKey, '10_rename_dialog.png');

    // 11. Delete Reel Dialog
    final deleteKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: deleteKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "queue",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.65)),
              ),
              Center(
                child: AlertDialog(
                  backgroundColor: AppColors.panelCream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.chassisBevelLight, width: 1.5),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.delete_forever_rounded, color: AppColors.vuRed, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Delete Reel?",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.textEngraved,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Are you sure you want to permanently delete \"Kinetic Cine Zoom • Urban Boom Bap\"?\n\nThis video file will be permanently removed from your device storage.",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text("CANCEL", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E212B),
                        side: const BorderSide(color: Color(0xFF00E5FF), width: 1.0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
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
    await capturePng(tester, deleteKey, '11_delete_dialog.png');

    // 12. Clear Completed Queue Dialog
    final clearKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: clearKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "queue",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.65)),
              ),
              Center(
                child: AlertDialog(
                  backgroundColor: AppColors.panelCream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.chassisBevelDark, width: 1.5),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.delete_sweep_rounded, color: Color(0xFF00E5FF), size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Clear Completed?",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.textEngraved,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Remove completed and finished reels from queue history? Your active render in progress will continue safely.",
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text("CANCEL", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E212B),
                        side: const BorderSide(color: Color(0xFF00E5FF), width: 1.0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text("CLEAR", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
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
    await capturePng(tester, clearKey, '12_clear_queue_dialog.png');

    // 13. Video Preview Dialog
    final previewKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: previewKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "queue",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(color: Colors.black87),
              ),
              const Center(
                child: VideoPreviewDialog(
                  videoPath: r"C:\MyProjects\snapbeat_flutter\assets\videos\splash_screen.mp4",
                  templateName: "Kinetic Cine Zoom",
                  customName: "Urban Boom Bap Reel",
                  quality: "1080P MASTER",
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
    await capturePng(tester, previewKey, '13_video_preview_dialog.png');

    // 14. Account Plan & Subscription Info Sheet
    final accountKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: accountKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "home",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.75)),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 140,
                child: Material(
                  color: Colors.transparent,
                  child: DefaultTextStyle(
                    style: TextStyle(fontFamily: 'Montserrat', decoration: TextDecoration.none),
                    child: AccountPlanDialog(),
                  ),
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
    await capturePng(tester, accountKey, '14_account_info_dialog.png');

    // 15. Security & Privacy Policy Info Dialog
    final privacyKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: privacyKey,
          child: Stack(
            children: [
              HomeScreen(
                initialTab: "home",
                initialMusic: dummyMusicFile,
                initialMusicTitle: "Funk Smooth Party (124 BPM)",
                initialPhotos: getSamplePhotos(),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.75)),
              ),
              const Center(
                child: Material(
                  color: Colors.transparent,
                  child: PrivacyPolicyDialog(),
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
    await capturePng(tester, privacyKey, '15_security_privacy_dialog.png');
  });
}

