import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

enum TactileButtonVariant {
  /// Golden-amber capsule CTA styled after the "Start Creating" button in the reference UI.
  primaryGold,
  /// Brushed gunmetal with metallic bevel and glowing jewel accent.
  secondaryGunmetal,
  /// Recessed cavity action (e.g. Delete, Dismiss).
  destructive,
}

/// A responsive, vector-rendered tactile hardware button replacing old raster cutouts.
class TactileActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final TactileButtonVariant variant;
  final double height;
  final double? width;
  final bool isEnabled;

  const TactileActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.variant = TactileButtonVariant.primaryGold,
    this.height = 46.0,
    this.width,
    this.isEnabled = true,
  });

  const TactileActionButton.primary({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.height = 46.0,
    this.width,
    this.isEnabled = true,
  }) : variant = TactileButtonVariant.primaryGold;

  const TactileActionButton.secondary({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.height = 46.0,
    this.width,
    this.isEnabled = true,
  }) : variant = TactileButtonVariant.secondaryGunmetal;

  const TactileActionButton.destructive({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.height = 46.0,
    this.width,
    this.isEnabled = true,
  }) : variant = TactileButtonVariant.destructive;

  @override
  State<TactileActionButton> createState() => _TactileActionButtonState();
}

class _TactileActionButtonState extends State<TactileActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && widget.onTap != null;

    // Dimensions and styling based on variant
    final isGold = widget.variant == TactileButtonVariant.primaryGold;
    final isDestructive = widget.variant == TactileButtonVariant.destructive;

    final gradient = isGold
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [
                    const Color(0xFFFFD54F),
                    const Color(0xFFFFC72C),
                    const Color(0xFFC69200),
                  ]
                : [
                    const Color(0xFFFFF0B3),
                    const Color(0xFFFFD54F),
                    const Color(0xFFFFC72C),
                    const Color(0xFFD49A00),
                  ],
            stops: _isPressed ? const [0.0, 0.4, 1.0] : const [0.0, 0.25, 0.7, 1.0],
          )
        : isDestructive
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3A1818), Color(0xFF220D0D), Color(0xFF160808)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF28363D), Color(0xFF17242A), Color(0xFF0F1A1F)],
              );

    final borderColor = isGold
        ? (_isPressed ? const Color(0xFFBF8A00) : const Color(0xFFFFE082))
        : isDestructive
            ? const Color(0xFF7A2020)
            : const Color(0xFF3E5A66);

    final textColor = isGold
        ? const Color(0xFF14120B)
        : isDestructive
            ? const Color(0xFFFF7A7A)
            : AppColors.textEngraved;

    final iconColor = isGold
        ? const Color(0xFF14120B)
        : isDestructive
            ? const Color(0xFFFF5252)
            : (widget.variant == TactileButtonVariant.secondaryGunmetal
                ? AppColors.brassGold
                : AppColors.textSecondary);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled
            ? (_) {
                HapticFeedback.lightImpact();
                setState(() => _isPressed = true);
              }
            : null,
        onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.mediumImpact();
                widget.onTap?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: widget.height,
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: gradient,
                border: Border.all(color: borderColor, width: 1.4),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: isGold
                              ? const Color(0xFFFFC72C).withValues(alpha: _isPressed ? 0.2 : 0.4)
                              : Colors.black.withValues(alpha: 0.5),
                          offset: _isPressed ? const Offset(0, 1) : const Offset(0, 4),
                          blurRadius: _isPressed ? 4 : 10,
                          spreadRadius: _isPressed ? 0 : 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 17, color: iconColor),
                    const SizedBox(width: 7),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
