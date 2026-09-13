"use client";

import { useState, useRef, useEffect } from "react";
import { SOUND_TRACKS } from "@/lib/constants";
import { Play, Pause, Disc, Upload, Scissors, Volume2, Check } from "lucide-react";

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

  const toggleMainPlay = () => {
    if (!audioRef.current || !audioUrl) return;
    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current.currentTime = audioTrim.start || 0;
      audioRef.current.play().catch(console.warn);
      setIsPlaying(true);
    }
  };

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const handleTimeUpdate = () => {
      setCurrentTime(audio.currentTime);
      if (audioTrim.end > audioTrim.start && audio.currentTime >= audioTrim.end) {
        audio.pause();
        audio.currentTime = audioTrim.start;
        setIsPlaying(false);
      }
    };

    const handleEnded = () => setIsPlaying(false);

    audio.addEventListener("timeupdate", handleTimeUpdate);
    audio.addEventListener("ended", handleEnded);
    return () => {
      audio.removeEventListener("timeupdate", handleTimeUpdate);
      audio.removeEventListener("ended", handleEnded);
    };
  }, [audioTrim]);

  // Preview built-in track
  const togglePreview = (track) => {
    if (previewTrackId === track.id) {
      if (previewAudioRef.current) {
        previewAudioRef.current.pause();
        setPreviewTrackId(null);
      }
    } else {
      setPreviewTrackId(track.id);
      if (previewAudioRef.current) {
        previewAudioRef.current.src = track.assetPath;
        previewAudioRef.current.play().catch(console.warn);
      }
    }
  };

  const formatTime = (secs) => {
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  return (
    <div className="space-y-6">
      <audio ref={audioRef} src={audioUrl || ""} preload="metadata" />
      <audio ref={previewAudioRef} onEnded={() => setPreviewTrackId(null)} />

      {/* TOP: Physical Cassette Tape Deck Console */}
      <div className="metal-panel rounded-3xl p-6 relative overflow-hidden">
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        <div className="max-w-3xl mx-auto space-y-4">
          {/* Deck Header & Tape Counter */}
          <div className="flex items-center justify-between border-b border-[#a89f90] pb-2">
            <div className="flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-[#ff3366]" />
              <h2 className="font-black text-sm tracking-wider text-[#2b2b2d] uppercase">
                STUDIO CASSETTE TAPE TRANSPORT
              </h2>
            </div>
            {/* Nixie / Mechanical Tape Counter */}
            <div className="px-3 py-1 rounded bg-[#1e1c1a] border border-[#3a3835] font-mono text-amber-400 font-bold text-xs tracking-widest shadow-inner">
              TAPE {formatTime(currentTime)} / {formatTime(audioDuration)}
            </div>
          </div>

          {/* Cassette Tape Well */}
          <div className="metal-inset rounded-2xl p-4 flex flex-col md:flex-row items-center justify-between gap-4">
            {/* Spinning Spools Simulation */}
            <div className="flex items-center gap-6 p-3 rounded-xl bg-[#1e1c1a] border border-[#3a3835] shadow-inner">
              <div
                className={`w-14 h-14 rounded-full border-4 border-[#ffc72c] bg-[#2a2826] flex items-center justify-center ${
                  isPlaying ? "animate-spin" : ""
                }`}
              >
                <div className="w-4 h-4 rounded-full bg-[#1e1c1a] border-2 border-[#ffc72c]" />
              </div>
              <div className="text-center">
                <p className="text-[10px] font-mono text-[#a89f90] uppercase tracking-widest">
                  ANALOG TAPE
                </p>
                <p className="text-xs font-black text-white truncate max-w-[200px]">
                  {selectedTrack ? selectedTrack.title : audioFile ? audioFile.name : "NO TAPE INSERTED"}
                </p>
                <p className="text-[10px] text-amber-400 font-bold">
                  {selectedTrack ? selectedTrack.bpm : "Custom Track"}
                </p>
              </div>
              <div
                className={`w-14 h-14 rounded-full border-4 border-[#ffc72c] bg-[#2a2826] flex items-center justify-center ${
                  isPlaying ? "animate-spin" : ""
                }`}
              >
                <div className="w-4 h-4 rounded-full bg-[#1e1c1a] border-2 border-[#ffc72c]" />
              </div>
            </div>

            {/* Transport Buttons */}
            <div className="flex items-center gap-3">
              <button
                onClick={toggleMainPlay}
                disabled={!audioUrl}
                className="btn-brass px-5 py-3 rounded-2xl flex items-center gap-2 font-black text-xs shadow-md"
              >
                {isPlaying ? <Pause className="w-4 h-4 fill-current" /> : <Play className="w-4 h-4 fill-current" />}
                <span>{isPlaying ? "PAUSE" : "PLAY TAPE"}</span>
              </button>

              <button
                onClick={() => fileInputRef.current?.click()}
                className="px-4 py-3 rounded-2xl metal-panel text-[#2b2b2d] font-black text-xs flex items-center gap-2 hover:bg-white/40 transition shadow"
              >
                <Upload className="w-4 h-4" />
                <span>LOAD CUSTOM MP3</span>
              </button>
              <input
                type="file"
                ref={fileInputRef}
                onChange={(e) => {
                  if (e.target.files?.[0]) setAudio(e.target.files[0]);
                }}
                accept="audio/*"
                className="hidden"
              />
            </div>
          </div>

          {/* Interactive Trimmer Waveform Bar */}
          {audioUrl && (
            <div className="metal-inset rounded-xl p-3 space-y-2">
              <div className="flex items-center justify-between text-xs font-bold text-[#2b2b2d]">
                <span className="flex items-center gap-1.5">
                  <Scissors className="w-3.5 h-3.5 text-[#bf8a00]" />
                  TRIM WINDOW: {formatTime(audioTrim.start)} - {formatTime(audioTrim.end)} (
                  {Math.round(audioTrim.end - audioTrim.start)}s)
                </span>
                <label className="flex items-center gap-1.5 text-[11px] font-semibold text-[#4a4743] cursor-pointer">
                  <input
                    type="checkbox"
                    checked={audioTrim.isFullTrack}
                    onChange={(e) =>
                      setAudioTrim((prev) => ({ ...prev, isFullTrack: e.target.checked }))
                    }
                    className="rounded accent-[#ffc72c]"
                  />
                  <span>Full Track</span>
                </label>
              </div>

              <div className="grid grid-cols-2 gap-4 pt-1">
                <div>
                  <span className="text-[10px] font-bold text-[#5a5752]">START POINT</span>
                  <input
                    type="range"
                    min={0}
                    max={Math.max(audioDuration - 5, 0)}
                    step={0.5}
                    value={audioTrim.start}
                    onChange={(e) => {
                      const start = parseFloat(e.target.value);
                      const end = Math.max(start + 5, audioTrim.end);
                      setAudioTrim((prev) => ({ ...prev, start, end, isFullTrack: false }));
                    }}
                    className="w-full"
                  />
                </div>
                <div>
                  <span className="text-[10px] font-bold text-[#5a5752]">END POINT</span>
                  <input
                    type="range"
                    min={Math.min(audioTrim.start + 5, audioDuration)}
                    max={audioDuration || 60}
                    step={0.5}
                    value={audioTrim.end}
                    onChange={(e) => {
                      const end = parseFloat(e.target.value);
                      setAudioTrim((prev) => ({ ...prev, end, isFullTrack: false }));
                    }}
                    className="w-full"
                  />
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* BOTTOM: Curated Sound Library (Analog Tape Rack) */}
      <div className="metal-panel rounded-3xl p-6 relative">
        <div className="flex items-center justify-between mb-4 border-b border-[#a89f90] pb-2">
          <div>
            <h3 className="font-black text-base text-[#2b2b2d] tracking-tight uppercase">
              STUDIO SOUND LIBRARY (TAPE RACK)
            </h3>
            <p className="text-xs text-[#5a5752]">
              Select from curated, royalty-free beat-synchronized studio tracks.
            </p>
          </div>
          <span className="px-3 py-1 rounded-full bg-[#ffc72c]/40 border border-[#bf8a00] font-black text-xs text-[#2b2820]">
            {SOUND_TRACKS.length} CASSETTES
          </span>
        </div>

        {/* Tape Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3.5">
          {SOUND_TRACKS.map((track) => {
            const isLoaded = selectedTrack?.id === track.id;
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
                  <p className="text-[11px] font-bold text-[#bf8a00] mt-0.5">{track.genre}</p>
                  <p className="text-[10px] text-[#5a5752] line-clamp-2 mt-1 leading-relaxed">
                    {track.vibe}
                  </p>
                </div>

                <div className="flex items-center justify-between gap-2 mt-4 pt-2 border-t border-[#8f8677]/40">
                  {/* Preview audio button */}
                  <button
                    onClick={() => togglePreview(track)}
                    className="flex items-center gap-1 text-[11px] font-bold text-[#4a4743] hover:text-[#2b2b2d] px-2 py-1 rounded hover:bg-black/5 transition"
                  >
                    {isPreviewing ? <Volume2 className="w-3.5 h-3.5 text-[#ff3366] animate-bounce" /> : <Play className="w-3.5 h-3.5" />}
                    <span>{isPreviewing ? "PLAYING" : "PREVIEW"}</span>
                  </button>

                  {/* Insert Tape Button */}
                  <button
                    onClick={() => onSelectBuiltInTrack(track)}
                    className={`px-3 py-1.5 rounded-xl font-black text-xs flex items-center gap-1 transition ${
                      isLoaded
                        ? "bg-[#00c853] text-white shadow"
                        : "btn-brass text-[#2b2820]"
                    }`}
                  >
                    {isLoaded && <Check className="w-3 h-3 stroke-[3]" />}
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
