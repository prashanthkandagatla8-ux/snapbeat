"use client";

import React, { useState } from "react";
import { TEMPLATES, ASPECT_RATIOS, TITLE_FONTS } from "@/lib/constants";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";
import { Sparkles, Crown, Film, Download, Type, Sliders, Loader2, Play, Eye } from "lucide-react";

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
}) {
  const currentTemplateObj = TEMPLATES.find((t) => t.id === selectedTemplate) || TEMPLATES[0];
  const [monitorMode, setMonitorMode] = useState("title"); // 'title' | 'video'

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
      <div className="lg:col-span-7 metal-panel rounded-3xl p-6 relative flex flex-col items-center shadow-xl">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        {/* Top Header of Monitor */}
        <div className="w-full flex items-center justify-between border-b border-[#a89f90] pb-2 mb-4">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse" />
            <h3 className="font-black text-xs text-[#2b2b2d] uppercase tracking-wider">
              {videoUrl && monitorMode === "video" ? "FINAL REEL PLAYBACK" : "TITLE CARD PREVIEW MONITOR"}
            </h3>
          </div>

          <div className="flex items-center gap-2">
            {videoUrl && (
              <div className="flex items-center bg-[#b8ae9e] rounded-lg p-0.5 border border-[#8f8677]">
                <button
                  onClick={() => setMonitorMode("title")}
                  className={`px-2 py-0.5 rounded text-[9px] font-black transition ${
                    monitorMode === "title" ? "bg-[#ffc72c] text-[#2b2820]" : "text-[#4a4743]"
                  }`}
                >
                  TITLE INTRO
                </button>
                <button
                  onClick={() => setMonitorMode("video")}
                  className={`px-2 py-0.5 rounded text-[9px] font-black transition ${
                    monitorMode === "video" ? "bg-[#ffc72c] text-[#2b2820]" : "text-[#4a4743]"
                  }`}
                >
                  VIDEO
                </button>
              </div>
            )}
            <span className="px-2 py-0.5 rounded bg-[#1e1c1a] text-amber-400 font-mono text-[10px] font-bold">
              FRAME: {aspectRatio} • {quality === "master" ? "1080P" : "720P"}
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
          {videoUrl && monitorMode === "video" ? (
            <video
              src={videoUrl}
              controls
              autoPlay
              loop
              className="w-full h-full object-cover"
            />
          ) : (
            /* Live Title Card Preview */
            <div className="w-full h-full relative flex flex-col items-center justify-between p-6 bg-gradient-to-b from-[#18181b] via-[#09090b] to-[#18181b] text-center select-none overflow-hidden">
              {/* Scanlines and Vignette Effect */}
              <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,_transparent_40%,_rgba(0,0,0,0.85)_100%)] z-10" />
              <div className="absolute inset-0 pointer-events-none opacity-20 bg-[repeating-linear-gradient(0deg,#000,#000_2px,transparent_2px,transparent_4px)] z-10" />

              {/* Top Letterbox Bar */}
              <div className="w-full z-20 flex items-center justify-between text-[9px] font-mono text-amber-400/70 border-b border-amber-400/20 pb-1">
                <span>INT. OPENING • SCENE 1</span>
                <span>00:00 - 00:0{titleCard.duration || 3}</span>
              </div>

              {/* Center Content: Title Card Typography */}
              <div className="z-20 my-auto space-y-3 px-2">
                {titleCard.enabled ? (
                  <>
                    <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-amber-400/10 border border-amber-400/30 text-amber-300 text-[10px] font-black uppercase tracking-widest">
                      <Sparkles className="w-3 h-3 text-amber-400" />
                      <span>OPENING TITLE</span>
                    </div>

                    <h2
                      className={`text-2xl sm:text-3xl font-black uppercase tracking-wider text-transparent bg-clip-text bg-gradient-to-b from-white via-amber-100 to-amber-400 drop-shadow-[0_4px_12px_rgba(251,191,36,0.4)] ${
                        titleCard.font === "retro"
                          ? "font-mono"
                          : titleCard.font === "serif"
                          ? "font-serif"
                          : "font-sans"
                      }`}
                    >
                      {titleCard.text.trim() || "YOUR REEL TITLE"}
                    </h2>

                    <p className="text-[11px] font-mono font-bold tracking-widest text-amber-400/80 uppercase">
                      {titleCard.subtitle?.trim() || "A SNAPBEAT PRODUCTION • 2026"}
                    </p>

                    <div className="w-16 h-0.5 bg-gradient-to-r from-transparent via-amber-400 to-transparent mx-auto mt-2" />
                  </>
                ) : (
                  <div className="space-y-3 p-4">
                    <div className="w-12 h-12 rounded-2xl metal-inset flex items-center justify-center mx-auto text-[#8f8677]">
                      <Type className="w-6 h-6" />
                    </div>
                    <p className="text-xs font-black text-gray-300 uppercase tracking-wider">
                      TITLE CARD DISABLED
                    </p>
                    <p className="text-[11px] text-gray-500 max-w-[200px] mx-auto leading-relaxed">
                      {isPro
                        ? "Toggle 'OPENING TITLE CARD' under Pro Controls to customize this intro."
                        : "Opening Title Cards are an exclusive Pro feature. Upgrade to Pro to customize."}
                    </p>
                    {!isPro && (
                      <button
                        onClick={onOpenPricing}
                        className="px-3 py-1.5 rounded-xl btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shadow"
                      >
                        UNLOCK WITH PRO
                      </button>
                    )}
                  </div>
                )}
              </div>

              {/* Bottom Letterbox Bar */}
              <div className="w-full z-20 flex items-center justify-between text-[9px] font-mono text-gray-500 border-t border-white/10 pt-1">
                <span>SNAPBEAT CHOREO</span>
                <span>{currentTemplateObj.name.toUpperCase()}</span>
              </div>
            </div>
          )}
        </div>

        {/* Download Action Bar if video is rendered */}
        {videoUrl && (
          <div className="mt-4 flex items-center gap-3">
            <a
              href={videoUrl}
              download="SnapBeat_Reel.mp4"
              className="inline-flex items-center gap-2"
            >
              <RetroMechanicalButton variant="download" height="46px" />
            </a>
          </div>
        )}
      </div>

      {/* RIGHT: Master Controls Rack (5 cols) */}
      <div className="lg:col-span-5 metal-panel rounded-3xl p-6 relative space-y-4 shadow-xl">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        {/* Header */}
        <div className="border-b border-[#a89f90] pb-2 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sliders className="w-4 h-4 text-[#bf8a00]" />
            <h3 className="font-black text-sm text-[#2b2b2d] uppercase tracking-wider">
              STUDIO CONTROLS
            </h3>
          </div>
          <span className={`px-2 py-0.5 rounded text-[10px] font-black uppercase ${
            isPro ? "bg-amber-400 text-black shadow" : "bg-[#b8ae9e] text-[#2b2b2d]"
          }`}>
            {isPro ? "PRO ACTIVE" : "FREE TIER"}
          </span>
        </div>

        {/* Motion Template Grid */}
        <div className="space-y-1.5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-black text-[#2b2b2d] uppercase">
              MOTION TEMPLATE
            </span>
            <span className="text-xs font-bold text-[#bf8a00]">
              {currentTemplateObj.name}
            </span>
          </div>

          <div className="grid grid-cols-2 gap-2 max-h-[180px] overflow-y-auto p-1.5 rounded-2xl metal-inset">
            {TEMPLATES.map((tmpl) => {
              const isSelected = tmpl.id === selectedTemplate;
              const isLocked = tmpl.isPro && !isPro;

              return (
                <div
                  key={tmpl.id}
                  onClick={() => {
                    if (isLocked) onOpenPricing();
                    else setSelectedTemplate(tmpl.id);
                  }}
                  className={`p-2 rounded-xl border-2 transition cursor-pointer flex flex-col justify-between ${
                    isSelected
                      ? "bg-[#ffc72c]/20 border-[#ffc72c] shadow-md"
                      : "bg-[#d4cdc0] border-[#9e9688] hover:border-[#2b2b2d]"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-base">{tmpl.emoji}</span>
                    {tmpl.isPro && (
                      <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
                        PRO
                      </span>
                    )}
                  </div>
                  <div>
                    <p className="font-black text-xs text-[#2b2b2d] truncate">{tmpl.name}</p>
                    <p className="text-[9px] text-[#5a5752] line-clamp-1">{tmpl.subtitle}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Frame Aspect Ratio Selector */}
        <div className="space-y-1">
          <span className="text-[11px] font-black text-[#5a5752] uppercase">
            FRAME PROPORTIONS
          </span>
          <div className="grid grid-cols-3 gap-2">
            {ASPECT_RATIOS.map((item) => (
              <button
                key={item.id}
                onClick={() => setAspectRatio(item.id)}
                className={`py-1.5 px-2 rounded-xl border-2 text-xs font-black transition flex items-center justify-center gap-1.5 ${
                  aspectRatio === item.id
                    ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                    : "metal-inset text-[#4a4743] hover:text-[#2b2b2d]"
                }`}
              >
                <span>{item.icon}</span>
                <span>{item.id}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Export Quality */}
        <div className="space-y-1 pt-1.5 border-t border-[#a89f90]">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black text-[#5a5752] uppercase">
              EXPORT QUALITY
            </span>
            {!isPro && (
              <span
                onClick={onOpenPricing}
                className="text-[10px] font-bold text-[#bf8a00] hover:underline cursor-pointer"
              >
                1080p requires Pro 👑
              </span>
            )}
          </div>
          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => setQuality("fast")}
              className={`py-1.5 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center ${
                quality === "fast"
                  ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                  : "metal-inset text-[#4a4743] hover:text-[#2b2b2d]"
              }`}
            >
              <span>720p Fast HD</span>
              <span className="text-[9px] font-semibold text-[#5a5752]">Free Standard</span>
            </button>

            <button
              onClick={() => {
                if (!isPro) onOpenPricing();
                else setQuality("master");
              }}
              className={`py-1.5 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center relative ${
                quality === "master"
                  ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                  : "metal-inset text-[#4a4743] hover:text-[#2b2b2d]"
              }`}
            >
              <div className="flex items-center gap-1">
                <span>1080p Master</span>
                {!isPro && <Crown className="w-3 h-3 text-[#bf8a00]" />}
              </div>
              <span className="text-[9px] font-semibold text-[#5a5752]">Studio Crisp</span>
            </button>
          </div>
        </div>

        {/* Watermark Toggle */}
        <div className="flex items-center justify-between p-2.5 rounded-2xl metal-inset">
          <div>
            <p className="text-xs font-black text-[#2b2b2d]">SNAPBEAT WATERMARK</p>
            <p className="text-[10px] text-[#5a5752]">
              {isPro ? "No watermark on Pro exports" : "Upgrade to Pro to remove"}
            </p>
          </div>
          <label className="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              checked={watermark}
              disabled={!isPro}
              onChange={(e) => {
                if (isPro) setWatermark(e.target.checked);
                else onOpenPricing();
              }}
              className="sr-only peer"
            />
            <div className="w-10 h-5 bg-[#7a766f] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-[#d62828]"></div>
          </label>
        </div>

        {/* Opening Title Card (PRO FEATURE) */}
        <div className="space-y-2 p-2.5 rounded-2xl metal-inset">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5">
              <Type className="w-3.5 h-3.5 text-[#bf8a00]" />
              <span className="text-xs font-black text-[#2b2b2d] uppercase">
                OPENING TITLE CARD
              </span>
              <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
                PRO
              </span>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={titleCard.enabled}
                onChange={(e) => handleTitleToggle(e.target.checked)}
                className="sr-only peer"
              />
              <div className="w-9 h-5 bg-[#7a766f] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-[#ffc72c]"></div>
            </label>
          </div>

          {titleCard.enabled && isPro && (
            <div className="space-y-2 pt-1">
              <input
                type="text"
                placeholder="Title text (e.g. Summer Memories)"
                value={titleCard.text}
                maxLength={40}
                onChange={(e) =>
                  setTitleCard((prev) => ({ ...prev, text: e.target.value }))
                }
                className="w-full px-3 py-1.5 rounded-xl bg-[#d4cdc0] border border-[#8f8677] text-xs font-bold text-[#2b2b2d] placeholder-[#7a766f] focus:outline-none focus:border-[#2b2b2d]"
              />
              <input
                type="text"
                placeholder="Subtitle / Date (e.g. Tokyo • 2026)"
                value={titleCard.subtitle || ""}
                maxLength={40}
                onChange={(e) =>
                  setTitleCard((prev) => ({ ...prev, subtitle: e.target.value }))
                }
                className="w-full px-3 py-1.5 rounded-xl bg-[#d4cdc0] border border-[#8f8677] text-xs font-bold text-[#2b2b2d] placeholder-[#7a766f] focus:outline-none focus:border-[#2b2b2d]"
              />
              <div className="grid grid-cols-2 gap-2">
                <select
                  value={titleCard.font}
                  onChange={(e) =>
                    setTitleCard((prev) => ({ ...prev, font: e.target.value }))
                  }
                  className="px-2 py-1 rounded-lg bg-[#d4cdc0] border border-[#8f8677] text-[11px] font-bold text-[#2b2b2d]"
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
                  className="px-2 py-1 rounded-lg bg-[#d4cdc0] border border-[#8f8677] text-[11px] font-bold text-[#2b2b2d]"
                >
                  <option value="2">2 seconds intro</option>
                  <option value="3">3 seconds intro</option>
                </select>
              </div>
            </div>
          )}

          {!isPro && (
            <p className="text-[10px] text-[#5a5752] font-semibold">
              Add a cinematic intro title to your video reel. Unlocks with any Pro Pass.
            </p>
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
            <p className="text-[10px] text-[#5a5752] font-bold text-center mt-2">
              Insert a track from Music tab and at least 2 photos to render
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
