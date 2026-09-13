"use client";

import { TITLE_FONTS } from "@/lib/constants";
import { Type, Crown, Sparkles } from "lucide-react";

export function TitleCardEditor({
  titleCard,
  setTitleCard,
  isPro = false,
  onOpenPricing,
}) {
  const handleToggle = (checked) => {
    if (!isPro) {
      if (onOpenPricing) onOpenPricing();
      return;
    }
    setTitleCard((prev) => ({ ...prev, enabled: checked }));
  };

  return (
    <div className="space-y-2 pt-2 border-t border-[#a89f90]/50">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          <Type className="w-3.5 h-3.5 text-[#bf8a00]" />
          <span className="text-xs font-black text-[#2b2b2d] uppercase">
            Opening Title Card
          </span>
          <span className="px-1.5 py-0.2 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
            PRO
          </span>
        </div>
        <label className="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            checked={Boolean(titleCard?.enabled && isPro)}
            onChange={(e) => handleToggle(e.target.checked)}
            className="sr-only peer"
          />
          <div className="w-9 h-5 bg-[#7a766f] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-[#ffc72c]"></div>
        </label>
      </div>

      {titleCard?.enabled && isPro && (
        <div className="space-y-2 p-2.5 rounded-xl metal-inset">
          <input
            type="text"
            placeholder="Title text (e.g. Summer Memories)"
            value={titleCard.text}
            maxLength={40}
            onChange={(e) =>
              setTitleCard((prev) => ({ ...prev, text: e.target.value }))
            }
            className="w-full bg-[#d4cdc0] border border-[#8f8677] rounded-lg px-2.5 py-1.5 text-xs font-bold text-[#2b2b2d] placeholder-[#7a766f] focus:outline-none focus:border-[#2b2b2d]"
          />

          <input
            type="text"
            placeholder="Subtitle / Date (e.g. Tokyo • 2026)"
            value={titleCard.subtitle || ""}
            maxLength={40}
            onChange={(e) =>
              setTitleCard((prev) => ({ ...prev, subtitle: e.target.value }))
            }
            className="w-full bg-[#d4cdc0] border border-[#8f8677] rounded-lg px-2.5 py-1.5 text-xs font-bold text-[#2b2b2d] placeholder-[#7a766f] focus:outline-none focus:border-[#2b2b2d]"
          />

          <div className="grid grid-cols-2 gap-2">
            <select
              value={titleCard.font}
              onChange={(e) =>
                setTitleCard((prev) => ({ ...prev, font: e.target.value }))
              }
              className="bg-[#d4cdc0] border border-[#8f8677] rounded-lg px-2 py-1.5 text-[11px] font-bold text-[#2b2b2d] focus:outline-none focus:border-[#2b2b2d]"
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
              className="bg-[#d4cdc0] border border-[#8f8677] rounded-lg px-2 py-1.5 text-[11px] font-bold text-[#2b2b2d] focus:outline-none focus:border-[#2b2b2d]"
            >
              <option value="2">2 seconds intro</option>
              <option value="3">3 seconds intro</option>
              <option value="4">4 seconds intro</option>
            </select>
          </div>
        </div>
      )}

      {!isPro && (
        <div className="pt-1.5 flex items-center justify-between border-t border-[#a89f90]/40">
          <p className="text-[10px] text-[#5a5752] font-semibold leading-tight">
            Cinematic intro title cards are locked for Free users.
          </p>
          <button
            type="button"
            onClick={onOpenPricing}
            className="px-2.5 py-1 rounded-xl btn-brass text-[#2b2820] text-[10px] font-black uppercase tracking-wider shrink-0 ml-2 shadow hover:brightness-110 flex items-center gap-1"
          >
            <Crown className="w-2.5 h-2.5" />
            <span>UNLOCK PRO</span>
          </button>
        </div>
      )}
    </div>
  );
}
