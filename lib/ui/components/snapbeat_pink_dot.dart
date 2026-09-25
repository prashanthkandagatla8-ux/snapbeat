import 'package:flutter/material.dart';

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
        color: const Color(0xFFFF3366),
        shape: BoxShape.circle,
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFFF3366).withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
