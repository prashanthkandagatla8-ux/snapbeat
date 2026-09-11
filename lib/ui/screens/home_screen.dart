import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../models/models.dart';
import '../../models/sound_track.dart';
import '../../services/credit_manager.dart';
import '../../services/queue_manager.dart';
import '../../services/api_service.dart';
import '../../services/export_service.dart';
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
import '../components/metal_chassis_scaffold.dart';
import '../components/snapbeat_pink_dot.dart';

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
  final ScrollController _scrollController = ScrollController();
  String? _focusedJobId;

  String _currentMode = "auto"; // "auto", "pro", "vault"
  File? _selectedMusic;
  String _selectedMusicTitle = "";
  final List<PhotoItem> _photos = [];
  String _selectedTemplate = "beat-cut";
  String _selectedAspectRatio = "9:16";
  String _selectedQuality = "1080p";
  String _arrangementMode = "sequential";

  /// Calculates max photos dynamically based on track duration and beat tempo.
  int get maxPhotosForTrack {
    if (_selectedMusic == null) return 0;
    final effectiveDuration = (_audioEnd > _audioStart && _audioEnd <= _audioDuration)
        ? (_audioEnd - _audioStart)
        : _audioDuration;

    // Try to parse BPM from title if available (e.g. "124 BPM")
    double beatSec = 0.5; // default 120 BPM (~0.5s per beat)
    final bpmMatch = RegExp(r'(\d+)\s*BPM', caseSensitive: false).firstMatch(_selectedMusicTitle);
    if (bpmMatch != null) {
      final bpmVal = double.tryParse(bpmMatch.group(1) ?? "");
      if (bpmVal != null && bpmVal >= 50 && bpmVal <= 220) {
        beatSec = 60.0 / bpmVal;
      }
    }

    // Minimum display time per photo for clean viewer comprehension is 0.5s or 1 beat
    final minSecPerPhoto = math.max(0.5, beatSec);
    final calculated = (effectiveDuration / minSecPerPhoto).floor();
    return calculated.clamp(4, 50);
  }

  // Audio Trim
  double _audioDuration = 30.0;
  double _audioStart = 0.0;
  double _audioEnd = 15.0;
  bool _isPlayingAudio = false;
  bool _showAudioTrimmerInAuto = false;

  // Title Intro
  bool _enableTitle = false;
  String _titleText = "";
  String _titleBg = "black";
  int _titleDuration = 2;
  String _titleFont = "impact";
  String _titleStyle = "classic";
  String _titleFrame = "none";

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

  void _autoShufflePhotos() {
    if (_photos.isEmpty) return;
    setState(() {
      _photos.shuffle();
      for (int i = 0; i < _photos.length; i++) {
        _photos[i].order = i + 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✨ Auto beat-sequence shuffled!"),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _rollAutoTemplate();
    qm.addListener(_onQueueChanged);
    _initData();
  }

  Future<void> _initData() async {
    await cm.init();
    await qm.init();
    if (mounted) setState(() {});
  }

  Future<void> _loadDefaultSampleTrack() async {
    await _audioPlayer.pause();
    setState(() => _isPlayingAudio = false);
    try {
      final track = SoundTrack.builtInLibrary.first;
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
            content: Text('🎵 Selected: ${track.title} (${track.bpm}) — Photos unlocked!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.panelCream,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading sample track: $e');
    }
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    qm.removeListener(_onQueueChanged);
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

  Future<void> _pickPhotos() async {
    if (_selectedMusic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Step 1: Please select a music track first!"),
          backgroundColor: AppColors.panelCream,
        ),
      );
      return;
    }

    final maxAllowed = maxPhotosForTrack;
    if (_photos.length >= maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maximum $maxAllowed photos already reached for this track duration."),
          backgroundColor: AppColors.panelCream,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      int added = 0;
      for (final xfile in pickedList) {
        if (_photos.length < maxAllowed) {
          _photos.add(PhotoItem(
            id: DateTime.now().microsecondsSinceEpoch.toString() + added.toString(),
            path: xfile.path,
            order: _photos.length,
          ));
          added++;
        }
      }
      setState(() {});
      if (pickedList.length > added && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added $added photos (capped at $maxAllowed for this track length)."),
            backgroundColor: AppColors.panelCream,
          ),
        );
      }
    }
  }

  Future<void> _loadSamplePhotos() async {
    if (_selectedMusic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Step 1: Please select a music track first!"),
          backgroundColor: AppColors.panelCream,
        ),
      );
      return;
    }

    final maxAllowed = maxPhotosForTrack;
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
      final countToLoad = math.min(sampleAssets.length, maxAllowed);

      for (int i = 0; i < countToLoad; i++) {
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
            content: Text("✨ Added ${_photos.length} demo photos (Max: $maxAllowed for track)!", style: const TextStyle(color: AppColors.textEngraved)),
            backgroundColor: AppColors.panelCream,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading sample photos: $e');
    }
  }

  void _togglePlayAudio() async {
    if (_selectedMusic == null) {
      _openSoundLibrary();
      return;
    }
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      if (_selectedMusic!.existsSync()) {
        await _audioPlayer.play(DeviceFileSource(_selectedMusic!.path));
        await _audioPlayer.seek(Duration(seconds: _audioStart.toInt()));
      }
      setState(() => _isPlayingAudio = true);
    }
  }

  void _triggerMasterReel() async {
    if (_selectedMusic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Step 1: Please select a music track first!"),
          backgroundColor: AppColors.panelCream,
        ),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Step 2: Add at least one photo first!"),
          backgroundColor: AppColors.panelCream,
        ),
      );
      return;
    }

    // All templates and Pro features unlocked for closed testing
    _showRenderChoiceDialog();
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

  void _executeRender({required bool isInstant}) {
    if (_selectedMusic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Step 1: Please select a music track first.")),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Step 2: Please select photos before rendering.")),
      );
      return;
    }

    String tId;
    String tDisplayName;
    if (_currentMode == "auto") {
      tId = _currentAutoTemplate.id;
      tDisplayName = _currentAutoTemplate.name;
    } else {
      tId = _selectedTemplate;
      final matching = BeatTemplate.allTemplates.where((t) => t.id == tId).toList();
      tDisplayName = matching.isNotEmpty ? matching.first.name : "Beat Cut";
    }

    final jobId = DateTime.now().millisecondsSinceEpoch.toString();
    final maxAllowed = maxPhotosForTrack;
    final photosToSend = _photos.length > maxAllowed
        ? _photos.take(maxAllowed).toList()
        : _photos;
    final photosSnapshot = List<PhotoItem>.from(photosToSend);
    final musicSnapshot = _selectedMusic;
    final aspectRatioSnapshot = _selectedAspectRatio;
    final qualitySnapshot = _selectedQuality;
    final shouldWatermark = cm.shouldWatermark(isInstant);
    final audioStartSnapshot = _audioStart.toInt();
    final audioEndSnapshot = _audioEnd.toInt();
    final titleTextSnapshot = _enableTitle ? _titleText : null;
    final titleBgSnapshot = _titleBg;
    final titleDurationSnapshot = _titleDuration;
    final titleFontSnapshot = _titleFont;
    final titleStyleSnapshot = _titleStyle;
    final titleFrameSnapshot = _titleFrame;

    // Immediately create and record the processing job in QueueManager
    qm.addJob(QueueJobItem(
      id: jobId,
      templateName: tDisplayName,
      status: "PROCESSING",
      createdAt: DateTime.now(),
      quality: qualitySnapshot,
      progress: 0.05,
    ));

    if (isInstant && cm.credits > 0) {
      cm.deductCredit();
    }

    // Immediately switch user to "MY REELS" (vault) view and focus new job
    setState(() {
      _currentMode = "vault";
      _focusedJobId = jobId;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.hardwareGunmetal,
        content: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(color: AppColors.brassGold, strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "🎬 Rendering '$tDisplayName' in background...",
                style: const TextStyle(color: AppColors.panelCream, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Launch background execution (non-blocking)
    _runBackgroundRenderTask(
      jobId: jobId,
      templateId: tId,
      templateName: tDisplayName,
      photos: photosSnapshot,
      music: musicSnapshot,
      aspectRatio: aspectRatioSnapshot,
      quality: qualitySnapshot,
      watermark: shouldWatermark,
      isInstant: isInstant,
      audioStart: audioStartSnapshot,
      audioEnd: audioEndSnapshot,
      titleText: titleTextSnapshot,
      titleBg: titleBgSnapshot,
      titleDuration: titleDurationSnapshot,
      titleFont: titleFontSnapshot,
      titleStyle: titleStyleSnapshot,
      titleFrame: titleFrameSnapshot,
    );
  }

  Future<void> _runBackgroundRenderTask({
    required String jobId,
    required String templateId,
    required String templateName,
    required List<PhotoItem> photos,
    required File? music,
    required String aspectRatio,
    required String quality,
    required bool watermark,
    required bool isInstant,
    required int audioStart,
    required int audioEnd,
    required String? titleText,
    required String titleBg,
    required int titleDuration,
    required String titleFont,
    required String titleStyle,
    required String titleFrame,
  }) async {
    try {
      final photoFiles = photos.map((p) => File(p.path)).toList();
      File musicFile = music ?? await SoundTrack.builtInLibrary.first.getCachedFile();
      if (!musicFile.existsSync()) {
        musicFile = await SoundTrack.builtInLibrary.first.getCachedFile();
      }

      final videoPath = await api.renderReel(
        musicFile: musicFile,
        photoFiles: photoFiles,
        templateId: templateId,
        aspectRatio: aspectRatio,
        quality: quality,
        watermark: watermark,
        isInstant: isInstant,
        audioStart: audioStart,
        audioEnd: audioEnd,
        titleText: titleText,
        titleBg: titleBg,
        titleDuration: titleDuration,
        titleFont: titleFont,
        titleStyle: titleStyle,
        titleFrame: titleFrame,
        onProgress: (p) {
          qm.updateJobProgress(jobId, p);
        },
      );

      await qm.updateJob(
        jobId,
        status: "READY",
        videoPath: videoPath,
        progress: 1.0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E2818),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.vuGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "'$templateName' is ready to watch!",
                    style: const TextStyle(color: AppColors.panelCream, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    VideoPreviewDialog.show(
                      context,
                      videoPath: videoPath,
                      templateName: templateName,
                      quality: quality,
                    );
                  },
                  child: const Text("PLAY ▶", style: TextStyle(color: AppColors.brassGold, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      final cleanMsg = e.toString().replaceAll("Exception: ", "").trim();
      await qm.updateJob(
        jobId,
        status: "FAILED",
        error: cleanMsg,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF381414),
            content: Text("Render failed: $cleanMsg", style: const TextStyle(color: Colors.white, fontSize: 12)),
            action: SnackBarAction(
              label: "DISMISS",
              textColor: AppColors.brassGold,
              onPressed: () {},
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SnapBeatPinkDot(size: 14, withGlow: true),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/snapbeat_logo.png',
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => StoreBottomSheet.show(context, onPurchaseComplete: () => setState(() {})),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.panelCream,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderBrass, width: 1),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, offset: Offset(1, 1), blurRadius: 2),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⚡', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${cm.credits} PASSES',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 9.5,
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

                // Main Scrollable Console Deck
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      if (_currentMode != "vault") ...[
                        if (_currentMode == "auto") _buildAutoTemplateBanner(),

                        // 1. Reel-to-Reel Tape Deck (STEP 1: MUSIC FIRST)
                        RetroTapeDeck(
                          isPlaying: _isPlayingAudio,
                          trackTitle: _selectedMusicTitle,
                          currentSeconds: _audioStart,
                          totalSeconds: _audioDuration,
                          onTogglePlay: _togglePlayAudio,
                          onPickAudio: _pickMusic,
                          onLoadSample: _openSoundLibrary,
                          onQuickDemo: _loadDefaultSampleTrack,
                        ),

                        // 2. Interactive Audio Waveform Trimmer (Collapsible, shown when music is loaded)
                        if (_selectedMusic != null) ...[
                          if (_currentMode == "pro" || _showAudioTrimmerInAuto) ...[
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
                            if (_currentMode == "auto")
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Center(
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: AppColors.textMuted),
                                    label: const Text('COLLAPSE TRIMMER', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                                    onPressed: () => setState(() => _showAudioTrimmerInAuto = false),
                                  ),
                                ),
                              ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: GestureDetector(
                                onTap: () => setState(() => _showAudioTrimmerInAuto = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.panelCreamDark,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderBrass.withValues(alpha: 0.6), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.tune_rounded, size: 14, color: AppColors.brassGold),
                                          const SizedBox(width: 8),
                                          Text(
                                            "TRIM AUDIO: ${_audioStart.toInt()}s - ${_audioEnd.toInt()}s (OPTIONAL)",
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                              color: AppColors.textEngraved,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textEngraved),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],

                        // 3. 35mm Slide Mounts Curate Strip (STEP 2: PHOTOS SECOND - ONLY PHOTO BLOCK)
                        SnapsReorderStrip(
                          photos: _photos,
                          isEnabled: _selectedMusic != null,
                          maxPhotos: maxPhotosForTrack,
                          onPromptSelectMusic: _openSoundLibrary,
                          onAddPhotos: _pickPhotos,
                          onReorder: (oldIdx, newIdx) {
                            setState(() {
                              if (newIdx > oldIdx) newIdx -= 1;
                              final item = _photos.removeAt(oldIdx);
                              _photos.insert(newIdx, item);
                              _arrangementMode = 'manual';
                            });
                          },
                          onDelete: (id) => setState(() => _photos.removeWhere((p) => p.id == id)),
                          arrangementMode: _arrangementMode,
                          onArrangementModeChanged: (m) => setState(() => _arrangementMode = m),
                          onLoadSample: _loadSamplePhotos,
                          onAutoShuffle: _autoShufflePhotos,
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
                            titleFont: _titleFont,
                            onSelectTitleFont: (f) => setState(() => _titleFont = f),
                            titleStyle: _titleStyle,
                            onSelectTitleStyle: (s) => setState(() => _titleStyle = s),
                            titleFrame: _titleFrame,
                            onSelectTitleFrame: (fr) => setState(() => _titleFrame = fr),
                          ),
                      ] else ...[
                        // Vault Jobs List
                        _buildVaultView(),
                      ],
                    ],
                  ),
                ),

                // Bottom Action Deck (With Integrated Thumb Mode Switcher and RENDER [Button] NOW)
                MasterActionDeck(
                  currentMode: _currentMode,
                  onSelectMode: (mode) {
                    setState(() {
                      _currentMode = mode;
                      if (mode == "auto") {
                        _rollAutoTemplate();
                      }
                    });
                  },
                  photoCount: _photos.length,
                  onTriggerMaster: _triggerMasterReel,
                  activeJobsCount: qm.activeJobs.length,
                ),
              ],
            ),
          ],
        ),
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
          const SnapBeatPinkDot(size: 13, withGlow: true),
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
          children: [
            const Icon(Icons.movie_creation_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              "NO REELS YET",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: AppColors.textEngraved,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your rendered reels will appear here.\nSelect photos & music to create your first reel!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brassGold,
                foregroundColor: AppColors.hardwareGunmetal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text("CREATE REEL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
              onPressed: () => setState(() => _currentMode = "auto"),
            ),
          ],
        ),
      );
    }

    final activeJobs = jobs.where((j) => j.status == "PROCESSING").toList();
    final completedJobs = jobs.where((j) => j.status == "READY").toList();
    final failedJobs = jobs.where((j) => j.status == "FAILED").toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top banner in Vault allowing scheduling another job
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.panelCreamDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.chassisBevelLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  SnapBeatPinkDot(size: 13, withGlow: true),
                  SizedBox(width: 8),
                  Text(
                    "MY REELS & QUEUE",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: AppColors.textEngraved,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _currentMode = "auto"),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brassGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_rounded, size: 14, color: AppColors.hardwareGunmetal),
                      SizedBox(width: 2),
                      Text(
                        "NEW REEL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.hardwareGunmetal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Active Rendering Jobs (shown at top with live progress)
        if (activeJobs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: const [
                SnapBeatPinkDot(size: 9, withGlow: true),
                SizedBox(width: 6),
                Text(
                  "PROCESSING IN BACKGROUND",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.amberJewel,
                  ),
                ),
              ],
            ),
          ),
          ...activeJobs.map((job) => _buildActiveJobCard(job)),
        ],

        // Completed / Ready Reels
        if (completedJobs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Text(
              "COMPLETED (${completedJobs.length})",
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...completedJobs.map((job) => _buildReadyJobCard(job)),
        ],

        // Failed Jobs (if any)
        if (failedJobs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Text(
              "FAILED (${failedJobs.length})",
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.vuRed,
              ),
            ),
          ),
          ...failedJobs.map((job) => _buildFailedJobCard(job)),
        ],
      ],
    );
  }

  Widget _buildActiveJobCard(QueueJobItem job) {
    final percent = (job.progress * 100).clamp(0, 99).toInt();
    final isFocused = job.id == _focusedJobId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFFFF3366) : AppColors.brassGold,
          width: isFocused ? 2.2 : 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? const Color(0xFFFF3366).withValues(alpha: 0.35)
                : AppColors.amberGlow.withValues(alpha: 0.4),
            offset: const Offset(0, 3),
            blurRadius: isFocused ? 12 : 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFocused) ...[
            Row(
              children: const [
                SnapBeatPinkDot(size: 11, withGlow: true),
                SizedBox(width: 6),
                Text(
                  "CURRENT RENDER IN PROGRESS",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFFFF3366),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(color: AppColors.brassGold, strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    job.templateName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: AppColors.textEngraved,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isFocused ? const Color(0xFFFF3366).withValues(alpha: 0.2) : AppColors.amberJewel.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isFocused ? const Color(0xFFFF3366) : AppColors.amberJewel, width: 1),
                ),
                child: Text(
                  "$percent%",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isFocused ? const Color(0xFFFF3366) : AppColors.amberJewel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: job.progress.clamp(0.05, 1.0),
              backgroundColor: AppColors.panelInset,
              color: isFocused ? const Color(0xFFFF3366) : AppColors.amberJewel,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quality: ${job.quality} • Syncing frames & beats...",
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              Text(
                DateFormat('hh:mm a').format(job.createdAt),
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadyJobCard(QueueJobItem job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBrass, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status badge, Title & Details, and Delete Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.vuGreen.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.vuGreen.withValues(alpha: 0.45), width: 1),
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.vuGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.templateName.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.textEngraved,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Resolution: ${job.quality.toUpperCase()}  •  ${DateFormat('MMM d, yyyy  •  hh:mm a').format(job.createdAt)}",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A5243),
                      ),
                    ),
                    if (job.videoPath != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        "Status: Ready for export & playback",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.vuGreen.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.textMuted),
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
                onPressed: () => qm.deleteJob(job.id),
              ),
            ],
          ),

          // Row 2: Action Buttons placed UNDER the video details
          if (job.videoPath != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.chassisBevelLight, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                // 1. PLAY BUTTON
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () async {
                      await _audioPlayer.pause();
                      if (!mounted) return;
                      setState(() => _isPlayingAudio = false);
                      VideoPreviewDialog.show(
                        context,
                        videoPath: job.videoPath!,
                        templateName: job.templateName,
                        quality: job.quality,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.brassKnobGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(1, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: AppColors.hardwareGunmetal, size: 18),
                          SizedBox(width: 4),
                          Text(
                            "PLAY",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.hardwareGunmetal,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 2. SAVE TO GALLERY BUTTON
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => ExportService.saveToGallery(
                      context,
                      videoPath: job.videoPath!,
                      templateName: job.templateName,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.panelCreamDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderBrass, width: 1.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_rounded, color: AppColors.brassGold, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "SAVE",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textEngraved,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 3. SOCIAL SHARE BUTTON
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => ExportService.shareReel(
                      context,
                      videoPath: job.videoPath!,
                      templateName: job.templateName,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.panelCreamDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.pinkAccent, width: 1.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, color: AppColors.pinkAccent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "SHARE",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.pinkAccent,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFailedJobCard(QueueJobItem job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.vuRed.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.vuRed, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.templateName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textEngraved),
                ),
                const SizedBox(height: 2),
                Text(
                  job.error ?? "Render error occurred",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.vuRed),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
            onPressed: () => qm.deleteJob(job.id),
          ),
        ],
      ),
    );
  }
}