import 'package:flutter/material.dart';

/// SNAPBEAT STUDIO – CERAMIC WHITE & SHINY PIANO BLACK DUO-TONE DESIGN TOKENS
/// Neumorphic Luxury Instrument System
/// - Pure Ceramic White Substrate (#F6F8FA / #FFFFFF)
/// - Floating High-Gloss Shiny Piano Black Lacquer (#1E222D -> #0D0F14 -> #050608)
/// - Radiant Amber Gold Accents & Diodes (#FFB300 / #D4AF37)
/// - Luminous Monochrome Silver/White Waveform (#FFFFFF / #E2E8F0 / #94A3B8)
/// References:
/// - watermark_clean.png
/// - snapbeat_app_icon.png
class AppColors {
  // ─── 01. Canonical Duo-Tone & Neumorphic Substrate ───

  // Ceramic White Substrate (Stage Canvas & Base Floor)
  static const Color ceramicWhite     = Color(0xFFF6F8FA); // Primary porcelain substrate
  static const Color ceramicWhiteTop  = Color(0xFFFFFFFF); // Specular top catchlight
  static const Color ceramicWhiteMid  = Color(0xFFEFF2F6); // Soft mid ceramic floor
  static const Color ceramicWhiteRim  = Color(0xFFE2E8F0); // Substrate border rim

  // Obsidian Canvas (#020304 near-pure black)
  static const Color obsidianCanvas   = Color(0xFF020304);
  static const Color obsidianDark     = Color(0xFF010203);
  static const Color obsidianWell     = Color(0xFF030405);

  // Recessed Ceramic / Dark Wells
  static const Color ceramicWell      = Color(0xFF030405);
  static const Color ceramicWellDark  = Color(0xFF010203);
  static const Color ceramicWellLight = Color(0xFF07080A);

  // ─── True Neumorphic Lighting & Surface Tokens ───
  static const Color specularHighlight = Color(0x45FFFFFF); // top-left catchlight
  static const Color ambientShadow     = Color(0x60000000); // bottom-right occlusion
  static const Color neumorphicSurface = Color(0xFF07080A); // extruded button surface
  static const Color neumorphicWell    = Color(0xFF030405); // recessed well
  static const Color mutedSilver       = Color(0xFF64748B); // inactive text
  static const Color specularRim       = Color(0x30FFFFFF); // crisp white rim for active buttons

  // Floating High-Gloss Shiny Piano Black Lacquer (True Obsidian)
  static const Color pianoBlack       = Color(0xFF07080A); // Deep mirror jet lacquer
  static const Color pianoBlackMid    = Color(0xFF030405); // Lacquer mid-body
  static const Color pianoBlackDeep   = Color(0xFF000000); // Lacquer shadow bevel
  static const Color pianoBlackTop    = Color(0xFF0A0D12); // Specular top chamfer
  static const Color pianoBlackRim    = specularRim;        // 1px Liquid specular gloss highlight
  static const Color pianoBlackGlow   = ambientShadow;      // Neumorphic ambient occlusion shadow

  // ─── 02. Radiant Amber Gold Diodes & Accents (Zero Maroon) ───
  static const Color amberGold        = Color(0xFFFFB300); // Radiant warm gold diode
  static const Color amberGoldLight   = Color(0xFFFFC837); // Specular illuminated gold peak
  static const Color amberGoldDark    = Color(0xFFD49200); // Beveled diode shadow
  static const Color amberGoldGlow    = Color(0x40FFB300); // Saturated ambient halo

  // Aliases for Ruby Diode -> Entirely replaced by Radiant Amber Gold
  static const Color rubyDiode        = amberGold;
  static const Color rubyDiodeLight   = amberGoldLight;
  static const Color rubyDiodeDark    = amberGoldDark;
  static const Color rubyDiodeGlow    = amberGoldGlow;

  // ─── 03. High-Contrast Studio Typography ───
  static const Color textInkBlack     = Color(0xFF0A0D11); // Ink black for white substrate labels
  static const Color textInkSecondary = Color(0x990A0D11); // 60% ink black
  static const Color textInkTertiary  = Color(0x730A0D11); // 45% ink black
  static const Color textInkDisabled  = Color(0x400A0D11); // 25% ink black

  // Crisp Pure White Typography for Floating Piano Black Consoles
  static const Color textPureWhite    = Color(0xFFFFFFFF); // 100% Crisp white
  static const Color textWhiteSecondary = Color(0xB3FFFFFF); // 70% Translucent white
  static const Color textWhiteMuted   = Color(0x80FFFFFF); // 50% Muted white

  // ─── 04. Backward-Compatible Aliases ───

  // Substrate & Canvas Aliases
  static const Color canvasChassis         = obsidianCanvas;
  static const Color canvasSlateGrey       = obsidianCanvas;
  static const Color canvasSlateGreyLight  = obsidianDark;
  static const Color graphiteSubstrate     = obsidianCanvas;
  static const Color graphiteLight         = obsidianWell;
  static const Color graphiteMid           = obsidianCanvas;
  static const Color graphiteDeep          = obsidianDark;
  static const Color graphiteDarkest       = obsidianDark;
  static const Color graphiteRecess        = neumorphicWell; // #030405 Dark cavity
  static const Color graphiteRecessDeep    = pianoBlackDeep; // #000000
  static const Color graphiteRecessLight   = neumorphicSurface; // #07080A

  // Piano Black Aliases
  static const Color pianoLacquer          = pianoBlack;
  static const Color pianoMid              = pianoBlackMid;
  static const Color pianoDeep             = pianoBlackDeep;
  static const Color pianoRim              = pianoBlackRim;
  static const Color luxObsidian           = pianoBlackDeep;
  static const Color luxCardSurface        = pianoBlack;
  static const Color luxCardSurfaceLight   = pianoBlackMid;

  // Indicator & Accent Aliases -> Radiant Amber Gold
  static const Color indicatorAccent       = amberGold;
  static const Color indicatorAccentLight  = amberGoldLight;
  static const Color indicatorAccentDark   = amberGoldDark;
  static const Color indicatorGlow         = amberGoldGlow;
  static const Color violetAccent          = amberGold;
  static const Color violetAccentLight     = amberGoldLight;
  static const Color violetAccentDark      = amberGoldDark;
  static const Color violetGlow            = amberGoldGlow;
  static const Color yellowPrimary         = amberGold;
  static const Color yellowSpecular        = amberGoldLight;
  static const Color yellowShadow          = amberGoldDark;
  static const Color brassGold             = amberGold;
  static const Color brassHighlight        = amberGoldLight;
  static const Color brassDark             = amberGoldDark;
  static const Color statusGreen           = Color(0xFF10B981);
  static const Color neonCyan              = specularRim;        // Purged teal -> crisp specular white
  static const Color cyanGlow              = specularHighlight;  // Purged cyan -> top-left catchlight
  static const Color goldGlow              = amberGoldGlow;

  // Panel & Inset Aliases -> Shiny Piano Black Consoles
  static const Color panelCream            = pianoBlack;
  static const Color panelCreamDark        = pianoBlackDeep;
  static const Color panelInset            = Color(0xFF08090C); // Recessed cavity
  static const Color metalBase             = pianoBlack;
  static const Color metalHighlight        = pianoBlackTop;
  static const Color metalShadow           = pianoBlackDeep;
  static const Color metalDeepCavity       = pianoBlackDeep;
  static const Color metalScrewHead        = Color(0xFF333846);
  static const Color metalBezelHighlight   = pianoBlackTop;
  static const Color metalBezelLight       = pianoBlackMid;
  static const Color metalBezelMid         = pianoBlack;
  static const Color metalBezelDark        = pianoBlackDeep;
  static const Color metalBezelDeep        = pianoBlackDeep;
  static const Color chassisBevelLight     = Color(0x28FFFFFF);
  static const Color chassisBevelDark      = Color(0x18000000);
  static const Color metalBrushedLight     = pianoBlackMid;
  static const Color metalBrushedDark      = pianoBlackDeep;

  // Typography Aliases (Piano Black context)
  static const Color textPrimary           = textPureWhite;
  static const Color textSecondary         = textWhiteSecondary;
  static const Color textTertiary          = textWhiteMuted;
  static const Color textDisabled          = Color(0x40FFFFFF);
  static const Color textEngraved          = textPureWhite;
  static const Color textHardwareLabel     = textWhiteSecondary;
  static const Color textMuted             = textWhiteMuted;
  static const Color textFoilGold          = amberGold;
  static const Color hardwareGunmetal      = Color(0xFF0A0D11);
  static const Color textWhite             = textPureWhite;

  // Hardware Diodes & Meters
  static const Color redSurface            = amberGold;
  static const Color redGloss              = amberGoldLight;
  static const Color redSocket             = amberGoldDark;
  static const Color redDeepRim            = Color(0xFF1A1202);
  static const Color pinkAccent            = amberGold;
  static const Color pinkGlow              = amberGoldGlow;
  static const Color amberJewel            = Color(0xFFFFFFFF); // Luminous white waveform
  static const Color amberGlow             = Color(0x30FFFFFF);
  static const Color tubeWarmOrange        = Color(0xFFF1F5F9); // Clean silver
  static const Color vuGreen               = Color(0xFF00C853);
  static const Color vuAmber               = Color(0xFFFFB300);
  static const Color vuRed                 = amberGold;

  // Groove, Border & Bevel Aliases
  static const Color grooveDark            = Color(0x60000000);
  static const Color grooveLight           = Color(0x25FFFFFF);
  static const Color seamDark              = Color(0x60000000);
  static const Color seamHighlight         = Color(0x20FFFFFF);
  static const Color borderBrass           = specularRim; // Pure 1px specular white rim (ZERO colored outlines)
  static const Color borderSubtle          = Color(0x18FFFFFF);

  // ─── 05. Tactical Elevation & Neumorphic Material Shadows ───
  static const List<BoxShadow> pianoBlackShadow = [
    BoxShadow(
      color: specularHighlight,
      offset: Offset(-2, -2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: ambientShadow,
      offset: Offset(3, 6),
      blurRadius: 14,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> ceramicCardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 8),
      blurRadius: 28,
    ),
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static const List<BoxShadow> rubyDiodeGlowShadow = [
    BoxShadow(
      color: Color(0x50FFB300),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> contactSubtle = pianoBlackShadow;
  static const List<BoxShadow> contactHero = pianoBlackShadow;
  static const List<BoxShadow> innerRecess = [
    BoxShadow(
      color: Color(0x60000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
  static const List<BoxShadow> luxCardShadow = pianoBlackShadow;
  static const List<BoxShadow> metalPanelShadow = pianoBlackShadow;
  static const List<BoxShadow> cardInsetShadows = innerRecess;

  static List<BoxShadow> luxGlowShadow(Color glowColor, {double blur = 10, double spread = 0}) => [
    BoxShadow(
      color: glowColor.withValues(alpha: 0.25),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 2),
    ),
  ];

  // ─── 06. Luxury High-Gloss Piano Black Gradients ───
  static const LinearGradient pianoBlackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF07080A), // Light end
      Color(0xFF030405), // Mid
      Color(0xFF000000), // Dark end
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient luxDarkCardGradient = pianoBlackGradient;
  static const LinearGradient ctaButtonGradient = pianoBlackGradient;
  static const LinearGradient brassKnobGradient = pianoBlackGradient;
  static const LinearGradient luxGoldGradient = pianoBlackGradient;
  static const LinearGradient luxRenderLaunchGradient = pianoBlackGradient;
  static const LinearGradient brushedMetalGradient = pianoBlackGradient;
  static const LinearGradient chassisPlateGradient = pianoBlackGradient;
  static const LinearGradient metalBezelGradient = pianoBlackGradient;
}
