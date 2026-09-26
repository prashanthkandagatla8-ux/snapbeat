# SNAPBEAT STUDIO FLUTTER CLIENT — CANONICAL DESIGN & ARCHITECTURE SPECIFICATION
**Document Version**: 2.0 (Authoritative)  
**Status**: ACTIVE / STRICT ENFORCEMENT  
**Target Repository**: `C:\\MyProjects\\snapbeat_flutter`  
**Applicability**: All AI models, agents, and human contributors MUST strictly adhere to this specification. Zero deviation permitted without explicit user sign-off.

---

## 1. Executive Summary & Design Vision
SnapBeat Studio is an editorial, luxury mobile video workstation engineered for high-energy beat-synced vertical reels (9:16 format). The application synthesizes precision audio stem analysis with cinematic video transitions.

The design philosophy is **Editorial Neumorphism & Shiny Piano Black Luxury**:
- Pure Ceramic White substrate (`#F4F6F9` / `#FFFFFF`) hosting floating, high-gloss Shiny Piano Black lacquer control modules.
- Tactile 3D physical hardware aesthetic reminiscent of high-end Teenage Engineering hardware, Braun industrial design, and Leica cameras.
- 100% full viewport density — zero empty voids or dead black spaces.

---

## 2. Universal Color Palette & Strict Eradications

### 2.1 The Approved Color Hierarchy
| Token | Hex / Value | Usage & Meaning |
| :--- | :--- | :--- |
| **Substrate (Chassis)** | `#F4F6F9` / `#FFFFFF` | Ceramic white baseplate. Clean, airy luxury background. |
| **Piano Black Lacquer** | `#1A1D25` $\\to$ `#0A0B0F` $\\to$ `#030406` | Elevated cards, hardware buttons, docked action deck. Multi-stop extruded gradient. |
| **Catchlight Rims** | `Color(0x30FFFFFF)` | 1px top/left specular bevel on elevated dark modules. |
| **Primary Accent** | `#FFB300` (Radiant Amber Gold) | Active toggles, Pro indicators, hero badges, progress indicators. |
| **Waveform Luminous** | `#FFFFFF` / `#E2E8F0` / `#94A3B8` | Monochrome silver/white audio waveforms. Crisp and professional. |
| **Cavity Well Shadows** | `Color(0x18000000)` inner | Recessed text input wells, waveform display trays, switch tracks. |
| **Success / Online** | `#00E676` | Server operational, verified audio sync, green status beacons. |
| **Info / Tech** | `#38BDF8` (Sky Blue) | Technical metadata, sample rate, FPS indicators. |

### 2.2 Prohibited Anti-Patterns & Absolute Bans
- ❌ **ABSOLUTE BAN ON MAROON (`#8B1A2B`)**: Maroon is completely forbidden across the entire application. Any switch, card, or border using maroon is a regression and must be rejected.
- ❌ **NO ORANGE WAVEFORMS**: Waveforms must be luminous monochrome silver/white.
- ❌ **NO FLAT 2D TEXT BRAND LOGOS**: The header must always render the official 3D beveled squircle emblem from `assets/images/snapbeat_app_icon.png` (matching `watermark_clean.png`).
- ❌ **NO PURPLE DOT / GAMING CLUTTER**: No random mascot icons, neon purple confetti, or distracting gamer elements.

---

## 3. Physical Neumorphism & Bevel Specifications

### 3.1 Elevated Piano Black Module (Cards, Decks, Primary Controls)
```dart
BoxDecoration(
  borderRadius: BorderRadius.circular(16),
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E222D), Color(0xFF0F1117), Color(0xFF07080B)],
    stops: [0.0, 0.45, 1.0],
  ),
  border: Border.all(color: const Color(0x28FFFFFF), width: 1.0),
  boxShadow: const [
    BoxShadow(
      color: Color(0x35000000),
      offset: Offset(0, 10),
      blurRadius: 22,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x15000000),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ],
)
```

### 3.2 Recessed Cavity Wells (Waveforms, Text Fields, Switch Tracks)
- Dark inner cavity with smooth border radius (8px to 14px).
- Border: `Border.all(color: Color(0x15FFFFFF), width: 1.0)`.
- Background: Solid deep lacquer `#050608` or `#08090C`.

---

## 4. Screen Architecture & Viewport Density Directives

### 4.1 Master Stage 1: Music Deck (Full Viewport Station)
- **Eliminate Dead Voids**: Music Deck must utilize 100% of available viewport between top header and bottom action deck.
- **Hardware Audio Rack**:
  - Live Interactive Waveform with trim drag handles and beat transient markers.
  - BPM Tempo Dial & Beat Snapping selector (1/4, 1/8, 1/16 beat cuts).
  - Integrated Genre & Vibe Audition Shelf right on the deck for instant previewing without page navigation.
  - Track metadata telemetry (Duration, Key, Loudness LUFS, Stems).

### 4.2 Master Stage 2: Photos Stage (Reorder & Dynamic Matrix)
- Dense photo reorder strip with magnetic drag-to-sort physics.
- Multi-selection badge and aspect crop preview (1:1, 9:16, 4:5).
- Auto-beat sync distribution counter (Photos per Beat measure).

### 4.3 Master Stage 3: Title Stage (Vertical 9:16 Reel Canvas)
- **Prominent Phone Canvas**: Occupies 50% to 60% of viewport height (minimum 360px).
- Realistic iPhone bezel preview displaying live video background.
- Kinetic Typography Layer: Real-time rendering of animated titles (Kinetic, Editorial, Glitch, Minimal).
- Floating typography parameter rack: Font weight, letter spacing, text alignment handles.

### 4.4 Master Stage 4: Render Pro Deck (Hardware Specifier)
- Hardware device cards with visual aspect ratio badges.
- Output resolution specifier: Master 1080p (Serverless), HD 720p (VPS), Fast 360p (Preview).
- Live rendering time estimator and video file size calculator.

---

## 5. Master Action Deck & Mode Architecture

### 5.1 The AUTO vs MANUAL Paradigm (Core Monetization Gating)
- **Primary Business Model Pivot**: The fundamental paywall boundary is now **MODE-BASED (AUTO vs MANUAL)** rather than resolution-based.
- **AUTO MODE (Universal / Free & Pro)**:
  - Streamlined 3-step creation flow: Music $\to$ Photos $\to$ Title Card $\to$ Instant Render.
  - Automated intelligent beat-synced mixing and transitions.
  - Clean, distraction-free 9:16 typography preview and title inputs.
  - Quality selection is **UNLOCKED** — free users can export in standard, 720p HD, or 1080p Master without being artificially locked to 360p.
- **MANUAL MODE (PRO EXCLUSIVE 🔒)**:
  - Dedicated creative suite unlocked exclusively for Pro subscribers.
  - Grants access to:
    - **Step 4: RENDER Deck**: Fine-grained template catalog selector (14 beat styles), Beat Motion effects (Burst, Teaser, Drop It), custom aspect ratios (9:16, 1:1, 16:9).
    - **Advanced Title Suite**: Font family selection (11 luxury typefaces via Google Fonts), Font Size controls (S/M/L/XL), Title Styles (Editorial, Neon, 3D Retro, Cinematic, Badge), Frame Borders, Duration Sliders (1–6s), Audio Timing, and Custom Canvas Color Swatches.
  - Attempting to activate MANUAL mode as a free user triggers `RetroSubscriptionDialog` / `AccountPlanDialog`.
  - The `MANUAL` toggle chip in `MasterActionDeck` features an iridescent `PRO` indicator badge.

### 5.2 Master Action Deck Hardware Specs
- **AUTO / MANUAL Switch**:
  - Track: Shiny Piano Black lacquer cavity.
  - Selected Option: Pure crisp white `#FFFFFF` text on elevated lacquer pill with subtle catchlight.
  - Unselected Option: Translucent white `#B3FFFFFF` text. Both labels must always be 100% legible.
  - `MANUAL` chip includes a high-gloss `PRO` badge when user is not subscribed.
- **Adaptive Switches**: Pure white thumb on piano black track. Zero maroon.

---

## 6. Subscription & Paywall (`retro_subscription_dialog.dart` & `account_plan_dialog.dart`)
- **Visual Harmony**: Must match the rest of the application.
  - Substrate: Clean Ceramic White background (`#F4F6F9`).
  - Tier Cards: Floating Shiny Piano Black extruded slabs with 1px catchlight rims.
  - Badges: Radiant Pure White / Iridescent gradient accents.
  - Account & Plan Management: Instant visibility into current plan, remaining credits, renewal/expiry date, and showcase tour replay.

---

## 7. Quality Policy & Export Pipelines (Quality Lock Dropped)
- **Quality Lock Dropped**: Users are no longer forcibly locked to 360p. All quality options (360p Standard, 720p HD, 1080p Master) are selectable in both Auto and Manual modes.
- **Export Pipelines**:
  | Tier | Resolution | Target Engine | Watermark Policy | Mode Availability |
  | :--- | :--- | :--- | :--- | :--- |
  | **1080p Master** | 1080 × 1920 | Cloud Run Serverless | No Watermark (Pro) / Watermarked (Free) | Auto & Manual (Pro) |
  | **720p HD** | 720 × 1280 | VPS Cult Engine | No Watermark (Pro) / Watermarked (Free) | Auto & Manual (Pro) |
  | **360p Standard** | 360 × 640 | VPS Cult Engine | Watermarked (Free) | Auto & Manual (Pro) |

---

## 8. Photo Album Auto-Save & Permissions Flow
- Check `Permission.photos` (or `Permission.photosAddOnly`) before attempting to write to gallery.
- In case of permission rejection or platform error, catch gracefully and present an actionable dialog with "Open Settings" button. Never swallow exceptions silently or falsely claim "Auto-saved to Photos".
