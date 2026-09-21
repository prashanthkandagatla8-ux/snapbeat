import 'package:flutter/material.dart';

/// SnapBeat Metal Black Theme
/// Bespoke Anodized Metal Black aesthetic.
/// Strict asset retention: ONLY the Logo, Pink Ball (#FF3366), and Watermark.
class AppColors {
  // ─── Anodized Metal Black Chassis ───
  static const Color canvasChassis = Color(0xFF000000);       // Pitch true-black OLED chassis
  static const Color metalBase = Color(0xFF05070A);           // Brushed dark titanium base
  static const Color metalHighlight = Color(0xFF1E2530);      // Hairline metallic specular edge
  static const Color metalShadow = Color(0xFF020305);         // Cavity & depth vignette
  static const Color metalDeepCavity = Color(0xFF010203);     // Inner punched recess
  static const Color metalScrewHead = Color(0xFF181F2A);      // Machined metal hardware detail
  static const Color hardwareGunmetal = Color(0xFF0F141C);    // Dark tactile switch housings

  // ─── Panels & Cards (Deep Metal Black) ───
  static const Color panelCream = Color(0xFF0A0D12);          // Primary dark card plate
  static const Color panelCreamDark = Color(0xFF07090D);      // Secondary recessed card
  static const Color panelInset = Color(0xFF040508);          // Deep recessed bays
  static const Color chassisBevelLight = Color(0xFF1C232E);   // Specular top hairline edge
  static const Color chassisBevelDark = Color(0xFF030406);    // Edge shadow bevel
  static const Color metalBrushedLight = Color(0xFF1A212C);
  static const Color metalBrushedDark = Color(0xFF080B0F);

  // ─── Radiant Pink Ball Accent (STRICTLY RETAINED) ───
  static const Color pinkAccent = Color(0xFFFF3366);          // Radiant signature pink sphere
  static const Color pinkGlow = Color(0xFFFF5588);            // Halo vibrancy glow
  static const Color accentPink = Color(0xFFFF3366);          // Alias for pink accent
  static const Color accentGreen = Color(0xFF10B981);         // Alias for LED green
  static const Color accentRed = Color(0xFFEF4444);           // Alias for alert red
  static const Color textPrimary = Color(0xFFF8FAFC);         // Pure silver-white primary text

  // ─── Backward compatibility aliases (mapped to Metal Black & Pink) ───
  static const Color yellowPrimary = Color(0xFFFF3366);       // Mapped to pink accent
  static const Color yellowSpecular = Color(0xFFFF5588);
  static const Color yellowShadow = Color(0xFFCC1F4B);
  static const Color brassGold = Color(0xFFFF3366);           // Replaced with signature pink
  static const Color brassHighlight = Color(0xFFFF5588);
  static const Color brassDark = Color(0xFFCC1F4B);
  static const Color redSurface = Color(0xFF141922);          // Tactile dark titanium switch
  static const Color redGloss = Color(0xFF222B3A);
  static const Color redSocket = Color(0xFF07090D);
  static const Color redDeepRim = Color(0xFF020305);

  // ─── Indicators & Meters ───
  static const Color amberJewel = Color(0xFFFF3366);          // Neon indicator
  static const Color amberGlow = Color(0x55FF3366);
  static const Color tubeWarmOrange = Color(0xFFFF5588);
  static const Color vuGreen = Color(0xFF10B981);             // Safe level LED
  static const Color vuAmber = Color(0xFFF59E0B);             // Warning LED
  static const Color vuRed = Color(0xFFEF4444);               // Peak LED

  // ─── Typography (Crisp light on metal black) ───
  static const Color textEngraved = Color(0xFFF8FAFC);        // Pure silver-white primary
  static const Color textSecondary = Color(0xFF94A3B8);       // Crisp secondary slate
  static const Color textMuted = Color(0xFF64748B);           // Subtle labels
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textFoilGold = Color(0xFFFF3366);

  // ─── Borders & Grooves ───
  static const Color grooveLight = Color(0x18FFFFFF);         // Top bevel hairline
  static const Color grooveDark = Color(0x99000000);          // Bottom inset shadow
  static const Color borderBrass = Color(0x66FF3366);         // Pink accent border
  static const Color borderSubtle = Color(0x1AFFFFFF);        // Fine chamfer border

  // ─── Metallic Gradients ───
  static const LinearGradient brushedMetalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF181F2A),
      Color(0xFF0A0D12),
      Color(0xFF07090D),
      Color(0xFF030406),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient brassKnobGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF222B3A),
      Color(0xFF141922),
      Color(0xFF0B0E14),
      Color(0xFF222B3A),
    ],
  );

  static const LinearGradient chassisPlateGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A212C),
      Color(0xFF0A0D12),
      Color(0xFF05070A),
    ],
  );

  static const LinearGradient ctaButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF5588),
      Color(0xFFFF3366),
      Color(0xFFD6184A),
    ],
  );

  static List<BoxShadow> get cardInsetShadows => [
    const BoxShadow(
      color: Color(0x60000000),
      offset: Offset(0, 3),
      blurRadius: 6,
    ),
    const BoxShadow(
      color: Color(0x10FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 2,
    ),
  ];
}
