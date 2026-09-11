import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tactile3DButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onTap;
  final Color baseColor;
  final Color highlightColor;
  final Color shadowColor;
  final Color textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final double bevelHeight;
  final bool isExpanded;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const Tactile3DButton({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    required this.onTap,
    this.baseColor = const Color(0xFFFFC72C),
    this.highlightColor = const Color(0xFFFFE082),
    this.shadowColor = const Color(0xFFBF8A00),
    this.textColor = const Color(0xFF1E1A10),
    this.height = 52,
    this.width,
    this.borderRadius = 28,
    this.bevelHeight = 4.0,
    this.isExpanded = false,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<Tactile3DButton> createState() => _Tactile3DButtonState();
}

class _Tactile3DButtonState extends State<Tactile3DButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    widget.onTap!();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double translateY = _isPressed ? widget.bevelHeight : 0.0;

    Widget buttonContent = SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          // Bottom 3D shadow layer (anchored at base)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: widget.height - widget.bevelHeight,
              decoration: BoxDecoration(
                color: widget.shadowColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Tactile button top face that translates downward on press
          AnimatedPositioned(
            duration: const Duration(milliseconds: 60),
            curve: Curves.easeOutQuad,
            top: translateY,
            left: 0,
            right: 0,
            child: Container(
              height: widget.height - widget.bevelHeight,
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.highlightColor,
                    widget.baseColor,
                    widget.shadowColor.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 8),
                  ] else if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: widget.textStyle ??
                        TextStyle(
                          color: widget.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: buttonContent,
    );
  }
}
