import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// SNAPBEAT STUDIO – FLOATING HIGH-GLOSS SHINY PIANO BLACK HARDWARE CONSOLE PANEL
/// Neumorphic luxury panel:
/// - 3D extruded beveled liquid lacquer (#07080A -> #030405 -> #000000)
/// - 0.5px liquid gloss specular rim chamfer (AppColors.specularRim)
/// - Dual-shadow neumorphic lighting: top-left specularHighlight + bottom-right ambientShadow
/// Reference: watermark_clean.png
class RetroMetalPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool showRedRivet;
  final Widget? header;

  const RetroMetalPanel({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 26.0,
    this.showRedRivet = false,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0xFFF2F4F6),
        boxShadow: AppColors.mediumRaisedShadow,
        border: Border.all(
          color: const Color(0xB3FFFFFF),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 1.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header != null) ...[
                  header!,
                  const SizedBox(height: 12),
                ],
                child,
              ],
            ),
          ),
        ),
    );
  }
}
