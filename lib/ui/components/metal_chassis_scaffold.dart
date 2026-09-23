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
      backgroundColor: AppColors.graphiteSubstrate,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Graphite Neo v3.0 Continuous Substrate (#2B2D30)
          backgroundUiImage != null
              ? RawImage(
                  image: backgroundUiImage,
                  fit: BoxFit.cover,
                  color: AppColors.graphiteSubstrate.withValues(alpha: 0.90),
                  colorBlendMode: BlendMode.srcOver,
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.graphiteLight,     // #303236
                        AppColors.graphiteSubstrate, // #2B2D30
                        AppColors.graphiteMid,       // #292B2E
                        AppColors.graphiteDeep,      // #26282B
                      ],
                      stops: [0.0, 0.35, 0.70, 1.0],
                    ),
                  ),
                ),

          // 2. Single Top-Left Studio Softbox Illumination
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.7),
                radius: 1.6,
                colors: [
                  Colors.white.withValues(alpha: 0.035),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.18),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // 3. Subtle Substrate Edge Catchlight (1px)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.0,
            child: Container(
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),

          // 4. Main content (Zero layout modification)
          body,
        ],
      ),
    );
  }
}
