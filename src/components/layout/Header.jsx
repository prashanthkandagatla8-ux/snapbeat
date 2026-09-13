"use client";

import { useState, useEffect } from "react";
import { Sparkles, Crown, Circle, HelpCircle } from "lucide-react";
import { DEFAULT_SERVER_URL } from "@/lib/constants";

export function Header({ isPro, daysRemaining, onOpenPricing }) {
  const [serverOnline, setServerOnline] = useState(false);

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const res = await fetch(`${DEFAULT_SERVER_URL}/api/health`, { cache: "no-store" });
        if (res.ok) {
          const data = await res.json();
          setServerOnline(data.ok === true || data.status === "ok");
        } else {
          setServerOnline(false);
        }
      } catch {
        setServerOnline(false);
      }
    };

    checkHealth();
    const interval = setInterval(checkHealth, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <header className="w-full bg-[#11141c] border-b border-[#242b38] px-4 lg:px-8 py-3 flex items-center justify-between sticky top-0 z-40">
      {/* Brand */}
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-amber-500 to-yellow-300 flex items-center justify-center shadow-lg shadow-amber-500/20">
          <span className="text-xl">🎵</span>
        </div>
        <div>
          <div className="flex items-center gap-2">
            <span className="font-extrabold text-lg lg:text-xl tracking-tight text-white">
              Snap<span className="text-amber-400">Beat</span>
            </span>
            <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20">
              STUDIO
            </span>
          </div>
          <p className="text-[11px] text-gray-400 hidden sm:block">AI Beat-Synced Video Reel Maker</p>
        </div>
      </div>

      {/* Center Server Health Status */}
      <div className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#181f2b] border border-[#263142] text-xs">
        <Circle
          className={`w-2.5 h-2.5 fill-current ${
            serverOnline ? "text-emerald-400" : "text-rose-400 animate-ping"
          }`}
        />
        <span className="text-gray-300 font-medium">
          {serverOnline ? "VPS Render Cluster Online" : "Connecting to Cluster..."}
        </span>
      </div>

      {/* Right Controls: Pro Status / Upgrade */}
      <div className="flex items-center gap-3">
        {isPro ? (
          <div className="flex items-center gap-2 px-3.5 py-1.5 rounded-lg bg-gradient-to-r from-amber-500/20 to-yellow-500/10 border border-amber-500/40 text-amber-300 font-bold text-xs shadow-sm">
            <Crown className="w-4 h-4 text-amber-400" />
            <span>PRO ACTIVE • {daysRemaining}d left</span>
          </div>
        ) : (
          <button
            onClick={onOpenPricing}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 hover:from-amber-400 hover:to-yellow-300 text-black font-extrabold text-xs shadow-md shadow-amber-500/25 transition-all transform hover:scale-[1.02] active:scale-[0.98]"
          >
            <Sparkles className="w-4 h-4 fill-black" />
            <span>UPGRADE TO PRO (from ₹99)</span>
          </button>
        )}

        <a
          href="/privacy"
          title="Privacy Policy"
          className="text-gray-400 hover:text-white p-2 rounded-lg hover:bg-white/5 transition"
        >
          <HelpCircle className="w-4 h-4" />
        </a>
      </div>
    </header>
  );
}
