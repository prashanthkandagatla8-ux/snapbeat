"use client";

import { ASPECT_RATIOS } from "@/lib/constants";

export function AspectRatioPicker({ aspectRatio, setAspectRatio }) {
  return (
    <div className="space-y-1.5">
      <span className="text-[11px] font-bold text-gray-400 uppercase tracking-wider">
        Aspect Ratio
      </span>
      <div className="grid grid-cols-3 gap-2">
        {ASPECT_RATIOS.map((item) => {
          const isSelected = aspectRatio === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setAspectRatio(item.id)}
              className={`flex items-center justify-center gap-1.5 py-2 px-2.5 rounded-xl border text-xs font-bold transition ${
                isSelected
                  ? "bg-amber-500/20 border-amber-400 text-amber-300"
                  : "bg-[#1a202c]/60 border-[#2d3748] text-gray-400 hover:text-white hover:bg-[#1a202c]"
              }`}
            >
              <span>{item.icon}</span>
              <span>{item.id}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
