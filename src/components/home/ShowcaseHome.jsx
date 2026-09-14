"use client";

import React, { useState, useRef } from "react";
import { useAuth } from "@/context/AuthContext";
import RetroAdBanner from "@/components/ads/RetroAdBanner";
import SeoFooter from "@/components/layout/SeoFooter";
import { trackStartCreating, trackGuestStarted, trackUpgradeViewed } from "@/lib/analytics";
import {
  Volume2,
  VolumeX,
  Play,
  Pause,
  Sparkles,
  Zap,
  Video,
  ArrowRight,
  User,
  Film,
  Share2,
  X,
  Info,
  Check,
} from "lucide-react";

export default function ShowcaseHome({ onEnterStudio, onOpenPricing }) {
  const { user, openAuthModal, loginAsGuest } = useAuth();
  const [isReelModalOpen, setIsReelModalOpen] = useState(false);
  const [isAboutModalOpen, setIsAboutModalOpen] = useState(false);

  // Inline Home Page Video State
  const [inlineMuted, setInlineMuted] = useState(true);
  const [inlinePlaying, setInlinePlaying] = useState(true);
  const inlineVideoRef = useRef(null);

  const toggleInlinePlay = () => {
    if (inlineVideoRef.current) {
      if (inlineVideoRef.current.paused) {
        inlineVideoRef.current.play();
        setInlinePlaying(true);
      } else {
        inlineVideoRef.current.pause();
        setInlinePlaying(false);
      }
    }
  };

  const toggleInlineMute = () => {
    if (inlineVideoRef.current) {
      inlineVideoRef.current.muted = !inlineMuted;
      setInlineMuted(!inlineMuted);
    }
  };

  // Studio Gate: Requires Login or 1-Click Guest Login
  const handleStudioAction = () => {
    trackStartCreating("/", "hero_cta");
    if (user) {
      onEnterStudio();
    } else {
      openAuthModal();
    }
  };

  const handleInstantGuest = () => {
    trackStartCreating("/", "guest_cta");
    trackGuestStarted("hero_guest_btn");
    loginAsGuest();
    onEnterStudio();
  };

  return (
    <div className="w-full flex flex-col items-center select-none sky-canvas text-white min-h-[780px] p-3 sm:p-6 md:p-7 space-y-4 sm:space-y-6 animate-fadeIn">
      {/* -------------------------------------------------------------
          1. TOP NAVIGATION BAR (SLEEK & MINIMAL)
          ------------------------------------------------------------- */}
      <header className="w-full flex items-center justify-between pb-3 border-b border-white/15 gap-2 relative z-20">
        {/* Left: SnapBeat 3D Logo */}
        <div className="flex items-center gap-2">
          <img
            src="/assets/images/snapbeat_logo_3d.png"
            alt="SnapBeat"
            className="h-8 sm:h-9 w-auto object-contain drop-shadow"
          />
          <span className="hidden sm:inline-block px-2 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] text-[9px] font-black uppercase tracking-wider shadow">
            STUDIO
          </span>
        </div>

        {/* Center: Minimal Navigation Links */}
        <nav className="flex items-center gap-1 sm:gap-3 text-xs font-black" aria-label="Main Navigation">
          <button
            type="button"
            onClick={handleStudioAction}
            className="px-2 py-1 text-white/90 hover:text-amber-300 transition cursor-pointer rounded-lg hover:bg-white/10 flex items-center gap-1 text-[11px] sm:text-xs"
            title="Open Studio Workstation"
          >
            <span>Create</span>
            <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" />
          </button>
          <button
            type="button"
            onClick={onOpenPricing}
            className="hidden sm:inline-block px-2 py-1 text-white/80 hover:text-amber-300 transition cursor-pointer rounded-lg hover:bg-white/10 text-xs"
            title="Free vs Pro Pricing"
          >
            Pricing
          </button>
          <button
            type="button"
            onClick={() => setIsAboutModalOpen(true)}
            className="hidden sm:inline-block px-2 py-1 text-white/80 hover:text-amber-300 transition cursor-pointer rounded-lg hover:bg-white/10 text-xs"
            title="About SnapBeat"
          >
            About
          </button>
        </nav>

        {/* Right: Guest Access / Account Pill */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {user ? (
            <div className="flex items-center gap-2 bg-[#1b262c]/90 backdrop-blur-md px-2.5 py-1 rounded-full border border-amber-400/50 shadow-sm">
              {user.picture ? (
                <img
                  src={user.picture}
                  alt={user.name || "User"}
                  className="w-5 h-5 rounded-full object-cover border border-[#ffc72c]"
                />
              ) : (
                <div className="w-5 h-5 rounded-full bg-[#ffc72c] text-[#2b2820] font-black text-[10px] flex items-center justify-center">
                  {(user.name || user.email || "U")[0].toUpperCase()}
                </div>
              )}
              <span className="text-[11px] font-black text-white/90 max-w-[90px] truncate hidden sm:inline">
                {user.name || user.email.split("@")[0]}
              </span>
              {user.isGuest && (
                <span className="px-1.5 py-0.2 rounded bg-amber-400/30 text-amber-300 text-[8px] font-mono font-black uppercase">
                  GUEST
                </span>
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
            <div className="flex items-center gap-1.5 sm:gap-2">
              <button
                type="button"
                onClick={handleInstantGuest}
                className="flex items-center gap-1 px-2.5 py-1 sm:px-3 sm:py-1.5 rounded-full bg-white/10 hover:bg-white/20 border border-white/20 text-white font-black text-[11px] sm:text-xs tracking-wide transition cursor-pointer shadow-sm active:scale-95"
                title="1-Click Instant Guest Access"
              >
                <Zap className="w-3 h-3 fill-current text-amber-400 shrink-0" />
                <span className="hidden sm:inline">Guest Access</span>
                <span className="sm:hidden">Guest</span>
              </button>

              <button
                type="button"
                onClick={openAuthModal}
                className="px-2.5 py-1 sm:px-3 sm:py-1.5 rounded-full btn-gold-radiant text-[#261b02] font-black text-[11px] sm:text-xs tracking-wide shadow hover:scale-105 active:scale-95 transition flex items-center gap-1 cursor-pointer"
                title="Sign In"
              >
                <User className="w-3 h-3 fill-current text-[#261b02] shrink-0" />
                <span>Sign In</span>
              </button>
            </div>
          )}
        </div>
      </header>

      {/* -------------------------------------------------------------
          2. MINIMAL HERO: TAGLINE & PRIMARY CTA
          ------------------------------------------------------------- */}
      <section className="w-full flex flex-col items-center text-center space-y-2 pt-1 relative z-10">
        <h1 className="text-xl sm:text-2xl md:text-3xl lg:text-4xl font-black text-white tracking-tight uppercase drop-shadow-md max-w-2xl">
          Turn Photos Into Beat-Synced Videos Automatically
        </h1>

        <p className="font-script text-xl sm:text-2xl md:text-3xl text-amber-200 font-semibold tracking-wide drop-shadow">
          Not just a video... It's your story in motion.
        </p>

        <p className="text-xs sm:text-sm text-amber-100/80 font-medium max-w-xl">
          Turn your photo memories into rhythmically synchronized short-form reels in seconds with AI beat detection and 14 cinematic kinetic motion styles.
        </p>
      </section>

      {/* -------------------------------------------------------------
          3. EMBEDDED SAMPLE REEL CENTERPIECE (PLAYS ON PAGE)
          ------------------------------------------------------------- */}
      <section className="w-full max-w-[700px] mx-auto flex flex-col sm:flex-row items-center justify-center gap-6 sm:gap-8 my-auto py-2">
        {/* Cinema Monitor Frame for 9:16 Video */}
        <div className="relative w-[210px] sm:w-[240px] aspect-[9/16] rounded-3xl overflow-hidden shadow-[0_20px_50px_rgba(0,0,0,0.9),0_0_20px_rgba(255,199,44,0.12)] border-2 border-white/20 bg-black group shrink-0">
          <video
            ref={inlineVideoRef}
            src="/assets/videos/showcase_reel.mp4"
            autoPlay
            loop
            playsInline
            muted={inlineMuted}
            className="w-full h-full object-cover"
            onPlay={() => setInlinePlaying(true)}
            onPause={() => setInlinePlaying(false)}
          />

          {/* CRT Scanline Overlay */}
          <div className="absolute inset-0 pointer-events-none crt-scanlines opacity-30" />

          {/* Top Bar Overlay */}
          <div className="absolute top-2 inset-x-2 flex items-center justify-between z-20 pointer-events-auto">
            <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-black/80 backdrop-blur-md border border-white/20 text-white text-[8px] font-mono font-black tracking-wider">
              <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse" />
              <span>LIVE DEMO</span>
            </div>

            <button
              type="button"
              onClick={toggleInlineMute}
              className={`px-2 py-0.5 rounded-lg backdrop-blur-md text-[9px] font-black uppercase tracking-wider flex items-center gap-1 shadow transition cursor-pointer ${
                inlineMuted
                  ? "bg-red-500/90 text-white animate-pulse border border-red-300"
                  : "bg-black/80 text-amber-300 border border-amber-400/50"
              }`}
              title={inlineMuted ? "Tap to Unmute Audio" : "Mute Audio"}
            >
              {inlineMuted ? (
                <>
                  <VolumeX className="w-3 h-3 fill-current" />
                  <span>UNMUTE 🔊</span>
                </>
              ) : (
                <>
                  <Volume2 className="w-3 h-3 text-emerald-400" />
                  <span>AUDIO ON</span>
                </>
              )}
            </button>
          </div>

          {/* Center Play/Pause Indicator on Hover */}
          <button
            type="button"
            onClick={toggleInlinePlay}
            className={`absolute inset-0 m-auto w-11 h-11 rounded-full bg-black/60 backdrop-blur-md border border-white/30 text-white flex items-center justify-center transition-opacity z-20 cursor-pointer ${
              inlinePlaying ? "opacity-0 group-hover:opacity-80" : "opacity-100"
            }`}
          >
            {inlinePlaying ? <Pause className="w-4 h-4 fill-white" /> : <Play className="w-4 h-4 fill-white ml-0.5" />}
          </button>

          {/* Bottom Bar: Template style */}
          <div className="absolute bottom-2 inset-x-2 flex items-center justify-between z-20">
            <span className="px-1.5 py-0.5 rounded bg-black/80 text-amber-300 font-mono text-[8px] font-bold border border-amber-400/30">
              BEAT-SYNCED • 1080P
            </span>
            <button
              type="button"
              onClick={() => setIsReelModalOpen(true)}
              className="px-1.5 py-0.5 rounded bg-black/80 text-white/80 hover:text-white font-mono text-[8px] font-bold border border-white/20 transition cursor-pointer"
            >
              EXPAND ⤢
            </button>
          </div>
        </div>

        {/* Side Console: Value Props + Master Button */}
        <div className="flex flex-col items-center sm:items-start text-center sm:text-left space-y-3.5 max-w-xs">
          <div className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-amber-400/20 border border-amber-400/30 text-amber-300 text-[10px] font-black uppercase tracking-wider">
            <Sparkles className="w-3 h-3" />
            <span>AI CHOREOGRAPHY</span>
          </div>

          <h3 className="text-lg sm:text-xl font-black text-white uppercase tracking-tight">
            Cinematic Motion On Every Beat
          </h3>

          <div className="space-y-1.5 w-full text-xs text-amber-100/80 font-medium">
            <div className="flex items-center gap-2">
              <Check className="w-3.5 h-3.5 text-emerald-400 shrink-0 stroke-[3]" />
              <span>Instant AI audio onset beat detection</span>
            </div>
            <div className="flex items-center gap-2">
              <Check className="w-3.5 h-3.5 text-emerald-400 shrink-0 stroke-[3]" />
              <span>14 Kinetic motion choreography presets</span>
            </div>
            <div className="flex items-center gap-2">
              <Check className="w-3.5 h-3.5 text-emerald-400 shrink-0 stroke-[3]" />
              <span>100% Free unlimited video renders</span>
            </div>
          </div>

          <div className="pt-2 w-full space-y-2">
            <button
              type="button"
              onClick={handleStudioAction}
              className="w-full sm:w-auto px-8 py-3.5 rounded-full btn-gold-radiant text-[#261b02] font-black text-sm tracking-wide shadow-lg hover:scale-105 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer border border-[#fff4b8]"
            >
              <Play className="w-4 h-4 fill-current" />
              <span>START CREATING</span>
            </button>
            <p className="text-[10px] text-amber-200/70 text-center sm:text-left">
              Instant 1-Click Guest Access • No signup required
            </p>
          </div>
        </div>
      </section>

      {/* -------------------------------------------------------------
          4. MINIMAL SPONSOR BAR (AESTHETIC & NON-INTRUSIVE)
          ------------------------------------------------------------- */}
      <div className="w-full max-w-2xl mx-auto z-20">
        <RetroAdBanner isPro={Boolean(user?.isPro)} onOpenPricing={onOpenPricing} className="my-0" />
      </div>

      {/* -------------------------------------------------------------
          5. BOTTOM DOCK: 4 INTERACTIVE FEATURE PILLS
          ------------------------------------------------------------- */}
      <section className="w-full grid grid-cols-2 md:grid-cols-4 gap-2 pt-2 z-20 border-t border-white/15">
        <button
          type="button"
          onClick={handleStudioAction}
          className="flex items-center gap-2.5 p-2.5 rounded-xl bg-black/40 hover:bg-amber-400/15 border border-white/10 hover:border-amber-400/40 backdrop-blur-md transition active:scale-95 cursor-pointer text-left"
        >
          <div className="w-8 h-8 rounded-lg bg-amber-500/20 text-amber-400 flex items-center justify-center shrink-0">
            <Video className="w-4 h-4" />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-black text-white truncate">Beat Sync</p>
            <p className="text-[10px] text-amber-100/60 truncate">Photos to MP4 reels</p>
          </div>
        </button>

        <button
          type="button"
          onClick={handleStudioAction}
          className="flex items-center gap-2.5 p-2.5 rounded-xl bg-black/40 hover:bg-pink-400/15 border border-white/10 hover:border-pink-400/40 backdrop-blur-md transition active:scale-95 cursor-pointer text-left"
        >
          <div className="w-8 h-8 rounded-lg bg-pink-500/20 text-pink-400 flex items-center justify-center shrink-0">
            <Sparkles className="w-4 h-4" />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-black text-white truncate">AI Onsets</p>
            <p className="text-[10px] text-amber-100/60 truncate">Automated cuts</p>
          </div>
        </button>

        <button
          type="button"
          onClick={handleStudioAction}
          className="flex items-center gap-2.5 p-2.5 rounded-xl bg-black/40 hover:bg-emerald-400/15 border border-white/10 hover:border-emerald-400/40 backdrop-blur-md transition active:scale-95 cursor-pointer text-left"
        >
          <div className="w-8 h-8 rounded-lg bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
            <Film className="w-4 h-4" />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-black text-white truncate">14 Templates</p>
            <p className="text-[10px] text-amber-100/60 truncate">Kinetic motion styles</p>
          </div>
        </button>

        <button
          type="button"
          onClick={handleStudioAction}
          className="flex items-center gap-2.5 p-2.5 rounded-xl bg-black/40 hover:bg-sky-400/15 border border-white/10 hover:border-sky-400/40 backdrop-blur-md transition active:scale-95 cursor-pointer text-left"
        >
          <div className="w-8 h-8 rounded-lg bg-sky-500/20 text-sky-400 flex items-center justify-center shrink-0">
            <Share2 className="w-4 h-4" />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-black text-white truncate">Fast Export</p>
            <p className="text-[10px] text-amber-100/60 truncate">Reels &amp; Shorts ready</p>
          </div>
        </button>
      </section>

      {/* -------------------------------------------------------------
          6. SLEEK FOOTER (INSIDE THE FRAME)
          ------------------------------------------------------------- */}
      <footer className="w-full flex flex-col sm:flex-row items-center justify-between text-[11px] text-amber-100/60 pt-2 border-t border-white/10 gap-2">
        <p>© 2026 SnapBeat Studio • Tactile Audio-Visual Reel Maker</p>
        <div className="flex items-center gap-3 font-semibold">
          <button type="button" onClick={onOpenPricing} className="hover:text-amber-300 transition cursor-pointer">
            Pricing
          </button>
          <button type="button" onClick={() => setIsAboutModalOpen(true)} className="hover:text-amber-300 transition cursor-pointer">
            About
          </button>
          <a href="/privacy" className="hover:text-amber-300 transition">Privacy</a>
          <a href="/terms" className="hover:text-amber-300 transition">Terms</a>
        </div>
      </footer>

      {/* -------------------------------------------------------------
          7. EXPANDED SAMPLE REEL MODAL
          ------------------------------------------------------------- */}
      {isReelModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fadeIn">
          <div className="relative w-full max-w-[400px] bg-[#07171c] rounded-3xl border border-white/20 shadow-2xl p-4 flex flex-col items-center space-y-3">
            <div className="w-full flex items-center justify-between pb-2 border-b border-white/15">
              <span className="font-mono text-xs font-black text-amber-300 uppercase">
                SNAPBEAT SAMPLE REEL
              </span>
              <button
                type="button"
                onClick={() => setIsReelModalOpen(false)}
                className="w-7 h-7 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="relative aspect-[9/16] w-full rounded-2xl overflow-hidden bg-black border border-white/20">
              <video
                src="/assets/videos/showcase_reel.mp4"
                autoPlay
                loop
                playsInline
                className="w-full h-full object-cover"
              />
            </div>

            <button
              type="button"
              onClick={() => {
                setIsReelModalOpen(false);
                handleStudioAction();
              }}
              className="w-full py-3 rounded-2xl btn-brass text-[#261b02] font-black text-xs uppercase tracking-wider shadow hover:brightness-110 active:scale-95 transition cursor-pointer"
            >
              CREATE YOUR OWN REEL NOW ❯
            </button>
          </div>
        </div>
      )}

      {/* -------------------------------------------------------------
          8. ABOUT MODAL
          ------------------------------------------------------------- */}
      {isAboutModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fadeIn">
          <div className="relative w-full max-w-md bg-[#07171c] rounded-3xl border border-white/20 shadow-2xl p-5 space-y-4 text-white">
            <div className="flex items-center justify-between pb-2 border-b border-white/15">
              <div className="flex items-center gap-2">
                <Info className="w-4 h-4 text-amber-400" />
                <h3 className="font-black text-xs uppercase tracking-wider text-amber-300">
                  ABOUT SNAPBEAT STUDIO
                </h3>
              </div>
              <button
                type="button"
                onClick={() => setIsAboutModalOpen(false)}
                className="w-7 h-7 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2.5 text-xs text-amber-100/80 leading-relaxed">
              <p>
                <strong>SnapBeat</strong> is a tactile audio-visual reel maker that turns your favorite photo collections into rhythmically synchronized short-form video reels in seconds.
              </p>
              <div className="p-3 rounded-xl bg-black/40 border border-white/10 space-y-1">
                <p className="font-black text-amber-300 text-[11px] uppercase">Key Features:</p>
                <ul className="list-disc pl-4 space-y-1 text-[11px]">
                  <li><strong>AI Onset Detection:</strong> Syncs visual transitions with audio drops and kicks.</li>
                  <li><strong>14 Motion Styles:</strong> Cinematic pans, zooms, slides, and glitch cuts.</li>
                  <li><strong>Free Unlimited Renders:</strong> Instant guest access with standard export queue.</li>
                </ul>
              </div>
            </div>

            <button
              type="button"
              onClick={() => {
                setIsAboutModalOpen(false);
                handleStudioAction();
              }}
              className="w-full py-2.5 rounded-xl btn-gold-radiant text-[#261b02] font-black text-xs uppercase tracking-wider shadow hover:scale-105 active:scale-95 transition cursor-pointer"
            >
              LAUNCH STUDIO WORKSTATION ❯
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
