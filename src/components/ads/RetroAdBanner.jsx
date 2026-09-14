"use client";

import React from "react";
import { Crown, Sparkles } from "lucide-react";

export default function RetroAdBanner({ isPro, onOpenPricing, slotId = "banner_default", className = "" }) {
  // Pro users never see ads!
  if (isPro) return null;

  return (
    <div className={`w-full max-w-4xl mx-auto my-4 ${className}`} aria-label="Sponsor Broadcast">
      <div className="relative sky-glass-card rounded-2xl p-4 sm:p-5 shadow-lg overflow-hidden border border-[#d4af37]/30 text-white">
        {/* Top Header Label */}
        <div className="flex items-center justify-between pb-2 mb-2 border-b border-white/10 text-[10px] font-mono font-bold text-amber-300 uppercase tracking-widest px-2">
          <div className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse" />
            <span>COMMUNITY SPOTLIGHT • 100% FREE BETA</span>
          </div>
          <span className="text-amber-200/70 text-[9px]">
            FREE UNLIMITED RENDERS TODAY
          </span>
        </div>

        {/* Ad Body */}
        <div className="bg-black/40 backdrop-blur-md rounded-xl p-3.5 sm:p-4 min-h-[80px] flex flex-col sm:flex-row items-center justify-between gap-4 border border-white/10">
          <div className="flex items-center gap-3.5 w-full sm:w-auto">
            <div className="w-12 h-12 rounded-xl overflow-hidden shadow-inner shrink-0 border border-white/15 bg-black/30 flex items-center justify-center p-1">
              <img
                src="/assets/images/snapbeat_app_icon.png"
                alt="SnapBeat Icon"
                className="w-full h-full object-contain rounded-lg"
              />
            </div>
            <div className="text-left">
              <span className="text-[10px] font-mono font-black text-amber-300 uppercase tracking-wider">
                COMMUNITY LAUNCH PASS
              </span>
              <div className="flex items-center gap-1.5 flex-wrap">
                <img
                  src="/assets/images/snapbeat_logo_3d.png"
                  alt="SnapBeat"
                  className="h-4 object-contain inline-block drop-shadow"
                />
                <h4 className="font-black text-sm text-white uppercase tracking-tight">
                  UNLIMITED REEL MAKER
                </h4>
              </div>
              <p className="text-xs text-amber-100/80 font-medium mt-0.5">
                Create unlimited beat-synced reels with 14 cinematic templates at zero cost!
              </p>
            </div>
          </div>

          <div className="px-4 py-2 rounded-full bg-amber-400/20 text-amber-300 font-black text-xs border border-amber-400/40 shrink-0">
            <span>FREE ACCESS</span>
          </div>
        </div>
      </div>
    </div>
  );
}
