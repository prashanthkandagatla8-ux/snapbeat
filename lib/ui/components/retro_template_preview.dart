import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import 'retro_subscription_dialog.dart';
import 'snapbeat_pink_dot.dart';

class RetroTemplatePreview extends StatefulWidget {
  final String selectedTemplateId;
  final Function(String templateId) onSelectTemplate;
  final bool isPro;

  const RetroTemplatePreview({
    super.key,
    required this.selectedTemplateId,
    required this.onSelectTemplate,
    required this.isPro,
  });

  @override
  State<RetroTemplatePreview> createState() => _RetroTemplatePreviewState();
}

class _RetroTemplatePreviewState extends State<RetroTemplatePreview> {
  late String _previewId;
  VideoPlayerController? _controller;
  bool _isMuted = true;
  bool _isPlaying = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _previewId = widget.selectedTemplateId.isNotEmpty
        ? widget.selectedTemplateId
        : BeatTemplate.allTemplates.first.id;
    _initVideoPlayer(_previewId);
  }

  @override
  void didUpdateWidget(covariant RetroTemplatePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTemplateId != widget.selectedTemplateId &&
        widget.selectedTemplateId != _previewId) {
      _changePreview(widget.selectedTemplateId);
    }
  }

  Future<void> _initVideoPlayer(String templateId) async {
    final oldController = _controller;
    setState(() {
      _isInitialized = false;
    });

    final newController = VideoPlayerController.asset(
      'assets/previews/$templateId.mp4',
    );

    try {
      await newController.initialize();
      await newController.setLooping(true);
      await newController.setVolume(_isMuted ? 0.0 : 1.0);
      await newController.play();

      if (!mounted) {
        newController.dispose();
        return;
      }

      setState(() {
        _controller = newController;
        _isInitialized = true;
        _isPlaying = true;
      });

      oldController?.dispose();
    } catch (e) {
      debugPrint('[RetroTemplatePreview] Error loading preview video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
      oldController?.dispose();
    }
  }

  void _changePreview(String templateId) {
    if (_previewId == templateId) return;
    setState(() {
      _previewId = templateId;
    });
    _initVideoPlayer(templateId);
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _openFullscreenModal(BeatTemplate currentPreview) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return _FullscreenTemplatePreviewDialog(
          template: currentPreview,
          isPro: widget.isPro,
          isSelected: widget.selectedTemplateId == currentPreview.id,
          onSelect: () {
            widget.onSelectTemplate(currentPreview.id);
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTemplate = BeatTemplate.allTemplates.firstWhere(
      (t) => t.id == _previewId,
      orElse: () => BeatTemplate.allTemplates.first,
    );
    final isCurrentSelected = widget.selectedTemplateId == _previewId;
    final isTemplatePro = activeTemplate.isPro;
    final canSelect = widget.isPro || !isTemplatePro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SnapBeatPinkDot(size: 10, withGlow: true),
                const SizedBox(width: 6),
                Text(
                  widget.isPro ? 'MOTION TEMPLATES (14)' : 'MOTION TEMPLATE PREVIEW',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.brassGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(activeTemplate.icon, size: 10, color: AppColors.brassGold),
                  const SizedBox(width: 4),
                  Text(
                    activeTemplate.name,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brassGold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Retro CRT Viewfinder Screen
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF071318),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(2, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Viewfinder HUD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // REC / Preview Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brassGold.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PREVIEW: ${activeTemplate.name.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brassGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Controls: Mute + Expand
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _toggleMute,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Icon(
                              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                              size: 14,
                              color: _isMuted ? AppColors.brassGold : Colors.greenAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _openFullscreenModal(activeTemplate),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 9:16 Video Player Area (height ~220px)
              GestureDetector(
                onTap: _togglePlay,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Poster Image (shown immediately)
                      Positioned.fill(
                        child: Image.asset(
                          'assets/previews/$_previewId.jpg',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.movie_creation_rounded, color: Colors.white24, size: 36),
                          ),
                        ),
                      ),

                      // Video Player (when initialized)
                      if (_isInitialized && _controller != null)
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio > 0
                                ? _controller!.value.aspectRatio
                                : 9 / 16,
                            child: VideoPlayer(_controller!),
                          ),
                        ),

                      // Scanline overlay effect
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // CRT Vignette glow
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF00FFC2).withValues(alpha: 0.08),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Paused overlay indicator
                      if (!_isPlaying && _isInitialized)
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.brassGold, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.brassGold,
                            size: 22,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Viewfinder HUD Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A1B22),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                  border: Border(top: BorderSide(color: Colors.white12, width: 1)),
                ),
                child: Row(
                  children: [
                    // Template Name and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(activeTemplate.icon, size: 13, color: AppColors.brassGold),
                              const SizedBox(width: 5),
                              Text(
                                activeTemplate.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              if (isTemplatePro) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.brassGold,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeTemplate.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.5,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Button: Select Style / Active / Unlock Pro
                    if (!canSelect)
                      GestureDetector(
                        onTap: () => RetroSubscriptionDialog.show(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.brassKnobGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: AppColors.amberGlow, blurRadius: 4),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, size: 12, color: AppColors.hardwareGunmetal),
                              SizedBox(width: 3),
                              Text(
                                'PRO PASS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.hardwareGunmetal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isCurrentSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.greenAccent, width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 11, color: Colors.greenAccent),
                            SizedBox(width: 3),
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => widget.onSelectTemplate(_previewId),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.brassGold,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: AppColors.amberGlow, blurRadius: 4),
                            ],
                          ),
                          child: const Text(
                            'SELECT STYLE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.hardwareGunmetal,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Template Selection Chips (All 14 styles)
        const Text(
          'TAP TO PREVIEW STYLE • CONFIRM TO SELECT',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: BeatTemplate.allTemplates.map((t) {
            final isPreviewed = t.id == _previewId;
            final isCommitted = t.id == widget.selectedTemplateId;
            final isLocked = !widget.isPro && t.isPro;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _changePreview(t.id);
                if (isLocked) {
                  RetroSubscriptionDialog.show(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isPreviewed
                      ? AppColors.brassGold
                      : (isCommitted ? AppColors.brassGold.withValues(alpha: 0.3) : AppColors.panelInset),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPreviewed
                        ? AppColors.brassGold
                        : (isCommitted ? AppColors.borderBrass : AppColors.chassisBevelLight),
                    width: isPreviewed ? 1.5 : 1.0,
                  ),
                  boxShadow: isPreviewed
                      ? const [
                          BoxShadow(color: AppColors.amberGlow, blurRadius: 4, spreadRadius: 1),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.icon,
                      size: 11,
                      color: isPreviewed ? AppColors.hardwareGunmetal : AppColors.brassGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isPreviewed ? FontWeight.w900 : FontWeight.w700,
                        letterSpacing: 0.4,
                        color: isPreviewed ? AppColors.hardwareGunmetal : AppColors.textSecondary,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.lock_rounded, size: 9, color: AppColors.brassGold),
                    ] else if (isCommitted) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.check_circle_rounded, size: 10, color: Colors.greenAccent),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FullscreenTemplatePreviewDialog extends StatefulWidget {
  final BeatTemplate template;
  final bool isPro;
  final bool isSelected;
  final VoidCallback onSelect;

  const _FullscreenTemplatePreviewDialog({
    required this.template,
    required this.isPro,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<_FullscreenTemplatePreviewDialog> createState() =>
      _FullscreenTemplatePreviewDialogState();
}

class _FullscreenTemplatePreviewDialogState
    extends State<_FullscreenTemplatePreviewDialog> {
  late VideoPlayerController _controller;
  bool _isMuted = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/previews/${widget.template.id}.mp4',
    )..initialize().then((_) {
        if (!mounted) return;
        _controller.setLooping(true);
        _controller.setVolume(_isMuted ? 0.0 : 1.0);
        _controller.play();
        setState(() => _isInit = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSelect = widget.isPro || !widget.template.isPro;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1C20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.brassGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(widget.template.icon, size: 16, color: AppColors.brassGold),
                      const SizedBox(width: 8),
                      Text(
                        widget.template.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brassGold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: _isMuted ? Colors.white60 : Colors.greenAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                            _controller.setVolume(_isMuted ? 0.0 : 1.0);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Video 9:16 Area
            Flexible(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/previews/${widget.template.id}.jpg',
                        fit: BoxFit.cover,
                      ),
                      if (_isInit)
                        VideoPlayer(_controller),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with description and action
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Text(
                    widget.template.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSelect ? AppColors.brassGold : AppColors.amberJewel,
                        foregroundColor: AppColors.hardwareGunmetal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (canSelect) {
                          widget.onSelect();
                        } else {
                          Navigator.of(context).pop();
                          RetroSubscriptionDialog.show(context);
                        }
                      },
                      child: !canSelect
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.workspace_premium, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'UNLOCK PRO TO USE THIS STYLE',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ],
                            )
                          : Text(
                              widget.isSelected ? 'CURRENTLY SELECTED ✓' : 'USE THIS TEMPLATE',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                            ),
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
}
