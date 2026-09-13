"use client";

import { TemplateGrid } from "@/components/templates/TemplateGrid";
import { AspectRatioPicker } from "@/components/controls/AspectRatioPicker";
import { QualitySelector } from "@/components/controls/QualitySelector";
import { TitleCardEditor } from "@/components/controls/TitleCardEditor";
import { Sparkles, Loader2 } from "lucide-react";

export function RightPanel({
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
}) {
  return (
    <div className="rounded-2xl bg-[#151922] border border-[#242b38] p-4 flex flex-col justify-between h-full shadow-sm space-y-4">
      <div className="space-y-4 overflow-y-auto pr-1">
        <TemplateGrid
          selectedTemplate={selectedTemplate}
          onSelectTemplate={setSelectedTemplate}
          isPro={isPro}
          onOpenPricing={onOpenPricing}
        />

        <AspectRatioPicker
          aspectRatio={aspectRatio}
          setAspectRatio={setAspectRatio}
        />

        <QualitySelector
          quality={quality}
          setQuality={setQuality}
          watermark={watermark}
          setWatermark={setWatermark}
          isPro={isPro}
          onOpenPricing={onOpenPricing}
        />

        <TitleCardEditor
          titleCard={titleCard}
          setTitleCard={setTitleCard}
        />
      </div>

      {/* Main Big Render CTA */}
      <div className="pt-2">
        <button
          onClick={onRender}
          disabled={!canRender || isRendering}
          className={`w-full py-3.5 px-4 rounded-xl font-black text-sm tracking-wide flex items-center justify-center gap-2 shadow-lg transition-all transform ${
            canRender && !isRendering
              ? "bg-gradient-to-r from-amber-500 via-amber-400 to-yellow-400 hover:from-amber-400 hover:to-yellow-300 text-black shadow-amber-500/25 hover:scale-[1.02] active:scale-[0.98]"
              : "bg-[#202736] text-gray-500 cursor-not-allowed border border-[#2d3748]"
          }`}
        >
          {isRendering ? (
            <>
              <Loader2 className="w-4 h-4 animate-spin" />
              <span>PROCESSING REEL...</span>
            </>
          ) : (
            <>
              <Sparkles className="w-4 h-4 fill-current" />
              <span>RENDER REEL {isPro ? "(PRO PRIORITY)" : "(FREE QUEUE)"}</span>
            </>
          )}
        </button>
        {!canRender && !isRendering && (
          <p className="text-[10px] text-gray-500 text-center mt-1.5">
            Add an audio track and at least 2 photos to render
          </p>
        )}
      </div>
    </div>
  );
}
