import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/models.dart';
import '../../services/credit_manager.dart';
import '../../services/queue_manager.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../components/interactive_waveform.dart';
import '../components/snaps_reorder_strip.dart';
import '../components/pro_controls_card.dart';
import '../components/master_action_deck.dart';
import '../components/store_dialog.dart';

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
  String _selectedMusicTitle = "Summer Beats (Acoustic Demo)";
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

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await cm.init();
    await qm.init();
    if (mounted) setState(() {});
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
      _audioDuration = 45.0;
      _audioStart = 0.0;
      _audioEnd = 15.0;
      setState(() {});
    }
  }

  void _loadSampleBeat() {
    setState(() {
      _selectedMusicTitle = "Electro Wave Demo (128 BPM)";
      _audioDuration = 30.0;
      _audioStart = 0.0;
      _audioEnd = 15.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✨ Sample beat loaded successfully!")),
    );
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

  void _togglePlayAudio() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      if (_selectedMusic != null) {
        await _audioPlayer.play(DeviceFileSource(_selectedMusic!.path));
      }
      setState(() => _isPlayingAudio = true);
    }
  }

  void _triggerMasterReel() {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add your snaps (photos) first!")),
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
        backgroundColor: AppColors.cardSurface,
        title: const Text("👑 UNLOCK SNAPBEAT PRO", style: TextStyle(color: AppColors.goldBright, fontWeight: FontWeight.bold)),
        content: Text(
          "Enable Pro Mode (${cm.pricing.proModePrice}) to unlock:\n\n"
          "• All 14 custom beat templates\n"
          "• Master 1080p 60fps high bitrate quality\n"
          "• Custom aspect ratios (9:16, 1:1, 16:9)\n"
          "• Animated Title Cards & Audio Trimming\n"
          "• NO WATERMARK included on all renders!",
          style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              StoreBottomSheet.show(context, onPurchaseComplete: () => setState(() {}));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
            child: Text("ENABLE PRO (${cm.pricing.proModePrice})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.canvasDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.goldPrimary)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose Render Processing", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            // Instant
            ListTile(
              leading: const Text("⚡", style: TextStyle(fontSize: 22)),
              title: const Text("Render Instant (1 Credit)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldBright)),
              subtitle: const Text("Bypasses queue • No watermark • Fast serverless", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              onTap: () {
                Navigator.pop(ctx);
                _executeRender(isInstant: true);
              },
            ),
            const Divider(color: AppColors.borderSubtle),
            // Free Queue
            ListTile(
              leading: const Text("📥", style: TextStyle(fontSize: 22)),
              title: Text(
                watermarkClean ? "Render Free (No Watermark)" : "Render Free with Watermark",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                watermarkClean ? "Processed in Free Queue • Clean output" : "Processed in Free Queue • Includes SnapBeat badge",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
      String tId = _selectedTemplate;
      if (_currentMode == "auto") {
        final proList = List<BeatTemplate>.from(BeatTemplate.allTemplates)..shuffle();
        tId = proList.first.id;
      }

      final photoFiles = _photos.map((p) => File(p.path)).toList();
      final musicFile = _selectedMusic ?? File("");

      final videoPath = await api.renderReel(
        musicFile: musicFile,
        photoFiles: photoFiles,
        templateId: tId,
        aspectRatio: _selectedAspectRatio,
        quality: _selectedQuality,
        watermark: cm.shouldWatermark(isInstant),
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
        templateName: tId,
        status: "READY",
        videoPath: videoPath,
        createdAt: DateTime.now(),
        quality: _selectedQuality,
      ));

      if (isInstant) {
        await cm.deductCredit();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✨ Reel Mastered! Saved to: $videoPath"),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Render notice: ${e.toString()}"), backgroundColor: Colors.amber[900]),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRendering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            _buildModeSegmentedBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    if (_currentMode == "vault") ...[
                      _buildVaultSection(),
                    ] else ...[
                      // Track Picker Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("🎧", style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                "Choose Your Track",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _pickMusic,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
                                  ),
                                  child: const Text("📁 Pick Audio", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.goldBright)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _loadSampleBeat,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: const Text("✨ Sample Beat", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      InteractiveWaveform(
                        trackTitle: _selectedMusicTitle,
                        durationSeconds: _audioDuration,
                        startSeconds: _audioStart,
                        endSeconds: _audioEnd,
                        isPlaying: _isPlayingAudio,
                        onTogglePlay: _togglePlayAudio,
                        onTrimChanged: (start, end) {
                          setState(() {
                            _audioStart = start;
                            _audioEnd = end;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SnapsReorderStrip(
                        photos: _photos,
                        onPickPhotos: _pickPhotos,
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            final item = _photos.removeAt(oldIdx);
                            _photos.insert(newIdx, item);
                          });
                        },
                        onDelete: (id) {
                          setState(() => _photos.removeWhere((p) => p.id == id));
                        },
                        arrangementMode: _arrangementMode,
                        onArrangementChanged: (mode) => setState(() => _arrangementMode = mode),
                      ),
                      const SizedBox(height: 12),
                      if (_currentMode == "pro") ...[
                        ProControlsCard(
                          selectedTemplateId: _selectedTemplate,
                          onSelectTemplate: (id) => setState(() => _selectedTemplate = id),
                          selectedAspectRatio: _selectedAspectRatio,
                          onSelectAspectRatio: (r) => setState(() => _selectedAspectRatio = r),
                          selectedQuality: _selectedQuality,
                          onSelectQuality: (q) => setState(() => _selectedQuality = q),
                          enableTitle: _enableTitle,
                          onToggleTitle: (v) => setState(() => _enableTitle = v),
                          titleText: _titleText,
                          onTitleTextChanged: (t) => setState(() => _titleText = t),
                          titleBg: _titleBg,
                          onSelectTitleBg: (b) => setState(() => _titleBg = b),
                          titleDuration: _titleDuration,
                          onTitleDurationChanged: (d) => setState(() => _titleDuration = d),
                        ),
                      ] else ...[
                        _buildAutoModeCard(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            MasterActionDeck(
              onMasterTap: _triggerMasterReel,
              isRendering: _isRendering,
              progress: _renderProgress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.canvasDark,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldPrimary, AppColors.goldBright]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text("SB", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SnapBeat", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                  Text("ÉDITION ROYALE", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.goldBright.withOpacity(0.8))),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => StoreBottomSheet.show(context, onPurchaseComplete: () => setState(() {})),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amberBadgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text("⚡", style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        "${cm.credits} Passes",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldBright),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  cm.pricing.currencySymbol,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSegmentedBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.canvasDark,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            _buildTabPill("🎲 Auto Magic", "auto"),
            _buildTabPill("👑 Studio Pro", "pro"),
            _buildTabPill("🎞️ Reel Vault", "vault"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String title, String mode) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.goldPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.black : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoModeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Text("🎲", style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Auto Magic Selection Active", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldBright)),
                SizedBox(height: 2),
                Text(
                  "Picks a completely different motion template from all 14 styles on every render!",
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultSection() {
    final jobs = qm.jobs;
    if (jobs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        child: const Center(
          child: Column(
            children: [
              Text("🎞️", style: TextStyle(fontSize: 36)),
              SizedBox(height: 8),
              Text("Reel Vault is Empty", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 4),
              Text("Render your first reel to see it here!", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text("🎬", style: TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reel #${job.id.substring(job.id.length - 4)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("Template: ${job.templateName} • ${job.quality}", style: const TextStyle(fontSize: 10, color: AppColors.goldBright)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.status == "READY" ? const Color(0xFF10B981).withOpacity(0.2) : AppColors.amberBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: job.status == "READY" ? const Color(0xFF34D399) : AppColors.goldBright,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
