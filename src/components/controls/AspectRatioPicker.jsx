"use client";

import { ASPECT_RATIOS } from "@/lib/constants";

export function AspectRatioPicker({ aspectRatio, setAspectRatio }) {
  return (
    <div className="space-y-1.5">
      <span className="text-[11px] font-black text-[#5a5752] uppercase tracking-wider">
        Aspect Ratio
      </span>
      <div className="grid grid-cols-3 gap-2">
        {ASPECT_RATIOS.map((item) => {
          const isSelected = aspectRatio === item.id;
          return (
            <button
              type="button"
              key={item.id}
              aria-pressed={isSelected}
              onClick={() => setAspectRatio(item.id)}
              className={`flex items-center justify-center gap-1.5 py-2 px-2.5 rounded-xl border-2 text-xs font-black transition ${
                isSelected
                  ? "bg-[#ffc72c] border-[#bf8a00] text-[#2b2820] shadow"
                  : "metal-inset text-[#4a4743] hover:text-[#2b2b2d] hover:border-[#7a766f]"
              }`}
              title={item.label}
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
