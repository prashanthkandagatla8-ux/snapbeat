import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/models.dart';
import '../../models/sound_track.dart';
import '../../services/credit_manager.dart';
import '../../services/queue_manager.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../components/retro_tape_deck.dart';
import '../components/interactive_waveform.dart';
import '../components/snaps_reorder_strip.dart';
import '../components/pro_controls_card.dart';
import '../components/master_action_deck.dart';
import '../components/store_dialog.dart';
import '../components/video_preview_dialog.dart';
import '../components/sound_library_dialog.dart';
import '../components/privacy_policy_dialog.dart';
import '../components/tactile_3d_button.dart';
import '../components/metal_chassis_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cm = CreditManager.instance;
  final qm = QueueManager.instance;
  final api = ApiService.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _currentMode = "auto"; // "auto", "pro", "vault"
  File? _selectedMusic;
  String _selectedMusicTitle = "Funk Smooth Party (124 BPM)";
  final List<PhotoItem> _photos = [];
  String _selectedTemplate = "beat-cut";
  String _selectedAspectRatio = "9:16";
  String _selectedQuality = "1080p";
  String _arrangementMode = "sequential";

  // Audio Trim
  double _audioDuration = 30.0;
  double _audioStart = 0.0;
  double _audioEnd = 15.0;
  bool _isPlayingAudio = false;

  // Title Intro
  bool _enableTitle = false;
  String _titleText = "";
  String _titleBg = "black";
  int _titleDuration = 2;

  // Rendering
  bool _isRendering = false;
  double _renderProgress = 0.0;

  // Auto Mode Template Rotation
  BeatTemplate _currentAutoTemplate = BeatTemplate.allTemplates.first;
  String? _lastAutoTemplateId;

  void _rollAutoTemplate() {
    final pool = BeatTemplate.allTemplates.where((t) => t.id != _lastAutoTemplateId).toList();
    final picked = pool.isNotEmpty
        ? (List<BeatTemplate>.from(pool)..shuffle()).first
        : BeatTemplate.allTemplates.first;
    setState(() {
      _lastAutoTemplateId = picked.id;
      _currentAutoTemplate = picked;
    });
  }

  @override
  void initState() {
    super.initState();
    _rollAutoTemplate();
    _initData();
  }

  Future<void> _initData() async {
    await cm.init();
    await qm.init();
    await _ensureDefaultSampleAudio();
    if (mounted) setState(() {});
  }

  Future<File> _ensureDefaultSampleAudio() async {
    try {
      final track = SoundTrack.builtInLibrary.first;
      final file = await track.getCachedFile();
      _selectedMusic = file;
      _selectedMusicTitle = '${track.title} (${track.bpm})';
      _audioDuration = track.durationSeconds;
      return file;
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sample_beat.mp3');
      if (!await file.exists()) {
        try {
          final byteData = await rootBundle.load('assets/audio/sample_beat.mp3');
          await file.writeAsBytes(
            byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          );
        } catch (_) {}
      }
      _selectedMusic = file;
      return file;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    if (result.isNotEmpty && result.first.path != null) {
      _selectedMusic = File(result.first.path!);
      _selectedMusicTitle = result.first.name;
      _audioDuration = 60.0;
      _audioStart = 0.0;
      _audioEnd = 15.0;
      setState(() {});
    }
  }

  void _openSoundLibrary() async {
    await _audioPlayer.pause();
    if (!mounted) return;
    setState(() => _isPlayingAudio = false);
    SoundLibraryDialog.show(
      context: context,
      currentTrackTitle: _selectedMusicTitle,
      onSelectTrack: (track) async {
        final file = await track.getCachedFile();
        setState(() {
          _selectedMusic = file;
          _selectedMusicTitle = '${track.title} (${track.bpm})';
          _audioDuration = track.durationSeconds;
          _audioStart = 0.0;
          _audioEnd = math.min(15.0, track.durationSeconds);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🎵 Selected: ${track.title}", style: const TextStyle(color: AppColors.textEngraved)),
              backgroundColor: AppColors.panelCream,
            ),
          );
        }
      },
    );
  }

  Future<File> _generateTestSlide(int index, String title, int hexColor) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/sample_slide_$index.png');
    if (!await file.exists()) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 720, 1280));
      final bgPaint = Paint()..color = Color(hexColor);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 720, 1280), bgPaint);

      final borderPaint = Paint()
        ..color = const Color(0xFFFAF6EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24;
      canvas.drawRect(const Rect.fromLTWH(20, 20, 680, 1240), borderPaint);

      final innerBorder = Paint()
        ..color = const Color(0xFFC8A232)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawRect(const Rect.fromLTWH(36, 36, 648, 1208), innerBorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'SNAPBEAT\n\n$title\n\n#$index',
          style: const TextStyle(
            color: Color(0xFFFAF6EE),
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 600);
      textPainter.paint(canvas, const Offset(60, 520));

      final picture = recorder.endRecording();
      final img = await picture.toImage(720, 1280);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      await file.writeAsBytes(byteData!.buffer.asUint8List());
    }
    return file;
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      for (final xfile in pickedList) {
        if (_photos.length < 60) {
          _photos.add(PhotoItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            path: xfile.path,
            order: _photos.length,
          ));
        }
      }
      setState(() {});
    }
  }

  Future<void> _loadSamplePhotos() async {
    final sampleAssets = [
      'assets/sample_photos/sample_01.jpg',
      'assets/sample_photos/sample_02.jpg',
      'assets/sample_photos/sample_03.jpg',
      'assets/sample_photos/sample_04.jpg',
      'assets/sample_photos/sample_05.jpg',
      'assets/sample_photos/sample_06.jpg',
      'assets/sample_photos/sample_07.jpg',
      'assets/sample_photos/sample_08.jpg',
    ];

    try {
      final tempDir = await getTemporaryDirectory();
      final List<PhotoItem> loadedPhotos = [];

      for (int i = 0; i < sampleAssets.length; i++) {
        final assetPath = sampleAssets[i];
        final targetFile = File('${tempDir.path}/snapbeat_sample_${i + 1}.jpg');
        if (!await targetFile.exists()) {
          final byteData = await rootBundle.load(assetPath);
          await targetFile.writeAsBytes(byteData.buffer.asUint8List());
        }
        loadedPhotos.add(PhotoItem(
          id: '${DateTime.now().microsecondsSinceEpoch}_$i',
          path: targetFile.path,
          order: i,
        ));
      }

      _photos.clear();
      _photos.addAll(loadedPhotos);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✨ Added ${_photos.length} AI sample photos!", style: const TextStyle(color: AppColors.textEngraved)),
            backgroundColor: AppColors.panelCream,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading sample photos: $e');
      final slides = [
        await _generateTestSlide(1, 'GOLDEN SUNSET', 0xFFE65100),
        await _generateTestSlide(2, 'NEON BEAT', 0xFF880E4F),
        await _generateTestSlide(3, 'PACIFIC DUSK', 0xFF0D47A1),
      ];

      _photos.clear();
      for (final file in slides) {
        _photos.add(PhotoItem(
          id: '${DateTime.now().microsecondsSinceEpoch}_${file.path.hashCode}',
          path: file.path,
          order: _photos.length,
        ));
      }
      setState(() {});
    }
  }

  void _togglePlayAudio() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      if (_selectedMusic != null && _selectedMusic!.existsSync()) {
        await _audioPlayer.play(DeviceFileSource(_selectedMusic!.path));
      }
      setState(() => _isPlayingAudio = true);
    }
  }

  void _triggerMasterReel() async {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Add some photos first!", style: TextStyle(color: AppColors.textEngraved)),
          backgroundColor: AppColors.panelCream,
        ),
      );
      return;
    }

    if (_currentMode == "pro" && !cm.isProModeEnabled) {
      _showProPaywall();
      return;
    }

    _showRenderChoiceDialog();
  }

  void _showProPaywall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.brassGold, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, color: AppColors.brassGold),
            SizedBox(width: 8),
            Text("Unlock Pro", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textEngraved)),
          ],
        ),
        content: const Text(
          "Access all 14 styles, 1080p 60fps export, all aspect ratios, and no watermarks.",
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CLOSE", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brassGold,
              foregroundColor: AppColors.hardwareGunmetal,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              StoreBottomSheet.show(context, onPurchaseComplete: () => setState(() {}));
            },
            child: const Text("UNLOCK PRO", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRenderChoiceDialog() {
    final watermarkClean = cm.isWatermarkRemoved;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.panelCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.chassisBevelLight, width: 2)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Render Options",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textEngraved),
            ),
            const SizedBox(height: 12),
            // Instant Fast Server
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brassKnobGradient,
                ),
                child: const Icon(Icons.bolt_rounded, size: 20, color: AppColors.hardwareGunmetal),
              ),
              title: const Text("⚡ Instant Render (1 Credit)", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textEngraved)),
              subtitle: const Text("No watermark · Fast processing", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _executeRender(isInstant: true);
              },
            ),
            const Divider(color: AppColors.chassisBevelDark),
            // Free Queue
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.panelInset,
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
                child: const Icon(Icons.cloud_download_outlined, size: 20, color: AppColors.textSecondary),
              ),
              title: Text(
                watermarkClean ? "Free Render (No Watermark)" : "Free Render",
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textEngraved),
              ),
              subtitle: Text(
                watermarkClean ? "Clean video output" : "Includes SnapBeat watermark",
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _executeRender(isInstant: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeRender({required bool isInstant}) async {
    setState(() {
      _isRendering = true;
      _renderProgress = 0.05;
    });

    try {
      String tId;
      String tDisplayName;
      if (_currentMode == "auto") {
        // Use the currently displayed auto template (which the user may have spun to)
        tId = _currentAutoTemplate.id;
        tDisplayName = _currentAutoTemplate.name;
      } else {
        tId = _selectedTemplate;
        final matching = BeatTemplate.allTemplates.where((t) => t.id == tId).toList();
        tDisplayName = matching.isNotEmpty ? matching.first.name : "Beat Cut";
      }

      final photoFiles = _photos.map((p) => File(p.path)).toList();
      File musicFile = _selectedMusic ?? await _ensureDefaultSampleAudio();
      if (!musicFile.existsSync()) {
        musicFile = await _ensureDefaultSampleAudio();
      }

      final videoPath = await api.renderReel(
        musicFile: musicFile,
        photoFiles: photoFiles,
        templateId: tId,
        aspectRatio: _selectedAspectRatio,
        quality: _selectedQuality,
        watermark: cm.shouldWatermark(isInstant),
        isInstant: isInstant,
        audioStart: _audioStart.toInt(),
        audioEnd: _audioEnd.toInt(),
        titleText: _enableTitle ? _titleText : null,
        titleBg: _titleBg,
        titleDuration: _titleDuration,
        onProgress: (p) => setState(() => _renderProgress = p),
      );

      // Record job
      await qm.addJob(QueueJobItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        templateName: tDisplayName,
        status: "READY",
        videoPath: videoPath,
        createdAt: DateTime.now(),
        quality: _selectedQuality,
      ));

      if (isInstant && cm.credits > 0) {
        await cm.deductCredit();
      }

      if (mounted) {
        setState(() => _isRendering = false);
        _showSuccessDialog(videoPath, templateName: tDisplayName, quality: _selectedQuality);
        // Automatically roll a new template for the NEXT render
        if (_currentMode == "auto") {
          _rollAutoTemplate();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRendering = false);
        _showErrorDialog(
          e.toString(),
          onRetry: () => _executeRender(isInstant: isInstant),
        );
      }
    }
  }

  void _showErrorDialog(String rawError, {VoidCallback? onRetry}) {
    String cleanMsg = rawError.replaceAll("Exception: ", "").trim();
    if (cleanMsg.contains("FileNotFoundError") || cleanMsg.contains("no longer available")) {
      cleanMsg = "The selected template preset is currently unavailable on the master engine. Please choose another preset.";
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.vuRed, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.vuRed, size: 24),
            SizedBox(width: 8),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.0,
                color: AppColors.textEngraved,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cleanMsg,
              style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your photos and settings are still loaded. Try again.",
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("DISMISS", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          if (onRetry != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brassGold,
                foregroundColor: AppColors.hardwareGunmetal,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("RETRY", style: TextStyle(fontWeight: FontWeight.w900)),
              onPressed: () {
                Navigator.pop(ctx);
                onRetry();
              },
            ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String videoPath, {String? templateName, String? quality}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.brassGold, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.vuGreen),
            SizedBox(width: 8),
            Text("Your Reel is Ready! 🎬", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textEngraved)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your beat-synced reel is ready to watch and share.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              "Saved: ${videoPath.split(Platform.pathSeparator).last}",
              style: const TextStyle(fontSize: 10, fontFamily: 'Courier', color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _currentMode = "vault");
            },
            child: const Text("VIEW REELS", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brassGold,
              foregroundColor: AppColors.hardwareGunmetal,
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text("PLAY ▶", style: TextStyle(fontWeight: FontWeight.w900)),
            onPressed: () async {
              Navigator.pop(ctx);
              await _audioPlayer.pause();
              if (!mounted) return;
              setState(() => _isPlayingAudio = false);
              VideoPreviewDialog.show(
                context,
                videoPath: videoPath,
                templateName: templateName,
                quality: quality,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MetalChassisScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Brushed Stainless Steel Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.metalBase.withValues(alpha: 0.9),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF9E988D), width: 1.5),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/snapbeat_logo_crop.png',
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'SNAPBEAT',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: AppColors.textEngraved,
                                  shadows: [
                                    Shadow(color: Color(0x88FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                                  ],
                                ),
                              ),
                              Text(
                                'Your Photos. Your Music. Perfectly Synced.',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.textSecondary,
                                  shadows: [
                                    Shadow(color: Color(0x88FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Right Action Group: Privacy Policy Shield + Credit Passes Badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shield_outlined, color: AppColors.brassGold, size: 20),
                            tooltip: 'Privacy Policy',
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            onPressed: () => PrivacyPolicyDialog.show(context),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => StoreBottomSheet.show(context, onPurchaseComplete: () => setState(() {})),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.panelCream,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderBrass, width: 1),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 2),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Text('⚡', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${cm.credits} PASSES',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textEngraved,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rocker Switch Mode Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildModeRocker('auto', 'AUTO', Icons.auto_awesome_rounded),
                      const SizedBox(width: 8),
                      _buildModeRocker('pro', 'PRO', Icons.tune_rounded),
                      const SizedBox(width: 8),
                      _buildModeRocker('vault', 'MY REELS', Icons.movie_filter_rounded),
                    ],
                  ),
                ),

                // Main Scrollable Console Deck
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      if (_currentMode != "vault") ...[
                        _buildMascotHeroCard(),
                        if (_currentMode == "auto") _buildAutoTemplateBanner(),

                        // 1. Reel-to-Reel Tape Deck
                        RetroTapeDeck(
                          isPlaying: _isPlayingAudio,
                          trackTitle: _selectedMusicTitle,
                          currentSeconds: _audioStart,
                          totalSeconds: _audioDuration,
                          onTogglePlay: _togglePlayAudio,
                          onPickAudio: _pickMusic,
                          onLoadSample: _openSoundLibrary,
                        ),

                        // 2. Interactive Audio Waveform Trimmer
                        InteractiveWaveform(
                          durationSeconds: _audioDuration,
                          startSeconds: _audioStart,
                          endSeconds: _audioEnd,
                          isPlaying: _isPlayingAudio,
                          onTogglePlay: _togglePlayAudio,
                          onTrimChanged: (s, e) => setState(() {
                            _audioStart = s;
                            _audioEnd = e;
                          }),
                        ),

                        // 3. 35mm Slide Mounts Curate Strip
                        SnapsReorderStrip(
                          photos: _photos,
                          onAddPhotos: _pickPhotos,
                          onReorder: (oldIdx, newIdx) {
                            setState(() {
                              if (newIdx > oldIdx) newIdx -= 1;
                              final item = _photos.removeAt(oldIdx);
                              _photos.insert(newIdx, item);
                            });
                          },
                          onDelete: (id) => setState(() => _photos.removeWhere((p) => p.id == id)),
                          arrangementMode: _arrangementMode,
                          onArrangementModeChanged: (m) => setState(() => _arrangementMode = m),
                          onLoadSample: _loadSamplePhotos,
                        ),

                        // 4. Pro Controls or Auto Magic Plate
                        if (_currentMode == "pro")
                          ProControlsCard(
                            selectedTemplateId: _selectedTemplate,
                            onSelectTemplate: (t) => setState(() => _selectedTemplate = t),
                            selectedAspectRatio: _selectedAspectRatio,
                            onSelectAspectRatio: (r) => setState(() => _selectedAspectRatio = r),
                            selectedQuality: _selectedQuality,
                            onSelectQuality: (q) => setState(() => _selectedQuality = q),
                            enableTitle: _enableTitle,
                            onToggleTitle: (v) => setState(() => _enableTitle = v),
                            titleText: _titleText,
                            onTitleTextChanged: (t) => setState(() => _titleText = t),
                            titleBg: _titleBg,
                            onSelectTitleBg: (bg) => setState(() => _titleBg = bg),
                            titleDuration: _titleDuration,
                            onTitleDurationChanged: (d) => setState(() => _titleDuration = d),
                          ),
                      ] else ...[
                        // Vault Jobs List
                        _buildVaultView(),
                      ],
                    ],
                  ),
                ),

                // Bottom Action Deck
                if (_currentMode != "vault")
                  MasterActionDeck(
                    photoCount: _photos.length,
                    onTriggerMaster: _triggerMasterReel,
                  ),
              ],
            ),

            // Live Rendering Modal Overlay
            if (_isRendering)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.panelCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.brassGold, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 12),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.brassGold),
                        const SizedBox(height: 18),
                        const Text(
                          "Creating your reel...",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.textEngraved,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Uploading & rendering... ${(_renderProgress * 100).toInt()}%",
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _renderProgress,
                            backgroundColor: AppColors.panelInset,
                            color: AppColors.amberJewel,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeRocker(String mode, String label, IconData icon) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentMode = mode;
            if (mode == "auto") {
              _rollAutoTemplate();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE082),
                      Color(0xFFFFC72C),
                      Color(0xFFD49A00),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFB5AD9E),
                      Color(0xFFA0988A),
                    ],
                  ),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFE8A3) : const Color(0xFFC7BFAF),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF4A463F),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF4A463F),
                  shadows: isSelected
                      ? [
                          const Shadow(
                            color: Color(0x66FFFFFF),
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8D2C5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEBE4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/snapbeat_mascot.png',
            height: 64,
            width: 64,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Turn your moments into cinematic stories',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2B2B2D),
                    shadows: [
                      Shadow(color: Color(0x88FFFFFF), offset: Offset(0, 1), blurRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Tactile3DButton(
                        label: '+ SELECT PHOTOS',
                        height: 36,
                        borderRadius: 18,
                        onTap: _pickPhotos,
                        textStyle: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1A10),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _loadSamplePhotos,
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7BFAF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE8E4DC), width: 1),
                        ),
                        child: const Row(
                          children: [
                            Text('✨', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'DEMO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF3B3830),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoTemplateBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panelCreamDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brassGold, width: 1.4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amberJewel,
              boxShadow: [
                BoxShadow(color: AppColors.amberJewel, blurRadius: 6, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'STYLE: ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _currentAutoTemplate.name.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textEngraved,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_currentAutoTemplate.emoji} ${_currentAutoTemplate.subtitle} (changes each render)',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _rollAutoTemplate,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.panelInset,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.chassisBevelDark),
              ),
              child: const Icon(Icons.casino_outlined, size: 20, color: AppColors.textEngraved),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultView() {
    final jobs = qm.jobs;
    if (jobs.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.panelCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.chassisBevelDark),
        ),
        child: Column(
          children: const [
            Icon(Icons.movie_creation_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              "No reels yet",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppColors.textEngraved,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Your rendered reels will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) {
        final job = jobs[i];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (job.videoPath != null) {
              await _audioPlayer.pause();
              if (!mounted) return;
              setState(() => _isPlayingAudio = false);
              VideoPreviewDialog.show(
                context,
                videoPath: job.videoPath!,
                templateName: job.templateName,
                quality: job.quality,
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.panelCream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.chassisBevelDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.movie_outlined, color: AppColors.brassGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.templateName.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textEngraved),
                      ),
                      Text(
                        "Quality: ${job.quality} • Status: ${job.status}",
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (job.videoPath != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.brassKnobGradient,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.play_arrow_rounded, color: AppColors.hardwareGunmetal, size: 16),
                        SizedBox(width: 2),
                        Text(
                          "PLAY",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.hardwareGunmetal,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}