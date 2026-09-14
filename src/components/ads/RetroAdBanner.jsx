"use client";

import React, { useState, useEffect } from "react";
import { Crown, Sparkles, ExternalLink, Zap } from "lucide-react";

const SPONSOR_ADS = [
  {
    id: "gcp_vertex",
    category: "INFRASTRUCTURE PARTNER",
    badge: "CLOUD PARTNER",
    title: "Google Cloud High-Speed GPU Renders",
    tagline: "Ultra-low latency audio waveform beat synchronization",
    description: "SnapBeat's video rendering engine is accelerated on Google Cloud Tensor Core GPU clusters for sub-minute cinematic reel delivery.",
    cta: "LEARN MORE",
    link: "https://cloud.google.com/gpu",
    icon: Zap,
    accentColor: "text-amber-300",
    badgeBg: "bg-amber-400 text-black",
  },
  {
    id: "creator_gear",
    category: "FEATURED SPONSOR",
    badge: "CREATOR GEAR",
    title: "Pro 35mm Cinema Lens Kits & Stabilizers",
    tagline: "Capture razor-sharp stills for cinematic video motion",
    description: "Pair your high-resolution mirrorless and smartphone photos with SnapBeat's 14 kinetic camera choreography templates.",
    cta: "DISCOVER GEAR",
    link: "https://snapbeat.app",
    icon: Sparkles,
    accentColor: "text-emerald-300",
    badgeBg: "bg-emerald-400 text-black",
  },
  {
    id: "snapbeat_pro",
    category: "PRO UPGRADE SPOTLIGHT",
    badge: "VIP CREATOR",
    title: "SnapBeat 1080p Master Studio Pass",
    tagline: "Clean exports, zero watermarks, 14 motion styles",
    description: "Unlock high-bitrate 1080p Full HD video exports, opening title card typography, and manual template choreography.",
    cta: "EXPLORE PRO (SOON)",
    isProCta: true,
    icon: Crown,
    accentColor: "text-amber-400",
    badgeBg: "bg-gradient-to-r from-amber-400 to-amber-500 text-black",
  },
];

export default function RetroAdBanner({
  isPro = false,
  onOpenPricing,
  slotId = "banner_default",
  className = "",
}) {
  const [adIndex, setAdIndex] = useState(0);

  // Rotate sponsor broadcast every 8 seconds
  useEffect(() => {
    const timer = setInterval(() => {
      setAdIndex((prev) => (prev + 1) % SPONSOR_ADS.length);
    }, 8000);
    return () => clearInterval(timer);
  }, []);

  // Pro users never see ads!
  if (isPro) return null;

  const currentAd = SPONSOR_ADS[adIndex];
  const Icon = currentAd.icon;

  return (
    <aside
      aria-label="Sponsored Broadcast Advertisement"
      className={`w-full max-w-4xl mx-auto my-6 select-none ${className}`}
    >
      <div className="relative rounded-3xl p-4 sm:p-5 bg-gradient-to-b from-[#091b22] via-[#051318] to-[#091b22] border-2 border-amber-400/50 shadow-[0_15px_45px_rgba(0,0,0,0.8),0_0_25px_rgba(255,199,44,0.15)] overflow-hidden text-white">
        {/* Subtle Ambient Gold Glow Top Edge */}
        <div className="absolute top-0 left-1/4 right-1/4 h-[2px] bg-gradient-to-r from-transparent via-amber-400 to-transparent" />

        {/* Top Header Label: Unmistakable Sponsored Advertisement Plaque */}
        <div className="flex items-center justify-between pb-3 mb-3 border-b border-white/15 px-1 flex-wrap gap-2">
          <div className="flex items-center gap-2">
            <span className="px-2 py-0.5 rounded bg-amber-400/20 text-amber-300 font-mono font-black text-[9px] uppercase tracking-widest border border-amber-400/50 flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse" />
              SPONSORED ADVERTISEMENT
            </span>
            <span className="font-mono text-[10px] text-amber-100/70 font-bold tracking-wider uppercase">
              • {currentAd.category}
            </span>
          </div>

          <div className="flex items-center gap-2">
            {/* Dot pager for rotating ads */}
            <div className="flex items-center gap-1">
              {SPONSOR_ADS.map((ad, idx) => (
                <button
                  key={ad.id}
                  type="button"
                  onClick={() => setAdIndex(idx)}
                  className={`h-1.5 rounded-full transition-all cursor-pointer ${
                    adIndex === idx ? "w-4 bg-amber-400" : "w-1.5 bg-white/20 hover:bg-white/40"
                  }`}
                  aria-label={`View advertisement ${idx + 1}`}
                />
              ))}
            </div>
            <span className="text-[9px] font-mono text-white/50 border border-white/20 px-1.5 py-0.2 rounded">
              AD
            </span>
          </div>
        </div>

        {/* Ad Body Content */}
        <div className="bg-black/50 backdrop-blur-md rounded-2xl p-4 sm:p-5 flex flex-col md:flex-row items-center justify-between gap-5 border border-white/10 shadow-inner">
          <div className="flex items-start gap-4 w-full md:w-auto">
            <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-2xl bg-gradient-to-br from-amber-500/20 via-black/60 to-amber-500/10 border-2 border-amber-400/40 flex items-center justify-center shrink-0 shadow-lg mt-0.5">
              <Icon className={`w-6 h-6 sm:w-7 sm:h-7 ${currentAd.accentColor}`} />
            </div>

            <div className="text-left space-y-1">
              <div className="flex items-center gap-2 flex-wrap">
                <span className={`px-2 py-0.5 rounded-full font-black text-[9px] uppercase tracking-wider shadow ${currentAd.badgeBg}`}>
                  {currentAd.badge}
                </span>
                <h4 className="font-black text-sm sm:text-base text-white tracking-tight uppercase">
                  {currentAd.title}
                </h4>
              </div>

              <p className="text-xs text-amber-300/90 font-bold">
                {currentAd.tagline}
              </p>

              <p className="text-[11px] sm:text-xs text-amber-100/70 font-medium leading-relaxed max-w-2xl">
                {currentAd.description}
              </p>
            </div>
          </div>

          {/* Action CTA Button */}
          <div className="shrink-0 w-full md:w-auto flex md:flex-col justify-end">
            {currentAd.isProCta ? (
              <button
                type="button"
                onClick={onOpenPricing}
                className="w-full md:w-auto btn-brass px-5 py-3 rounded-2xl font-black text-xs text-[#261b02] uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <Crown className="w-3.5 h-3.5 text-amber-800" />
                <span>{currentAd.cta}</span>
              </button>
            ) : (
              <a
                href={currentAd.link}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full md:w-auto px-5 py-3 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-black text-xs uppercase tracking-wider border border-white/20 shadow-md backdrop-blur-md active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer hover:border-amber-400/50"
              >
                <span>{currentAd.cta}</span>
                <ExternalLink className="w-3.5 h-3.5 text-amber-400" />
              </a>
            )}
          </div>
        </div>

        {/* Ad Footnote */}
        <div className="mt-3 pt-2 border-t border-white/10 flex items-center justify-between text-[10px] text-white/50 px-1 font-mono">
          <span>Free tier is sponsored by our cloud &amp; hardware partners</span>
          <button
            type="button"
            onClick={onOpenPricing}
            className="text-amber-400 hover:text-amber-300 font-bold hover:underline cursor-pointer"
          >
            Go Ad-Free with Pro (Coming Soon) ❯
          </button>
        </div>
      </div>
    </aside>
  );
}
