import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A realistic skeuomorphic hardware panel encased in a brushed metal frame
/// with an outer slate-grey elevation and a 3D red lacquer dome rivet.
/// Inspired directly by the SnapBeat Studio hardware reference design.
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
    this.borderRadius = 18.0,
    this.showRedRivet = true,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppColors.metalPanelShadow,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Realistic Brushed Metallic Bezel Border Layer
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x332E3440),
                  Color(0x1A252932),
                  Color(0x0A101216),
                ],
              ),
            ),
            padding: const EdgeInsets.all(1.0), // Bezel thickness
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius - 2.5),
                // Recessed inner dark boundary lip
                border: Border.all(
                  color: const Color(0xFF050608),
                  width: 1.0,
                ),
                // Interior Studio Console Gradient Surface
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E222A),
                    Color(0xFF191C22),
                    Color(0xFF15171D),
                    Color(0xFF111317),
                  ],
                  stops: [0.0, 0.35, 0.75, 1.0],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius - 3.5),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (header != null) ...[
                        header!,
                        const SizedBox(height: 10),
                      ],
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Tactile 3D Red Lacquer Dome Rivet (Top-Right Hardware Accent)
          if (showRedRivet)
            Positioned(
              top: -4,
              right: 14,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.35, -0.4),
                    radius: 0.85,
                    colors: [
                      Color(0xFFFF7A7A), // Hotspot shine
                      Color(0xFFFF3333),
                      Color(0xFFD62828), // Deep lacquer body
                      Color(0xFF6B0000), // Shadow edge
                    ],
                    stops: [0.0, 0.25, 0.65, 1.0],
                  ),
                  border: Border.all(
                    color: const Color(0xFF261D18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF3366).withValues(alpha: 0.4),
                      blurRadius: 5,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
