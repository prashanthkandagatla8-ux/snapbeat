"use client";

import React from "react";
import { Crown } from "lucide-react";

export default function RetroAdBanner({ isPro, onOpenPricing, slotId = "banner_default", className = "" }) {
  // Pro users never see ads!
  if (isPro) return null;

  return (
    <div className={`w-full max-w-4xl mx-auto my-4 ${className}`} aria-label="Sponsor Broadcast">
      <div className="relative metal-panel rounded-2xl p-4 sm:p-5 border-2 border-[#8f8677]/60 shadow-md overflow-hidden">
        {/* Screws with absolute positioning */}
        <div className="absolute top-2.5 left-2.5 metal-screw" />
        <div className="absolute top-2.5 right-2.5 metal-screw" />
        <div className="absolute bottom-2.5 left-2.5 metal-screw" />
        <div className="absolute bottom-2.5 right-2.5 metal-screw" />

        {/* Top Header Label */}
        <div className="flex items-center justify-between pb-2 mb-2 border-b border-[#8f8677]/40 text-[9px] font-mono font-bold text-[#5a5752] uppercase tracking-widest px-4">
          <div className="flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
            <span>SPONSORED BROADCAST • HARDWARE SPONSOR</span>
          </div>
          <button
            type="button"
            onClick={onOpenPricing}
            className="hover:text-[#2b2b2d] text-amber-800 flex items-center gap-1 font-black transition cursor-pointer"
          >
            <Crown className="w-3 h-3" />
            <span>REMOVE ADS WITH PRO</span>
          </button>
        </div>

        {/* Ad Body (Tasteful Retro Hardware Sponsor Plaque) */}
        <div className="metal-inset rounded-xl p-3.5 sm:p-4 min-h-[85px] flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3.5 w-full sm:w-auto">
            <div className="w-12 h-12 rounded-xl overflow-hidden shadow-inner shrink-0 border border-[#8f8677]/70 bg-black/10 flex items-center justify-center p-1">
              <img
                src="/assets/images/snapbeat_app_icon.png"
                alt="SnapBeat Icon"
                className="w-full h-full object-contain rounded-lg"
              />
            </div>
            <div className="text-left">
              <span className="text-[10px] font-mono font-black text-amber-800 uppercase tracking-wider">
                FEATURED HARDWARE UPGRADE
              </span>
              <div className="flex items-center gap-1.5 flex-wrap">
                <img
                  src="/assets/images/snapbeat_logo_crop.png"
                  alt="SnapBeat"
                  className="h-4 object-contain inline-block"
                />
                <h4 className="font-black text-sm text-[#2b2b2d] uppercase tracking-tight">
                  PRO STUDIO PASS
                </h4>
              </div>
              <p className="text-xs text-[#5a5752] font-semibold mt-0.5">
                Export unlimited crisp 1080p reels without watermarks. Passes start at ₹99/week.
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onOpenPricing}
            className="btn-brass px-5 py-2.5 rounded-xl font-black text-xs text-[#2b2820] shadow hover:brightness-105 active:scale-95 transition whitespace-nowrap flex items-center gap-1.5 cursor-pointer shrink-0"
          >
            <Crown className="w-3.5 h-3.5 fill-current" />
            <span>UPGRADE (₹99)</span>
          </button>
        </div>
      </div>
    </div>
  );
}

