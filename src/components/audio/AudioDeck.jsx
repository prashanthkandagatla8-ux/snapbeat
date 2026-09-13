"use client";

import { useState, useRef, useEffect } from "react";
import { Music, Play, Pause, Scissors, UploadCloud, RefreshCw } from "lucide-react";

export function AudioDeck({ audioFile, audioUrl, audioDuration, audioTrim, setAudio, setAudioTrim }) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const audioRef = useRef(null);
  const fileInputRef = useRef(null);

  const togglePlay = () => {
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

  const handleFileChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      setAudio(e.target.files[0]);
    }
  };

  const loadSampleTrack = async () => {
    try {
      const res = await fetch("/sample_music.mp3");
      if (!res.ok) throw new Error("Sample not found");
      const blob = await res.blob();
      const file = new File([blob], "Little_Do_You_Know_Sample.mp3", { type: "audio/mp3" });
      setAudio(file);
    } catch {
      alert("Could not load sample track. Please upload your own MP3.");
    }
  };

  const formatTime = (secs) => {
    const m = Math.floor(secs / 60);
    const s = Math.floor(secs % 60);
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

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
          className="flex items-center gap-1 text-[11px] text-amber-400/90 hover:text-amber-300 font-semibold px-2 py-1 rounded-md bg-amber-500/10 hover:bg-amber-500/20 transition"
        >
          <RefreshCw className="w-3 h-3" />
          <span>Load Sample</span>
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
          <audio ref={audioRef} src={audioUrl} preload="metadata" />

          {/* Track Info Card */}
          <div className="flex items-center justify-between p-3 rounded-xl bg-[#1a202c] border border-[#2d3748]">
            <div className="flex items-center gap-3 overflow-hidden">
              <button
                onClick={togglePlay}
                className="w-10 h-10 rounded-xl bg-amber-500 text-black flex items-center justify-center font-bold hover:bg-amber-400 transition shadow"
              >
                {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 ml-0.5" />}
              </button>
              <div className="overflow-hidden">
                <p className="text-xs font-bold text-white truncate max-w-[170px]">
                  {audioFile ? audioFile.name : "Custom Audio Track"}
                </p>
                <p className="text-[11px] text-gray-400">
                  {formatTime(currentTime)} / {formatTime(audioDuration)}
                </p>
              </div>
            </div>
            <button
              onClick={() => fileInputRef.current?.click()}
              className="text-xs text-gray-400 hover:text-white px-2 py-1 rounded hover:bg-white/5 transition"
            >
              Change
            </button>
          </div>

          {/* Trimmer Controls */}
          <div className="p-3 rounded-xl bg-[#1a202c]/60 border border-[#2d3748]/60 space-y-2">
            <div className="flex items-center justify-between text-[11px] text-gray-400">
              <span className="flex items-center gap-1 font-semibold text-gray-300">
                <Scissors className="w-3 h-3 text-amber-400" />
                Trim Section
              </span>
              <span>
                {formatTime(audioTrim.start)} - {formatTime(audioTrim.end)} (
                {Math.max(0, Math.round(audioTrim.end - audioTrim.start))}s)
              </span>
            </div>

            <div className="space-y-1.5 pt-1">
              <div className="flex items-center justify-between text-[10px] text-gray-400">
                <span>Start: {formatTime(audioTrim.start)}</span>
                <input
                  type="range"
                  min={0}
                  max={Math.max(audioDuration - 5, 0)}
                  step={0.5}
                  value={audioTrim.start}
                  onChange={(e) => {
                    const startVal = parseFloat(e.target.value);
                    const endVal = Math.max(startVal + 5, audioTrim.end);
                    setAudioTrim((prev) => ({
                      ...prev,
                      start: startVal,
                      end: endVal,
                      isFullTrack: false,
                    }));
                  }}
                  className="w-36 h-1.5 bg-[#2d3748] rounded-lg appearance-none cursor-pointer"
                />
              </div>

              <div className="flex items-center justify-between text-[10px] text-gray-400">
                <span>End: {formatTime(audioTrim.end)}</span>
                <input
                  type="range"
                  min={Math.min(audioTrim.start + 5, audioDuration)}
                  max={audioDuration || 60}
                  step={0.5}
                  value={audioTrim.end}
                  onChange={(e) => {
                    const endVal = parseFloat(e.target.value);
                    setAudioTrim((prev) => ({
                      ...prev,
                      end: endVal,
                      isFullTrack: false,
                    }));
                  }}
                  className="w-36 h-1.5 bg-[#2d3748] rounded-lg appearance-none cursor-pointer"
                />
              </div>
            </div>

            <label className="flex items-center gap-2 pt-1 text-[11px] text-gray-300 cursor-pointer">
              <input
                type="checkbox"
                checked={audioTrim.isFullTrack}
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
