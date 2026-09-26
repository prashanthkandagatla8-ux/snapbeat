import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A real animated retro-modern vinyl turntable player deck.
/// Features:
/// - Stadium / pill tactile ceramic console with 3D specular bevel.
/// - Recessed vinyl well with authentic grooved disc that rotates continuously at 33 RPM when playing.
/// - Mechanical tonearm that smoothly pivots onto the record groove when playing and swings back when paused.
/// - Clean typography header for Artist / Genre and Track Name.
/// - Tactile circular mechanical push-buttons (Previous, Master Play/Pause, Next, Library).
/// - Radial arc progress scrubber conforming to the stadium pill's curved right edge.
class RetroTurntableDeck extends StatefulWidget {
  final bool isPlaying;
  final String trackTitle;
  final String? artistOrGenre;
  final String? bpm;
  final double currentSeconds;
  final double totalSeconds;
  final VoidCallback onTogglePlay;
  final VoidCallback? onStop;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onOpenLibrary;
  final ValueChanged<double>? onSeek;

  const RetroTurntableDeck({
    super.key,
    required this.isPlaying,
    required this.trackTitle,
    this.artistOrGenre,
    this.bpm,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.onTogglePlay,
    this.onStop,
    this.onPrevious,
    this.onNext,
    this.onOpenLibrary,
    this.onSeek,
  });

  @override
  State<RetroTurntableDeck> createState() => _RetroTurntableDeckState();
}

class _RetroTurntableDeckState extends State<RetroTurntableDeck>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _tonearmController;
  late Animation<double> _tonearmAngle;

  @override
  void initState() {
    super.initState();

    // Vinyl 33 RPM continuous rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Mechanical tonearm pivot animation (rest -> groove)
    _tonearmController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _tonearmAngle = Tween<double>(begin: 0.0, end: 0.28).animate(
      CurvedAnimation(
        parent: _tonearmController,
        curve: Curves.easeInOutCubic,
      ),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
      _tonearmController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RetroTurntableDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
        _tonearmController.forward();
      } else {
        _rotationController.stop();
        _tonearmController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _tonearmController.dispose();
    super.dispose();
  }

  String _formatDuration(double secs) {
    if (secs.isNaN || secs.isInfinite || secs < 0) return '0:00';
    final m = secs ~/ 60;
    final s = (secs % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _cleanTrackTitle(String raw) {
    var title = raw.replaceAll('.mp3', '').replaceAll('.wav', '');
    title = title.replaceAll(RegExp(r'\(\s*\d+\s*BPM\s*\)', caseSensitive: false), '').trim();
    if (title.isEmpty) return 'Selected Track';
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeconds > 0
        ? (widget.currentSeconds / widget.totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final cleanTitle = _cleanTrackTitle(widget.trackTitle);
    final genreLabel = widget.artistOrGenre?.toUpperCase() ?? 'ORIGINAL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(55),
        border: Border.all(color: AppColors.ceramicWhiteRim, width: 1.2),
        boxShadow: AppColors.tactile3DBevel,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── 1. Left: Animated Turntable with Spinning Vinyl & Tonearm ───
              _buildTurntableSection(cleanTitle),

              const SizedBox(width: 14),

              // ─── 2. Center: Track Metadata & Cylindrical Push Buttons ───
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artist / Track Title Headline
                    Text(
                      '$genreLabel / $cleanTitle'.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: AppColors.primaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Duration Readout
                    Text(
                      'Duration: ${_formatDuration(widget.currentSeconds)} / ${_formatDuration(widget.totalSeconds)}'
                      '${widget.bpm != null ? " · ${widget.bpm} BPM" : ""}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.secondaryDarkText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tactile Mechanical Button Console (Row of 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Previous Track Button
                        _buildTactileCircularButton(
                          size: 34,
                          icon: Icons.skip_previous_rounded,
                          iconSize: 18,
                          onTap: widget.onPrevious,
                        ),
                        const SizedBox(width: 8),

                        // Master Play / Pause Button (Accented with 3D Bevel)
                        _buildMasterPlayPauseButton(size: 42),

                        const SizedBox(width: 8),

                        // Next Track Button
                        _buildTactileCircularButton(
                          size: 34,
                          icon: Icons.skip_next_rounded,
                          iconSize: 18,
                          onTap: widget.onNext,
                        ),
                        const SizedBox(width: 8),

                        // Sound Library / Playlist Trigger
                        _buildTactileCircularButton(
                          size: 34,
                          icon: Icons.format_list_bulleted_rounded,
                          iconSize: 16,
                          onTap: widget.onOpenLibrary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ─── 3. Right: Radial Arc Scrubber conforming to Capsule Edge ───
              if (!isNarrow)
                _buildRadialArcScrubber(progress),
            ],
          );
        },
      ),
    );
  }

  /// Left Turntable Well with Spinning Vinyl Record & Pivot Tonearm
  Widget _buildTurntableSection(String cleanTitle) {
    const double wellSize = 106.0;
    const double vinylSize = 94.0;

    return SizedBox(
      width: wellSize,
      height: wellSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Recessed Circular Turntable Well
          Container(
            width: wellSize,
            height: wellSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF07090D),
              border: Border.all(color: const Color(0x30FFFFFF), width: 1.2),
              boxShadow: const [
                // Inset depth well shadow
                BoxShadow(
                  color: Color(0x70000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),

          // Spinning Vinyl Disc
          RotationTransition(
            turns: _rotationController,
            child: Container(
              width: vinylSize,
              height: vinylSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF1E222B),
                    Color(0xFF0F1218),
                    Color(0xFF141820),
                    Color(0xFF080A0E),
                    Color(0xFF161A22),
                    Color(0xFF050608),
                  ],
                  stops: [0.0, 0.25, 0.45, 0.65, 0.85, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _VinylGroovePainter(),
                child: Center(
                  // Center Record Label Sticker
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF3366),
                          Color(0xFFB026FF),
                        ],
                      ),
                      border: Border.all(color: Colors.white38, width: 0.8),
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), blurRadius: 2),
                      ],
                    ),
                    child: Center(
                      // Center Spindle Hole
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF050608),
                          boxShadow: [
                            BoxShadow(color: Colors.white24, blurRadius: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tonearm with Smooth Pivot Animation
          Positioned(
            top: 6,
            right: 4,
            child: AnimatedBuilder(
              animation: _tonearmAngle,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _tonearmAngle.value,
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 38,
                    height: 60,
                    child: CustomPaint(
                      painter: _TonearmPainter(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Standard Extruded Cylindrical Push Button
  Widget _buildTactileCircularButton({
    required double size,
    required IconData icon,
    required double iconSize,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF0EBE3),
          border: Border.all(color: const Color(0xFFD6CFC3), width: 1.0),
          boxShadow: [
            // Ambient soft drop shadow
            BoxShadow(
              color: const Color(0xFF383025).withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            // Top specular catchlight lip
            const BoxShadow(
              color: Color(0xB0FFFFFF),
              blurRadius: 1,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: AppColors.primaryDarkText,
          ),
        ),
      ),
    );
  }

  /// Master Center Play/Pause Button (Accented with Specular Rim & Glowing Diode)
  Widget _buildMasterPlayPauseButton({required double size}) {
    return GestureDetector(
      onTap: widget.onTogglePlay,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE84545),
              Color(0xFFCC2B2B),
              Color(0xFFA81818),
            ],
          ),
          border: Border.all(color: const Color(0xFFFFA4A4), width: 1.2),
          boxShadow: [
            // Radiant glow shadow
            BoxShadow(
              color: const Color(0xFFE84545).withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            // Contact depth shadow
            const BoxShadow(
              color: Color(0x35000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Radial Arc Scrubber conforming to the right curved edge of the stadium pill
  Widget _buildRadialArcScrubber(double progress) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (widget.onSeek != null && widget.totalSeconds > 0) {
          // Allow interactive drag seeking
          final delta = -details.primaryDelta! / 50.0;
          final newProgress = (progress + delta).clamp(0.0, 1.0);
          widget.onSeek!(newProgress * widget.totalSeconds);
        }
      },
      child: SizedBox(
        width: 32,
        height: 84,
        child: CustomPaint(
          painter: _RadialArcScrubberPainter(
            progress: progress,
            activeColor: const Color(0xFFE84545),
            trackColor: const Color(0xFFD6CFC3),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for authentic vinyl micro-grooves
class _VinylGroovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Draw realistic concentric vinyl grooves
    const grooveSteps = [20.0, 24.0, 28.0, 31.0, 35.0, 38.0, 41.0, 44.0];
    for (int i = 0; i < grooveSteps.length; i++) {
      paint.color = i % 2 == 0 ? const Color(0x25FFFFFF) : const Color(0x35000000);
      canvas.drawCircle(center, grooveSteps[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for mechanical tonearm and stylus needle
class _TonearmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Pivot Gimbal Base (top-right)
    final pivotCenter = Offset(size.width - 6, 8);
    final pivotPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pivotCenter, 6, pivotPaint);

    final rimPaint = Paint()
      ..color = const Color(0xFF6B7280)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(pivotCenter, 6, rimPaint);

    // 2. Chrome Tonearm Tube
    final armPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;

    final path = Path();
    path.moveTo(pivotCenter.dx, pivotCenter.dy);
    // Smooth S-curve down toward platter
    path.cubicTo(
      pivotCenter.dx - 10, pivotCenter.dy + 18,
      pivotCenter.dx - 18, pivotCenter.dy + 34,
      4, size.height - 8,
    );
    canvas.drawPath(path, armPaint);

    // 3. Headshell & Cartridge (at the tip)
    final headshellPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(4, size.height - 7), width: 7, height: 11),
      const Radius.circular(2),
    );
    canvas.drawRRect(headRect, headshellPaint);

    // Stylus needle tip
    final needlePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(4, size.height - 2), 1.2, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the right-hand curved radial arc scrubber
class _RadialArcScrubberPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _RadialArcScrubberPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Arc curves along the right pill cap
    final center = Offset(-size.width * 0.4, size.height / 2);
    final radius = size.height * 0.48;
    const startAngle = -math.pi / 2.7;
    const sweepAngle = math.pi * 0.74;

    // 1. Inset Background Track
    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Active Glowing Progress Arc
    if (progress > 0.0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0;

      final activeSweep = sweepAngle * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        activePaint,
      );

      // 3. Sliding Indicator Knob on the arc tip
      final currentAngle = startAngle + activeSweep;
      final knobX = center.dx + radius * math.cos(currentAngle);
      final knobY = center.dy + radius * math.sin(currentAngle);

      final knobPaint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(knobX, knobY), 4.5, knobPaint);

      final knobBorder = Paint()
        ..color = const Color(0xFF07090D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(knobX, knobY), 4.5, knobBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialArcScrubberPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
