"use client";

import { useRef, useState } from "react";
import { Images, Wand2, Plus, GripVertical, Sparkles, Loader2 } from "lucide-react";
import { SAMPLE_PHOTOS } from "@/lib/constants";

export function PhotoSequencer({
  photos,
  addPhotos,
  removePhoto,
  reorderPhotos,
  clearPhotos,
  autoArrange,
  setAutoArrange,
}) {
  const fileInputRef = useRef(null);
  const [loadingSamples, setLoadingSamples] = useState(false);

  const handleFiles = (e) => {
    if (e.target.files) {
      addPhotos(e.target.files);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      addPhotos(e.dataTransfer.files);
    }
  };

  const loadSamplePhotos = async () => {
    setLoadingSamples(true);
    try {
      const paths = SAMPLE_PHOTOS && SAMPLE_PHOTOS.length > 0 ? SAMPLE_PHOTOS : [
        "/assets/sample_photos/sample_01.jpg",
        "/assets/sample_photos/sample_02.jpg",
        "/assets/sample_photos/sample_03.jpg",
        "/assets/sample_photos/sample_04.jpg",
        "/assets/sample_photos/sample_05.jpg",
        "/assets/sample_photos/sample_06.jpg",
        "/assets/sample_photos/sample_07.jpg",
        "/assets/sample_photos/sample_08.jpg",
      ];
      const files = await Promise.all(
        paths.map(async (path, idx) => {
          const res = await fetch(path);
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const blob = await res.blob();
          const fileName = path.split("/").pop() || `sample_0${idx + 1}.jpg`;
          return new File([blob], fileName, { type: blob.type || "image/jpeg" });
        })
      );
      addPhotos(files);
    } catch (e) {
      console.error("Failed to load sample photos in PhotoSequencer:", e);
    } finally {
      setLoadingSamples(false);
    }
  };

  return (
    <div className="rounded-2xl bg-[#151922] border border-[#242b38] p-4 shadow-sm flex flex-col h-full">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-cyan-500/10 border border-cyan-500/20 flex items-center justify-center text-cyan-400">
            <Images className="w-4 h-4" />
          </div>
          <span className="font-bold text-sm text-white">Photos ({photos.length}/20)</span>
        </div>

        <div className="flex items-center gap-2">
          {photos.length === 0 && (
            <button
              type="button"
              onClick={loadSamplePhotos}
              disabled={loadingSamples}
              className="flex items-center gap-1 text-[11px] text-amber-400/90 hover:text-amber-300 font-semibold px-2 py-1 rounded bg-amber-500/10 hover:bg-amber-500/20 transition disabled:opacity-50"
              title="Load 8 sample photos"
            >
              {loadingSamples ? (
                <Loader2 className="w-3 h-3 animate-spin" />
              ) : (
                <Sparkles className="w-3 h-3 text-amber-400" />
              )}
              <span>Samples</span>
            </button>
          )}

          {photos.length > 0 && (
            <button
              type="button"
              onClick={clearPhotos}
              className="flex items-center gap-1 text-[11px] text-rose-400 hover:text-rose-300 font-semibold px-2 py-1 rounded bg-rose-500/10 hover:bg-rose-500/20 transition"
              title="Clear all photos"
            >
              <img
                src="/assets/images/btn_delete.png"
                alt="Delete"
                className="w-3.5 h-3.5 object-contain"
              />
              <span>Clear</span>
            </button>
          )}
        </div>
      </div>

      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFiles}
        multiple
        accept="image/*"
        className="hidden"
      />

      {/* Grid of photos */}
      <div
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
        className="grid grid-cols-3 sm:grid-cols-4 gap-2.5 max-h-[300px] overflow-y-auto p-1 rounded-xl bg-[#11141c]/50 border border-[#242b38]/50 flex-1"
      >
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
            className="group relative aspect-square rounded-xl overflow-hidden bg-[#1f2633] border border-[#2d3748] hover:border-amber-400/80 transition-all cursor-grab active:cursor-grabbing shadow-sm"
          >
            <img
              src={p.previewUrl}
              alt={`Photo ${index + 1}`}
              className="w-full h-full object-cover select-none"
            />
            {/* Number Pill */}
            <div className="absolute top-1.5 left-1.5 px-1.5 py-0.5 rounded-md bg-black/75 backdrop-blur-sm text-[10px] font-bold text-white border border-white/10">
              #{index + 1}
            </div>

            {/* Remove Button using btn_delete.png */}
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                removePhoto(p.id);
              }}
              className="absolute top-1.5 right-1.5 w-6 h-6 rounded-md overflow-hidden opacity-0 group-hover:opacity-100 transition shadow-md hover:scale-110 active:scale-95 bg-black/70 p-0.5 border border-white/20"
              title="Remove Photo"
            >
              <img
                src="/assets/images/btn_delete.png"
                alt="Delete"
                className="w-full h-full object-contain pointer-events-none"
              />
            </button>

            <div className="absolute bottom-1 right-1 opacity-0 group-hover:opacity-75 text-white">
              <GripVertical className="w-3 h-3" />
            </div>
          </div>
        ))}

        {photos.length < 20 && (
          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="aspect-square rounded-xl border-2 border-dashed border-[#2d3748] hover:border-amber-400/60 flex flex-col items-center justify-center p-2 text-gray-400 hover:text-white transition bg-[#181e29]/40 hover:bg-[#181e29]"
          >
            <Plus className="w-6 h-6 mb-1 text-amber-400" />
            <span className="text-[10px] font-bold">Add Photos</span>
          </button>
        )}
      </div>

      {/* Auto Arrange Toggle */}
      <div className="mt-3 pt-3 border-t border-[#242b38]/60 flex items-center justify-between">
        <div className="flex items-center gap-1.5">
          <Wand2 className="w-3.5 h-3.5 text-amber-400" />
          <span className="text-xs text-gray-300 font-medium">Smart Auto-Arrange</span>
        </div>
        <label className="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            checked={autoArrange}
            onChange={(e) => setAutoArrange(e.target.checked)}
            className="sr-only peer"
          />
          <div className="w-9 h-5 bg-[#2d3748] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-amber-500"></div>
        </label>
      </div>
    </div>
  );
}

