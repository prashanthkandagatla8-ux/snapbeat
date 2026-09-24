import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// True Neomorphic UI Primitives for SnapBeat Studio
/// Implements dual-light physics (top-left specular highlight + bottom-right occlusion)
/// with zero external packages.

class NeumorphicKit {
  /// Raised Porcelain Pill or Tile decoration
  static BoxDecoration raised({
    double radius = 16,
    Color surfaceColor = AppColors.ceramicWhite,
    Border? border,
  }) {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppColors.neumorphicRaisedCard,
      border: border ?? Border.all(color: const Color(0x99FFFFFF), width: 1.0),
    );
  }

  /// Compact Raised Pill (buttons, chips, tags)
  static BoxDecoration raisedPill({
    double radius = 24,
    Color surfaceColor = AppColors.ceramicWhite,
  }) {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppColors.neumorphicRaisedPill,
      border: Border.all(color: const Color(0xCCFFFFFF), width: 1.0),
    );
  }

  /// High-Contrast Piano Black Raised Pill (Primary CTAs)
  static BoxDecoration pianoBlackPill({
    double radius = 24,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF222631),
          Color(0xFF101319),
          Color(0xFF07090C),
        ],
      ),
      boxShadow: AppColors.neumorphicBlackRaised,
      border: Border.all(color: const Color(0x20FFFFFF), width: 0.8),
    );
  }

  /// Sunken / Recessed Well (Grooves, sliders, instruction containers)
  static BoxDecoration sunkenWell({
    double radius = 12,
  }) {
    return BoxDecoration(
      color: const Color(0xFFE4EAF2),
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFDAE1EB),
          Color(0xFFECF1F7),
        ],
      ),
      border: Border.all(color: const Color(0x30A3B1C6), width: 1.0),
      boxShadow: const [
        BoxShadow(color: Color(0x40A3B1C6), offset: Offset(2, 2), blurRadius: 4, spreadRadius: -1),
        BoxShadow(color: Color(0x80FFFFFF), offset: Offset(-2, -2), blurRadius: 4, spreadRadius: -1),
      ],
    );
  }
  /// Raised Ceramic Tile for photo cards — dual-shadow extrusion
  static BoxDecoration raisedTile({
    double radius = 12,
  }) {
    return BoxDecoration(
      color: const Color(0xFFFDFEFF),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppColors.neumorphicRaisedTile,
      border: Border.all(
        color: const Color(0xB3FFFFFF),
        width: 1.0,
      ),
    );
  }

  /// Dark Sunken Well for dark-surface recessed tracks (mode selectors on black dock)
  static BoxDecoration darkSunkenWell({
    double radius = 10,
  }) {
    return BoxDecoration(
      color: const Color(0xFF090A0E),
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF060710),
          Color(0xFF0E1018),
        ],
      ),
      border: Border.all(color: const Color(0x18FFFFFF), width: 1.0),
      boxShadow: const [
        BoxShadow(color: Color(0x60000000), offset: Offset(2, 2), blurRadius: 4, spreadRadius: -1),
        BoxShadow(color: Color(0x14FFFFFF), offset: Offset(-1, -1), blurRadius: 3, spreadRadius: -1),
      ],
    );
  }

}
