"use client";

import { Download, Film, Sparkles } from "lucide-react";

export function VideoStage({ videoUrl, aspectRatio = "9:16", isRendering }) {
  const aspectClass =
    aspectRatio === "1:1"
      ? "aspect-square max-w-[420px]"
      : aspectRatio === "16:9"
      ? "aspect-video max-w-[620px]"
      : "aspect-[9/16] max-w-[340px]"; // 9:16 default

  return (
    <div className="flex flex-col items-center justify-center w-full h-full p-2">
      {/* Viewport container */}
      <div
        className={`w-full ${aspectClass} rounded-2xl overflow-hidden relative shadow-2xl border-4 border-[#242b38] bg-[#090b10] flex items-center justify-center transition-all duration-300`}
      >
        {videoUrl ? (
          <video
            src={videoUrl}
            controls
            autoPlay
            loop
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="flex flex-col items-center justify-center text-center p-6 space-y-4">
            <div className="w-16 h-16 rounded-2xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
              <Film className="w-8 h-8" />
            </div>
            <div>
              <p className="font-extrabold text-white text-base">Studio Preview Canvas</p>
              <p className="text-xs text-gray-400 mt-1 max-w-[240px]">
                Upload music and photos, choose your template, and hit Render Reel!
              </p>
            </div>
            {/* Animated equalizer bars */}
            <div className="flex items-center gap-1.5 pt-2">
              {[40, 70, 30, 85, 55, 90, 45, 65, 35].map((h, i) => (
                <div
                  key={i}
                  className="w-1.5 bg-amber-500/50 rounded-full animate-pulse"
                  style={{
                    height: `${h * 0.4}px`,
                    animationDelay: `${i * 120}ms`,
                  }}
                />
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Download Action Bar */}
      {videoUrl && (
        <div className="mt-4 flex items-center gap-3">
          <a
            href={videoUrl}
            download="SnapBeat_Reel.mp4"
            className="flex items-center gap-2 px-6 py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 hover:from-emerald-400 hover:to-teal-300 text-black font-extrabold text-sm shadow-lg shadow-emerald-500/20 transition transform hover:scale-[1.02] active:scale-[0.98]"
          >
            <Download className="w-4 h-4 stroke-[2.5]" />
            <span>DOWNLOAD HD REEL (MP4)</span>
          </a>
        </div>
      )}
    </div>
  );
}
