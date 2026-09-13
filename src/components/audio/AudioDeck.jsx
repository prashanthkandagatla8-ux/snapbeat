"use client";

import { useState, useRef, useEffect, useMemo } from "react";
import { Music, Play, Pause, Square, Scissors, UploadCloud, RefreshCw } from "lucide-react";

export function AudioDeck({ audioFile, audioUrl, audioDuration, audioTrim, setAudio, setAudioTrim }) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [loadingSample, setLoadingSample] = useState(false);
  const audioRef = useRef(null);
  const fileInputRef = useRef(null);
  const waveformRef = useRef(null);

  // Play / Pause toggle with resume support
  const togglePlay = () => {
    if (!audioRef.current || !audioUrl) return;

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      const start = audioTrim?.start || 0;
      const end = audioTrim?.end && audioTrim.end > start ? audioTrim.end : audioDuration || Infinity;

      // Resume from current time if within bounds; otherwise seek to start
      if (audioRef.current.currentTime < start || audioRef.current.currentTime >= end) {
        audioRef.current.currentTime = start;
      }

      audioRef.current.play().then(() => {
        setIsPlaying(true);
      }).catch((err) => {
        console.warn("Audio play error:", err);
        setIsPlaying(false);
      });
    }
  };

  // Stop playback and rewind to start point
  const handleStop = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = audioTrim?.start || 0;
    }
    setIsPlaying(false);
    setCurrentTime(audioTrim?.start || 0);
  };

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const handleTimeUpdate = () => {
      setCurrentTime(audio.currentTime);
      const start = audioTrim?.start || 0;
      const end = audioTrim?.end && audioTrim.end > start ? audioTrim.end : audioDuration;

      if (end > start && audio.currentTime >= end) {
        audio.pause();
        audio.currentTime = start;
        setIsPlaying(false);
        setCurrentTime(start);
      }
    };

    const handleEnded = () => {
      setIsPlaying(false);
      const start = audioTrim?.start || 0;
      if (audioRef.current) audioRef.current.currentTime = start;
      setCurrentTime(start);
    };

    audio.addEventListener("timeupdate", handleTimeUpdate);
    audio.addEventListener("ended", handleEnded);
    return () => {
      audio.removeEventListener("timeupdate", handleTimeUpdate);
      audio.removeEventListener("ended", handleEnded);
    };
  }, [audioTrim, audioDuration]);

  const handleFileChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      handleStop();
      setAudio(e.target.files[0]);
    }
  };

  const loadSampleTrack = async () => {
    setLoadingSample(true);
    try {
      // First attempt /assets/audio/little_do_you_know.mp3, fallback to /sample_music.mp3
      let res = await fetch("/assets/audio/little_do_you_know.mp3");
      if (!res.ok) {
        res = await fetch("/sample_music.mp3");
      }
      if (!res.ok) throw new Error("Audio sample file could not be reached");

      const blob = await res.blob();
      const file = new File([blob], "Little_Do_You_Know_Sample.mp3", { type: "audio/mp3" });
      handleStop();
      setAudio(file);
    } catch (err) {
      console.error("Failed to load sample track:", err);
      alert("Could not load sample track. Please upload your own MP3.");
    } finally {
      setLoadingSample(false);
    }
  };

  const formatTime = (secs) => {
    if (!secs || isNaN(secs) || secs < 0) return "0:00";
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  // Deterministic waveform bars
  const waveformBars = useMemo(() => {
    const seedStr = audioFile?.name || "snapbeat_deck";
    let hash = 0;
    for (let i = 0; i < seedStr.length; i++) {
      hash = (hash << 5) - hash + seedStr.charCodeAt(i);
      hash |= 0;
    }
    const bars = [];
    const count = 40;
    for (let i = 0; i < count; i++) {
      const pseudo = Math.abs(Math.sin((i + 1) * 12.9898 + hash) * 43758.5453) % 1;
      bars.push(Math.floor(25 + pseudo * 70));
    }
    return bars;
  }, [audioFile?.name]);

  // Click on waveform to seek
  const handleWaveformClick = (e) => {
    if (!waveformRef.current || !audioDuration || audioDuration <= 0) return;
    const rect = waveformRef.current.getBoundingClientRect();
    const ratio = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    const seekTime = ratio * audioDuration;
    if (audioRef.current) {
      audioRef.current.currentTime = seekTime;
      setCurrentTime(seekTime);
    }
  };

  const totalDuration = audioDuration > 0 ? audioDuration : 60;
  const trimStart = audioTrim?.start || 0;
  const trimEnd = audioTrim?.end && audioTrim.end > trimStart ? audioTrim.end : totalDuration;
  const trimStartPercent = Math.max(0, Math.min(100, (trimStart / totalDuration) * 100));
  const trimEndPercent = Math.max(0, Math.min(100, (trimEnd / totalDuration) * 100));
  const playheadPercent = Math.max(0, Math.min(100, (currentTime / totalDuration) * 100));

  return (
    <div className="rounded-2xl bg-[#151922] border border-[#242b38] p-4 shadow-sm">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
            <Music className="w-4 h-4" />
          </div>
          <span className="font-bold text-sm text-white">Audio Track</span>
        </div>
        <button
          onClick={loadSampleTrack}
          disabled={loadingSample}
          className="flex items-center gap-1 text-[11px] text-amber-400/90 hover:text-amber-300 font-semibold px-2 py-1 rounded-md bg-amber-500/10 hover:bg-amber-500/20 transition disabled:opacity-50"
        >
          <RefreshCw className={`w-3 h-3 ${loadingSample ? "animate-spin" : ""}`} />
          <span>{loadingSample ? "Loading..." : "Load Sample"}</span>
        </button>
      </div>

      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="audio/*"
        className="hidden"
      />

      {audioUrl ? (
        <div className="space-y-3">
          <audio
            ref={audioRef}
            src={audioUrl}
            preload="metadata"
            onError={(e) => {
              console.warn("AudioDeck playback error:", e);
              setIsPlaying(false);
            }}
          />

          {/* Track Info Card */}
          <div className="flex items-center justify-between p-3 rounded-xl bg-[#1a202c] border border-[#2d3748]">
            <div className="flex items-center gap-3 overflow-hidden">
              <div className="flex items-center gap-1.5">
                {/* Play / Pause */}
                <button
                  type="button"
                  onClick={togglePlay}
                  className="w-9 h-9 rounded-xl bg-amber-500 text-black flex items-center justify-center font-bold hover:bg-amber-400 transition shadow active:scale-95"
                  title={isPlaying ? "Pause" : "Play"}
                >
                  {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 ml-0.5" />}
                </button>
                {/* Stop */}
                <button
                  type="button"
                  onClick={handleStop}
                  className="w-9 h-9 rounded-xl bg-[#2d3748] text-gray-300 hover:text-white flex items-center justify-center transition shadow active:scale-95"
                  title="Stop"
                >
                  <Square className="w-3.5 h-3.5 fill-current text-rose-400" />
                </button>
              </div>

              <div className="overflow-hidden">
                <p className="text-xs font-bold text-white truncate max-w-[150px] sm:max-w-[200px]">
                  {audioFile ? audioFile.name : "Custom Audio Track"}
                </p>
                <p className="text-[11px] text-gray-400 font-mono">
                  {formatTime(currentTime)} / {formatTime(audioDuration)}
                </p>
              </div>
            </div>

            <button
              onClick={() => fileInputRef.current?.click()}
              className="text-xs text-gray-400 hover:text-white px-2.5 py-1 rounded hover:bg-white/5 transition"
            >
              Change
            </button>
          </div>

          {/* Waveform Visualizer */}
          <div
            ref={waveformRef}
            onClick={handleWaveformClick}
            className="relative h-14 bg-[#11141c] rounded-xl p-2 flex items-end justify-between gap-0.5 overflow-hidden border border-[#242b38] cursor-pointer select-none"
            title="Click to seek"
          >
            {/* Trim window overlay */}
            <div
              className="absolute top-0 bottom-0 bg-amber-500/20 border-x border-amber-400 pointer-events-none transition-all"
              style={{
                left: `${trimStartPercent}%`,
                width: `${Math.max(0, trimEndPercent - trimStartPercent)}%`,
              }}
            />
            {/* Playhead */}
            <div
              className="absolute top-0 bottom-0 w-0.5 bg-rose-500 shadow-[0_0_6px_#f43f5e] pointer-events-none transition-all z-10"
              style={{ left: `${playheadPercent}%` }}
            />
            {/* Bars */}
            {waveformBars.map((height, idx) => {
              const barPercent = (idx / waveformBars.length) * 100;
              const isInside = barPercent >= trimStartPercent && barPercent <= trimEndPercent;
              return (
                <div
                  key={idx}
                  className={`flex-1 rounded-t-sm transition-all ${
                    isInside ? "bg-amber-400" : "bg-gray-600 opacity-40"
                  }`}
                  style={{ height: `${height}%` }}
                />
              );
            })}
          </div>

          {/* Trimmer Controls */}
          <div className="p-3 rounded-xl bg-[#1a202c]/60 border border-[#2d3748]/60 space-y-2">
            <div className="flex items-center justify-between text-[11px] text-gray-400">
              <span className="flex items-center gap-1 font-semibold text-gray-300">
                <Scissors className="w-3 h-3 text-amber-400" />
                Trim Section
              </span>
              <span className="font-mono text-amber-300">
                {formatTime(trimStart)} - {formatTime(trimEnd)} (
                {Math.max(0, Math.round(trimEnd - trimStart))}s)
              </span>
            </div>

            <div className="space-y-1.5 pt-1">
              <div className="flex items-center justify-between text-[10px] text-gray-400">
                <span>Start: {formatTime(trimStart)}</span>
                <input
                  type="range"
                  min={0}
                  max={Math.max(audioDuration - 5, 0)}
                  step={0.5}
                  value={trimStart}
                  onChange={(e) => {
                    const startVal = parseFloat(e.target.value);
                    const endVal = Math.max(startVal + 5, trimEnd);
                    setAudioTrim((prev) => ({
                      ...prev,
                      start: startVal,
                      end: endVal,
                      isFullTrack: false,
                    }));
                  }}
                  className="w-36 h-1.5 bg-[#2d3748] rounded-lg appearance-none cursor-pointer accent-amber-500"
                />
              </div>

              <div className="flex items-center justify-between text-[10px] text-gray-400">
                <span>End: {formatTime(trimEnd)}</span>
                <input
                  type="range"
                  min={Math.min(trimStart + 5, audioDuration || 60)}
                  max={audioDuration || 60}
                  step={0.5}
                  value={trimEnd}
                  onChange={(e) => {
                    const endVal = parseFloat(e.target.value);
                    setAudioTrim((prev) => ({
                      ...prev,
                      end: endVal,
                      isFullTrack: false,
                    }));
                  }}
                  className="w-36 h-1.5 bg-[#2d3748] rounded-lg appearance-none cursor-pointer accent-amber-500"
                />
              </div>
            </div>

            <label className="flex items-center gap-2 pt-1 text-[11px] text-gray-300 cursor-pointer">
              <input
                type="checkbox"
                checked={audioTrim?.isFullTrack ?? true}
                onChange={(e) =>
                  setAudioTrim((prev) => ({ ...prev, isFullTrack: e.target.checked }))
                }
                className="rounded bg-[#2d3748] border-gray-600 text-amber-500 focus:ring-amber-400"
              />
              <span>Render full audio length without clipping</span>
            </label>
          </div>
        </div>
      ) : (
        <div
          onClick={() => fileInputRef.current?.click()}
          className="border-2 border-dashed border-[#2d3748] hover:border-amber-500/60 rounded-xl p-6 flex flex-col items-center justify-center cursor-pointer transition bg-[#181e29]/50 hover:bg-[#181e29]"
        >
          <UploadCloud className="w-8 h-8 text-amber-400 mb-2 animate-bounce" />
          <p className="text-xs font-bold text-white">Click or Drop Music File</p>
          <p className="text-[10px] text-gray-400 mt-0.5">MP3, WAV, M4A, or AAC audio</p>
        </div>
      )}
    </div>
  );
}

