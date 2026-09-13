"use client";

import { TITLE_FONTS } from "@/lib/constants";
import { Type } from "lucide-react";

export function TitleCardEditor({ titleCard, setTitleCard }) {
  return (
    <div className="space-y-2 pt-2 border-t border-[#242b38]/60">
      <div className="flex items-center justify-between">
        <span className="flex items-center gap-1.5 text-xs font-bold text-gray-300">
          <Type className="w-3.5 h-3.5 text-amber-400" />
          Opening Title Card
        </span>
        <label className="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            checked={titleCard.enabled}
            onChange={(e) =>
              setTitleCard((prev) => ({ ...prev, enabled: e.target.checked }))
            }
            className="sr-only peer"
          />
          <div className="w-9 h-5 bg-[#2d3748] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-amber-500"></div>
        </label>
      </div>

      {titleCard.enabled && (
        <div className="space-y-2 p-2.5 rounded-xl bg-[#1a202c] border border-[#2d3748]">
          <input
            type="text"
            placeholder="Enter title text (e.g. Goa Memories 2026)"
            value={titleCard.text}
            maxLength={40}
            onChange={(e) =>
              setTitleCard((prev) => ({ ...prev, text: e.target.value }))
            }
            className="w-full bg-[#11141c] border border-[#2d3748] rounded-lg px-2.5 py-1.5 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-amber-400"
          />

          <div className="grid grid-cols-2 gap-2">
            <select
              value={titleCard.font}
              onChange={(e) =>
                setTitleCard((prev) => ({ ...prev, font: e.target.value }))
              }
              className="bg-[#11141c] border border-[#2d3748] rounded-lg px-2 py-1.5 text-[11px] text-gray-300 focus:outline-none focus:border-amber-400"
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
              className="bg-[#11141c] border border-[#2d3748] rounded-lg px-2 py-1.5 text-[11px] text-gray-300 focus:outline-none focus:border-amber-400"
            >
              <option value="2">2 seconds</option>
              <option value="3">3 seconds</option>
              <option value="4">4 seconds</option>
            </select>
          </div>
        </div>
      )}
    </div>
  );
}
