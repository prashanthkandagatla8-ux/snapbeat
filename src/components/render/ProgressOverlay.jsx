"use client";

import { Clock, AlertCircle, X, Loader2 } from "lucide-react";

export function ProgressOverlay({ isRendering, progress, stage, queuePosition, error, onCancel }) {
  if (!isRendering && !error) return null;

  return (
    <div className="absolute inset-0 bg-black/85 backdrop-blur-md rounded-2xl flex flex-col items-center justify-center p-6 z-20 transition-all">
      <div className="w-full max-w-xs text-center space-y-4">
        {error ? (
          <div className="space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-rose-500/20 border border-rose-500/40 text-rose-400 flex items-center justify-center mx-auto">
              <AlertCircle className="w-6 h-6" />
            </div>
            <div>
              <p className="font-bold text-white text-sm">Render Failed</p>
              <p className="text-xs text-rose-300 mt-1">{error}</p>
            </div>
            <button
              onClick={onCancel}
              className="px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white font-bold text-xs transition"
            >
              Close & Try Again
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            {/* Queue Badge */}
            {queuePosition > 0 && (
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/15 border border-amber-500/30 text-amber-400 text-xs font-extrabold tracking-wide animate-pulse">
                <Clock className="w-3.5 h-3.5" />
                <span>IN QUEUE • POSITION #{queuePosition}</span>
              </div>
            )}

            {/* Spinner */}
            <div className="relative flex items-center justify-center w-20 h-20 mx-auto">
              <Loader2 className="w-16 h-16 text-amber-400 animate-spin stroke-[1.5]" />
              <span className="absolute font-extrabold text-white text-sm">
                {Math.round(progress)}%
              </span>
            </div>

            {/* Stage Text */}
            <div>
              <p className="font-bold text-white text-sm">Rendering Your Reel</p>
              <p className="text-xs text-gray-300 mt-1 truncate">
                {stage || "Processing audio & video frames..."}
              </p>
              <p className="text-[10px] text-gray-400 mt-2">
                Free renders process in a shared 1-at-a-time serialized queue.
              </p>
            </div>

            {/* Progress Bar */}
            <div className="w-full bg-[#242b38] h-2 rounded-full overflow-hidden">
              <div
                className="bg-gradient-to-r from-amber-500 to-yellow-300 h-full rounded-full transition-all duration-300"
                style={{ width: `${Math.max(5, progress)}%` }}
              />
            </div>

            <button
              onClick={onCancel}
              className="text-[11px] text-gray-400 hover:text-white pt-2 flex items-center gap-1 mx-auto transition"
            >
              <X className="w-3.5 h-3.5" />
              <span>Cancel</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
