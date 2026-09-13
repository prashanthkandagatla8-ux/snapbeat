"use client";

import React, { useState, useRef, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";
import RetroAdBanner from "@/components/ads/RetroAdBanner";
import { Volume2, VolumeX, Play, Pause, Square, Sparkles, Crown, Zap, Music, Image as ImageIcon, Video, ArrowRight, ShieldCheck, User } from "lucide-react";

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
            // Autoplay prevented until user interacts with the page
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
        setIsPlaying(false);
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

  return (
    <div className="w-full flex flex-col items-center py-6 px-4 sm:px-6 max-w-6xl mx-auto space-y-8 animate-fadeIn">
      {/* Top Banner / User Account Bar */}
      <div className="w-full flex items-center justify-between metal-panel px-5 py-3 rounded-2xl border-2 border-[#7a766f] shadow-md">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl metal-inset p-1 flex items-center justify-center">
            <img
              src="/assets/images/snapbeat_app_icon.png"
              alt="SnapBeat App Icon"
              className="w-full h-full object-contain rounded-lg"
            />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <img
                src="/assets/images/snapbeat_logo_crop.png"
                alt="SnapBeat Logo"
                className="h-7 sm:h-8 w-auto object-contain"
              />
              <span className="px-2 py-0.5 rounded-full bg-amber-500 text-black text-[9px] font-black uppercase tracking-widest shadow-sm">
                BETA
              </span>
            </div>
            <p className="text-[10px] text-[#5a5752] font-bold">Tactile Audio-Visual Reel Maker</p>
          </div>
        </div>

        {/* User Account Controls */}
        <div className="flex items-center gap-3">
          {user ? (
            <div className="flex items-center gap-2 sm:gap-3">
              <div className="flex items-center gap-2">
                {user.picture ? (
                  <img
                    src={user.picture}
                    alt={user.name || user.email}
                    className="w-7 h-7 rounded-full object-cover border border-amber-500 shadow-sm"
                  />
                ) : (
                  <div className="w-7 h-7 rounded-full bg-amber-500/25 text-amber-900 border border-amber-600/40 flex items-center justify-center font-black text-xs shrink-0">
                    {(user.name || user.email || "U")[0].toUpperCase()}
                  </div>
                )}
                <div className="text-right hidden sm:block">
                  <p className="text-xs font-black text-[#2b2b2d] max-w-[120px] truncate">{user.name || user.email}</p>
                  <span className={`text-[9px] font-black uppercase px-2 py-0.5 rounded-full ${
                    user.isPro ? "bg-amber-400 text-black" : "bg-black/10 text-[#4a4743]"
                  }`}>
                    {user.isPro ? "PRO SUBSCRIBER" : "FREE USER"}
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={onEnterStudio}
                className="px-3 py-1.5 rounded-xl text-xs font-black uppercase tracking-wider btn-brass text-[#2b2820] shadow flex items-center gap-1 hover:brightness-110 active:scale-95 transition"
              >
                <span>STUDIO</span>
                <ArrowRight className="w-3 h-3" />
              </button>
              <button
                type="button"
                onClick={signOut}
                className="text-[10px] font-bold text-[#5a5752] hover:text-red-700 px-2 py-1.5 rounded-lg metal-inset hover:bg-black/5 transition active:scale-95"
              >
                Sign Out
              </button>
            </div>
          ) : (
            <button
              type="button"
              onClick={openAuthModal}
              className="px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider btn-brass text-[#2b2820] shadow flex items-center gap-1.5 hover:brightness-110 transition"
            >
              <User className="w-3.5 h-3.5" />
              <span>SIGN IN</span>
            </button>
          )}
        </div>
      </div>

      {/* Main Showcase Hero Section */}
      <div className="w-full grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
        {/* Left Side: CRT Framed Showcase Video Player */}
        <div className="lg:col-span-6 flex flex-col items-center">
          <div className="relative w-full max-w-[340px] sm:max-w-[380px] metal-panel rounded-3xl p-4 sm:p-5 border-4 border-[#7a766f] shadow-2xl">
            {/* Chassis Screws */}
            <div className="metal-screw top-3 left-3 pointer-events-none" />
            <div className="metal-screw top-3 right-3 pointer-events-none" />
            <div className="metal-screw bottom-3 left-3 pointer-events-none" />
            <div className="metal-screw bottom-3 right-3 pointer-events-none" />

            {/* Top Control Bar with Play, Pause, Stop, and Mute */}
            <div className="flex items-center justify-between px-2 pb-3 mb-2 border-b border-[#7a766f]/40 gap-2 flex-wrap">
              <div className="flex items-center gap-2">
                <span className={`w-2.5 h-2.5 rounded-full shadow-md ${
                  isPlaying ? "bg-red-500 animate-pulse shadow-[0_0_8px_rgba(239,68,68,0.8)]" : "bg-amber-500"
                }`} />
                <span className="font-mono text-[10px] font-black text-[#4a4743] tracking-widest hidden sm:inline">
                  SHOWCASE REEL • 1080P
                </span>
              </div>

              <div className="flex items-center gap-1.5 ml-auto">
                {/* Play / Pause Toggle Button */}
                <button
                  type="button"
                  onClick={togglePlay}
                  className="px-2.5 py-1 rounded-lg metal-inset text-[#3b3834] hover:text-black transition flex items-center gap-1 text-[10px] font-black cursor-pointer shadow-sm active:scale-95"
                  title={isPlaying ? "Pause Sample Reel" : "Play Sample Reel"}
                  aria-label={isPlaying ? "Pause Sample Reel" : "Play Sample Reel"}
                >
                  {isPlaying ? (
                    <>
                      <Pause className="w-3.5 h-3.5 fill-current text-amber-600" />
                      <span>PAUSE</span>
                    </>
                  ) : (
                    <>
                      <Play className="w-3.5 h-3.5 fill-current text-green-700" />
                      <span>PLAY</span>
                    </>
                  )}
                </button>

                {/* Stop Button */}
                <button
                  type="button"
                  onClick={stopVideo}
                  className="px-2.5 py-1 rounded-lg metal-inset text-[#3b3834] hover:text-black transition flex items-center gap-1 text-[10px] font-black cursor-pointer shadow-sm active:scale-95"
                  title="Stop and Rewind Sample Reel"
                  aria-label="Stop Sample Reel"
                >
                  <Square className="w-3.5 h-3.5 fill-current text-[#d62828]" />
                  <span>STOP</span>
                </button>

                {/* Audio Mute/Unmute */}
                <button
                  type="button"
                  onClick={toggleSound}
                  className="px-2 py-1 rounded-lg metal-inset text-[#3b3834] hover:text-black transition flex items-center gap-1 text-[10px] font-black cursor-pointer shadow-sm active:scale-95"
                  title={isMuted ? "Click to unmute audio" : "Click to mute audio"}
                  aria-label={isMuted ? "Click to unmute audio" : "Click to mute audio"}
                >
                  {isMuted ? <VolumeX className="w-3.5 h-3.5 text-red-600" /> : <Volume2 className="w-3.5 h-3.5 text-green-700" />}
                  <span className="hidden sm:inline">{isMuted ? "UNMUTE" : "MUTE"}</span>
                </button>
              </div>
            </div>

            {/* The Video CRT Viewport */}
            <div className="relative aspect-[9/16] w-full rounded-2xl overflow-hidden bg-black border-2 border-[#2b2b2d] shadow-inner group">
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

              {/* CRT Scanline Overlay */}
              <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(ellipse_at_center,_rgba(0,0,0,0)_0%,_rgba(0,0,0,0.4)_100%)] opacity-80" />

              {/* Floating Track & Motion Badges */}
              <div className="absolute bottom-3 left-3 right-3 flex flex-col gap-1.5 pointer-events-none">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-black/75 backdrop-blur-md border border-white/20 text-white text-xs font-black shadow-lg w-max">
                  <Music className="w-3.5 h-3.5 text-amber-400" />
                  <span>Little Do You Know • 128 BPM</span>
                </div>
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-black/75 backdrop-blur-md border border-white/20 text-amber-300 text-[11px] font-bold shadow-lg w-max">
                  <Sparkles className="w-3 h-3 text-amber-400" />
                  <span>Template: Pendulum Motion & Beat Flash</span>
                </div>
              </div>

              {/* Paused State Overlay */}
              {!isPlaying && (
                <div
                  onClick={togglePlay}
                  className="absolute inset-0 flex flex-col items-center justify-center bg-black/60 backdrop-blur-[2px] transition cursor-pointer z-20 space-y-3"
                >
                  <div className="w-16 h-16 rounded-full bg-[#ffc72c] text-[#2b2820] flex items-center justify-center shadow-2xl border-2 border-white hover:scale-105 transition">
                    <Play className="w-8 h-8 fill-current ml-1" />
                  </div>
                  <span className="px-3 py-1 rounded-full bg-black/80 text-white font-mono text-xs font-bold border border-white/20 tracking-wider">
                    SAMPLE PAUSED • TAP TO RESUME
                  </span>
                </div>
              )}

              {/* Tap to Unmute Overlay for Mobile (when playing but muted) */}
              {isMuted && isPlaying && (
                <button
                  type="button"
                  onClick={toggleSound}
                  aria-label="Tap for audio"
                  className="absolute inset-0 flex items-center justify-center bg-black/25 hover:bg-black/15 transition group-hover:opacity-100 cursor-pointer"
                >
                  <div className="px-4 py-2 rounded-2xl bg-black/80 backdrop-blur-md border border-amber-400/50 text-white text-xs font-black flex items-center gap-2 shadow-2xl">
                    <Volume2 className="w-4 h-4 text-amber-400 animate-bounce" />
                    <span>TAP FOR AUDIO</span>
                  </div>
                </button>
              )}
            </div>

            {/* Bottom Deck Badge & Direct Sign In Button ON Player */}
            <div className="pt-3 mt-2 border-t border-[#7a766f]/40 space-y-2.5">
              <div className="flex items-center justify-between text-[10px] font-bold text-[#5a5752]">
                <div className="flex items-center gap-1.5">
                  <img
                    src="/assets/images/snapbeat_app_icon.png"
                    alt="SnapBeat App Icon"
                    className="w-3.5 h-3.5 rounded object-contain"
                  />
                  <span className="font-mono text-[9px] tracking-wider text-[#5a5752]">SYNCHRONIZED DECK</span>
                </div>
                <span className="font-mono text-amber-600">CHOREO V2.0</span>
              </div>

              {/* Prominent Sign In / Studio Button directly on Home Page Player */}
              {!user ? (
                <button
                  type="button"
                  onClick={openAuthModal}
                  className="w-full py-3 rounded-2xl btn-brass text-[#2b2820] font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2 shadow-lg hover:brightness-110 active:scale-95 transition cursor-pointer"
                >
                  <User className="w-4 h-4 text-[#2b2820]" />
                  <span>SIGN IN TO CREATE REEL ❯</span>
                </button>
              ) : (
                <button
                  type="button"
                  onClick={onEnterStudio}
                  className="w-full py-3 rounded-2xl btn-brass text-[#2b2820] font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2 shadow-lg hover:brightness-110 active:scale-95 transition cursor-pointer"
                >
                  <span>OPEN STUDIO WORKSTATION ❯</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Right Side: Headline, Features, and Master CTA */}
        <div className="lg:col-span-6 flex flex-col items-center lg:items-start text-center lg:text-left space-y-6">
          <div className="space-y-3">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full metal-inset text-[#3b3834] font-black text-xs">
              <Sparkles className="w-3.5 h-3.5 text-amber-500" />
              <span>CREATE VIDEOS IN JUST A FEW CLICKS</span>
            </div>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-black text-[#2b2b2d] tracking-tight uppercase leading-none">
              Beat-Synced <br className="hidden sm:inline" />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-600 via-amber-700 to-[#2b2b2d]">
                Reels from Photos
              </span>
            </h1>
            <p className="text-sm sm:text-base text-[#4a4743] font-semibold max-w-xl leading-relaxed">
              No complex timelines or manual keyframing. Drop your favorite photos, insert a cassette track, and let SnapBeat engineer a rhythmically locked video reel with dynamic zooms and momentum.
            </p>
          </div>

          {/* 3 Simple Steps */}
          <div className="w-full grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className="p-3.5 rounded-2xl metal-inset flex flex-col items-center lg:items-start text-center lg:text-left">
              <div className="w-8 h-8 rounded-xl bg-amber-500/20 flex items-center justify-center text-amber-700 mb-2">
                <Music className="w-4 h-4" />
              </div>
              <h4 className="font-black text-xs text-[#2b2b2d] uppercase">1. Pick Track</h4>
              <p className="text-[10px] font-bold text-[#5a5752] mt-0.5">9 built-in tapes or custom MP3 audio</p>
            </div>

            <div className="p-3.5 rounded-2xl metal-inset flex flex-col items-center lg:items-start text-center lg:text-left">
              <div className="w-8 h-8 rounded-xl bg-amber-500/20 flex items-center justify-center text-amber-700 mb-2">
                <ImageIcon className="w-4 h-4" />
              </div>
              <h4 className="font-black text-xs text-[#2b2b2d] uppercase">2. Add Photos</h4>
              <p className="text-[10px] font-bold text-[#5a5752] mt-0.5">1-click sample photos or upload yours</p>
            </div>

            <div className="p-3.5 rounded-2xl metal-inset flex flex-col items-center lg:items-start text-center lg:text-left">
              <div className="w-8 h-8 rounded-xl bg-amber-500/20 flex items-center justify-center text-amber-700 mb-2">
                <Video className="w-4 h-4" />
              </div>
              <h4 className="font-black text-xs text-[#2b2b2d] uppercase">3. Render Reel</h4>
              <p className="text-[10px] font-bold text-[#5a5752] mt-0.5">14 cinematic motion choreography templates</p>
            </div>
          </div>

          {/* Master Call to Action */}
          <div className="w-full pt-2 flex flex-col items-center lg:items-start gap-3">
            <div className="flex items-center gap-4">
              <RetroMechanicalButton
                variant="redMaster"
                onClick={handleAction}
                title={user ? "Enter Studio" : "Sign In to Create Reel"}
              />
              <div className="text-left">
                <button
                  type="button"
                  onClick={handleAction}
                  className="px-6 py-3.5 rounded-2xl font-black text-sm uppercase tracking-wider btn-brass text-[#2b2820] shadow-xl hover:brightness-110 active:scale-95 transition flex items-center gap-2"
                >
                  <span>{user ? "ENTER STUDIO ❯" : "SIGN IN TO CREATE REEL ❯"}</span>
                </button>
                <p className="text-[10px] font-bold text-[#6e695f] mt-1 pl-1">
                  {user ? `Signed in as ${user.email}` : "Free unlimited 720p renders • No card required"}
                </p>
              </div>
            </div>

            {/* Reassurance note requiring sign-in to enter studio */}
            {!user && (
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full metal-inset text-[11px] font-bold text-[#5a5752]">
                <ShieldCheck className="w-3.5 h-3.5 text-amber-600 shrink-0" />
                <span>1-Click Google or Email sign-in unlocks the Studio Workstation</span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Free vs Pro Feature Comparison Panel */}
      <div className="w-full metal-panel rounded-3xl p-6 sm:p-8 border-2 border-[#7a766f] shadow-lg">
        <div className="text-center space-y-1 mb-6">
          <span className="font-mono text-xs font-black text-amber-600 uppercase tracking-widest">PLANS & PASSES</span>
          <h3 className="text-2xl font-black text-[#2b2b2d] uppercase">Choose Free or Upgrade to Pro</h3>
          <p className="text-xs text-[#5a5752] font-semibold">Instant upgrades starting at just ₹99 / week</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-4xl mx-auto">
          {/* Free Tier */}
          <div className="rounded-2xl p-6 metal-inset border-2 border-[#8f8677]/60 flex flex-col justify-between space-y-4">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-lg font-black text-[#2b2b2d] uppercase">FREE TIER</span>
                <span className="px-3 py-1 rounded-full bg-black/10 text-xs font-black text-[#3b3834]">ALWAYS ₹0</span>
              </div>
              <p className="text-xs text-[#5a5752] font-semibold mt-1">Perfect for casual creators and trying out SnapBeat</p>

              <ul className="mt-4 space-y-2.5 text-xs font-bold text-[#3b3834]">
                <li className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-green-600" />
                  <span>Unlimited 720p HD Video Exports</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-green-600" />
                  <span>Shared 1-at-a-time serialized render queue</span>
                </li>
                <li className="flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-green-600" />
                  <span>All 14 motion templates included</span>
                </li>
                <li className="flex items-center gap-2 text-[#6e695f]">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#8f8677]" />
                  <span>Subtle corner watermark (removable with Pro)</span>
                </li>
              </ul>
            </div>

            <button
              type="button"
              onClick={handleAction}
              className="w-full py-3 rounded-xl metal-inset hover:bg-black/5 text-[#2b2b2d] font-black text-xs uppercase tracking-wider transition shadow-sm"
            >
              {user ? "ENTER STUDIO (FREE TIER) ❯" : "SIGN IN FOR FREE TIER ❯"}
            </button>
          </div>

          {/* Pro Passes */}
          <div className="rounded-2xl p-6 metal-panel border-2 border-amber-500 shadow-xl flex flex-col justify-between space-y-4 relative overflow-hidden">
            <div className="absolute top-0 right-0 px-4 py-1 bg-gradient-to-l from-amber-500 to-amber-600 text-black text-[10px] font-black uppercase tracking-wider rounded-bl-xl shadow">
              PRO HARDWARE PASS
            </div>

            <div>
              <div className="flex items-center gap-2">
                <Crown className="w-5 h-5 text-amber-500" />
                <img
                  src="/assets/images/snapbeat_logo_crop.png"
                  alt="SnapBeat Logo"
                  className="h-5 w-auto object-contain"
                />
                <span className="text-sm font-black text-amber-600 uppercase tracking-wider">PRO PASS</span>
              </div>

              {/* Three Distinct Pricing Badges */}
              <div className="flex flex-wrap gap-2 mt-2.5 mb-1">
                <div className="px-2.5 py-1 rounded-lg bg-amber-500/20 border border-amber-500/40 text-[11px] font-black text-[#2b2820]">
                  ₹99 <span className="font-semibold text-[10px] text-[#5a5752]">/ week</span>
                </div>
                <div className="px-2.5 py-1 rounded-lg bg-amber-500/30 border border-amber-500/60 text-[11px] font-black text-[#2b2820] shadow-sm">
                  ₹199 <span className="font-semibold text-[10px] text-[#5a5752]">/ month</span>
                </div>
                <div className="px-2.5 py-1 rounded-lg bg-amber-500/20 border border-amber-500/40 text-[11px] font-black text-[#2b2820]">
                  ₹999 <span className="font-semibold text-[10px] text-[#5a5752]">/ year</span>
                </div>
              </div>

              <ul className="mt-4 space-y-2.5 text-xs font-black text-[#2b2b2d]">
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-500 shrink-0" />
                  <span>1080p Master Crisp Full HD Quality</span>
                </li>
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-500 shrink-0" />
                  <span>No SnapBeat Watermark (Clean Export)</span>
                </li>
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-500 shrink-0" />
                  <span>Opening Title Cards with custom typography</span>
                </li>
                <li className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-amber-500 shrink-0" />
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
              className="w-full py-3 rounded-xl btn-brass text-[#2b2820] font-black text-xs uppercase tracking-wider shadow-md hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2"
            >
              <Crown className="w-3.5 h-3.5 text-amber-600" />
              <span>{user ? "UPGRADE TO PRO ❯" : "SIGN IN & UPGRADE TO PRO ❯"}</span>
            </button>
          </div>
        </div>
      </div>

      {/* TASTEFUL SPONSOR BROADCAST BANNER (HIDDEN FOR PRO USERS) */}
      <RetroAdBanner isPro={user?.isPro} onOpenPricing={onOpenPricing} />
    </div>
  );
}
