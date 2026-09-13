"use client";

import React from "react";
import { Sparkles, Crown } from "lucide-react";

export default function RetroAdBanner({ isPro, onOpenPricing, slotId = "banner_default", className = "" }) {
  // Pro users never see ads!
  if (isPro) return null;

  return (
    <div className={`w-full max-w-4xl mx-auto my-4 ${className}`}>
      <div className="relative metal-panel rounded-2xl p-4 border-2 border-[#8f8677]/60 shadow-md overflow-hidden">
        {/* Screws */}
        <div className="metal-screw top-2 left-2" />
        <div className="metal-screw top-2 right-2" />
        <div className="metal-screw bottom-2 left-2" />
        <div className="metal-screw bottom-2 right-2" />

        {/* Top Header Label */}
        <div className="flex items-center justify-between pb-2 mb-2 border-b border-[#8f8677]/40 text-[9px] font-mono font-bold text-[#5a5752] uppercase tracking-widest px-1">
          <div className="flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
            <span>SPONSORED BROADCAST • ADVERTISEMENT</span>
          </div>
          <button
            onClick={onOpenPricing}
            className="hover:text-[#2b2b2d] text-amber-700 flex items-center gap-1 font-black transition"
          >
            <Crown className="w-3 h-3" />
            <span>REMOVE ADS WITH PRO</span>
          </button>
        </div>

        {/* Ad Body (Tasteful Retro Sponsor Card or AdSense Slot) */}
        <div className="metal-inset rounded-xl p-4 min-h-[90px] flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3.5">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center text-black font-black text-xl shadow shrink-0">
              <Sparkles className="w-6 h-6" />
            </div>
            <div className="text-left">
              <span className="text-[10px] font-mono font-black text-amber-700 uppercase tracking-wider">
                FEATURED SPONSOR
              </span>
              <h4 className="font-black text-sm text-[#2b2b2d] uppercase tracking-tight">
                Upgrade to SnapBeat Pro Studio
              </h4>
              <p className="text-xs text-[#5a5752] font-semibold">
                Export unlimited crisp 1080p reels without watermarks. Starts at ₹99.
              </p>
            </div>
          </div>

          <button
            onClick={onOpenPricing}
            className="btn-brass px-5 py-2 rounded-xl font-black text-xs text-[#2b2820] shadow hover:brightness-110 active:scale-95 transition whitespace-nowrap"
          >
            EXPLORE PASSES
          </button>
        </div>
      </div>
    </div>
  );
}
