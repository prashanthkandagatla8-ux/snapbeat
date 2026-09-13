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
  daysRemaining,
  onOpenPricing,
  serverOnline,
  activeQueueCount = 0,
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
    <header className="w-full metal-panel border-b-2 border-[#7a766f] px-3 sm:px-6 py-2.5 sticky top-0 z-40 relative shadow-md select-none">
      {/* 4 Corner Screws */}
      <div className="absolute top-2 left-2 metal-screw hidden sm:block" />
      <div className="absolute top-2 right-2 metal-screw hidden sm:block" />
      <div className="absolute bottom-2 left-2 metal-screw hidden sm:block" />
      <div className="absolute bottom-2 right-2 metal-screw hidden sm:block" />

      <div className="max-w-[1600px] mx-auto flex flex-col md:flex-row items-center justify-between gap-2.5">
        {/* Left: SnapBeat App Icon + Logo + Showcase Link */}
        <div className="flex items-center gap-2 sm:gap-3 w-full md:w-auto justify-between md:justify-start flex-wrap">
          <div
            onClick={onShowcaseClick}
            className={`flex items-center gap-2.5 ${
              onShowcaseClick ? "cursor-pointer group" : ""
            }`}
            title={onShowcaseClick ? "Return to Showcase Home" : "SnapBeat Studio"}
            role={onShowcaseClick ? "button" : undefined}
            tabIndex={onShowcaseClick ? 0 : undefined}
            onKeyDown={(e) => {
              if (onShowcaseClick && (e.key === "Enter" || e.key === " ")) {
                onShowcaseClick();
              }
            }}
          >
            <div className="w-9 h-9 rounded-xl metal-inset p-1 flex items-center justify-center shadow-inner group-hover:brightness-105 transition">
              <img
                src="/assets/images/snapbeat_app_icon.png"
                alt="SnapBeat App Icon"
                className="w-full h-full object-contain rounded-lg"
              />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <img
                  src="/assets/images/snapbeat_logo_crop.png"
                  alt="SnapBeat"
                  className="h-7 lg:h-8 w-auto object-contain group-hover:brightness-105 transition"
                />
                <span className="px-1.5 py-0.5 rounded bg-[#ffc72c] text-[#2b2820] font-black text-[9px] tracking-wider shadow-sm border border-[#bf8a00]">
                  STUDIO
                </span>
              </div>
              <div
                className="flex items-center gap-1.5 text-[9px] text-[#4a4743] font-bold"
                title={serverOnline ? "GPU cluster is online and operational" : "GPU render server is offline or unreachable"}
              >
                <div
                  className={
                    serverOnline
                      ? "led-green"
                      : "w-2 h-2 rounded-full bg-red-500 shadow-[0_0_8px_#ef4444] animate-pulse"
                  }
                />
                <span className={serverOnline ? "text-[#2e7d32]" : "text-red-700"}>
                  {serverOnline ? "SERVER ONLINE" : "SERVER OFFLINE"}
                </span>
              </div>
            </div>
          </div>

          {/* Return to Showcase Button */}
          {onShowcaseClick && (
            <button
              type="button"
              onClick={onShowcaseClick}
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg metal-inset hover:bg-black/5 text-[#3b3834] text-[11px] font-black tracking-wide transition border border-[#8f8677]/40 active:scale-95"
              title="View Sample Render Showcase Reel"
              aria-label="Return to Showcase Home"
            >
              <Film className="w-3.5 h-3.5 text-amber-600" />
              <span className="hidden sm:inline">SHOWCASE</span>
            </button>
          )}
        </div>

        {/* Center: Tabs (Music → Photos → Render → Queue) */}
        <nav
          className="flex items-center gap-1 p-1 rounded-xl metal-inset overflow-x-auto max-w-full"
          aria-label="Workflow Tabs"
        >
          {[
            { id: "music", label: "MUSIC", icon: Music, desc: "Soundtrack & Audio Trim" },
            { id: "photos", label: "PHOTOS", icon: Images, desc: "Photo Strips & Auto-Arrange" },
            { id: "render", label: "RENDER", icon: Sliders, desc: "Templates, Aspect Ratio & Render" },
            { id: "queue", label: "QUEUE", icon: ListOrdered, badge: activeQueueCount, desc: "Render Progress & Downloads" },
          ].map((tab) => {
            const isActive = currentTab === tab.id;
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setCurrentTab(tab.id)}
                title={tab.desc}
                aria-current={isActive ? "page" : undefined}
                className={`flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-lg text-xs font-black transition-all ${
                  isActive
                    ? "btn-brass text-[#2b2820] shadow-md"
                    : "text-[#4a4743] hover:text-[#2b2b2d] hover:bg-black/5"
                }`}
              >
                <Icon className="w-3.5 h-3.5 shrink-0" />
                <span>{tab.label}</span>
                {tab.badge > 0 && (
                  <span className="px-1.5 py-0.5 rounded-full bg-[#d62828] text-white text-[9px] font-bold animate-pulse shrink-0">
                    {tab.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Right: FREE vs PRO Mode Switcher + User Account + Pro Button */}
        <div className="flex items-center justify-center md:justify-end gap-2 sm:gap-3 flex-wrap">
          {/* FREE vs PRO Switcher */}
          <div
            className="flex items-center gap-1.5 px-2 py-1 rounded-xl metal-inset"
            title="Render output tier: Free (720p with watermark) vs Pro (1080p clean)"
          >
            <span className="text-[10px] font-black text-[#5a5752]">MODE:</span>
            <div className="flex items-center bg-[#b8ae9e] rounded-lg p-0.5 border border-[#8f8677]">
              <button
                type="button"
                onClick={() => handleModeSwitch("free")}
                className={`px-2 py-0.5 rounded-md text-[10px] font-black transition ${
                  renderMode === "free"
                    ? "bg-[#2b2b2d] text-white shadow"
                    : "text-[#5a5752] hover:text-[#2b2b2d]"
                }`}
                title="Free Mode (720p, watermark included)"
              >
                FREE
              </button>
              <button
                type="button"
                onClick={() => handleModeSwitch("pro")}
                className={`px-2 py-0.5 rounded-md text-[10px] font-black transition flex items-center gap-0.5 ${
                  renderMode === "pro"
                    ? "bg-gradient-to-r from-amber-500 to-amber-600 text-black shadow"
                    : "text-[#5a5752] hover:text-[#2b2b2d]"
                }`}
                title="Pro Mode (1080p, no watermark, title cards unlocked)"
              >
                <Crown className="w-2.5 h-2.5" />
                <span>PRO</span>
              </button>
            </div>
          </div>

          {/* Pro Upgrade / Badge Button */}
          {isPro ? (
            <div
              className="flex items-center gap-1 px-2.5 py-1 rounded-lg bg-gradient-to-r from-amber-400 to-amber-500 text-black font-black text-[10px] tracking-wider shadow cursor-default"
              title={daysRemaining ? `Pro Subscription Active — ${daysRemaining} days remaining` : "Pro Subscription Active"}
            >
              <Crown className="w-3 h-3 fill-current" />
              <span>PRO ACTIVE{daysRemaining ? ` (${daysRemaining}d)` : ""}</span>
            </div>
          ) : (
            <button
              type="button"
              onClick={onOpenPricing}
              className="flex items-center gap-1 px-3 py-1.5 rounded-xl font-black text-xs btn-brass text-[#2b2820] shadow hover:brightness-110 active:scale-95 transition"
              title="Unlock 1080p Full HD, Title Cards, and Watermark Removal"
            >
              <Crown className="w-3.5 h-3.5 text-amber-600 fill-amber-500" />
              <span>GET PRO</span>
            </button>
          )}

          {/* User Sign In / Account Status */}
          {user ? (
            <div className="flex items-center gap-1.5 pl-1 sm:pl-2 border-l border-[#8f8677]/60">
              <div
                className="flex items-center gap-1 px-2 py-1 rounded-lg metal-inset text-[#2b2b2d]"
                title={`Signed in as ${user.email}${user.isPro ? " (Pro Account)" : ""}`}
              >
                <User className="w-3 h-3 text-[#5a5752] shrink-0" />
                <span className="text-[10px] sm:text-[11px] font-black max-w-[80px] sm:max-w-[120px] truncate">
                  {user.name || user.email.split("@")[0]}
                </span>
              </div>
              <button
                type="button"
                onClick={signOut}
                className="p-1.5 rounded-lg metal-inset text-[#5a5752] hover:text-red-700 hover:bg-black/5 active:scale-95 transition"
                title="Sign Out"
                aria-label="Sign Out"
              >
                <LogOut className="w-3.5 h-3.5" />
              </button>
            </div>
          ) : (
            <button
              type="button"
              onClick={openAuthModal}
              className="px-2.5 py-1.5 rounded-lg metal-inset text-[#4a4743] hover:text-[#2b2b2d] hover:bg-black/5 transition flex items-center gap-1 text-[11px] font-bold border border-[#8f8677]/40 active:scale-95"
              title="Sign In with Email or Google"
            >
              <User className="w-3.5 h-3.5" />
              <span className="inline">Sign In</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
