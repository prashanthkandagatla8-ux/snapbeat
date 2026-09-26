"use client";

import React, { useEffect } from "react";
import { Zap } from "lucide-react";

export default function RetroAdBanner({
  isPro = false,
  onOpenPricing,
  slotId = "banner_default",
  className = "",
}) {
  useEffect(() => {
    try {
      if (typeof window !== "undefined" && !isPro && process.env.NEXT_PUBLIC_ADSENSE_ID) {
        (window.adsbygoogle = window.adsbygoogle || []).push({});
      }
    } catch (err) {
      console.error("AdSense error", err);
    }
  }, [isPro]);

  if (isPro) return null;

  const adClient = process.env.NEXT_PUBLIC_ADSENSE_ID;

  return (
    <aside
      aria-label="Advertisement"
      className={`w-full max-w-3xl mx-auto my-3 ${className}`}
    >
      {adClient ? (
        <ins
          className="adsbygoogle"
          style={{ display: "block", textAlign: "center" }}
          data-ad-layout="in-article"
          data-ad-format="fluid"
          data-ad-client={adClient}
          data-ad-slot={slotId}
        />
      ) : (
        <div className="relative rounded-2xl p-2.5 sm:px-4 sm:py-3 bg-[#06151a]/90 backdrop-blur-md border border-amber-400/30 shadow-sm overflow-hidden text-white flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-xl bg-amber-500/15 border border-amber-400/30 flex items-center justify-center shrink-0">
              <Zap className="w-4 h-4 text-amber-300" />
            </div>
            <div className="text-left space-y-0.5">
              <span className="font-mono text-[9px] text-white/50 uppercase tracking-wide">
                Feature Spotlight
              </span>
              <p className="text-xs font-bold text-white tracking-tight">
                Unlock High-Speed GPU Renders
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onOpenPricing}
            className="px-3 py-1.5 rounded-xl btn-brass text-[10px] font-black text-[#261b02] uppercase tracking-wider shadow hover:brightness-110 active:scale-95 transition cursor-pointer"
          >
            Upgrade to Pro
          </button>
        </div>
      )}
    </aside>
  );
}
