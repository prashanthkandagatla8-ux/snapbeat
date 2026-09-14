"use client";

import { useState, useRef, useEffect, useMemo } from "react";
import { SOUND_TRACKS } from "@/lib/constants";
import { trackMusicSelected } from "@/lib/analytics";
import { Play, Pause, Square, Upload, Scissors, Volume2, Check, Music, Radio, Sparkles } from "lucide-react";

export function RetroTapeDeck({
  selectedTrack,
  onSelectBuiltInTrack,
  audioFile,
  audioUrl,
  audioDuration,
  audioTrim,
  setAudio,
  setAudioTrim,
}) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [previewTrackId, setPreviewTrackId] = useState(null);
  const audioRef = useRef(null);
  const previewAudioRef = useRef(null);
  const fileInputRef = useRef(null);
  const waveformRef = useRef(null);

  // Play / Pause toggle with resume support
  const toggleMainPlay = () => {
    if (!audioRef.current || !audioUrl) return;

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      if (previewAudioRef.current && !previewAudioRef.current.paused) {
        previewAudioRef.current.pause();
        setPreviewTrackId(null);
      }

      const start = audioTrim?.start || 0;
      const end = audioTrim?.end && audioTrim.end > start ? audioTrim.end : audioDuration || Infinity;

      if (audioRef.current.currentTime < start || audioRef.current.currentTime >= end) {
        audioRef.current.currentTime = start;
      }

      audioRef.current.play().then(() => {
        setIsPlaying(true);
      }).catch((err) => {
        console.warn("Main deck play interrupted or blocked:", err);
        setIsPlaying(false);
      });
    }
  };

  // Stop playback and rewind to start point
  const handleStop = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = audioTrim?.start || 0;
      setIsPlaying(false);
      setCurrentTime(audioTrim?.start || 0);
    }
  };

  // Sync current playback position
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const handleTimeUpdate = () => {
      setCurrentTime(audio.currentTime);
      const end = audioTrim?.end && audioTrim.end > (audioTrim?.start || 0)
        ? audioTrim.end
        : audioDuration;

      if (end && audio.currentTime >= end) {
        audio.pause();
        audio.currentTime = audioTrim?.start || 0;
        setIsPlaying(false);
        setCurrentTime(audioTrim?.start || 0);
      }
    };

    const handleEnded = () => {
      setIsPlaying(false);
      audio.currentTime = audioTrim?.start || 0;
      setCurrentTime(audioTrim?.start || 0);
    };

    audio.addEventListener("timeupdate", handleTimeUpdate);
    audio.addEventListener("ended", handleEnded);
    return () => {
      audio.removeEventListener("timeupdate", handleTimeUpdate);
      audio.removeEventListener("ended", handleEnded);
    };
  }, [audioTrim, audioDuration]);

  // Audio track preview player
  const togglePreview = (track) => {
    if (previewTrackId === track.id) {
      if (previewAudioRef.current) {
        previewAudioRef.current.pause();
      }
      setPreviewTrackId(null);
    } else {
      if (audioRef.current && isPlaying) {
        audioRef.current.pause();
        setIsPlaying(false);
      }

      setPreviewTrackId(track.id);
      if (previewAudioRef.current) {
        previewAudioRef.current.src = track.assetPath;
        previewAudioRef.current.play().catch((err) => {
          console.warn("Audio preview failed:", err);
          setPreviewTrackId(null);
        });
      }
    }
  };

  // Choose track
  const handleSelectTrack = (track) => {
    if (previewAudioRef.current) {
      previewAudioRef.current.pause();
      setPreviewTrackId(null);
    }
    handleStop();
    trackMusicSelected("built_in", track.id || track.name);
    onSelectBuiltInTrack(track);
  };

  // Custom audio upload handler
  const handleFileChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      handleStop();
      trackMusicSelected("custom_upload", file.name);
      setAudio(file);
    }
  };

  const formatTime = (secs) => {
    if (!secs || isNaN(secs) || secs < 0) return "0:00";
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  // Deterministic waveform bar heights
  const waveformBars = useMemo(() => {
    const seedStr = (selectedTrack?.id || audioFile?.name || "snapbeat_audio");
    let hash = 0;
    for (let i = 0; i < seedStr.length; i++) {
      hash = (hash << 5) - hash + seedStr.charCodeAt(i);
      hash |= 0;
    }
    const bars = [];
    const count = 54;
    for (let i = 0; i < count; i++) {
      const pseudo = Math.abs(Math.sin((i + 1) * 12.9898 + hash) * 43758.5453) % 1;
      const height = Math.floor(20 + pseudo * 75);
      bars.push(height);
    }
    return bars;
  }, [selectedTrack?.id, audioFile?.name]);

  // Click on waveform to scrub or seek
  const handleWaveformClick = (e) => {
    if (!waveformRef.current || !audioDuration || audioDuration <= 0) return;
    const rect = waveformRef.current.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const ratio = Math.max(0, Math.min(1, clickX / rect.width));
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
    <div className="space-y-6 text-white">
      <audio
        ref={audioRef}
        src={audioUrl || ""}
        preload="metadata"
        onError={(e) => {
          console.warn("Main deck audio error:", e);
          setIsPlaying(false);
        }}
      />
      <audio
        ref={previewAudioRef}
        onEnded={() => setPreviewTrackId(null)}
        onError={(e) => {
          console.warn("Sound rack preview error:", e);
          setPreviewTrackId(null);
        }}
      />

      {/* TOP: Glassmorphic Audio Deck Console */}
      <div className="sky-glass-panel rounded-3xl p-6 relative overflow-hidden shadow-2xl">
        <div className="max-w-3xl mx-auto space-y-5">
          {/* Deck Header & Timecode Counter */}
          <div className="flex items-center justify-between border-b border-white/10 pb-3">
            <div className="flex items-center gap-2.5">
              <span
                className={`w-3 h-3 rounded-full transition-all ${
                  isPlaying ? "bg-emerald-400 shadow-[0_0_10px_#34d399]" : "bg-amber-500 shadow-[0_0_8px_#f59e0b]"
                }`}
              />
              <div>
                <h2 className="font-black text-sm tracking-widest text-white uppercase flex items-center gap-2">
                  <Music className="w-4 h-4 text-amber-400" />
                  SOUNDTRACK &amp; AUDIO WAVEFORM
                </h2>
              </div>
            </div>

            {/* Modern Digital Time Counter */}
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-mono font-bold text-amber-200/70 uppercase hidden sm:inline">
                PLAYHEAD
              </span>
              <div className="px-3.5 py-1 rounded-full bg-black/60 border border-white/15 font-mono text-amber-300 font-bold text-xs tracking-widest shadow-inner">
                {formatTime(currentTime)} / {formatTime(audioDuration)}
              </div>
            </div>
          </div>

          {/* Audio Visualizer & Transport Stage */}
          <div className="bg-black/40 backdrop-blur-md rounded-2xl p-5 border border-white/10 flex flex-col md:flex-row items-center justify-between gap-6">
            {/* Animated Audio Equalizer Spectrum Display */}
            <div className="flex items-center gap-4 sm:gap-6 p-4 rounded-2xl bg-black/50 border border-white/15 shadow-2xl w-full md:w-auto justify-center">
              {/* Dynamic Soundwave Visualizer Bars */}
              <div className="flex items-end gap-1.5 h-16 px-2">
                {[45, 75, 30, 90, 60, 100, 40, 85, 55, 70, 95, 35, 80, 50, 65].map((h, i) => (
                  <div
                    key={i}
                    className={`w-1.5 rounded-full transition-all duration-150 ${
                      isPlaying
                        ? "bg-gradient-to-t from-amber-500 via-amber-400 to-yellow-200 shadow-[0_0_8px_rgba(255,199,44,0.6)]"
                        : "bg-white/20"
                    }`}
                    style={{
                      height: isPlaying ? `${Math.max(15, Math.min(100, h * (0.6 + Math.sin(currentTime * 8 + i) * 0.4)))}%` : "25%",
                    }}
                  />
                ))}
              </div>

              {/* Center Track Info */}
              <div className="flex flex-col items-center gap-1.5 min-w-[160px] max-w-[220px] text-center">
                <div className="inline-block px-3 py-0.5 rounded-full bg-amber-500/20 text-[9px] font-mono text-amber-300 uppercase tracking-widest border border-amber-400/40">
                  {selectedTrack ? "PREMIUM STUDIO AUDIO" : "CUSTOM AUDIO"}
                </div>
                <p className="text-sm font-black text-white truncate w-full mt-0.5">
                  {selectedTrack ? selectedTrack.title : audioFile ? audioFile.name : "No Audio Selected"}
                </p>
                <p className="text-xs text-amber-400 font-bold">
                  {selectedTrack ? `${selectedTrack.bpm} • ${selectedTrack.genre}` : "Uploaded File"}
                </p>
              </div>
            </div>

            {/* Transport Action Buttons (Play, Pause, Stop, Custom MP3) */}
            <div className="flex items-center gap-3 flex-wrap justify-center">
              {/* Play / Pause Toggle Button */}
              <button
                type="button"
                onClick={toggleMainPlay}
                disabled={!audioUrl}
                className={`btn-gold-radiant px-6 py-3.5 rounded-full flex items-center gap-2 font-black text-xs shadow-xl active:scale-95 text-[#241903] ${
                  !audioUrl ? "opacity-50 cursor-not-allowed" : ""
                }`}
                title={isPlaying ? "Pause" : "Play"}
              >
                {isPlaying ? <Pause className="w-4 h-4 fill-current" /> : <Play className="w-4 h-4 fill-current ml-0.5" />}
                <span>{isPlaying ? "PAUSE AUDIO" : "PLAY AUDIO"}</span>
              </button>

              {/* Stop Button */}
              <button
                type="button"
                onClick={handleStop}
                disabled={!audioUrl}
                className="px-4 py-3 rounded-full bg-white/10 hover:bg-white/20 text-white font-black text-xs flex items-center gap-1.5 border border-white/15 backdrop-blur-md active:scale-95 transition shadow disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                title="Stop & Rewind"
              >
                <Square className="w-3.5 h-3.5 fill-current text-red-400" />
                <span>STOP</span>
              </button>

              {/* Load Custom MP3 Button */}
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="px-4 py-3 rounded-full bg-white/10 hover:bg-white/20 text-white font-black text-xs flex items-center gap-2 border border-white/15 backdrop-blur-md active:scale-95 transition shadow cursor-pointer"
                title="Upload MP3"
              >
                <Upload className="w-4 h-4 text-amber-400" />
                <span>LOAD CUSTOM MP3</span>
              </button>
              <input
                type="file"
                ref={fileInputRef}
                onChange={handleFileChange}
                accept="audio/*"
                className="hidden"
              />
            </div>
          </div>

          {/* Interactive Waveform Scrubbing & Trim Zone */}
          {audioUrl && (
            <div className="space-y-3 bg-black/40 backdrop-blur-md p-4 sm:p-5 rounded-2xl border border-white/10">
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5 text-amber-300 font-bold">
                  <Scissors className="w-3.5 h-3.5 text-amber-400" />
                  <span>AUDIO TRIM &amp; TIME WINDOW</span>
                </div>
                <div className="text-[11px] font-mono font-bold text-amber-200/70">
                  DURATION: {(trimEnd - trimStart).toFixed(1)}s
                </div>
              </div>

              {/* Scrubbable Waveform Canvas */}
              <div
                ref={waveformRef}
                onClick={handleWaveformClick}
                className="relative h-20 sm:h-24 bg-black/60 rounded-xl overflow-hidden cursor-pointer border border-white/15 shadow-inner flex items-center px-2 group select-none"
                title="Click anywhere to seek playback position"
              >
                {/* Active Trim Window Overlay */}
                <div
                  className="absolute top-0 bottom-0 bg-amber-500/20 border-x-2 border-amber-400 z-10 pointer-events-none transition-all duration-75"
                  style={{
                    left: `${trimStartPercent}%`,
                    width: `${Math.max(2, trimEndPercent - trimStartPercent)}%`,
                  }}
                />

                {/* Live Playhead Needle */}
                <div
                  className="absolute top-0 bottom-0 w-1 bg-white shadow-[0_0_10px_#ffffff] z-20 pointer-events-none transition-all duration-75"
                  style={{ left: `${playheadPercent}%` }}
                />

                {/* Waveform Bars */}
                {waveformBars.map((height, i) => {
                  const barPercent = (i / waveformBars.length) * 100;
                  const isWithinTrim = barPercent >= trimStartPercent && barPercent <= trimEndPercent;
                  const isPastPlayhead = barPercent <= playheadPercent;

                  return (
                    <div
                      key={i}
                      className="flex-1 mx-[1px] rounded-full transition-colors duration-150"
                      style={{
                        height: `${height}%`,
                        backgroundColor: isPastPlayhead
                          ? "#ffc72c"
                          : isWithinTrim
                          ? "#f59e0b"
                          : "rgba(255, 255, 255, 0.2)",
                      }}
                    />
                  );
                })}
              </div>

              {/* Start & End Point Range Sliders */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-1">
                <div className="bg-black/50 p-3 rounded-xl border border-white/10">
                  <div className="flex items-center justify-between text-[10px] font-bold text-amber-200/70 mb-1">
                    <span>START POINT:</span>
                    <span className="font-mono text-amber-300 font-bold">{formatTime(trimStart)}</span>
                  </div>
                  <input
                    type="range"
                    min={0}
                    max={Math.max(audioDuration - 5, 0)}
                    step={0.5}
                    value={trimStart}
                    onChange={(e) => {
                      const start = parseFloat(e.target.value);
                      const end = Math.max(start + 5, trimEnd);
                      setAudioTrim((prev) => ({ ...prev, start, end, isFullTrack: false }));
                    }}
                    className="w-full accent-amber-400 cursor-pointer"
                  />
                </div>

                <div className="bg-black/50 p-3 rounded-xl border border-white/10">
                  <div className="flex items-center justify-between text-[10px] font-bold text-amber-200/70 mb-1">
                    <span>END POINT:</span>
                    <span className="font-mono text-amber-300 font-bold">{formatTime(trimEnd)}</span>
                  </div>
                  <input
                    type="range"
                    min={Math.min(trimStart + 5, audioDuration || 60)}
                    max={audioDuration || 60}
                    step={0.5}
                    value={trimEnd}
                    onChange={(e) => {
                      const end = parseFloat(e.target.value);
                      setAudioTrim((prev) => ({ ...prev, end, isFullTrack: false }));
                    }}
                    className="w-full accent-amber-400 cursor-pointer"
                  />
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* BOTTOM: Curated Sound Library */}
      <div className="sky-glass-panel rounded-3xl p-6 relative shadow-xl">
        <div className="flex items-center justify-between mb-4 border-b border-white/10 pb-3">
          <div>
            <h3 className="font-black text-base text-white tracking-tight uppercase flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-amber-400" />
              CURATED SOUNDTRACK LIBRARY
            </h3>
            <p className="text-xs text-amber-100/70 mt-0.5">
              Select from royalty-free beat-synchronized studio tracks.
            </p>
          </div>
          <span className="px-3.5 py-1 rounded-full bg-amber-400/20 border border-amber-400/40 font-black text-xs text-amber-300">
            {SOUND_TRACKS.length} TRACKS
          </span>
        </div>

        {/* Track Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {SOUND_TRACKS.map((track) => {
            const isLoaded = selectedTrack?.id === track.id || (!selectedTrack && !audioFile && track.id === SOUND_TRACKS[0].id);
            const isPreviewing = previewTrackId === track.id;

            return (
              <div
                key={track.id}
                className={`rounded-2xl p-4 transition-all flex flex-col justify-between border-2 ${
                  isLoaded
                    ? "bg-amber-500/20 border-amber-400 shadow-[0_0_20px_rgba(255,199,44,0.3)] scale-[1.01]"
                    : "bg-black/40 border-white/10 hover:border-amber-400/40"
                }`}
              >
                <div>
                  <div className="flex items-start justify-between gap-2">
                    <span className="font-black text-sm text-white leading-tight line-clamp-1">
                      {track.title}
                    </span>
                    <span className="px-2.5 py-0.5 rounded-full bg-black/60 text-amber-400 font-mono font-bold text-[10px] shrink-0 border border-white/10">
                      {track.bpm}
                    </span>
                  </div>
                  <p className="text-[11px] font-bold text-amber-400 mt-1">{track.genre}</p>
                  <p className="text-[10px] text-amber-100/70 line-clamp-2 mt-1 leading-relaxed">
                    {track.vibe}
                  </p>
                </div>

                <div className="flex items-center justify-between gap-2 mt-4 pt-3 border-t border-white/10">
                  {/* Preview audio button */}
                  <button
                    type="button"
                    onClick={() => togglePreview(track)}
                    className="flex items-center gap-1.5 text-[11px] font-bold text-amber-200/80 hover:text-white px-3 py-1.5 rounded-full bg-white/5 hover:bg-white/15 transition cursor-pointer"
                    title={isPreviewing ? "Pause preview" : "Listen to preview"}
                  >
                    {isPreviewing ? (
                      <Volume2 className="w-4 h-4 text-pink-400 animate-pulse" />
                    ) : (
                      <Play className="w-4 h-4" />
                    )}
                    <span>{isPreviewing ? "PLAYING" : "PREVIEW"}</span>
                  </button>

                  {/* Select Track Button */}
                  <button
                    type="button"
                    onClick={() => handleSelectTrack(track)}
                    className={`px-4 py-1.5 rounded-full font-black text-xs flex items-center gap-1 transition cursor-pointer ${
                      isLoaded
                        ? "bg-emerald-500 text-white shadow"
                        : "btn-gold-radiant text-[#241903] hover:scale-105 active:scale-95"
                    }`}
                  >
                    {isLoaded && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                    <span>{isLoaded ? "SELECTED" : "SELECT TRACK"}</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
