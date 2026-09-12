import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'hardware_accents.dart';

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
      backgroundColor: const Color(0xFFC2B8A5),
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-resolution clean brushed metal plate texture from wishlist
          backgroundUiImage != null
              ? RawImage(
                  image: backgroundUiImage,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/brushed_metal_background.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFC8C4BD),
                    Color(0xFFC2B8A5),
                    Color(0xFFAFA592),
                    Color(0xFF8F8B83),
                  ],
                ),
              ),
            ),
          ),

          // 2. Subtle directional room light gradient & vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.1,
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // 3. Corner industrial screws
          const Positioned(top: 10, left: 10, child: HardwareScrew()),
          const Positioned(top: 10, right: 10, child: HardwareScrew()),
          const Positioned(bottom: 10, left: 10, child: HardwareScrew()),
          const Positioned(bottom: 10, right: 10, child: HardwareScrew()),

          // 4. Main content
          body,
        ],
      ),
    );
  }
}
