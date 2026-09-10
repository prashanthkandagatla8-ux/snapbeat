import 'package:flutter/material.dart';

class AppColors {
  // ─── Carbon Chassis & Dark Metal Canvas ───
  static const Color canvasChassis = Color(0xFF0D0D0F);       // Near-black carbon fiber
  static const Color chassisBevelLight = Color(0xFF2A2A30);   // Subtle top highlight
  static const Color chassisBevelDark = Color(0xFF050507);    // Deep shadow

  // ─── Dark Steel Panels & Cards ───
  static const Color panelCream = Color(0xFF1A1A1E);          // Primary card surface
  static const Color panelCreamDark = Color(0xFF151518);      // Secondary card
  static const Color panelInset = Color(0xFF111114);          // Recessed bays & wells

  // ─── Brushed Metals & Hardware ───
  static const Color metalBrushedLight = Color(0xFF2E2E34);   // Brushed aluminum highlight
  static const Color metalBrushedDark = Color(0xFF1F1F24);    // Brushed aluminum shadow
  static const Color metalScrewHead = Color(0xFF555560);      // Screw/rivet detail
  static const Color hardwareGunmetal = Color(0xFF0A0A0C);    // Deep dark hardware

  // ─── SnapBeat Yellow & Gold Accents ───
  static const Color brassGold = Color(0xFFFFD54F);           // Primary accent (SnapBeat yellow)
  static const Color brassHighlight = Color(0xFFFFE082);      // Lighter yellow highlight
  static const Color brassDark = Color(0xFFC9A100);           // Pressed/dark yellow

  // ─── Backlit Indicators & VU Meters ───
  static const Color amberJewel = Color(0xFFFF8A00);          // Backlit amber LED
  static const Color amberGlow = Color(0x55FF8A00);           // Amber glow halo
  static const Color tubeWarmOrange = Color(0xFFFF6A00);      // Nixie tube warm
  static const Color vuGreen = Color(0xFF00E676);             // VU safe level
  static const Color vuAmber = Color(0xFFFFC107);             // VU mid level
  static const Color vuRed = Color(0xFFFF3D00);               // VU peak/clip

  // ─── Typography & Text ───
  static const Color textEngraved = Color(0xFFF0F0F0);        // Primary bright text
  static const Color textSecondary = Color(0xFFAAAAAF);       // Secondary text
  static const Color textMuted = Color(0xFF6B6B75);           // Muted captions
  static const Color textFoilGold = Color(0xFFFFD54F);        // Accent text (yellow)
  static const Color textWhite = Color(0xFFFFFFFF);

  // ─── Borders & Grooves ───
  static const Color grooveLight = Color(0x18FFFFFF);         // Subtle top bevel
  static const Color grooveDark = Color(0x40000000);          // Subtle bottom shadow
  static const Color borderBrass = Color(0x44FFD54F);         // Yellow border accent
  static const Color borderSubtle = Color(0x22FFFFFF);        // Faint white border

  // ─── Metallic Gradients ───
  static const LinearGradient brushedMetalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF22222A),
      Color(0xFF1A1A20),
      Color(0xFF252530),
      Color(0xFF18181E),
      Color(0xFF202028),
    ],
  );

  static const LinearGradient brassKnobGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE082),
      Color(0xFFFFD54F),
      Color(0xFFC9A100),
      Color(0xFFFFE082),
    ],
  );

  static const LinearGradient chassisPlateGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A20),
      Color(0xFF121216),
      Color(0xFF0E0E12),
    ],
  );

  // ─── New: CTA Button Gradient ───
  static const LinearGradient ctaButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE082),
      Color(0xFFFFD54F),
      Color(0xFFFFC107),
    ],
  );

  // ─── New: Dark Card Inset Shadow ───
  static List<BoxShadow> get cardInsetShadows => [
    const BoxShadow(
      color: Color(0x30000000),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
    const BoxShadow(
      color: Color(0x10FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 1,
    ),
  ];
}
