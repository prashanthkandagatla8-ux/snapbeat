import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// SNAPBEAT STUDIO – OBSIDIAN CANVAS HARDWARE CHASSIS SCAFFOLD
/// Near-pure black obsidian substrate (#020304) with ambient specular catchlight
/// and subtle watermark contour backdrop.
class MetalChassisScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  static ui.Image? backgroundUiImage;

  const MetalChassisScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianCanvas,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Pure Obsidian Substrate Canvas (#020304)
          Container(
            color: AppColors.obsidianCanvas,
          ),

          // 2. Top-Left Studio Softbox Specular Illumination
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.8),
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.035),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Subtle Branded Watermark Contour Backdrop
          Positioned(
            bottom: 120,
            right: -40,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/watermark_clean.png',
                width: 320,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 5. Main Content Foreground
          Positioned.fill(
            child: body,
          ),
        ],
      ),
    );
  }
}
