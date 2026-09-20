"use client";

import { useState, useRef, useEffect } from "react";
import { TEMPLATES } from "@/lib/constants";
import { Sparkles, Crown, Lock, Volume2, VolumeX, Maximize2, Play, Pause, X } from "lucide-react";

export function TemplateGrid({ selectedTemplate, onSelectTemplate, isPro, onOpenPricing }) {
  const currentTemplateObj = TEMPLATES.find((t) => t.id === selectedTemplate) || TEMPLATES[0];

  // Active template being previewed in the CRT viewfinder (defaults to selected)
  const [previewId, setPreviewId] = useState(selectedTemplate || "pendulum");
  const [isMuted, setIsMuted] = useState(true);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isExpanded, setIsExpanded] = useState(false);
  const videoRef = useRef(null);

  // Sync preview when selectedTemplate prop changes
  useEffect(() => {
    if (selectedTemplate) {
      setPreviewId(selectedTemplate);
    }
  }, [selectedTemplate]);

  const activePreviewObj = TEMPLATES.find((t) => t.id === previewId) || currentTemplateObj;

  const handleTogglePlay = (e) => {
    e?.stopPropagation();
    if (!videoRef.current) return;
    if (videoRef.current.paused) {
      videoRef.current.play().catch(() => {});
      setIsPlaying(true);
    } else {
      videoRef.current.pause();
      setIsPlaying(false);
    }
  };

  const handleToggleMute = (e) => {
    e?.stopPropagation();
    if (!videoRef.current) return;
    videoRef.current.muted = !videoRef.current.muted;
    setIsMuted(videoRef.current.muted);
  };

  const handleTemplateClick = (tmpl) => {
    setPreviewId(tmpl.id);
    onSelectTemplate(tmpl.id);
  };

  return (
    <div className="space-y-3 select-none text-white">
      {/* SECTION TITLE & STATUS */}
      <div className="flex items-center justify-between">
        <span className="font-black text-xs uppercase tracking-wider flex items-center gap-1.5 text-white">
          {isPro ? (
            <>
              <Crown className="w-3.5 h-3.5 text-amber-400" />
              <span>MOTION TEMPLATES ({TEMPLATES.length})</span>
            </>
          ) : (
            <>
              <Sparkles className="w-3.5 h-3.5 text-amber-400" />
              <span>MOTION TEMPLATE (AUTO-ASSIGNED)</span>
            </>
          )}
        </span>
        <span className="text-xs font-bold text-amber-300">
          {currentTemplateObj.name} {currentTemplateObj.emoji}
        </span>
      </div>

      {/* RETRO CRT MOTION VIEWFINDER SCREEN */}
      <div className="relative rounded-2xl overflow-hidden bg-[#071318] border-2 border-amber-400/40 shadow-xl group">
        {/* Subtle scanline overlay */}
        <div className="absolute inset-0 pointer-events-none opacity-20 bg-[repeating-linear-gradient(0deg,#000,#000_2px,transparent_2px,transparent_4px)] z-10" />
        <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,_transparent_50%,_rgba(0,0,0,0.8)_100%)] z-10" />

        {/* Top Viewfinder HUD Header */}
        <div className="absolute top-2 inset-x-2 flex items-center justify-between z-20 px-1">
          <div className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-black/70 backdrop-blur-sm border border-amber-400/40 text-[9px] font-mono text-amber-300 font-bold">
            <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse" />
            <span>PREVIEW: {activePreviewObj.name.toUpperCase()}</span>
          </div>

          <div className="flex items-center gap-1.5">
            {/* Audio Toggle */}
            <button
              type="button"
              onClick={handleToggleMute}
              className="p-1 rounded-full bg-black/70 hover:bg-black/90 text-white/80 hover:text-white border border-white/20 transition cursor-pointer"
              title={isMuted ? "Unmute audio preview" : "Mute preview"}
            >
              {isMuted ? <VolumeX className="w-3 h-3 text-amber-300" /> : <Volume2 className="w-3 h-3 text-emerald-400" />}
            </button>

            {/* Expand Modal */}
            <button
              type="button"
              onClick={() => setIsExpanded(true)}
              className="p-1 rounded-full bg-black/70 hover:bg-black/90 text-white/80 hover:text-white border border-white/20 transition cursor-pointer"
              title="Expand preview"
            >
              <Maximize2 className="w-3 h-3" />
            </button>
          </div>
        </div>

        {/* Video Player in Native 9:16 Reel Proportion */}
        <div className="relative aspect-[9/16] w-full max-w-[240px] mx-auto bg-black flex items-center justify-center overflow-hidden cursor-pointer rounded-xl my-1" onClick={handleTogglePlay}>
          <video
            ref={videoRef}
            key={previewId}
            src={`/assets/previews/${previewId}.mp4`}
            poster={`/assets/previews/${previewId}.jpg`}
            autoPlay
            loop
            muted={isMuted}
            playsInline
            className="w-full h-full object-cover"
          />

          {/* Play/Pause Overlay indicator on hover or pause */}
          {!isPlaying && (
            <div className="absolute inset-0 flex items-center justify-center bg-black/40 z-10">
              <div className="w-10 h-10 rounded-full bg-black/80 border border-white/40 text-white flex items-center justify-center shadow">
                <Play className="w-4 h-4 fill-white ml-0.5" />
              </div>
            </div>
          )}
        </div>

        {/* Bottom Viewfinder HUD Footer */}
        <div className="p-2.5 bg-[#0a1b22]/95 border-t border-amber-400/20 flex items-center justify-between gap-2 z-20 text-[10px]">
          <div className="min-w-0">
            <p className="font-black text-white text-xs truncate flex items-center gap-1.5">
              <span>{activePreviewObj.emoji}</span>
              <span>{activePreviewObj.name}</span>
              {activePreviewObj.isPro && (
                <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#241903]">
                  PRO
                </span>
              )}
            </p>
            <p className="text-amber-100/70 truncate text-[10px]">{activePreviewObj.subtitle}</p>
          </div>

          <div className="shrink-0 flex items-center gap-1.5">
            {!isPro && (
              <button
                type="button"
                onClick={onOpenPricing}
                className="btn-brass px-2.5 py-1 rounded-xl text-black font-black text-[9px] uppercase tracking-wide shadow hover:brightness-110 active:scale-95 transition cursor-pointer"
              >
                UNLOCK PRO
              </button>
            )}
            {isPro && previewId !== selectedTemplate && (
              <button
                type="button"
                onClick={() => onSelectTemplate(previewId)}
                className="btn-gold-radiant px-2.5 py-1 rounded-xl text-black font-black text-[9px] uppercase tracking-wide shadow hover:scale-105 active:scale-95 transition cursor-pointer"
              >
                SELECT STYLE
              </button>
            )}
          </div>
        </div>
      </div>

      {/* TEMPLATE GRID / SELECTOR TRAY */}
      {false ? (
        /* Free Tier: Active Auto-Selected Card + 14-Template Preview Carousel */
        <div className="space-y-2">
          {/* 14 Motion Styles Preview Strip (Free users can preview all 14!) */}
          <div className="space-y-1">
            <div className="flex items-center justify-between text-[10px] text-amber-200/70">
              <span className="font-bold uppercase tracking-wider">Tap any style to preview motion</span>
              <span className="text-[9px] font-mono">14 PRESETS</span>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-1.5 max-h-[140px] overflow-y-auto p-1.5 rounded-2xl bg-black/40 border border-white/10">
              {TEMPLATES.map((tmpl) => {
                const isCurrentPreview = tmpl.id === previewId;
                const isCurrentAuto = tmpl.id === selectedTemplate;
                return (
                  <button
                    key={tmpl.id}
                    type="button"
                    onClick={() => handleTemplateClick(tmpl)}
                    className={`p-2 rounded-xl text-left transition border flex items-center justify-between gap-1.5 cursor-pointer ${
                      isCurrentPreview
                        ? "bg-amber-400/25 border-amber-400 text-white shadow"
                        : "bg-black/50 border-white/10 hover:border-white/20 text-white/80"
                    }`}
                  >
                    <div className="min-w-0">
                      <p className="font-black text-xs truncate flex items-center gap-1">
                        <span>{tmpl.emoji}</span>
                        <span className="truncate">{tmpl.name}</span>
                      </p>
                    </div>
                    {isCurrentAuto ? (
                      <span className="px-1 py-0.2 rounded text-[7px] font-black bg-emerald-500 text-black shrink-0">
                        ACTIVE
                      </span>
                    ) : (
                      <Lock className="w-2.5 h-2.5 text-amber-400/70 shrink-0" />
                    )}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Locked Manual Selection Notice */}
          <div className="p-2.5 rounded-2xl bg-black/40 border border-amber-400/30 flex items-center justify-between gap-2 text-white">
            <div className="min-w-0">
              <p className="font-black text-[11px] text-amber-300">Free reels rotate styles automatically</p>
              <p className="text-[10px] text-amber-100/70 truncate">Upgrade to Pro to fix your preferred template manually</p>
            </div>
            <button
              type="button"
              onClick={onOpenPricing}
              className="btn-gold-radiant px-3 py-1.5 rounded-xl text-black font-black text-[10px] uppercase shrink-0 hover:scale-105 active:scale-95 transition cursor-pointer"
            >
              PRO PASS
            </button>
          </div>
        </div>
      ) : (
        /* Pro Tier: Full 14-template interactive selector grid */
        <div className="grid grid-cols-2 gap-2 max-h-[190px] overflow-y-auto p-1.5 rounded-2xl bg-black/40 border border-white/10">
          {TEMPLATES.map((tmpl) => {
            const isSelected = tmpl.id === selectedTemplate;
            const isPreviewing = tmpl.id === previewId;
            return (
              <div
                key={tmpl.id}
                role="button"
                tabIndex={0}
                aria-selected={isSelected}
                onClick={() => handleTemplateClick(tmpl)}
                className={`p-2.5 rounded-xl border-2 transition cursor-pointer flex flex-col justify-between ${
                  isSelected
                    ? "bg-[#ffc72c]/20 border-[#ffc72c] shadow-md text-white"
                    : isPreviewing
                    ? "bg-amber-500/10 border-amber-400/50 text-white"
                    : "bg-black/50 border-white/10 hover:border-amber-400/40 text-white"
                }`}
              >
                <div className="flex items-center justify-between mb-1">
                  <span className="text-lg">{tmpl.emoji}</span>
                  <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#241903]">
                    {isSelected ? "SELECTED" : "PRO"}
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

      {/* EXPANDED 9:16 PREVIEW MODAL */}
      {isExpanded && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fadeIn"
          onClick={() => setIsExpanded(false)}
        >
          <div
            className="relative w-full max-w-[380px] bg-[#07171c] rounded-3xl border-2 border-amber-400/50 shadow-2xl p-4 flex flex-col items-center space-y-3"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="w-full flex items-center justify-between pb-2 border-b border-white/15">
              <span className="font-mono text-xs font-black text-amber-300 uppercase flex items-center gap-1.5">
                <span>{activePreviewObj.emoji}</span>
                <span>{activePreviewObj.name} PREVIEW (9:16)</span>
              </span>
              <button
                type="button"
                onClick={() => setIsExpanded(false)}
                className="w-7 h-7 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="relative aspect-[9/16] w-full rounded-2xl overflow-hidden bg-black border border-white/20">
              <video
                src={`/assets/previews/${activePreviewObj.id}.mp4`}
                poster={`/assets/previews/${activePreviewObj.id}.jpg`}
                autoPlay
                loop
                playsInline
                className="w-full h-full object-cover"
              />
            </div>

            <div className="w-full flex items-center justify-between gap-2 pt-1">
              <div className="min-w-0">
                <p className="font-black text-xs text-white truncate">{activePreviewObj.name}</p>
                <p className="text-[10px] text-amber-100/70 truncate">{activePreviewObj.subtitle}</p>
              </div>

              {isPro ? (
                <button
                  type="button"
                  onClick={() => {
                    onSelectTemplate(activePreviewObj.id);
                    setIsExpanded(false);
                  }}
                  className="btn-gold-radiant px-4 py-2 rounded-xl text-black font-black text-xs uppercase tracking-wider shadow hover:scale-105 active:scale-95 transition cursor-pointer"
                >
                  USE TEMPLATE
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => {
                    setIsExpanded(false);
                    onOpenPricing?.();
                  }}
                  className="btn-brass px-4 py-2 rounded-xl text-black font-black text-xs uppercase tracking-wider shadow hover:brightness-110 active:scale-95 transition cursor-pointer"
                >
                  UNLOCK PRO
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default TemplateGrid;
