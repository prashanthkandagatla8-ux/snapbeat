"use client";

import { useRef, useState } from "react";
import { Plus, X, Shuffle, AlertCircle, Sparkles, Loader2, Images, Trash2 } from "lucide-react";
import { trackPhotosUploaded } from "@/lib/analytics";

export function RetroPhotoStrip({
  photos,
  addPhotos,
  removePhoto,
  reorderPhotos,
  shufflePhotos,
  clearPhotos,
  autoArrange,
  setAutoArrange,
}) {
  const fileInputRef = useRef(null);
  const [loadingSamples, setLoadingSamples] = useState(false);
  const [loadError, setLoadError] = useState(null);

  const handleFileChange = (e) => {
    if (e.target.files && e.target.files.length > 0) {
      trackPhotosUploaded(e.target.files.length, "file_picker");
      addPhotos(e.target.files);
    }
  };

  const handleShuffle = () => {
    if (shufflePhotos) {
      shufflePhotos();
    } else {
      const indices = photos.map((_, i) => i);
      for (let i = indices.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [indices[i], indices[j]] = [indices[j], indices[i]];
      }
      indices.forEach((from, to) => {
        if (from !== to) reorderPhotos(from, to);
      });
    }
  };

  // 1-Click Sample Photos Loader
  const loadSamplePhotos = async () => {
    setLoadingSamples(true);
    setLoadError(null);

    const samplePaths = [
      "/assets/sample_photos/sample_01.jpg",
      "/assets/sample_photos/sample_02.jpg",
      "/assets/sample_photos/sample_03.jpg",
      "/assets/sample_photos/sample_04.jpg",
      "/assets/sample_photos/sample_05.jpg",
      "/assets/sample_photos/sample_06.jpg",
      "/assets/sample_photos/sample_07.jpg",
      "/assets/sample_photos/sample_08.jpg",
    ];

    try {
      const files = await Promise.all(
        samplePaths.map(async (path, idx) => {
          const res = await fetch(path);
          if (!res.ok) {
            throw new Error(`Failed to load ${path} (status ${res.status})`);
          }
          const blob = await res.blob();
          const fileName = path.split("/").pop() || `sample_0${idx + 1}.jpg`;
          return new File([blob], fileName, { type: blob.type || "image/jpeg" });
        })
      );
      trackPhotosUploaded(files.length, "sample_photos");
      addPhotos(files);
    } catch (err) {
      console.error("Failed to load sample photos:", err);
      setLoadError("Could not load sample photos. Please upload your own images.");
    } finally {
      setLoadingSamples(false);
    }
  };

  return (
    <div className="sky-glass-panel rounded-3xl p-6 relative shadow-2xl text-white">
      <div className="max-w-5xl mx-auto space-y-6">
        {/* Header Bar */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-white/10 pb-3">
          <div>
            <h2 className="font-black text-lg text-white tracking-tight uppercase flex items-center gap-2">
              <Images className="w-5 h-5 text-amber-400" />
              PHOTO SEQUENCE BAY ({photos.length} / 20)
            </h2>
            <p className="text-xs text-amber-100/70 mt-0.5">
              Drag and drop cards to adjust the rhythmic order of video cuts.
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center gap-2.5 flex-wrap">
            {/* Load Sample Photos Button (Header - shown when photos exist for quick re-load) */}
            {photos.length > 0 && (
              <button
                type="button"
                onClick={loadSamplePhotos}
                disabled={loadingSamples}
                className="px-4 py-2 rounded-full bg-white/10 hover:bg-white/20 text-white text-xs font-black flex items-center gap-1.5 border border-white/15 active:scale-95 transition disabled:opacity-50 cursor-pointer"
                title="Reload 8 sample photos"
              >
                {loadingSamples ? (
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                ) : (
                  <Sparkles className="w-3.5 h-3.5 text-amber-400 ml-0.5" />
                )}
                <span>RELOAD SAMPLES</span>
              </button>
            )}

            {photos.length > 1 && (
              <button
                type="button"
                onClick={handleShuffle}
                className="px-3.5 py-2 rounded-full bg-white/10 hover:bg-white/20 text-xs font-bold text-white flex items-center gap-1.5 border border-white/15 active:scale-95 transition cursor-pointer"
                title="Shuffle Photo Sequence"
              >
                <Shuffle className="w-3.5 h-3.5 text-amber-400" />
                <span>SHUFFLE</span>
              </button>
            )}

            {photos.length > 0 && (
              <button
                type="button"
                onClick={clearPhotos}
                className="px-3.5 py-2 rounded-full bg-red-500/20 hover:bg-red-500/30 text-xs font-bold text-red-300 flex items-center gap-1.5 border border-red-500/40 active:scale-95 transition cursor-pointer"
                title="Clear All Photos"
              >
                <Trash2 className="w-3.5 h-3.5" />
                <span>CLEAR ALL</span>
              </button>
            )}
          </div>
        </div>

        {loadError && (
          <div className="flex items-center gap-2 p-3 rounded-xl bg-red-950/80 border border-red-500/50 text-red-300 text-xs font-semibold">
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{loadError}</span>
          </div>
        )}

        {/* Photos Well */}
        <div
          onDragOver={(e) => e.preventDefault()}
          onDrop={(e) => {
            e.preventDefault();
            if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
              addPhotos(e.dataTransfer.files);
            }
          }}
          className="bg-black/40 backdrop-blur-md rounded-2xl p-5 min-h-[320px] max-h-[520px] overflow-y-auto border border-white/10"
        >
          {photos.length === 0 ? (
            <div className="border-2 border-dashed border-amber-400/40 rounded-2xl p-8 sm:p-12 flex flex-col items-center justify-center text-center space-y-4 bg-black/30">
              <div
                onClick={() => fileInputRef.current?.click()}
                className="w-16 h-16 rounded-2xl btn-gold-radiant flex items-center justify-center text-[#241903] shadow-lg cursor-pointer hover:scale-105 transition"
              >
                <Plus className="w-8 h-8 stroke-[3]" />
              </div>
              <div>
                <p className="font-black text-sm text-white uppercase tracking-wider">
                  Click or Drop Photos Here
                </p>
                <p className="text-xs text-amber-100/70 mt-1">
                  Select between 2 and 20 JPEG, PNG, or WebP images
                </p>
              </div>

              {/* Instant 1-Click Sample Photos Option */}
              <div className="pt-2 border-t border-white/10 w-full max-w-xs">
                <button
                  type="button"
                  onClick={loadSamplePhotos}
                  disabled={loadingSamples}
                  className="w-full py-3 rounded-full btn-gold-radiant text-[#241903] font-black text-xs uppercase tracking-wider shadow-md hover:scale-105 active:scale-95 transition flex items-center justify-center gap-2 disabled:opacity-50 cursor-pointer"
                >
                  {loadingSamples ? (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  ) : (
                    <Sparkles className="w-4 h-4 fill-current" />
                  )}
                  <span>LOAD 8 SAMPLE PHOTOS</span>
                </button>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
              {photos.map((p, index) => (
                <div
                  key={p.id}
                  draggable
                  onDragStart={(e) => e.dataTransfer.setData("text/plain", index)}
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={(e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    const fromIndex = parseInt(e.dataTransfer.getData("text/plain"), 10);
                    if (!isNaN(fromIndex) && fromIndex !== index) {
                      reorderPhotos(fromIndex, index);
                    }
                  }}
                  className="group relative rounded-2xl bg-black/60 p-2 shadow-md hover:shadow-2xl border border-white/15 hover:border-amber-400 transition-all cursor-grab active:cursor-grabbing hover:-translate-y-1"
                >
                  <div className="relative aspect-[3/4] w-full rounded-xl overflow-hidden bg-black border border-white/10">
                    <img
                      src={p.previewUrl}
                      alt={`Photo ${index + 1}`}
                      className="w-full h-full object-cover select-none pointer-events-none"
                    />
                    {/* Stamped Number Pill */}
                    <div className="absolute top-2 left-2 px-2.5 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] font-mono font-black text-[10px] shadow">
                      #{index + 1}
                    </div>

                    {/* Delete Button */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        removePhoto(p.id);
                      }}
                      className="absolute top-2 right-2 w-7 h-7 rounded-full bg-black/70 hover:bg-red-600 text-white flex items-center justify-center shadow transition active:scale-95 cursor-pointer border border-white/20"
                      title="Remove Photo"
                      aria-label={`Remove photo ${index + 1}`}
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}

              {/* Add More Photos Slot */}
              {photos.length < 20 && (
                <div
                  onClick={() => fileInputRef.current?.click()}
                  className="rounded-2xl border-2 border-dashed border-white/20 hover:border-amber-400 bg-black/30 flex flex-col items-center justify-center p-4 aspect-[3/4] cursor-pointer hover:bg-black/50 transition group"
                >
                  <div className="w-10 h-10 rounded-full bg-white/10 group-hover:bg-amber-400 group-hover:text-[#241903] text-white flex items-center justify-center transition mb-2">
                    <Plus className="w-5 h-5 stroke-[2.5]" />
                  </div>
                  <span className="text-[11px] font-black text-white group-hover:text-amber-300 uppercase">
                    Add Photo
                  </span>
                  <span className="text-[9px] text-amber-100/60 font-mono mt-0.5">
                    {20 - photos.length} REMAINING
                  </span>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Auto Arrange & Guidelines Footnote */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-2 text-xs text-amber-100/70 border-t border-white/10">
          <label className="flex items-center gap-2 cursor-pointer select-none">
            <input
              type="checkbox"
              checked={autoArrange}
              onChange={(e) => setAutoArrange(e.target.checked)}
              className="w-4 h-4 rounded accent-amber-400 cursor-pointer"
            />
            <span className="font-bold text-white">Smart Pace Harmonization (Auto-match beat tempo)</span>
          </label>
          <span className="font-mono text-[11px] text-amber-300">
            MINIMUM 2 PHOTOS REQUIRED • RECOMMENDED 6-12
          </span>
        </div>
      </div>

      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        multiple
        accept="image/jpeg,image/png,image/webp"
        className="hidden"
      />
    </div>
  );
}
