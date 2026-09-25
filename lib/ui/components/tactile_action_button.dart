import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

enum TactileButtonVariant {
  /// Piano Black lacquer CTA with piano-slab shadow.
  primaryPiano,
  /// Ceramic raised mid-tone control with ceramic-raise shadow.
  secondaryGunmetal,
  /// Recessed cavity destructive action (e.g. Delete, Dismiss).
  destructive;

  /// Backward-compatible alias for primaryPiano
  static const TactileButtonVariant primaryGold = TactileButtonVariant.primaryPiano;
}

/// A responsive tactile hardware button strictly adhering to Ceramic Duo-Tone design tokens.
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
    this.variant = TactileButtonVariant.primaryPiano,
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
  }) : variant = TactileButtonVariant.primaryPiano;

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

    final isPrimary = widget.variant == TactileButtonVariant.primaryPiano;
    final isDestructive = widget.variant == TactileButtonVariant.destructive;

    final Gradient gradient;
    final Color borderColor;
    final Color textColor;
    final Color iconColor;
    final List<BoxShadow> shadows;

    if (isPrimary) {
      gradient = _isPressed
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF090B0F),
                Color(0xFF06080B),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF161A22),
                Color(0xFF0D1015),
              ],
            );
      borderColor = const Color(0x24FFFFFF); // Fine silky rim
      textColor = AppColors.whiteText;
      iconColor = AppColors.whiteText;
      shadows = _isPressed ? const [] : AppColors.darkHardwareShadow;
    } else if (isDestructive) {
      // Recessed well with #C62828 text
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE1E5E9), Color(0xFFF2F4F6)],
      );
      borderColor = const Color(0xFFDCE1E6);
      textColor = const Color(0xFFC62828);
      iconColor = const Color(0xFFC62828);
      shadows = const [];
    } else {
      // Porcelain soft raised surface per 24-Sep spec §3.1 & §6
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF6F7F8),
          Color(0xFFF2F4F6),
        ],
      );
      borderColor = const Color(0xFFDCE1E6);
      textColor = AppColors.primaryDarkText;
      iconColor = AppColors.primaryDarkText;
      shadows = _isPressed ? const [] : AppColors.softRaisedShadow;
    }

    final double buttonRadius = widget.height >= 44 ? 22.0 : 18.0;

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
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: widget.height,
              width: widget.width,
              padding: isPrimary ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(buttonRadius + (isPrimary ? 1.5 : 0)),
                gradient: isPrimary ? AppColors.iridescentGradient : null,
                boxShadow: enabled && isPrimary
                    ? [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        ...shadows,
                      ]
                    : (enabled ? shadows : const []),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(buttonRadius),
                  gradient: gradient,
                  border: isPrimary ? null : Border.all(color: borderColor, width: 1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: iconColor),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
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
        ),
      ),
    );
  }
}
