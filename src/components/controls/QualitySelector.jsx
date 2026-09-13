"use client";

import { Crown, Sparkles } from "lucide-react";

export function QualitySelector({ quality, setQuality, watermark, setWatermark, isPro, onOpenPricing }) {
  return (
    <div className="space-y-3 pt-2 border-t border-[#242b38]/60">
      {/* Quality Picker */}
      <div className="space-y-1.5">
        <div className="flex items-center justify-between">
          <span className="text-[11px] font-bold text-gray-400 uppercase tracking-wider">
            Export Quality
          </span>
          {!isPro && (
            <span className="text-[10px] text-amber-400 font-semibold cursor-pointer" onClick={onOpenPricing}>
              1080p requires Pro
            </span>
          )}
        </div>
        <div className="grid grid-cols-2 gap-2">
          <button
            onClick={() => setQuality("fast")}
            className={`py-2 px-3 rounded-xl border text-xs font-bold transition flex flex-col items-center justify-center ${
              quality === "fast"
                ? "bg-amber-500/20 border-amber-400 text-amber-300"
                : "bg-[#1a202c]/60 border-[#2d3748] text-gray-400 hover:text-white"
            }`}
          >
            <span>720p HD</span>
            <span className="text-[9px] font-normal text-gray-400">Fast Render</span>
          </button>

          <button
            onClick={() => {
              if (!isPro) {
                onOpenPricing();
              } else {
                setQuality("master");
              }
            }}
            className={`py-2 px-3 rounded-xl border text-xs font-bold transition flex flex-col items-center justify-center relative ${
              quality === "master"
                ? "bg-amber-500/20 border-amber-400 text-amber-300"
                : "bg-[#1a202c]/60 border-[#2d3748] text-gray-400 hover:text-white"
            }`}
          >
            <div className="flex items-center gap-1">
              <span>1080p Master</span>
              {!isPro && <Crown className="w-3 h-3 text-amber-400" />}
            </div>
            <span className="text-[9px] font-normal text-gray-400">Crisp Quality</span>
          </button>
        </div>
      </div>

      {/* Watermark Toggle */}
      <div className="flex items-center justify-between p-2.5 rounded-xl bg-[#1a202c]/60 border border-[#2d3748]/60">
        <div>
          <p className="text-xs font-bold text-white">SnapBeat Watermark</p>
          <p className="text-[10px] text-gray-400">
            {isPro ? "Removed on export" : "Upgrade to Pro to remove"}
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
          <div className="w-9 h-5 bg-[#2d3748] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-amber-500"></div>
        </label>
      </div>
    </div>
  );
}
