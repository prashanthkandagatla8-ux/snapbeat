"use client";

import { Crown, Sparkles } from "lucide-react";

export function QualitySelector({ quality, setQuality, watermark, setWatermark, isPro, onOpenPricing }) {
  return (
    <div className="space-y-3 pt-2 border-t border-[#a89f90]/50">
      {/* Quality Picker */}
      <div className="space-y-1.5">
        <div className="flex items-center justify-between">
          <span className="text-[11px] font-black text-[#5a5752] uppercase tracking-wider">
            Export Quality
          </span>
          {!isPro && (
            <span
              type="button"
              className="text-[10px] font-bold text-[#bf8a00] hover:underline cursor-pointer"
              onClick={onOpenPricing}
            >
              1080p requires Pro (Coming Soon) 👑
            </span>
          )}
        </div>
        <div className="grid grid-cols-2 gap-2">
          <button
            type="button"
            onClick={() => setQuality("fast")}
            className={`py-2 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center justify-center ${
              quality === "fast"
                ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                : "metal-inset text-[#4a4743] hover:text-[#2b2b2d]"
            }`}
          >
            <span>480p Standard</span>
            <span className="text-[9px] font-semibold text-[#5a5752]">Free Tier</span>
          </button>

          <button
            type="button"
            onClick={() => {
              if (!isPro) {
                onOpenPricing();
              } else {
                setQuality("master");
              }
            }}
            className={`py-2 px-3 rounded-xl border-2 text-xs font-black transition flex flex-col items-center justify-center relative ${
              quality === "master"
                ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                : "metal-inset text-[#4a4743] hover:text-[#2b2b2d]"
            }`}
          >
            <div className="flex items-center gap-1">
              <span>1080p Master</span>
              {!isPro && <Crown className="w-3 h-3 text-[#bf8a00]" />}
            </div>
            <span className="text-[9px] font-semibold text-[#5a5752]">Pro • Coming Soon</span>
          </button>
        </div>
      </div>

      {/* Watermark Section */}
      <div className="flex items-center justify-between p-3 rounded-xl metal-inset">
        <div>
          <p className="text-xs font-black text-[#2b2b2d]">SNAPBEAT WATERMARK</p>
          <p className="text-[10px] text-[#5a5752]">
            {isPro ? "Clean export • No watermark" : "Free output includes watermark"}
          </p>
        </div>
        {isPro ? (
          <span className="px-2.5 py-1 rounded-full bg-[#00c853]/20 text-[#00c853] text-[10px] font-black uppercase tracking-wider border border-[#00c853]/40">
            WATERMARK: REMOVED
          </span>
        ) : (
          <div className="flex items-center gap-2">
            <span className="px-2 py-0.5 rounded-full bg-[#ffc72c]/30 text-[#4a3b00] text-[9px] font-black uppercase tracking-wider border border-[#bf8a00]/40">
              WATERMARK: APPLIED
            </span>
            <button
              type="button"
              onClick={onOpenPricing}
              className="px-2.5 py-1 rounded-full btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shadow hover:brightness-110 flex items-center gap-1 cursor-pointer"
            >
              <Crown className="w-2.5 h-2.5" />
              <span>REMOVE (PRO - SOON)</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
