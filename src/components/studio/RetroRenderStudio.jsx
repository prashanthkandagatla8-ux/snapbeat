"use client";

import React, { useState } from "react";
import { TEMPLATES, ASPECT_RATIOS, TITLE_FONTS } from "@/lib/constants";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";
import { Sparkles, Crown, Film, Download, Type, Sliders, Loader2, Play, Eye, Lock } from "lucide-react";

export function RetroRenderStudio({
  renderMode,
  setRenderMode,
  selectedTemplate,
  setSelectedTemplate,
  aspectRatio,
  setAspectRatio,
  quality,
  setQuality,
  watermark,
  setWatermark,
  titleCard,
  setTitleCard,
  isPro,
  onOpenPricing,
  onRender,
  isRendering,
  canRender,
  videoUrl,
  onNavigateQueue,
}) {
  const currentTemplateObj = TEMPLATES.find((t) => t.id === selectedTemplate) || TEMPLATES[0];

  const getTitleCardFontClass = (fontId) => {
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

  const handleTitleToggle = (checked) => {
    if (!isPro) {
      onOpenPricing();
      return;
    }
    setTitleCard((prev) => ({ ...prev, enabled: checked }));
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
      {/* LEFT: Title Card Preview & Monitor Console (7 cols) */}
      <div className="lg:col-span-7 sky-glass-panel text-white rounded-3xl p-6 relative flex flex-col items-center shadow-xl">
        {/* Top Header of Monitor */}
        <div className="w-full flex items-center justify-between border-b border-white/10 pb-2 mb-4">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse" />
            <h3 className="font-black text-xs text-white uppercase tracking-wider">
              {videoUrl && monitorMode === "video" ? "FINAL REEL PLAYBACK" : "LIVE TITLE CARD CRT MONITOR"}
            </h3>
          </div>

          <div className="flex items-center gap-2">
            {videoUrl && (
              <button
                type="button"
                onClick={onNavigateQueue}
                className="px-2.5 py-1 rounded-xl btn-brass text-[#2b2820] text-[10px] font-black tracking-wide flex items-center gap-1 hover:brightness-110 active:scale-95 transition shadow cursor-pointer"
                title="Preview & Export Finished Reel in Queue"
              >
                <Film className="w-3 h-3" />
                <span>VIEW REEL IN QUEUE</span>
              </button>
            )}
            <span className="px-2 py-0.5 rounded bg-[#1e1c1a] text-amber-400 font-mono text-[10px] font-bold">
              FRAME: {aspectRatio} • {quality === "master" ? "1080P" : "480P"}
            </span>
          </div>
        </div>

        {/* Viewport Stage */}
        <div
          className={`w-full ${
            aspectRatio === "1:1"
              ? "aspect-square max-w-[380px]"
              : aspectRatio === "16:9"
              ? "aspect-video max-w-[540px]"
              : "aspect-[9/16] max-w-[320px]"
          } rounded-2xl overflow-hidden relative shadow-2xl border-4 border-[#3a3734] bg-[#0d0c0b] flex items-center justify-center transition-all duration-300 group`}
        >
          {/* Live Title Card CRT Stage - Always Live, Never Just Placeholder */}
          <div className="w-full h-full relative flex flex-col items-center justify-between p-6 bg-gradient-to-b from-[#18181b] via-[#09090b] to-[#18181b] text-center select-none overflow-hidden">
              {/* Scanlines and Vignette CRT Effect */}
              <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,_transparent_40%,_rgba(0,0,0,0.85)_100%)] z-10" />
              <div className="absolute inset-0 pointer-events-none opacity-25 bg-[repeating-linear-gradient(0deg,#000,#000_2px,transparent_2px,transparent_4px)] z-10" />

              {/* Top Letterbox Bar */}
              <div className="w-full z-20 flex items-center justify-between text-[9px] font-mono text-amber-400/80 border-b border-amber-400/20 pb-1">
                <span>INT. OPENING • SCENE 1</span>
                <span>00:00 - 00:0{titleCard?.duration || 3}</span>
              </div>

              {/* Center Content: Live Title Card Typography */}
              <div className="z-20 my-auto space-y-3 px-2 w-full flex flex-col items-center">
                {/* Mode Indicator Badge */}
                {isPro ? (
                  titleCard?.enabled ? (
                    <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-amber-400/15 border border-amber-400/30 text-amber-300 text-[10px] font-black uppercase tracking-widest">
                      <Sparkles className="w-3 h-3 text-amber-400" />
                      <span>OPENING TITLE CARD ACTIVE</span>
                    </div>
                  ) : (
                    <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-white/10 border border-white/20 text-gray-300 text-[10px] font-black uppercase tracking-widest">
                      <Type className="w-3 h-3 text-amber-400" />
                      <span>TITLE PREVIEW (OFFLINE)</span>
                    </div>
                  )
                ) : (
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/80 border border-amber-500/60 text-amber-300 text-[10px] font-black uppercase tracking-wider backdrop-blur-sm shadow-lg">
                    <Crown className="w-3 h-3 text-amber-400" />
                    <span>PRO TITLE CARD PREVIEW</span>
                  </div>
                )}

                {/* Primary Cinematic Title Headline */}
                <h2
                  className={`text-2xl sm:text-3xl font-black tracking-wider text-transparent bg-clip-text bg-gradient-to-b from-white via-amber-100 to-amber-400 drop-shadow-[0_4px_12px_rgba(251,191,36,0.4)] ${getTitleCardFontClass(
                    titleCard?.font
                  )}`}
                >
                  {titleCard?.text?.trim() || "YOUR REEL TITLE"}
                </h2>

                {/* Subtitle / Dateline */}
                <p className="text-[11px] font-mono font-bold tracking-widest text-amber-400/80 uppercase">
                  {titleCard?.subtitle?.trim() || "A SNAPBEAT PRODUCTION • 2026"}
                </p>

                {/* Accent Divider Bar */}
                <div className="w-16 h-0.5 bg-gradient-to-r from-transparent via-amber-400 to-transparent mx-auto mt-2" />

                {/* Pro Lock Prompt Overlay when not Pro */}
                {!isPro ? (
                  <div className="pt-2 flex flex-col items-center gap-1.5">
                    <span className="text-[9px] font-mono text-amber-300/80 uppercase tracking-wider">
                      Title cards render on Pro reels only
                    </span>
                    <button
                      type="button"
                      onClick={onOpenPricing}
                      className="px-3 py-1 rounded-xl btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shadow hover:brightness-110 flex items-center gap-1 cursor-pointer"
                    >
                      <Crown className="w-2.5 h-2.5" />
                      <span>UNLOCK WITH PRO (COMING SOON)</span>
                    </button>
                  </div>
                ) : !titleCard?.enabled ? (
                  <p className="text-[9px] font-mono text-gray-400 uppercase tracking-wide">
                    Toggle "OPENING TITLE CARD" under controls to attach to export
                  </p>
                ) : null}
              </div>

              {/* Bottom Letterbox Bar */}
              <div className="w-full z-20 flex items-center justify-between text-[9px] font-mono text-gray-500 border-t border-white/10 pt-1">
                <span>SNAPBEAT CHOREO</span>
                <span>{currentTemplateObj.name.toUpperCase()}</span>
              </div>
            </div>
        </div>

        {/* Queue Preview & Export Action Bar if video is rendered */}
        {videoUrl && (
          <div className="mt-4 flex items-center gap-3">
            <button
              type="button"
              onClick={onNavigateQueue}
              className="btn-gold-radiant px-5 py-2.5 rounded-2xl text-xs font-black uppercase text-[#261b02] flex items-center gap-2 shadow-lg hover:scale-105 active:scale-95 transition cursor-pointer"
              title="Open Queue Console to Preview & Download Reel"
            >
              <Film className="w-4 h-4" />
              <span>PREVIEW & EXPORT IN QUEUE</span>
            </button>
          </div>
        )}
      </div>

      {/* RIGHT: Master Controls Rack (5 cols) */}
      <div className="lg:col-span-5 sky-glass-panel text-white rounded-3xl p-6 relative space-y-4 shadow-xl">
        {/* Header */}
        <div className="border-b border-white/10 pb-2 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sliders className="w-4 h-4 text-[#bf8a00]" />
            <h3 className="font-black text-sm text-white uppercase tracking-wider">
              STUDIO CONTROLS
            </h3>
          </div>
          <span className={`px-2 py-0.5 rounded text-[10px] font-black uppercase ${
            isPro ? "bg-amber-400 text-black shadow" : "bg-[#b8ae9e] text-white"
          }`}>
            {isPro ? "PRO ACTIVE" : "FREE TIER"}
          </span>
        </div>

        {/* Motion Template Section */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-black text-white uppercase flex items-center gap-1.5">
              {isPro ? (
                <>
                  <Crown className="w-3.5 h-3.5 text-amber-400" />
                  <span>MOTION TEMPLATE (PRO UNLOCKED)</span>
                </>
              ) : (
                <>
                  <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                  <span>MOTION TEMPLATE (AUTO-ASSIGNED)</span>
                </>
              )}
            </span>
            <span className="text-xs font-bold text-[#ffc72c]">
              {currentTemplateObj.name} {currentTemplateObj.emoji}
            </span>
          </div>

          {!isPro ? (
            /* ================= FREE USER: AUTO-SELECTED TEMPLATE ONLY (MANUAL DISABLED) ================= */
            <div className="space-y-2">
              {/* Active Auto-Selected Template Banner */}
              <div className="p-3 rounded-2xl bg-gradient-to-r from-amber-500/20 via-[#ffc72c]/10 to-amber-500/20 border border-[#ffc72c]/50 shadow-inner flex items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-black/50 border border-amber-400/40 flex items-center justify-center text-xl shadow">
                    {currentTemplateObj.emoji}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-black text-sm text-white">{currentTemplateObj.name}</h4>
                      <span className="px-2 py-0.5 rounded-full bg-amber-400 text-[#241903] font-black text-[9px] uppercase tracking-wider shadow-sm">
                        AUTO-SELECTED
                      </span>
                    </div>
                    <p className="text-[11px] text-amber-100/80">{currentTemplateObj.subtitle}</p>
                  </div>
                </div>
                <div className="text-right shrink-0">
                  <span className="text-[10px] text-amber-300 font-bold block">Free Tier</span>
                  <span className="text-[9px] text-white/60 block">Changes each render</span>
                </div>
              </div>

              {/* Locked Manual Selector Box with Upgrade CTA */}
              <div className="relative rounded-2xl overflow-hidden border border-white/10 bg-black/40 p-2">
                {/* Non-clickable dimmed background grid */}
                <div className="grid grid-cols-2 gap-1.5 opacity-20 pointer-events-none select-none filter blur-[0.5px]">
                  {TEMPLATES.slice(0, 4).map((tmpl) => (
                    <div key={tmpl.id} className="p-2 rounded-xl bg-black/60 border border-white/10 text-white flex items-center gap-2">
                      <span className="text-sm">{tmpl.emoji}</span>
                      <span className="text-xs font-black truncate">{tmpl.name}</span>
                    </div>
                  ))}
                </div>

                {/* Frosted Lock Overlay */}
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/85 backdrop-blur-[2px] p-3 text-center">
                  <div className="flex items-center gap-1.5 text-amber-300 text-xs font-black mb-1">
                    <Lock className="w-3.5 h-3.5 text-amber-400" />
                    <span>MANUAL TEMPLATE SELECTION (PRO ONLY)</span>
                  </div>
                  <p className="text-[11px] text-amber-100/80 mb-2 max-w-[340px] font-medium leading-snug">
                    Free users get a different surprise template automatically chosen for each video. Upgrade to Pro to choose any template manually!
                  </p>
                  <button
                    type="button"
                    onClick={onOpenPricing}
                    className="btn-brass px-4 py-1.5 rounded-xl font-black text-xs text-[#2b2820] shadow-md hover:brightness-110 active:scale-95 transition flex items-center gap-1.5 cursor-pointer"
                  >
                    <Crown className="w-3.5 h-3.5 text-amber-800" />
                    <span>UNLOCK MANUAL TEMPLATES (COMING SOON) ❯</span>
                  </button>
                </div>
              </div>
            </div>
          ) : (
            /* ================= PRO USER: FULL INTERACTIVE 14 TEMPLATE GRID ================= */
            <div className="grid grid-cols-2 gap-2 max-h-[180px] overflow-y-auto p-1.5 rounded-2xl bg-black/40 border border-white/10 text-white">
              {TEMPLATES.map((tmpl) => {
                const isSelected = tmpl.id === selectedTemplate;
                return (
                  <div
                    key={tmpl.id}
                    onClick={() => setSelectedTemplate(tmpl.id)}
                    className={`p-2 rounded-xl border-2 transition cursor-pointer flex flex-col justify-between ${
                      isSelected
                        ? "bg-[#ffc72c]/20 border-[#ffc72c] shadow-md"
                        : "bg-black/50 text-white border-[#9e9688] hover:border-[#ffc72c]/50"
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-base">{tmpl.emoji}</span>
                      <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
                        PRO
                      </span>
                    </div>
                    <div>
                      <p className="font-black text-xs text-white truncate">{tmpl.name}</p>
                      <p className="text-[9px] text-amber-100/60 line-clamp-1">{tmpl.subtitle}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Frame Aspect Ratio Selector */}
        <div className="space-y-1">
          <span className="text-[11px] font-black text-amber-100/60 uppercase">
            FRAME PROPORTIONS
          </span>
          <div className="grid grid-cols-3 gap-2">
            {ASPECT_RATIOS.map((item) => (
              <button
                type="button"
                key={item.id}
                onClick={() => setAspectRatio(item.id)}
                className={`py-1.5 px-2 rounded-xl border-2 text-xs font-black transition flex items-center justify-center gap-1.5 ${
                  aspectRatio === item.id
                    ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                    : "bg-black/40 border border-white/10 text-white text-amber-100/70 hover:text-white"
                }`}
              >
                <span>{item.icon}</span>
                <span>{item.id}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Export Quality */}
        <div className="space-y-1 pt-1.5 border-t border-white/10">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black text-amber-100/60 uppercase">
              EXPORT QUALITY
            </span>
            {!isPro && (
              <span
                onClick={onOpenPricing}
                className="text-[10px] font-bold text-[#bf8a00] hover:underline cursor-pointer"
              >
                1080p requires Pro (Coming Soon) 👑
              </span>
            )}
          </div>
          <div className="grid grid-cols-2 gap-2">
            <button
              type="button"
              onClick={() => setQuality("fast")}
              className={`py-1.5 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center ${
                quality === "fast"
                  ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                  : "bg-black/40 border border-white/10 text-white text-amber-100/70 hover:text-white"
              }`}
            >
              <span>480p Standard</span>
              <span className="text-[9px] font-semibold text-amber-100/60">Free Tier</span>
            </button>

            <button
              type="button"
              onClick={() => {
                if (!isPro) onOpenPricing();
                else setQuality("master");
              }}
              className={`py-1.5 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center relative ${
                quality === "master"
                  ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                  : "bg-black/40 border border-white/10 text-white text-amber-100/70 hover:text-white"
              }`}
            >
              <div className="flex items-center gap-1">
                <span>1080p Master</span>
                {!isPro && <Crown className="w-3 h-3 text-[#bf8a00]" />}
              </div>
              <span className="text-[9px] font-semibold text-amber-100/60">Pro • Coming Soon</span>
            </button>
          </div>
        </div>

        {/* Watermark Status (No toggle - Informative status pill only) */}
        <div className="flex items-center justify-between p-2.5 rounded-2xl bg-black/40 border border-white/10 text-white gap-2">
          <div>
            <p className="text-xs font-black text-white">SNAPBEAT WATERMARK</p>
            <p className="text-[10px] text-amber-100/60">
              {isPro ? "Clean video output • No watermark" : "Free output includes watermark"}
            </p>
          </div>
          {isPro ? (
            <span className="px-2.5 py-1 rounded-full bg-[#00c853]/20 text-[#00c853] text-[10px] font-black uppercase tracking-wider border border-[#00c853]/40 shrink-0">
              WATERMARK: REMOVED
            </span>
          ) : (
            <div className="flex items-center gap-1.5 shrink-0">
              <span className="px-2 py-0.5 rounded-full bg-[#ffc72c]/30 text-[#4a3b00] text-[9px] font-black uppercase tracking-wider border border-[#bf8a00]/40">
                WATERMARK: APPLIED
              </span>
              <button
                type="button"
                onClick={onOpenPricing}
                className="px-2.5 py-1 rounded-full btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shadow hover:brightness-110 flex items-center gap-1 shrink-0 cursor-pointer"
              >
                <Crown className="w-2.5 h-2.5" />
                <span>REMOVE (PRO - SOON)</span>
              </button>
            </div>
          )}
        </div>

        {/* Opening Title Card (PRO-ONLY FEATURE) */}
        <div className="space-y-2 p-2.5 rounded-2xl bg-black/40 border border-white/10 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <Type className="w-3.5 h-3.5 text-[#bf8a00]" />
              <span className="text-xs font-black text-white uppercase">
                OPENING TITLE CARD
              </span>
              <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
                PRO
              </span>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={Boolean(titleCard?.enabled && isPro)}
                onChange={(e) => handleTitleToggle(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-9 h-5 bg-[#7a766f] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-[#ffc72c]"></div>
            </label>
          </div>

          {titleCard?.enabled && isPro && (
            <div className="space-y-2 pt-1">
              <input
                type="text"
                placeholder="Title text (e.g. Summer Memories)"
                value={titleCard.text}
                maxLength={40}
                onChange={(e) =>
                  setTitleCard((prev) => ({ ...prev, text: e.target.value }))
                }
                className="w-full px-3 py-1.5 rounded-xl bg-black/50 text-white border border-white/15 text-xs font-bold text-white placeholder-[#7a766f] focus:outline-none focus:border-[#2b2b2d]"
              />
              <input
                type="text"
                placeholder="Subtitle / Date (e.g. Tokyo • 2026)"
                value={titleCard.subtitle || ""}
                maxLength={40}
                onChange={(e) =>
                  setTitleCard((prev) => ({ ...prev, subtitle: e.target.value }))
                }
                className="w-full px-3 py-1.5 rounded-xl bg-black/50 text-white border border-white/15 text-xs font-bold text-white placeholder-[#7a766f] focus:outline-none focus:border-[#2b2b2d]"
              />
              <div className="grid grid-cols-2 gap-2">
                <select
                  value={titleCard.font}
                  onChange={(e) =>
                    setTitleCard((prev) => ({ ...prev, font: e.target.value }))
                  }
                  className="px-2 py-1 rounded-lg bg-black/50 text-white border border-white/15 text-[11px] font-bold text-white"
                >
                  {TITLE_FONTS.map((f) => (
                    <option key={f.id} value={f.id}>
                      {f.label}
                    </option>
                  ))}
                </select>
                <select
                  value={titleCard.duration}
                  onChange={(e) =>
                    setTitleCard((prev) => ({
                      ...prev,
                      duration: parseInt(e.target.value, 10),
                    }))
                  }
                  className="px-2 py-1 rounded-lg bg-black/50 text-white border border-white/15 text-[11px] font-bold text-white"
                >
                  <option value="2">2 seconds intro</option>
                  <option value="3">3 seconds intro</option>
                  <option value="4">4 seconds intro</option>
                </select>
              </div>
            </div>
          )}

          {!isPro && (
            <div className="pt-1.5 flex items-center justify-between border-t border-white/10/50">
              <p className="text-[10px] text-amber-100/60 font-semibold leading-tight">
                Cinematic intro cards unlock with any Pro Pass.
              </p>
              <button
                type="button"
                onClick={onOpenPricing}
                className="px-2.5 py-1 rounded-xl btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shrink-0 ml-2 shadow hover:brightness-110 cursor-pointer"
              >
                PRO (SOON)
              </button>
            </div>
          )}
        </div>

        {/* PRIMARY MECHANICAL RENDER BUTTON */}
        <div className="pt-2 flex flex-col items-center">
          {isRendering ? (
            <div className="w-full py-3.5 px-4 rounded-2xl bg-[#7a766f] text-white font-black text-xs uppercase flex items-center justify-center gap-2">
              <Loader2 className="w-4 h-4 animate-spin" />
              <span>PROCESSING IN QUEUE...</span>
            </div>
          ) : (
            <RetroMechanicalButton
              variant="render"
              disabled={!canRender}
              onClick={onRender}
              className="w-full"
              height="60px"
              title="Render Beat-Synced Reel"
            />
          )}

          {!canRender && !isRendering && (
            <p className="text-[10px] text-amber-100/60 font-bold text-center mt-2">
              Insert a track from Music tab and at least 2 photos to render
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
