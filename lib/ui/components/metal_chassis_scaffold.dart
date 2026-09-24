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
      backgroundColor: AppColors.ceramicWhite,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Pure Ceramic Substrate Canvas
          Container(
            color: AppColors.ceramicWhite,
          ),

          // 2. Top-Left Studio Softbox Specular Illumination
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.6, -0.8),
                  radius: 1.5,
                  colors: [
                    Color(0x30FFFFFF),
                    Colors.transparent,
                  ],
                ),
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
