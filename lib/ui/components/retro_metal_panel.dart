import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// SNAPBEAT STUDIO – GRAPHITE NEO v3.0 Hardware Panel
/// Precision graphite console panel with contact-subtle elevation and optical bevel.
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
        boxShadow: AppColors.contactSubtle,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Graphite Neo Panel Surface
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: const Color(0x0AFFFFFF), // Subtle 1px edge catchlight
                width: 1.0,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.graphiteLight,     // #303236
                  AppColors.graphiteSubstrate, // #2B2D30
                  AppColors.graphiteMid,       // #292B2E
                ],
                stops: [0.0, 0.20, 1.0],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1),
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

          // 2. Hardware Indicator LED (Top-Right Restrained Status Dot)
          if (showRedRivet)
            Positioned(
              top: 6,
              right: 12,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.indicatorAccent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indicatorAccent.withValues(alpha: 0.6),
                      blurRadius: 4,
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
