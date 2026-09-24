# SNAPBEAT — Neomorphic Design System
### Premium Creative Technology UI · 2026

## 1. Design Direction
**Product personality:**
> Premium creative studio + tactile physical hardware + modern Apple-like usability + soft neumorphic surfaces.

The interface should feel:
* sophisticated, tactile, calm, highly polished, spacious, precise
* playful enough for a creative app, technologically advanced, extremely easy to understand

Avoid making it look:
* overly glossy, toy-like, skeuomorphic, overly "crypto/Web3", gaming-oriented
* excessively futuristic, flat Material Design, generic Dribbble neumorphism

### Core visual concept
Think of the interface as a **physical creative workstation carved from a single soft material**.
Large surfaces appear gently raised from the background.

Controls appear either:
* **Raised**: button is physically sitting above the surface.
* **Pressed**: button appears physically pushed into the surface.
* **Inset**: control/content area appears recessed into the surface.

---

## 2. Color System
Base palette is cool-neutral. Do **not** use pure white as the dominant surface.

### Base colors
* Background / Canvas: `#F3F5F8`
* Primary Surface: `#F7F8FA`
* Secondary Surface: `#EEF1F5`
* Elevated Surface: `#FAFBFC`
* Inset Surface: `#ECEFF3`
* Dark Control: `#111722`
* Dark Control Hover: `#18202D`
* Dark Control Pressed: `#0C1119`
* Primary Text: `#18202B`
* Secondary Text: `#687181`
* Muted Text: `#9AA2AE`
* Divider: `#E1E5EA`
* White: `#FFFFFF`

### Brand accents (used sparingly for logo, tiny dots, status)
* Snap Orange: `#FF9B54`
* Snap Cyan: `#62C8FF`
* Snap Violet: `#A47CFF`
* Snap Pink: `#F078C8`
* Snap Green: `#6FD3A3`

---

## 3. Surface Hierarchy (5 Levels)
* **Level 0 — Canvas**: `#F3F5F8`
* **Level 1 — Raised Surface**: `#F7F8FA`
  * Light shadow: `0 -4px 10px rgba(255,255,255,0.85)`
  * Dark shadow: `0 5px 14px rgba(35,45,60,0.12)`
* **Level 2 — Strong Raised Surface**: `#F8F9FB`
  * Shadow: `0 7px 18px rgba(40,50,65,0.14)`, `0 -3px 10px rgba(255,255,255,0.90)`
* **Level 3 — Inset Surface**: `#ECEFF3`
  * Shadow: `inset 3px 3px 7px rgba(45,55,70,0.12)`, `inset -3px -3px 7px rgba(255,255,255,0.85)`
* **Level 4 — Dark Hardware Surface**:
  * Background: `linear-gradient(145deg, #1A212C, #0F151E)`
  * Shadow: `0 7px 16px rgba(18,25,35,0.28)`
  * Highlight: `inset 0 1px 1px rgba(255,255,255,0.08)`

---

## 4. Neomorphic Shadow Rules
* **Soft Raised**: `0 4px 10px rgba(40,50,65,0.08)`, `0 -3px 8px rgba(255,255,255,0.80)`
* **Medium Raised**: `0 8px 18px rgba(35,45,60,0.12)`, `0 -4px 12px rgba(255,255,255,0.90)`
* **Deep Floating**: `0 14px 28px rgba(30,40,55,0.16)`, `0 -5px 15px rgba(255,255,255,0.90)`
* Avoid dark, harsh shadows; use soft, broad, low-opacity shadows.

---

## 5. Border System
* Light surfaces: `1px solid rgba(255,255,255,0.70)`
* Dark surfaces: `1px solid rgba(255,255,255,0.07)`
* **CRITICAL FLUTTER RULE**: Always use uniform borders (`Border.all`) when a `borderRadius` is applied to avoid paint assertions.

---

## 6. Radius Hierarchy
* XS: `8px`
* SM: `12px`
* MD: `16px`
* LG: `22px`
* XL: `28px` (large panel)
* XXL: `34px`
* DOCK: `30px` (bottom dock top corners)
* PHOTO CARD: `24px` (outer), `18px` (inner image)
* PILL: `999px` (buttons, chips, status)

---

## 7. Component Specifics
* **ADD PHOTOS (+)**: Height 58px, radius 29px (pill), dark hardware background (`#1A212C` -> `#0F151E`), text 14px / 700.
* **SAMPLE PHOTOS**: Height 58px, radius 29px (pill), soft raised light surface `#F7F8FA`, text 14px / 700.
* **Photo Cards**: Padding 10px, radius 24px, background `#F8F9FB`, inner image radius 18px, integrated footer bar.
* **Studio Dock**: Background `#101620`, radius 30px (top), padding 14px, deep floating shadow `0 14px 28px rgba(20,25,35,.20)`.
  * Active tab: `#F7F8FA` with `#18202B` dark text.
  * Inactive tab: `#111722` with `#9AA2AE` text.
* **Slider Track**: Inset surface `#ECEFF3` with dark circular thumb.
* **Background Watermark**: Removed completely per user specification.
