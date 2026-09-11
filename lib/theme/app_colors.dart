import 'package:flutter/material.dart';

class AppColors {
  // ─── Confirmed Warm Brushed Metal Chassis ───
  static const Color metalHighlight = Color(0xFFC8C4BD);    // Top light wash highlight
  static const Color metalBase = Color(0xFFC2B8A5);         // Warmer beige-grey mid metal
  static const Color metalShadow = Color(0xFF8F8B83);       // Bottom vignette & cavity shadow
  static const Color metalDeepCavity = Color(0xFF1E1C1A);   // Inner punched recess
  static const Color metalScrewHead = Color(0xFF5A5752);    // Screw/rivet detail
  static const Color hardwareGunmetal = Color(0xFF2A2826);  // Dark hardware

  // ─── Backward-compatible chassis & panels ───
  static const Color canvasChassis = Color(0xFFC2B8A5);       // Warm metal canvas
  static const Color chassisBevelLight = Color(0xFFE2DDD5);   // Specular top edge
  static const Color chassisBevelDark = Color(0xFF7A766F);    // Edge bevel shadow
  static const Color panelCream = Color(0xFFD4CDC0);          // Primary metal card surface
  static const Color panelCreamDark = Color(0xFFB8AE9E);      // Secondary recessed card
  static const Color panelInset = Color(0xFFA89F90);          // Recessed bays & wells
  static const Color metalBrushedLight = Color(0xFFD2CCC0);
  static const Color metalBrushedDark = Color(0xFFA0988A);

  // ─── SnapBeat Bubbly Yellow & Gold ───
  static const Color yellowPrimary = Color(0xFFFFC72C);     // Primary button & logo yellow
  static const Color yellowSpecular = Color(0xFFFFE082);    // Specular top light
  static const Color yellowShadow = Color(0xFFBF8A00);      // Bevel depth & 3D shadow
  static const Color brassGold = Color(0xFFFFC72C);
  static const Color brassHighlight = Color(0xFFFFE082);
  static const Color brassDark = Color(0xFFBF8A00);

  // ─── Master Red Lacquer ───
  static const Color redSurface = Color(0xFFD62828);        // Center dome lacquer
  static const Color redGloss = Color(0xFFFF4D4D);          // Specular hotspot
  static const Color redSocket = Color(0xFF7A0000);         // Recessed dark rim
  static const Color redDeepRim = Color(0xFF17120F);        // Pitch dark bezel shadow

  // ─── Pink / Coral Sphere Accent ───
  static const Color pinkAccent = Color(0xFFFF3366);        // Vibrancy dot
  static const Color pinkGlow = Color(0xFFFF5588);

  // ─── Backlit Indicators & VU Meters ───
  static const Color amberJewel = Color(0xFFFF8A00);        // Backlit amber LED
  static const Color amberGlow = Color(0x55FF8A00);         // Amber glow halo
  static const Color tubeWarmOrange = Color(0xFFFF6A00);    // Nixie tube warm
  static const Color vuGreen = Color(0xFF00C853);           // VU safe level
  static const Color vuAmber = Color(0xFFFFB300);           // VU mid level
  static const Color vuRed = Color(0xFFD50000);             // VU peak/clip

  // ─── Stamped Typography ───
  static const Color textEngraved = Color(0xFF2B2B2D);      // Stamped dark iron typography
  static const Color textSecondary = Color(0xFF5A5752);     // Stamped subtitle
  static const Color textMuted = Color(0xFF7A766E);         // Fine etched labels
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textFoilGold = Color(0xFFFFC72C);

  // ─── Borders & Grooves ───
  static const Color grooveLight = Color(0x44FFFFFF);       // Top bevel highlight
  static const Color grooveDark = Color(0x40000000);        // Bottom shadow
  static const Color borderBrass = Color(0x88FFC72C);       // Yellow border accent
  static const Color borderSubtle = Color(0x33000000);      // Fine stamped border

  // ─── Metallic Gradients ───
  static const LinearGradient brushedMetalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFC8C4BD),
      Color(0xFFC2B8A5),
      Color(0xFFAFA592),
      Color(0xFF8F8B83),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient brassKnobGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE082),
      Color(0xFFFFC72C),
      Color(0xFFBF8A00),
      Color(0xFFFFE082),
    ],
  );

  static const LinearGradient chassisPlateGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFC8C4BD),
      Color(0xFFC2B8A5),
      Color(0xFFAFA592),
    ],
  );

  static const LinearGradient ctaButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE082),
      Color(0xFFFFC72C),
      Color(0xFFE5A800),
    ],
  );

  static List<BoxShadow> get cardInsetShadows => [
    const BoxShadow(
      color: Color(0x35000000),
      offset: Offset(0, 3),
      blurRadius: 6,
    ),
    const BoxShadow(
      color: Color(0x60FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 2,
    ),
  ];
}
