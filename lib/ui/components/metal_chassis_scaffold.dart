import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
      backgroundColor: AppColors.canvasChassis,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dark Brushed Gunmetal Base Texture / Gradient
          backgroundUiImage != null
              ? RawImage(
                  image: backgroundUiImage,
                  fit: BoxFit.cover,
                  color: const Color(0xFF0B0D10).withValues(alpha: 0.88),
                  colorBlendMode: BlendMode.srcOver,
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF162A32),
                        Color(0xFF0C1B20),
                        Color(0xFF0B0D10),
                        Color(0xFF050E12),
                      ],
                      stops: [0.0, 0.25, 0.65, 1.0],
                    ),
                  ),
                ),

          // 2. Ambient Studio Spotlight Glow (matches web radial-gradient)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 1.15,
                colors: [
                  AppColors.chassisBevelLight.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // 3. Subtle edge hairline highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.5,
            child: Container(
              color: AppColors.chassisBevelLight.withValues(alpha: 0.4),
            ),
          ),

          // 4. Main content
          body,
        ],
      ),
    );
  }
}
