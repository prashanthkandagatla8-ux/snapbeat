"use client";

import { TEMPLATES } from "@/lib/constants";
import { Sparkles, Crown } from "lucide-react";

export function TemplateGrid({ selectedTemplate, onSelectTemplate, isPro, onOpenPricing }) {
  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <span className="font-bold text-xs text-gray-300 uppercase tracking-wider">
          Motion Templates ({TEMPLATES.length})
        </span>
        <span className="text-[11px] text-amber-400 font-semibold">
          {TEMPLATES.find((t) => t.id === selectedTemplate)?.name || "Select"}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-2 max-h-[220px] overflow-y-auto p-1 rounded-xl bg-[#11141c]/50 border border-[#242b38]/50">
        {TEMPLATES.map((tmpl) => {
          const isSelected = tmpl.id === selectedTemplate;
          const isLocked = tmpl.isPro && !isPro;

          return (
            <div
              key={tmpl.id}
              onClick={() => {
                if (isLocked) {
                  onOpenPricing();
                } else {
                  onSelectTemplate(tmpl.id);
                }
              }}
              className={`relative p-2.5 rounded-xl border transition-all cursor-pointer flex flex-col justify-between ${
                isSelected
                  ? "bg-amber-500/15 border-amber-400 shadow-md shadow-amber-500/10"
                  : "bg-[#1a202c]/70 border-[#2d3748] hover:border-gray-500 hover:bg-[#1a202c]"
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-xl">{tmpl.emoji}</span>
                {tmpl.isPro && (
                  <span className="flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[9px] font-black bg-gradient-to-r from-amber-500 to-yellow-400 text-black">
                    <Crown className="w-2.5 h-2.5" />
                    PRO
                  </span>
                )}
              </div>
              <div>
                <p className="font-bold text-xs text-white leading-tight">{tmpl.name}</p>
                <p className="text-[10px] text-gray-400 line-clamp-1 mt-0.5">
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
