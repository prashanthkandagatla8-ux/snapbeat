import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, SystemNavigator, PlatformException;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart' show DateFormat;
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_config.dart';
import '../../models/models.dart';
import '../../models/sound_track.dart';
import '../../services/ad_manager.dart';
import '../../services/queue_manager.dart';
import '../../services/api_service.dart';

import '../../theme/app_colors.dart';
import '../../services/subscription_manager.dart';
import '../components/retro_pro_badge.dart';
import '../components/web_audio_deck.dart';
import '../components/interactive_waveform.dart';
import '../components/snaps_reorder_strip.dart';
import '../components/pro_controls_card.dart';
import '../components/master_action_deck.dart';
import '../components/video_preview_dialog.dart';
import '../components/sound_library_dialog.dart';
import '../components/privacy_policy_dialog.dart';
import '../components/metal_chassis_scaffold.dart';
import '../components/retro_subscription_dialog.dart';
import '../components/retro_metal_panel.dart';
import '../components/tactile_action_button.dart';
import '../components/account_plan_dialog.dart';

class HomeScreen extends StatefulWidget {
  final String initialTab;
  final String initialRenderMode;
  final File? initialMusic;
  final String? initialMusicTitle;
  final List<PhotoItem>? initialPhotos;
  final bool fromShowcase;

  static ui.Image? logoUiImage;
  static ui.Image? wordmarkUiImage;

  const HomeScreen({
    super.key,
    this.initialTab = "home",
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
  // Unified Workflow State
  bool _isManualRenderMode = false;
  bool _isTitleCardEnabled = true;
  String _titleAudioTiming = 'with_music'; // 'with_music' (Overlay on Audio Intro) vs 'outside_track' (Audio Starts After Title)
  String _titleBgSurface = 'video_overlay'; // 'video_overlay' (Over Photo/Video) vs 'studio_bg' (Solid Studio Background)
  String _titleAnimationStyle = 'fade'; // 'fade', 'kinetic_zoom', 'glitch', 'typewriter', 'slide'
  double _titleDurationSec = 2.5; // 1.0 to 5.0 seconds

  final TextEditingController _subtitleTextController = TextEditingController(text: "Moments in Motion · 2026");

  final qm = QueueManager.instance;
  final api = ApiService.instance;
  final sm = SubscriptionManager.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  String? _focusedJobId;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerPositionSubscription;
  bool _isSubmittingRender = false;

  String _currentTab = "home"; // "home", "photos", "audio_deck", "title", "render", "queue"
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
    bool? isManualMode,
    bool? isTitleCardEnabled,
    String? titleAudioTiming,
    String? titleBgSurface,
    String? titleAnimationStyle,
    double? titleDurationSec,
  }) {
    if (isManualMode != null) _isManualRenderMode = isManualMode;
    if (isTitleCardEnabled != null) _isTitleCardEnabled = isTitleCardEnabled;
    if (titleAudioTiming != null) _titleAudioTiming = titleAudioTiming;
    if (titleBgSurface != null) _titleBgSurface = titleBgSurface;
    if (titleAnimationStyle != null) _titleAnimationStyle = titleAnimationStyle;
    if (titleDurationSec != null) _titleDurationSec = titleDurationSec;
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
  String _selectedQuality = "1080p";
  String _renderSpeed = "queued"; // 'instant' (serverless) or 'queued'
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
  double _currentPlaybackSeconds = 0.0;

  // Title Intro
  bool _enableTitle = false;
  String _titleText = "Summer Memories";
  late final TextEditingController _titleTextController;
  String _titleBg = "black";
  int _titleDuration = 2;
  String _titleFont = "great_vibes";
  String _titleFontSize = "large";
  String _titleStyle = "classic";
  String _titleFrame = "none";
  String _titleAudio = "before_audio";

  // Creative Motion Effects (Manual Mode - Bursts, Teaser, Drop-It)
  bool _enableBurst = true;
  bool _enableTeaser = true;
  bool _enableDropIt = true;



  void _showNotice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F1218),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 95),
        duration: const Duration(milliseconds: 2200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x35FFFFFF), width: 1),
        ),
        elevation: 8,
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
    final hasActive = qm.activeJobs.isNotEmpty;
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
            Icon(Icons.delete_sweep_rounded, color: AppColors.primaryDarkText, size: 22),
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
        content: Text(
          hasActive
              ? "Remove completed and finished reels from queue history? Your active render in progress will continue safely."
              : "Remove completed reel history from the queue?",
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vuRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              qm.clearCompleted();
              if (_focusedJobId != null && !qm.jobs.any((j) => j.id == _focusedJobId)) {
                _focusedJobId = null;
              }
              setState(() {});
            },
            child: const Text("CLEAR COMPLETED", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
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

  void _openAccountPlanDialog() {
    AccountPlanDialog.show(
      context,
      onReplayShowcase: _showShowcaseWelcomeModal,
    );
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
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
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
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/snapbeat_app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.pianoBlack,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0x30FFFFFF)),
                    ),
                    child: const Text(
                      'WELCOME TO SNAPBEAT STUDIO',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
                      icon: Icons.library_music_rounded,
                      step: 'STEP 1',
                      title: 'Pick Soundtrack',
                      desc: 'Select from built-in beat library or import your own track.',
                    ),
                    const Divider(color: AppColors.chassisBevelDark, height: 16),
                    _buildWelcomeStepRow(
                      icon: Icons.photo_library_rounded,
                      step: 'STEP 2',
                      title: 'Curate Photos',
                      desc: 'Add 2 or more photos from gallery or try sample photos.',
                    ),
                    const Divider(color: AppColors.chassisBevelDark, height: 16),
                    _buildWelcomeStepRow(
                      icon: Icons.bolt_rounded,
                      step: 'STEP 3',
                      title: 'Export Beat Reel',
                      desc: 'Instant beat-synced 1080p Master render with motion physics.',
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
                      colors: [Color(0xFFF2F4F6), Color(0xFFE1E5E9)],
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
                      Icon(Icons.explore_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'EXPLORE STUDIO',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Colors.white,
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
            color: AppColors.pianoBlack,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x30FFFFFF)),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
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
                      color: AppColors.primaryDarkText,
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
    sm.init();
    AdManager.instance.init();
    _currentTab = widget.initialTab;
    _renderMode = widget.initialRenderMode;
    _titleTextController = TextEditingController(text: _titleText);
    _titleTextController.addListener(() {
      _titleText = _titleTextController.text;
    });
    if (widget.fromShowcase) {
      _selectedTemplate = 'pendulum';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showShowcaseWelcomeModal();
      });
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
      _loadDefaultSampleTrack();
    }
    if (widget.initialPhotos != null) {
      _photos.addAll(widget.initialPhotos!);
    }
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          _currentPlaybackSeconds = _audioStart;
        });
      }
    });
    _playerPositionSubscription = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _currentPlaybackSeconds = pos.inMilliseconds / 1000.0;
        });
      }
      if (_isPlayingAudio && pos.inMilliseconds >= (_audioEnd * 1000).toInt()) {
        _audioPlayer.pause();
        if (mounted) setState(() => _isPlayingAudio = false);
      }
    });
    qm.addListener(_onQueueChanged);
    _initData();
  }

  Future<void> _initData() async {
    await qm.init();
    
    // Default Auto Mode & Mode Preference Persistence
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('snapbeat_preferred_render_mode');
    if (savedMode == 'manual') {
      if (sm.isPro) {
        _isManualRenderMode = true;
      } else {
        _isManualRenderMode = false;
        await prefs.setString('snapbeat_preferred_render_mode', 'auto');
      }
    } else {
      _isManualRenderMode = false;
      await prefs.setString('snapbeat_preferred_render_mode', 'auto');
    }

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
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      );
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
    } catch (e) {
      debugPrint("Audio picker error: $e");
      if (mounted) {
        _showNotice("Unable to load selected audio. Please ensure it is a standard non-DRM MP3, WAV, or M4A file.");
      }
    }
  }

  Future<void> _pickMusicFromVideo() async {
    try {
      final picker = ImagePicker();
      final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null && pickedVideo.path.isNotEmpty) {
        final videoFile = File(pickedVideo.path);
        final fileName = p.basename(pickedVideo.path);
        double dur = 30.0;

        try {
          final tempController = VideoPlayerController.file(videoFile);
          await tempController.initialize();
          final d = tempController.value.duration;
          if (d.inSeconds > 0) {
            dur = d.inSeconds.toDouble();
          }
          await tempController.dispose();
        } catch (_) {
          try {
            await _audioPlayer.setSource(DeviceFileSource(videoFile.path));
            final d = await _audioPlayer.getDuration();
            if (d != null && d.inSeconds > 0) {
              dur = d.inSeconds.toDouble();
            }
          } catch (_) {}
        }

        if (!mounted) return;
        setState(() {
          _selectedMusic = videoFile;
          _selectedMusicTitle = 'Video Audio: $fileName';
          _audioDuration = dur;
          _audioStart = 0.0;
          _audioEnd = dur;
        });

        _showNotice('Extracted audio from video: $fileName (${dur.toInt()}s)');
      }
    } catch (e) {
      _showNotice('Failed to extract audio from video: $e');
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

  void _stopAudio() async {
    await _audioPlayer.stop();
    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
      _currentPlaybackSeconds = _audioStart;
    });
  }

  void _onSelectBuiltInTrack(SoundTrack track) async {
    await _audioPlayer.pause();
    final file = await track.getCachedFile();
    if (!mounted) return;
    setState(() {
      _selectedMusic = file;
      _selectedMusicTitle = '${track.title} (${track.bpm})';
      _audioDuration = track.durationSeconds;
      _audioStart = 0.0;
      _audioEnd = track.durationSeconds;
      _currentPlaybackSeconds = 0.0;
      _isPlayingAudio = false;
    });
  }

  String? _getBpmFromTitle() {
    final match = RegExp(r'(\d+)\s*BPM', caseSensitive: false).firstMatch(_selectedMusicTitle);
    if (match != null) {
      return match.group(1);
    }
    final digitMatch = RegExp(r'(\d+)').firstMatch(_selectedMusicTitle);
    return digitMatch?.group(1);
  }

  String? _getGenreForSelected() {
    for (final t in SoundTrack.builtInLibrary) {
      if (_selectedMusicTitle.contains(t.title)) {
        return t.genre;
      }
    }
    return null;
  }

  Future<void> _pickPhotos() async {
    final maxAllowed = maxPhotosForTrack;
    if (_photos.length >= maxAllowed) {
      _showNotice("Maximum $maxAllowed photos already reached for this track.");
      return;
    }

    try {
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
    } on PlatformException catch (e) {
      debugPrint("Photo picker permission error: $e");
      if (mounted) {
        _showNotice("Photo access is needed to choose pictures. Please enable it in Settings.");
      }
    } catch (e) {
      debugPrint("Error picking photos: $e");
    }
  }

  void _promptRenameReel(QueueJobItem job) {
    final controller = TextEditingController(text: job.customName ?? job.templateName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.chassisBevelLight, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: AppColors.primaryDarkText, size: 22),
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
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
              borderSide: const BorderSide(color: AppColors.pianoBlack, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pianoBlack,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0x30FFFFFF), width: 1),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                qm.renameJob(job.id, newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReel(QueueJobItem job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
        content: Text(
          "Are you sure you want to permanently delete \"${job.displayName}\"?\n\nThis video file will be permanently removed from your device storage.",
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vuRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              qm.deleteJob(job.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(" Deleted \"${job.displayName}\""),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSamplePhotos() async {
    if (_selectedMusic == null) {
      await _loadDefaultSampleTrack();
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
      await _executeRender(isInstant: false);
    } finally {
      _isSubmittingRender = false;
    }
  }

  // Reserved for instant render & credits pack workflow (temporarily held):
  // void _showRenderChoiceDialog() { ... }

  Future<void> _executeRender({required bool isInstant}) async {
    if (_selectedMusic == null) {
      _showNotice("Step 1: Please select a music track first.");
      return;
    }
    if (_photos.isEmpty) {
      _showNotice("Step 2: Please select photos before rendering.");
      return;
    }

    final isPro = sm.isPro;
    if (!isPro) {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString('free_render_date') ?? '';
      int count = prefs.getInt('free_render_count') ?? 0;
      if (lastDate != todayStr) {
        count = 0;
        await prefs.setString('free_render_date', todayStr);
        await prefs.setInt('free_render_count', 0);
      }
      if (count >= 3) {
        if (mounted) {
          RetroSubscriptionDialog.show(
            context,
            reason: "Daily limit of 3 free renders reached for today. Upgrade to VIP for unlimited daily exports!",
          );
        }
        return;
      }
      
    }

    String tId;
    String tDisplayName;
    if (_renderMode == "auto") {
      tId = "mix";
      tDisplayName = "Dynamic Auto Mix";
    } else {
      tId = _selectedTemplate;
      if (tId == "mix") {
        tDisplayName = "Dynamic Mix";
      } else {
        final matching = BeatTemplate.allTemplates.where((t) => t.id == tId).toList();
        tDisplayName = matching.isNotEmpty ? matching.first.name : "Beat Cut";
      }
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
    
    final qualitySnapshot = sm.isPro ? _selectedQuality : "360p";
    // Pro subscribers have watermarks removed; Free videos have watermark
    final shouldWatermark = !isPro;
    // Pro subscribers get fast priority queue; Free users use standard queue
    final renderTypeSnapshot = isPro ? "priority_queue" : "free_queue";
    final entitlementTokenSnapshot = isPro ? sm.signedEntitlementToken : null;
    final audioStartSnapshot = _audioStart.toInt();
    final audioEndSnapshot = _audioEnd.toInt();
    final enteredTitle = _titleTextController.text.trim();
    final stateTitle = _titleText.trim();
    final effectiveTitle = enteredTitle.isNotEmpty
        ? enteredTitle
        : (stateTitle.isNotEmpty ? stateTitle : "SnapBeat");
    final titleTextSnapshot = _enableTitle ? effectiveTitle : null;
    final titleBgSnapshot = _titleBg;
    final titleDurationSnapshot = _titleDuration;
    final titleFontSnapshot = _titleFont;
    final titleFontSizeSnapshot = _titleFontSize;
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
      renderType: renderTypeSnapshot,
      entitlementToken: entitlementTokenSnapshot,
      audioStart: audioStartSnapshot,
      audioEnd: audioEndSnapshot,
      titleText: titleTextSnapshot,
      titleBg: titleBgSnapshot,
      titleDuration: titleDurationSnapshot,
      titleFont: titleFontSnapshot,
      titleFontSize: titleFontSizeSnapshot,
      titleStyle: titleStyleSnapshot,
      titleFrame: titleFrameSnapshot,
      titleAudio: titleAudioSnapshot,
      enableBurst: _renderMode == "pro" ? _enableBurst : true,
      enableTeaser: _renderMode == "pro" ? _enableTeaser : true,
      dropIt: _renderMode == "pro" ? _enableDropIt : false,
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
    String? renderType,
    String? entitlementToken,
    required int audioStart,
    required int audioEnd,
    String? titleText,
    String? titleBg,
    int? titleDuration,
    String? titleFont,
    String? titleFontSize,
    String? titleStyle,
    String? titleFrame,
    String? titleAudio,
    bool enableBurst = true,
    bool enableTeaser = true,
    bool dropIt = false,
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
        preview: false,
        isInstant: isInstant,
        autoArrange: _arrangementMode == "auto",
        renderType: renderType,
        entitlementToken: entitlementToken,
        audioStart: audioStart,
        audioEnd: audioEnd,
        titleText: titleText,
        titleBg: titleBg,
        titleDuration: titleDuration,
        titleFont: titleFont,
        titleFontSize: titleFontSize,
        titleStyle: titleStyle,
        titleFrame: titleFrame,
        titleAudio: titleAudio,
        enableBurst: enableBurst,
        enableTeaser: enableTeaser,
        dropIt: dropIt,
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
      
      if (!sm.isPro) {
        final prefs = await SharedPreferences.getInstance();
        int count = prefs.getInt('free_render_count') ?? 0;
        await prefs.setInt('free_render_count', count + 1);
      }


      _showNotice('Reel ready! Tap Play to preview and save to Photos.');


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
          bottom: false,
          child: Stack(
          children: [
            Column(
              children: [
                // Top Header (Clean Transparent Wordmark on Ceramic Floor, per Spec Section 5)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Wordmark left-aligned with BEAT-SYNCED REELS subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (HomeScreen.wordmarkUiImage != null)
                                RawImage(
                                  image: HomeScreen.wordmarkUiImage,
                                  height: 26,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                )
                              else
                                Image.asset(
                                  'assets/images/snapbeat_wordmark_black.png',
                                  height: 26,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F131C),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0x30FFFFFF), width: 0.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'STUDIO',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'BEAT-SYNCED PHOTO REELS',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.8,
                              color: AppColors.textInkTertiary,
                            ),
                          ),
                        ],
                      ),

                      // Right Action Group: Pro Badge and Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RetroProBadge(onTap: () => RetroSubscriptionDialog.show(context)),
                          const SizedBox(width: 8),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111722),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0x18FFFFFF), width: 1),
                              boxShadow: AppColors.darkHardwareShadow,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 17),
                              tooltip: 'Account & Plan',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _openAccountPlanDialog,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111722),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0x18FFFFFF), width: 1),
                              boxShadow: AppColors.darkHardwareShadow,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                              tooltip: 'Privacy Policy',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => PrivacyPolicyDialog.show(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Console Deck with Easing Page Transitions
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
                        child: child,
                      );
                    },
                    child: ListView(
                      key: ValueKey(_currentTab),
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 160),
                      children: [
                      if (_currentTab == "music" || _currentTab == "home") ...[
                        // UNIFIED HOME STUDIO VIEW
                        _buildUnifiedHomeView(),
                      ] else if (_currentTab == "audio_deck") ...[
                        // STAGE 1: MUSIC FIRST - Web Audio Console Deck
                        WebAudioConsoleDeck(
                          isPlaying: _isPlayingAudio,
                          trackTitle: _selectedMusicTitle,
                          currentSeconds: _currentPlaybackSeconds,
                          totalSeconds: _audioDuration,
                          bpm: _getBpmFromTitle(),
                          genre: _getGenreForSelected(),
                          isCustom: _selectedMusic != null && !_selectedMusicTitle.contains('BPM'),
                          onTogglePlay: _togglePlayAudio,
                          onStop: _stopAudio,
                          onPickAudio: _pickMusic,
                          onPickVideoAudio: _pickMusicFromVideo,
                          onOpenLibrary: () => SoundLibraryDialog.show(
                            context: context,
                            currentTrackTitle: _selectedMusicTitle,
                            onSelectTrack: _onSelectBuiltInTrack,
                          ),
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

                        ],

                        // Music guidance prompt when no track is selected
                        if (_selectedMusic == null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: AppColors.luxDarkCardGradient,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.chassisBevelLight.withValues(alpha: 0.6)),
                                boxShadow: AppColors.luxCardShadow,
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textMuted),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Loading default soundtrack... Tap a track in the library above to select it.",
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
                        // Photo progression handled exclusively by persistent MasterActionDeck
                      ] else if (_currentTab == "title") ...[
                        if (_selectedMusic == null)
                          _buildGatedCard(
                            icon: Icons.library_music_rounded,
                            title: "MUSIC REQUIRED FIRST",
                            description: "Please select a music track in Step 1 before customizing intro title cards.",
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
                        else if (_photos.isEmpty || _photos.length < 2)
                          _buildGatedCard(
                            icon: Icons.photo_library_rounded,
                            title: "PHOTOS REQUIRED FIRST",
                            description: "Please select at least 2 photos in Step 2 before customizing intro title cards.",
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
                          _buildTitleStageView(),
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
              ),

                // Bottom Action Deck (Matching Luxury 2-Tier Reference Layout)
                MasterActionDeck(
                  currentMode: _currentTab,
                  onSelectMode: (tab) {
                    if (_isPlayingAudio && tab != 'music' && tab != 'audio_deck') {
                      _audioPlayer.pause();
                      _isPlayingAudio = false;
                    }
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                    setState(() {
                      _currentTab = tab;
                    });
                  },
                  isPhotosEnabled: _selectedMusic != null,
                  isTitleEnabled: _selectedMusic != null && _photos.length >= 2,
                  isRenderEnabled: _selectedMusic != null && _photos.length >= 2,
                  isManualMode: _isManualRenderMode,
                  onToggleManualMode: (manual) async {
                    if (manual && !sm.isPro) {
                      RetroSubscriptionDialog.show(context, reason: "Manual Customization Mode is a PRO Feature. Upgrade to Pro to customize individual templates, motion dynamics, advanced typography, and duration.");
                      return;
                    }
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('snapbeat_preferred_render_mode', manual ? 'manual' : 'auto');

                    setState(() {
                      _isManualRenderMode = manual;
                      if (!manual && _currentTab == 'render') {
                        _currentTab = 'title';
                      }
                    });
                  },
                  renderSpeed: _renderSpeed,
                  onToggleRenderSpeed: (speed) {
                    if (speed == 'instant' && !sm.isPro) {
                      RetroSubscriptionDialog.show(
                        context,
                        reason: "Instant Serverless Render is a PRO feature. Upgrade to Pro to enable instant GPU rendering.",
                      );
                      return;
                    }
                    setState(() => _renderSpeed = speed);
                  },
                  creditBalanceDisplay: sm.creditBalanceDisplay,
                  onTapCredits: _openAccountPlanDialog,
                  stageTag: _currentTab == 'photos'
                      ? '${_photos.length} PHOTOS'
                      : (_currentTab == 'audio_deck'
                          ? '${_getBpmFromTitle()} BPM'
                          : (_currentTab == 'title'
                              ? 'TITLE INTRO'
                              : null)),
                  onBackToHome: () {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0.0);
                    }
                    setState(() => _currentTab = 'home');
                  },
                  actionButtonText: _getActionButtonText(),
                  actionButtonSubtitle: _getActionButtonSubtitle(),
                  actionIcon: _getActionIcon(),
                  isActionEnabled: _isActionEnabled(),
                  onActionPressed: _handleMasterAction,
                  activeJobsCount: qm.activeJobs.length,
                ),
              ],
            ),
          ],
        ),
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
              backgroundColor: AppColors.pianoBlack,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0x30FFFFFF), width: 1),
              ),
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
        // 1. Studio Header Card (Shining Piano Black)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1F2128), Color(0xFF101114), Color(0xFF08090B)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x35FFFFFF), width: 1.0),
              boxShadow: const [
                BoxShadow(color: Color(0x80000000), offset: Offset(0, 4), blurRadius: 12),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07080A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x30FFFFFF), width: 1.0),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "4. STUDIO RENDER SPECIFICATIONS",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Color(0xFFF2F4F8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Custom aspect ratio, resolution, motion dynamic and video quality",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5,
                          color: Color(0xFF9094A0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Pro Manual Controls
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
          titleFontSize: _titleFontSize,
          onSelectTitleFontSize: (s) => setState(() => _titleFontSize = s),
          titleStyle: _titleStyle,
          onSelectTitleStyle: (s) => setState(() => _titleStyle = s),
          titleFrame: _titleFrame,
          onSelectTitleFrame: (fr) => setState(() => _titleFrame = fr),
          titleAudio: _titleAudio,
          onSelectTitleAudio: (a) => setState(() => _titleAudio = a),
          representativePhoto: _photos.isNotEmpty ? File(_photos.first.path) : null,
          isPro: sm.isPro,
          enableBurst: _enableBurst,
          onToggleBurst: (v) => setState(() => _enableBurst = v),
          enableTeaser: _enableTeaser,
          onToggleTeaser: (v) => setState(() => _enableTeaser = v),
          enableDropIt: _enableDropIt,
          onToggleDropIt: (v) => setState(() => _enableDropIt = v),
        ),

        // 3. Job Summary Badge
        _buildJobSummaryCard(),
        const SizedBox(height: 16),
      ],
    );
  }


  Widget _buildJobSummaryCard() {
    final durationSec = (_audioEnd > _audioStart && _audioEnd <= _audioDuration)
        ? (_audioEnd - _audioStart).toInt()
        : _audioDuration.toInt();
    final isMix = (_renderMode == "auto") || (_renderMode == "manual" && _selectedTemplate == "mix");
    final styleName = isMix ? "DYNAMIC MIX" : _selectedTemplate.toUpperCase();

    return RetroMetalPanel(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.iridescentGradient)),
                  SizedBox(width: 6),
                  Text(
                    "JOB SPECIFICATIONS",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: AppColors.textEngraved,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.chassisBevelDark, width: 0.8),
                ),
                child: Text(
                  _renderMode == "auto" ? "AUTO PRESET" : (isMix ? "MIX ENGINE" : "MANUAL CONFIG"),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.primaryDarkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 1: Soundtrack & Duration
          Row(
            children: [
              _buildSummaryPill(
                Icons.music_note_rounded,
                _selectedMusicTitle.isEmpty ? "Track" : _selectedMusicTitle,
                subtitle: "AUDIO",
              ),
              const SizedBox(width: 6),
              _buildSummaryPill(
                Icons.timer_outlined,
                "${durationSec}s length",
                subtitle: "DURATION",
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Photo count & Motion style
          Row(
            children: [
              _buildSummaryPill(
                Icons.photo_library_outlined,
                "${_photos.length} ${_photos.length == 1 ? 'photo' : 'photos'}",
                subtitle: "MEDIA",
              ),
              const SizedBox(width: 6),
              _buildSummaryPill(
                isMix ? Icons.shuffle_rounded : Icons.auto_awesome_mosaic_rounded,
                styleName,
                subtitle: "STYLE",
                highlight: isMix,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 3: Aspect ratio & Quality + Watermark status
          Row(
            children: [
              _buildSummaryPill(
                Icons.video_settings_rounded,
                "$_selectedAspectRatio · ${sm.isPro ? _selectedQuality : '360p (Free)'}",
                subtitle: "OUTPUT",
              ),
              const SizedBox(width: 6),
              _buildSummaryPill(
                !sm.shouldWatermark ? Icons.verified_rounded : Icons.branding_watermark_rounded,
                !sm.shouldWatermark ? "NONE (PRO)" : "SNAPBEAT",
                subtitle: "WATERMARK",
                highlight: sm.shouldWatermark,
                trailingAffordance: sm.shouldWatermark ? "UPGRADE" : null,
                onTap: sm.shouldWatermark ? () => RetroSubscriptionDialog.show(context) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(
    IconData icon,
    String text, {
    String? subtitle,
    bool highlight = false,
    String? trailingAffordance,
    VoidCallback? onTap,
  }) {
    final pillWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? AppColors.pianoBlack : AppColors.panelInset,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlight ? const Color(0x30FFFFFF) : AppColors.chassisBevelDark.withValues(alpha: 0.5),
          width: highlight ? 1.2 : 0.8,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: highlight ? const Color(0xFFFFFFFF) : AppColors.primaryDarkText),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 6.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: highlight ? const Color(0xFFFFFFFF) : AppColors.textMuted,
                    ),
                  ),
                ],
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: highlight ? const Color(0xFFF2F4F6) : AppColors.textEngraved,
                  ),
                ),
              ],
            ),
          ),
          if (trailingAffordance != null) ...[
            const SizedBox(width: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.pianoBlack,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0x30FFFFFF)),
                boxShadow: const [
                  BoxShadow(color: Color(0x30FFFFFF), blurRadius: 2),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingAffordance,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: pillWidget,
        ),
      );
    }

    return Expanded(child: pillWidget);
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
                backgroundColor: AppColors.pianoBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0x30FFFFFF), width: 1),
                ),
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
            gradient: AppColors.luxDarkCardGradient,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.chassisBevelLight.withValues(alpha: 0.6)),
            boxShadow: AppColors.luxCardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.iridescentGradient)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "QUEUE",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (jobs.any((j) {
                    final s = j.status.toLowerCase();
                    return s != 'processing' && s != 'rendering' && s != 'queued' && s != 'uploading';
                  })) ...[
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
                              "CLEAR COMPLETED",
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
                        color: AppColors.pianoBlack,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x30FFFFFF)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            "NEW REEL",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
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

        // Testing Queue Notice Banner (active during closed beta) - Hidden on iOS
        if (AppConfig.showBetaFeatures && activeJobs.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A16).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x30FFFFFF), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.5),
                  child: Icon(Icons.info_outline_rounded, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: "Queue Notice: ",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextSpan(
                          text: "Free renders process sequentially (1-at-a-time) in a shared queue. Upgrade to Pro for instant priority renders.",
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
          color: isFocused ? AppColors.pianoBlack : const Color(0xFFCBD5E1),
          width: isFocused ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                    border: Border.all(color: const Color(0x30FFFFFF), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, size: 10, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "IN QUEUE · POSITION #${job.queuePosition > 0 ? job.queuePosition : 1}",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
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
              children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.iridescentGradient)),
                    const SizedBox(width: 6),
                Text(
                  "CURRENT RENDER IN PROGRESS",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.primaryDarkText,
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
                      child: CircularProgressIndicator(color: AppColors.primaryDarkText, strokeWidth: 2),
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
                      color: const Color(0xFF090B0F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x30FFFFFF), width: 1),
                    ),
                    child: Text(
                      job.queuePosition > 0 || job.status.toUpperCase() == "QUEUED"
                          ? "QUEUE #${job.queuePosition > 0 ? job.queuePosition : 1}"
                          : "$percent%",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
              color: isFocused ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF),
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
                      ? "Queue Position #${job.queuePosition > 0 ? job.queuePosition : 1} · Waiting for active render..."
                      : (job.stage != null && job.stage!.isNotEmpty
                          ? "Quality: ${job.quality} · ${job.stage}"
                          : "Quality: ${job.quality} · Syncing frames & beats..."),
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
    return RetroMetalPanel(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      padding: const EdgeInsets.all(14),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.displayName.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.textEngraved,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _promptRenameReel(job),
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.panelInset,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.chassisBevelLight, width: 0.8),
                            ),
                            child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Resolution: ${job.quality.toUpperCase()}  · ${DateFormat('MMM d, yyyy  · hh:mm a').format(job.createdAt)}",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (job.videoPath != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: AppColors.vuGreen),
                          const SizedBox(width: 4),
                          Text(
                            "Ready to Preview & Save",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.vuGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (job.videoPath == null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.textMuted),
                  tooltip: 'Delete reel',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDeleteReel(job),
                ),
            ],
          ),

          // Row 2: Action Buttons placed UNDER the video details (PLAY, SHARE, DELETE)
          if (job.videoPath != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.chassisBevelLight, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TactileActionButton.primary(
                    height: 44,
                    label: "PLAY REEL",
                    icon: Icons.play_arrow_rounded,
                    onTap: () async {
                      await _audioPlayer.pause();
                      if (!mounted) return;
                      setState(() => _isPlayingAudio = false);
                      VideoPreviewDialog.show(
                        context,
                        videoPath: job.videoPath!,
                        templateName: job.templateName,
                        customName: job.displayName,
                        quality: job.quality,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TactileActionButton.destructive(
                  height: 44,
                  label: "DELETE",
                  icon: Icons.delete_outline_rounded,
                  onTap: () => _confirmDeleteReel(job),
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
          Tooltip(
            message: 'Delete reel',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _cancelAndRemoveJob(job.id),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.metalDeepCavity,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.chassisBevelDark,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildAdvancedTitleSuite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        const Text('FONT FAMILY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF090B0F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x25FFFFFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _titleFont,
              isExpanded: true,
              dropdownColor: const Color(0xFF1B1C22),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              items: [
                'great_vibes', 'allura', 'alex_brush', 'bodoni_moda', 'cormorant_garamond',
                'cinzel', 'serif', 'clean', 'typewriter', 'playful', 'impact'
              ].map((String value) {
                
                TextStyle style = const TextStyle(color: Colors.white, fontSize: 12);
                try {
                  switch (value) {
                    case 'great_vibes': style = GoogleFonts.greatVibes(color: Colors.white, fontSize: 14); break;
                    case 'allura': style = GoogleFonts.allura(color: Colors.white, fontSize: 14); break;
                    case 'alex_brush': style = GoogleFonts.alexBrush(color: Colors.white, fontSize: 14); break;
                    case 'bodoni_moda': style = GoogleFonts.bodoniModa(color: Colors.white, fontSize: 12); break;
                    case 'cormorant_garamond': style = GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 12); break;
                    case 'cinzel': style = GoogleFonts.cinzel(color: Colors.white, fontSize: 12); break;
                    case 'serif': style = GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 12); break;
                    case 'clean': style = GoogleFonts.inter(color: Colors.white, fontSize: 12); break;
                    case 'typewriter': style = GoogleFonts.courierPrime(color: Colors.white, fontSize: 12); break;
                    case 'playful': style = GoogleFonts.fredoka(color: Colors.white, fontSize: 12); break;
                    case 'impact': style = GoogleFonts.oswald(color: Colors.white, fontSize: 12); break;
                  }
                } catch (_) {}
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: style),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _titleFont = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text('FONT SIZE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 5),
        Row(
          children: ['small', 'medium', 'large', 'xlarge'].map((size) {
            final isSelected = _titleFontSize == size;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _titleFontSize = size),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF07080A) : const Color(0xFF030405),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isSelected ? const Color(0x60FFFFFF) : AppColors.chassisBevelLight, width: isSelected ? 1.5 : 1.0),
                  ),
                  child: Text(size.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('TITLE STYLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['classic', 'neon', 'cinematic', '3d_retro', 'badge'].map((style) {
            final isSelected = _titleStyle == style;
            return GestureDetector(
              onTap: () => setState(() => _titleStyle = style),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF07080A) : const Color(0xFF030405),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isSelected ? const Color(0x60FFFFFF) : AppColors.chassisBevelLight, width: isSelected ? 1.5 : 1.0),
                ),
                child: Text(style.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('FRAME BORDER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['none', 'box', 'double_line', 'bracket', 'viewfinder'].map((frame) {
            final isSelected = _titleFrame == frame;
            return GestureDetector(
              onTap: () => setState(() => _titleFrame = frame),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF07080A) : const Color(0xFF030405),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isSelected ? const Color(0x60FFFFFF) : AppColors.chassisBevelLight, width: isSelected ? 1.5 : 1.0),
                ),
                child: Text(frame.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const Text('BACKGROUND COLOR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['black', '#FF0000', '#0000FF', 'video'].map((bg) {
              final isSelected = _titleBg == bg;
              return GestureDetector(
                onTap: () => setState(() => _titleBg = bg),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF141720) : AppColors.panelInset,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0x60FFFFFF) : AppColors.chassisBevelLight, width: isSelected ? 1.5 : 1.0),
                  ),
                  child: Text(bg == 'video' ? 'VIDEO OVERLAY' : bg.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        const Text('DURATION (1-6s)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        Slider(
          value: _titleDuration.toDouble(),
          min: 1.0,
          max: 6.0,
          divisions: 5,
          label: 's',
          onChanged: (val) => setState(() => _titleDuration = val.toInt()),
        ),
        const SizedBox(height: 14),
        const Text('AUDIO TIMING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 5),
        Row(
          children: ['before_audio', 'with_audio'].map((audio) {
            final isSelected = _titleAudio == audio;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _titleAudio = audio),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF07080A) : const Color(0xFF030405),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isSelected ? const Color(0x60FFFFFF) : AppColors.chassisBevelLight, width: isSelected ? 1.5 : 1.0),
                  ),
                  child: Text(audio.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  // =========================================================================
  // UNIFIED HOME STUDIO (Option 3: Adaptive Hero + Core Trio + Pro Modals)
  // =========================================================================

  Widget _buildUnifiedHomeView() {
    final bool hasAssets = _photos.isNotEmpty && _selectedMusic != null;
    final int photoCount = _photos.length;
    final String trackSubtitle = _selectedMusic != null
        ? "${_getBpmFromTitle()} BPM · ${_getGenreForSelected()}"
        : "Tap to audition and select music";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. OPTION 3: ADAPTIVE HERO STAGE (Top Section)
        _buildAdaptiveHeroStage(hasAssets),

        const SizedBox(height: 16),

        // 2. THE CORE INGREDIENTS TRIO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.chipBorder, width: 1),
              boxShadow: AppColors.softRaisedShadow,
            ),
            child: Column(
              children: [
                // Photos Row
                _buildIngredientRow(
                  icon: Icons.photo_library_outlined,
                  title: "Photos",
                  subtitle: photoCount > 0 ? "$photoCount Photos Selected" : "Tap to select photos",
                  valueTag: photoCount > 0 ? "$photoCount loaded" : "Required",
                  isConfigured: photoCount > 0,
                  onTap: () {
                    setState(() => _currentTab = 'photos');
                  },
                ),
                Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),

                // Music Row
                _buildIngredientRow(
                  icon: Icons.music_note_rounded,
                  title: "Soundtrack",
                  subtitle: trackSubtitle,
                  valueTag: _selectedMusic != null ? "${_getBpmFromTitle()} BPM" : "Required",
                  isConfigured: _selectedMusic != null,
                  onTap: () {
                    setState(() => _currentTab = 'audio_deck');
                  },
                ),
                Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),

                // Title Intro Card Row
                _buildIngredientRow(
                  icon: Icons.title_rounded,
                  title: "Title Intro Card",
                  subtitle: _isTitleCardEnabled ? (_titleTextController.text.isNotEmpty ? _titleTextController.text : "Enabled") : "Disabled",
                  valueTag: _isTitleCardEnabled ? "ON" : "OFF",
                  isConfigured: _isTitleCardEnabled,
                  onTap: () {
                    setState(() => _currentTab = 'title');
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 3. MOTION MODE TOGGLE (Auto Free vs Manual Pro)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MOTION ENGINE",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.textInkTertiary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Auto Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isManualRenderMode = false;
                        });
                        SharedPreferences.getInstance().then((p) => p.setString('snapbeat_preferred_render_mode', 'auto'));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !_isManualRenderMode ? const Color(0xFF090B0F) : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !_isManualRenderMode ? AppColors.pureWhite : AppColors.chipBorder,
                            width: !_isManualRenderMode ? 1.5 : 1,
                          ),
                          boxShadow: !_isManualRenderMode ? AppColors.darkHardwareShadow : AppColors.softRaisedShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 16, color: !_isManualRenderMode ? Colors.white : AppColors.textInkBlack),
                                    const SizedBox(width: 4),
                                    Text(
                                      "AUTO",
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: !_isManualRenderMode ? Colors.white : AppColors.textInkBlack,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: !_isManualRenderMode ? const Color(0x30FFFFFF) : const Color(0x15000000),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "FREE",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: !_isManualRenderMode ? Colors.white : AppColors.textInkTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "SnapBeat chooses the best style for you.",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: !_isManualRenderMode ? const Color(0xB3FFFFFF) : AppColors.textInkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Manual Card (Pro)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!sm.isPro) {
                          RetroSubscriptionDialog.show(context);
                          return;
                        }
                        setState(() {
                          _isManualRenderMode = true;
                        });
                        SharedPreferences.getInstance().then((p) => p.setString('snapbeat_preferred_render_mode', 'manual'));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isManualRenderMode ? const Color(0xFF090B0F) : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isManualRenderMode ? AppColors.pureWhite : AppColors.chipBorder,
                            width: _isManualRenderMode ? 1.5 : 1,
                          ),
                          boxShadow: _isManualRenderMode ? AppColors.darkHardwareShadow : AppColors.softRaisedShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.tune_rounded, size: 16, color: _isManualRenderMode ? Colors.white : AppColors.textInkBlack),
                                    const SizedBox(width: 4),
                                    Text(
                                      "MANUAL",
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: _isManualRenderMode ? Colors.white : AppColors.textInkBlack,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.iridescentGradient,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "PRO",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Full control over motion, style & more.",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _isManualRenderMode ? const Color(0xB3FFFFFF) : AppColors.textInkSecondary,
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
          ),
        ),

        const SizedBox(height: 16),

        // 4. CONFIGURATION ROWS (Auto vs Manual Pro)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.chipBorder, width: 1),
              boxShadow: AppColors.softRaisedShadow,
            ),
            child: Column(
              children: [
                if (!_isManualRenderMode) ...[
                  // Auto Mode Rows (AI Controlled for Free Tier)
                  _buildConfigSettingRow(
                    label: "Beat Sync",
                    value: "Auto Beat-Sync",
                    icon: Icons.graphic_eq_rounded,
                    isLocked: true,
                    onTap: () => _showNotice("SnapBeat detects musical tempo and synchronizes photos to the beat. Switch to MANUAL (PRO) to customize individual beat styles."),
                  ),
                  Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),
                  _buildConfigSettingRow(
                    label: "Motion Dynamics",
                    value: "Dynamic Motion Flow",
                    icon: Icons.auto_awesome_rounded,
                    isLocked: true,
                    onTap: () => _showNotice("SnapBeat motion engine alternates dynamic pan, zoom, and cinematic flow. Switch to MANUAL (PRO) to customize dynamics."),
                  ),
                  Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),
                  _buildConfigSettingRow(
                    label: "Render Quality",
                    value: sm.isPro
                        ? (_selectedQuality == '1080p' ? '1080p Master' : '720p HD')
                        : '360p Standard (Free)',
                    icon: Icons.high_quality_rounded,
                    isLocked: !sm.isPro,
                    onTap: () {
                      if (!sm.isPro) {
                        RetroSubscriptionDialog.show(context);
                      } else {
                        _openQualityModal();
                      }
                    },
                  ),
                  Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),
                  _buildConfigSettingRow(
                    label: "Aspect Format",
                    value: sm.isPro
                        ? (_selectedAspectRatio == '9:16' ? '9:16 Stories/Reels' : (_selectedAspectRatio == '1:1' ? '1:1 Square' : '16:9 Landscape'))
                        : '9:16 Reels (Free)',
                    icon: Icons.aspect_ratio_rounded,
                    isLocked: !sm.isPro,
                    onTap: () {
                      if (!sm.isPro) {
                        RetroSubscriptionDialog.show(
                          context,
                          reason: "Custom Aspect Formats (1:1 Square & 16:9 Landscape) are a PRO Feature. Upgrade to unlock all formats.",
                        );
                      } else {
                        _openAspectRatioModal();
                      }
                    },
                  ),
                ] else ...[
                  // Manual Pro Rows
                  _buildConfigSettingRow(
                    label: "Motion Style",
                    value: _selectedTemplate.replaceAll('_', ' ').toUpperCase(),
                    icon: Icons.animation_rounded,
                    onTap: () => _openMotionStyleModal(),
                  ),
                  Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),
                  _buildConfigSettingRow(
                    label: "Render Quality",
                    value: sm.isPro
                        ? (_selectedQuality == '1080p' ? '1080p Master' : '720p HD')
                        : '360p Standard (Free)',
                    icon: Icons.high_quality_rounded,
                    isLocked: !sm.isPro,
                    onTap: () {
                      if (!sm.isPro) {
                        RetroSubscriptionDialog.show(context);
                      } else {
                        _openQualityModal();
                      }
                    },
                  ),
                  Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),
                  _buildConfigSettingRow(
                    label: "Aspect Format",
                    value: sm.isPro
                        ? (_selectedAspectRatio == '9:16' ? '9:16 Stories/Reels' : (_selectedAspectRatio == '1:1' ? '1:1 Square' : '16:9 Landscape'))
                        : '9:16 Reels (Free)',
                    icon: Icons.aspect_ratio_rounded,
                    isLocked: !sm.isPro,
                    onTap: () {
                      if (!sm.isPro) {
                        RetroSubscriptionDialog.show(
                          context,
                          reason: "Custom Aspect Formats (1:1 Square & 16:9 Landscape) are a PRO Feature. Upgrade to unlock all formats.",
                        );
                      } else {
                        _openAspectRatioModal();
                      }
                    },
                  ),
                  Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.5)),
                  _buildConfigSettingRow(
                    label: "Render Engine",
                    value: _renderSpeed == 'instant' ? '⚡ Instant (Serverless)' : '🎞️ Master Studio (Queued)',
                    icon: Icons.speed_rounded,
                    onTap: () => _openRenderSpeedModal(),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // OPTION 3: DYNAMIC ADAPTIVE HERO STAGE
  Widget _buildAdaptiveHeroStage(bool hasAssets) {
    if (!hasAssets) {
      // Compact Empty State
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF090B0F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x25FFFFFF), width: 1),
            boxShadow: AppColors.darkHardwareShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.iridescentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "CREATE BEAT-SYNCED PHOTO REEL",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Select photos and a soundtrack below to generate your beat-synced photo reel.",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0x99FFFFFF),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Hydrated Live Reel Player Card
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF07080A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x30FFFFFF), width: 1),
          boxShadow: AppColors.darkHardwareShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail / Background
            if (_photos.isNotEmpty && File(_photos.first.path).existsSync())
              Image.file(
                File(_photos.first.path),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: const Color(0xFF11141A),
                child: const Center(
                  child: Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 48),
                ),
              ),

            // Subtle vignette gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x60000000), Color(0x00000000), Color(0x90000000)],
                ),
              ),
            ),

            // Top Badges (Aspect & Expand)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Text(
                  _selectedAspectRatio,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),

            // Center Play / Audition Button
            Center(
              child: GestureDetector(
                onTap: _togglePlayAudio,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),

            // Bottom Duration Pill
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${(_audioDuration / 60).floor().toString().padLeft(2, '0')}:${(_audioDuration % 60).floor().toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row Item for Photos / Music / Title
  Widget _buildIngredientRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String valueTag,
    required bool isConfigured,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isConfigured ? const Color(0xFF090B0F) : AppColors.chipSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: isConfigured ? Colors.white : AppColors.textInkTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textInkBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textInkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isConfigured ? const Color(0x1510B981) : const Color(0x10000000),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueTag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isConfigured ? const Color(0xFF059669) : AppColors.textInkTertiary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textInkTertiary),
          ],
        ),
      ),
    );
  }

  // Row Item for Settings (Motion, Quality, Format, Speed)
  Widget _buildConfigSettingRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Left Column: Icon + Label (takes left half)
            SizedBox(
              width: 140,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: isLocked ? AppColors.textInkTertiary : AppColors.textInkSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? AppColors.textInkSecondary : AppColors.textInkBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Column: Value + Status/Lock aligned to the right
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isLocked ? AppColors.textInkTertiary : AppColors.textInkSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLocked) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x14000000),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0x10000000), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock_rounded, size: 9, color: AppColors.textInkTertiary),
                          SizedBox(width: 2.5),
                          Text(
                            'AUTO',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.textInkTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textInkTertiary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  // =========================================================================
  // SUB-MODAL BOTTOM SHEETS (Screen 3, 4, 5 Reference Implementation)
  // =========================================================================

  void _openMotionStyleModal() {
    final templates = [
      {"id": "pendulum", "name": "Pendulum", "desc": "Smooth, rhythmic kinetic motion"},
      {"id": "beat_cut", "name": "Beat Cut", "desc": "Sharp micro-beat transitions"},
      {"id": "bounce", "name": "Bounce", "desc": "Dynamic and energetic spring leaps"},
      {"id": "cinematic_zoom", "name": "Cinematic Zoom", "desc": "Slow dramatic depth push"},
      {"id": "fade", "name": "Fade", "desc": "Smooth crossfade transitions"},
      {"id": "glide", "name": "Glide", "desc": "Elegant horizontal slide motion"},
      {"id": "pulse", "name": "Pulse", "desc": "Beat-driven bass pulse effect"},
      {"id": "punch", "name": "Punch", "desc": "Bold and powerful impact snap"},
      {"id": "reveal_boxes", "name": "Reveal Boxes", "desc": "Creative procedural box reveals"},
      {"id": "slide", "name": "Slide", "desc": "Crisp directional slide wipes"},
      {"id": "slow_drift", "name": "Slow Drift", "desc": "Calm and ambient cinematic glide"},
      {"id": "sway", "name": "Sway", "desc": "Gentle pendulum side-to-side motion"},
      {"id": "whip", "name": "Whip", "desc": "Fast, dramatic speed blur snap"},
      {"id": "zoom_out", "name": "Zoom Out", "desc": "Pull back for maximum visual impact"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090B0F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String tempSelected = _selectedTemplate;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Motion Style", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          SizedBox(height: 2),
                          Text("Choose how your photos move to the beat.", style: TextStyle(fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: templates.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final item = templates[idx];
                        final bool isSel = tempSelected == item['id'];
                        return GestureDetector(
                          onTap: () => setModalState(() => tempSelected = item['id']!),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF141922) : const Color(0xFF0F1218),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSel ? AppColors.pureWhite : const Color(0x20FFFFFF), width: isSel ? 1.5 : 1),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(item['desc']!, style: const TextStyle(fontSize: 10, color: Colors.white60)),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSel ? Colors.white : Colors.white30,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedTemplate = tempSelected);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("APPLY", style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openQualityModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090B0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String tempQ = _selectedQuality;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Video Quality", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          SizedBox(height: 2),
                          Text("Choose export resolution for your reel.", style: TextStyle(fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQualityOptionTile(
                    id: "360p",
                    title: "360p Fast Preview",
                    subtitle: "Fastest rendering, light file size",
                    isSelected: tempQ == "360p",
                    onTap: () => setModalState(() => tempQ = "360p"),
                  ),
                  const SizedBox(height: 8),
                  _buildQualityOptionTile(
                    id: "720p",
                    title: "720p HD Standard",
                    subtitle: "High definition, balanced render speed",
                    isSelected: tempQ == "720p",
                    onTap: () => setModalState(() => tempQ = "720p"),
                  ),
                  const SizedBox(height: 8),
                  _buildQualityOptionTile(
                    id: "1080p",
                    title: "1080p Master 1080p",
                    subtitle: "Maximum clarity, studio production quality",
                    isSelected: tempQ == "1080p",
                    onTap: () => setModalState(() => tempQ = "1080p"),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedQuality = tempQ);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("APPLY", style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQualityOptionTile({required String id, required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF141922) : const Color(0xFF0F1218),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.pureWhite : const Color(0x20FFFFFF), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white60)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.white : Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }

  void _openAspectRatioModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090B0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String tempA = _selectedAspectRatio;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Aspect Ratio", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          SizedBox(height: 2),
                          Text("Choose the perfect format for your platform.", style: TextStyle(fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAspectCard(
                          ratio: "9:16",
                          label: "Stories • Reels • Shorts",
                          isSelected: tempA == "9:16",
                          onTap: () => setModalState(() => tempA = "9:16"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAspectCard(
                          ratio: "1:1",
                          label: "Instagram • Square",
                          isSelected: tempA == "1:1",
                          onTap: () => setModalState(() => tempA = "1:1"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAspectCard(
                          ratio: "16:9",
                          label: "YouTube • Landscape",
                          isSelected: tempA == "16:9",
                          onTap: () => setModalState(() => tempA = "16:9"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedAspectRatio = tempA);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("APPLY", style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAspectCard({required String ratio, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF141922) : const Color(0xFF0F1218),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.pureWhite : const Color(0x20FFFFFF), width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ratio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 9, color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  void _openRenderSpeedModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090B0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String tempS = _renderSpeed;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Render Engine & Speed", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          SizedBox(height: 2),
                          Text("Select instantaneous cloud render or queued studio master.", style: TextStyle(fontSize: 11, color: Colors.white60)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQualityOptionTile(
                    id: "instant",
                    title: "⚡ Instant Render (Serverless Cloud)",
                    subtitle: "Sub-15s GPU render with instant local playback",
                    isSelected: tempS == "instant",
                    onTap: () {
                      if (!sm.isPro) {
                        RetroSubscriptionDialog.show(
                          context,
                          reason: "Instant Serverless Render is a PRO feature. Upgrade to Pro to enable instant GPU rendering.",
                        );
                        return;
                      }
                      setModalState(() => tempS = "instant");
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildQualityOptionTile(
                    id: "queued",
                    title: "🎞️ Queued Studio Master",
                    subtitle: "Dedicated background queue with max bitrate export",
                    isSelected: tempS == "queued",
                    onTap: () => setModalState(() => tempS = "queued"),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _renderSpeed = tempS);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("APPLY", style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTitleStageView() {
    final hasPhoto = _photos.isNotEmpty;
    final photoPath = hasPhoto ? _photos.first.path : null;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card: Title Card ON/OFF Switch
          RetroMetalPanel(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pianoLacquer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x18FFFFFF)),
                      ),
                      child: const Icon(Icons.title_rounded, size: 18, color: Color(0xFF00E5FF)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '3. INTRO TITLE CARD STUDIO',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isTitleCardEnabled ? 'Enabled · Custom timing & typography' : 'Bypassed · Starts on first photo',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _isTitleCardEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF252936),
                  inactiveThumbColor: const Color(0xFF64748B),
                  inactiveTrackColor: const Color(0xFF12141A),
                  onChanged: (val) {
                    setState(() => _isTitleCardEnabled = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (!_isTitleCardEnabled) ...[
            RetroMetalPanel(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.graphiteRecess,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x14FFFFFF)),
                      ),
                      child: const Icon(Icons.flash_on_rounded, size: 24, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Direct Photo Motion Flow',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your video will dive immediately into the first photo with beat-synced motion physics. Tap CONTINUE below to proceed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // LIVE 9:16 INTERACTIVE PREVIEW
            RetroMetalPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LIVE 9:16 STUDIO PREVIEW',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.pianoLacquer,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x18FFFFFF)),
                            ),
                            child: Text(
                              _titleAudioTiming == 'with_music' ? '🎵 AUDIO OVERLAY' : '⏳ INTRO BUMPER',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.pianoLacquer,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x18FFFFFF)),
                            ),
                            child: const Text(
                              '9:16 REEL',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // The 9:16 Simulated Card
                  Container(
                    height: 340,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1B1C22), Color(0xFF101115), Color(0xFF0A0B0D)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x25FFFFFF), width: 1.0),
                      boxShadow: const [
                        BoxShadow(color: Color(0x60000000), offset: Offset(0, 4), blurRadius: 14),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Optional Photo Backdrop Scrim
                        if (_titleBgSurface == 'video_overlay' && photoPath != null && File(photoPath).existsSync()) ...[
                          Image.file(File(photoPath), fit: BoxFit.cover),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xCC000000), Color(0x99000000), Color(0xEE000000)],
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: _titleBgSurface == 'video_overlay'
                                    ? [const Color(0xFF1E2430), const Color(0xFF12141A), const Color(0xFF090A0D)]
                                    : [const Color(0xFF14161D), const Color(0xFF0A0B0E), const Color(0xFF040507)],
                              ),
                            ),
                          ),
                        ],

                        // Centered Typography Content
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _titleTextController.text.trim().isEmpty ? 'SUMMER MEMORIES' : _titleTextController.text.trim().toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: _titleFontSize == 'small' ? 16 : (_titleFontSize == 'medium' ? 20 : (_titleFontSize == 'xlarge' ? 26 : 22)),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: const Color(0xFFF2F4F7),
                                    shadows: const [
                                      Shadow(color: Color(0x80000000), offset: Offset(0, 2), blurRadius: 6),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 36,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.iridescentGradient,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _subtitleTextController.text.trim().isEmpty ? 'MOMENTS IN MOTION' : _subtitleTextController.text.trim(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    color: Color(0xFFA6ABB8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom duration badge
                        Positioned(
                          left: 12,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x80000000),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0x20FFFFFF), width: 0.8),
                            ),
                            child: Text(
                              '${_titleDurationSec.toStringAsFixed(1)}s DURATION · ${_titleAnimationStyle.toUpperCase()}',
                              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 1. AUDIO SYNCHRONIZATION TIMING ROCKER
                  const Text(
                    'AUDIO SYNCHRONIZATION TIMING',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _titleAudioTiming = 'with_music'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _titleAudioTiming == 'with_music' ? const Color(0xFF1E232E) : const Color(0xFF090B0F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _titleAudioTiming == 'with_music' ? const Color(0xFF00E5FF) : const Color(0x25FFFFFF),
                                width: _titleAudioTiming == 'with_music' ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.music_note_rounded, size: 12, color: _titleAudioTiming == 'with_music' ? const Color(0xFF00E5FF) : Colors.white70),
                                    const SizedBox(width: 4),
                                    const Text('WITH MUSIC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text('Overlay on audio intro', style: TextStyle(fontSize: 8, color: Colors.white60)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _titleAudioTiming = 'outside_track'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _titleAudioTiming == 'outside_track' ? const Color(0xFF1E232E) : const Color(0xFF090B0F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _titleAudioTiming == 'outside_track' ? const Color(0xFF00E5FF) : const Color(0x25FFFFFF),
                                width: _titleAudioTiming == 'outside_track' ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.timer_outlined, size: 12, color: _titleAudioTiming == 'outside_track' ? const Color(0xFF00E5FF) : Colors.white70),
                                    const SizedBox(width: 4),
                                    const Text('OUTSIDE TRACK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text('Audio starts after intro', style: TextStyle(fontSize: 8, color: Colors.white60)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. TITLE BACKDROP SURFACE ROCKER
                  const Text(
                    'TITLE BACKDROP SURFACE',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _titleBgSurface = 'video_overlay'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _titleBgSurface == 'video_overlay' ? const Color(0xFF1E232E) : const Color(0xFF090B0F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _titleBgSurface == 'video_overlay' ? const Color(0xFF00E5FF) : const Color(0x25FFFFFF),
                                width: _titleBgSurface == 'video_overlay' ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined, size: 12, color: _titleBgSurface == 'video_overlay' ? const Color(0xFF00E5FF) : Colors.white70),
                                    const SizedBox(width: 4),
                                    const Text('ON PHOTO / VIDEO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text('Dynamic photo backdrop', style: TextStyle(fontSize: 8, color: Colors.white60)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _titleBgSurface = 'studio_bg'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _titleBgSurface == 'studio_bg' ? const Color(0xFF1E232E) : const Color(0xFF090B0F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _titleBgSurface == 'studio_bg' ? const Color(0xFF00E5FF) : const Color(0x25FFFFFF),
                                width: _titleBgSurface == 'studio_bg' ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.crop_square_rounded, size: 12, color: _titleBgSurface == 'studio_bg' ? const Color(0xFF00E5FF) : Colors.white70),
                                    const SizedBox(width: 4),
                                    const Text('SOLID STUDIO BG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text('Piano black studio card', style: TextStyle(fontSize: 8, color: Colors.white60)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. TEXT INPUTS
                  const Text(
                    'MAIN TITLE',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _titleTextController,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPureWhite,
                    ),
                    onChanged: (val) => setState(() => _titleText = val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF090B0F),
                      hintText: "e.g. Summer Memories",
                      hintStyle: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0x25FFFFFF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0x25FFFFFF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'SUBTITLE / CAPTION',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _subtitleTextController,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPureWhite,
                    ),
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF090B0F),
                      hintText: "e.g. Moments in Motion · 2026",
                      hintStyle: const TextStyle(color: Color(0x80FFFFFF), fontSize: 11),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0x25FFFFFF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0x25FFFFFF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. ANIMATION STYLE ROCKER
                  const Text(
                    'INTRO ANIMATION MOTION',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['fade', 'kinetic_zoom', 'glitch', 'typewriter', 'slide'].map((anim) {
                        final isSel = _titleAnimationStyle == anim;
                        return GestureDetector(
                          onTap: () => setState(() => _titleAnimationStyle = anim),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF1E232E) : const Color(0xFF090B0F),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSel ? const Color(0xFF00E5FF) : const Color(0x20FFFFFF),
                                width: isSel ? 1.2 : 0.8,
                              ),
                            ),
                            child: Text(
                              anim.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                color: isSel ? Colors.white : Colors.white60,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. DURATION SLIDER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'INTRO DURATION',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${_titleDurationSec.toStringAsFixed(1)} SECONDS',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _titleDurationSec,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    activeColor: const Color(0xFF00E5FF),
                    inactiveColor: const Color(0xFF1B1F2A),
                    onChanged: (val) => setState(() => _titleDurationSec = val),
                  ),

                  if (_isManualRenderMode) _buildAdvancedTitleSuite(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getActionButtonText() {
    switch (_currentTab) {
      case 'home':
      case 'music':
        if (_selectedMusic == null) {
          return 'SELECT SOUNDTRACK';
        } else if (_photos.length < 2) {
          return 'SELECT PHOTOS (${_photos.length}/2)';
        } else {
          return 'CREATE THE REEL';
        }
      case 'audio_deck':
        return _selectedMusic != null ? 'APPLY SOUNDTRACK' : 'SELECT A TRACK';
      case 'photos':
        return _photos.length >= 2 ? 'DONE: SAVE PHOTOS' : 'SELECT 2+ PHOTOS (${_photos.length}/2)';
      case 'title':
        return 'SAVE TITLE & RETURN';
      case 'render':
        return 'START RENDER';
      case 'queue':
        return '+ CREATE NEW PHOTO REEL';
      default:
        return 'CONTINUE';
    }
  }

  String _getActionButtonSubtitle() {
    switch (_currentTab) {
      case 'home':
      case 'music':
        if (_selectedMusic == null) {
          return 'Step 1 · Pick beat-synced soundtrack';
        } else if (_photos.length < 2) {
          return 'Step 2 · Curate 2+ photos for beat matching';
        } else {
          return 'Generate beat-synced 1080p photo reel';
        }
      case 'audio_deck':
        return 'Set selected audio as reel soundtrack';
      case 'photos':
        return '${_photos.length} photos ready for reel';
      case 'title':
        return 'Intro title card customized';
      case 'render':
        return 'Render with configured settings';
      case 'queue':
        return 'Start a fresh reel project';
      default:
        return '';
    }
  }

  IconData _getActionIcon() {
    switch (_currentTab) {
      case 'home':
      case 'music':
        if (_selectedMusic == null) {
          return Icons.music_note_rounded;
        } else if (_photos.length < 2) {
          return Icons.photo_library_outlined;
        } else {
          return Icons.bolt_rounded;
        }
      case 'audio_deck':
        return Icons.music_note_rounded;
      case 'photos':
        return Icons.check_circle_outline_rounded;
      case 'title':
        return Icons.title_rounded;
      case 'render':
        return Icons.movie_creation_rounded;
      case 'queue':
        return Icons.add_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  bool _isActionEnabled() {
    switch (_currentTab) {
      case 'home':
      case 'music':
        return true; // Always actionable: guides user to soundtrack, photos, or renders reel
      case 'audio_deck':
        return _selectedMusic != null;
      case 'photos':
        return _photos.length >= 2;
      case 'title':
        return true;
      case 'render':
        return _selectedMusic != null && _photos.length >= 2;
      case 'queue':
        return true;
      default:
        return false;
    }
  }

  void _handleMasterAction() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
    switch (_currentTab) {
      case 'home':
      case 'music':
        if (_selectedMusic != null && _photos.length >= 2) {
          if (_isManualRenderMode) {
            _executeRender(isInstant: _renderSpeed == 'instant');
          } else {
            _startDirectAutoRender();
          }
          setState(() => _currentTab = 'queue');
        } else if (_selectedMusic == null) {
          setState(() => _currentTab = 'audio_deck');
        } else if (_photos.length < 2) {
          setState(() => _currentTab = 'photos');
        }
        break;
      case 'audio_deck':
        setState(() => _currentTab = 'home');
        break;
      case 'photos':
        if (_photos.length >= 2) {
          setState(() => _currentTab = 'home');
        }
        break;
      case 'title':
        setState(() => _currentTab = 'home');
        break;
      case 'render':
        _triggerMasterReel();
        break;
      case 'queue':
        setState(() => _currentTab = 'home');
        break;
    }
  }

  void _startDirectAutoRender() {
    if (_selectedMusic == null || _photos.length < 2) return;
    _executeRender(isInstant: !_isManualRenderMode);
  }

}
