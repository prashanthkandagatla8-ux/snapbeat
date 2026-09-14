"use client";

import React, { useState, useRef, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import RetroAdBanner from "@/components/ads/RetroAdBanner";
import {
  Volume2,
  VolumeX,
  Play,
  Pause,
  Square,
  Sparkles,
  Crown,
  Zap,
  Music,
  Video,
  ArrowRight,
  ShieldCheck,
  User,
  Film,
  Share2,
  X,
  Info,
  Clock,
  Check,
} from "lucide-react";

export default function ShowcaseHome({ onEnterStudio, onOpenPricing }) {
  const { user, openAuthModal } = useAuth();
  const [isReelModalOpen, setIsReelModalOpen] = useState(false);
  const [isAboutModalOpen, setIsAboutModalOpen] = useState(false);
  const [modalMuted, setModalMuted] = useState(false);
  const modalVideoRef = useRef(null);

  const scrollToSection = (id) => {
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  };

  return (
    <div className="w-full flex flex-col items-center py-2 px-2 sm:px-4 max-w-[1000px] mx-auto select-none space-y-8 animate-fadeIn">
      {/* =========================================================================
          SIGNATURE TABLET CHASSIS WITH AUTHENTIC METALLIC EDGE FRAME
          ========================================================================= */}
      <section
        id="hero"
        className="w-full relative rounded-[36px] sm:rounded-[44px] overflow-hidden shadow-[0_30px_90px_rgba(0,0,0,0.95)] border-4 border-[#2c333a] bg-[#07191f] text-white"
      >
        {/* Sky Canvas Background with Atmospheric Vignette */}
        <div className="relative w-full sky-canvas p-4 sm:p-7 md:p-8 flex flex-col items-center justify-between min-h-[700px] sm:min-h-[820px]">
          {/* Subtle Ambient Radial Flare */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-xl h-64 bg-radial from-amber-400/20 via-amber-500/5 to-transparent blur-3xl pointer-events-none -z-10" />

          {/* -------------------------------------------------------------
              1. REAL TOP NAVIGATION BAR (NO FAKE DRAWN BUTTONS)
              ------------------------------------------------------------- */}
          <header className="w-full flex items-center justify-between pb-4 border-b border-white/15 gap-2 relative z-20">
            {/* Left: SnapBeat 3D Logo */}
            <button
              type="button"
              onClick={() => scrollToSection("hero")}
              className="flex items-center gap-2 cursor-pointer group hover:opacity-95 transition"
              title="SnapBeat Home"
              aria-label="SnapBeat Home"
            >
              <img
                src="/assets/images/snapbeat_logo_3d.png"
                alt="SnapBeat"
                className="h-8 sm:h-9 md:h-10 w-auto object-contain drop-shadow-md group-hover:scale-105 transition-transform"
              />
            </button>

            {/* Center: Real Interactive Navigation Links */}
            <nav className="flex items-center gap-2 sm:gap-4 md:gap-6 text-xs sm:text-sm font-black" aria-label="Main Navigation">
              <button
                type="button"
                onClick={() => scrollToSection("hero")}
                className="px-2.5 py-1 text-amber-300 hover:text-white transition cursor-pointer rounded-lg hover:bg-white/10"
              >
                Home
              </button>
              <button
                type="button"
                onClick={onEnterStudio}
                className="px-2.5 py-1 text-white/80 hover:text-amber-200 transition cursor-pointer rounded-lg hover:bg-white/10 flex items-center gap-1"
                title="Open Studio Workstation"
              >
                <span>Create</span>
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse hidden sm:inline-block" />
              </button>
              <button
                type="button"
                onClick={() => setIsReelModalOpen(true)}
                className="px-2.5 py-1 text-white/80 hover:text-amber-200 transition cursor-pointer rounded-lg hover:bg-white/10"
                title="Watch Sample Reels with Sound"
              >
                Explore
              </button>
              <button
                type="button"
                onClick={() => setIsAboutModalOpen(true)}
                className="px-2.5 py-1 text-white/80 hover:text-amber-200 transition cursor-pointer rounded-lg hover:bg-white/10"
                title="About SnapBeat Studio & Features"
              >
                About
              </button>
            </nav>

            {/* Right: Real User Authentication / Account Profile */}
            <div className="flex items-center">
              {user ? (
                <div className="flex items-center gap-1.5 bg-[#1b262c]/90 backdrop-blur-md px-2.5 sm:px-3 py-1 rounded-full border border-amber-400/60 shadow-lg">
                  {user.picture ? (
                    <img
                      src={user.picture}
                      alt={user.name || "User"}
                      className="w-5 h-5 sm:w-6 sm:h-6 rounded-full object-cover border border-[#ffc72c]"
                    />
                  ) : (
                    <div className="w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-[#ffc72c] text-[#2b2820] font-black text-[10px] flex items-center justify-center">
                      {(user.name || user.email || "U")[0].toUpperCase()}
                    </div>
                  )}
                  <button
                    type="button"
                    onClick={onEnterStudio}
                    className="text-[10px] sm:text-xs font-black text-amber-300 hover:text-white uppercase tracking-wider pl-1 cursor-pointer flex items-center gap-1"
                  >
                    <span>STUDIO</span>
                    <ArrowRight className="w-3 h-3" />
                  </button>
                </div>
              ) : (
                <button
                  type="button"
                  onClick={openAuthModal}
                  className="px-3.5 sm:px-4 py-1.5 sm:py-2 rounded-full btn-gold-radiant text-[#261b02] font-black text-xs sm:text-sm tracking-wide shadow-md hover:scale-105 active:scale-95 transition flex items-center gap-1.5 cursor-pointer"
                  title="Sign In to SnapBeat"
                  aria-label="Sign In"
                >
                  <User className="w-3.5 h-3.5 fill-current text-[#261b02]" />
                  <span>Sign In</span>
                </button>
              )}
            </div>
          </header>

          {/* -------------------------------------------------------------
              2. REAL HERO CENTER: 3D LOGO + SCRIPT TAGLINE + START CREATING CTA
              ------------------------------------------------------------- */}
          <div className="relative z-10 flex flex-col items-center text-center my-auto py-4 space-y-4 w-full">
            {/* Big 3D Logo Header */}
            <div className="relative inline-block hover:scale-[1.02] transition-transform duration-300">
              <img
                src="/assets/images/snapbeat_logo_3d.png"
                alt="SnapBeat 3D Title"
                className="h-16 sm:h-24 md:h-28 w-auto object-contain drop-shadow-[0_15px_35px_rgba(0,0,0,0.85)]"
              />
            </div>

            {/* Script Tagline */}
            <h2 className="font-script text-2xl sm:text-3xl md:text-4xl text-[#fffae8] font-bold tracking-wide drop-shadow-md">
              Not just a video... It's your story in motion.
            </h2>

            {/* Radiant Tactile "Start Creating" Button */}
            <div className="flex items-center justify-center gap-2 sm:gap-3 pt-2">
              <span className="text-amber-300/60 font-mono text-sm sm:text-base tracking-widest hidden sm:inline select-none">
                \\
              </span>
              <button
                type="button"
                onClick={onEnterStudio}
                className="px-8 sm:px-11 py-3.5 sm:py-4 rounded-full btn-gold-radiant text-[#261b02] font-black text-base sm:text-lg tracking-wide shadow-[0_10px_35px_rgba(245,158,11,0.65)] hover:scale-105 active:scale-95 transition-all flex items-center gap-2.5 cursor-pointer border border-[#fff4b8]"
                title="Enter Studio Workstation"
              >
                <Play className="w-5 h-5 fill-current ml-0.5" />
                <span>Start Creating</span>
              </button>
              <span className="text-amber-300/60 font-mono text-sm sm:text-base tracking-widest hidden sm:inline select-none">
                //
              </span>
            </div>

            {/* -------------------------------------------------------------
                3. REAL CENTERPIECE ARTWORK: VINTAGE CAMERA & FILMSTRIP WITH INTERACTIVE PLAY
                ------------------------------------------------------------- */}
            <div className="relative w-full max-w-[500px] mx-auto pt-2 group">
              <div className="relative overflow-hidden rounded-3xl shadow-2xl flex items-center justify-center">
                <img
                  src="/assets/images/snapbeat_camera_filmstrip.png"
                  alt="SnapBeat Vintage Camera with 35mm Filmstrip"
                  className="w-full h-auto object-contain max-h-[320px] sm:max-h-[380px] drop-shadow-[0_20px_40px_rgba(0,0,0,0.8)] select-none pointer-events-none transition-transform duration-500 group-hover:scale-[1.02]"
                />

                {/* Pulsing Interactive Play Lens Button (Taps to open sample reel with sound) */}
                <button
                  type="button"
                  onClick={() => setIsReelModalOpen(true)}
                  className="absolute top-[48%] left-[49%] -translate-x-1/2 -translate-y-1/2 w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-red-500 via-[#d62828] to-red-700 text-white flex items-center justify-center shadow-[0_0_30px_rgba(239,68,68,0.8)] hover:scale-115 active:scale-95 transition-all cursor-pointer border-2 border-white/80 group/lens z-20"
                  title="Watch Beat-Synced Sample Reel (with audio)"
                  aria-label="Play Sample Reel"
                >
                  <span className="absolute inset-0 rounded-full bg-red-400/40 animate-ping pointer-events-none" />
                  <Play className="w-7 h-7 fill-white ml-0.5" />
                </button>

                {/* Floating Hint Tag */}
                <div className="absolute bottom-2 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-black/85 backdrop-blur-md border border-amber-400/50 text-amber-200 text-[10px] font-black uppercase tracking-wider shadow-lg pointer-events-none">
                  ▶ Tap Lens to Watch Sample Reel
                </div>
              </div>
            </div>
          </div>

          {/* -------------------------------------------------------------
              4. REAL BOTTOM DOCK: 4 INTERACTIVE FEATURE BUTTON CARDS
              ------------------------------------------------------------- */}
          <div className="w-full grid grid-cols-2 md:grid-cols-4 gap-2.5 sm:gap-3.5 pt-4 z-20 border-t border-white/15">
            {/* Card 1: Create Videos */}
            <button
              type="button"
              onClick={onEnterStudio}
              className="flex flex-col items-center text-center p-3 sm:p-4 rounded-2xl bg-black/45 hover:bg-amber-400/15 border border-white/10 hover:border-amber-400/50 backdrop-blur-md transition-all active:scale-95 cursor-pointer group shadow-md"
              title="Create Videos in Studio"
            >
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center mb-1.5 shadow-sm group-hover:scale-110 transition-transform">
                <Video className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider group-hover:text-amber-300">
                Create Videos
              </h4>
              <p className="text-[10px] sm:text-[11px] text-amber-100/70 mt-0.5">
                Beat-synced reels from photos in seconds
              </p>
            </button>

            {/* Card 2: AI Powered */}
            <button
              type="button"
              onClick={onEnterStudio}
              className="flex flex-col items-center text-center p-3 sm:p-4 rounded-2xl bg-black/45 hover:bg-pink-400/15 border border-white/10 hover:border-pink-400/50 backdrop-blur-md transition-all active:scale-95 cursor-pointer group shadow-md"
              title="AI Beat & Rhythm Detection"
            >
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-pink-500/20 text-pink-400 flex items-center justify-center mb-1.5 shadow-sm group-hover:scale-110 transition-transform">
                <Sparkles className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider group-hover:text-pink-300">
                AI Powered
              </h4>
              <p className="text-[10px] sm:text-[11px] text-amber-100/70 mt-0.5">
                Automated audio beat & onset detection
              </p>
            </button>

            {/* Card 3: Stunning Templates */}
            <button
              type="button"
              onClick={() => setIsReelModalOpen(true)}
              className="flex flex-col items-center text-center p-3 sm:p-4 rounded-2xl bg-black/45 hover:bg-emerald-400/15 border border-white/10 hover:border-emerald-400/50 backdrop-blur-md transition-all active:scale-95 cursor-pointer group shadow-md"
              title="Watch 14 Motion Templates Reel"
            >
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center mb-1.5 shadow-sm group-hover:scale-110 transition-transform">
                <Film className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider group-hover:text-emerald-300">
                14 Templates
              </h4>
              <p className="text-[10px] sm:text-[11px] text-amber-100/70 mt-0.5">
                Cinematic motion choreography presets
              </p>
            </button>

            {/* Card 4: Easy Sharing */}
            <button
              type="button"
              onClick={() => setIsReelModalOpen(true)}
              className="flex flex-col items-center text-center p-3 sm:p-4 rounded-2xl bg-black/45 hover:bg-sky-400/15 border border-white/10 hover:border-sky-400/50 backdrop-blur-md transition-all active:scale-95 cursor-pointer group shadow-md"
              title="Quick MP4 Sharing"
            >
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-sky-500/20 text-sky-400 flex items-center justify-center mb-1.5 shadow-sm group-hover:scale-110 transition-transform">
                <Share2 className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider group-hover:text-sky-300">
                Easy Sharing
              </h4>
              <p className="text-[10px] sm:text-[11px] text-amber-100/70 mt-0.5">
                Instant MP4 export for Reels, Shorts &amp; Status
              </p>
            </button>
          </div>
        </div>
      </section>

      {/* =========================================================================
          SPONSORED BROADCAST AD BANNER (VISIBLE FOR FREE TIER USERS)
          ========================================================================= */}
      <RetroAdBanner isPro={Boolean(user?.isPro)} onOpenPricing={onOpenPricing} />

      {/* =========================================================================
          FREE VS PRO COMPARISON SECTION (WITH COMING SOON BADGE & DISABLED PURCHASE)
          ========================================================================= */}
      <section
        id="features-pricing"
        className="w-full sky-glass-panel rounded-3xl p-6 sm:p-8 text-white space-y-6"
      >
        <div className="text-center space-y-2 max-w-xl mx-auto">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/20 text-amber-300 text-xs font-black uppercase tracking-wider border border-amber-400/40">
            <Sparkles className="w-3.5 h-3.5" />
            <span>STUDIO TIERS COMPARISON</span>
          </div>
          <h3 className="text-xl sm:text-2xl font-black uppercase tracking-tight">
            FREE PUBLIC BETA VS PRO STUDIO PASS
          </h3>
          <p className="text-xs text-amber-100/70">
            Enjoy unlimited free reel creation during our public beta. Pro Master tier with priority processing is coming soon!
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* FREE TIER CARD */}
          <div className="p-5 sm:p-6 rounded-2xl bg-black/40 border border-white/15 flex flex-col justify-between space-y-4">
            <div>
              <div className="flex items-center justify-between">
                <h4 className="font-black text-base text-white uppercase">FREE TIER</h4>
                <span className="px-2.5 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 font-mono font-bold text-[10px] border border-emerald-500/40">
                  LIVE TODAY
                </span>
              </div>
              <p className="text-2xl font-black text-amber-300 mt-2">₹0 / FOREVER</p>
              <p className="text-xs text-amber-100/70 mt-1">100% Free unlimited reel renders during Public Beta</p>

              <ul className="mt-4 space-y-2 text-xs font-semibold text-white/90">
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-emerald-400 shrink-0" />
                  <span>Unlimited Video Renders</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-emerald-400 shrink-0" />
                  <span>Curated Music Library &amp; Custom MP3 Uploads</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-emerald-400 shrink-0" />
                  <span>Automatic Motion Template Assignment</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-emerald-400 shrink-0" />
                  <span>Standard 480p MP4 Export with Watermark</span>
                </li>
              </ul>
            </div>

            <button
              type="button"
              onClick={onEnterStudio}
              className="w-full py-3 rounded-xl btn-gold-radiant text-[#261b02] font-black text-xs uppercase tracking-wider shadow-md hover:scale-105 active:scale-95 transition cursor-pointer"
            >
              START RENDERING FREE ❯
            </button>
          </div>

          {/* PRO PASS CARD (DISABLED & LABELED COMING SOON) */}
          <div className="p-5 sm:p-6 rounded-2xl bg-amber-500/15 border-2 border-amber-400/60 flex flex-col justify-between space-y-4 shadow-xl">
            <div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-1.5">
                  <Crown className="w-4 h-4 text-amber-400" />
                  <h4 className="font-black text-base text-amber-300 uppercase">PRO STUDIO PASS</h4>
                </div>
                <span className="px-2.5 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] font-mono font-black text-[10px] uppercase shadow">
                  COMING SOON
                </span>
              </div>
              <div className="flex items-baseline gap-2 mt-2">
                <p className="text-2xl font-black text-amber-300">₹99 - ₹999</p>
                <span className="text-xs text-amber-100/70">/ week, month, or annual</span>
              </div>
              <p className="text-xs text-amber-100/70 mt-1">Payment integration in progress • Coming soon to all creators</p>

              <ul className="mt-4 space-y-2 text-xs font-semibold text-white/90">
                <li className="flex items-center gap-2">
                  <Crown className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>1080p Master Studio Crisp Clarity</span>
                </li>
                <li className="flex items-center gap-2">
                  <Crown className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>100% Watermark-Free Export</span>
                </li>
                <li className="flex items-center gap-2">
                  <Crown className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>Manual Selection of all 14 Motion Templates</span>
                </li>
                <li className="flex items-center gap-2">
                  <Crown className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>Opening Cinematic Title Cards with Custom Typography</span>
                </li>
                <li className="flex items-center gap-2">
                  <Crown className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>Priority Queue Scheduling &amp; Ad-Free Downloads</span>
                </li>
              </ul>
            </div>

            {/* Disabled Coming Soon Button */}
            <button
              type="button"
              disabled={true}
              aria-disabled="true"
              className="w-full py-3 rounded-xl bg-amber-400/20 text-amber-300 border border-amber-400/40 font-black text-xs uppercase tracking-wider cursor-not-allowed opacity-75 flex items-center justify-center gap-1.5 shadow-inner select-none"
            >
              <Clock className="w-3.5 h-3.5 text-amber-400" />
              <span>PRO PASS — COMING SOON</span>
            </button>
          </div>
        </div>
      </section>

      {/* =========================================================================
          SHOWCASE REEL VIDEO MODAL (POPUP PLAYER WITH SOUND)
          ========================================================================= */}
      {isReelModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-3 sm:p-6 animate-fadeIn">
          <div className="relative w-full max-w-[440px] bg-[#07171c] rounded-3xl border border-white/20 shadow-[0_25px_80px_rgba(0,0,0,0.95)] p-4 sm:p-5 flex flex-col items-center space-y-4">
            {/* Modal Header */}
            <div className="w-full flex items-center justify-between pb-2 border-b border-white/15">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse" />
                <span className="font-mono text-xs font-black text-amber-300 tracking-wider uppercase">
                  SNAPBEAT SAMPLE REEL
                </span>
              </div>
              <button
                type="button"
                onClick={() => setIsReelModalOpen(false)}
                className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
                title="Close Sample Reel"
                aria-label="Close"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Video Viewport */}
            <div className="relative aspect-[9/16] w-full rounded-2xl overflow-hidden bg-black border border-white/20 shadow-inner">
              <video
                ref={modalVideoRef}
                src="/assets/videos/showcase_reel.mp4"
                autoPlay
                loop
                playsInline
                muted={modalMuted}
                className="w-full h-full object-cover"
              />
              <button
                type="button"
                onClick={() => setModalMuted(!modalMuted)}
                className="absolute top-3 right-3 px-3 py-1.5 rounded-xl bg-black/70 backdrop-blur-md border border-white/20 text-white text-xs font-bold flex items-center gap-1.5 shadow-lg cursor-pointer hover:bg-black/90"
              >
                {modalMuted ? <VolumeX className="w-4 h-4 text-red-400" /> : <Volume2 className="w-4 h-4 text-emerald-400" />}
                <span>{modalMuted ? "UNMUTE" : "MUTED"}</span>
              </button>
            </div>

            {/* Modal Action CTA -> Enters Studio directly */}
            <button
              type="button"
              onClick={() => {
                setIsReelModalOpen(false);
                onEnterStudio();
              }}
              className="w-full py-3.5 rounded-2xl btn-brass text-[#261b02] font-black text-sm uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <span>CREATE YOUR OWN REEL NOW ❯</span>
            </button>
          </div>
        </div>
      )}

      {/* =========================================================================
          ABOUT SNAPBEAT STUDIO MODAL
          ========================================================================= */}
      {isAboutModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fadeIn">
          <div className="relative w-full max-w-lg bg-[#07171c] rounded-3xl border border-white/20 shadow-2xl p-6 space-y-4 text-white">
            <div className="flex items-center justify-between pb-3 border-b border-white/15">
              <div className="flex items-center gap-2">
                <Info className="w-5 h-5 text-amber-400" />
                <h3 className="font-black text-sm uppercase tracking-wider text-amber-300">
                  ABOUT SNAPBEAT STUDIO
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setIsAboutModalOpen(false)}
                className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 text-xs text-amber-100/80 leading-relaxed max-h-[60vh] overflow-y-auto pr-1">
              <p>
                <strong>SnapBeat</strong> is a tactile audio-visual reel maker that turns your favorite photo collections into rhythmically synchronized short-form video reels in seconds.
              </p>
              <div className="p-3 rounded-xl bg-black/40 border border-white/10 space-y-1">
                <p className="font-black text-amber-300 text-xs uppercase">Key Highlights:</p>
                <ul className="list-disc pl-4 space-y-1 text-[11px]">
                  <li><strong>AI Onset Beat Matching:</strong> Automatically detects rhythm spikes, kicks, and drop points to coordinate cuts.</li>
                  <li><strong>14 Cinematic Motion Styles:</strong> Dynamic pans, zooms, slides, glitch cuts, and pendulum motions.</li>
                  <li><strong>Curated Royalty-Free Library:</strong> High-tempo beats, lo-fi, EDM, and cinematic tracks ready to render.</li>
                  <li><strong>Free Unlimited Renders:</strong> Enjoy full access during our public beta.</li>
                </ul>
              </div>
              <p className="text-[11px] text-white/60">
                Designed with tactile retro audio hardware aesthetics, SnapBeat blends vintage recording console charm with modern cloud GPU processing.
              </p>
            </div>

            <button
              type="button"
              onClick={() => {
                setIsAboutModalOpen(false);
                onEnterStudio();
              }}
              className="w-full py-3 rounded-2xl btn-gold-radiant text-[#261b02] font-black text-xs uppercase tracking-wider shadow-lg hover:scale-105 active:scale-95 transition cursor-pointer"
            >
              LAUNCH STUDIO WORKSTATION ❯
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

