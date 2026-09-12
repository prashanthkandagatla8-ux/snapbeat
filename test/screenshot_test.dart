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
import 'package:snapbeat_flutter/ui/screens/home_screen.dart';

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
  final image = await boundary.toImage(pixelRatio: 2.625);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    final file = File('store_assets/screenshots/$filename');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(byteData.buffer.asUint8List());
    // ignore: avoid_print
    print('SAVED_SCREENSHOT: $filename');
  }
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
  fontFamily: 'Montserrat',
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
      final file = File(r'C:\MyProjects\snapbeat_flutter\assets\images\snapbeat_logo.png');
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

    // Mock audioplayers channels
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channels = [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers/events',
      'xyz.luan/audioplayers.global/events',
    ];
    for (final ch in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(ch), (call) async => 1);
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
    await loadFont('Courier', courPath);
    await loadFont('Courier New', courPath);
    await loadFont('Courier_bold', courBoldPath);
    await loadFont('Segoe UI', segoePath);
    await loadFont('Segoe UI Bold', segoeBoldPath);
    await loadFont('sans-serif', segoePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('screen_03_render_auto', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await preloadAllAssets(tester);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: key,
          child: HomeScreen(
            initialTab: "render",
            initialRenderMode: "auto",
            initialMusic: dummyMusicFile,
            initialMusicTitle: "Funk Smooth Party (124 BPM)",
            initialPhotos: getSamplePhotos(),
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await capturePng(key, '03_render_auto.png');
    exit(0);
  });

  testWidgets('screen_04_render_pro', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await preloadAllAssets(tester);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: key,
          child: HomeScreen(
            initialTab: "render",
            initialRenderMode: "pro",
            initialMusic: dummyMusicFile,
            initialMusicTitle: "Funk Smooth Party (124 BPM)",
            initialPhotos: getSamplePhotos(),
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await capturePng(key, '04_render_pro.png');
    exit(0);
  });

  testWidgets('screen_05_queue_vault', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await preloadAllAssets(tester);

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

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: key,
          child: const HomeScreen(
            initialTab: "queue",
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await capturePng(key, '05_queue_vault.png');
    exit(0);
  });

  testWidgets('screen_02_photos_stage', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await preloadAllAssets(tester);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: testTheme,
        home: RepaintBoundary(
          key: key,
          child: HomeScreen(
            initialTab: "photos",
            initialMusic: dummyMusicFile,
            initialMusicTitle: "Funk Smooth Party (124 BPM)",
            initialPhotos: getSamplePhotos(),
          ),
        ),
      ),
    );

    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await capturePng(key, '02_photos_stage.png');
    exit(0);
  });
}
