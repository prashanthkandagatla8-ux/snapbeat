import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, SystemNavigator;
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
import '../components/video_preview_dialog.dart';
import '../components/sound_library_dialog.dart';
import '../components/privacy_policy_dialog.dart';
import '../components/metal_chassis_scaffold.dart';
import '../components/snapbeat_pink_dot.dart';
import '../components/retro_mechanical_button.dart';

class HomeScreen extends StatefulWidget {
  final String initialTab;
  final String initialRenderMode;
  final File? initialMusic;
  final String? initialMusicTitle;
  final List<PhotoItem>? initialPhotos;
  final bool fromShowcase;

  static ui.Image? logoUiImage;

  const HomeScreen({
    super.key,
    this.initialTab = "music",
    this.initialRenderMode = "auto",
    this.initialMusic,
    this.initialMusicTitle,
    this.initialPhotos,
    this.fromShowcase = false,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final cm = CreditManager.instance;
  final qm = QueueManager.instance;
  final api = ApiService.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  String? _focusedJobId;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerPositionSubscription;
  bool _isSubmittingRender = false;

  String _currentTab = "music"; // "music", "photos", "render", "queue"
  String _renderMode = "auto"; // "auto", "pro"
  File? _selectedMusic;
  String _selectedMusicTitle = "";

  void setScreenshotState({
    String? currentTab,
    String? renderMode,
    File? musicFile,
    String? musicTitle,
    List<PhotoItem>? photos,
    String? selectedTemplate,
    String? selectedAspectRatio,
    String? selectedQuality,
  }) {
    setState(() {
      if (currentTab != null) {
        if (_isPlayingAudio && currentTab != 'music') {
          _audioPlayer.pause();
          _isPlayingAudio = false;
        }
        _currentTab = currentTab;
      }
      if (renderMode != null) _renderMode = renderMode;
      if (musicFile != null) _selectedMusic = musicFile;
      if (musicTitle != null) _selectedMusicTitle = musicTitle;
      if (photos != null) {
        _photos.clear();
        _photos.addAll(photos);
      }
      if (selectedTemplate != null) _selectedTemplate = selectedTemplate;
      if (selectedAspectRatio != null) _selectedAspectRatio = selectedAspectRatio;
      if (selectedQuality != null) _selectedQuality = selectedQuality;
    });
  }
  final List<PhotoItem> _photos = [];
  String _selectedTemplate = "pendulum";
  String _selectedAspectRatio = "9:16";
  String _selectedQuality = "720p";
  String _arrangementMode = "sequential";

  /// Calculates max photos dynamically based on track duration and beat tempo.
  int get maxPhotosForTrack {
    if (_selectedMusic == null) return 30;
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
  double _audioEnd = 30.0;
  bool _isPlayingAudio = false;

  // Title Intro
  bool _enableTitle = false;
  String _titleText = "";
  late final TextEditingController _titleTextController;
  String _titleBg = "black";
  int _titleDuration = 2;
  String _titleFont = "great_vibes";
  String _titleStyle = "classic";
  String _titleFrame = "none";
  String _titleAudio = "before_audio";

  // Auto Mode Template Rotation
  BeatTemplate _currentAutoTemplate = BeatTemplate.allTemplates.first;
  String? _lastAutoTemplateId;

  void _assignAutoTemplate() {
    final pool = BeatTemplate.allTemplates.where((t) => t.id != _lastAutoTemplateId).toList();
    final picked = pool.isNotEmpty
        ? (List<BeatTemplate>.from(pool)..shuffle()).first
        : BeatTemplate.allTemplates.first;
    _lastAutoTemplateId = picked.id;
    _currentAutoTemplate = picked;
  }

  void _rollAutoTemplate() {
    setState(() {
      _assignAutoTemplate();
    });
  }

  void _showNotice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: Color(0xFF1E1A10),
          ),
        ),
        backgroundColor: const Color(0xFFFFD54F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 95),
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFBF8A00), width: 1),
        ),
      ),
    );
  }

  void _cancelAndRemoveJob(String jobId) {
    qm.markCancelled(jobId);
    qm.deleteJob(jobId);
    if (_focusedJobId == jobId) {
      _focusedJobId = null;
    }
    setState(() {});
  }

  void _showClearQueueDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.chassisBevelDark, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.delete_sweep_rounded, color: AppColors.brassGold, size: 22),
            SizedBox(width: 8),
            Text(
              "Clear Queue?",
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
          "Are you sure you want to cancel any active renders and remove all reel items from the queue?",
          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B2525),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              qm.clearAll();
              _focusedJobId = null;
              setState(() {});
            },
            child: const Text("CLEAR ALL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _autoShufflePhotos() {
    if (_photos.isEmpty) return;
    setState(() {
      _photos.shuffle();
      for (int i = 0; i < _photos.length; i++) {
        _photos[i].order = i + 1;
      }
    });
  }

  void _resetPhotos() {
    if (_photos.isEmpty) return;
    setState(() {
      _photos.clear();
      SnapsReorderStrip.photoImageCache.clear();
    });
    _showNotice("Photo selection reset");
  }

  void _showShowcaseWelcomeModal() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.panelCream,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.borderBrass, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle & Branding Pill
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.chassisBevelDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Welcome Badge
              Row(
                children: [
                  const SnapBeatPinkDot(size: 14, withGlow: true),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brassGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'WELCOME TO SNAPBEAT',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.hardwareGunmetal,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Headline
              const Text(
                'Create Reels Like This with Your Photos & Music!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textEngraved,
                  letterSpacing: -0.2,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              // Friendly guidance text
              const Text(
                'You just saw the Pendulum beat-sync sample. You can create the exact same cinematic reel using your personal gallery photos and favorite soundtrack in seconds!',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),

              // 3 Quick Steps Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.chassisBevelDark),
                ),
                child: Column(
                  children: [
                    _buildWelcomeStepRow(
                      icon: Icons.photo_library_rounded,
                      step: 'STEP 1',
                      title: 'Pick Your Photos',
                      desc: 'Select photos from your gallery or try with Sample Photos.',
                    ),
                    const Divider(color: AppColors.chassisBevelDark, height: 16),
                    _buildWelcomeStepRow(
                      icon: Icons.music_note_rounded,
                      step: 'STEP 2',
                      title: 'Choose Music',
                      desc: 'Pick your own MP3 or choose from the sound library.',
                    ),
                    const Divider(color: AppColors.chassisBevelDark, height: 16),
                    _buildWelcomeStepRow(
                      icon: Icons.motion_photos_auto_rounded,
                      step: 'STEP 3',
                      title: 'Render Pendulum Reel',
                      desc: 'Pre-selected for you! Tap Render to sync your photos to the beat.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Call to Action
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE082), Color(0xFFFFC72C)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBF8A00), width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.explore_rounded, size: 16, color: Color(0xFF1E1A10)),
                      SizedBox(width: 8),
                      Text(
                        'EXPLORE STUDIO ❯',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Color(0xFF1E1A10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStepRow({
    required IconData icon,
    required String step,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.brassGold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, size: 14, color: AppColors.brassGold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    step,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.amberJewel,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textEngraved,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _renderMode = widget.initialRenderMode;
    _titleTextController = TextEditingController(text: _titleText);
    if (widget.fromShowcase) {
      _selectedTemplate = 'pendulum';
      _currentAutoTemplate = BeatTemplate.allTemplates.firstWhere(
        (t) => t.id == 'pendulum',
        orElse: () => BeatTemplate.allTemplates.first,
      );
      _lastAutoTemplateId = 'pendulum';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showShowcaseWelcomeModal();
      });
    } else {
      _assignAutoTemplate();
    }
    if (widget.initialMusic != null) {
      _selectedMusic = widget.initialMusic;
      _selectedMusicTitle = widget.initialMusicTitle ?? "";
      _audioDuration = 58.0;
      _audioStart = 0.0;
      _audioEnd = 58.0;
    } else {
      final defaultTrack = SoundTrack.builtInLibrary.first;
      _selectedMusicTitle = '${defaultTrack.title} (${defaultTrack.bpm})';
      _audioDuration = defaultTrack.durationSeconds;
      _audioStart = 0.0;
      _audioEnd = defaultTrack.durationSeconds;
    }
    if (widget.initialPhotos != null) {
      _photos.addAll(widget.initialPhotos!);
    }
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
    _playerPositionSubscription = _audioPlayer.onPositionChanged.listen((pos) {
      if (_isPlayingAudio && pos.inMilliseconds >= (_audioEnd * 1000).toInt()) {
        _audioPlayer.pause();
        if (mounted) setState(() => _isPlayingAudio = false);
      }
    });
    qm.addListener(_onQueueChanged);
    _initData();
  }

  Future<void> _initData() async {
    await cm.init();
    await qm.init();
    if (widget.initialMusic == null && _selectedMusic == null) {
      await _loadDefaultSampleTrack();
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadDefaultSampleTrack() async {
    await _audioPlayer.pause();
    if (!mounted) return;
    setState(() => _isPlayingAudio = false);
    try {
      final track = SoundTrack.builtInLibrary.first;
      final file = await track.getCachedFile();
      if (!mounted) return;
      setState(() {
        _selectedMusic = file;
        _selectedMusicTitle = '${track.title} (${track.bpm})';
        _audioDuration = track.durationSeconds;
        _audioStart = 0.0;
        _audioEnd = track.durationSeconds;
      });
    } catch (e) {
      debugPrint('Error loading sample track: $e');
    }
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _playerPositionSubscription?.cancel();
    _titleTextController.dispose();
    _scrollController.dispose();
    qm.removeListener(_onQueueChanged);
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    if (result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      final fileName = result.first.name;
      double dur = 60.0;
      try {
        await _audioPlayer.setSource(DeviceFileSource(file.path));
        final d = await _audioPlayer.getDuration();
        if (d != null && d.inSeconds > 0) {
          dur = d.inSeconds.toDouble();
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _selectedMusic = file;
        _selectedMusicTitle = fileName;
        _audioDuration = dur;
        _audioStart = 0.0;
        _audioEnd = dur;
      });
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
        if (!mounted) return;
        setState(() {
          _selectedMusic = file;
          _selectedMusicTitle = '${track.title} (${track.bpm})';
          _audioDuration = track.durationSeconds;
          _audioStart = 0.0;
          _audioEnd = track.durationSeconds;
        });
      },
    );
  }

  Future<void> _pickPhotos() async {
    final maxAllowed = maxPhotosForTrack;
    if (_photos.length >= maxAllowed) {
      _showNotice("Maximum $maxAllowed photos already reached for this track.");
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
      if (!mounted) return;
      setState(() {});
      if (pickedList.length > added && mounted) {
        _showNotice("Added $added photos (capped at $maxAllowed).");
      }
    }
  }

  Future<void> _loadSamplePhotos() async {
    if (_selectedMusic == null) {
      _showNotice("Step 1: Please select a music track first!");
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

      if (!mounted) return;
      _photos.clear();
      _photos.addAll(loadedPhotos);
      setState(() {});
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
      if (!mounted) return;
      setState(() => _isPlayingAudio = false);
    } else {
      if (_selectedMusic!.existsSync()) {
        await _audioPlayer.play(DeviceFileSource(_selectedMusic!.path));
        await _audioPlayer.seek(Duration(seconds: _audioStart.toInt()));
      }
      if (!mounted) return;
      setState(() => _isPlayingAudio = true);
    }
  }

  void _triggerMasterReel() async {
    if (_isSubmittingRender) return;
    _isSubmittingRender = true;
    try {
      if (_selectedMusic == null) {
        _showNotice("Step 1: Please select a music track first!");
        return;
      }
      if (_photos.isEmpty) {
        _showNotice("Step 2: Please add at least 2 photos.");
        return;
      }

      // Direct single render execution for testing (holding instant modal for now)
      _executeRender(isInstant: false);
    } finally {
      _isSubmittingRender = false;
    }
  }


  // Reserved for instant render & credits pack workflow (temporarily held):
  // void _showRenderChoiceDialog() { ... }

  void _executeRender({required bool isInstant}) {
    if (_selectedMusic == null) {
      _showNotice("Step 1: Please select a music track first.");
      return;
    }
    if (_photos.isEmpty) {
      _showNotice("Step 2: Please select photos before rendering.");
      return;
    }

    String tId;
    String tDisplayName;
    if (_renderMode == "auto") {
      tId = _currentAutoTemplate.id;
      tDisplayName = _currentAutoTemplate.name;
    } else {
      tId = _selectedTemplate;
      final matching = BeatTemplate.allTemplates.where((t) => t.id == tId).toList();
      tDisplayName = matching.isNotEmpty ? matching.first.name : "Beat Cut";
    }

    final selectedTpl = BeatTemplate.allTemplates.firstWhere((t) => t.id == tId, orElse: () => BeatTemplate.allTemplates.first);
    if (selectedTpl.isPro && !cm.isProModeEnabled) {
      _showNotice('This template requires Pro Mode. Unlock it in the Store.');
      return;
    }

    final jobId = DateTime.now().millisecondsSinceEpoch.toString();
    final maxAllowed = maxPhotosForTrack;
    if (_photos.length > maxAllowed) {
      _showNotice('Only the first $maxAllowed photos will be used for this track duration.');
    }
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
    final titleAudioSnapshot = _titleAudio;

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

    // Immediately switch user to "QUEUE" view and focus new job (retains all photo/music selections)
    setState(() {
      const newTab = "queue";
      if (_isPlayingAudio && newTab != 'music') {
        _audioPlayer.pause();
        _isPlayingAudio = false;
      }
      _currentTab = newTab;
      _focusedJobId = jobId;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });

    // Launch background execution (non-blocking, zero intrusive popups)
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
      titleAudio: titleAudioSnapshot,
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
    required String titleAudio,
  }) async {
    try {
      if (qm.isCancelled(jobId)) return;

      final photoFiles = photos.map((p) => File(p.path)).toList();
      File musicFile = music ?? await SoundTrack.builtInLibrary.first.getCachedFile();
      if (!musicFile.existsSync()) {
        musicFile = await SoundTrack.builtInLibrary.first.getCachedFile();
      }

      if (qm.isCancelled(jobId)) return;

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
        titleAudio: titleAudio,
        onProgress: (p) {
          if (!qm.isCancelled(jobId)) {
            qm.updateJobProgress(jobId, p);
          }
        },
        onStatusUpdate: (status, stage, queuePos, p) {
          if (!qm.isCancelled(jobId)) {
            final mappedStatus = (status == "queued")
                ? "QUEUED"
                : (status == "rendering" ? "RENDERING" : "PROCESSING");
            qm.updateJobProgress(
              jobId,
              p,
              queuePosition: queuePos,
              stage: stage,
              status: mappedStatus,
            );
          }
        },
      );

      if (qm.isCancelled(jobId)) return;

      await qm.updateJob(
        jobId,
        status: "READY",
        videoPath: videoPath,
        progress: 1.0,
      );
    } catch (e) {
      if (qm.isCancelled(jobId)) return;
      final cleanMsg = e.toString().replaceAll("Exception: ", "").trim();
      await qm.updateJob(
        jobId,
        status: "FAILED",
        error: cleanMsg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentTab != 'music') {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0.0);
          }
          setState(() {
            const newTab = 'music';
            if (_isPlayingAudio && newTab != 'music') {
              _audioPlayer.pause();
              _isPlayingAudio = false;
            }
            _currentTab = newTab;
          });
        } else {
          // Optionally show exit confirmation or allow pop
          SystemNavigator.pop();
        }
      },
      child: MetalChassisScaffold(
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
                            HomeScreen.logoUiImage != null
                                ? RawImage(
                                    image: HomeScreen.logoUiImage,
                                    height: 42,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    'assets/images/snapbeat_logo.png',
                                    height: 42,
                                    fit: BoxFit.contain,
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Right Action Group: Privacy Policy Shield (credits pack held for now)
                      IconButton(
                        icon: const Icon(Icons.shield_outlined, color: AppColors.brassGold, size: 20),
                        tooltip: 'Privacy Policy',
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        onPressed: () => PrivacyPolicyDialog.show(context),
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
                      if (_currentTab == "music") ...[
                        // STAGE 1: MUSIC FIRST
                        RetroTapeDeck(
                          isPlaying: _isPlayingAudio,
                          trackTitle: _selectedMusicTitle,
                          currentSeconds: _audioStart,
                          onTogglePlay: _togglePlayAudio,
                          onPickAudio: _pickMusic,
                          onLoadSample: _openSoundLibrary,
                        ),

                        // Interactive Audio Waveform Trimmer (shown when music is loaded)
                        if (_selectedMusic != null) ...[
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: _buildProceedButton(
                              label: "PROCEED TO PHOTOS",
                              subtitle: "Up to $maxPhotosForTrack photos can fit this ${_audioEnd > _audioStart ? (_audioEnd - _audioStart).toInt() : _audioDuration.toInt()}s track",
                              icon: Icons.photo_library_rounded,
                              onTap: () {
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpTo(0.0);
                                }
                                setState(() {
                                  const newTab = "photos";
                                  if (_isPlayingAudio && newTab != 'music') {
                                    _audioPlayer.pause();
                                    _isPlayingAudio = false;
                                  }
                                  _currentTab = newTab;
                                });
                              },
                            ),
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.panelCreamDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.chassisBevelLight),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textMuted),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Loading default soundtrack... Tap Library or Choose Music if you want to change it.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ] else if (_currentTab == "photos") ...[
                        // STAGE 2: PHOTOS (Curate & Arrange)
                        if (_selectedMusic == null)
                          _buildGatedCard(
                            icon: Icons.library_music_rounded,
                            title: "Music Required",
                            description: "Track duration and BPM determine the optimal photo count.\nPlease select a music track in Step 1 first.",
                            buttonText: "GO TO MUSIC",
                            onButtonTap: () {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(0.0);
                              }
                              setState(() {
                                const newTab = "music";
                                if (_isPlayingAudio && newTab != 'music') {
                                  _audioPlayer.pause();
                                  _isPlayingAudio = false;
                                }
                                _currentTab = newTab;
                              });
                            },
                          )
                        else ...[
                          SnapsReorderStrip(
                            photos: _photos,
                            isEnabled: true,
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
                            onClearAll: _resetPhotos,
                            onResetPhotos: _resetPhotos,
                          ),
                          if (_photos.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: _buildProceedButton(
                                label: "PROCEED TO RENDER OPTIONS",
                                subtitle: "${_photos.length} photos curated and ready",
                                icon: Icons.movie_creation_rounded,
                                onTap: () {
                                  if (_scrollController.hasClients) {
                                    _scrollController.jumpTo(0.0);
                                  }
                                  setState(() {
                                    const newTab = "render";
                                    if (_isPlayingAudio && newTab != 'music') {
                                      _audioPlayer.pause();
                                      _isPlayingAudio = false;
                                    }
                                    _currentTab = newTab;
                                  });
                                },
                              ),
                            ),
                        ],
                      ] else if (_currentTab == "render") ...[
                        // STAGE 3: RENDER OPTIONS (Auto vs Pro)
                        if (_selectedMusic == null)
                          _buildGatedCard(
                            icon: Icons.library_music_rounded,
                            title: "Music Required",
                            description: "Please select a music track in Step 1 before configuring render options.",
                            buttonText: "GO TO MUSIC",
                            onButtonTap: () {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(0.0);
                              }
                              setState(() {
                                const newTab = "music";
                                if (_isPlayingAudio && newTab != 'music') {
                                  _audioPlayer.pause();
                                  _isPlayingAudio = false;
                                }
                                _currentTab = newTab;
                              });
                            },
                          )
                        else if (_photos.isEmpty)
                          _buildGatedCard(
                            icon: Icons.photo_library_rounded,
                            title: "PHOTOS REQUIRED FIRST",
                            description: "Please add at least 2 photos in Step 2 before configuring render options.",
                            buttonText: "GO TO PHOTOS",
                            onButtonTap: () {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(0.0);
                              }
                              setState(() {
                                const newTab = "photos";
                                if (_isPlayingAudio && newTab != 'music') {
                                  _audioPlayer.pause();
                                  _isPlayingAudio = false;
                                }
                                _currentTab = newTab;
                              });
                            },
                          )
                        else
                          _buildRenderOptionsView(),
                      ] else ...[
                        // STAGE 4: QUEUE (Processing & Finished Reels)
                        _buildVaultView(),
                      ],
                    ],
                  ),
                ),

                // Bottom Action Deck (With 4-Stage Navigation Switcher: MUSIC, PHOTOS, RENDER, QUEUE)
                MasterActionDeck(
                  currentMode: _currentTab,
                  onSelectMode: (tab) {
                    if (_isPlayingAudio && tab != 'music') {
                      _audioPlayer.pause();
                      _isPlayingAudio = false;
                    }
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                    setState(() {
                      _currentTab = tab;
                      if (tab == "render" && _renderMode == "auto") {
                        _assignAutoTemplate();
                      }
                    });
                  },
                  isPhotosEnabled: _selectedMusic != null,
                  isRenderEnabled: _selectedMusic != null && _photos.isNotEmpty,
                  activeJobsCount: qm.activeJobs.length,
                  onDisabledTabTap: (tab) {
                    if (tab == 'photos') {
                      _showNotice("🎵 Select a music track first to unlock photos!");
                    } else if (tab == 'render') {
                      final msg = _selectedMusic == null
                          ? "🎵 Select a music track first!"
                          : "📸 Add at least 2 photos to configure render options!";
                      _showNotice(msg);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildProceedButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE082), Color(0xFFFFC72C)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBF8A00), width: 1.2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1E1A10)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Color(0xFF1E1A10),
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A463F),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF1E1A10)),
          ],
        ),
      ),
    );
  }

  Widget _buildGatedCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chassisBevelDark),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.panelInset,
              border: Border.all(color: AppColors.chassisBevelLight),
            ),
            child: Icon(icon, size: 36, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: AppColors.textEngraved,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brassGold,
              foregroundColor: AppColors.hardwareGunmetal,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            onPressed: onButtonTap,
          ),
        ],
      ),
    );
  }

  Widget _buildRenderOptionsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Dual Mode Toggle: AUTO vs PRO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFB8AE9F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDED8CE), width: 1),
              boxShadow: const [
                BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
              ],
            ),
            child: Row(
              children: [
                _buildRenderModeSwitchOption(
                  mode: "auto",
                  label: "AUTO MODE",
                  icon: Icons.auto_awesome_rounded,
                  isSelected: _renderMode == "auto",
                ),
                const SizedBox(width: 4),
                _buildRenderModeSwitchOption(
                  mode: "pro",
                  label: "PRO MODE",
                  icon: Icons.tune_rounded,
                  isSelected: _renderMode == "pro",
                ),
              ],
            ),
          ),
        ),

        // 2. Mode Content
        if (_renderMode == "auto") ...[
          _buildAutoTemplateBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.panelCreamDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.chassisBevelLight),
              ),
              child: Row(
                children: const [
                  Icon(Icons.bolt_rounded, size: 18, color: AppColors.brassGold),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Auto beat-sync dynamically arranges transitions and pacing to match the soundtrack rhythm. Tap the dice to roll a different preset style!",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
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
            titleController: _titleTextController,
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
            titleAudio: _titleAudio,
            onSelectTitleAudio: (a) => setState(() => _titleAudio = a),
          ),
        ],

        // 3. Upcoming Templates & Advanced Modes Teaser Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1A16).withValues(alpha: 0.9),
                  const Color(0xFF2B2319).withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.45), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.5),
                  child: Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.amberJewel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: "Coming Soon: ",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.amberJewel),
                        ),
                        TextSpan(
                          text: "More exciting templates, advanced features and modes coming soon!",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Job Summary Badge
        _buildJobSummaryCard(),

        // 4. Render Reel Launch Button (Tactile 3D Skeuomorphic Button)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Center(
                child: RetroMechanicalButton(
                  variant: RetroButtonVariant.render,
                  height: 72,
                  onTap: _triggerMasterReel,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "READY TO SYNC ${_photos.length} ${_photos.length == 1 ? 'PHOTO' : 'PHOTOS'} TO BEAT",
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRenderModeSwitchOption({
    required String mode,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _renderMode = mode;
            if (mode == "auto") {
              _assignAutoTemplate();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE082),
                      Color(0xFFFFC72C),
                    ],
                  )
                : null,
            border: isSelected ? Border.all(color: const Color(0xFFBF8A00), width: 1) : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const SnapBeatPinkDot(size: 8, withGlow: true),
                const SizedBox(width: 4),
              ],
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF5A554D),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isSelected ? const Color(0xFF1E1A10) : const Color(0xFF4A463F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSummaryCard() {
    final durationSec = (_audioEnd > _audioStart && _audioEnd <= _audioDuration)
        ? (_audioEnd - _audioStart).toInt()
        : _audioDuration.toInt();
    final styleName = _renderMode == "auto"
        ? _currentAutoTemplate.name.toUpperCase()
        : _selectedTemplate.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panelCreamDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.chassisBevelLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SnapBeatPinkDot(size: 9, withGlow: true),
              SizedBox(width: 6),
              Text(
                "JOB CONFIGURATION SUMMARY",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.textEngraved,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryPill(Icons.music_note_rounded, _selectedMusicTitle.isEmpty ? "Track" : _selectedMusicTitle),
              _buildSummaryPill(Icons.timer_outlined, "${durationSec}s duration"),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryPill(Icons.photo_library_outlined, "${_photos.length} photos"),
              _buildSummaryPill(Icons.style_outlined, "$styleName • $_selectedAspectRatio • $_selectedQuality"),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSummaryPill(
                cm.isWatermarkRemoved ? Icons.verified_rounded : Icons.branding_watermark_rounded,
                cm.isWatermarkRemoved ? "WATERMARK: NONE" : "WATERMARK: SNAPBEAT",
                highlight: !cm.isWatermarkRemoved,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(IconData icon, String text, {bool highlight = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF2E2614) : AppColors.panelInset,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: highlight ? const Color(0xFFD4AF37) : AppColors.chassisBevelDark.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: highlight ? const Color(0xFFFFD54F) : AppColors.brassGold),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: highlight ? const Color(0xFFFFE082) : AppColors.textEngraved,
                ),
              ),
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
                  '${_currentAutoTemplate.emoji} ${_currentAutoTemplate.subtitle} (tap dice to change)',
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
              "No Reels Yet",
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
              onPressed: () {
                final newTab = _selectedMusic == null
                    ? "music"
                    : _photos.isEmpty
                        ? "photos"
                        : "render";
                if (_isPlayingAudio && newTab != 'music') {
                  _audioPlayer.pause();
                  _isPlayingAudio = false;
                }
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0.0);
                }
                setState(() => _currentTab = newTab);
              },
            ),
          ],
        ),
      );
    }

    final activeJobs = jobs.where((j) {
      final s = j.status.toUpperCase();
      return s == "PROCESSING" || s == "RENDERING" || s == "QUEUED";
    }).toList();
    final completedJobs = jobs.where((j) {
      final s = j.status.toUpperCase();
      return s == "READY" || s == "DONE" || s == "COMPLETED";
    }).toList();
    final failedJobs = jobs.where((j) => !activeJobs.contains(j) && !completedJobs.contains(j)).toList();

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
              Expanded(
                child: Row(
                  children: const [
                    SnapBeatPinkDot(size: 11, withGlow: true),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "QUEUE",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textEngraved,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (jobs.isNotEmpty) ...[
                    GestureDetector(
                      onTap: _showClearQueueDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.vuRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.vuRed.withValues(alpha: 0.5), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.delete_sweep_rounded, size: 13, color: AppColors.vuRed),
                            SizedBox(width: 3),
                            Text(
                              "CLEAR ALL",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.vuRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: () {
                      final newTab = _selectedMusic == null
                          ? "music"
                          : _photos.isEmpty
                              ? "photos"
                              : "render";
                      if (_isPlayingAudio && newTab != 'music') {
                        _audioPlayer.pause();
                        _isPlayingAudio = false;
                      }
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0.0);
                      }
                      setState(() => _currentTab = newTab);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.brassGold,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_rounded, size: 14, color: AppColors.hardwareGunmetal),
                          SizedBox(width: 3),
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
            ],
          ),
        ),

        // Testing Queue Notice Banner (active during closed beta)
        if (activeJobs.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A16).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.4), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.5),
                  child: Icon(Icons.info_outline_rounded, size: 13, color: AppColors.amberJewel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: "Beta Notice: ",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.amberJewel),
                        ),
                        TextSpan(
                          text: "Free renders process sequentially (1-at-a-time) in a shared queue. Thank you for your patience! Instant priority renders arriving soon.",
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
          // Header Status Badge: In Queue vs In Progress
          if (job.queuePosition > 0 || job.status.toUpperCase() == "QUEUED") ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A16),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.brassGold, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, size: 10, color: AppColors.amberJewel),
                      const SizedBox(width: 4),
                      Text(
                        "IN QUEUE • POSITION #${job.queuePosition > 0 ? job.queuePosition : 1}",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.amberJewel,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFocused) ...[
                  const SizedBox(width: 6),
                  const Text(
                    "WAITING IN LINE",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ] else if (isFocused || job.status.toUpperCase() == "RENDERING" || job.status.toUpperCase() == "PROCESSING") ...[
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
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: AppColors.brassGold, strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        job.templateName.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: AppColors.textEngraved,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isFocused ? const Color(0xFFFF3366).withValues(alpha: 0.2) : AppColors.amberJewel.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isFocused ? const Color(0xFFFF3366) : AppColors.amberJewel, width: 1),
                    ),
                    child: Text(
                      job.queuePosition > 0 || job.status.toUpperCase() == "QUEUED"
                          ? "QUEUE #${job.queuePosition > 0 ? job.queuePosition : 1}"
                          : "$percent%",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isFocused ? const Color(0xFFFF3366) : AppColors.amberJewel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _cancelAndRemoveJob(job.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.vuRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.vuRed.withValues(alpha: 0.6), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.close_rounded, size: 12, color: AppColors.vuRed),
                          SizedBox(width: 3),
                          Text(
                            "CANCEL",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: AppColors.vuRed,
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
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (job.queuePosition > 0 || job.status.toUpperCase() == "QUEUED") ? null : job.progress.clamp(0.05, 1.0),
              backgroundColor: AppColors.panelInset,
              color: isFocused ? const Color(0xFFFF3366) : AppColors.amberJewel,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.queuePosition > 0 || job.status.toUpperCase() == "QUEUED"
                      ? "Queue Position #${job.queuePosition > 0 ? job.queuePosition : 1} • Waiting for active render..."
                      : (job.stage != null && job.stage!.isNotEmpty
                          ? "Quality: ${job.quality} • ${job.stage}"
                          : "Quality: ${job.quality} • Syncing frames & beats..."),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
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
                        "Status: Ready to play and export",
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
                  child: RetroMechanicalButton(
                    variant: RetroButtonVariant.play,
                    height: 44,
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
                  ),
                ),
                const SizedBox(width: 6),
                // 2. SAVE TO GALLERY (DOWNLOAD)
                Expanded(
                  child: RetroMechanicalButton(
                    variant: RetroButtonVariant.download,
                    height: 44,
                    onTap: () => ExportService.saveToGallery(
                      context,
                      videoPath: job.videoPath!,
                      templateName: job.templateName,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // 3. SOCIAL SHARE
                Expanded(
                  child: RetroMechanicalButton(
                    variant: RetroButtonVariant.share,
                    height: 44,
                    onTap: () => ExportService.shareReel(
                      context,
                      videoPath: job.videoPath!,
                      templateName: job.templateName,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // 4. DELETE
                Expanded(
                  child: RetroMechanicalButton(
                    variant: RetroButtonVariant.delete,
                    height: 44,
                    onTap: () => qm.deleteJob(job.id),
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
                  job.error ?? (job.status == "CANCELLED" ? "Render cancelled by user" : "Incomplete or failed render"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.vuRed),
                ),
              ],
            ),
          ),
          RetroMechanicalButton(
            variant: RetroButtonVariant.delete,
            height: 36,
            onTap: () => _cancelAndRemoveJob(job.id),
          ),
        ],
      ),
    );
  }
}