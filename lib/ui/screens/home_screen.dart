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
import '../components/tester_feedback_dialog.dart';
import '../components/metal_chassis_scaffold.dart';
import '../components/snapbeat_pink_dot.dart';
import '../components/retro_mechanical_button.dart';
import '../components/retro_subscription_dialog.dart';

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
  final qm = QueueManager.instance;
  final api = ApiService.instance;
  final sm = SubscriptionManager.instance;
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
  String _selectedQuality = "540p";
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
  String _titleText = "";
  late final TextEditingController _titleTextController;
  String _titleBg = "black";
  int _titleDuration = 2;
  String _titleFont = "great_vibes";
  String _titleFontSize = "large";
  String _titleStyle = "classic";
  String _titleFrame = "none";
  String _titleAudio = "before_audio";

  // Cult Effects (Manual Mode - Bursts, Teaser, Drop-It)
  bool _enableBurst = true;
  bool _enableTeaser = true;
  bool _enableDropIt = false;

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
            Icon(Icons.delete_sweep_rounded, color: AppColors.brassGold, size: 22),
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
              backgroundColor: const Color(0xFF8B2525),
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
    sm.init();
    AdManager.instance.init();
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
          _selectedMusicTitle = '🎬 Video Audio: $fileName';
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
    final match = RegExp(r'(\d+\s*BPM)', caseSensitive: false).firstMatch(_selectedMusicTitle);
    return match?.group(1);
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

  void _duplicatePhoto(String photoId) {
    final idx = _photos.indexWhere((p) => p.id == photoId);
    if (idx != -1) {
      if (_photos.length >= maxPhotosForTrack) {
        _showNotice("Maximum $maxPhotosForTrack photos reached.");
        return;
      }
      final src = _photos[idx];
      final duplicate = PhotoItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_dup',
        path: src.path,
        order: idx + 1,
      );
      setState(() {
        _photos.insert(idx + 1, duplicate);
        for (int i = 0; i < _photos.length; i++) {
          _photos[i].order = i;
        }
      });
      _showNotice("Photo duplicated! (${_photos.length}/$maxPhotosForTrack)");
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
              borderSide: const BorderSide(color: AppColors.brassGold, width: 2),
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
              backgroundColor: AppColors.brassGold,
              foregroundColor: const Color(0xFF1E1A10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  content: Text("✓ Deleted \"${job.displayName}\""),
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

  void _triggerPreviewRender() async {
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

      await _executeRender(isInstant: false, isPreview: true);
    } finally {
      _isSubmittingRender = false;
    }
  }


  // Reserved for instant render & credits pack workflow (temporarily held):
  // void _showRenderChoiceDialog() { ... }

  Future<void> _executeRender({required bool isInstant, bool isPreview = false}) async {
    if (_selectedMusic == null) {
      _showNotice("Step 1: Please select a music track first.");
      return;
    }
    if (_photos.isEmpty) {
      _showNotice("Step 2: Please select photos before rendering.");
      return;
    }

    final isPro = sm.isPro;
    if (!isPreview && !isPro) {
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
          RetroSubscriptionDialog.show(context);
          _showNotice("Daily limit of 3 free renders reached. Upgrade to VIP for unlimited exports!");
        }
        return;
      }
      await prefs.setInt('free_render_count', count + 1);
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

    if (isPreview) {
      tDisplayName = "Preview: $tDisplayName";
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
    // Pro subscribers get 1080p Master exports; Free users get 540p Standard; Previews use 360p
    final qualitySnapshot = isPreview ? "360p" : (isPro ? "1080p" : "540p");
    // Pro subscribers have watermarks removed; Free videos have watermark (always for preview)
    final shouldWatermark = isPreview ? true : !isPro;
    // Pro subscribers get fast priority queue; Free users use standard queue (always free for preview)
    final renderTypeSnapshot = isPreview ? "free_queue" : (isPro ? "priority_queue" : "free_queue");
    final entitlementTokenSnapshot = isPreview ? null : (isPro ? sm.signedEntitlementToken : null);
    final audioStartSnapshot = _audioStart.toInt();
    final audioEndSnapshot = _audioEnd.toInt();
    final titleTextSnapshot = (_enableTitle && _titleText.trim().isNotEmpty) ? _titleText.trim() : null;
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
      isPreview: isPreview,
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
    bool isPreview = false,
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
        preview: isPreview,
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
                                    'assets/images/snapbeat_studio_logo.png',
                                    height: 42,
                                    fit: BoxFit.contain,
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Right Action Group: Pro Badge, Feedback & Privacy Policy
                      const RetroProBadge(),
                      const SizedBox(width: 4),
                      // Tester Feedback only shown on Android (not on iOS App Store build)
                      if (AppConfig.showTesterFeedback)
                        IconButton(
                          icon: const Icon(Icons.rate_review_outlined, color: AppColors.brassGold, size: 20),
                          tooltip: 'Send Tester Feedback',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          onPressed: () => TesterFeedbackDialog.show(context),
                        ),
                      if (AppConfig.showTesterFeedback) const SizedBox(width: 4),
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

                        // Curated Soundtrack Library (Inline, matching Web RetroTapeDeck)
                        CuratedSoundtrackSection(
                          selectedTrackTitle: _selectedMusicTitle,
                          onSelectTrack: _onSelectBuiltInTrack,
                        ),

                        // Bottom Action CTA
                        if (_selectedMusic != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: _buildProceedButton(
                              label: "NEXT: ADD PHOTOS ->",
                              subtitle: "Soundtrack configured * Select photos for your reel",
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
                          onDuplicate: _duplicatePhoto,
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
                        if (_photos.length >= 2)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: _buildProceedButton(
                              label: "NEXT: CHOOSE STYLE & RENDER →",
                              subtitle: "${_photos.length} photos ready • Pick template and motion style",
                              icon: Icons.movie_creation_rounded,
                              onTap: () {
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpTo(0.0);
                                }
                                setState(() {
                                  const newTab = "render";
                                  _currentTab = newTab;
                                });
                              },
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: _buildProceedButton(
                              label: "SELECT AT LEAST 2 PHOTOS",
                              subtitle: "Tap 'Add Photos' or 'Sample Photos' to start your reel",
                              icon: Icons.add_photo_alternate_rounded,
                              onTap: _pickPhotos,
                            ),
                          ),
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
                  label: "MANUAL MODE",
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.panelCreamDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.chassisBevelLight),
              ),
              child: Row(
                children: const [
                  Icon(Icons.bolt_rounded, size: 16, color: AppColors.brassGold),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Auto beat-sync dynamically arranges transitions and pacing to match the soundtrack rhythm. Tap the dice to roll a different preset style!",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        height: 1.25,
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
            // Cult Effects (User-facing toggles: Bursts, Teaser, Drop-It)
            enableBurst: _enableBurst,
            onToggleBurst: (v) => setState(() => _enableBurst = v),
            enableTeaser: _enableTeaser,
            onToggleTeaser: (v) => setState(() => _enableTeaser = v),
            enableDropIt: _enableDropIt,
            onToggleDropIt: (v) => setState(() => _enableDropIt = v),
          ),
        ],

        // 3. Job Summary Badge
        _buildJobSummaryCard(),

        // 4. Render Reel Launch Button (Tactile 3D Skeuomorphic Button)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RetroMechanicalButton(
                    variant: RetroButtonVariant.render,
                    height: 68,
                    onTap: _triggerMasterReel,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _triggerPreviewRender,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2525),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF4A1010), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "PREVIEW",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "READY TO SYNC ${_photos.length} ${_photos.length == 1 ? 'PHOTO' : 'PHOTOS'} TO BEAT",
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9.5,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelCreamDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.chassisBevelLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  SnapBeatPinkDot(size: 8.5, withGlow: true),
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
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.panelInset,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.chassisBevelDark, width: 0.8),
                ),
                child: Text(
                  _renderMode == "auto" ? "AUTO PRESET" : "MANUAL CONFIG",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.brassGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 1: Soundtrack & Duration
          Row(
            children: [
              _buildSummaryPill(
                Icons.music_note_rounded,
                _selectedMusicTitle.isEmpty ? "Track" : _selectedMusicTitle,
                subtitle: "AUDIO",
              ),
              const SizedBox(width: 4),
              _buildSummaryPill(
                Icons.timer_outlined,
                "${durationSec}s length",
                subtitle: "DURATION",
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Row 2: Photo count & Motion style
          Row(
            children: [
              _buildSummaryPill(
                Icons.photo_library_outlined,
                "${_photos.length} ${_photos.length == 1 ? 'photo' : 'photos'}",
                subtitle: "MEDIA",
              ),
              const SizedBox(width: 4),
              _buildSummaryPill(
                Icons.auto_awesome_mosaic_rounded,
                styleName,
                subtitle: "STYLE",
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Row 3: Aspect ratio & Quality + Watermark status
          Row(
            children: [
              _buildSummaryPill(
                Icons.video_settings_rounded,
                "$_selectedAspectRatio • $_selectedQuality",
                subtitle: "OUTPUT",
              ),
              const SizedBox(width: 4),
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
        color: highlight ? const Color(0xFF2E2614) : AppColors.panelInset,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: highlight ? AppColors.amberGlow : AppColors.chassisBevelDark.withValues(alpha: 0.5),
          width: highlight ? 1.2 : 0.8,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.amberGlow.withValues(alpha: 0.25),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: highlight ? const Color(0xFFFFD54F) : AppColors.brassGold),
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
                      color: highlight ? AppColors.amberJewel : AppColors.textMuted,
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
                    color: highlight ? const Color(0xFFFFE082) : AppColors.textEngraved,
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
                color: AppColors.brassGold,
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(color: AppColors.amberGlow, blurRadius: 2),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingAffordance,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 6.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      color: AppColors.hardwareGunmetal,
                    ),
                  ),
                  const SizedBox(width: 1.5),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 5.5, color: AppColors.hardwareGunmetal),
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

  Widget _buildAutoTemplateBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Row(
                  children: [
                    Icon(_currentAutoTemplate.icon, size: 11, color: AppColors.brassGold),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_currentAutoTemplate.subtitle} (tap dice to change)',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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

        // Testing Queue Notice Banner (active during closed beta) - Hidden on iOS
        if (AppConfig.showBetaFeatures && activeJobs.isNotEmpty)
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
                          text: "Queue Notice: ",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.amberJewel),
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

        // Closed Beta Tester Feedback & Bug Report Action Bar - Hidden on iOS
        if (AppConfig.showBetaFeatures)
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.panelCreamDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.chassisBevelLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.rate_review_rounded, size: 14, color: AppColors.amberJewel),
                    SizedBox(width: 8),
                    Text(
                      "TESTER FEEDBACK & BUG REPORT",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textEngraved,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => TesterFeedbackDialog.show(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.brassGold,
                    foregroundColor: AppColors.textEngraved,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "FEEDBACK",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                              color: AppColors.panelCreamDark,
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
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: AppColors.vuGreen),
                          const SizedBox(width: 4),
                          Text(
                            "Auto-saved to Photos (SnapBeat album)",
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
                // 1. PLAY BUTTON (Primary)
                Expanded(
                  child: RetroMechanicalButton(
                    variant: RetroButtonVariant.play,
                    height: 44,
                    onTap: () async {
                      await _audioPlayer.pause();
                      if (!mounted) return;
                      setState(() => _isPlayingAudio = false);
                      AdManager.instance.showBeforePlayback(
                        context: context,
                        onDone: () => VideoPreviewDialog.show(
                          context,
                          videoPath: job.videoPath!,
                          templateName: job.templateName,
                          customName: job.displayName,
                          quality: job.quality,
                        ),
                      );
                    },
                  ),
                ),
                // 3. TACTILE RECESSED DELETE BUTTON (Quieter secondary action)
                Tooltip(
                  message: 'Delete reel',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _confirmDeleteReel(job),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.metalDeepCavity,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.chassisBevelDark,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
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
}