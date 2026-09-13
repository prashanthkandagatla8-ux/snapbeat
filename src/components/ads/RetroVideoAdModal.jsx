"use client";

import React, { useState, useEffect, useRef } from "react";
import { Crown, Sparkles, X, Volume2, VolumeX, CheckCircle, ArrowRight } from "lucide-react";

export default function RetroVideoAdModal({ isOpen, onComplete, onClose, onOpenPricing }) {
  const [timeLeft, setTimeLeft] = useState(5);
  const [canSkip, setCanSkip] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const videoRef = useRef(null);

  useEffect(() => {
    if (!isOpen) {
      setTimeLeft(5);
      setCanSkip(false);
      return;
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

  if (!isOpen) return null;

  const handleFinish = () => {
    onComplete();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-fadeIn">
      <div className="relative w-full max-w-lg metal-panel rounded-3xl p-6 sm:p-7 shadow-2xl border-4 border-[#7a766f] animate-scaleUp">
        {/* Screws */}
        <div className="metal-screw top-3 left-3" />
        <div className="metal-screw top-3 right-3" />
        <div className="metal-screw bottom-3 left-3" />
        <div className="metal-screw bottom-3 right-3" />

        {/* Top Header */}
        <div className="flex items-center justify-between border-b border-[#8f8677]/60 pb-2 mb-3">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-ping" />
            <span className="font-mono text-xs font-black text-[#2b2b2d] uppercase tracking-wider">
              SPONSORED BROADCAST (AD 1 OF 1)
            </span>
          </div>

          <button
            onClick={onOpenPricing}
            className="flex items-center gap-1 text-[10px] font-black text-amber-700 hover:text-black transition"
          >
            <Crown className="w-3 h-3" />
            <span>SKIP ADS WITH PRO</span>
          </button>
        </div>

        {/* Video Ad Player Screen */}
        <div className="relative aspect-video w-full rounded-2xl overflow-hidden bg-black border-2 border-[#2b2b2d] shadow-inner mb-4">
          <video
            ref={videoRef}
            src="/assets/videos/showcase_reel.mp4"
            autoPlay
            loop
            muted={isMuted}
            playsInline
            className="w-full h-full object-cover"
          />

          {/* CRT Scanline */}
          <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,_transparent_40%,_rgba(0,0,0,0.7)_100%)]" />

          {/* Floating Timer Badge */}
          <div className="absolute top-3 left-3 px-3 py-1 rounded-full bg-black/80 backdrop-blur-md border border-white/20 text-white font-mono text-xs font-black shadow flex items-center gap-1.5">
            {canSkip ? (
              <span className="text-green-400">REEL READY</span>
            ) : (
              <span>UNLOCKS IN {timeLeft}S</span>
            )}
          </div>

          {/* Sound Toggle */}
          <button
            onClick={() => setIsMuted(!isMuted)}
            className="absolute top-3 right-3 p-2 rounded-full bg-black/80 text-white hover:text-amber-400 transition"
          >
            {isMuted ? <VolumeX className="w-3.5 h-3.5" /> : <Volume2 className="w-3.5 h-3.5" />}
          </button>

          {/* Progress Bar */}
          <div className="absolute bottom-0 left-0 right-0 h-1.5 bg-black/50">
            <div
              className="h-full bg-amber-400 transition-all duration-1000 ease-linear"
              style={{ width: `${((5 - timeLeft) / 5) * 100}%` }}
            />
          </div>
        </div>

        {/* Ad Info & Action */}
        <div className="space-y-3 text-center">
          <p className="text-xs font-bold text-[#4a4743]">
            {canSkip
              ? "Your beat-synchronized MP4 reel is ready for download!"
              : "Thank you for supporting SnapBeat Free. Your download unlocks in a few seconds."}
          </p>

          {canSkip ? (
            <button
              onClick={handleFinish}
              className="w-full py-3.5 rounded-2xl font-black text-sm uppercase tracking-wider btn-brass text-[#2b2820] shadow-xl hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2"
            >
              <span>CONTINUE TO DOWNLOAD REEL</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          ) : (
            <div className="w-full py-3.5 rounded-2xl bg-[#7a766f] text-white font-black text-xs uppercase tracking-wider flex items-center justify-center gap-2 cursor-wait">
              <span>PLEASE WAIT ({timeLeft}S)...</span>
            </div>
          )}

          <p className="text-[10px] text-[#6e695f] font-semibold">
            Want an ad-free experience?{" "}
            <span
              onClick={onOpenPricing}
              className="text-amber-700 font-bold underline cursor-pointer hover:text-black"
            >
              Upgrade to Pro for just ₹99/week
            </span>
          </p>
        </div>
      </div>
    </div>
  );
}
