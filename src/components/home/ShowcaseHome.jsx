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

  const scrollToSection = (id) => {
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  };

  return (
    <div className="w-full flex flex-col items-center py-2 px-1 sm:px-2 max-w-[857px] mx-auto select-none">
      
      {/* =========================================================================
          FIRST PAGE: SIGNATURE TABLET WITH AUTHENTIC METAL EDGE FRAME ONLY
          ========================================================================= */}
      <section
        id="hero"
        className="w-full relative rounded-[38px] sm:rounded-[44px] overflow-hidden shadow-[0_30px_90px_rgba(0,0,0,0.95)] select-none group"
      >
        {/* Full-Bleed Reference Artwork Canvas with Native Metal Edge Frame */}
        <div className="relative w-full aspect-[857/1324] overflow-hidden rounded-[38px] sm:rounded-[44px]">
          <img
            src="/assets/images/snapbeat_tablet_homescreen.png"
            alt="SnapBeat Studio Tablet Home Screen"
            className="w-full h-full object-cover select-none pointer-events-none rounded-[38px] sm:rounded-[44px]"
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
              onClick={onEnterStudio}
              className="px-2 py-1 text-xs sm:text-sm font-black text-transparent hover:text-amber-200 transition-colors cursor-pointer rounded-lg hover:bg-black/20"
              title="Create Video Reel (Enter Studio)"
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
              INTERACTIVE OVERLAY 2: RADIANT "START CREATING" BUTTON -> ENTERS STUDIO SCREENS
              ------------------------------------------------------------- */}
          <button
            type="button"
            onClick={onEnterStudio}
            aria-label="Start Creating Videos"
            title="Start Creating - Open Studio Screens"
            className="absolute top-[36.2%] left-[33.2%] w-[33.6%] h-[4.8%] rounded-full cursor-pointer z-20 group/btn flex items-center justify-center transition-all duration-300 hover:scale-[1.04] active:scale-95 shadow-[0_0_20px_rgba(255,199,44,0.4)] hover:shadow-[0_0_40px_rgba(255,199,44,0.9)]"
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
              onClick={onEnterStudio}
              onMouseEnter={() => setActiveTooltip("Click to enter studio and create beat-synced reels")}
              onMouseLeave={() => setActiveTooltip(null)}
              className="w-full h-full rounded-2xl cursor-pointer hover:bg-amber-400/10 active:scale-95 transition-all flex flex-col items-center justify-end pb-1 sm:pb-2 border border-transparent hover:border-amber-400/30"
              title="Create Videos"
            >
              <span className="sr-only">Create Videos</span>
            </button>

            {/* 4.2 AI Powered */}
            <button
              type="button"
              onClick={onEnterStudio}
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
    </div>
  );
}
