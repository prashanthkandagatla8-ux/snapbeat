"use client";

import React, { useState, useRef, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";
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
  Image as ImageIcon,
  Video,
  ArrowRight,
  ShieldCheck,
  User,
  Film,
  Share2,
  Download,
  ExternalLink,
  X,
} from "lucide-react";

export default function ShowcaseHome({ onEnterStudio, onOpenPricing }) {
  const { user, openAuthModal, signOut } = useAuth();
  const [isMuted, setIsMuted] = useState(true);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isReelModalOpen, setIsReelModalOpen] = useState(false);
  const [modalMuted, setModalMuted] = useState(false);
  const [activeTooltip, setActiveTooltip] = useState(null);
  const videoRef = useRef(null);
  const modalVideoRef = useRef(null);

  // Initialize video autoplay safely across all browser policies
  useEffect(() => {
    if (videoRef.current) {
      videoRef.current.defaultMuted = true;
      videoRef.current.muted = true;
      const playPromise = videoRef.current.play();
      if (playPromise !== undefined) {
        playPromise
          .then(() => setIsPlaying(true))
          .catch(() => {
            setIsPlaying(false);
          });
      }
    }
  }, []);

  const toggleSound = () => {
    if (videoRef.current) {
      const nextMuted = !videoRef.current.muted;
      videoRef.current.muted = nextMuted;
      setIsMuted(nextMuted);
      if (!nextMuted) {
        videoRef.current.play().then(() => setIsPlaying(true)).catch(() => {});
      }
    }
  };

  const togglePlay = () => {
    if (videoRef.current) {
      if (videoRef.current.paused) {
        videoRef.current.play().then(() => setIsPlaying(true)).catch(() => {});
      } else {
        videoRef.current.pause();
      }
    }
  };

  const stopVideo = () => {
    if (videoRef.current) {
      videoRef.current.pause();
      videoRef.current.currentTime = 0;
      setIsPlaying(false);
    }
  };

  const handleAction = () => {
    if (!user) {
      openAuthModal();
    } else {
      onEnterStudio();
    }
  };

  const scrollToSection = (id) => {
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  };

  return (
    <div className="w-full flex flex-col items-center py-2 sm:py-4 px-2 sm:px-4 max-w-7xl mx-auto space-y-10 animate-fadeIn select-none">
      
      {/* =========================================================================
          SECTION 1: THE SIGNATURE TABLET HOME SCREEN (1:1 UI REFERENCE)
          ========================================================================= */}
      <section
        id="hero"
        className="w-full relative max-w-[857px] mx-auto rounded-[36px] sm:rounded-[44px] overflow-hidden shadow-2xl group"
      >
        {/* Full-Bleed Reference Artwork Canvas */}
        <div className="relative w-full aspect-[857/1324] overflow-hidden">
          <img
            src="/assets/images/snapbeat_tablet_homescreen.png"
            alt="SnapBeat Studio Tablet Home Screen"
            className="w-full h-full object-cover select-none pointer-events-none"
          />

          {/* -------------------------------------------------------------
              INTERACTIVE OVERLAY 1: TOP NAVIGATION BAR
              ------------------------------------------------------------- */}
          {/* 1.1 Left Logo Hotspot */}
          <button
            type="button"
            onClick={() => scrollToSection("hero")}
            title="SnapBeat Home"
            aria-label="SnapBeat Home"
            className="absolute top-[2.2%] left-[4.5%] w-[20%] h-[5%] rounded-xl cursor-pointer hover:bg-white/10 transition-colors z-20"
          />

          {/* 1.2 Center Nav Links Hotspot */}
          <div className="absolute top-[2.2%] left-[34%] w-[42%] h-[5%] flex items-center justify-center gap-3 sm:gap-5 z-20">
            <button
              type="button"
              onClick={() => scrollToSection("hero")}
              className="px-2 py-1 text-xs sm:text-sm font-black text-transparent hover:text-amber-200 transition-colors cursor-pointer rounded-lg hover:bg-black/20"
              title="Home"
            >
              <span className="sr-only">Home</span>
            </button>
            <button
              type="button"
              onClick={handleAction}
              className="px-2 py-1 text-xs sm:text-sm font-black text-transparent hover:text-amber-200 transition-colors cursor-pointer rounded-lg hover:bg-black/20"
              title="Create Video Reel"
            >
              <span className="sr-only">Create</span>
            </button>
            <button
              type="button"
              onClick={() => setIsReelModalOpen(true)}
              className="px-2 py-1 text-xs sm:text-sm font-black text-transparent hover:text-amber-200 transition-colors cursor-pointer rounded-lg hover:bg-black/20"
              title="Explore Sample Reels"
            >
              <span className="sr-only">Explore</span>
            </button>
            <button
              type="button"
              onClick={() => scrollToSection("pricing")}
              className="px-2 py-1 text-xs sm:text-sm font-black text-transparent hover:text-amber-200 transition-colors cursor-pointer rounded-lg hover:bg-black/20"
              title="About & Pricing"
            >
              <span className="sr-only">About</span>
            </button>
          </div>

          {/* 1.3 Right Sign In / User Profile Hotspot */}
          <div className="absolute top-[2.2%] right-[4%] z-20 flex items-center">
            {user ? (
              <div className="flex items-center gap-1.5 bg-[#2b2820]/90 backdrop-blur-md px-2 sm:px-3 py-1 rounded-full border border-[#ffc72c] shadow-lg">
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
                className="w-[96px] sm:w-[110px] md:w-[124px] h-[30px] sm:h-[36px] md:h-[40px] rounded-full hover:bg-amber-400/20 active:scale-95 transition-all cursor-pointer flex items-center justify-center border border-transparent hover:border-[#fffae8]/50 shadow-sm"
                title="Sign In to SnapBeat"
                aria-label="Sign In"
              >
                <span className="sr-only">Sign In</span>
              </button>
            )}
          </div>

          {/* -------------------------------------------------------------
              INTERACTIVE OVERLAY 2: RADIANT "START CREATING" CTA BUTTON
              ------------------------------------------------------------- */}
          <button
            type="button"
            onClick={handleAction}
            aria-label="Start Creating Videos"
            title="Start Creating Beat-Synced Reel"
            className="absolute top-[36.2%] left-[33.2%] w-[33.6%] h-[4.8%] rounded-full cursor-pointer z-20 group/btn flex items-center justify-center transition-all duration-300 hover:scale-[1.03] active:scale-95 shadow-[0_0_20px_rgba(255,199,44,0.3)] hover:shadow-[0_0_35px_rgba(255,199,44,0.8)]"
          >
            {/* Ambient hover glow halo */}
            <span className="absolute inset-0 rounded-full bg-gradient-to-r from-amber-400/0 via-amber-300/30 to-amber-400/0 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-300 pointer-events-none" />
            <span className="sr-only">Start Creating</span>
          </button>

          {/* -------------------------------------------------------------
              INTERACTIVE OVERLAY 3: CAMERA SCREEN INTERACTIVE PLAY BUTTON
              ------------------------------------------------------------- */}
          <button
            type="button"
            onClick={() => setIsReelModalOpen(true)}
            aria-label="Play Sample Reel on Camera Screen"
            title="Tap to Play Beat-Synced Reel Sample"
            className="absolute top-[57.5%] left-[44.5%] w-[11%] h-[7.2%] rounded-full cursor-pointer z-20 flex items-center justify-center group/cam transition-transform duration-300 hover:scale-115 active:scale-90"
          >
            {/* Glowing lens pulse ring on hover */}
            <span className="absolute inset-0 rounded-full bg-amber-400/30 animate-ping opacity-0 group-hover/cam:opacity-100 transition-opacity pointer-events-none" />
            <span className="sr-only">Play Sample Reel</span>
          </button>

          {/* -------------------------------------------------------------
              INTERACTIVE OVERLAY 4: BOTTOM 4 NEON DOCK HOTSPOTS
              ------------------------------------------------------------- */}
          <div className="absolute bottom-[2.5%] left-[3%] right-[3%] h-[10.5%] grid grid-cols-4 gap-1 sm:gap-2 z-20">
            {/* 4.1 Create Videos */}
            <button
              type="button"
              onClick={handleAction}
              onMouseEnter={() => setActiveTooltip("Create beat-synced reels from your photos in seconds")}
              onMouseLeave={() => setActiveTooltip(null)}
              className="w-full h-full rounded-2xl cursor-pointer hover:bg-amber-400/10 active:scale-95 transition-all flex flex-col items-center justify-end pb-1 sm:pb-2 border border-transparent hover:border-amber-400/30"
              title="Create Videos"
            >
              <span className="sr-only">Create Videos</span>
            </button>

            {/* 4.2 AI Powered */}
            <button
              type="button"
              onClick={handleAction}
              onMouseEnter={() => setActiveTooltip("Automated beat and onset rhythm detection algorithm")}
              onMouseLeave={() => setActiveTooltip(null)}
              className="w-full h-full rounded-2xl cursor-pointer hover:bg-pink-400/10 active:scale-95 transition-all flex flex-col items-center justify-end pb-1 sm:pb-2 border border-transparent hover:border-pink-400/30"
              title="AI Powered"
            >
              <span className="sr-only">AI Powered</span>
            </button>

            {/* 4.3 Stunning Templates */}
            <button
              type="button"
              onClick={() => scrollToSection("showcase-player")}
              onMouseEnter={() => setActiveTooltip("14 cinematic camera motion choreography presets")}
              onMouseLeave={() => setActiveTooltip(null)}
              className="w-full h-full rounded-2xl cursor-pointer hover:bg-emerald-400/10 active:scale-95 transition-all flex flex-col items-center justify-end pb-1 sm:pb-2 border border-transparent hover:border-emerald-400/30"
              title="Stunning Templates"
            >
              <span className="sr-only">Stunning Templates</span>
            </button>

            {/* 4.4 Easy Sharing */}
            <button
              type="button"
              onClick={() => scrollToSection("showcase-player")}
              onMouseEnter={() => setActiveTooltip("Direct export to MP4 ready for Reels, Shorts, and Status")}
              onMouseLeave={() => setActiveTooltip(null)}
              className="w-full h-full rounded-2xl cursor-pointer hover:bg-sky-400/10 active:scale-95 transition-all flex flex-col items-center justify-end pb-1 sm:pb-2 border border-transparent hover:border-sky-400/30"
              title="Easy Sharing"
            >
              <span className="sr-only">Easy Sharing</span>
            </button>
          </div>

          {/* Floating Neon Tooltip Badge */}
          {activeTooltip && (
            <div className="absolute bottom-[13.5%] left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-black/85 border border-[#ffc72c]/70 text-amber-200 text-[11px] font-bold shadow-2xl pointer-events-none animate-fadeIn z-30">
              {activeTooltip}
            </div>
          )}
        </div>
      </section>

      {/* =========================================================================
          SECTION 2: INTERACTIVE SHOWCASE REEL PLAYER (CRT CHASSIS)
          ========================================================================= */}
      <section
        id="showcase-player"
        className="w-full sky-glass-panel rounded-3xl p-5 sm:p-7 md:p-8 shadow-2xl"
      >
        <div className="flex flex-col lg:flex-row items-center gap-8">
          {/* Left: The CRT Framed Video Player */}
          <div className="w-full lg:w-1/2 flex flex-col items-center">
            <div className="relative w-full max-w-[340px] sm:max-w-[380px] bg-[#07171c]/90 rounded-3xl p-4 sm:p-5 border-2 border-[#d4af37]/40 shadow-2xl">
              {/* Player Top Controls */}
              <div className="flex items-center justify-between px-2 pb-3 mb-2 border-b border-white/10 gap-2 flex-wrap">
                <div className="flex items-center gap-2">
                  <span
                    className={`w-2.5 h-2.5 rounded-full shadow-md ${
                      isPlaying
                        ? "bg-red-500 animate-pulse shadow-[0_0_8px_rgba(239,68,68,0.8)]"
                        : "bg-amber-500"
                    }`}
                  />
                  <span className="font-mono text-[10px] font-black text-amber-300 tracking-widest">
                    SAMPLE REEL • 1080P
                  </span>
                </div>

                <div className="flex items-center gap-1.5 ml-auto">
                  <button
                    type="button"
                    onClick={togglePlay}
                    className="px-2.5 py-1 rounded-lg bg-black/40 border border-white/10 text-white hover:bg-white/10 transition flex items-center gap-1 text-[10px] font-black cursor-pointer shadow-sm active:scale-95"
                  >
                    {isPlaying ? (
                      <>
                        <Pause className="w-3.5 h-3.5 fill-current text-amber-400" />
                        <span>PAUSE</span>
                      </>
                    ) : (
                      <>
                        <Play className="w-3.5 h-3.5 fill-current text-emerald-400" />
                        <span>PLAY</span>
                      </>
                    )}
                  </button>

                  <button
                    type="button"
                    onClick={stopVideo}
                    className="px-2.5 py-1 rounded-lg bg-black/40 border border-white/10 text-white hover:bg-white/10 transition flex items-center gap-1 text-[10px] font-black cursor-pointer shadow-sm active:scale-95"
                  >
                    <Square className="w-3.5 h-3.5 fill-current text-red-400" />
                    <span>STOP</span>
                  </button>

                  <button
                    type="button"
                    onClick={toggleSound}
                    className="px-2 py-1 rounded-lg bg-black/40 border border-white/10 text-white hover:bg-white/10 transition flex items-center gap-1 text-[10px] font-black cursor-pointer shadow-sm active:scale-95"
                  >
                    {isMuted ? <VolumeX className="w-3.5 h-3.5 text-red-400" /> : <Volume2 className="w-3.5 h-3.5 text-emerald-400" />}
                    <span className="hidden sm:inline">{isMuted ? "UNMUTE" : "MUTE"}</span>
                  </button>
                </div>
              </div>

              {/* Viewport */}
              <div className="relative aspect-[9/16] w-full rounded-2xl overflow-hidden bg-black border-2 border-white/15 shadow-inner group">
                <video
                  ref={videoRef}
                  src="/assets/videos/showcase_reel.mp4"
                  poster="/assets/images/splash_poster.webp"
                  autoPlay
                  loop
                  muted
                  playsInline
                  onPlay={() => setIsPlaying(true)}
                  onPause={() => setIsPlaying(false)}
                  className="w-full h-full object-cover"
                />

                {/* CRT Scanline */}
                <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(ellipse_at_center,_rgba(0,0,0,0)_0%,_rgba(0,0,0,0.4)_100%)] opacity-80" />

                {/* Floating Track Badge */}
                <div className="absolute bottom-3 left-3 right-3 flex flex-col gap-1.5 pointer-events-none">
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-black/80 backdrop-blur-md border border-white/20 text-white text-xs font-black shadow-lg w-max">
                    <Music className="w-3.5 h-3.5 text-amber-400" />
                    <span>Little Do You Know • 128 BPM</span>
                  </div>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-black/80 backdrop-blur-md border border-white/20 text-amber-300 text-[11px] font-bold shadow-lg w-max">
                    <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                    <span>Pendulum Motion & Beat Flash</span>
                  </div>
                </div>

                {/* Paused Overlay */}
                {!isPlaying && (
                  <div
                    onClick={togglePlay}
                    className="absolute inset-0 flex flex-col items-center justify-center bg-black/60 backdrop-blur-[2px] transition cursor-pointer z-20 space-y-3"
                  >
                    <div className="w-16 h-16 rounded-full bg-[#ffc72c] text-[#2b2820] flex items-center justify-center shadow-2xl border-2 border-white hover:scale-105 transition">
                      <Play className="w-8 h-8 fill-current ml-1" />
                    </div>
                    <span className="px-3 py-1 rounded-full bg-black/80 text-white font-mono text-xs font-bold border border-white/20 tracking-wider">
                      SAMPLE PAUSED • TAP TO PLAY
                    </span>
                  </div>
                )}

                {/* Mobile Unmute Overlay */}
                {isMuted && isPlaying && (
                  <button
                    type="button"
                    onClick={toggleSound}
                    className="absolute inset-0 flex items-center justify-center bg-black/25 hover:bg-black/15 transition cursor-pointer"
                  >
                    <div className="px-4 py-2 rounded-2xl bg-black/80 backdrop-blur-md border border-amber-400/50 text-white text-xs font-black flex items-center gap-2 shadow-2xl">
                      <Volume2 className="w-4 h-4 text-amber-400 animate-bounce" />
                      <span>TAP FOR AUDIO</span>
                    </div>
                  </button>
                )}
              </div>
            </div>
          </div>

          {/* Right: Pitch & Direct Studio Launcher */}
          <div className="w-full lg:w-1/2 flex flex-col items-center lg:items-start text-center lg:text-left space-y-6">
            <div className="space-y-2">
              <span className="font-mono text-xs font-black text-amber-400 uppercase tracking-widest">
                AUTOMATED CHOREOGRAPHY
              </span>
              <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight uppercase leading-none">
                Turn Still Photos Into High-Impact Reels
              </h2>
              <p className="text-sm sm:text-base text-amber-100/80 font-semibold leading-relaxed">
                No complex timelines or manual keyframing. Insert a music tape, drop your favorite photos, and let SnapBeat engineer a rhythmically locked video with camera sweeps, zooms, and drop flashes.
              </p>
            </div>

            {/* 3 Steps */}
            <div className="w-full grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="p-3.5 rounded-2xl sky-glass-inset text-left">
                <Music className="w-5 h-5 text-amber-400 mb-1" />
                <h4 className="font-black text-xs text-white uppercase">1. Pick Track</h4>
                <p className="text-[10px] text-amber-100/70 mt-0.5">9 built-in tapes or custom MP3</p>
              </div>
              <div className="p-3.5 rounded-2xl sky-glass-inset text-left">
                <ImageIcon className="w-5 h-5 text-amber-400 mb-1" />
                <h4 className="font-black text-xs text-white uppercase">2. Add Photos</h4>
                <p className="text-[10px] text-amber-100/70 mt-0.5">Sample photos or your gallery</p>
              </div>
              <div className="p-3.5 rounded-2xl sky-glass-inset text-left">
                <Video className="w-5 h-5 text-amber-400 mb-1" />
                <h4 className="font-black text-xs text-white uppercase">3. Render Reel</h4>
                <p className="text-[10px] text-amber-100/70 mt-0.5">14 cinematic motion templates</p>
              </div>
            </div>

            {/* Master Button CTA */}
            <div className="flex items-center gap-4 pt-2">
              <RetroMechanicalButton
                variant="redMaster"
                onClick={handleAction}
                title={user ? "Enter Studio" : "Sign In to Create Reel"}
              />
              <div>
                <button
                  type="button"
                  onClick={handleAction}
                  className="px-6 py-3.5 rounded-2xl font-black text-sm uppercase tracking-wider btn-brass text-[#261b02] shadow-xl hover:brightness-110 active:scale-95 transition flex items-center gap-2 cursor-pointer"
                >
                  <span>{user ? "ENTER STUDIO ❯" : "SIGN IN TO CREATE REEL ❯"}</span>
                </button>
                <p className="text-[10px] font-bold text-amber-200/70 mt-1">
                  Free unlimited 720p renders • No card required
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* =========================================================================
          SECTION 3: FREE VS PRO PRICING COMPARISON
          ========================================================================= */}
      <section
        id="pricing"
        className="w-full sky-glass-panel rounded-3xl p-5 sm:p-7 md:p-8 shadow-2xl"
      >
        <div className="text-center space-y-1 mb-6">
          <span className="font-mono text-xs font-black text-amber-400 uppercase tracking-widest">
            PLANS & PASSES
          </span>
          <h3 className="text-2xl font-black text-white uppercase">Choose Free or Upgrade to Pro</h3>
          <p className="text-xs text-amber-100/70 font-semibold">Instant upgrades starting at just ₹99 / week</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-4xl mx-auto">
          {/* Free Tier */}
          <div className="rounded-2xl p-6 sky-glass-inset border border-white/10 flex flex-col justify-between space-y-4">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-lg font-black text-white uppercase">FREE TIER</span>
                <span className="px-3 py-1 rounded-full bg-white/10 text-xs font-black text-amber-300">
                  ALWAYS ₹0
                </span>
              </div>
              <p className="text-xs text-amber-100/70 font-semibold mt-1">
                Perfect for casual creators and trying out SnapBeat
              </p>

              <ul className="mt-4 space-y-2.5 text-xs font-bold text-white/90">
                <li className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                  <span>Unlimited 720p HD Video Exports</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                  <span>Shared 1-at-a-time serialized render queue</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                  <span>All 14 motion choreography templates included</span>
                </li>
                <li className="flex items-center gap-2 text-white/50">
                  <span className="w-1.5 h-1.5 rounded-full bg-white/30" />
                  <span>Subtle corner watermark (removable with Pro)</span>
                </li>
              </ul>
            </div>

            <button
              type="button"
              onClick={handleAction}
              className="w-full py-3 rounded-xl bg-white/10 hover:bg-white/20 text-white font-black text-xs uppercase tracking-wider transition shadow-sm cursor-pointer border border-white/10"
            >
              {user ? "ENTER STUDIO (FREE TIER) ❯" : "SIGN IN FOR FREE TIER ❯"}
            </button>
          </div>

          {/* Pro Pass */}
          <div className="rounded-2xl p-6 bg-gradient-to-b from-[#0f343e]/90 to-[#091f26]/95 border-2 border-amber-400 shadow-[0_10px_35px_rgba(255,199,44,0.3)] flex flex-col justify-between space-y-4 relative overflow-hidden">
            <div className="absolute top-0 right-0 px-4 py-1 bg-gradient-to-l from-amber-400 to-amber-500 text-black text-[10px] font-black uppercase tracking-wider rounded-bl-xl shadow">
              PRO STUDIO PASS
            </div>

            <div>
              <div className="flex items-center gap-2">
                <Crown className="w-5 h-5 text-amber-400" />
                <img
                  src="/assets/images/snapbeat_logo_3d.png"
                  alt="SnapBeat"
                  className="h-5 w-auto object-contain"
                />
                <span className="text-sm font-black text-amber-400 uppercase tracking-wider">PRO PASS</span>
              </div>

              <div className="flex flex-wrap gap-2 mt-2.5 mb-1">
                <div className="px-2.5 py-1 rounded-lg bg-amber-500/20 border border-amber-400/40 text-[11px] font-black text-amber-200">
                  ₹99 <span className="font-semibold text-[10px] text-amber-300/70">/ week</span>
                </div>
                <div className="px-2.5 py-1 rounded-lg bg-amber-400/30 border border-amber-400/70 text-[11px] font-black text-amber-200 shadow-sm">
                  ₹199 <span className="font-semibold text-[10px] text-amber-300/70">/ month</span>
                </div>
                <div className="px-2.5 py-1 rounded-lg bg-amber-500/20 border border-amber-400/40 text-[11px] font-black text-amber-200">
                  ₹999 <span className="font-semibold text-[10px] text-amber-300/70">/ year</span>
                </div>
              </div>

              <ul className="mt-4 space-y-2.5 text-xs font-black text-white">
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>1080p Master Crisp Full HD Quality</span>
                </li>
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>No SnapBeat Watermark (Clean Export)</span>
                </li>
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>Opening Title Cards with custom typography</span>
                </li>
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>Priority Render Processing</span>
                </li>
              </ul>
            </div>

            <button
              type="button"
              onClick={() => {
                if (!user) {
                  openAuthModal();
                } else if (onOpenPricing) {
                  onOpenPricing();
                } else {
                  onEnterStudio();
                }
              }}
              className="w-full py-3 rounded-xl btn-brass text-[#261b02] font-black text-xs uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <Crown className="w-3.5 h-3.5 text-amber-700" />
              <span>{user ? "UPGRADE TO PRO ❯" : "SIGN IN & UPGRADE TO PRO ❯"}</span>
            </button>
          </div>
        </div>
      </section>

      {/* =========================================================================
          SECTION 4: ANDROID CLOSED BETA ACCESS & TESTER TUTORIAL
          ========================================================================= */}
      <section className="w-full sky-glass-card rounded-3xl p-5 sm:p-7 shadow-2xl flex flex-col sm:flex-row items-center justify-between gap-6">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 rounded-2xl bg-black/40 border border-[#d4af37]/30 p-1.5 flex items-center justify-center shrink-0 shadow-inner">
            <img
              src="/assets/images/snapbeat_app_icon.png"
              alt="SnapBeat Icon"
              className="w-full h-full object-contain rounded-xl"
            />
          </div>
          <div>
            <span className="px-2 py-0.5 rounded-full bg-amber-400 text-black text-[9px] font-black uppercase tracking-wider">
              GOOGLE PLAY TESTING
            </span>
            <h3 className="text-xl font-black text-white uppercase mt-1">Get SnapBeat on Android</h3>
            <p className="text-xs text-amber-100/70 font-semibold mt-0.5">
              Join our closed tester community to install early builds directly from Google Play.
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
          <a
            href="/join"
            target="_blank"
            rel="noopener noreferrer"
            className="flex-1 sm:flex-initial px-5 py-3 rounded-2xl bg-white/10 hover:bg-white/20 font-black text-xs text-white border border-white/15 backdrop-blur-md flex items-center justify-center gap-2 transition active:scale-95 shadow-sm"
          >
            <span>1. JOIN GROUP</span>
            <ExternalLink className="w-3.5 h-3.5 text-amber-400" />
          </a>
          <a
            href="/beta"
            target="_blank"
            rel="noopener noreferrer"
            className="flex-1 sm:flex-initial px-5 py-3 rounded-2xl btn-brass font-black text-xs text-[#261b02] flex items-center justify-center gap-2 shadow-md hover:brightness-105 transition active:scale-95"
          >
            <span>2. INSTALL APP</span>
            <Download className="w-3.5 h-3.5" />
          </a>
        </div>
      </section>

      {/* SPONSOR BROADCAST BANNER (HIDDEN FOR PRO SUBSCRIBERS) */}
      <RetroAdBanner isPro={user?.isPro} onOpenPricing={onOpenPricing} />

      {/* =========================================================================
          SHOWCASE REEL VIDEO MODAL (TRIGGERED BY "EXPLORE" OR CAMERA SCREEN)
          ========================================================================= */}
      {isReelModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-3 sm:p-6 animate-fadeIn">
          <div className="relative w-full max-w-[440px] bg-[#07171c] rounded-3xl border-2 border-[#d4af37] shadow-[0_25px_80px_rgba(0,0,0,0.95)] p-4 sm:p-5 flex flex-col items-center space-y-4">
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

            {/* Modal Action CTA */}
            <button
              type="button"
              onClick={() => {
                setIsReelModalOpen(false);
                handleAction();
              }}
              className="w-full py-3.5 rounded-2xl btn-brass text-[#261b02] font-black text-sm uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <span>CREATE YOUR OWN REEL NOW ❯</span>
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
