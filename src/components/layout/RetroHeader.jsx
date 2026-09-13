"use client";

import { Crown, Sparkles, Music, Images, Sliders, ListOrdered, Circle } from "lucide-react";

export function RetroHeader({
  currentTab,
  setCurrentTab,
  renderMode,
  setRenderMode,
  isPro,
  daysRemaining,
  onOpenPricing,
  serverOnline,
  activeQueueCount,
}) {
  return (
    <header className="w-full metal-panel border-b-2 border-[#7a766f] px-4 lg:px-8 py-3 sticky top-0 z-40 relative">
      {/* 4 Corner Screws */}
      <div className="absolute top-2 left-2 metal-screw hidden sm:block" />
      <div className="absolute top-2 right-2 metal-screw hidden sm:block" />
      <div className="absolute bottom-2 left-2 metal-screw hidden sm:block" />
      <div className="absolute bottom-2 right-2 metal-screw hidden sm:block" />

      <div className="max-w-[1600px] mx-auto flex flex-col md:flex-row items-center justify-between gap-3">
        {/* Left: SnapBeat Stamped Logo + Pink Dot */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2">
            <div className="w-3.5 h-3.5 rounded-full bg-[#ff3366] shadow-[0_0_10px_#ff3366]" />
            <h1 className="text-xl lg:text-2xl font-black text-[#2b2b2d] tracking-tight uppercase">
              Snap<span className="text-[#bf8a00]">Beat</span>
            </h1>
            <span className="px-2 py-0.5 rounded bg-[#ffc72c] text-[#2b2820] font-black text-[10px] tracking-wider shadow-sm border border-[#bf8a00]">
              CONSOLE
            </span>
          </div>

          {/* LED Server Status Indicator */}
          <div className="hidden xl:flex items-center gap-2 px-2.5 py-1 rounded-full metal-inset text-[11px] text-[#4a4743] font-bold">
            <div className={serverOnline ? "led-green" : "led-amber animate-ping"} />
            <span>{serverOnline ? "CLUSTER READY" : "CONNECTING..."}</span>
          </div>
        </div>

        {/* Center: Mobile-Parity Navigation Deck (Music | Photos | Render | Queue) */}
        <nav className="flex items-center gap-1.5 p-1 rounded-xl metal-inset">
          {[
            { id: "music", label: "MUSIC", icon: Music },
            { id: "photos", label: "PHOTOS", icon: Images },
            { id: "render", label: "STUDIO", icon: Sliders },
            { id: "queue", label: "QUEUE", icon: ListOrdered, badge: activeQueueCount },
          ].map((tab) => {
            const isActive = currentTab === tab.id;
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setCurrentTab(tab.id)}
                className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg text-xs font-black transition-all ${
                  isActive
                    ? "btn-brass text-[#2b2820] shadow-md"
                    : "text-[#4a4743] hover:text-[#2b2b2d] hover:bg-black/5"
                }`}
              >
                <Icon className="w-3.5 h-3.5" />
                <span>{tab.label}</span>
                {tab.badge > 0 && (
                  <span className="px-1.5 py-0.2 rounded-full bg-[#d62828] text-white text-[9px] font-bold">
                    {tab.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Right: Mode Toggle (AUTO vs PRO) + Pro Store Trigger */}
        <div className="flex items-center gap-3">
          {/* Tactile Mode Switcher */}
          <div className="flex items-center gap-2 px-2.5 py-1 rounded-xl metal-inset">
            <span className="text-[10px] font-black text-[#5a5752]">MODE:</span>
            <div className="flex items-center bg-[#b8ae9e] rounded-lg p-0.5 border border-[#8f8677]">
              <button
                onClick={() => setRenderMode("auto")}
                className={`px-2.5 py-1 rounded-md text-[10px] font-black transition ${
                  renderMode === "auto"
                    ? "bg-[#ffc72c] text-[#2b2820] shadow"
                    : "text-[#5a5752] hover:text-[#2b2b2d]"
                }`}
              >
                AUTO
              </button>
              <button
                onClick={() => setRenderMode("pro")}
                className={`px-2.5 py-1 rounded-md text-[10px] font-black transition ${
                  renderMode === "pro"
                    ? "bg-[#d62828] text-white shadow"
                    : "text-[#5a5752] hover:text-[#2b2b2d]"
                }`}
              >
                PRO
              </button>
            </div>
          </div>

          {/* Pro Store Action */}
          {isPro ? (
            <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#ffc72c]/30 border border-[#bf8a00] text-[#2b2820] text-xs font-black shadow-sm">
              <Crown className="w-3.5 h-3.5 text-[#bf8a00]" />
              <span>PRO • {daysRemaining}d</span>
            </div>
          ) : (
            <button
              onClick={onOpenPricing}
              className="btn-brass px-3.5 py-1.5 rounded-xl text-xs font-black flex items-center gap-1.5"
            >
              <Sparkles className="w-3.5 h-3.5 fill-[#2b2820]" />
              <span>PRO STORE</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
