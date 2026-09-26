import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SnapBeatPinkDot extends StatelessWidget {
  final double size;
  final bool withGlow;

  const SnapBeatPinkDot({
    super.key,
    this.size = 9,
    this.withGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.iridescentGradient,
        shape: BoxShape.circle,
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
