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
    this.trackTitle = "Summer Acoustic Beat",
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dur = widget.durationSeconds > 0 ? widget.durationSeconds : 45.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGold),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Play/Pause and Title
          Row(
            children: [
              GestureDetector(
                onTap: widget.onTogglePlay,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldPrimary, AppColors.goldBright],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trackTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.amberBadgeBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                          ),
                          child: Text(
                            "128 BPM",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.goldBright,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "44.1 kHz • Stereo Master",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: const Text(
                  "SYNCED",
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Waveform Canvas
          SizedBox(
            height: 64,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 64),
                  painter: _WaveformPainter(
                    pulse: _pulseController.value,
                    isPlaying: widget.isPlaying,
                    startFrac: (widget.startSeconds / dur).clamp(0.0, 1.0),
                    endFrac: (widget.endSeconds / dur).clamp(0.0, 1.0),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Dual Trim Sliders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Start: ${_formatTime(widget.startSeconds)}",
                style: const TextStyle(fontSize: 10, color: AppColors.goldBright, fontWeight: FontWeight.bold),
              ),
              Text(
                "Duration: ${_formatTime(widget.endSeconds - widget.startSeconds)}",
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                "End: ${_formatTime(widget.endSeconds)}",
                style: const TextStyle(fontSize: 10, color: AppColors.goldBright, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(
              widget.startSeconds.clamp(0.0, dur - 3),
              widget.endSeconds.clamp(widget.startSeconds + 3, dur),
            ),
            min: 0.0,
            max: dur,
            activeColor: AppColors.goldPrimary,
            inactiveColor: AppColors.borderSubtle,
            onChanged: (values) {
              if (values.end - values.start >= 3) {
                widget.onTrimChanged(values.start, values.end);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(double sec) {
    final s = sec.toInt();
    final m = s ~/ 60;
    final rem = s % 60;
    return "$m:${rem.toString().padLeft(2, '0')}";
  }
}

class _WaveformPainter extends CustomPainter {
  final double pulse;
  final bool isPlaying;
  final double startFrac;
  final double endFrac;

  _WaveformPainter({
    required this.pulse,
    required this.isPlaying,
    required this.startFrac,
    required this.endFrac,
  });

  static const List<double> _peaks = [
    0.2, 0.4, 0.7, 0.9, 0.6, 0.8, 1.0, 0.75, 0.4, 0.65,
    0.85, 0.95, 0.7, 0.5, 0.8, 0.9, 0.6, 0.45, 0.7, 0.85,
    0.95, 0.6, 0.4, 0.7, 0.8, 0.5, 0.75, 0.9, 0.65, 0.35
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(bgRRect, Paint()..color = const Color(0xFF0C0E14));

    // Draw active trim highlight zone
    final highlightLeft = size.width * startFrac;
    final highlightRight = size.width * endFrac;
    final highlightRect = Rect.fromLTRB(highlightLeft, 0, highlightRight, size.height);
    canvas.drawRect(
      highlightRect,
      Paint()..color = AppColors.goldPrimary.withOpacity(0.12),
    );

    final barWidth = (size.width / _peaks.length) * 0.65;
    final spacing = (size.width / _peaks.length) * 0.35;

    for (int i = 0; i < _peaks.length; i++) {
      final x = i * (barWidth + spacing) + barWidth / 2;
      final peakRatio = _peaks[i];
      final dynamicHeight = isPlaying
          ? size.height * (peakRatio * (0.8 + 0.2 * pulse)) * 0.85
          : size.height * peakRatio * 0.8;

      final isInsideTrim = x >= highlightLeft && x <= highlightRight;
      final barPaint = Paint()
        ..color = isInsideTrim
            ? AppColors.goldBright.withOpacity(0.9)
            : AppColors.textDim.withOpacity(0.35)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      final top = (size.height - dynamicHeight) / 2;
      final bottom = top + dynamicHeight;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), barPaint);
    }

    // Draggable boundary needles
    final handlePaint = Paint()
      ..color = AppColors.goldBright
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(highlightLeft, 0), Offset(highlightLeft, size.height), handlePaint);
    canvas.drawLine(Offset(highlightRight, 0), Offset(highlightRight, size.height), handlePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.startFrac != startFrac ||
        oldDelegate.endFrac != endFrac;
  }
}
