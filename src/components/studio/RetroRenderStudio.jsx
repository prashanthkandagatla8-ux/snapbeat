"use client";

import { TEMPLATES, ASPECT_RATIOS, TITLE_FONTS } from "@/lib/constants";
import { Sparkles, Crown, Film, Download, Type, Sliders, Loader2 } from "lucide-react";

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

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
      {/* LEFT: Video Viewport & Monitor Console (7 cols) */}
      <div className="lg:col-span-7 metal-panel rounded-3xl p-6 relative flex flex-col items-center">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        {/* Top Header of Monitor */}
        <div className="w-full flex items-center justify-between border-b border-[#a89f90] pb-2 mb-4">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-[#ffc72c]" />
            <h3 className="font-black text-xs text-[#2b2b2d] uppercase tracking-wider">
              CRT MASTER REEL MONITOR
            </h3>
          </div>
          <span className="px-2 py-0.5 rounded bg-[#1e1c1a] text-amber-400 font-mono text-[10px] font-bold">
            FRAME: {aspectRatio} • {quality === "master" ? "1080P" : "720P"}
          </span>
        </div>

        {/* Video Viewport Stage */}
        <div
          className={`w-full ${
            aspectRatio === "1:1"
              ? "aspect-square max-w-[420px]"
              : aspectRatio === "16:9"
              ? "aspect-video max-w-[580px]"
              : "aspect-[9/16] max-w-[340px]"
          } rounded-2xl overflow-hidden relative shadow-2xl border-4 border-[#3a3734] bg-[#0d0c0b] flex items-center justify-center transition-all duration-300`}
        >
          {videoUrl ? (
            <video
              src={videoUrl}
              controls
              autoPlay
              loop
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="flex flex-col items-center justify-center text-center p-6 space-y-3 select-none">
              <div className="w-16 h-16 rounded-2xl bg-[#ffc72c]/15 border-2 border-[#ffc72c]/40 flex items-center justify-center text-[#ffc72c]">
                <Film className="w-8 h-8" />
              </div>
              <p className="font-black text-sm text-white uppercase tracking-wider">
                READY FOR RENDER
              </p>
              <p className="text-xs text-gray-400 max-w-[220px]">
                {renderMode === "auto"
                  ? "Auto Mode active: AI adapts cuts and transitions to the rhythm."
                  : `Template: ${currentTemplateObj.name}`}
              </p>
              {/* Retro VU Meter Simulation */}
              <div className="flex items-center gap-1 pt-2">
                {[30, 60, 45, 80, 50, 95, 70, 40].map((val, i) => (
                  <div
                    key={i}
                    className="w-1.5 bg-[#00c853] rounded-full animate-pulse"
                    style={{ height: `${val * 0.3}px`, animationDelay: `${i * 100}ms` }}
                  />
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Download Action Bar if ready */}
        {videoUrl && (
          <div className="mt-4 flex items-center gap-3">
            <a
              href={videoUrl}
              download="SnapBeat_Reel.mp4"
              className="btn-brass px-6 py-3 rounded-2xl font-black text-xs flex items-center gap-2 shadow-lg"
            >
              <Download className="w-4 h-4 stroke-[3]" />
              <span>SAVE & DOWNLOAD REEL (MP4)</span>
            </a>
          </div>
        )}
      </div>

      {/* RIGHT: Master Controls Rack (5 cols) */}
      <div className="lg:col-span-5 metal-panel rounded-3xl p-6 relative space-y-5">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        {/* Header */}
        <div className="border-b border-[#a89f90] pb-2 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sliders className="w-4 h-4 text-[#bf8a00]" />
            <h3 className="font-black text-sm text-[#2b2b2d] uppercase tracking-wider">
              {renderMode === "auto" ? "AUTO CHOREOGRAPHY" : "PRO MASTER CONTROLS"}
            </h3>
          </div>
          <span className="px-2 py-0.5 rounded bg-[#b8ae9e] text-[#2b2b2d] font-black text-[10px]">
            {renderMode.toUpperCase()}
          </span>
        </div>

        {/* PRO CONTROLS: Template Selection Grid */}
        {renderMode === "pro" && (
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs font-black text-[#2b2b2d] uppercase">
                MOTION TEMPLATE
              </span>
              <span className="text-xs font-bold text-[#bf8a00]">
                {currentTemplateObj.name}
              </span>
            </div>

            <div className="grid grid-cols-2 gap-2 max-h-[220px] overflow-y-auto p-1.5 rounded-2xl metal-inset">
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
                    className={`p-2.5 rounded-xl border-2 transition cursor-pointer flex flex-col justify-between ${
                      isSelected
                        ? "bg-[#ffc72c]/20 border-[#ffc72c] shadow-md"
                        : "bg-[#d4cdc0] border-[#9e9688] hover:border-[#2b2b2d]"
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-lg">{tmpl.emoji}</span>
                      {tmpl.isPro && (
                        <span className="px-1.5 py-0.5 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
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
        )}

        {/* Aspect Ratio Selector */}
        <div className="space-y-1.5">
          <span className="text-[11px] font-black text-[#5a5752] uppercase">
            FRAME PROPORTIONS
          </span>
          <div className="grid grid-cols-3 gap-2">
            {ASPECT_RATIOS.map((item) => (
              <button
                key={item.id}
                onClick={() => setAspectRatio(item.id)}
                className={`py-2 px-2.5 rounded-xl border-2 text-xs font-black transition flex items-center justify-center gap-1.5 ${
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

        {/* Export Quality (720p vs 1080p) */}
        <div className="space-y-1.5 pt-2 border-t border-[#a89f90]">
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
              className={`py-2 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center ${
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
              className={`py-2 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center relative ${
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
        <div className="flex items-center justify-between p-3 rounded-2xl metal-inset">
          <div>
            <p className="text-xs font-black text-[#2b2b2d]">SNAPBEAT WATERMARK</p>
            <p className="text-[10px] text-[#5a5752]">
              {isPro ? "Removed on your exports" : "Upgrade to Pro to remove"}
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

        {/* Opening Title Card (Pro) */}
        {renderMode === "pro" && (
          <div className="space-y-2 p-3 rounded-2xl metal-inset">
            <div className="flex items-center justify-between">
              <span className="flex items-center gap-1.5 text-xs font-black text-[#2b2b2d]">
                <Type className="w-3.5 h-3.5 text-[#bf8a00]" />
                OPENING TITLE CARD
              </span>
              <input
                type="checkbox"
                checked={titleCard.enabled}
                onChange={(e) =>
                  setTitleCard((prev) => ({ ...prev, enabled: e.target.checked }))
                }
                className="rounded accent-[#ffc72c]"
              />
            </div>

            {titleCard.enabled && (
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
                    <option value="2">2 seconds</option>
                    <option value="3">3 seconds</option>
                  </select>
                </div>
              </div>
            )}
          </div>
        )}

        {/* GIANT 3D MASTER RED LACQUER BUTTON */}
        <div className="pt-2">
          <button
            onClick={onRender}
            disabled={!canRender || isRendering}
            className={`w-full py-4 px-6 rounded-2xl font-black text-sm tracking-wider flex items-center justify-center gap-2.5 transition-all shadow-xl ${
              canRender && !isRendering
                ? "btn-red-lacquer cursor-pointer hover:scale-[1.02] active:scale-[0.98]"
                : "bg-[#7a766f] text-[#3a3835] cursor-not-allowed opacity-60 border-2 border-[#5a5752]"
            }`}
          >
            {isRendering ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" />
                <span>RENDERING IN QUEUE...</span>
              </>
            ) : (
              <>
                <Sparkles className="w-5 h-5 fill-current" />
                <span>
                  {renderMode === "auto" ? "START AUTO RENDER" : "RENDER MASTER REEL"}
                </span>
              </>
            )}
          </button>
          {!canRender && !isRendering && (
            <p className="text-[10px] text-[#5a5752] font-bold text-center mt-2">
              Select music from Music tab and at least 2 photos from Photos tab
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
