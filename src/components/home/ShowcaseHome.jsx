"use client";

import React, { useState, useRef } from "react";
import { useAuth } from "@/context/AuthContext";
import { PRICING_PLANS, TEMPLATES } from "@/lib/constants";
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
  Crown,
  ShieldCheck,
  Maximize2,
} from "lucide-react";

export default function ShowcaseHome({ onEnterStudio, onOpenPricing, onSelectPlan }) {
  const { user, openAuthModal, loginAsGuest } = useAuth();
  const [isReelModalOpen, setIsReelModalOpen] = useState(false);
  const [isAboutModalOpen, setIsAboutModalOpen] = useState(false);

  // Inline Hero Phone Video State
  const [inlineMuted, setInlineMuted] = useState(true);
  const [inlinePlaying, setInlinePlaying] = useState(true);
  const inlineVideoRef = useRef(null);

  // Template Showcase Viewfinder State
  const [activeTemplateId, setActiveTemplateId] = useState("pendulum");
  const [templateMuted, setTemplateMuted] = useState(true);
  const [templatePlaying, setTemplatePlaying] = useState(true);
  const templateVideoRef = useRef(null);

  const activeTemplate = TEMPLATES.find((t) => t.id === activeTemplateId) || TEMPLATES[0];

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

  const toggleTemplatePlay = () => {
    if (templateVideoRef.current) {
      if (templateVideoRef.current.paused) {
        templateVideoRef.current.play();
        setTemplatePlaying(true);
      } else {
        templateVideoRef.current.pause();
        setTemplatePlaying(false);
      }
    }
  };

  const toggleTemplateMute = () => {
    if (templateVideoRef.current) {
      templateVideoRef.current.muted = !templateMuted;
      setTemplateMuted(!templateMuted);
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

  const handlePlanClick = (planId) => {
    trackUpgradeViewed(planId, "showcase_pricing_card");
    if (!user || user.isGuest) {
      openAuthModal({
        intent: "pro_upgrade",
        title: "ACCOUNT REQUIRED FOR PRO",
        subtitle: "Please sign in with your email or Google account so your Pro pass is safely attached and never lost.",
      });
      return;
    }
    if (onSelectPlan) {
      onSelectPlan(planId);
    } else if (onOpenPricing) {
      onOpenPricing();
    }
  };

  return (
    <div className="w-full flex flex-col items-center select-none sky-canvas text-white min-h-[780px] p-3 sm:p-6 md:p-8 space-y-8 sm:space-y-12 animate-fadeIn">
      {/* -------------------------------------------------------------
          1. TOP NAVIGATION BAR (SLEEK & POLISHED)
          ------------------------------------------------------------- */}
      <header className="w-full flex items-center justify-between pb-3 border-b border-white/15 gap-2 relative z-20">
        {/* Left: SnapBeat Official 3D Logo */}
        <div className="flex items-center gap-2.5">
          <img
            src="/assets/images/snapbeat_logo_3d.png"
            alt="SnapBeat"
            className="h-9 sm:h-11 md:h-12 w-auto object-contain drop-shadow-[0_4px_14px_rgba(0,0,0,0.7)] hover:scale-105 transition-transform duration-200 shrink-0"
          />
          <span className="hidden sm:inline-block px-2 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] text-[9px] font-black uppercase tracking-wider shadow-sm">
            BETA
          </span>
        </div>

        {/* Center: Minimal Navigation Links */}
        <nav className="flex items-center gap-2 sm:gap-4 text-xs font-black" aria-label="Main Navigation">
          <button
            type="button"
            onClick={handleStudioAction}
            className="px-2 py-1 text-white/90 hover:text-amber-300 transition cursor-pointer rounded-lg hover:bg-white/10 flex items-center gap-1 text-[11px] sm:text-xs"
            title="Open Studio Workstation"
          >
            <span>Create</span>
            <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" />
          </button>
          <a
            href="#templates-showcase"
            className="hidden sm:inline-block px-2 py-1 text-white/80 hover:text-amber-300 transition cursor-pointer rounded-lg hover:bg-white/10 text-xs"
            title="14 Motion Templates"
          >
            Templates
          </a>
          <a
            href="#pricing-section"
            className="hidden sm:inline-block px-2 py-1 text-white/80 hover:text-amber-300 transition cursor-pointer rounded-lg hover:bg-white/10 text-xs"
            title="Creator Pricing Plans"
          >
            Pricing
          </a>
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
              {user.isGuest ? (
                <span className="px-1.5 py-0.2 rounded bg-amber-400/30 text-amber-300 text-[8px] font-mono font-black uppercase">
                  GUEST
                </span>
              ) : (
                <span className="px-1.5 py-0.2 rounded bg-emerald-500/30 text-emerald-300 text-[8px] font-mono font-black uppercase">
                  ACTIVE
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
          2. HERO: TAGLINE & CALL TO ACTION
          ------------------------------------------------------------- */}
      <section className="w-full flex flex-col items-center text-center space-y-2 pt-1 relative z-10">
        <h1 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-black text-white tracking-tight uppercase drop-shadow-md max-w-3xl">
          Turn Photos Into Beat-Synced Videos Automatically
        </h1>

        <p className="serif-italic text-xl sm:text-2xl md:text-3xl text-amber-200 font-normal tracking-wide drop-shadow">
          Not just a video... It's your story in motion.
        </p>

        <p className="text-xs sm:text-sm text-amber-100/80 font-medium max-w-xl">
          Turn your photo memories into rhythmically synchronized short-form reels in seconds with AI beat detection and 14 cinematic kinetic motion styles.
        </p>
      </section>

      {/* -------------------------------------------------------------
          3. HERO CENTERPIECE: 3D PHONE WITH LIVE DEMO VIDEO
          ------------------------------------------------------------- */}
      <section className="w-full max-w-[760px] mx-auto flex flex-col sm:flex-row items-center justify-center gap-6 sm:gap-10 my-auto py-2">
        {/* Enhanced 3D Phone Chassis with Floating Animation */}
        <div className="phone-float relative w-[220px] sm:w-[250px] shrink-0">
          <div className="relative rounded-[36px] bg-black p-[7px] shadow-[0_25px_70px_rgba(0,0,0,0.85),0_0_0_1px_rgba(255,255,255,0.12),inset_0_1px_0_rgba(255,255,255,0.2)]">
            {/* Top Phone Notch / Island */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 z-30 notch w-[130px] h-[22px] rounded-b-[14px] flex items-center justify-center gap-2.5 px-3">
              <div className="w-[32px] h-[3.5px] rounded-full bg-[#1a1a1a] shadow-[inset_0_1px_2px_rgba(0,0,0,1)]" />
              <div className="w-[5px] h-[5px] rounded-full bg-[#0f0f10] shadow-[inset_0_1px_1px_rgba(255,255,255,0.15),0_0_0_1px_#1a1a1a]" />
            </div>

            {/* Inner Screen Aspect 9:16 */}
            <div className="rounded-[28px] overflow-hidden bg-black relative aspect-[9/16] w-full group">
              <video
                ref={inlineVideoRef}
                src="/assets/videos/showcase_reel.mp4"
                autoPlay
                loop
                playsInline
                muted={inlineMuted}
                className="w-full h-full object-cover cursor-pointer"
                onClick={toggleInlinePlay}
                onPlay={() => setInlinePlaying(true)}
                onPause={() => setInlinePlaying(false)}
              />

              {/* CRT Scanline Overlay */}
              <div className="absolute inset-0 pointer-events-none crt-scanlines opacity-20" />

              {/* Top HUD Bar */}
              <div className="absolute top-6 inset-x-2 flex items-center justify-between z-20 pointer-events-auto">
                <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-black/80 backdrop-blur-md border border-white/20 text-white text-[8px] font-mono font-black tracking-wider">
                  <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse shadow-[0_0_6px_rgba(239,68,68,0.8)]" />
                  <span>LIVE DEMO</span>
                </div>

                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleInlineMute();
                    }}
                    className="p-1 rounded-full bg-black/80 hover:bg-black/90 text-white/90 border border-white/20 transition cursor-pointer flex items-center gap-1 text-[8px] font-bold px-2"
                    title={inlineMuted ? "Unmute audio" : "Mute audio"}
                  >
                    {inlineMuted ? <VolumeX className="w-2.5 h-2.5 text-amber-300" /> : <Volume2 className="w-2.5 h-2.5 text-emerald-400" />}
                    <span>{inlineMuted ? "UNMUTE" : "MUTED"}</span>
                  </button>

                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      setIsReelModalOpen(true);
                    }}
                    className="p-1 rounded-full bg-black/80 hover:bg-black/90 text-white border border-white/20 transition cursor-pointer"
                    title="Expand Video"
                  >
                    <Maximize2 className="w-2.5 h-2.5" />
                  </button>
                </div>
              </div>

              {/* Play / Pause Center Overlay */}
              {!inlinePlaying && (
                <div
                  className="absolute inset-0 flex items-center justify-center bg-black/40 z-20 cursor-pointer"
                  onClick={toggleInlinePlay}
                >
                  <div className="w-11 h-11 rounded-full bg-amber-400/90 text-black flex items-center justify-center shadow-lg transform transition hover:scale-110">
                    <Play className="w-5 h-5 fill-current ml-0.5" />
                  </div>
                </div>
              )}

              {/* Bottom Badge Bar */}
              <div className="absolute bottom-2 inset-x-2 flex items-center justify-between z-20 pointer-events-none">
                <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-black/80 backdrop-blur-md border border-white/10 text-[9px] font-extrabold text-amber-300">
                  <Sparkles className="w-2.5 h-2.5 fill-current" />
                  <span>BEAT-SYNCED</span>
                </div>
                <div className="px-2 py-0.5 rounded-full bg-black/80 backdrop-blur-md border border-white/10 text-[9px] font-mono text-white/80">
                  <span>1080P MASTER</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Right Hero Information & Primary Actions */}
        <div className="flex-1 flex flex-col items-center sm:items-start text-center sm:text-left space-y-4 max-w-md">
          <div className="space-y-2">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/20 text-amber-300 text-xs font-black tracking-wider uppercase border border-amber-400/30">
              <Sparkles className="w-3.5 h-3.5 fill-current" />
              <span>AI CHOREOGRAPHY ON EVERY BEAT</span>
            </span>
            <h2 className="text-xl sm:text-2xl font-black text-white leading-tight">
              Create Studio-Grade Reels In Just 30 Seconds
            </h2>
            <p className="text-xs sm:text-sm text-amber-100/70 font-medium">
              Upload your photos, select a built-in sound track or upload your own, and let SnapBeat compose camera movements timed precisely to musical drops.
            </p>
          </div>

          {/* Key Value Checklist */}
          <ul className="space-y-1.5 text-xs text-amber-100/90 font-semibold w-full">
            <li className="flex items-center gap-2 justify-center sm:justify-start">
              <Check className="w-3.5 h-3.5 text-emerald-400 stroke-[3] shrink-0" />
              <span>Automatic beat transient detection &amp; drop synchronization</span>
            </li>
            <li className="flex items-center gap-2 justify-center sm:justify-start">
              <Check className="w-3.5 h-3.5 text-emerald-400 stroke-[3] shrink-0" />
              <span>14 cinematic motion templates with dynamic easing</span>
            </li>
            <li className="flex items-center gap-2 justify-center sm:justify-start">
              <Check className="w-3.5 h-3.5 text-emerald-400 stroke-[3] shrink-0" />
              <span>Cloud GPU high-speed rendering with MP4 download</span>
            </li>
            <li className="flex items-center gap-2 justify-center sm:justify-start">
              <Check className="w-3.5 h-3.5 text-emerald-400 stroke-[3] shrink-0" />
              <span>1080p Master exports &amp; zero watermarks with Pro pass</span>
            </li>
          </ul>

          {/* Master CTA Button */}
          <div className="pt-2 w-full flex flex-col items-center sm:items-start gap-2">
            <button
              type="button"
              onClick={handleStudioAction}
              className="w-full sm:w-auto px-8 py-3.5 rounded-full font-black text-sm tracking-wider uppercase flex items-center justify-center gap-2 btn-gold-radiant text-[#261b02] shadow-2xl hover:scale-105 active:scale-95 transition cursor-pointer shine-btn"
            >
              <Play className="w-4 h-4 fill-current" />
              <span>START CREATING NOW</span>
            </button>
            <p className="text-[11px] text-amber-200/70 text-center sm:text-left">
              Instant 1-Click Guest Access • No signup required to try
            </p>
          </div>
        </div>
      </section>

      {/* -------------------------------------------------------------
          4. 14 KINETIC MOTION TEMPLATES SHOWCASE
          ------------------------------------------------------------- */}
      <section id="templates-showcase" className="w-full max-w-4xl mx-auto space-y-4 pt-4 border-t border-white/10">
        <div className="text-center space-y-1">
          <div className="inline-flex items-center gap-1.5 px-3 py-0.5 rounded-full bg-white/10 text-amber-300 text-[10px] font-black uppercase tracking-wider">
            <Film className="w-3 h-3 text-amber-400" />
            <span>KINETIC MOTION ENGINE</span>
          </div>
          <h2 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tight">
            14 CINEMATIC TEMPLATES WITH LIVE PREVIEWS
          </h2>
          <p className="text-xs text-amber-100/70 max-w-lg mx-auto font-medium">
            Every template features tailored camera choreography, transitions, and easing curves mapped to audio transients.
          </p>
        </div>

        {/* Viewfinder Player + Selector Grid */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-6 bg-[#09171f]/80 p-5 rounded-3xl border border-amber-400/20 backdrop-blur-md items-center">
          {/* Left Viewfinder Monitor: 5 Cols (Native 9:16 Portrait Reel) */}
          <div className="md:col-span-5 flex flex-col items-center space-y-3">
            <div className="relative aspect-[9/16] w-[210px] sm:w-[230px] rounded-2xl overflow-hidden bg-black border-2 border-amber-400/40 shadow-xl group">
              <video
                ref={templateVideoRef}
                key={activeTemplate.id}
                src={`/assets/previews/${activeTemplate.id}.mp4`}
                poster={`/assets/previews/${activeTemplate.id}.jpg`}
                autoPlay
                loop
                playsInline
                muted={templateMuted}
                className="w-full h-full object-cover cursor-pointer"
                onClick={toggleTemplatePlay}
                onPlay={() => setTemplatePlaying(true)}
                onPause={() => setTemplatePlaying(false)}
              />

              <div className="absolute inset-0 pointer-events-none crt-scanlines opacity-20" />

              {/* Viewfinder Top Bar */}
              <div className="absolute top-2 inset-x-2 flex items-center justify-between z-20">
                <span className="px-2 py-0.5 rounded-full bg-black/80 text-[8px] font-mono text-amber-300 font-bold border border-amber-400/30">
                  {activeTemplate.name.toUpperCase()} {activeTemplate.emoji}
                </span>

                <button
                  type="button"
                  onClick={toggleTemplateMute}
                  className="p-1 rounded-full bg-black/80 text-white/80 hover:text-white border border-white/20 transition cursor-pointer"
                  title={templateMuted ? "Unmute preview" : "Mute preview"}
                >
                  {templateMuted ? <VolumeX className="w-3 h-3 text-amber-300" /> : <Volume2 className="w-3 h-3 text-emerald-400" />}
                </button>
              </div>

              {!templatePlaying && (
                <div
                  className="absolute inset-0 flex items-center justify-center bg-black/40 z-20 cursor-pointer"
                  onClick={toggleTemplatePlay}
                >
                  <div className="w-9 h-9 rounded-full bg-amber-400 text-black flex items-center justify-center shadow">
                    <Play className="w-4 h-4 fill-current ml-0.5" />
                  </div>
                </div>
              )}
            </div>

            <div className="flex items-center justify-between text-xs px-1 w-[210px] sm:w-[230px]">
              <div>
                <p className="font-black text-white text-sm flex items-center gap-1">
                  <span>{activeTemplate.emoji}</span>
                  <span>{activeTemplate.name}</span>
                  {activeTemplate.isPro && (
                    <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#241903]">
                      PRO
                    </span>
                  )}
                </p>
                <p className="text-[10px] text-amber-100/70">{activeTemplate.subtitle}</p>
              </div>

              <button
                type="button"
                onClick={handleStudioAction}
                className="btn-brass px-3 py-1.5 rounded-xl text-black font-black text-[10px] uppercase tracking-wide shadow hover:brightness-110 active:scale-95 transition cursor-pointer shrink-0"
              >
                USE STYLE
              </button>
            </div>
          </div>

          {/* Right Selector Grid: 7 Cols */}
          <div className="md:col-span-7 grid grid-cols-2 sm:grid-cols-3 gap-2.5 max-h-[380px] overflow-y-auto pr-1">
            {TEMPLATES.map((tmpl) => {
              const isSelected = tmpl.id === activeTemplateId;
              return (
                <button
                  key={tmpl.id}
                  type="button"
                  onClick={() => setActiveTemplateId(tmpl.id)}
                  className={`p-2 rounded-xl text-left transition-all border flex flex-col justify-between cursor-pointer ${
                    isSelected
                      ? "bg-amber-400/20 border-amber-400 shadow-[0_0_15px_rgba(255,199,44,0.2)]"
                      : "bg-black/40 border-white/10 hover:border-white/25 hover:bg-black/60"
                  }`}
                >
                  <div className="flex items-center justify-between gap-1">
                    <span className="text-sm">{tmpl.emoji}</span>
                    {tmpl.isPro ? (
                      <span className="text-[7px] font-black px-1 py-0.2 rounded bg-amber-400/30 text-amber-300">
                        PRO
                      </span>
                    ) : (
                      <span className="text-[7px] font-black px-1 py-0.2 rounded bg-emerald-400/30 text-emerald-300">
                        FREE
                      </span>
                    )}
                  </div>
                  <div className="mt-1">
                    <p className="text-[11px] font-black text-white truncate">{tmpl.name}</p>
                    <p className="text-[9px] text-amber-100/60 truncate">{tmpl.subtitle}</p>
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      </section>

      {/* -------------------------------------------------------------
          5. TRANSPARENT 4-TIER PRICING SECTION (₹49, ₹99, ₹199, ₹999)
          ------------------------------------------------------------- */}
      <section id="pricing-section" className="w-full max-w-4xl mx-auto space-y-4 pt-4 border-t border-white/10">
        <div className="text-center space-y-1">
          <div className="inline-flex items-center gap-1.5 px-3 py-0.5 rounded-full bg-amber-400/20 text-amber-300 text-[10px] font-black uppercase tracking-wider border border-amber-400/30">
            <Crown className="w-3 h-3 text-amber-400" />
            <span>TRANSPARENT CREATOR PASSES</span>
          </div>
          <h2 className="text-2xl sm:text-3xl font-black text-white uppercase tracking-tight">
            UPGRADE TO 1080P MASTER &amp; REMOVE WATERMARKS
          </h2>
          <p className="text-xs text-amber-100/70 max-w-md mx-auto font-medium">
            Choose your Pro access pass. Instant activation with unlimited master exports.
          </p>
        </div>

        {/* Live Payment Notice */}
        <div className="p-3 rounded-2xl bg-gradient-to-r from-emerald-500/20 via-amber-500/15 to-emerald-500/20 border border-emerald-400/40 text-left flex items-center justify-between gap-3 backdrop-blur-md shadow-sm">
          <div className="flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0" />
            <p className="text-[11px] text-amber-100/90 font-medium">
              <span className="font-black text-white">INSTANT ACTIVATION:</span> UPI (GPay, PhonePe, Paytm, QR), Cards &amp; NetBanking • Powered by Cashfree Payments
            </p>
          </div>
          <span className="hidden sm:inline-block px-2 py-0.5 rounded-full bg-emerald-400/20 border border-emerald-400/40 text-emerald-300 text-[9px] font-mono font-black uppercase">
            LIVE CHECKOUT
          </span>
        </div>

        {/* Pricing Cards Grid (4 Plans including ₹49 Daily Pass) */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {PRICING_PLANS.map((plan) => {
            const isHighlight = plan.id === "monthly" || plan.id === "daily";
            const periodLabel = plan.id === "daily" ? "day" : plan.id === "weekly" ? "week" : plan.id === "monthly" ? "month" : "year";

            return (
              <div
                key={plan.id}
                className={`relative p-5 rounded-2xl transition-all flex flex-col justify-between border-2 ${
                  isHighlight
                    ? "bg-amber-500/15 border-amber-400 shadow-[0_0_25px_rgba(255,199,44,0.2)] hover:scale-[1.02]"
                    : "bg-black/40 border-white/15 hover:border-amber-400/50 hover:scale-[1.01]"
                }`}
              >
                {plan.badge && (
                  <div className="absolute -top-2.5 left-3 px-2.5 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] font-black text-[9px] shadow">
                    {plan.badge}
                  </div>
                )}

                <div>
                  <h3 className="font-black text-sm text-white uppercase mt-1">{plan.name}</h3>
                  <div className="mt-2 flex items-baseline gap-1">
                    <span className="text-3xl font-black text-amber-300">
                      ₹{plan.price}
                    </span>
                    <span className="text-xs text-amber-100/70">/{periodLabel}</span>
                  </div>
                  <p className="text-[11px] text-amber-100/70 mt-1 min-h-[30px]">{plan.description}</p>

                  <div className="mt-4 pt-3 border-t border-white/10 space-y-1.5">
                    {plan.features.slice(0, 4).map((feat, idx) => (
                      <div key={idx} className="flex items-center gap-1.5 text-[11px] text-white font-bold">
                        <Check className="w-3 h-3 text-emerald-400 shrink-0 stroke-[3]" />
                        <span className="truncate">{feat}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="pt-5 mt-auto">
                  <button
                    type="button"
                    onClick={() => handlePlanClick(plan.id)}
                    className={`w-full py-2.5 px-3 rounded-xl font-black text-xs tracking-wider uppercase shadow transition active:scale-95 cursor-pointer flex items-center justify-center gap-1.5 ${
                      isHighlight
                        ? "btn-gold-radiant text-[#261b02]"
                        : "bg-white/15 hover:bg-white/25 text-white border border-white/20"
                    }`}
                  >
                    <Crown className="w-3 h-3 fill-current shrink-0" />
                    <span>GET {plan.name.toUpperCase()}</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        {/* Free vs Pro Comparison Strip */}
        <div className="p-4 rounded-2xl bg-black/40 border border-white/10 space-y-3">
          <p className="text-xs font-black text-white uppercase tracking-wide text-center">
            FREE TIER VS PRO STUDIO PASS COMPARISON
          </p>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-center text-xs">
            <div className="p-2 rounded-xl bg-white/5 border border-white/5">
              <p className="text-[10px] text-amber-100/60 uppercase">Export Resolution</p>
              <p className="font-black text-white mt-0.5">480p (Free) vs 1080p (Pro)</p>
            </div>
            <div className="p-2 rounded-xl bg-white/5 border border-white/5">
              <p className="text-[10px] text-amber-100/60 uppercase">Watermark Branding</p>
              <p className="font-black text-emerald-400 mt-0.5">100% Removed with Pro</p>
            </div>
            <div className="p-2 rounded-xl bg-white/5 border border-white/5">
              <p className="text-[10px] text-amber-100/60 uppercase">Templates Unlocked</p>
              <p className="font-black text-amber-300 mt-0.5">All 14 Motion Styles</p>
            </div>
            <div className="p-2 rounded-xl bg-white/5 border border-white/5">
              <p className="text-[10px] text-amber-100/60 uppercase">Queue Priority</p>
              <p className="font-black text-sky-400 mt-0.5">VIP Fast-Track GPU</p>
            </div>
          </div>
        </div>
      </section>

      {/* -------------------------------------------------------------
          6. MINIMAL SPONSOR BAR
          ------------------------------------------------------------- */}
      <div className="w-full max-w-2xl mx-auto z-20">
        <RetroAdBanner isPro={Boolean(user?.isPro)} onOpenPricing={onOpenPricing} className="my-0" />
      </div>

      {/* -------------------------------------------------------------
          7. BOTTOM DOCK: 4 INTERACTIVE FEATURE PILLS
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
          8. SLEEK FOOTER
          ------------------------------------------------------------- */}
      <footer className="w-full flex flex-col sm:flex-row items-center justify-between text-[11px] text-amber-100/60 pt-2 border-t border-white/10 gap-2">
        <p>© 2026 SnapBeat • Tactile Audio-Visual Reel Maker</p>
        <div className="flex items-center gap-3 font-semibold">
          <a href="#pricing-section" className="hover:text-amber-300 transition cursor-pointer">
            Pricing
          </a>
          <button type="button" onClick={() => setIsAboutModalOpen(true)} className="hover:text-amber-300 transition cursor-pointer">
            About
          </button>
          <a href="/privacy" className="hover:text-amber-300 transition">Privacy</a>
          <a href="/terms" className="hover:text-amber-300 transition">Terms</a>
        </div>
      </footer>

      {/* -------------------------------------------------------------
          9. EXPANDED SAMPLE REEL MODAL
          ------------------------------------------------------------- */}
      {isReelModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fadeIn">
          <div className="relative w-full max-w-sm rounded-3xl overflow-hidden bg-black border-2 border-amber-400 shadow-2xl">
            <button
              type="button"
              onClick={() => setIsReelModalOpen(false)}
              className="absolute top-3 right-3 z-30 w-8 h-8 rounded-full bg-black/70 hover:bg-black text-white flex items-center justify-center transition cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>
            <video
              src="/assets/videos/showcase_reel.mp4"
              controls
              autoPlay
              className="w-full aspect-[9/16] object-cover"
            />
          </div>
        </div>
      )}

      {/* -------------------------------------------------------------
          10. ABOUT MODAL
          ------------------------------------------------------------- */}
      {isAboutModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fadeIn">
          <div className="relative w-full max-w-md sky-glass-panel rounded-3xl p-6 border border-[#d4af37]/40 shadow-2xl text-white space-y-4">
            <button
              type="button"
              onClick={() => setIsAboutModalOpen(false)}
              className="absolute top-4 right-4 w-7 h-7 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-2">
              <img
                src="/assets/images/snapbeat_logo_3d.png"
                alt="SnapBeat"
                className="h-8 object-contain"
              />
              <span className="px-2 py-0.5 rounded-full bg-amber-400 text-black text-[9px] font-black uppercase">
                ABOUT
              </span>
            </div>
            <h3 className="text-lg font-black uppercase tracking-wide">
              Tactile Audio-Visual Reel Maker
            </h3>
            <p className="text-xs text-amber-100/80 leading-relaxed">
              SnapBeat is an audio-driven video generator that automatically pairs rhythmic beats with dynamic visual motion. Select your soundtrack, drop in your favourite photos, and export studio-quality reels in seconds.
            </p>
            <div className="pt-2 border-t border-white/10 flex justify-end">
              <button
                type="button"
                onClick={() => setIsAboutModalOpen(false)}
                className="btn-gold-radiant px-4 py-2 rounded-xl text-black font-black text-xs uppercase"
              >
                GOT IT
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
