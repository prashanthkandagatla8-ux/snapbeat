import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum RetroButtonVariant {
  render('assets/images/btn_render.png', 'RENDER'),
  play('assets/images/btn_play.png', 'PLAY'),
  download('assets/images/btn_download.png', 'DOWNLOAD'),
  share('assets/images/btn_share.png', 'SHARE'),
  delete('assets/images/btn_delete.png', 'DELETE');

  final String assetPath;
  final String label;
  const RetroButtonVariant(this.assetPath, this.label);
}

/// A tactile 3D skeuomorphic retro mechanical button
/// featuring vintage brushed metal bezel and recessed red trigger.
class RetroMechanicalButton extends StatefulWidget {
  final RetroButtonVariant variant;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool isEnabled;

  /// In-memory decoded UI images (e.g. for testing & screenshot rendering)
  static final Map<RetroButtonVariant, ui.Image> uiImageCache = {};

  const RetroMechanicalButton({
    super.key,
    required this.variant,
    required this.onTap,
    this.height,
    this.width,
    this.isEnabled = true,
  });

  @override
  State<RetroMechanicalButton> createState() => _RetroMechanicalButtonState();
}

class _RetroMechanicalButtonState extends State<RetroMechanicalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && widget.onTap != null;
    final cachedUiImage = RetroMechanicalButton.uiImageCache[widget.variant];

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.variant.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        onTap: enabled ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: FittedBox(
                fit: BoxFit.contain,
                child: cachedUiImage != null
                    ? RawImage(
                        image: cachedUiImage,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      )
                    : Image.asset(
                        widget.variant.assetPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
