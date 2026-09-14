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
} from "lucide-react";

export default function ShowcaseHome({ onEnterStudio, onOpenPricing }) {
  const { user, openAuthModal, signOut } = useAuth();
  const [isMuted, setIsMuted] = useState(true);
  const [isPlaying, setIsPlaying] = useState(true);
  const videoRef = useRef(null);

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
    <div className="w-full flex flex-col items-center py-4 sm:py-6 px-3 sm:px-6 md:px-8 max-w-7xl mx-auto space-y-12 animate-fadeIn select-none">
      
      {/* =========================================================================
          SECTION 1: THE SIGNATURE HERO STAGE (MATCHING UI REFERENCE)
          ========================================================================= */}
      <section
        id="hero"
        className="w-full relative overflow-hidden text-white pt-2 sm:pt-4 pb-8"
      >
        {/* Subtle Ambient Lighting Flare */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-2xl h-72 bg-radial from-amber-400/20 via-emerald-400/5 to-transparent blur-3xl pointer-events-none" />

        {/* 1.1 TOP NAVIGATION BAR */}
        <header className="relative z-10 flex items-center justify-between gap-4 pb-4 border-b border-white/10">
          {/* 3D SnapBeat Logo on Left */}
          <div
            onClick={() => scrollToSection("hero")}
            className="flex items-center gap-2 cursor-pointer group"
          >
            <img
              src="/assets/images/snapbeat_logo_3d.png"
              alt="SnapBeat Logo"
              className="h-9 sm:h-11 md:h-12 w-auto object-contain drop-shadow-lg group-hover:scale-105 transition-transform"
            />
          </div>

          {/* Nav Links in Center */}
          <nav className="hidden md:flex items-center gap-7 text-sm font-semibold tracking-wide">
            <button
              type="button"
              onClick={() => scrollToSection("hero")}
              className="text-[#ffc72c] font-black border-b-2 border-[#ffc72c] pb-0.5 cursor-pointer"
            >
              Home
            </button>
            <button
              type="button"
              onClick={handleAction}
              className="text-amber-100/80 hover:text-white font-bold transition cursor-pointer"
            >
              Create
            </button>
            <button
              type="button"
              onClick={() => scrollToSection("showcase-player")}
              className="text-amber-100/80 hover:text-white font-bold transition cursor-pointer"
            >
              Explore
            </button>
            <button
              type="button"
              onClick={() => scrollToSection("pricing")}
              className="text-amber-100/80 hover:text-white font-bold transition cursor-pointer"
            >
              About
            </button>
          </nav>

          {/* User Account Button on Right */}
          <div className="flex items-center gap-3">
            {user ? (
              <div className="flex items-center gap-2 sm:gap-3">
                <div className="flex items-center gap-2">
                  {user.picture ? (
                    <img
                      src={user.picture}
                      alt={user.name || user.email}
                      className="w-8 h-8 rounded-full object-cover border-2 border-[#ffc72c] shadow"
                    />
                  ) : (
                    <div className="w-8 h-8 rounded-full bg-[#ffc72c] text-[#2b2820] font-black text-xs flex items-center justify-center shadow">
                      {(user.name || user.email || "U")[0].toUpperCase()}
                    </div>
                  )}
                  <div className="text-right hidden sm:block">
                    <p className="text-xs font-bold text-white max-w-[120px] truncate">{user.name || user.email}</p>
                    <span className="text-[9px] font-black uppercase text-amber-300">
                      {user.isPro ? "PRO PASS" : "FREE TIER"}
                    </span>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={onEnterStudio}
                  className="px-3 py-1.5 rounded-xl bg-amber-400 text-[#2b2820] font-black text-xs hover:brightness-110 active:scale-95 transition flex items-center gap-1 shadow-sm cursor-pointer"
                >
                  <span>STUDIO</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            ) : (
              <button
                type="button"
                onClick={openAuthModal}
                className="px-4 sm:px-5 py-2 rounded-full bg-gradient-to-r from-[#ffc72c] via-[#ffb800] to-[#f59e0b] text-[#2b2820] font-black text-xs sm:text-sm tracking-wide shadow-[0_4px_15px_rgba(255,199,44,0.4)] hover:brightness-105 active:scale-95 transition flex items-center gap-1.5 cursor-pointer border border-[#fff2b2]"
              >
                <User className="w-4 h-4 fill-current text-[#2b2820]" />
                <span>Sign In</span>
              </button>
            )}
          </div>
        </header>

        {/* 1.2 HERO CONTENT (3D TITLE + SCRIPT TAGLINE + START CREATING CTA) */}
        <div className="relative z-10 flex flex-col items-center text-center mt-6 sm:mt-8 space-y-4">
          {/* Big 3D Logo Header */}
          <div className="relative inline-block hover:scale-[1.02] transition-transform duration-300">
            <img
              src="/assets/images/snapbeat_logo_3d.png"
              alt="SnapBeat 3D Title"
              className="h-20 sm:h-28 md:h-36 w-auto object-contain drop-shadow-[0_15px_30px_rgba(0,0,0,0.7)]"
            />
          </div>

          {/* Script Tagline (From UI Reference) */}
          <h2 className="font-script text-2xl sm:text-3xl md:text-4xl text-[#fffae8] font-bold tracking-wide drop-shadow-md">
            Not just a video... It's your story in motion.
          </h2>

          {/* "Start Creating" Golden Radiate CTA Button */}
          <div className="flex items-center justify-center gap-3 pt-2">
            <span className="text-amber-300 font-mono text-base tracking-widest hidden sm:inline select-none">
              \ \
            </span>
            <button
              type="button"
              onClick={handleAction}
              className="px-8 sm:px-10 py-3.5 sm:py-4 rounded-full bg-gradient-to-r from-[#ffc72c] via-[#ffb800] to-[#f59e0b] text-[#2b2820] font-black text-base sm:text-lg tracking-wide shadow-[0_10px_35px_rgba(245,158,11,0.55)] hover:brightness-105 hover:scale-105 active:scale-95 transition-all flex items-center gap-2.5 border border-[#fff0a6] cursor-pointer"
            >
              <Play className="w-5 h-5 fill-current ml-0.5" />
              <span>Start Creating</span>
            </button>
            <span className="text-amber-300 font-mono text-base tracking-widest hidden sm:inline select-none">
              / /
            </span>
          </div>

          {/* 1.3 CENTERPIECE ARTWORK: VINTAGE CAMERA & 35MM FILM STRIP */}
          <div className="relative w-full max-w-2xl mx-auto pt-4 group">
            <div className="relative overflow-hidden rounded-3xl shadow-[0_20px_50px_rgba(0,0,0,0.6)] border border-white/15">
              <img
                src="/assets/images/snapbeat_camera_filmstrip.png"
                alt="SnapBeat Camera with 35mm Filmstrip"
                className="w-full h-auto object-contain rounded-3xl transition-transform duration-500 group-hover:scale-[1.02]"
              />

              {/* Interactive Play Overlay right on the Camera Screen */}
              <button
                type="button"
                onClick={() => scrollToSection("showcase-player")}
                className="absolute inset-0 flex items-center justify-center bg-black/10 hover:bg-black/25 transition cursor-pointer"
                title="Watch Sample Reel in Player"
                aria-label="Watch Sample Reel"
              >
                <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-full bg-[#ffc72c]/90 text-[#2b2820] flex items-center justify-center shadow-[0_0_35px_rgba(255,199,44,0.9)] border-2 border-white/80 group-hover:scale-110 transition duration-300">
                  <Play className="w-8 h-8 fill-current ml-1" />
                </div>
              </button>
            </div>
            <p className="text-[11px] text-amber-200/70 font-mono text-center mt-2 tracking-wide">
              ▲ TAP CAMERA SCREEN TO PREVIEW AUDIO-VISUAL REEL ▲
            </p>
          </div>

          {/* 1.4 BOTTOM 4 FEATURE CARDS (NEON DOCK FROM UI REFERENCE) */}
          <div className="w-full grid grid-cols-2 lg:grid-cols-4 gap-3.5 p-4 sm:p-5 bg-black/45 backdrop-blur-md rounded-3xl border border-white/10 shadow-inner mt-6">
            {/* Feature 1 */}
            <div className="flex flex-col items-center text-center p-3 rounded-2xl hover:bg-white/5 transition">
              <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center mb-2 shadow-sm">
                <Video className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider">Create Videos</h4>
              <p className="text-[11px] text-amber-100/70 mt-0.5">Beat-synced reels from photos in seconds</p>
            </div>

            {/* Feature 2 */}
            <div className="flex flex-col items-center text-center p-3 rounded-2xl hover:bg-white/5 transition">
              <div className="w-10 h-10 rounded-xl bg-pink-500/20 text-pink-400 flex items-center justify-center mb-2 shadow-sm">
                <Sparkles className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider">AI Powered</h4>
              <p className="text-[11px] text-amber-100/70 mt-0.5">Automated audio beat & onset detection</p>
            </div>

            {/* Feature 3 */}
            <div className="flex flex-col items-center text-center p-3 rounded-2xl hover:bg-white/5 transition">
              <div className="w-10 h-10 rounded-xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center mb-2 shadow-sm">
                <Film className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider">Stunning Templates</h4>
              <p className="text-[11px] text-amber-100/70 mt-0.5">14 cinematic motion choreography presets</p>
            </div>

            {/* Feature 4 */}
            <div className="flex flex-col items-center text-center p-3 rounded-2xl hover:bg-white/5 transition">
              <div className="w-10 h-10 rounded-xl bg-sky-500/20 text-sky-400 flex items-center justify-center mb-2 shadow-sm">
                <Share2 className="w-5 h-5" />
              </div>
              <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider">Easy Sharing</h4>
              <p className="text-[11px] text-amber-100/70 mt-0.5">Instant MP4 export for Reels, Shorts & Status</p>
            </div>
          </div>
        </div>
      </section>

      {/* =========================================================================
          SECTION 2: INTERACTIVE SHOWCASE REEL PLAYER (CRT CHASSIS)
          ========================================================================= */}
      <section
        id="showcase-player"
        className="w-full sky-glass-panel rounded-3xl p-6 sm:p-8 shadow-2xl"
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
                    <span>Pendulum Motion &amp; Beat Flash</span>
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
        className="w-full sky-glass-panel rounded-3xl p-6 sm:p-8 shadow-2xl"
      >
        <div className="text-center space-y-1 mb-6">
          <span className="font-mono text-xs font-black text-amber-400 uppercase tracking-widest">
            PLANS &amp; PASSES
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
      <section className="w-full sky-glass-card rounded-3xl p-6 sm:p-8 shadow-2xl flex flex-col sm:flex-row items-center justify-between gap-6">
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
    </div>
  );
}
