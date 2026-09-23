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
    this.borderRadius = 20.0,
    this.showRedRivet = false,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          // Neumorphic dual-shadow: top-left specular highlight + bottom-right ambient shadow
          BoxShadow(
            color: AppColors.specularHighlight,
            offset: Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.ambientShadow,
            offset: Offset(3, 6),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          // 0.5px liquid gloss specular rim chamfer
          border: Border.all(
            color: AppColors.specularRim,
            width: 0.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF07080A), // 3D Extruded beveled liquid lacquer
              Color(0xFF030405),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.4, 1.0],
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
      ),
    );
  }
}
