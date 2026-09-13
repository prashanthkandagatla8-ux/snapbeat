"use client";

import React from "react";
import { useAuth } from "@/context/AuthContext";
import { Crown, Music, Images, Sliders, ListOrdered, Film, User, LogOut } from "lucide-react";

export function RetroHeader({
  currentTab,
  setCurrentTab,
  renderMode,
  setRenderMode,
  isPro,
  onOpenPricing,
  serverOnline,
  activeQueueCount,
  onShowcaseClick,
}) {
  const { user, openAuthModal, signOut } = useAuth();

  const handleModeSwitch = (mode) => {
    if (mode === "pro" && !isPro) {
      onOpenPricing();
      return;
    }
    setRenderMode(mode);
  };

  return (
    <header className="w-full metal-panel border-b-2 border-[#7a766f] px-3 sm:px-6 py-2.5 sticky top-0 z-40 relative shadow-md">
      {/* 4 Corner Screws */}
      <div className="absolute top-2 left-2 metal-screw hidden sm:block" />
      <div className="absolute top-2 right-2 metal-screw hidden sm:block" />
      <div className="absolute bottom-2 left-2 metal-screw hidden sm:block" />
      <div className="absolute bottom-2 right-2 metal-screw hidden sm:block" />

      <div className="max-w-[1600px] mx-auto flex flex-col md:flex-row items-center justify-between gap-2.5">
        {/* Left: SnapBeat App Icon + Logo + Showcase Link */}
        <div className="flex items-center gap-3 w-full md:w-auto justify-between md:justify-start">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl metal-inset p-1 flex items-center justify-center shadow-inner">
              <img
                src="/assets/images/snapbeat_app_icon.png"
                alt="SnapBeat Icon"
                className="w-full h-full object-contain rounded-lg"
              />
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <h1 className="text-lg lg:text-xl font-black text-[#2b2b2d] tracking-tight uppercase">
                  Snap<span className="text-[#bf8a00]">Beat</span>
                </h1>
                <span className="px-1.5 py-0.2 rounded bg-[#ffc72c] text-[#2b2820] font-black text-[9px] tracking-wider shadow-sm border border-[#bf8a00]">
                  STUDIO
                </span>
              </div>
              <div className="flex items-center gap-1.5 text-[9px] text-[#4a4743] font-bold">
                <div className={serverOnline ? "led-green" : "led-amber animate-ping"} />
                <span>{serverOnline ? "CLUSTER READY" : "CONNECTING..."}</span>
              </div>
            </div>
          </div>

          {/* Return to Showcase Button */}
          {onShowcaseClick && (
            <button
              onClick={onShowcaseClick}
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg metal-inset hover:bg-black/5 text-[#3b3834] text-[11px] font-black tracking-wide transition ml-2"
              title="View Sample Render Showcase"
            >
              <Film className="w-3.5 h-3.5 text-amber-600" />
              <span className="hidden sm:inline">SHOWCASE</span>
            </button>
          )}
        </div>

        {/* Center: Tabs (Music | Photos | Studio | Queue) */}
        <nav className="flex items-center gap-1 p-1 rounded-xl metal-inset">
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
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-black transition-all ${
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

        {/* Right: FREE vs PRO Mode Switcher + User Account + Pro Button */}
        <div className="flex items-center gap-2 sm:gap-3">
          {/* FREE vs PRO Switcher */}
          <div className="flex items-center gap-1.5 px-2 py-1 rounded-xl metal-inset">
            <span className="text-[10px] font-black text-[#5a5752]">TIER:</span>
            <div className="flex items-center bg-[#b8ae9e] rounded-lg p-0.5 border border-[#8f8677]">
              <button
                onClick={() => handleModeSwitch("free")}
                className={`px-2 py-0.5 rounded-md text-[10px] font-black transition ${
                  renderMode === "free"
                    ? "bg-[#2b2b2d] text-white shadow"
                    : "text-[#5a5752] hover:text-[#2b2b2d]"
                }`}
              >
                FREE
              </button>
              <button
                onClick={() => handleModeSwitch("pro")}
                className={`px-2 py-0.5 rounded-md text-[10px] font-black transition flex items-center gap-0.5 ${
                  renderMode === "pro"
                    ? "bg-gradient-to-r from-amber-500 to-amber-600 text-black shadow"
                    : "text-[#5a5752] hover:text-[#2b2b2d]"
                }`}
              >
                <Crown className="w-2.5 h-2.5" />
                <span>PRO</span>
              </button>
            </div>
          </div>

          {/* Pro Upgrade / Badge Button */}
          {isPro ? (
            <div className="flex items-center gap-1 px-2.5 py-1 rounded-lg bg-gradient-to-r from-amber-400 to-amber-500 text-black font-black text-[10px] tracking-wider shadow">
              <Crown className="w-3 h-3 fill-current" />
              <span>PRO ACTIVE</span>
            </div>
          ) : (
            <button
              onClick={onOpenPricing}
              className="flex items-center gap-1 px-3 py-1.5 rounded-xl font-black text-xs btn-brass text-[#2b2820] shadow hover:brightness-110 active:scale-95 transition"
            >
              <Crown className="w-3.5 h-3.5 text-amber-600 fill-amber-500" />
              <span>GET PRO</span>
            </button>
          )}

          {/* User Sign In / Profile */}
          {user ? (
            <div className="flex items-center gap-1.5 pl-1 border-l border-[#8f8677]/60">
              <span className="text-[11px] font-black text-[#2b2b2d] max-w-[90px] truncate hidden xl:inline" title={user.email}>
                {user.name || user.email.split("@")[0]}
              </span>
              <button
                onClick={signOut}
                className="p-1.5 rounded-lg metal-inset text-[#5a5752] hover:text-red-700 transition"
                title="Sign Out"
              >
                <LogOut className="w-3.5 h-3.5" />
              </button>
            </div>
          ) : (
            <button
              onClick={openAuthModal}
              className="p-1.5 rounded-lg metal-inset text-[#4a4743] hover:text-[#2b2b2d] transition flex items-center gap-1 text-[11px] font-bold"
              title="Sign In"
            >
              <User className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Sign In</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
