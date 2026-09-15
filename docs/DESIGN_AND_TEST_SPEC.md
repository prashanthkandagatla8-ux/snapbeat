# SnapBeat Master Architecture, Design & Test Specification
> **Document Status**: Living Master Document  
> **Last Updated**: 2026-09-15  
> **Applicable Repositories**: `SnapBeat` (Android), `SnapBeat-Web` (Next.js), `SnapBeatServer` (Render Engine)

---

## 1. System Architecture & Ecosystem

```mermaid
graph TD
    subgraph Client_Applications [Client Applications]
        WebClient["SnapBeat-Web (Next.js 14 + Tailwind)"]
        AndroidClient["SnapBeat Android (Kotlin + WorkManager)"]
    end

    subgraph Monetization_Layer [Monetization & Auth]
        WebAuth["Auth Context (Guest + Google/Email)"]
        WebBilling["Cashfree & Razorpay Gateway (₹49, ₹99, ₹199, ₹999)"]
        PlayBilling["Google Play In-App Billing Client 7.0"]
        AdMobNetwork["Google AdMob Rewarded Video Ads"]
    end

    subgraph Cloud_Rendering_Engine [Cloud Render Engine (34.93.112.240)]
        APIGateway["FastAPI Gateway (/api/render/mobile)"]
        WorkerQueue["Background Render Worker & DB Queue"]
        Choreographer["Choreography & Beat Detection Engine"]
        FFmpegEngine["FFmpeg Kinetic Hardware Compositor"]
    end

    WebClient --> WebAuth
    WebClient --> WebBilling
    AndroidClient --> PlayBilling
    AndroidClient --> AdMobNetwork

    WebClient -- "Multipart Job (Watermark: Web 3D Top-Left)" --> APIGateway
    AndroidClient -- "Multipart Job (Watermark: Mobile Sticker Bottom-Right)" --> APIGateway
    APIGateway --> WorkerQueue
    WorkerQueue --> Choreographer
    Choreographer --> FFmpegEngine
```

---

## 2. Core Design & Feature Specifications

### 2.1 Watermark Policy & Platform Separation
* **Web Renders**:
  - **Free Tier**: Top-left 3D SnapBeat Web logo watermark (`public/assets/brand/snapbeat_web_watermark.png`) overlaid with drop-shadow.
  - **Pro Tier**: 100% clean video export, zero watermark.
* **Mobile Renders**:
  - **Free Tier**: Bottom-right sticker watermark.
  - **Pro Tier / Credit Purchase**: Clean export without watermark.
* **Server Verification**: Render engine distinguishes requests via `watermark_type="web"` or `watermark_type="mobile"`.

### 2.2 Audio Engine & 16-Track Royalty-Free Catalog
Both Web and Android are strictly synchronized with all 16 royalty-free tracks:
1. `funk_smooth_party.mp3` — **Funk Smooth Party** (Nu-Funk / Retro, 124 BPM, 71.5s)
2. `urban_boom_bap.mp3` — **Urban Boom Bap (46s)** (Hip-Hop / Rap, 92 BPM, 46.0s)
3. `rap_beat_extended.mp3` — **Urban Boom Bap (66s)** (Hip-Hop / Rap, 92 BPM, 66.4s)
4. `hood_90s_boombap.mp3` — **90s Hood Boom Bap** (Golden Era / 90s, 90 BPM, 174.0s)
5. `voicemails_90s_boombap.mp3` — **90s Voicemails** (Lo-Fi / 90s, 88 BPM, 176.1s)
6. `sweet_life_chill.mp3` — **Sweet Life Lounge** (Downtempo / Chill, 85 BPM, 102.3s)
7. `lofi_sunset_beat.mp3` — **Lo-Fi Sunset Beat** (Lo-Fi / Study, 80 BPM, 113.5s)
8. `chill_vlog_beat.mp3` — **Chill Vlog Hip-Hop** (Lo-Fi / Vlog, 90 BPM, 96.0s)
9. `percussion_drive.mp3` — **Percussion Drive** (Acoustic / Stomp, 115 BPM, 76.0s)
10. `action_stinger.mp3` — **Action Stinger** (Dynamic / Short, 130 BPM, 44.9s)
11. `celebration_anthem.mp3` — **Celebration Anthem** (Festive / Pop, 120 BPM, 130.9s)
12. `heavy_bass_dubstep.mp3` — **Heavy Bass Dubstep** (Bass / Dubstep, 140 BPM, 156.0s)
13. `melodic_techno_journey.mp3` — **Melodic Techno Journey** (Techno / Deep, 126 BPM, 304.0s)
14. `melody_so_melody.mp3` — **Melody So Melody** (House / Dance, 122 BPM, 166.6s)
15. `aerobic_edm_remix.mp3` — **Aerobic EDM Remix** (EDM / Workout, 97 BPM, 156.9s)
16. `emotional_happy_boombap.mp3` — **Goodbye Emotional Beat** (Emotional / Hip-Hop, 88 BPM, 243.6s)

### 2.3 Motion Presets & Templates (14 Kinetic Styles)
Every template has dedicated MP4 and JPG preview assets in `public/assets/previews/`:
* `beat-bounce` (High energy bounce on primary kick drums)
* `beat-cut` (Snappy clean cuts on 1/4 and 1/8 note chops)
* `beat-fade` (Dreamy crossfades timed to melody downbeats)
* `beat-pulse` (Rhythmic bass pulse zoom)
* `beat-slide` (Horizontal kinetic slide transitions)
* `beat-whip` (Aggressive whip pans on snare drops)
* `cinematic-zoom` (Gradual slow push with dramatic cutbacks)
* `glide-pan` (Smooth camera tracking transitions)
* `pendulum` (Subtle swinging parallax sway)
* `punch-cut` (Hard impact frame zoom on transients)
* `reveal-tiles` (Retro grid-tile card reveals)
* `slow-drift` (Calm ambient drift for lo-fi aesthetics)
* `sway-ballad` (Rhythmic pendulum sway for vocal tracks)
* `zoom-out-reveal` (Dynamic pull-back revealing new photo layers)

### 2.4 Photo Stacking & Ingestion Rules
* Supported range: **2 to 60 photos**.
* Ingestion must be **additive**: selecting more photos appends to existing selection up to 60.
* Re-ordering enabled via drag & drop.
* Confirmation dialog on clear/reset.

### 2.5 Pricing & Monetization Model
* **Web Tiers**:
  * **1 Day**: ₹49 (`daily`) — Quick Pass
  * **1 Week**: ₹99 (`weekly`) — Popular
  * **1 Month**: ₹199 (`monthly`) — Best Value
  * **1 Year**: ₹999 (`annual`) — VIP Pass
* **Guest Pro Gate**:
  * Free creation & rendering is 100% accessible to guests.
  * Clicking "Upgrade to Pro" triggers sign-in modal (`RetroAuthModal.jsx`) ensuring subscriptions attach to persistent accounts.
* **Mobile Tiers**:
  * Free tier with AdMob Rewarded Ads (1 ad = 1 credit).
  * In-app purchase packs: Starter (10 credits), Party (35 credits), Studio (80 credits), Director (200 credits).
  * Subscriptions: Monthly (₹199), Yearly (₹999).

### 2.6 Tactile Hardware, Two-Panel Header & CRT Aesthetics
* **Web Chassis**: High-end light cream/champagne brushed metal (`#eae5dc`, `#dfd8cb`, `#f4f0e8`) with machined bevels and specular catchlights.
* **Header Architecture (Two Panels, Zero Arrows)**:
  - **Top Panel**: Brand logo (SnapBeat 3D logo), cluster health status (`ONLINE`/`OFFLINE`), Showcase button on left; Tier status (`FREE TIER` / `PRO ACTIVE`), Pro Upgrade button, and Account / Guest controls on right. No "Studio" badge.
  - **Second Panel (Workflow Console)**: Dedicated full-width tactile row directly below the top panel displaying all 4 workflow buttons simultaneously (`MUSIC`, `PHOTOS`, `RENDER`, `QUEUE`).
  - **Active State**: Selected page displays illuminated brass styling (`btn-brass`), glowing active LED indicator, and bold typography. Inactive pages display darkened tactile bezel styling and can be clicked to switch directly.
  - **Zero Arrows**: Strictly avoids prev/next chevron buttons (`ChevronLeft`/`ChevronRight`) for direct 1-click access.
* **Brand Name Integrity**: The application is strictly **SnapBeat** (never "SnapBeat Studio").
* **CRT Viewfinder**: Scanlines overlay, ambient vignette, live video loop, audio toggle, and expanded 9:16 inspection modal.
* **Zero Job ID Display**: Job numbers kept strictly in background/state, never visible in user UI.

---

## 3. End-to-End Test Matrix & Verification Protocols

Whenever testing or changes occur, this checklist must be verified:

| Test ID | Area | Verification Step | Pass Criteria |
| :--- | :--- | :--- | :--- |
| **TEST-01** | Build | Run `npm run build` on SnapBeat-Web | Exit code 0, all 36 static pages & routes prerendered |
| **TEST-02** | Build | Run `./gradlew assembleDebug` on SnapBeat | Exit code 0, `app-debug.apk` produced without compilation errors |
| **TEST-03** | Server | Query `GET http://34.93.112.240/api/health` | HTTP 200 OK, `available >= 1` |
| **TEST-04** | Music Sync | Verify all 16 MP3 files exist in Web & Android assets | Non-zero size, exact filename match across platforms |
| **TEST-05** | Previews | Verify 14 MP4 + 14 JPG files in Web previews directory | All 14 presets play in CRT viewfinder; poster displays while buffering |
| **TEST-06** | Showcase Reel | Verify `showcase_reel.mp4` on Web landing page | Clean top-left logo, no delogo blur/smudge, smooth 30fps playback |
| **TEST-07** | Pricing | Verify 4 plans in Web Store Modal | ₹49 (1 Day), ₹99 (1 Week), ₹199 (1 Month), ₹999 (1 Year) correctly displayed |
| **TEST-08** | Guest Gate | Click "Upgrade to Pro" as guest in Web | Sign-in modal appears; guest button hidden; store opens on sign-in |
| **TEST-09** | Job ID Privacy | Inspect Web Render & Queue pages | Job ID never displayed in headers, cards, or titles |
| **TEST-10** | Android Audio | Tap "✨ CHOOSE SAMPLE MUSIC" in Android | Dialog displays all 16 tracks with genres & BPM; loads selected track |
| **TEST-11** | Android Photos | Pick photos multiple times in Android | Selection is additive up to 60 photos; clear prompt on reset |
| **TEST-12** | Two-Panel Header | Inspect Web workstation navigation | Top panel displays brand & account; second panel displays all 4 buttons at once without arrows |
| **TEST-13** | Brand Name | Search all UI for "SnapBeat Studio" | 0 occurrences in visible UI; only "SnapBeat" used |

---

## 4. Android Release Readiness Audit & Upgrade Roadmap

Current Status for Production Google Play Release:

| Component | Current State | Release Requirement | Action Needed for Production Release |
| :--- | :--- | :--- | :--- |
| **Version Code** | `1` | Increment per release | Bump to `2` (or next sequence in Google Play) |
| **Version Name** | `"1.0"` | Public release version | Bump to `"1.1"` or `"2.0"` |
| **Target SDK** | `34` (Android 14) | Target SDK >= 34 | **READY** (Meets Google Play requirements) |
| **Package Format** | Debug APK built | `.aab` (Android App Bundle) | Run `./gradlew bundleRelease` |
| **Signing Config** | Debug keys only | Production Keystore (.jks) | Configure release signing block in `build.gradle` |
| **R8 / Proguard** | `minifyEnabled false` | Obfuscation & shrinking | Enable R8 minification & verify keep rules |
| **AdMob Unit IDs** | Google Test IDs | Developer AdMob IDs | Replace test IDs with production AdMob account IDs |
| **Billing Products** | Defined in code | Active in Play Console | Ensure product IDs match Google Play Console setup |
| **Privacy Compliance**| Prominent disclosure active | Google Play media policy | **READY** (Pre-permission modal active) |
