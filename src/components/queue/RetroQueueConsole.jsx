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
  Crown,
  Volume2,
  VolumeX,
} from "lucide-react";

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
  const [isAdMuted, setIsAdMuted] = useState(true);
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

  // YouTube-Style Pre-Roll In-Stream Ad State
  const AD_DURATION = 8;
  const [isPlayingPreRoll, setIsPlayingPreRoll] = useState(false);
  const [preRollTimeLeft, setPreRollTimeLeft] = useState(AD_DURATION);
  const preRollTimerRef = useRef(null);
  const directLink = process.env.NEXT_PUBLIC_MONETAG_DIRECT_LINK || "https://omg10.com/4/11799879";

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

  const currentDisplayVideo = activePreviewUrl || videoUrl;
  const currentKey = currentDisplayVideo || (jobId ? `job_${jobId}` : null);
  const isCurrentUnlocked =
    isPro ||
    (currentKey && Boolean(unlockedJobs[currentKey] || (jobId && unlockedJobs[jobId])));

  const finishPreRollAd = (pending) => {
    setIsPlayingPreRoll(false);
    const key = pending?.url || currentDisplayVideo || (jobId ? `job_${jobId}` : "current");
    markJobUnlocked(key);
    if (currentDisplayVideo) markJobUnlocked(currentDisplayVideo);
    if (jobId) markJobUnlocked(jobId);

    // Smoothly start playing the rendered reel now that ad has concluded
    setTimeout(() => {
      if (previewVideoRef.current) {
        previewVideoRef.current.currentTime = 0;
        previewVideoRef.current.play().catch(() => {});
      }
    }, 150);

    // If user clicked download before watching, trigger download now
    if (pending?.url) {
      const link = document.createElement("a");
      link.href = pending.url;
      link.download = pending.fileName || `SnapBeat_${jobId || "Reel"}.mp4`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
    setPendingDownload(null);
  };

  const triggerPreRollAd = (targetUrl, targetName) => {
    let pending = null;
    if (targetUrl && targetName) {
      pending = { url: targetUrl, fileName: targetName };
      setPendingDownload(pending);
    }

    // Open sponsor link in background on click
    if (directLink && typeof window !== "undefined") {
      try {
        window.open(directLink, "_blank", "noopener,noreferrer");
      } catch (e) {
        console.warn("Sponsor tab prevented:", e);
      }
    }

    // Start 8-second YouTube-style non-skippable pre-roll
    setIsPlayingPreRoll(true);
    setPreRollTimeLeft(AD_DURATION);

    if (preRollTimerRef.current) clearInterval(preRollTimerRef.current);
    preRollTimerRef.current = setInterval(() => {
      setPreRollTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(preRollTimerRef.current);
          preRollTimerRef.current = null;
          finishPreRollAd(pending);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  // Clean up timer on unmount
  useEffect(() => {
    return () => {
      if (preRollTimerRef.current) {
        clearInterval(preRollTimerRef.current);
      }
    };
  }, []);

  // Sync activePreviewUrl when a new videoUrl finishes rendering & trigger pre-roll for free users
  useEffect(() => {
    if (videoUrl) {
      setActivePreviewUrl(videoUrl);
      setActivePreviewTitle(`SnapBeat Job #${jobId || "Reel"}`);
      // If free user and not yet unlocked, auto-play the 5s pre-roll like YouTube
      if (
        !isPro &&
        !unlockedJobs[videoUrl] &&
        !(jobId && unlockedJobs[jobId]) &&
        !autoPromptTriggered.current
      ) {
        autoPromptTriggered.current = true;
        triggerPreRollAd(null, null);
      }
    }
  }, [videoUrl, jobId, isPro, unlockedJobs]);

  const handleDownloadClick = (e, targetUrl, fileName) => {
    if (e) e.preventDefault();
    const url = targetUrl || currentDisplayVideo;
    const name = fileName || `SnapBeat_${jobId || "Reel"}.mp4`;
    const isUnlocked = isPro || Boolean(unlockedJobs[url] || (jobId && unlockedJobs[jobId]));

    if (!isUnlocked) {
      if (isPlayingPreRoll) {
        setPendingDownload({ url, fileName: name });
        return;
      }
      triggerPreRollAd(url, name);
      return;
    }

    const link = document.createElement("a");
    link.href = url;
    link.download = name;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
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
                isPro
                  ? "bg-amber-500/20 text-amber-300 border-amber-500/40"
                  : "bg-emerald-500/20 text-emerald-300 border-emerald-500/40"
              }`}>
                {isPro ? "1080P MASTER OUTPUT" : "480P STANDARD OUTPUT"}
              </span>
            </div>

            {/* In-Stream YouTube-Style Video Player */}
            <div className="relative aspect-[9/16] w-full max-w-[260px] sm:max-w-[300px] rounded-2xl overflow-hidden bg-black border-2 border-amber-400/50 shadow-[0_20px_50px_rgba(0,0,0,0.9),0_0_20px_rgba(255,199,44,0.15)] group">
              <video
                ref={previewVideoRef}
                key={isPlayingPreRoll ? "ad-video" : currentDisplayVideo}
                src={isPlayingPreRoll ? "/assets/videos/showcase_reel.mp4" : currentDisplayVideo}
                controls={!isPlayingPreRoll}
                controlsList="nodownload"
                autoPlay
                loop={isPlayingPreRoll}
                muted={isPlayingPreRoll ? isAdMuted : false}
                playsInline
                className="w-full h-full object-cover"
              />

              {/* Scanlines Effect */}
              <div className="absolute inset-0 pointer-events-none crt-scanlines opacity-25 z-10" />

              {/* YouTube In-Stream Non-Skippable Pre-Roll Overlay */}
              {isPlayingPreRoll && (
                <div className="absolute inset-0 z-20 flex flex-col justify-between p-3 pointer-events-auto select-none bg-gradient-to-b from-black/80 via-transparent to-black/80">
                  {/* Top Row: Countdown Tag + Sponsor Link + Mute */}
                  <div className="flex items-center justify-between w-full">
                    <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-black/85 backdrop-blur-md border border-white/20 text-white font-mono text-[10px] sm:text-[11px] font-bold shadow">
                      <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse" />
                      <span>Ad • 0:0{preRollTimeLeft}</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <button
                        type="button"
                        onClick={() => setIsAdMuted(!isAdMuted)}
                        className="p-1.5 rounded-md bg-black/80 hover:bg-black/95 text-white/80 hover:text-white border border-white/20 transition cursor-pointer"
                        title={isAdMuted ? "Unmute audio" : "Mute audio"}
                        aria-label={isAdMuted ? "Unmute audio" : "Mute audio"}
                      >
                        {isAdMuted ? (
                          <VolumeX className="w-3.5 h-3.5" />
                        ) : (
                          <Volume2 className="w-3.5 h-3.5 text-amber-300" />
                        )}
                      </button>

                      {directLink && (
                        <a
                          href={directLink}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="flex items-center gap-1 px-2.5 py-1 rounded-md bg-[#ffc72c] hover:bg-[#ffe082] text-[#241903] font-mono text-[9px] sm:text-[10px] font-black tracking-wider uppercase shadow-md transition cursor-pointer"
                          title="Visit advertiser website"
                        >
                          <span>Visit Sponsor ↗</span>
                        </a>
                      )}
                    </div>
                  </div>

                  {/* Center Tag: Non-skippable countdown status */}
                  <div className="my-auto self-center text-center space-y-1">
                    <div className="px-3 py-1 rounded-full bg-black/75 backdrop-blur-md border border-white/15 text-white/90 text-[10px] font-mono font-medium shadow">
                      Reel begins in 0:0{preRollTimeLeft}s
                    </div>
                    <p className="text-[9px] text-amber-200/60 font-mono">
                      Full sponsor ad plays before export
                    </p>
                  </div>

                  {/* Bottom: YouTube Yellow Progress Bar */}
                  <div className="w-full space-y-1">
                    <div className="w-full bg-white/20 h-1.5 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-gradient-to-r from-amber-400 to-yellow-300 transition-all duration-1000 ease-linear shadow-[0_0_8px_#fbbf24]"
                        style={{
                          width: `${((AD_DURATION - preRollTimeLeft) / AD_DURATION) * 100}%`,
                        }}
                      />
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Action Bar: Download & Create Another Reel */}
            <div className="flex items-center justify-center gap-3 pt-1 flex-wrap w-full">
              <button
                type="button"
                onClick={(e) =>
                  handleDownloadClick(
                    e,
                    currentDisplayVideo,
                    `SnapBeat_${jobId || "Reel"}.mp4`
                  )
                }
                className="btn-gold-radiant px-6 py-3 rounded-full text-xs font-black tracking-wider uppercase text-[#261b02] shadow-lg flex items-center gap-2 hover:scale-105 active:scale-95 transition cursor-pointer border border-[#fff4b8]"
                title="Download MP4 to your device"
              >
                <Download className="w-4 h-4" />
                <span>DOWNLOAD REEL MP4</span>
              </button>

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
                        onClick={() => {
                          handleSelectPreview(job);
                          const isUnlocked = isPro || unlockedJobs[job.videoUrl] || unlockedJobs[job.id];
                          if (!isUnlocked) {
                            triggerPreRollAd(null, null);
                          }
                        }}
                        className={`px-2.5 py-1 rounded-xl text-[10px] font-black uppercase tracking-wider transition cursor-pointer flex items-center gap-1 ${
                          isSelected
                            ? "bg-amber-400 text-black shadow"
                            : "bg-white/10 hover:bg-white/20 text-amber-300 border border-amber-400/30"
                        }`}
                        title="Preview reel in player above"
                      >
                        <Play className="w-3 h-3 fill-current" />
                        <span>PREVIEW</span>
                      </button>

                      {/* Download Button */}
                      <button
                        type="button"
                        onClick={(e) => handleDownloadClick(e, job.videoUrl, `SnapBeat_${job.id}.mp4`)}
                        className="p-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-white transition cursor-pointer border border-white/15"
                        title="Download MP4"
                        aria-label="Download MP4"
                      >
                        <Download className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
