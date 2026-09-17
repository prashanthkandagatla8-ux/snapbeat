"use client";

import React from "react";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";
import { Film, Sparkles, Crown, Type } from "lucide-react";

export function VideoStage({
  videoUrl,
  aspectRatio = "9:16",
  isRendering,
  titleCard,
  isPro = false,
  onOpenPricing,
  onDownload,
}) {
  const aspectClass =
    aspectRatio === "1:1"
      ? "aspect-square max-w-[420px]"
      : aspectRatio === "16:9"
      ? "aspect-video max-w-[620px]"
      : "aspect-[9/16] max-w-[340px]"; // 9:16 default

  const getFontClass = (fontId) => {
    switch (fontId) {
      case "great_vibes":
        return "font-serif italic tracking-wider";
      case "cinzel":
        return "font-serif tracking-[0.2em] uppercase font-black";
      case "bebas_neue":
        return "font-sans font-black tracking-widest uppercase scale-y-110";
      case "playfair":
        return "font-serif italic font-bold tracking-wide";
      case "montserrat":
      default:
        return "font-sans font-black tracking-tight uppercase";
    }
  };

  return (
    <div className="flex flex-col items-center justify-center w-full h-full p-2">
      {/* Viewport container */}
      <div
        className={`w-full ${aspectClass} rounded-2xl overflow-hidden relative shadow-2xl border-4 border-[#3a3734] bg-[#0d0c0b] flex items-center justify-center transition-all duration-300 group`}
      >
        {videoUrl ? (
          <video
            src={videoUrl}
            controls
            autoPlay
            loop
            className="w-full h-full object-cover"
          />
        ) : titleCard?.enabled || titleCard?.text ? (
          /* Live Title Card Preview Stage */
          <div className="w-full h-full relative flex flex-col items-center justify-between p-6 bg-gradient-to-b from-[#18181b] via-[#09090b] to-[#18181b] text-center select-none overflow-hidden">
            {/* Scanlines and Vignette Effect */}
            <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,_transparent_40%,_rgba(0,0,0,0.85)_100%)] z-10" />
            <div className="absolute inset-0 pointer-events-none opacity-25 bg-[repeating-linear-gradient(0deg,#000,#000_2px,transparent_2px,transparent_4px)] z-10" />

            {/* Top Letterbox Bar */}
            <div className="w-full z-20 flex items-center justify-between text-[9px] font-mono text-amber-400/80 border-b border-amber-400/20 pb-1">
              <span>INT. OPENING • SCENE 1</span>
              <span>00:00 - 00:0{titleCard?.duration || 3}</span>
            </div>

            {/* Center Typography */}
            <div className="z-20 my-auto space-y-3 px-2 flex flex-col items-center w-full">
              {isPro ? (
                <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-amber-400/15 border border-amber-400/30 text-amber-300 text-[10px] font-black uppercase tracking-widest">
                  <Sparkles className="w-3 h-3 text-amber-400" />
                  <span>OPENING TITLE</span>
                </div>
              ) : (
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/80 border border-amber-500/60 text-amber-300 text-[10px] font-black uppercase tracking-wider backdrop-blur-sm shadow-lg">
                  <Crown className="w-3 h-3 text-amber-400" />
                  <span>PRO TITLE CARD PREVIEW</span>
                </div>
              )}

              <h2
                className={`text-2xl sm:text-3xl font-black uppercase tracking-wider text-transparent bg-clip-text bg-gradient-to-b from-white via-amber-100 to-amber-400 drop-shadow-[0_4px_12px_rgba(251,191,36,0.4)] ${getFontClass(
                  titleCard?.font
                )}`}
              >
                {titleCard?.text?.trim() || "YOUR REEL TITLE"}
              </h2>

              <p className="text-[11px] font-mono font-bold tracking-widest text-amber-400/80 uppercase">
                {titleCard?.subtitle?.trim() || "A SNAPBEAT PRODUCTION • 2026"}
              </p>

              <div className="w-16 h-0.5 bg-gradient-to-r from-transparent via-amber-400 to-transparent mx-auto mt-2" />

              {!isPro && onOpenPricing && (
                <button
                  type="button"
                  onClick={onOpenPricing}
                  className="px-3 py-1 rounded-xl btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shadow hover:brightness-110 flex items-center gap-1 mt-2"
                >
                  <Crown className="w-2.5 h-2.5" />
                  <span>UNLOCK WITH PRO</span>
                </button>
              )}
            </div>

            {/* Bottom Letterbox Bar */}
            <div className="w-full z-20 flex items-center justify-between text-[9px] font-mono text-gray-500 border-t border-white/10 pt-1">
              <span>SNAPBEAT</span>
              <span>LIVE CRT MONITOR</span>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center text-center p-6 space-y-4">
            <div className="w-16 h-16 rounded-2xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
              <Film className="w-8 h-8" />
            </div>
            <div>
              <p className="font-extrabold text-white text-base">Studio Preview Canvas</p>
              <p className="text-xs text-gray-400 mt-1 max-w-[240px]">
                Upload music and photos, choose your template, and hit Render Reel!
              </p>
            </div>
            {/* Animated equalizer bars */}
            <div className="flex items-center gap-1.5 pt-2">
              {[40, 70, 30, 85, 55, 90, 45, 65, 35].map((h, i) => (
                <div
                  key={i}
                  className="w-1.5 bg-amber-500/50 rounded-full animate-pulse"
                  style={{
                    height: `${h * 0.4}px`,
                    animationDelay: `${i * 120}ms`,
                  }}
                />
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Auto-Saved Status Indicator */}
      {videoUrl && (
        <div className="mt-4 flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-500/15 border border-emerald-400/30 text-emerald-300 text-xs font-bold">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          <span>AUTO-SAVED TO DOWNLOADS</span>
        </div>
      )}
    </div>
  );
}
