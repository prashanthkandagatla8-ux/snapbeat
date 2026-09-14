"use client";

import React, { useState, useRef, useEffect } from "react";
import {
  Clock,
  Download,
  Trash2,
  CheckCircle2,
  AlertTriangle,
  AlertCircle,
  RefreshCw,
  Sparkles,
  Play,
  Film,
  Lock,
  Crown,
} from "lucide-react";
import RetroVideoAdModal from "@/components/ads/RetroVideoAdModal";

export function RetroQueueConsole({
  jobId,
  isRendering,
  progress,
  stage,
  queuePosition,
  error,
  videoUrl,
  pastJobs = [],
  onClearCompleted,
  isPro = false,
  onOpenPricing,
  onRetry,
  onDismissError,
  onNewReel,
}) {
  const [isAdOpen, setIsAdOpen] = useState(false);
  const [unlockedJobs, setUnlockedJobs] = useState(() => {
    if (typeof window !== "undefined") {
      try {
        const stored = sessionStorage.getItem("snapbeat_unlocked_jobs");
        return stored ? JSON.parse(stored) : {};
      } catch (_) {
        return {};
      }
    }
    return {};
  });
  const [pendingDownload, setPendingDownload] = useState(null);

  // Active preview state (can be current render or selected from history)
  const [activePreviewUrl, setActivePreviewUrl] = useState(videoUrl);
  const [activePreviewTitle, setActivePreviewTitle] = useState(null);
  const previewVideoRef = useRef(null);
  const autoPromptTriggered = useRef(false);

  const markJobUnlocked = (key) => {
    if (!key) return;
    setUnlockedJobs((prev) => {
      const updated = { ...prev, [key]: true };
      if (typeof window !== "undefined") {
        try {
          sessionStorage.setItem("snapbeat_unlocked_jobs", JSON.stringify(updated));
        } catch (_) {}
      }
      return updated;
    });
  };

  // Sync activePreviewUrl when a new videoUrl finishes rendering & auto-prompt ad for free users
  useEffect(() => {
    if (videoUrl) {
      setActivePreviewUrl(videoUrl);
      setActivePreviewTitle(`SnapBeat Job #${jobId || "Reel"}`);
      // Free users auto-see full video ad to unlock output when render completes
      if (
        !isPro &&
        !unlockedJobs[videoUrl] &&
        !(jobId && unlockedJobs[jobId]) &&
        !autoPromptTriggered.current
      ) {
        autoPromptTriggered.current = true;
        setPendingDownload(null);
        setIsAdOpen(true);
      }
    }
  }, [videoUrl, jobId, isPro, unlockedJobs]);

  const currentDisplayVideo = activePreviewUrl || videoUrl;
  const currentKey = currentDisplayVideo || (jobId ? `job_${jobId}` : null);
  const isCurrentUnlocked =
    isPro ||
    (currentKey && Boolean(unlockedJobs[currentKey] || (jobId && unlockedJobs[jobId])));

  const handleDownloadClick = (e, targetUrl, fileName) => {
    const url = targetUrl || currentDisplayVideo;
    const name = fileName || `SnapBeat_${jobId || "Reel"}.mp4`;
    const isUnlocked =
      isPro || Boolean(unlockedJobs[url] || (jobId && unlockedJobs[jobId]));

    if (!isUnlocked) {
      if (e) e.preventDefault();
      setPendingDownload({ url, fileName: name });
      setIsAdOpen(true);
      return;
    }
  };

  const handleAdComplete = () => {
    setIsAdOpen(false);
    const key = pendingDownload?.url || currentDisplayVideo || (jobId ? `job_${jobId}` : "current");
    markJobUnlocked(key);
    if (currentDisplayVideo) markJobUnlocked(currentDisplayVideo);
    if (jobId) markJobUnlocked(jobId);

    // If download was pending, trigger it immediately
    if (pendingDownload?.url) {
      const link = document.createElement("a");
      link.href = pendingDownload.url;
      link.download = pendingDownload.fileName || `SnapBeat_${jobId || "Reel"}.mp4`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
    setPendingDownload(null);
  };

  const handleSelectPreview = (job) => {
    setActivePreviewUrl(job.videoUrl);
    setActivePreviewTitle(`Job #${job.id} • ${job.templateName || "Reel"}`);
    if (typeof window !== "undefined") {
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  };

  return (
    <div className="space-y-5 max-w-3xl mx-auto select-none">
      {/* Beta Serialization Notice Banner */}
      <div className="p-3 sm:p-3.5 rounded-2xl bg-amber-500/15 border border-amber-400/40 flex items-center justify-between gap-3 text-white">
        <div className="flex items-center gap-2.5">
          <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0" />
          <p className="text-xs text-amber-100/90 font-semibold leading-snug">
            <strong>Shared GPU Cluster:</strong> Free renders process sequentially (1-at-a-time). 100% free unlimited renders during Public Beta.
          </p>
        </div>
      </div>

      {/* ACTIVE JOB OR VIDEO PREVIEW CONSOLE */}
      <div className="sky-glass-panel text-white rounded-3xl p-4 sm:p-6 relative shadow-xl space-y-4">
        <div className="border-b border-white/10 pb-3 flex items-center justify-between flex-wrap gap-2">
          <div className="flex items-center gap-2">
            <span
              className={`w-2.5 h-2.5 rounded-full ${
                isRendering
                  ? "bg-amber-400 shadow-[0_0_8px_#f59e0b] animate-pulse"
                  : currentDisplayVideo
                  ? "bg-emerald-400 shadow-[0_0_8px_#10b981]"
                  : "bg-white/30"
              }`}
            />
            <h2 className="font-black text-xs sm:text-sm text-white uppercase tracking-wider">
              {isRendering
                ? "ACTIVE RENDER IN PROGRESS"
                : currentDisplayVideo
                ? "REEL VIDEO PREVIEW & EXPORT"
                : "RENDER QUEUE STATUS"}
            </h2>
          </div>

          {jobId && (
            <span className="px-2.5 py-0.5 rounded-full bg-black/50 border border-white/10 text-amber-300 font-mono font-bold text-[10px]">
              JOB #{jobId}
            </span>
          )}
        </div>

        {/* STATE 1: RENDERING IN PROGRESS */}
        {isRendering ? (
          <div className="bg-black/50 border border-white/10 text-white rounded-2xl p-5 sm:p-6 space-y-4">
            <div className="flex items-center justify-between gap-2 flex-wrap">
              <div className="flex items-center gap-2">
                {queuePosition > 0 ? (
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/20 text-amber-300 font-black text-xs border border-amber-400/40 animate-pulse">
                    <Clock className="w-3.5 h-3.5" />
                    <span>POSITION IN QUEUE: #{queuePosition}</span>
                  </div>
                ) : (
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 font-black text-xs border border-emerald-500/40">
                    <RefreshCw className="w-3.5 h-3.5 animate-spin text-emerald-400" />
                    <span>ENCODING AUDIO-VISUAL FRAMES</span>
                  </div>
                )}
              </div>

              <span className="font-mono text-sm font-black text-amber-300">
                {Math.round(progress)}% COMPLETED
              </span>
            </div>

            {/* Stage Description */}
            <div className="bg-[#0b1519] p-3 rounded-xl border border-white/10">
              <p className="text-[9px] font-mono text-white/50 uppercase tracking-widest">
                PIPELINE STAGE
              </p>
              <p className="font-mono text-xs font-bold text-amber-300 mt-0.5 truncate">
                {stage || "Analyzing audio waveform peaks and choreographing photo cuts..."}
              </p>
            </div>

            {/* Progress Bar Track */}
            <div className="w-full bg-[#0b1519] h-3.5 rounded-full p-0.5 border border-white/15 overflow-hidden">
              <div
                className="bg-gradient-to-r from-amber-500 via-amber-300 to-amber-500 h-full rounded-full transition-all duration-300 shadow"
                style={{ width: `${Math.max(5, progress)}%` }}
              />
            </div>
          </div>
        ) : error ? (
          /* STATE 2: RENDER ERROR */
          <div className="bg-black/50 border border-white/10 text-white rounded-2xl p-5 space-y-3">
            <div className="p-4 rounded-xl bg-red-500/15 border border-red-500/40 flex items-center gap-3">
              <AlertCircle className="w-5 h-5 text-red-400 shrink-0" />
              <div className="flex-1">
                <p className="font-black text-xs text-red-400 uppercase">RENDER FAILED</p>
                <p className="text-xs text-amber-100/70 mt-0.5">{error}</p>
              </div>
            </div>
            <div className="flex items-center justify-end gap-2">
              {onDismissError && (
                <button
                  type="button"
                  onClick={onDismissError}
                  className="px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-white font-black text-xs uppercase transition cursor-pointer"
                >
                  DISMISS
                </button>
              )}
              {onRetry && (
                <button
                  type="button"
                  onClick={onRetry}
                  className="px-4 py-1.5 rounded-xl btn-brass text-[#2b2820] font-black text-xs uppercase shadow hover:brightness-110 transition flex items-center gap-1.5 cursor-pointer"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  <span>RETRY RENDER</span>
                </button>
              )}
            </div>
          </div>
        ) : currentDisplayVideo ? (
          /* STATE 3: FULL VIDEO PREVIEW & EXPORT PLAYER */
          <div className="flex flex-col items-center space-y-4 bg-black/50 border border-amber-400/40 rounded-2xl sm:rounded-3xl p-4 sm:p-6 shadow-2xl">
            {/* Status Header */}
            <div className="w-full flex items-center justify-between border-b border-white/10 pb-2.5 flex-wrap gap-2">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                <span className="font-black text-xs text-white uppercase tracking-wider">
                  {activePreviewTitle || "REEL RENDER COMPLETED!"}
                </span>
              </div>
              <span className={`px-2 py-0.5 rounded-full font-mono text-[9px] font-bold border ${
                isCurrentUnlocked
                  ? "bg-emerald-500/20 text-emerald-300 border-emerald-500/40"
                  : "bg-amber-500/20 text-amber-300 border-amber-500/40"
              }`}>
                {isPro
                  ? "1080P MASTER OUTPUT"
                  : isCurrentUnlocked
                  ? "480P STANDARD • UNLOCKED"
                  : "480P STANDARD • LOCKED"}
              </span>
            </div>

            {/* Video Screen: Locked vs Unlocked */}
            {isCurrentUnlocked ? (
              /* Unlocked Live Video Screen */
              <div className="relative aspect-[9/16] w-full max-w-[260px] sm:max-w-[300px] rounded-2xl overflow-hidden bg-black border-2 border-amber-400/50 shadow-[0_20px_50px_rgba(0,0,0,0.9),0_0_20px_rgba(255,199,44,0.15)] group">
                <video
                  ref={previewVideoRef}
                  src={currentDisplayVideo}
                  controls
                  controlsList="nodownload"
                  autoPlay
                  loop
                  playsInline
                  className="w-full h-full object-cover"
                />
                {/* Scanlines Effect */}
                <div className="absolute inset-0 pointer-events-none crt-scanlines opacity-25" />
              </div>
            ) : (
              /* Locked Sponsor Screen */
              <div className="relative aspect-[9/16] w-full max-w-[260px] sm:max-w-[300px] rounded-2xl overflow-hidden bg-[#090e11] border-2 border-amber-400/50 shadow-[0_20px_50px_rgba(0,0,0,0.9),0_0_20px_rgba(255,199,44,0.15)] flex flex-col items-center justify-between p-6 text-center select-none group">
                {/* Scanlines Effect */}
                <div className="absolute inset-0 pointer-events-none crt-scanlines opacity-30" />
                <div className="absolute inset-0 pointer-events-none bg-[radial-gradient(circle_at_center,_transparent_30%,_rgba(0,0,0,0.85)_100%)] z-10" />

                {/* Top Header Tag */}
                <div className="z-20 w-full flex items-center justify-between border-b border-amber-400/20 pb-2 text-[9px] font-mono font-bold text-amber-300/80">
                  <span>SNAPBEAT SPONSOR VAULT</span>
                  <span className="px-1.5 py-0.5 rounded bg-amber-400/20 text-amber-300 font-black">
                    FREE TIER
                  </span>
                </div>

                {/* Center Lock Graphic & Call to Action */}
                <div className="z-20 my-auto flex flex-col items-center space-y-3 px-2 w-full">
                  <div className="relative">
                    <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-amber-500/20 to-amber-300/30 border border-amber-400/60 flex items-center justify-center text-amber-300 shadow-[0_0_25px_rgba(251,191,36,0.3)] animate-pulse">
                      <Lock className="w-8 h-8" />
                    </div>
                    <span className="absolute -bottom-1 -right-1 p-1 rounded-full bg-amber-500 text-black text-[9px]">
                      <Sparkles className="w-3 h-3" />
                    </span>
                  </div>

                  <div className="space-y-1">
                    <h3 className="text-sm sm:text-base font-black text-white uppercase tracking-wider">
                      OUTPUT VIDEO LOCKED
                    </h3>
                    <p className="text-[11px] text-amber-100/70 font-medium leading-relaxed max-w-[220px]">
                      Watch a 5-second sponsor video to unlock preview & MP4 download!
                    </p>
                  </div>

                  {/* Primary Radiant Unlock Button */}
                  <button
                    type="button"
                    onClick={() => {
                      setPendingDownload(null);
                      setIsAdOpen(true);
                    }}
                    className="w-full py-3 px-4 rounded-xl btn-gold-radiant text-[#261b02] font-black text-xs uppercase tracking-wider shadow-xl hover:scale-105 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer border border-[#fff4b8]"
                  >
                    <Play className="w-3.5 h-3.5 fill-current" />
                    <span>WATCH AD TO UNLOCK (5S)</span>
                  </button>

                  {/* Skip with Pro */}
                  <button
                    type="button"
                    onClick={onOpenPricing}
                    className="text-[10px] text-amber-300/70 hover:text-amber-200 font-bold uppercase tracking-wider flex items-center gap-1 transition cursor-pointer pt-1"
                  >
                    <Crown className="w-3 h-3 text-amber-400" />
                    <span>OR SKIP ADS WITH PRO PASS</span>
                  </button>
                </div>

                {/* Bottom CRT telemetry */}
                <div className="z-20 w-full flex items-center justify-between border-t border-white/10 pt-2 text-[8px] font-mono text-white/40">
                  <span>ENCODED: 480P MP4</span>
                  <span>LOCKED OUTPUT</span>
                </div>
              </div>
            )}

            {/* Action Bar: Download & Create Another Reel */}
            <div className="flex items-center justify-center gap-3 pt-1 flex-wrap w-full">
              {isCurrentUnlocked ? (
                <a
                  href={currentDisplayVideo}
                  download={`SnapBeat_${jobId || "Reel"}.mp4`}
                  className="btn-gold-radiant px-6 py-3 rounded-full text-xs font-black tracking-wider uppercase text-[#261b02] shadow-lg flex items-center gap-2 hover:scale-105 active:scale-95 transition cursor-pointer border border-[#fff4b8]"
                  title="Download MP4 to your device"
                >
                  <Download className="w-4 h-4" />
                  <span>DOWNLOAD REEL MP4</span>
                </a>
              ) : (
                <button
                  type="button"
                  onClick={() => {
                    setPendingDownload({
                      url: currentDisplayVideo,
                      fileName: `SnapBeat_${jobId || "Reel"}.mp4`,
                    });
                    setIsAdOpen(true);
                  }}
                  className="btn-gold-radiant px-6 py-3 rounded-full text-xs font-black tracking-wider uppercase text-[#261b02] shadow-lg flex items-center gap-2 hover:scale-105 active:scale-95 transition cursor-pointer border border-[#fff4b8]"
                  title="Watch sponsored video ad to unlock download"
                >
                  <Lock className="w-4 h-4" />
                  <span>UNLOCK WITH AD TO DOWNLOAD</span>
                </button>
              )}

              {onNewReel && (
                <button
                  type="button"
                  onClick={onNewReel}
                  className="px-5 py-3 rounded-full bg-white/10 hover:bg-white/20 text-white text-xs font-black tracking-wider uppercase border border-white/20 shadow active:scale-95 transition cursor-pointer"
                  title="Make another video reel"
                >
                  + CREATE ANOTHER REEL
                </button>
              )}
            </div>
          </div>
        ) : (
          /* STATE 4: QUEUE EMPTY */
          <div className="p-8 text-center text-white/50 space-y-1">
            <Clock className="w-8 h-8 mx-auto mb-2 opacity-40 text-amber-300" />
            <p className="font-black text-xs uppercase tracking-wider text-white/80">
              QUEUE IS CURRENTLY EMPTY
            </p>
            <p className="text-[11px] text-amber-100/60">
              Select music and photos, choose a motion template, and click Render Reel!
            </p>
          </div>
        )}
      </div>

      {/* COMPLETED RENDERS HISTORY (ACCOUNT & GUEST PERSISTED) */}
      {pastJobs.length > 0 && (
        <div className="sky-glass-panel text-white rounded-3xl p-4 sm:p-6 relative shadow-xl space-y-3">
          <div className="flex items-center justify-between border-b border-white/10 pb-2.5">
            <div className="flex items-center gap-2">
              <Film className="w-4 h-4 text-amber-400" />
              <h3 className="font-black text-xs sm:text-sm text-white uppercase tracking-wider">
                SAVED RENDERS HISTORY ({pastJobs.length})
              </h3>
            </div>
            {onClearCompleted && (
              <button
                type="button"
                onClick={onClearCompleted}
                className="text-[11px] font-bold text-red-400 hover:text-red-300 hover:underline flex items-center gap-1 transition cursor-pointer"
                title="Clear all saved renders from this device"
              >
                <Trash2 className="w-3.5 h-3.5" />
                <span>CLEAR</span>
              </button>
            )}
          </div>

          <div className="space-y-2 max-h-[260px] overflow-y-auto pr-1">
            {pastJobs.map((job) => {
              const isSelected = activePreviewUrl === job.videoUrl;
              return (
                <div
                  key={job.id}
                  className={`p-3 rounded-2xl border transition flex items-center justify-between gap-3 ${
                    isSelected
                      ? "bg-amber-500/20 border-amber-400/70 shadow-md"
                      : "bg-black/40 border-white/10 hover:border-white/20"
                  }`}
                >
                  <div className="min-w-0">
                    <p className="font-black text-xs text-white truncate">
                      Job #{job.id} • {job.templateName || "Kinetic Reel"}
                    </p>
                    <p className="text-[10px] text-amber-100/60 truncate">
                      {job.quality === "master" ? "1080p Master" : "480p Standard"} •{" "}
                      {job.createdAt
                        ? new Date(job.createdAt).toLocaleTimeString([], {
                            hour: "2-digit",
                            minute: "2-digit",
                          })
                        : "Recent"}
                    </p>
                  </div>

                  {job.videoUrl && (
                    <div className="flex items-center gap-2 shrink-0">
                      {/* Preview Button */}
                      <button
                        type="button"
                        onClick={() => handleSelectPreview(job)}
                        className={`px-2.5 py-1 rounded-xl text-[10px] font-black uppercase tracking-wider transition cursor-pointer flex items-center gap-1 ${
                          isSelected
                            ? "bg-amber-400 text-black shadow"
                            : "bg-white/10 hover:bg-white/20 text-amber-300 border border-amber-400/30"
                        }`}
                        title="Preview video in player above"
                      >
                        {isPro || unlockedJobs[job.videoUrl] || unlockedJobs[job.id] ? (
                          <Play className="w-3 h-3 fill-current" />
                        ) : (
                          <Lock className="w-3 h-3 text-amber-400" />
                        )}
                        <span>
                          {isPro || unlockedJobs[job.videoUrl] || unlockedJobs[job.id]
                            ? "PREVIEW"
                            : "UNLOCK"}
                        </span>
                      </button>

                      {/* Download Button */}
                      {isPro || unlockedJobs[job.videoUrl] || unlockedJobs[job.id] ? (
                        <a
                          href={job.videoUrl}
                          download={`SnapBeat_${job.id}.mp4`}
                          className="p-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-white transition cursor-pointer border border-white/15"
                          title="Download MP4"
                          aria-label="Download MP4"
                        >
                          <Download className="w-3.5 h-3.5" />
                        </a>
                      ) : (
                        <button
                          type="button"
                          onClick={() => {
                            setPendingDownload({
                              url: job.videoUrl,
                              fileName: `SnapBeat_${job.id}.mp4`,
                            });
                            setIsAdOpen(true);
                          }}
                          className="p-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-amber-400 transition cursor-pointer border border-amber-400/30"
                          title="Unlock with Ad to Download"
                          aria-label="Unlock with Ad to Download"
                        >
                          <Lock className="w-3.5 h-3.5" />
                        </button>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* INTERSTITIAL VIDEO AD MODAL FOR FREE TIER DOWNLOADS */}
      <RetroVideoAdModal
        isOpen={isAdOpen}
        onComplete={handleAdComplete}
        onClose={() => setIsAdOpen(false)}
        onOpenPricing={onOpenPricing}
      />
    </div>
  );
}
