import 'package:flutter/material.dart';

/// SNAPBEAT STUDIO – GRAPHITE NEO v3.0 Design Tokens
/// Material-First Industrial UI System (Graphite Substrate + Piano Black Lacquer)
/// Reference: C:\MyProjects\SnapBeat\References\Final UI Design\NewDesignSystem.txt
class AppColors {
  // ─── 01. Canonical Graphite Neo v3.0 Tokens ───

  // M0 — GRAPHITE SUBSTRATE (65% Application Surface — Visibly Grey)
  static const Color graphiteSubstrate = Color(0xFF2B2D30); // Primary visible grey base
  static const Color graphiteLight     = Color(0xFF303236); // Top-left studio illumination
  static const Color graphiteMid       = Color(0xFF292B2E); // Surface mid-tone
  static const Color graphiteDeep      = Color(0xFF26282B); // Bottom shadow / separator tone
  static const Color graphiteDarkest   = Color(0xFF232528);

  // M1 — GRAPHITE RECESS (Wells, cavities, waveform, inputs, slider tracks)
  static const Color graphiteRecessDeep    = Color(0xFF1D1F22); // Deepest cavity
  static const Color graphiteRecess        = Color(0xFF202225); // Standard recess well
  static const Color graphiteRecessLight   = Color(0xFF24262A); // Inner edge catchlight

  // M2 — PIANO BLACK (22% Inserted Lacquered Controls, Primary CTA, Video Frame)
  static const Color pianoLacquer     = Color(0xFF161719); // Primary CTA surface
  static const Color pianoMid         = Color(0xFF121315); // Lacquer mid-tone
  static const Color pianoDeep        = Color(0xFF0D0F11); // Lacquer shadow edge
  static const Color pianoRim         = Color(0xFF1C1D20); // Top catchlight

  // M4 — INDICATOR ACCENT (2% Restrained LED Indicator Light — NOT Decorative)
  static const Color indicatorAccent      = Color(0xFF8A7CFF); // Precision violet indicator
  static const Color indicatorAccentLight = Color(0xFFA59BFF);
  static const Color indicatorAccentDark  = Color(0xFF7061FF);
  static const Color indicatorGlow        = Color(0x338A7CFF); // Controlled 2% indicator glow

  // TYPOGRAPHY (Clean, flat, high contrast)
  static const Color textPrimary   = Color(0xFFF0F1F3); // Main headings, CTA labels
  static const Color textSecondary = Color(0xFFB6B8BD); // Subtitles, descriptions
  static const Color textTertiary  = Color(0xFF85878D); // Monospace specs, track times
  static const Color textDisabled  = Color(0xFF616369); // Inactive items, placeholders
  static const Color textWhite     = Color(0xFFFFFFFF);

  // ─── 02. Backward-Compatible Aliases (Zero Broken Callers) ───

  // Violet Accent Aliases
  static const Color violetAccent      = indicatorAccent;
  static const Color violetAccentLight = indicatorAccentLight;
  static const Color violetAccentDark  = indicatorAccentDark;
  static const Color violetGlow        = indicatorGlow;
  static const Color statusGreen       = Color(0xFF10B981);

  // Chassis & Canvas Aliases -> Graphite Neo Substrate
  static const Color canvasChassis         = graphiteSubstrate;
  static const Color canvasSlateGrey       = graphiteSubstrate;
  static const Color canvasSlateGreyLight  = graphiteLight;
  static const Color metalBase             = graphiteMid;
  static const Color metalHighlight        = graphiteLight;
  static const Color metalShadow           = graphiteRecess;
  static const Color metalDeepCavity       = graphiteRecessDeep;
  static const Color metalScrewHead        = graphiteDeep;
  static const Color hardwareGunmetal      = pianoLacquer;

  // Frame & Bezel Aliases
  static const Color metalBezelHighlight = graphiteLight;
  static const Color metalBezelLight     = graphiteMid;
  static const Color metalBezelMid       = graphiteDeep;
  static const Color metalBezelDark      = graphiteRecess;
  static const Color metalBezelDeep      = graphiteRecessDeep;

  // Panels & Insets Aliases -> Graphite Materials
  static const Color chassisBevelLight = graphiteLight;
  static const Color chassisBevelDark  = graphiteRecessDeep;
  static const Color panelCream        = graphiteMid;
  static const Color panelCreamDark    = graphiteDeep;
  static const Color panelInset        = graphiteRecess;
  static const Color metalBrushedLight = graphiteLight;
  static const Color metalBrushedDark  = graphiteDeep;

  // Primary / Secondary Brand Aliases -> Piano Black & Indicator
  static const Color yellowPrimary  = indicatorAccent;
  static const Color yellowSpecular = indicatorAccentLight;
  static const Color yellowShadow   = indicatorAccentDark;
  static const Color brassGold      = indicatorAccent;
  static const Color brassHighlight = indicatorAccentLight;
  static const Color brassDark      = indicatorAccentDark;

  // Dome & Indicators
  static const Color redSurface     = Color(0xFFD62828);
  static const Color redGloss       = Color(0xFFFF4D4D);
  static const Color redSocket      = Color(0xFF7A0000);
  static const Color redDeepRim     = Color(0xFF17120F);
  static const Color pinkAccent     = indicatorAccent;
  static const Color pinkGlow       = indicatorGlow;
  static const Color amberJewel     = Color(0xFFFF8A00);
  static const Color amberGlow      = Color(0x44FF8A00);
  static const Color tubeWarmOrange = Color(0xFFFF6A00);
  static const Color vuGreen        = Color(0xFF00C853);
  static const Color vuAmber        = Color(0xFFFFB300);
  static const Color vuRed          = Color(0xFFD50000);

  // Typography Aliases
  static const Color textEngraved = textPrimary;
  static const Color textFoilGold = indicatorAccent;
  static const Color textMuted    = textTertiary;

  // Borders & Grooves
  static const Color grooveLight  = Color(0x0AFFFFFF); // Subtle 1px edge catch
  static const Color grooveDark   = Color(0x55000000); // Contact occlusion
  static const Color borderBrass  = Color(0x448A7CFF);
  static const Color borderSubtle = Color(0x10FFFFFF);

  static const Color goldGlow           = indicatorGlow;
  static const Color luxObsidian        = pianoDeep;
  static const Color luxCardSurface     = graphiteMid;
  static const Color luxCardSurfaceLight = graphiteLight;
  static const Color neonCyan           = indicatorAccent;
  static const Color cyanGlow           = indicatorGlow;

  // ─── 03. Graphite Neo v3.0 Gradients ───

  // Primary Graphite Substrate Gradient (Top-Left Studio Light)
  static const LinearGradient brushedMetalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      graphiteLight,
      graphiteSubstrate,
      graphiteMid,
      graphiteDeep,
    ],
    stops: [0.0, 0.35, 0.70, 1.0],
  );

  static const LinearGradient chassisPlateGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      graphiteLight,
      graphiteSubstrate,
      graphiteMid,
    ],
  );

  // Piano Black CTA Button Gradient (Lacquered Finish)
  static const LinearGradient ctaButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      pianoRim,
      pianoLacquer,
      pianoMid,
      pianoDeep,
    ],
    stops: [0.0, 0.22, 0.68, 1.0],
  );

  static const LinearGradient brassKnobGradient = ctaButtonGradient;
  static const LinearGradient luxDarkCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      graphiteLight,
      graphiteMid,
      graphiteDeep,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient luxGoldGradient = ctaButtonGradient;
  static const LinearGradient luxRenderLaunchGradient = ctaButtonGradient;

  static const LinearGradient metalBezelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      graphiteLight,
      graphiteSubstrate,
      graphiteMid,
      graphiteDeep,
      graphiteRecess,
    ],
    stops: [0.0, 0.22, 0.60, 0.88, 1.0],
  );

  // ─── 04. Graphite Neo v3.0 Physical Contact Shadows (No Neumorphic Bloat) ───

  // Contact Subtle: For secondary controls, photo tiles, panels
  static List<BoxShadow> get contactSubtle => [
    const BoxShadow(
      color: Color(0x80000000),
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
    const BoxShadow(
      color: Color(0x47000000),
      offset: Offset(0, 3),
      blurRadius: 10,
    ),
    const BoxShadow(
      color: Color(0x08FFFFFF),
      offset: Offset(0, 1),
      blurRadius: 0,
    ),
  ];

  // Contact Hero: For Primary CTA ("Create Video") and Video Frame
  static List<BoxShadow> get contactHero => [
    const BoxShadow(
      color: Color(0x9E000000),
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
    const BoxShadow(
      color: Color(0x75000000),
      offset: Offset(0, 10),
      blurRadius: 28,
    ),
    const BoxShadow(
      color: Color(0x0AFFFFFF),
      offset: Offset(0, 1),
      blurRadius: 0,
    ),
  ];

  // Inner Recess: For waveform wells, inputs, slider tracks
  static List<BoxShadow> get innerRecess => [
    const BoxShadow(
      color: Color(0x75000000),
      offset: Offset(2, 2.5),
      blurRadius: 5,
    ),
    const BoxShadow(
      color: Color(0x08FFFFFF),
      offset: Offset(-0.5, -0.5),
      blurRadius: 1,
    ),
  ];

  // Backward-compatible getters
  static List<BoxShadow> get metalPanelShadow => contactSubtle;
  static List<BoxShadow> get luxCardShadow     => contactHero;
  static List<BoxShadow> get cardInsetShadows  => innerRecess;

  static List<BoxShadow> luxGlowShadow(Color glowColor, {double blur = 10, double spread = 0}) => [
    BoxShadow(
      color: glowColor.withValues(alpha: 0.25),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 2),
    ),
  ];
}
