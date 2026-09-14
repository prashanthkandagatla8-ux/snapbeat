"use client";

import { TEMPLATES } from "@/lib/constants";
import { Sparkles, Crown, Lock } from "lucide-react";

export function TemplateGrid({ selectedTemplate, onSelectTemplate, isPro, onOpenPricing }) {
  const currentTemplateObj = TEMPLATES.find((t) => t.id === selectedTemplate) || TEMPLATES[0];

  return (
    <div className="space-y-2 select-none">
      <div className="flex items-center justify-between">
        <span className="font-black text-xs text-[#2b2b2d] uppercase tracking-wider flex items-center gap-1.5">
          {isPro ? (
            <>
              <Crown className="w-3.5 h-3.5 text-amber-600" />
              <span>Motion Templates ({TEMPLATES.length})</span>
            </>
          ) : (
            <>
              <Sparkles className="w-3.5 h-3.5 text-amber-600" />
              <span>Auto-Assigned Template</span>
            </>
          )}
        </span>
        <span className="text-[11px] text-[#bf8a00] font-black">
          {currentTemplateObj.name} {currentTemplateObj.emoji}
        </span>
      </div>

      {!isPro ? (
        /* Free tier: Auto-assigned template display + locked selector */
        <div className="space-y-2">
          <div className="p-3 rounded-2xl bg-amber-50 border-2 border-[#ffc72c] shadow-sm flex items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <span className="text-2xl p-1.5 bg-amber-100 rounded-xl">{currentTemplateObj.emoji}</span>
              <div>
                <div className="flex items-center gap-2">
                  <h4 className="font-black text-sm text-[#2b2820]">{currentTemplateObj.name}</h4>
                  <span className="px-2 py-0.5 rounded-full bg-amber-400 text-black font-black text-[9px] uppercase tracking-wider">
                    AUTO-SELECTED
                  </span>
                </div>
                <p className="text-[11px] text-[#635f58]">{currentTemplateObj.subtitle}</p>
              </div>
            </div>
            <span className="text-[9px] text-[#8c8270] font-bold text-right shrink-0">
              Changes each render
            </span>
          </div>

          <div className="relative rounded-2xl overflow-hidden border border-black/10 bg-black/5 p-2">
            <div className="grid grid-cols-2 gap-1.5 opacity-20 pointer-events-none filter blur-[0.5px]">
              {TEMPLATES.slice(0, 4).map((tmpl) => (
                <div key={tmpl.id} className="p-2 rounded-xl bg-white/60 text-[#2b2b2d] flex items-center gap-2">
                  <span>{tmpl.emoji}</span>
                  <span className="text-xs font-bold truncate">{tmpl.name}</span>
                </div>
              ))}
            </div>
            <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/70 backdrop-blur-[1px] p-2.5 text-center text-white rounded-xl">
              <div className="flex items-center gap-1 text-amber-300 text-xs font-black mb-1">
                <Lock className="w-3.5 h-3.5" />
                <span>MANUAL SELECTION (PRO ONLY)</span>
              </div>
              <p className="text-[10px] text-amber-100/80 mb-2 max-w-[260px]">
                Upgrade to Pro to manually choose from all 14 motion presets!
              </p>
              <button
                type="button"
                onClick={onOpenPricing}
                className="btn-brass px-3 py-1 rounded-xl text-black font-black text-[11px] shadow hover:brightness-110 active:scale-95 transition cursor-pointer"
              >
                UNLOCK ALL TEMPLATES (SOON) ❯
              </button>
            </div>
          </div>
        </div>
      ) : (
        /* Pro tier: Full 14-template interactive grid */
        <div className="grid grid-cols-2 gap-2 max-h-[220px] overflow-y-auto p-1.5 rounded-2xl metal-inset">
          {TEMPLATES.map((tmpl) => {
            const isSelected = tmpl.id === selectedTemplate;
            return (
              <div
                key={tmpl.id}
                role="button"
                tabIndex={0}
                aria-selected={isSelected}
                onClick={() => onSelectTemplate(tmpl.id)}
                className={`relative p-2.5 rounded-xl border-2 transition cursor-pointer flex flex-col justify-between select-none ${
                  isSelected
                    ? "bg-[#ffc72c]/25 border-[#ffc72c] shadow-md text-[#2b2820]"
                    : "bg-[#d4cdc0] border-[#9e9688] hover:border-[#2b2b2d] text-[#2b2b2d]"
                }`}
              >
                <div className="flex items-center justify-between mb-1">
                  <span className="text-xl">{tmpl.emoji}</span>
                  <span className="flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[8px] font-black bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00]">
                    <Crown className="w-2.5 h-2.5" />
                    PRO
                  </span>
                </div>
                <div>
                  <p className="font-black text-xs text-[#2b2b2d] leading-tight truncate">{tmpl.name}</p>
                  <p className="text-[10px] text-[#5a5752] line-clamp-1 mt-0.5">{tmpl.subtitle}</p>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
