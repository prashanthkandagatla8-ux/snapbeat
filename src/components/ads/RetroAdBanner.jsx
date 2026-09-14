"use client";

import React, { useState, useEffect } from "react";
import { Crown, Sparkles, ExternalLink, Zap } from "lucide-react";
import { trackAffiliateClicked, trackUpgradeViewed } from "@/lib/analytics";

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
      aria-label="Sponsored Broadcast"
      className={`w-full max-w-3xl mx-auto my-3 select-none ${className}`}
    >
      <div className="relative rounded-2xl p-2.5 sm:px-4 sm:py-3 bg-[#06151a]/90 backdrop-blur-md border border-amber-400/30 shadow-[0_10px_30px_rgba(0,0,0,0.6)] overflow-hidden text-white flex flex-col sm:flex-row items-center justify-between gap-3">
        {/* Left: Indicator + Icon + Sponsor Message */}
        <div className="flex items-center gap-3 w-full sm:w-auto">
          <div className="w-8 h-8 rounded-xl bg-amber-500/15 border border-amber-400/30 flex items-center justify-center shrink-0">
            <Icon className={`w-4 h-4 ${currentAd.accentColor}`} />
          </div>

          <div className="text-left space-y-0.5 min-w-0">
            <div className="flex items-center gap-2">
              <span className="px-1.5 py-0.2 rounded bg-amber-400/20 text-amber-300 font-mono font-black text-[8px] uppercase tracking-wider border border-amber-400/40">
                SPONSOR
              </span>
              <span className="font-mono text-[9px] text-white/50 uppercase tracking-wide truncate">
                {currentAd.category}
              </span>
            </div>
            <p className="text-xs font-bold text-white tracking-tight truncate">
              {currentAd.title}
            </p>
          </div>
        </div>

        {/* Right: Action Link + Dots */}
        <div className="flex items-center justify-between sm:justify-end gap-3 w-full sm:w-auto shrink-0 pt-1 sm:pt-0 border-t sm:border-t-0 border-white/10">
          <div className="flex items-center gap-1">
            {SPONSOR_ADS.map((ad, idx) => (
              <button
                key={ad.id}
                type="button"
                onClick={() => setAdIndex(idx)}
                className={`h-1.5 rounded-full transition-all cursor-pointer ${
                  adIndex === idx ? "w-3 bg-amber-400" : "w-1 bg-white/20 hover:bg-white/40"
                }`}
                aria-label={`View ad ${idx + 1}`}
              />
            ))}
          </div>

          {currentAd.isProCta ? (
            <button
              type="button"
              onClick={() => {
                trackUpgradeViewed("all", "ad_banner");
                onOpenPricing?.();
              }}
              className="px-3 py-1.5 rounded-xl btn-brass text-[10px] font-black text-[#261b02] uppercase tracking-wider shadow hover:brightness-110 active:scale-95 transition cursor-pointer"
            >
              <span>{currentAd.cta}</span>
            </button>
          ) : (
            <a
              href={currentAd.link}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => {
                trackAffiliateClicked({
                  category: currentAd.category,
                  partner: currentAd.id,
                  placement: "ad_banner",
                });
              }}
              className="px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-white font-black text-[10px] uppercase tracking-wider border border-white/20 shadow-sm active:scale-95 transition flex items-center gap-1 cursor-pointer hover:border-amber-400/50"
            >
              <span>{currentAd.cta}</span>
              <ExternalLink className="w-3 h-3 text-amber-400" />
            </a>
          )}
        </div>
      </div>
    </aside>
  );
}
