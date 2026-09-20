"use client";

import React from "react";
import { useAuth } from "@/context/AuthContext";
import {
  Crown,
  Music,
  Images,
  Sliders,
  ListOrdered,
  Film,
  User,
  LogOut,
} from "lucide-react";

export function RetroHeader({
  currentTab,
  setCurrentTab,
  isPro,
  daysRemaining,
  onOpenPricing,
  serverOnline,
  activeQueueCount = 0,
  onShowcaseClick,
}) {
  const { user, openAuthModal, signOut } = useAuth();

  const TABS = [
    { id: "music", label: "MUSIC", icon: Music, desc: "Soundtrack & Audio Trim" },
    { id: "photos", label: "PHOTOS", icon: Images, desc: "Photo Strips & Auto-Arrange" },
    { id: "render", label: "RENDER", icon: Sliders, desc: "Templates, Aspect Ratio & Render" },
    { id: "queue", label: "QUEUE", icon: ListOrdered, desc: "Render Progress & Downloads" },
  ];

  return (
    <header className="w-full bg-[#081b20]/90 backdrop-blur-xl border-b border-[#d4af37]/25 px-2 sm:px-4 py-2 sticky top-0 z-40 relative shadow-lg select-none text-white">
      <div className="w-full flex flex-row items-center justify-between gap-1.5 sm:gap-2 flex-nowrap overflow-x-auto no-scrollbar">
        {/* Left: SnapBeat 3D Logo + STUDIO Badge + Server Status + Showcase Link */}
        <div className="flex items-center gap-1.5 sm:gap-2 flex-nowrap shrink-0">
          <div
            onClick={onShowcaseClick}
            className={`flex items-center gap-1.5 sm:gap-2 ${
              onShowcaseClick ? "cursor-pointer group" : ""
            }`}
            title={onShowcaseClick ? "Return to Showcase Home" : "SnapBeat"}
            role={onShowcaseClick ? "button" : undefined}
            tabIndex={onShowcaseClick ? 0 : undefined}
            onKeyDown={(e) => {
              if (onShowcaseClick && (e.key === "Enter" || e.key === " ")) {
                onShowcaseClick();
              }
            }}
          >
            <img
              src="/assets/images/snapbeat_logo_3d.png"
              alt="SnapBeat"
              className="h-7 sm:h-8 md:h-9 w-auto object-contain group-hover:brightness-110 transition drop-shadow-[0_2px_10px_rgba(0,0,0,0.7)] shrink-0"
            />
            <div
              className="hidden lg:flex items-center gap-1 px-1.5 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-[8px] font-bold text-emerald-400 shrink-0"
              title={serverOnline ? "GPU cluster is online" : "GPU render cluster offline"}
            >
              <div
                className={
                  serverOnline
                    ? "w-1.5 h-1.5 rounded-full bg-emerald-400 shadow-[0_0_6px_#34d399] animate-pulse"
                    : "w-1.5 h-1.5 rounded-full bg-red-500 shadow-[0_0_6px_#ef4444] animate-pulse"
                }
              />
              <span>{serverOnline ? "ONLINE" : "OFFLINE"}</span>
            </div>
          </div>

          {/* Return to Showcase Button */}
          {onShowcaseClick && (
            <button
              type="button"
              onClick={onShowcaseClick}
              className="flex items-center gap-1 px-2 py-1 rounded-lg bg-amber-500/15 hover:bg-amber-500/25 text-amber-300 text-[10px] font-black tracking-wide transition border border-amber-500/30 active:scale-95 shadow-sm cursor-pointer shrink-0"
              title="View Sample Render Showcase Reel"
              aria-label="Return to Showcase Home"
            >
              <Film className="w-3 h-3 text-amber-400 shrink-0" />
              <span>SHOWCASE</span>
            </button>
          )}
        </div>

        {/* Right: FREE vs PRO Mode Switcher + Pro Pass + User Account */}
        <div className="flex items-center gap-1.5 sm:gap-2 flex-nowrap shrink-0">
          {/* Non-Switchable Tier Status: Automatically reflects active Pro pass or Free tier */}
          {isPro ? (
            <div
              className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-gradient-to-r from-amber-400 via-amber-500 to-amber-600 text-black font-black text-[10px] tracking-wider shadow-[0_4px_15px_rgba(255,199,44,0.4)] cursor-default select-none shrink-0"
              title={daysRemaining ? `SnapBeat Pro Active — ${daysRemaining} days remaining` : "SnapBeat Pro Active (1080p Master & Watermark-Free)"}
            >
              <Crown className="w-3 h-3 fill-current" />
              <span>PRO ACTIVE{daysRemaining ? ` (${daysRemaining}d)` : ""}</span>
            </div>
          ) : (
            <div className="flex items-center gap-1.5 shrink-0">
              <div
                className="flex items-center gap-1 px-2 py-0.5 sm:py-1 rounded-xl bg-black/40 border border-white/10 text-white/70 text-[9px] font-mono font-bold select-none shrink-0"
                title="Free Tier: 480p output with top-left watermark"
              >
                <span>FREE TIER</span>
              </div>
              {/* <button
                type="button"
                onClick={onOpenPricing}
                className="flex items-center gap-1 px-2 sm:px-2.5 py-1 rounded-xl font-black text-[10px] btn-brass text-[#261b02] shadow-[0_4px_15px_rgba(255,199,44,0.4)] hover:brightness-110 active:scale-95 transition cursor-pointer shrink-0"
                title="Unlock 1080p Master, Watermark Removal & Pro Features"
              >
                <Crown className="w-3 h-3 text-amber-800 fill-amber-700 shrink-0" />
                <span>UPGRADE</span>
              </button> */}
            </div>
          )}

          {/* User Sign In / Account Status */}
          {user ? (
            <div className="flex items-center gap-1 pl-1 border-l border-white/10 shrink-0">
              <div
                className="flex items-center gap-1.5 px-2 py-1 rounded-xl bg-black/40 border border-white/10 text-white shrink-0"
                title={`Signed in as ${user.email}${user.isPro ? " (Pro Account)" : ""}`}
              >
                {user.picture ? (
                  <img
                    src={user.picture}
                    alt={user.name || user.email}
                    className="w-4 h-4 rounded-full object-cover border border-amber-400 shrink-0"
                  />
                ) : (
                  <div className="w-4 h-4 rounded-full bg-amber-400/30 text-amber-300 flex items-center justify-center font-black text-[8px] shrink-0">
                    {(user.name || user.email || "U")[0].toUpperCase()}
                  </div>
                )}
                <span className="text-[10px] font-black max-w-[65px] sm:max-w-[90px] truncate">
                  {user.name || user.email.split("@")[0]}
                </span>
                {user.isGuest && (
                  <span className="px-1 py-0.2 rounded bg-amber-400/30 text-amber-300 text-[7px] font-mono font-black uppercase tracking-wider border border-amber-400/50 shrink-0">
                    GUEST
                  </span>
                )}
              </div>
              <button
                type="button"
                onClick={signOut}
                className="p-1 rounded-lg bg-black/40 border border-white/10 text-white/60 hover:text-red-400 hover:bg-white/5 active:scale-95 transition cursor-pointer shrink-0"
                title="Sign Out"
                aria-label="Sign Out"
              >
                <LogOut className="w-3 h-3" />
              </button>
            </div>
          ) : (
            <button
              type="button"
              onClick={openAuthModal}
              className="px-2.5 py-1 rounded-xl bg-gradient-to-b from-[#ffd152] via-[#ffbe1a] to-[#d99700] text-[#261b02] hover:brightness-110 transition flex items-center gap-1 text-[10px] font-black shadow active:scale-95 cursor-pointer shrink-0"
              title="Sign In with Email or Google"
            >
              <User className="w-3 h-3" />
              <span>Sign In</span>
            </button>
          )}
        </div>
      </div>

      {/* Second Panel: Tactile 4-Button Workflow Console (All 4 Buttons Displayed at Once, No Arrows) */}
      <div className="w-full pt-2">
        <nav
          className="w-full grid grid-cols-4 gap-1 sm:gap-2 p-1 rounded-xl bg-black/50 border border-[#d4af37]/20 backdrop-blur-md shadow-inner"
          aria-label="Workflow Navigation"
        >
          {TABS.map((tab) => {
            const Icon = tab.icon;
            const isSelected = currentTab === tab.id;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setCurrentTab(tab.id)}
                className={`relative flex items-center justify-center gap-1 sm:gap-2 py-1.5 sm:py-2 px-1 sm:px-2 rounded-lg text-[10px] sm:text-xs font-black tracking-wider transition-all duration-200 cursor-pointer select-none ${
                  isSelected
                    ? "btn-brass text-[#261b02] shadow-[0_2px_12px_rgba(255,199,44,0.4)] ring-1 ring-amber-300 scale-[1.02]"
                    : "bg-black/30 hover:bg-white/10 text-white/50 hover:text-white/90 border border-white/5 hover:border-white/15 opacity-65 hover:opacity-100 active:scale-95"
                }`}
                title={`${tab.label} — ${tab.desc}`}
                aria-current={isSelected ? "page" : undefined}
              >
                {/* Active illuminated pip */}
                <span
                  className={`w-1.5 h-1.5 rounded-full shrink-0 transition-colors ${
                    isSelected
                      ? "bg-emerald-500 shadow-[0_0_8px_#10b981]"
                      : "bg-white/20"
                  }`}
                />

                <Icon
                  className={`w-3.5 h-3.5 shrink-0 ${
                    isSelected ? "text-[#261b02]" : "text-white/60"
                  }`}
                />

                <span className="uppercase truncate">{tab.label}</span>

                {/* Queue rendering badge */}
                {tab.id === "queue" && activeQueueCount > 0 && (
                  <span className="w-2 h-2 rounded-full bg-[#d62828] animate-pulse shrink-0 ml-0.5" />
                )}
              </button>
            );
          })}
        </nav>
      </div>
    </header>
  );
}
