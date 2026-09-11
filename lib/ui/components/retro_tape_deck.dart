import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'snapbeat_pink_dot.dart';

class RetroTapeDeck extends StatefulWidget {
  final bool isPlaying;
  final String trackTitle;
  final double currentSeconds;
  final double totalSeconds;
  final VoidCallback onTogglePlay;
  final VoidCallback onPickAudio;
  final VoidCallback onLoadSample;
  final VoidCallback? onQuickDemo;

  const RetroTapeDeck({
    super.key,
    required this.isPlaying,
    required this.trackTitle,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.onTogglePlay,
    required this.onPickAudio,
    required this.onLoadSample,
    this.onQuickDemo,
  });

  @override
  State<RetroTapeDeck> createState() => _RetroTapeDeckState();
}

class _RetroTapeDeckState extends State<RetroTapeDeck> with SingleTickerProviderStateMixin {
  late AnimationController _reelController;

  @override
  void initState() {
    super.initState();
    _reelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying) {
      _reelController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RetroTapeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _reelController.repeat();
      } else {
        _reelController.stop();
      }
    }
  }

  @override
  void dispose() {
    _reelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTrack = widget.trackTitle.trim().isNotEmpty && widget.trackTitle != "No soundtrack selected";
    final mins = hasTrack ? (widget.currentSeconds ~/ 60).toString().padLeft(2, '0') : '--';
    final secs = hasTrack ? (widget.currentSeconds % 60).toInt().toString().padLeft(2, '0') : '--';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
        boxShadow: [
          // Bevel light top-left
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          // Bevel shadow bottom-right
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(4, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner Brass Screws
          const Positioned(top: 8, left: 8, child: _ScrewHead()),
          const Positioned(top: 8, right: 8, child: _ScrewHead()),
          const Positioned(bottom: 8, left: 8, child: _ScrewHead()),
          const Positioned(bottom: 8, right: 8, child: _ScrewHead()),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Nameplate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SnapBeatPinkDot(size: 13, withGlow: true),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brassGold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '1. MUSIC',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.hardwareGunmetal,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasTrack ? 'READY' : 'REQUIRED FIRST',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: hasTrack ? AppColors.amberJewel : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    // Mechanical Counter Window
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.chassisBevelDark, width: 1),
                      ),
                      child: Text(
                        '$mins : $secs',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amberJewel,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tape Reels & VU Meter Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.panelInset,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Supply Reel
                      AnimatedBuilder(
                        animation: _reelController,
                        builder: (ctx, child) {
                          return Transform.rotate(
                            angle: _reelController.value * 2 * math.pi,
                            child: const _TapeReelSpool(),
                          );
                        },
                      ),

                      // Central Analog VU Meter
                      Column(
                        children: [
                          _AnalogVuMeter(isPlaying: widget.isPlaying),
                        ],
                      ),

                      // Take-up Reel
                      AnimatedBuilder(
                        animation: _reelController,
                        builder: (ctx, child) {
                          return Transform.rotate(
                            angle: -_reelController.value * 2 * math.pi,
                            child: const _TapeReelSpool(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Track Title Bar & Action Buttons
                Row(
                  children: [
                    // Transport Play/Pause Lever
                    GestureDetector(
                      onTap: widget.onTogglePlay,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brassKnobGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(2, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: AppColors.hardwareGunmetal,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Track Info Display
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasTrack ? widget.trackTitle : 'CHOOSE SOUNDTRACK',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: hasTrack ? AppColors.textEngraved : AppColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasTrack ? 'Step 1 Ready • Tap play to preview' : 'Step 1 • Pick track to unlock Step 2 Photos',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Audio Source Buttons
                    Row(
                      children: [
                        if (widget.onQuickDemo != null) ...[
                          _RetroMiniButton(
                            label: 'DEMO',
                            icon: Icons.auto_awesome,
                            onTap: widget.onQuickDemo!,
                          ),
                          const SizedBox(width: 6),
                        ],
                        _RetroMiniButton(
                          label: 'LIBRARY',
                          icon: Icons.library_music_rounded,
                          onTap: widget.onLoadSample,
                        ),
                        const SizedBox(width: 6),
                        _RetroMiniButton(
                          label: 'FILES',
                          icon: Icons.file_upload_outlined,
                          onTap: widget.onPickAudio,
                        ),
                      ],
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
}

class _TapeReelSpool extends StatelessWidget {
  const _TapeReelSpool();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF4A3C31), // Magnetic tape core
            Color(0xFF6B5847),
            Color(0xFFC8A232), // Brass outer rim
            Color(0xFFA68523),
          ],
          stops: [0.0, 0.45, 0.9, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(1, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8E4DC),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 3 Spoke Cutouts
              for (int i = 0; i < 3; i++)
                Transform.rotate(
                  angle: (i * 2 * math.pi / 3),
                  child: Container(
                    width: 4,
                    height: 24,
                    color: const Color(0xFF2E2B28),
                  ),
                ),
              // Center brass spindle
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brassKnobGradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalogVuMeter extends StatelessWidget {
  final bool isPlaying;
  const _AnalogVuMeter({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.panelInset,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.metalBrushedDark, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('-20', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Text('-7', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Text('0', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.textEngraved)),
              Text('+3', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.vuRed)),
            ],
          ),
          const SizedBox(height: 4),
          // Swaying Needle Track
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Scale Arc Line
                Container(
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.vuGreen, AppColors.vuAmber, AppColors.vuRed],
                    ),
                  ),
                ),
                // Needle
                AnimatedAlign(
                  alignment: isPlaying ? const Alignment(0.4, 0.0) : const Alignment(-0.85, 0.0),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.elasticOut,
                  child: Container(
                    width: 2,
                    height: 24,
                    color: AppColors.vuRed,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'VU LEVEL',
            style: TextStyle(fontSize: 6, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ScrewHead extends StatelessWidget {
  const _ScrewHead();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.metalScrewHead,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 1.2,
          color: Colors.black38,
        ),
      ),
    );
  }
}

class _RetroMiniButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RetroMiniButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.metalBrushedDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.chassisBevelLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              offset: const Offset(-1, -1),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(1, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textEngraved,
              ),
            ),
          ],
        ),
      ),
    );
  }
}