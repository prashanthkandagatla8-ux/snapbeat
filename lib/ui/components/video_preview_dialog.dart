import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import '../../services/export_service.dart';
import 'retro_mechanical_button.dart';

class VideoPreviewDialog extends StatefulWidget {
  final String videoPath;
  final String? templateName;
  final String? quality;

  const VideoPreviewDialog({
    super.key,
    required this.videoPath,
    this.templateName,
    this.quality,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoPath,
    String? templateName,
    String? quality,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (ctx) => VideoPreviewDialog(
        videoPath: videoPath,
        templateName: templateName,
        quality: quality,
      ),
    );
  }

  @override
  State<VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<VideoPreviewDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final file = File(widget.videoPath);
      if (!file.existsSync()) {
        setState(() {
          _hasError = true;
          _errorMessage = "Video file not found.";
        });
        return;
      }

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.addListener(() {
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = "Could not load video.";
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panelCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.panelCreamDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.chassisBevelDark, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isInitialized && _controller.value.isPlaying
                          ? AppColors.amberJewel
                          : AppColors.textMuted,
                      boxShadow: _isInitialized && _controller.value.isPlaying
                          ? const [BoxShadow(color: AppColors.amberJewel, blurRadius: 6, spreadRadius: 1)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Video Preview",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            color: AppColors.textEngraved,
                          ),
                        ),
                        if (widget.templateName != null)
                          Text(
                            "${widget.templateName!.toUpperCase()} • ${widget.quality ?? '1080P MASTER'}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textFoilGold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textEngraved),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Video CRT Screen Area
            Container(
              color: Colors.black,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: Center(
                child: _hasError
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.vuRed, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : !_isInitialized
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                CircularProgressIndicator(color: AppColors.brassGold),
                                SizedBox(height: 16),
                                Text(
                                  "Loading video...",
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                    color: AppColors.brassHighlight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                                if (!_controller.value.isPlaying)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.6),
                                      border: Border.all(color: AppColors.brassGold, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.brassHighlight,
                                      size: 36,
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ),
            ),

            // Bottom Transport Bar
            if (_isInitialized) ...[
              // Scrubber
              Container(
                color: AppColors.canvasChassis,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.amberJewel,
                    bufferedColor: Colors.white24,
                    backgroundColor: AppColors.panelInset,
                  ),
                ),
              ),
              // Controls Section (2-Row Layout: NEVER overflows or floats outside)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: const BoxDecoration(
                  color: AppColors.panelCream,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Play/Pause, Timecode Readout, and Close Button
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            _controller.value.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                            color: AppColors.textEngraved,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        // Nixie Timecode Readout
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.canvasChassis,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.chassisBevelDark, width: 1.0),
                          ),
                          child: Text(
                            "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amberJewel,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            backgroundColor: AppColors.panelCreamDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: AppColors.chassisBevelLight),
                            ),
                          ),
                          icon: const Icon(Icons.close_rounded, size: 15, color: AppColors.textEngraved),
                          label: const Text(
                            "CLOSE",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textEngraved,
                              letterSpacing: 0.6,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row 2: Full-Width Responsive Action Buttons (SAVE & SHARE)
                    Row(
                      children: [
                        // Save to Gallery Button (DOWNLOAD)
                        Expanded(
                          child: RetroMechanicalButton(
                            variant: RetroButtonVariant.download,
                            height: 48,
                            onTap: () => ExportService.saveToGallery(
                              context,
                              videoPath: widget.videoPath,
                              templateName: widget.templateName ?? 'SnapBeat',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Social Share Button (SHARE)
                        Expanded(
                          child: RetroMechanicalButton(
                            variant: RetroButtonVariant.share,
                            height: 48,
                            onTap: () => ExportService.shareReel(
                              context,
                              videoPath: widget.videoPath,
                              templateName: widget.templateName ?? 'SnapBeat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.panelCream,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CLOSE", style: TextStyle(color: AppColors.textEngraved, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
