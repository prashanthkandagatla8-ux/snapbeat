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
  // =========================================================================
  // Official SnapBeat 2026 Neomorphic Design System (ChatGPT Spec)
  // =========================================================================

  // =========================================================================
  // SNAPBEAT — GRAPHITE PIANO NEO (24 Sep 2026 Spec)
  // =========================================================================

  // Section 3.1: White Studio Material (Warm Architectural Ceramic Beige Substrate #EDE8DF)
  static const Color canvasBg = Color(0xFFEDE8DF); // Warm architectural ceramic beige floor
  static const Color primaryWhite = Color(0xFFFFFFFF); // Pure pristine ceramic white panel surface
  static const Color primarySurface = Color(0xFFFFFFFF); // Card / inner sections
  static const Color secondarySurface = Color(0xFFFFFFFF);
  static const Color softWhiteRaised = Color(0xFFF5F3EE);
  static const Color porcelainHighlight = Color(0xFFFFFFFF);
  static const Color recessedWhite = Color(0xFFF5F2EC);
  static const Color insetSurface = Color(0xFFEDE8DF);
  static const Color elevatedSurface = Color(0xFFFFFFFF);
  static const Color chipSurface = Color(0xFFE2DDD4); // Chip pills (#E2DDD4)
  static const Color chipBorder = Color(0xFFD8D2C7); // 1px border
  static const Color chipSelected = Color(0xFF000000); // Selected chip
  static const Color chipCheck = Color(0xFF10B981); // Green check

  // Section 3.2: Piano-Black Material
  static const Color pianoBlackBase = Color(0xFF090B0F);
  static const Color pianoBlackSoft = Color(0xFF0D1015);
  static const Color pianoBlackMid = Color(0xFF12161D);
  static const Color pianoBlackHighlight = Color(0xFF1B2028);
  static const Color pianoBlackDeep = Color(0xFF06080B);
  static const Color darkControl = Color(0xFF0D1015);
  static const Color darkControlHover = Color(0xFF12161D);
  static const Color darkControlPressed = Color(0xFF06080B);

  // Section 3.3: Typography (#111111 Studio Soft Base)
  static const Color primaryDarkText = Color(0xFF11151B);
  static const Color primaryText = Color(0xFF11151B);
  static const Color secondaryDarkText = Color(0xFF525A65);
  static const Color secondaryText = Color(0xFF525A65);
  static const Color mutedDarkText = Color(0xFF8B929B);
  static const Color mutedText = Color(0xFF8B929B);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color subtleWhiteText = Color(0xFFC9CDD3);
  static const Color dividerColor = Color(0xFFDCE1E6);

  // Section 3.4: Brand Micro-Accent (Black, White, Iridescent Gradient Only - Zero Yellow/Orange)
  static const Color microGold = pureWhite;
  static const Color snapOrange = pureWhite;
  static const Color snapCyan = pureWhite;
  static const Color snapViolet = Color(0xFFB026FF);
  static const Color snapPink = Color(0xFFFF3366);
  static const Color snapGreen = Color(0xFF10B981);

  // Section 6 & 8: Calibrated Lighting & Material Shadows
  static const List<BoxShadow> softRaisedShadow = [
    BoxShadow(color: Color(0x1F4A4235), offset: Offset(0, 4), blurRadius: 12, spreadRadius: 0),
    BoxShadow(color: Color(0xB3FFFFFF), offset: Offset(0, -2), blurRadius: 6, spreadRadius: 0),
  ];

  static const List<BoxShadow> mediumRaisedShadow = [
    BoxShadow(color: Color(0x1C28303A), offset: Offset(0, 8), blurRadius: 20, spreadRadius: 0),
    BoxShadow(color: Color(0xBFFFFFFF), offset: Offset(0, -3), blurRadius: 10, spreadRadius: 0),
  ];

  static const List<BoxShadow> deepFloatingShadow = [
    BoxShadow(color: Color(0x2E05080C), offset: Offset(0, 8), blurRadius: 24, spreadRadius: 0),
    BoxShadow(color: Color(0x12FFFFFF), offset: Offset(0, -1), blurRadius: 2, spreadRadius: 0),
  ];

  static const List<BoxShadow> darkHardwareShadow = [
    BoxShadow(color: Color(0x3305080C), offset: Offset(0, 5), blurRadius: 12, spreadRadius: 0),
    BoxShadow(color: Color(0x1F05080C), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0),
  ];

  static const LinearGradient darkHardwareGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF161A22),
      Color(0xFF0D1015),
      Color(0xFF090B0F),
    ],
  );

  // ─── 01. Canonical Duo-Tone & Neumorphic Substrate ───

  // Ceramic White Substrate (Stage Canvas & Base Floor) -> Warm Architectural Ceramic Beige
  static const Color ceramicWhite        = Color(0xFFEDE8DF); // Warm architectural beige substrate
  static const Color ceramicWhiteTop     = Color(0xFFFFFFFF); // Specular top catchlight
  static const Color ceramicWhiteMid     = Color(0xFFF7F5F0); // Card / inner sections
  static const Color ceramicWhiteRim     = Color(0xFFE2DDD4); // 1px panel rim
  static const Color ceramicShadow       = Color(0x1F4A4235); // Warm studio occlusion
  static const Color ceramicShadowSoft   = Color(0x144A4235); // Soft occlusion
  static const Color ceramicHighlight    = Color(0xFFFFFFFF); // Specular catchlight

  // Piano Slab Lacquer Slices (for floating black objects on ceramic)
  static const Color pianoSlabTop        = Color(0xFF262C36); // Top of lacquer gradient
  static const Color pianoSlabMid        = Color(0xFF141922);
  static const Color pianoSlabDeep       = Color(0xFF080A0E);
  static const Color pianoSlabBase       = Color(0xFF030406);

  // Obsidian Canvas
  static const Color obsidianCanvas      = Color(0xFF020304);
  static const Color obsidianDark        = Color(0xFF010203);
  static const Color obsidianWell        = Color(0xFF030405);

  // Recessed Ceramic / Dark Wells
  static const Color ceramicWell         = Color(0xFF030405);
  static const Color ceramicWellDark     = Color(0xFF010203);
  static const Color ceramicWellLight    = Color(0xFF07080A);

  // ─── True Neumorphic Lighting & Surface Tokens ───
  static const Color specularHighlight   = Color(0x45FFFFFF); // top-left catchlight
  static const Color ambientShadow       = Color(0x60000000); // bottom-right occlusion
  static const Color neumorphicSurface   = Color(0xFF07080A); // extruded button surface
  static const Color neumorphicWell      = Color(0xFF030405); // recessed well
  static const Color mutedSilver         = Color(0xFF64748B); // inactive text
  static const Color specularRim         = Color(0x30FFFFFF); // crisp white rim for active buttons

  // Floating High-Gloss Shiny Piano Black Lacquer
  static const Color pianoBlack          = Color(0xFF07080A); // Deep mirror jet lacquer
  static const Color pianoBlackTop       = Color(0xFF0A0D12); // Specular top chamfer
  static const Color pianoBlackRim       = specularRim;        // 1px Liquid specular gloss highlight
  static const Color pianoBlackGlow      = ambientShadow;      // Neumorphic ambient occlusion shadow

  // ─── 02. Accents: Zero Yellow, Zero Orange (Black, White, Iridescent Gradient Only) ───
  static const Color pureWhite           = Color(0xFFFFFFFF);
  static const Color pureBlack           = Color(0xFF07080A);

  // Deprecated color aliases remapped strictly to White / Black / Neutral
  static const Color amberGold           = pureWhite;
  static const Color amberGoldLight      = pureWhite;
  static const Color amberGoldDark       = Color(0xFF94A3B8);
  static const Color amberGoldGlow       = Color(0x30FFFFFF);

  // Aliases for Ruby Diode -> Pure White
  static const Color rubyDiode           = pureWhite;
  static const Color rubyDiodeLight      = pureWhite;
  static const Color rubyDiodeDark       = Color(0xFF94A3B8);
  static const Color rubyDiodeGlow       = Color(0x30FFFFFF);

  // ─── 03. High-Contrast Studio Typography ───
  static const Color textInkBlack        = Color(0xFF0A0D11); // Ink black for warm studio base (#111111)
  static const Color textInkSecondary    = Color(0x99111111); // 60% ink black
  static const Color textInkTertiary     = Color(0x73111111); // 45% ink black
  static const Color textInkDisabled     = Color(0x400A0D11); // 25% ink black

  // Crisp Pure White Typography for Floating Piano Black Consoles
  static const Color textPureWhite       = Color(0xFFFFFFFF); // 100% Crisp white
  static const Color textWhiteSecondary  = Color(0xB3FFFFFF); // 70% Translucent white
  static const Color textWhiteMuted      = Color(0x80FFFFFF); // 50% Muted white

  // ─── 04. Backward-Compatible Aliases (Ceramic Theme Flip per Spec §3) ───

  // Substrate & Canvas Aliases -> Ceramic White
  static const Color canvasChassis         = ceramicWhite;
  static const Color canvasSlateGrey       = ceramicWhite;
  static const Color canvasSlateGreyLight  = ceramicWhiteMid;
  static const Color graphiteSubstrate     = ceramicWhite;
  static const Color graphiteLight         = ceramicWhiteTop;
  static const Color graphiteMid           = ceramicWhite;
  static const Color graphiteDeep          = ceramicWhiteMid;
  static const Color graphiteDarkest       = ceramicShadow;
  static const Color graphiteRecess        = ceramicWhiteMid;
  static const Color graphiteRecessDeep    = ceramicShadow;
  static const Color graphiteRecessLight   = ceramicWhiteTop;

  // Piano Black Aliases (Preserved for black objects on ceramic)
  static const Color pianoLacquer          = pianoBlack;
  static const Color pianoMid              = pianoBlackMid;
  static const Color pianoDeep             = pianoBlackDeep;
  static const Color pianoRim              = pianoBlackRim;
  static const Color luxObsidian           = pianoBlackDeep;
  static const Color luxCardSurface        = pianoBlack;
  static const Color luxCardSurfaceLight   = pianoBlackMid;

  // Indicator & Accent Aliases -> Pure White / Piano Black (Zero Yellow, Zero Orange)
  static const Color indicatorAccent       = pureWhite;
  static const Color indicatorAccentLight  = pureWhite;
  static const Color indicatorAccentDark   = Color(0xFF94A3B8);
  static const Color indicatorGlow         = Color(0x40FFFFFF);
  static const Color violetAccent          = Color(0xFFB026FF);
  static const Color violetAccentLight     = Color(0xFFD946EF);
  static const Color violetAccentDark      = Color(0xFF7C3AED);
  static const Color violetGlow            = Color(0x40B026FF);
  static const Color yellowPrimary         = pureWhite;
  static const Color yellowSpecular        = pureWhite;
  static const Color yellowShadow          = Color(0xFF94A3B8);
  static const Color brassGold             = pureBlack;
  static const Color brassHighlight        = pureWhite;
  static const Color brassDark             = pureBlack;
  static const Color statusGreen           = Color(0xFF10B981);
  static const Color neonCyan              = specularRim;
  static const Color cyanGlow              = specularHighlight;
  static const Color goldGlow              = Color(0x30FFFFFF);

  // Panel & Inset Aliases -> Warm Studio Gray Cards (#E5E1D8) & Wells
  static const Color panelCream            = ceramicWhite;
  static const Color panelCreamDark        = ceramicWhiteMid;
  static const Color panelInset            = ceramicWhiteMid;
  static const Color metalBase             = ceramicWhite;
  static const Color metalHighlight        = ceramicWhiteTop;
  static const Color metalShadow           = ceramicShadow;
  static const Color metalDeepCavity       = ceramicShadow;
  static const Color metalScrewHead        = Color(0xFF94A3B8);
  static const Color metalBezelHighlight   = ceramicWhiteTop;
  static const Color metalBezelLight       = ceramicWhiteMid;
  static const Color metalBezelMid         = ceramicWhite;
  static const Color metalBezelDark        = ceramicShadow;
  static const Color metalBezelDeep        = ceramicShadow;
  static const Color chassisBevelLight     = ceramicHighlight;
  static const Color chassisBevelDark      = Color(0x40CFC8BA);
  static const Color metalBrushedLight     = ceramicWhiteTop;
  static const Color metalBrushedDark      = ceramicWhiteMid;

  // Typography Aliases (Ceramic Theme Flip per Spec §3)
  static const Color textPrimary           = textInkBlack;
  static const Color textSecondary         = textInkSecondary;
  static const Color textTertiary          = textInkTertiary;
  static const Color textDisabled          = textInkDisabled;
  static const Color textEngraved          = textInkBlack;
  static const Color textHardwareLabel     = textInkSecondary;
  static const Color textMuted             = textInkTertiary;
  static const Color textFoilGold          = textInkBlack;
  static const Color hardwareGunmetal      = textInkBlack;
  static const Color textWhite             = textPureWhite;

  // Hardware Diodes & Meters (Purge Colour Drift per Spec §3)
  static const Color redSurface            = pureBlack;
  static const Color redGloss              = pureWhite;
  static const Color redSocket             = pureBlack;
  static const Color redDeepRim            = Color(0xFF07080A);
  static const Color pinkAccent            = Color(0xFFFF3366);
  static const Color pinkGlow              = Color(0x60FF3366);

  static const LinearGradient iridescentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E5FF), Color(0xFFB026FF), Color(0xFFFF007F)],
  );
  static const Color amberJewel            = textInkBlack;
  static const Color amberGlow             = Color(0x30FFFFFF);
  static const Color tubeWarmOrange        = textInkSecondary;
  static const Color vuGreen               = Color(0xFF00C853);
  static const Color vuAmber               = Color(0xFFFFFFFF);
  static const Color vuRed                 = Color(0xFFEF4444);

  // Groove, Border & Bevel Aliases
  static const Color grooveDark            = Color(0x60000000);
  static const Color grooveLight           = Color(0x25FFFFFF);
  static const Color seamDark              = Color(0x60000000);
  static const Color seamHighlight         = Color(0x20FFFFFF);
  static const Color borderBrass           = ceramicWhiteRim;
  static const Color borderSubtle          = Color(0x33A3B1C6);

  // ─── 05. Tactical Elevation & Neumorphic Material Shadows ───

  // TRUE NEUMORPHISM ELEVATIONS (Ref Theme)
  static const List<BoxShadow> neumorphicRaisedPill = softRaisedShadow;
  static const List<BoxShadow> neumorphicRaisedCard = mediumRaisedShadow;

  static const List<BoxShadow> neumorphicUpwardBlack = [
    BoxShadow(color: Color(0x70000000), offset: Offset(0, -5), blurRadius: 16, spreadRadius: 0),
    BoxShadow(color: Color(0x18FFFFFF), offset: Offset(0, 1), blurRadius: 3, spreadRadius: 0),
  ];

  static const List<BoxShadow> neumorphicRaisedTile = [
    BoxShadow(color: Color(0x55A3B1C6), offset: Offset(3, 4), blurRadius: 10, spreadRadius: 0),
    BoxShadow(color: Color(0xE6FFFFFF), offset: Offset(-3, -3), blurRadius: 8, spreadRadius: 0),
  ];

  static const List<BoxShadow> neumorphicBlackRaised = darkHardwareShadow;

  // CERAMIC / PORCELAIN RAISED (24-Sep spec §6: soft, broad, vertical-only)
  static const List<BoxShadow> ceramicRaise = softRaisedShadow;

  // PIANO BLACK SLAB SHADOW (24-Sep spec §8: darkHardwareShadow)
  static const List<BoxShadow> pianoSlabShadow = darkHardwareShadow;

  static const List<BoxShadow> pianoBlackShadow = darkHardwareShadow;

  static const List<BoxShadow> ceramicCardShadow = mediumRaisedShadow;

  static const List<BoxShadow> rubyDiodeGlowShadow = [
    BoxShadow(
      color: Color(0x30FFFFFF),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> contactSubtle = ceramicRaise;
  static const List<BoxShadow> contactHero = pianoSlabShadow;
  static const List<BoxShadow> innerRecess = [
    BoxShadow(
      color: Color(0x60000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
  static const List<BoxShadow> luxCardShadow = ceramicRaise;
  static const List<BoxShadow> metalPanelShadow = ceramicRaise;
  static const List<BoxShadow> cardInsetShadows = innerRecess;

  static List<BoxShadow> luxGlowShadow(Color glowColor, {double blur = 10, double spread = 0}) => [
    BoxShadow(
      color: glowColor.withValues(alpha: 0.25),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 2),
    ),
  ];

  // ─── Real 3D Tactile Specular Bevels ───
  static final List<BoxShadow> tactile3DBevel = [
    // Ambient soft drop shadow calibrated for warm ceramic beige substrate
    BoxShadow(
      color: const Color(0xFF383025).withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    // Contact drop shadow
    BoxShadow(
      color: const Color(0xFF383025).withValues(alpha: 0.06),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
    // Specular top highlight catchlight lip
    const BoxShadow(
      color: Color(0x60FFFFFF),
      blurRadius: 1,
      offset: Offset(0, -1),
    ),
  ];

  static final BoxDecoration tactileWhiteCardDecoration = BoxDecoration(
    color: primaryWhite,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ceramicWhiteRim, width: 1.0),
    boxShadow: tactile3DBevel,
  );

  static final List<BoxShadow> darkTactile3DBevel = [
    // Dense piano ambient shadow
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.55),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    // Sharp direct contact shadow
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.80),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    // Specular top rim catchlight
    const BoxShadow(
      color: Color(0x35FFFFFF),
      blurRadius: 1,
      offset: Offset(0, -1),
    ),
  ];

  static final BoxDecoration tactileDarkCardDecoration = BoxDecoration(
    color: pianoBlack,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: pianoBlackRim, width: 1.0),
    boxShadow: darkTactile3DBevel,
  );

  // ─── 06. Silky Piano Black Gradients (24-Sep Spec §3.2) ───
  static const LinearGradient pianoBlackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF161A22), // Soft piano highlight
      Color(0xFF0D1015), // Silky mid
      Color(0xFF090B0F), // Dense piano base
    ],
    stops: [0.0, 0.5, 1.0],
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
