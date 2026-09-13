"use client";

import { Clock, Play, Download, Trash2, CheckCircle2, AlertTriangle, AlertCircle, RefreshCw } from "lucide-react";

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
}) {
  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Beta Notice Banner (matching mobile app) */}
      <div className="p-4 rounded-2xl bg-[#ffc72c]/20 border-2 border-[#bf8a00] flex items-start gap-3 shadow-md">
        <AlertTriangle className="w-5 h-5 text-[#bf8a00] shrink-0 mt-0.5" />
        <div>
          <p className="font-black text-xs text-[#2b2b2d] uppercase tracking-wide">
            BETA NOTICE: 1-AT-A-TIME SERIALIZED QUEUE
          </p>
          <p className="text-xs text-[#5a5752] mt-0.5 leading-relaxed">
            Free renders process sequentially (1-at-a-time) in a shared cluster queue to prevent server overload. Thank you for your patience! Pro subscribers receive priority scheduling.
          </p>
        </div>
      </div>

      {/* ACTIVE JOB CONSOLE */}
      <div className="metal-panel rounded-3xl p-6 relative">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        <div className="border-b border-[#a89f90] pb-3 mb-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-[#00c853] shadow-[0_0_8px_#00c853]" />
            <h2 className="font-black text-sm text-[#2b2b2d] uppercase tracking-wider">
              ACTIVE RENDER QUEUE STATUS
            </h2>
          </div>
          {jobId && (
            <span className="px-2.5 py-0.5 rounded bg-[#1e1c1a] text-amber-400 font-mono font-bold text-[10px]">
              JOB #{jobId}
            </span>
          )}
        </div>

        {isRendering ? (
          <div className="metal-inset rounded-2xl p-6 space-y-4">
            {/* Live Queue Position Badge */}
            <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
              <div className="flex items-center gap-2">
                {queuePosition > 0 ? (
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#ffc72c] text-[#2b2820] font-black text-xs border border-[#bf8a00] shadow animate-pulse">
                    <Clock className="w-3.5 h-3.5" />
                    <span>IN QUEUE • POSITION #{queuePosition}</span>
                  </div>
                ) : (
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#00c853] text-white font-black text-xs shadow">
                    <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                    <span>CURRENT RENDER IN PROGRESS</span>
                  </div>
                )}
              </div>

              <span className="font-mono text-xs font-black text-[#2b2b2d]">
                {Math.round(progress)}% COMPLETED
              </span>
            </div>

            {/* Stage Description */}
            <div className="bg-[#1e1c1a] p-3.5 rounded-xl border border-[#3a3835]">
              <p className="text-[10px] font-mono text-gray-400 uppercase tracking-widest">
                CURRENT STAGE
              </p>
              <p className="font-mono text-xs font-bold text-amber-400 mt-0.5 truncate">
                {stage || "Analyzing audio waveforms & synchronizing beats..."}
              </p>
            </div>

            {/* 3D Inset Progress Track */}
            <div className="w-full bg-[#1e1c1a] h-3.5 rounded-full p-0.5 border border-[#3a3835] shadow-inner overflow-hidden">
              <div
                className="bg-gradient-to-r from-[#ffc72c] via-[#ffe082] to-[#ffc72c] h-full rounded-full transition-all duration-300 shadow"
                style={{ width: `${Math.max(4, progress)}%` }}
              />
            </div>
          </div>
        ) : error ? (
          <div className="p-4 rounded-2xl bg-[#d62828]/15 border border-[#d62828]/40 flex items-center gap-3">
            <AlertCircle className="w-5 h-5 text-[#d62828] shrink-0" />
            <div>
              <p className="font-black text-xs text-[#d62828] uppercase">RENDER INTERRUPTED</p>
              <p className="text-xs text-[#5a5752] mt-0.5">{error}</p>
            </div>
          </div>
        ) : videoUrl ? (
          <div className="metal-inset rounded-2xl p-5 flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <CheckCircle2 className="w-6 h-6 text-[#00c853]" />
              <div>
                <p className="font-black text-xs text-[#2b2b2d] uppercase">
                  REEL RENDER COMPLETED!
                </p>
                <p className="text-xs text-[#5a5752]">
                  Your beat-synchronized MP4 video is ready to download.
                </p>
              </div>
            </div>

            <a
              href={videoUrl}
              download="SnapBeat_Reel.mp4"
              className="btn-brass px-5 py-2.5 rounded-xl font-black text-xs flex items-center gap-2 shadow"
            >
              <Download className="w-4 h-4 stroke-[3]" />
              <span>DOWNLOAD MP4</span>
            </a>
          </div>
        ) : (
          <div className="p-8 text-center text-[#7a766f]">
            <Clock className="w-8 h-8 mx-auto mb-2 opacity-50" />
            <p className="font-black text-xs uppercase tracking-wider">QUEUE IS CURRENTLY EMPTY</p>
            <p className="text-[11px] text-[#5a5752] mt-0.5">
              Switch to Studio or Music tab and hit Render Reel to start!
            </p>
          </div>
        )}
      </div>

      {/* COMPLETED RENDERS HISTORY */}
      {pastJobs.length > 0 && (
        <div className="metal-panel rounded-3xl p-6 relative">
          <div className="flex items-center justify-between border-b border-[#a89f90] pb-2 mb-4">
            <h3 className="font-black text-sm text-[#2b2b2d] uppercase tracking-wider">
              RENDER HISTORY
            </h3>
            {onClearCompleted && (
              <button
                onClick={onClearCompleted}
                className="text-xs font-bold text-[#d62828] hover:underline flex items-center gap-1"
              >
                <Trash2 className="w-3.5 h-3.5" />
                <span>CLEAR HISTORY</span>
              </button>
            )}
          </div>

          <div className="space-y-2.5">
            {pastJobs.map((job) => (
              <div
                key={job.id}
                className="p-3.5 rounded-2xl metal-inset flex items-center justify-between gap-3"
              >
                <div>
                  <p className="font-black text-xs text-[#2b2b2d]">
                    Job #{job.id} • {job.templateName || "Reel"}
                  </p>
                  <p className="text-[10px] text-[#5a5752]">
                    {job.quality || "720p"} • {job.createdAt ? new Date(job.createdAt).toLocaleTimeString() : "Recent"}
                  </p>
                </div>

                {job.videoUrl && (
                  <a
                    href={job.videoUrl}
                    download={`SnapBeat_${job.id}.mp4`}
                    className="px-3 py-1.5 rounded-lg btn-brass font-black text-xs flex items-center gap-1"
                  >
                    <Download className="w-3.5 h-3.5" />
                    <span>DOWNLOAD</span>
                  </a>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
