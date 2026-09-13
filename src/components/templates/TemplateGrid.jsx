"use client";

import { TEMPLATES } from "@/lib/constants";
import { Sparkles, Crown } from "lucide-react";

export function TemplateGrid({ selectedTemplate, onSelectTemplate, isPro, onOpenPricing }) {
  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <span className="font-black text-xs text-[#2b2b2d] uppercase tracking-wider">
          Motion Templates ({TEMPLATES.length})
        </span>
        <span className="text-[11px] text-[#bf8a00] font-black">
          {TEMPLATES.find((t) => t.id === selectedTemplate)?.name || "Select"}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-2 max-h-[220px] overflow-y-auto p-1.5 rounded-2xl metal-inset">
        {TEMPLATES.map((tmpl) => {
          const isSelected = tmpl.id === selectedTemplate;
          const isLocked = tmpl.isPro && !isPro;

          const handleSelect = () => {
            if (isLocked) {
              if (onOpenPricing) onOpenPricing();
            } else {
              onSelectTemplate(tmpl.id);
            }
          };

          return (
            <div
              key={tmpl.id}
              role="button"
              tabIndex={0}
              aria-selected={isSelected}
              onClick={handleSelect}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.preventDefault();
                  handleSelect();
                }
              }}
              className={`relative p-2.5 rounded-xl border-2 transition cursor-pointer flex flex-col justify-between select-none ${
                isSelected
                  ? "bg-[#ffc72c]/25 border-[#ffc72c] shadow-md text-[#2b2820]"
                  : "bg-[#d4cdc0] border-[#9e9688] hover:border-[#2b2b2d] text-[#2b2b2d]"
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-xl">{tmpl.emoji}</span>
                {tmpl.isPro && (
                  <span className="flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
                    <Crown className="w-2.5 h-2.5" />
                    PRO
                  </span>
                )}
              </div>
              <div>
                <p className="font-black text-xs text-[#2b2b2d] leading-tight truncate">{tmpl.name}</p>
                <p className="text-[10px] text-[#5a5752] line-clamp-1 mt-0.5">
                  {tmpl.subtitle}
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
