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
    <header className="w-full bg-[#081b20]/80 backdrop-blur-xl border-b border-[#d4af37]/25 px-3 sm:px-6 py-2.5 sticky top-0 z-40 relative shadow-lg select-none text-white">
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
            <div className="w-9 h-9 rounded-xl bg-black/40 border border-[#d4af37]/30 p-1 flex items-center justify-center shadow-inner group-hover:brightness-110 transition">
              <img
                src="/assets/images/snapbeat_app_icon.png"
                alt="SnapBeat App Icon"
                className="w-full h-full object-contain rounded-lg"
              />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <img
                  src="/assets/images/snapbeat_logo_3d.png"
                  alt="SnapBeat"
                  className="h-7 lg:h-8 w-auto object-contain group-hover:brightness-110 transition drop-shadow-md"
                />
                <span className="px-1.5 py-0.5 rounded bg-[#ffc72c] text-[#2b2820] font-black text-[9px] tracking-wider shadow-sm border border-[#bf8a00]">
                  STUDIO
                </span>
              </div>
              <div
                className="flex items-center gap-1.5 text-[9px] text-white/70 font-bold"
                title={serverOnline ? "GPU cluster is online and operational" : "GPU render server is offline or unreachable"}
              >
                <div
                  className={
                    serverOnline
                      ? "w-2 h-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399] animate-pulse"
                      : "w-2 h-2 rounded-full bg-red-500 shadow-[0_0_8px_#ef4444] animate-pulse"
                  }
                />
                <span className={serverOnline ? "text-emerald-400" : "text-red-400"}>
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
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl bg-amber-500/15 hover:bg-amber-500/25 text-amber-300 text-[11px] font-black tracking-wide transition border border-amber-500/30 active:scale-95 shadow-sm"
              title="View Sample Render Showcase Reel"
              aria-label="Return to Showcase Home"
            >
              <Film className="w-3.5 h-3.5 text-amber-400" />
              <span className="hidden sm:inline">SHOWCASE</span>
            </button>
          )}
        </div>

        {/* Center: Tabs (Music → Photos → Render → Queue) */}
        <nav
          className="flex items-center gap-1 p-1 rounded-2xl bg-black/40 border border-white/10 overflow-x-auto max-w-full backdrop-blur-md"
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
                className={`flex items-center gap-1.5 px-3 sm:px-4 py-2 rounded-xl text-xs font-black transition-all ${
                  isActive
                    ? "btn-brass text-[#261b02] shadow-[0_4px_12px_rgba(255,199,44,0.35)] scale-100"
                    : "text-white/70 hover:text-white hover:bg-white/10"
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
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl bg-black/40 border border-white/10"
            title="Render output tier: Free (720p with watermark) vs Pro (1080p clean)"
          >
            <span className="text-[10px] font-black text-amber-300/80">MODE:</span>
            <div className="flex items-center bg-[#0a1e24] rounded-lg p-0.5 border border-white/10">
              <button
                type="button"
                onClick={() => handleModeSwitch("free")}
                className={`px-2 py-0.5 rounded-md text-[10px] font-black transition ${
                  renderMode === "free"
                    ? "bg-white/20 text-white shadow"
                    : "text-white/50 hover:text-white"
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
                    ? "bg-gradient-to-r from-amber-400 to-amber-500 text-black shadow font-black"
                    : "text-white/50 hover:text-white"
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
              className="flex items-center gap-1 px-3 py-1.5 rounded-xl bg-gradient-to-r from-amber-400 via-amber-500 to-amber-600 text-black font-black text-[10px] tracking-wider shadow-[0_4px_15px_rgba(255,199,44,0.4)] cursor-default"
              title={daysRemaining ? `Pro Subscription Active — ${daysRemaining} days remaining` : "Pro Subscription Active"}
            >
              <Crown className="w-3 h-3 fill-current" />
              <span>PRO ACTIVE{daysRemaining ? ` (${daysRemaining}d)` : ""}</span>
            </div>
          ) : (
            <button
              type="button"
              onClick={onOpenPricing}
              className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl font-black text-xs btn-brass text-[#261b02] shadow-[0_4px_15px_rgba(255,199,44,0.4)] hover:brightness-110 active:scale-95 transition"
              title="Unlock 1080p Full HD, Title Cards, and Watermark Removal"
            >
              <Crown className="w-3.5 h-3.5 text-amber-700 fill-amber-600" />
              <span>GET PRO</span>
            </button>
          )}

          {/* User Sign In / Account Status */}
          {user ? (
            <div className="flex items-center gap-1.5 pl-1 sm:pl-2 border-l border-white/10">
              <div
                className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl bg-black/40 border border-white/10 text-white"
                title={`Signed in as ${user.email}${user.isPro ? " (Pro Account)" : ""}`}
              >
                {user.picture ? (
                  <img
                    src={user.picture}
                    alt={user.name || user.email}
                    className="w-4 h-4 rounded-full object-cover border border-amber-400 shrink-0"
                  />
                ) : (
                  <div className="w-4 h-4 rounded-full bg-amber-400/30 text-amber-300 flex items-center justify-center font-black text-[9px] shrink-0">
                    {(user.name || user.email || "U")[0].toUpperCase()}
                  </div>
                )}
                <span className="text-[10px] sm:text-[11px] font-black max-w-[80px] sm:max-w-[120px] truncate">
                  {user.name || user.email.split("@")[0]}
                </span>
              </div>
              <button
                type="button"
                onClick={signOut}
                className="p-1.5 rounded-xl bg-black/40 border border-white/10 text-white/60 hover:text-red-400 hover:bg-white/5 active:scale-95 transition"
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
              className="px-3 py-1.5 rounded-xl bg-gradient-to-b from-[#ffd152] via-[#ffbe1a] to-[#d99700] text-[#261b02] hover:brightness-110 transition flex items-center gap-1.5 text-[11px] font-black shadow-[0_4px_12px_rgba(255,199,44,0.35)] active:scale-95"
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
