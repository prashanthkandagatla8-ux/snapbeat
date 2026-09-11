import 'package:flutter/material.dart';

class SnapBeatPinkDot extends StatelessWidget {
  final double size;
  final bool withGlow;

  const SnapBeatPinkDot({
    super.key,
    this.size = 14,
    this.withGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFFF3366).withValues(alpha: 0.45),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Image.asset(
        'assets/images/snapbeat_pink_dot.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
