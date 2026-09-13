"use client";

import { Clock, AlertCircle, X, Loader2 } from "lucide-react";

export function ProgressOverlay({ isRendering, progress = 0, stage, queuePosition = 0, error, onCancel }) {
  if (!isRendering && !error) return null;

  return (
    <div className="absolute inset-0 bg-[#0d0c0b]/90 backdrop-blur-md rounded-2xl flex flex-col items-center justify-center p-6 z-30 transition-all select-none">
      {/* Subtle scanline overlay */}
      <div className="absolute inset-0 pointer-events-none opacity-20 bg-[repeating-linear-gradient(0deg,#000,#000_2px,transparent_2px,transparent_4px)] rounded-2xl" />

      <div className="w-full max-w-xs text-center space-y-4 z-10">
        {error ? (
          <div className="space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-rose-500/20 border-2 border-rose-500/50 text-rose-400 flex items-center justify-center mx-auto shadow-lg shadow-rose-500/10">
              <AlertCircle className="w-6 h-6" />
            </div>
            <div>
              <p className="font-black text-white text-sm uppercase tracking-wider">Render Interrupted</p>
              <p className="text-xs text-rose-300 mt-1 leading-relaxed">{error}</p>
            </div>
            {onCancel && (
              <button
                type="button"
                onClick={onCancel}
                className="px-4 py-2 rounded-xl btn-brass text-[#2b2820] font-black text-xs uppercase shadow hover:brightness-110 transition"
              >
                Dismiss & Try Again
              </button>
            )}
          </div>
        ) : (
          <div className="space-y-4">
            {/* Queue Badge */}
            {queuePosition > 0 && (
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#ffc72c] text-[#2b2820] border border-[#bf8a00] text-xs font-black tracking-wide shadow animate-pulse">
                <Clock className="w-3.5 h-3.5" />
                <span>IN QUEUE • POSITION #{queuePosition}</span>
              </div>
            )}

            {/* Retro Numeric Dial Spinner */}
            <div className="relative flex items-center justify-center w-20 h-20 mx-auto">
              <Loader2 className="w-16 h-16 text-[#ffc72c] animate-spin stroke-[2]" />
              <span className="absolute font-mono font-black text-amber-300 text-sm">
                {Math.round(progress)}%
              </span>
            </div>

            {/* Stage Text */}
            <div className="bg-[#1e1c1a] p-3 rounded-xl border border-[#3a3835]">
              <p className="font-mono text-[10px] text-gray-400 uppercase tracking-widest">
                STAGE MONITOR
              </p>
              <p className="font-mono text-xs font-bold text-amber-400 mt-0.5 truncate">
                {stage || "Synchronizing frames & rendering audio..."}
              </p>
            </div>

            {/* Progress Bar */}
            <div className="w-full bg-[#1e1c1a] h-3 rounded-full p-0.5 border border-[#3a3835] overflow-hidden shadow-inner">
              <div
                className="bg-gradient-to-r from-[#ffc72c] via-[#ffe082] to-[#ffc72c] h-full rounded-full transition-all duration-300 shadow"
                style={{ width: `${Math.max(5, progress)}%` }}
              />
            </div>

            {onCancel && (
              <button
                type="button"
                onClick={onCancel}
                className="text-[11px] font-bold text-gray-400 hover:text-white pt-1 flex items-center gap-1 mx-auto transition"
              >
                <X className="w-3.5 h-3.5" />
                <span>Cancel Render</span>
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
