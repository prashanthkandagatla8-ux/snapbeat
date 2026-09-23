import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

enum TactileButtonVariant {
  /// Piano Black lacquer CTA with contact-hero shadow.
  primaryGold,
  /// Graphite mid-tone control with contact-subtle shadow.
  secondaryGunmetal,
  /// Recessed cavity destructive action (e.g. Delete, Dismiss).
  destructive,
}

/// A responsive tactile hardware button strictly adhering to Graphite Neo v3.0.
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

    final isPrimary = widget.variant == TactileButtonVariant.primaryGold;
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
                AppColors.pianoMid,
                AppColors.pianoDeep,
                Color(0xFF08090B),
              ],
            )
          : AppColors.ctaButtonGradient;
      borderColor = const Color(0x18FFFFFF);
      textColor = AppColors.textPureWhite;
      iconColor = Colors.white;
      shadows = _isPressed ? AppColors.contactSubtle : AppColors.contactHero;
    } else if (isDestructive) {
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF28181A), Color(0xFF1D1113), Color(0xFF140B0D)],
      );
      borderColor = const Color(0x33FF5252);
      textColor = const Color(0xFFFF7A7A);
      iconColor = const Color(0xFFFF5252);
      shadows = AppColors.innerRecess;
    } else {
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.graphiteLight,
          AppColors.graphiteMid,
          AppColors.graphiteDeep,
        ],
      );
      borderColor = const Color(0x0DFFFFFF);
      textColor = AppColors.textSecondary;
      iconColor = Colors.white;
      shadows = AppColors.contactSubtle;
    }

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
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: gradient,
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: enabled ? shadows : [],
              ),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
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
    );
  }
}
