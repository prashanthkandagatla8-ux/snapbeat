"use client";

import React, { useState, useEffect, useRef } from "react";
import { Crown, X, Volume2, VolumeX, ArrowRight, Sparkles } from "lucide-react";

export default function RetroVideoAdModal({ isOpen, onComplete, onClose, onOpenPricing }) {
  const [timeLeft, setTimeLeft] = useState(5);
  const [canSkip, setCanSkip] = useState(false);
  const [isMuted, setIsMuted] = useState(true); // Default muted to comply with browser autoplay policy
  const videoRef = useRef(null);

  useEffect(() => {
    if (!isOpen) {
      setTimeLeft(5);
      setCanSkip(false);
      return;
    }

    setTimeLeft(5);
    setCanSkip(false);

    if (videoRef.current) {
      videoRef.current.currentTime = 0;
      videoRef.current.play().catch(() => {});
    }

    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          setCanSkip(true);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [isOpen]);

  // Handle keyboard escape once countdown is complete
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === "Escape" && canSkip) {
        if (onClose) onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, canSkip, onClose]);

  if (!isOpen) return null;

  const handleFinish = () => {
    if (typeof onComplete === "function") {
      onComplete();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-fadeIn"
      role="dialog"
      aria-modal="true"
      aria-labelledby="ad-modal-title"
    >
      <div className="relative w-full max-w-lg sky-glass-panel rounded-3xl p-6 sm:p-7 shadow-2xl border border-white/20 animate-scaleUp text-white">
        {/* Top Header */}
        <div className="flex items-center justify-between border-b border-white/10 pb-3 mb-4 px-1">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-amber-400 animate-ping" />
            <span id="ad-modal-title" className="font-mono text-xs font-black text-amber-300 uppercase tracking-wider flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5 text-amber-400" />
              SPONSORED SPOTLIGHT • FREE EXPORT
            </span>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={onOpenPricing}
              className="flex items-center gap-1 text-[10px] font-black text-amber-300 hover:text-white transition cursor-pointer"
            >
              <Crown className="w-3 h-3" />
              <span>PRO PASS (SOON)</span>
            </button>
            {canSkip && onClose && (
              <button
                type="button"
                onClick={onClose}
                className="w-7 h-7 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition cursor-pointer"
                title="Dismiss"
                aria-label="Dismiss Ad"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>

        {/* Video Ad Player Screen */}
        <div className="relative aspect-video w-full rounded-2xl overflow-hidden bg-black border border-white/15 shadow-2xl mb-4">
          <video
            ref={videoRef}
            src="/assets/videos/showcase_reel.mp4"
            autoPlay
            loop
            muted={isMuted}
            playsInline
            className="w-full h-full object-cover"
          />

          {/* Floating Timer Badge */}
          <div className="absolute top-3 left-3 px-3 py-1 rounded-full bg-black/80 backdrop-blur-md border border-white/20 text-white font-mono text-xs font-black shadow flex items-center gap-1.5">
            {canSkip ? (
              <span className="text-emerald-400 font-bold">READY TO DOWNLOAD</span>
            ) : (
              <span className="text-amber-300">UNLOCKS IN {timeLeft}S</span>
            )}
          </div>

          {/* Sound Toggle */}
          <button
            type="button"
            onClick={() => setIsMuted(!isMuted)}
            aria-label={isMuted ? "Unmute audio" : "Mute audio"}
            className="absolute top-3 right-3 p-2 rounded-full bg-black/80 text-white hover:text-amber-400 transition cursor-pointer"
          >
            {isMuted ? <VolumeX className="w-4 h-4" /> : <Volume2 className="w-4 h-4 text-emerald-400" />}
          </button>

          {/* Progress Bar */}
          <div className="absolute bottom-0 left-0 right-0 h-1.5 bg-black/60">
            <div
              className="h-full bg-gradient-to-r from-amber-500 to-amber-300 transition-all duration-1000 ease-linear"
              style={{ width: `${((5 - timeLeft) / 5) * 100}%` }}
            />
          </div>
        </div>

        {/* Ad Info & Action */}
        <div className="space-y-3 text-center">
          <div className="flex items-center justify-center gap-2">
            <img
              src="/assets/images/snapbeat_logo_3d.png"
              alt="SnapBeat"
              className="h-5 object-contain drop-shadow"
            />
            <span className="text-xs font-black text-amber-300 uppercase tracking-wider">FREE HD REEL EXPORT</span>
          </div>

          <p className="text-xs font-medium text-amber-100/80">
            {canSkip
              ? "Your beat-synchronized MP4 reel is unlocked!"
              : "Thank you for creating with SnapBeat Free Tier. Your reel preview & download unlock momentarily."}
          </p>

          {canSkip ? (
            <button
              type="button"
              onClick={handleFinish}
              className="w-full py-3.5 rounded-full font-black text-sm uppercase tracking-wider btn-gold-radiant text-[#241903] shadow-xl hover:scale-105 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <span>UNLOCK REEL & ACCESS OUTPUT</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          ) : (
            <div className="w-full py-3.5 rounded-full bg-white/10 text-white/70 font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2 cursor-wait border border-white/10">
              <span className="w-2 h-2 rounded-full bg-amber-400 animate-ping mr-1" />
              <span>SPONSOR AD PLAYING ({timeLeft}S)...</span>
            </div>
          )}

          <p className="text-[11px] text-amber-200/60 font-medium">
            SnapBeat Free Public Beta • 100% Free Unlimited Video Renders
          </p>
        </div>
      </div>
    </div>
  );
}
