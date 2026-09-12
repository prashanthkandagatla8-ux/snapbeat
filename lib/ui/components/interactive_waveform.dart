import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class InteractiveWaveform extends StatefulWidget {
  final String trackTitle;
  final double durationSeconds;
  final double startSeconds;
  final double endSeconds;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final Function(double start, double end) onTrimChanged;

  const InteractiveWaveform({
    super.key,
    this.trackTitle = "Master Sound Track",
    required this.durationSeconds,
    required this.startSeconds,
    required this.endSeconds,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onTrimChanged,
  });

  @override
  State<InteractiveWaveform> createState() => _InteractiveWaveformState();
}

class _InteractiveWaveformState extends State<InteractiveWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dur = widget.durationSeconds > 0 ? widget.durationSeconds : 45.0;
    if (dur < 1.0) dur = 1.0;

    double startMax = (dur - 1.0).clamp(0.0, dur);
    if (startMax <= 0.0) startMax = 0.1; // Ensure max > min

    double endMin = (widget.startSeconds + 0.5).clamp(0.5, dur);
    double endMax = dur;
    if (endMax <= endMin) endMax = endMin + 0.1; // Ensure max > min

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chassisBevelLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppColors.brassKnobGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TRIM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.hardwareGunmetal,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AUDIO TRIM',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${(widget.endSeconds - widget.startSeconds).toStringAsFixed(1)}s Selected',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textFoilGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recessed Waveform Display
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.panelInset,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.chassisBevelDark, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomPaint(
                  painter: _RetroWaveformPainter(
                    startRatio: (widget.startSeconds / dur).clamp(0.0, 1.0),
                    endRatio: (widget.endSeconds / dur).clamp(0.0, 1.0),
                    pulseValue: _pulseController.value,
                    isPlaying: widget.isPlaying,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Analog Sliders for Start & End Trims
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'START: ${widget.startSeconds.toStringAsFixed(1)}s',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.amberJewel,
                        inactiveTrackColor: AppColors.panelInset,
                        thumbColor: AppColors.amberJewel,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: widget.startSeconds.clamp(0.0, startMax),
                        min: 0.0,
                        max: startMax,
                        onChanged: (val) {
                          final clamped = val.clamp(0.0, widget.endSeconds - 0.5);
                          widget.onTrimChanged(clamped, widget.endSeconds);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'END: ${widget.endSeconds.toStringAsFixed(1)}s',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.amberJewel,
                        inactiveTrackColor: AppColors.panelInset,
                        thumbColor: AppColors.amberJewel,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: widget.endSeconds.clamp(endMin, endMax),
                        min: endMin,
                        max: endMax,
                        onChanged: (val) {
                          final clamped = val.clamp(widget.startSeconds + 0.5, widget.durationSeconds);
                          widget.onTrimChanged(widget.startSeconds, clamped);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RetroWaveformPainter extends CustomPainter {
  final double startRatio;
  final double endRatio;
  final double pulseValue;
  final bool isPlaying;

  _RetroWaveformPainter({
    required this.startRatio,
    required this.endRatio,
    required this.pulseValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 42;
    final barWidth = size.width / (barCount * 1.6);
    final spacing = barWidth * 0.6;

    final unselectedPaint = Paint()
      ..color = const Color(0xFF4A443A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final activePaint = Paint()
      ..color = AppColors.amberJewel
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final heights = [
      0.3, 0.5, 0.7, 0.4, 0.9, 0.8, 0.6, 0.3, 0.5, 0.8, 0.95, 0.7,
      0.4, 0.6, 0.85, 0.5, 0.3, 0.7, 0.9, 0.65, 0.4, 0.8, 0.9, 0.6,
      0.45, 0.7, 0.8, 0.55, 0.35, 0.6, 0.9, 0.75, 0.5, 0.8, 0.6, 0.4,
      0.3, 0.55, 0.7, 0.45, 0.3, 0.2
    ];

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing) + barWidth / 2;
      final ratio = i / barCount;
      final isSelected = ratio >= startRatio && ratio <= endRatio;

      double h = heights[i % heights.length] * size.height * 0.85;
      if (isSelected && isPlaying) {
        h *= (0.8 + 0.3 * pulseValue);
      }

      final yTop = (size.height - h) / 2;
      final yBottom = yTop + h;

      canvas.drawLine(
        Offset(x, yTop),
        Offset(x, yBottom),
        isSelected ? activePaint : unselectedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RetroWaveformPainter oldDelegate) {
    return oldDelegate.startRatio != startRatio ||
        oldDelegate.endRatio != endRatio ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isPlaying != isPlaying;
  }
}