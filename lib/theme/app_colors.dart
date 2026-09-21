import 'package:flutter/material.dart';

class AppColors {
  // ─── Dark Teal Chassis (ported from web app globals.css) ───
  static const Color metalHighlight = Color(0xFF203C46);    // Top bevel highlight
  static const Color metalBase = Color(0xFF0B0D10);         // Dark chassis mid
  static const Color metalShadow = Color(0xFF071317);       // Bottom vignette & cavity shadow
  static const Color metalDeepCavity = Color(0xFF03090C);   // Inner punched recess
  static const Color metalScrewHead = Color(0xFF1E3A42);    // Screw/rivet detail
  static const Color hardwareGunmetal = Color(0xFF0A1B22);  // Dark hardware

  // ─── Backward-compatible chassis & panels (dark) ───
  static const Color canvasChassis = Color(0xFF0B0D10);       // Dark metal canvas
  static const Color chassisBevelLight = Color(0xFF203C46);   // Specular top edge
  static const Color chassisBevelDark = Color(0xFF071317);    // Edge bevel shadow
  static const Color panelCream = Color(0xFF0C242C);          // Primary dark card surface
  static const Color panelCreamDark = Color(0xFF081A20);      // Secondary recessed card
  static const Color panelInset = Color(0xFF051419);          // Recessed bays & wells
  static const Color metalBrushedLight = Color(0xFF203C46);
  static const Color metalBrushedDark = Color(0xFF081A20);

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

  // ─── Typography (light on dark, ported from web) ───
  static const Color textEngraved = Color(0xFFF8FAFC);      // Primary text (near-white)
  static const Color textSecondary = Color(0xFFCBD5E1);     // Subtitle
  static const Color textMuted = Color(0xFF94A3B8);         // Fine labels
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textFoilGold = Color(0xFFFFC72C);

  // ─── Borders & Grooves ───
  static const Color grooveLight = Color(0x22FFFFFF);       // Top bevel highlight (dark)
  static const Color grooveDark = Color(0x66000000);        // Bottom shadow (deeper on dark)
  static const Color borderBrass = Color(0x88FFC72C);       // Yellow border accent
  static const Color borderSubtle = Color(0x33FFFFFF);      // Fine border (light on dark)

  // ─── Metallic Gradients ───
  static const LinearGradient brushedMetalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF203C46),
      Color(0xFF0C242C),
      Color(0xFF081A20),
      Color(0xFF051419),
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
      Color(0xFF203C46),
      Color(0xFF0C242C),
      Color(0xFF081A20),
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

  static const Color goldGlow = Color(0x55FFC72C);
  static const Color luxObsidian = Color(0xFF070A0D);
  static const Color luxCardSurface = Color(0xFF0D222A);
  static const Color luxCardSurfaceLight = Color(0xFF13323D);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color cyanGlow = Color(0x4400F0FF);

  // ─── Luxury Audio-Grade Gradients ───
  static const LinearGradient luxDarkCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF13333E),
      Color(0xFF0D232B),
      Color(0xFF08181E),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient luxGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF0B3),
      Color(0xFFFFD54F),
      Color(0xFFFFC72C),
      Color(0xFFC69200),
    ],
    stops: [0.0, 0.25, 0.7, 1.0],
  );

  static const LinearGradient luxRenderLaunchGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF176),
      Color(0xFFFFC72C),
      Color(0xFFFF9800),
      Color(0xFFD84315),
    ],
    stops: [0.0, 0.35, 0.75, 1.0],
  );

  // ─── Elevation & Tactile Lighting Presets ───
  static List<BoxShadow> get luxCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.65),
      offset: const Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0xFF203C46).withValues(alpha: 0.25),
      offset: const Offset(0, -1),
      blurRadius: 1,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardInsetShadows => [
    const BoxShadow(
      color: Color(0x35000000),
      offset: Offset(0, 3),
      blurRadius: 6,
    ),
    const BoxShadow(
      color: Color(0x20FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> luxGlowShadow(Color glowColor, {double blur = 14, double spread = 1}) => [
    BoxShadow(
      color: glowColor.withValues(alpha: 0.45),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 2),
    ),
  ];
}
