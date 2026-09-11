import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashMasterRedButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final String? label;

  const SplashMasterRedButton({
    super.key,
    required this.onTap,
    this.size = 140,
    this.label,
  });

  @override
  State<SplashMasterRedButton> createState() => _SplashMasterRedButtonState();
}

class _SplashMasterRedButtonState extends State<SplashMasterRedButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    HapticFeedback.heavyImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 70),
            curve: Curves.easeOutQuad,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.25 : 0.45),
                    blurRadius: _isPressed ? 8 : 16,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Physical unpressed button
                  AnimatedOpacity(
                    opacity: _isPressed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 50),
                    child: Image.asset(
                      'assets/images/red_button_unpressed.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Physical depressed / pressed-down button state
                  AnimatedOpacity(
                    opacity: _isPressed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 50),
                    child: Image.asset(
                      'assets/images/red_button_pressed.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 10),
          Text(
            widget.label!,
            style: const TextStyle(
              color: Color(0xFF2B2B2D),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Color(0x99FFFFFF),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
