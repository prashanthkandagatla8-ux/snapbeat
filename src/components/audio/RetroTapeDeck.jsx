"use client";

import { useState, useRef, useEffect, useMemo } from "react";
import { SOUND_TRACKS } from "@/lib/constants";
import { Play, Pause, Square, Upload, Scissors, Volume2, Check, Music, Radio } from "lucide-react";

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
      // Pause sound library preview if active to avoid conflicting audio
      if (previewAudioRef.current && !previewAudioRef.current.paused) {
        previewAudioRef.current.pause();
        setPreviewTrackId(null);
      }

      const start = audioTrim?.start || 0;
      const end = audioTrim?.end && audioTrim.end > start ? audioTrim.end : audioDuration || Infinity;

      // Resume from current time if within bounds; otherwise seek to start
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
    }
    setIsPlaying(false);
    setCurrentTime(audioTrim?.start || 0);
  };

  // Synchronize playback position and trim boundary auto-loop/stop
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

  // Preview built-in track from rack
  const togglePreview = (track) => {
    // If main tape deck is playing, pause it
    if (isPlaying && audioRef.current) {
      audioRef.current.pause();
      setIsPlaying(false);
    }

    if (previewTrackId === track.id) {
      if (previewAudioRef.current) {
        previewAudioRef.current.pause();
        setPreviewTrackId(null);
      }
    } else {
      setPreviewTrackId(track.id);
      if (previewAudioRef.current) {
        previewAudioRef.current.src = track.assetPath;
        previewAudioRef.current.play().catch((err) => {
          console.warn("Track preview failed:", err);
          setPreviewTrackId(null);
        });
      }
    }
  };

  // Insert tape from library
  const handleInsertTape = (track) => {
    if (previewAudioRef.current) {
      previewAudioRef.current.pause();
      setPreviewTrackId(null);
    }
    handleStop();
    onSelectBuiltInTrack(track);
  };

  // Custom audio upload handler
  const handleFileChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      handleStop();
      setAudio(file);
    }
  };

  const formatTime = (secs) => {
    if (!secs || isNaN(secs) || secs < 0) return "0:00";
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  // Generate deterministic retro waveform bar heights
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
    <div className="space-y-6">
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

      {/* TOP: Physical Cassette Tape Deck Console */}
      <div className="metal-panel rounded-3xl p-6 relative overflow-hidden shadow-2xl">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        <div className="max-w-3xl mx-auto space-y-5">
          {/* Deck Header & Tape Counter */}
          <div className="flex items-center justify-between border-b border-[#a89f90] pb-3">
            <div className="flex items-center gap-2.5">
              <span
                className={`w-3 h-3 rounded-full transition-all ${
                  isPlaying ? "bg-[#00c853] shadow-[0_0_8px_#00c853]" : "bg-[#ff3366] shadow-[0_0_8px_#ff3366]"
                }`}
              />
              <div>
                <h2 className="font-black text-sm tracking-widest text-[#2b2b2d] uppercase flex items-center gap-1.5">
                  <Radio className="w-4 h-4 text-[#bf8a00]" />
                  STUDIO CASSETTE TAPE TRANSPORT
                </h2>
              </div>
            </div>

            {/* Nixie / Mechanical Tape Counter */}
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-mono font-bold text-[#5a5752] uppercase hidden sm:inline">
                INDEX
              </span>
              <div className="px-3.5 py-1 rounded bg-[#1e1c1a] border border-[#3a3835] font-mono text-amber-400 font-bold text-xs tracking-widest shadow-inner">
                TAPE {formatTime(currentTime)} / {formatTime(audioDuration)}
              </div>
            </div>
          </div>

          {/* Cassette Tape Well */}
          <div className="metal-inset rounded-2xl p-4 flex flex-col md:flex-row items-center justify-between gap-5">
            {/* Spinning Spools Simulation with Analog VU Level Meter */}
            <div className="flex items-center gap-4 sm:gap-6 p-4 rounded-2xl bg-gradient-to-b from-[#141312] to-[#22201e] border-2 border-[#3a3835] shadow-2xl w-full md:w-auto justify-center">
              {/* Left Spool */}
              <div className="flex flex-col items-center">
                <div
                  className={`w-14 h-14 sm:w-16 sm:h-16 rounded-full relative flex items-center justify-center transition-transform shadow-lg ${
                    isPlaying ? "animate-spin" : ""
                  }`}
                  style={{ animationDuration: isPlaying ? "2.4s" : "0s" }}
                >
                  <img
                    src="/assets/images/rotary_knob.png"
                    alt="Spool"
                    className="w-full h-full object-contain pointer-events-none drop-shadow"
                  />
                  <div className="absolute w-4 h-4 rounded-full bg-[#181716] border-2 border-[#ffc72c] shadow flex items-center justify-center">
                    <div className="w-1.5 h-1.5 rounded-full bg-[#ffc72c]" />
                  </div>
                </div>
                <span className="text-[8px] font-mono font-bold text-amber-500/80 mt-1 uppercase tracking-widest">FEED</span>
              </div>

              {/* Center Console: Cassette Label & Analog VU Level Meter */}
              <div className="flex flex-col items-center gap-2 min-w-[160px] max-w-[210px]">
                {/* Tape Badge */}
                <div className="text-center w-full">
                  <div className="inline-block px-2.5 py-0.5 rounded-md bg-[#2b2820] text-[9px] font-mono text-amber-300 uppercase tracking-widest border border-amber-500/40 shadow-sm">
                    {selectedTrack ? "TYPE II • CrO2 HIGH BIAS" : "MAGNETIC TAPE"}
                  </div>
                  <p className="text-xs font-black text-white truncate mt-1">
                    {selectedTrack ? selectedTrack.title : audioFile ? audioFile.name : "NO TAPE INSERTED"}
                  </p>
                  <p className="text-[10px] text-amber-400 font-bold">
                    {selectedTrack ? `${selectedTrack.bpm} • ${selectedTrack.genre}` : "Custom Audio File"}
                  </p>
                </div>

                {/* Analog Hi-Fi VU Level Meter (Matching Mobile App) */}
                <div className="w-full px-2.5 py-1.5 rounded-lg bg-[#11100f] border border-[#33312e] shadow-inner flex flex-col items-center">
                  <div className="flex items-center justify-between w-full text-[8px] font-mono text-[#a89f90] px-1 font-bold">
                    <span>-20</span>
                    <span>-7</span>
                    <span className="text-amber-400">0</span>
                    <span className="text-red-500">+3</span>
                  </div>
                  <div className="relative w-full h-2 rounded-sm bg-[#1c1a18] overflow-hidden border border-[#2a2826] mt-0.5">
                    <div className="absolute inset-0 bg-gradient-to-r from-[#00c853] via-[#ffc72c] to-[#d62828] opacity-75" />
                    {/* Dynamic VU Needle */}
                    <div
                      className="absolute top-0 bottom-0 w-1 bg-white shadow-[0_0_6px_#fff] transition-all duration-75"
                      style={{
                        left: isPlaying
                          ? `${Math.min(92, Math.max(10, 45 + Math.sin(currentTime * 12) * 35))}%`
                          : "12%",
                      }}
                    />
                  </div>
                  <span className="text-[7.5px] font-mono text-amber-500/90 font-bold uppercase tracking-widest mt-0.5">
                    STUDIO HI-FI 48kHz
                  </span>
                </div>
              </div>

              {/* Right Spool */}
              <div className="flex flex-col items-center">
                <div
                  className={`w-14 h-14 sm:w-16 sm:h-16 rounded-full relative flex items-center justify-center transition-transform shadow-lg ${
                    isPlaying ? "animate-spin" : ""
                  }`}
                  style={{ animationDuration: isPlaying ? "2.4s" : "0s" }}
                >
                  <img
                    src="/assets/images/rotary_knob.png"
                    alt="Spool"
                    className="w-full h-full object-contain pointer-events-none drop-shadow"
                  />
                  <div className="absolute w-4 h-4 rounded-full bg-[#181716] border-2 border-[#ffc72c] shadow flex items-center justify-center">
                    <div className="w-1.5 h-1.5 rounded-full bg-[#ffc72c]" />
                  </div>
                </div>
                <span className="text-[8px] font-mono font-bold text-amber-500/80 mt-1 uppercase tracking-widest">TAKEUP</span>
              </div>
            </div>

            {/* Tactile Hardware Transport Buttons (Play, Pause, Stop, Custom MP3) */}
            <div className="flex items-center gap-2.5 flex-wrap justify-center">
              {/* Play / Pause Toggle Button */}
              <button
                type="button"
                onClick={toggleMainPlay}
                disabled={!audioUrl}
                className={`px-5 py-3 rounded-2xl flex items-center gap-2 font-black text-xs shadow-md transition active:scale-95 ${
                  !audioUrl
                    ? "opacity-50 cursor-not-allowed bg-[#7a766f] text-[#2b2b2d]"
                    : isPlaying
                    ? "bg-[#ffc72c] text-[#2b2820] ring-2 ring-[#bf8a00]"
                    : "btn-brass text-[#2b2820]"
                }`}
                title={isPlaying ? "Pause Tape" : "Play Tape"}
              >
                {isPlaying ? <Pause className="w-4 h-4 fill-current" /> : <Play className="w-4 h-4 fill-current" />}
                <span>{isPlaying ? "PAUSE" : "PLAY TAPE"}</span>
              </button>

              {/* Stop Button */}
              <button
                type="button"
                onClick={handleStop}
                disabled={!audioUrl}
                className="px-4 py-3 rounded-2xl metal-panel text-[#2b2b2d] font-black text-xs flex items-center gap-1.5 hover:bg-white/40 active:scale-95 transition shadow disabled:opacity-50 disabled:cursor-not-allowed"
                title="Stop and Rewind to Trim Start"
              >
                <Square className="w-3.5 h-3.5 fill-current text-[#d62828]" />
                <span>STOP</span>
              </button>

              {/* Load Custom MP3 Button */}
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="px-4 py-3 rounded-2xl metal-panel text-[#2b2b2d] font-black text-xs flex items-center gap-2 hover:bg-white/40 active:scale-95 transition shadow"
                title="Upload Custom MP3 Audio"
              >
                <Upload className="w-4 h-4 text-[#bf8a00]" />
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

          {/* Interactive Trimmer & Tactile Waveform Visualizer */}
          {audioUrl && (
            <div className="metal-inset rounded-2xl p-4 space-y-3">
              <div className="flex items-center justify-between text-xs font-bold text-[#2b2b2d]">
                <span className="flex items-center gap-1.5 font-black uppercase tracking-wider">
                  <Scissors className="w-3.5 h-3.5 text-[#bf8a00]" />
                  TRIM WINDOW: {formatTime(trimStart)} - {formatTime(trimEnd)} (
                  {Math.max(0, Math.round(trimEnd - trimStart))}s)
                </span>
                <label className="flex items-center gap-1.5 text-[11px] font-bold text-[#4a4743] cursor-pointer">
                  <input
                    type="checkbox"
                    checked={audioTrim?.isFullTrack ?? true}
                    onChange={(e) =>
                      setAudioTrim((prev) => ({ ...prev, isFullTrack: e.target.checked }))
                    }
                    className="rounded accent-[#ffc72c] w-3.5 h-3.5"
                  />
                  <span>Full Track (No Clip)</span>
                </label>
              </div>

              {/* Analog Audio Spectrum Waveform Visualizer */}
              <div
                ref={waveformRef}
                onClick={handleWaveformClick}
                className="relative h-20 bg-[#161514] rounded-xl p-2.5 flex items-end justify-between gap-1 overflow-hidden border border-[#3a3835] cursor-pointer select-none shadow-inner"
                title="Click anywhere to seek or inspect waveform"
              >
                {/* Background Grid Pattern */}
                <div
                  className="absolute inset-0 opacity-10 pointer-events-none"
                  style={{
                    backgroundImage: "linear-gradient(to right, #ffc72c 1px, transparent 1px), linear-gradient(to bottom, #ffc72c 1px, transparent 1px)",
                    backgroundSize: "16px 16px",
                  }}
                />

                {/* Trim Window Highlight Overlay */}
                <div
                  className="absolute top-0 bottom-0 bg-[#ffc72c]/15 border-x-2 border-[#ffc72c] pointer-events-none transition-all shadow-[0_0_15px_rgba(255,199,44,0.3)]"
                  style={{
                    left: `${trimStartPercent}%`,
                    width: `${Math.max(0, trimEndPercent - trimStartPercent)}%`,
                  }}
                />

                {/* Live Playhead Needle */}
                <div
                  className="absolute top-0 bottom-0 w-0.5 bg-[#ff3366] shadow-[0_0_8px_#ff3366] pointer-events-none transition-all z-10"
                  style={{ left: `${playheadPercent}%` }}
                >
                  <div className="w-2.5 h-2.5 -ml-1 rounded-full bg-[#ff3366] shadow" />
                </div>

                {/* Waveform Bars */}
                {waveformBars.map((height, idx) => {
                  const barPercent = (idx / waveformBars.length) * 100;
                  const isInsideTrim = barPercent >= trimStartPercent && barPercent <= trimEndPercent;
                  return (
                    <div
                      key={idx}
                      className={`flex-1 rounded-t-sm transition-all duration-75 ${
                        isInsideTrim
                          ? "bg-gradient-to-t from-[#bf8a00] to-[#ffc72c] shadow-[0_0_4px_rgba(255,199,44,0.4)]"
                          : "bg-[#3a3835] opacity-50"
                      }`}
                      style={{ height: `${height}%` }}
                    />
                  );
                })}
              </div>

              {/* Start & End Point Range Sliders */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-1">
                <div className="bg-[#242220] p-2.5 rounded-xl border border-[#3a3835]">
                  <div className="flex items-center justify-between text-[10px] font-bold text-[#a89f90] mb-1">
                    <span>START POINT:</span>
                    <span className="font-mono text-amber-400 font-bold">{formatTime(trimStart)}</span>
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
                    className="w-full accent-[#ffc72c] cursor-pointer"
                  />
                </div>

                <div className="bg-[#242220] p-2.5 rounded-xl border border-[#3a3835]">
                  <div className="flex items-center justify-between text-[10px] font-bold text-[#a89f90] mb-1">
                    <span>END POINT:</span>
                    <span className="font-mono text-amber-400 font-bold">{formatTime(trimEnd)}</span>
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
                    className="w-full accent-[#ffc72c] cursor-pointer"
                  />
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* BOTTOM: Curated Sound Library (Analog Tape Rack) */}
      <div className="metal-panel rounded-3xl p-6 relative shadow-xl">
        <div className="flex items-center justify-between mb-4 border-b border-[#a89f90] pb-3">
          <div>
            <h3 className="font-black text-base text-[#2b2b2d] tracking-tight uppercase flex items-center gap-2">
              <Music className="w-5 h-5 text-[#bf8a00]" />
              STUDIO SOUND LIBRARY (TAPE RACK)
            </h3>
            <p className="text-xs text-[#5a5752] mt-0.5">
              Select from curated, royalty-free beat-synchronized studio tracks.
            </p>
          </div>
          <span className="px-3.5 py-1 rounded-full bg-[#ffc72c]/30 border border-[#bf8a00] font-black text-xs text-[#2b2820]">
            {SOUND_TRACKS.length} CASSETTES
          </span>
        </div>

        {/* Tape Grid: Renders all built-in tracks */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {SOUND_TRACKS.map((track) => {
            const isLoaded = selectedTrack?.id === track.id || (!selectedTrack && !audioFile && track.id === SOUND_TRACKS[0].id);
            const isPreviewing = previewTrackId === track.id;

            return (
              <div
                key={track.id}
                className={`rounded-2xl p-4 transition-all flex flex-col justify-between border-2 ${
                  isLoaded
                    ? "bg-[#ffc72c]/15 border-[#ffc72c] shadow-lg"
                    : "metal-inset hover:border-[#7a766f]"
                }`}
              >
                <div>
                  <div className="flex items-start justify-between gap-2">
                    <span className="font-black text-sm text-[#2b2b2d] leading-tight line-clamp-1">
                      {track.title}
                    </span>
                    <span className="px-2 py-0.5 rounded bg-[#1e1c1a] text-amber-400 font-mono font-bold text-[10px] shrink-0">
                      {track.bpm}
                    </span>
                  </div>
                  <p className="text-[11px] font-bold text-[#bf8a00] mt-1">{track.genre}</p>
                  <p className="text-[10px] text-[#5a5752] line-clamp-2 mt-1 leading-relaxed">
                    {track.vibe}
                  </p>
                </div>

                <div className="flex items-center justify-between gap-2 mt-4 pt-3 border-t border-[#8f8677]/40">
                  {/* Preview audio button */}
                  <button
                    type="button"
                    onClick={() => togglePreview(track)}
                    className="flex items-center gap-1.5 text-[11px] font-bold text-[#4a4743] hover:text-[#2b2b2d] px-2.5 py-1 rounded-lg hover:bg-black/5 transition"
                    title={isPreviewing ? "Pause preview" : "Listen to preview"}
                  >
                    {isPreviewing ? (
                      <Volume2 className="w-4 h-4 text-[#ff3366] animate-pulse" />
                    ) : (
                      <Play className="w-4 h-4" />
                    )}
                    <span>{isPreviewing ? "PLAYING" : "PREVIEW"}</span>
                  </button>

                  {/* Insert Tape Button */}
                  <button
                    type="button"
                    onClick={() => handleInsertTape(track)}
                    className={`px-3 py-1.5 rounded-xl font-black text-xs flex items-center gap-1 transition ${
                      isLoaded
                        ? "bg-[#00c853] text-white shadow"
                        : "btn-brass text-[#2b2820] hover:brightness-105 active:scale-95"
                    }`}
                  >
                    {isLoaded && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                    <span>{isLoaded ? "INSERTED" : "INSERT TAPE"}</span>
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

