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
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
