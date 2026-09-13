"use client";

import React, { useRef, useState } from "react";
import { Images, Plus, Shuffle, Wand2, GripVertical, Sparkles, Loader2, AlertCircle } from "lucide-react";
import { SAMPLE_PHOTOS } from "@/lib/constants";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";

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

  const handleShuffle = () => {
    if (typeof shufflePhotos === "function") {
      shufflePhotos();
      return;
    }
    if (photos.length < 2) return;
    for (let i = photos.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      if (j !== i) {
        reorderPhotos(j, i);
      }
    }
  };

  const loadSamplePhotos = async () => {
    setLoadingSamples(true);
    setLoadError(null);

    const samplePaths = SAMPLE_PHOTOS && SAMPLE_PHOTOS.length > 0 ? SAMPLE_PHOTOS : [
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
      addPhotos(files);
    } catch (err) {
      console.error("Failed to load sample photos:", err);
      setLoadError("Could not load sample photos. Please upload your own images.");
    } finally {
      setLoadingSamples(false);
    }
  };

  return (
    <div className="metal-panel rounded-3xl p-6 relative shadow-xl">
      <div className="absolute top-3 left-3 metal-screw" />
      <div className="absolute top-3 right-3 metal-screw" />
      <div className="absolute bottom-3 left-3 metal-screw" />
      <div className="absolute bottom-3 right-3 metal-screw" />

      <div className="max-w-4xl mx-auto space-y-6">
        {/* Header Bar */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-[#a89f90] pb-3">
          <div>
            <h2 className="font-black text-lg text-[#2b2b2d] tracking-tight uppercase flex items-center gap-2">
              <Images className="w-5 h-5 text-[#bf8a00]" />
              PHOTO REORDER BAY ({photos.length} / 20)
            </h2>
            <p className="text-xs text-[#5a5752]">
              Drag and drop Polaroid cards to adjust the rhythmic sequence of cuts.
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center gap-2 flex-wrap">
            {/* Load Sample Photos Button */}
            <button
              type="button"
              onClick={loadSamplePhotos}
              disabled={loadingSamples}
              className="px-3 py-1.5 rounded-xl btn-brass text-[#2b2820] text-xs font-black flex items-center gap-1.5 shadow hover:brightness-110 active:scale-95 transition disabled:opacity-50"
              title="Load 8 sample photos with 1-click"
            >
              {loadingSamples ? (
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
              ) : (
                <Sparkles className="w-3.5 h-3.5 text-amber-600" />
              )}
              <span>LOAD SAMPLE PHOTOS</span>
            </button>

            {photos.length > 1 && (
              <button
                type="button"
                onClick={handleShuffle}
                className="px-3 py-1.5 rounded-xl metal-inset text-xs font-bold text-[#2b2b2d] flex items-center gap-1.5 hover:bg-black/10 active:scale-95 transition shadow-inner"
                title="Shuffle Photo Sequence"
              >
                <Shuffle className="w-3.5 h-3.5 text-[#bf8a00]" />
                <span>SHUFFLE</span>
              </button>
            )}

            {photos.length > 0 && (
              <RetroMechanicalButton
                variant="delete"
                onClick={clearPhotos}
                height="32px"
                title="Clear All Photos"
              />
            )}
          </div>
        </div>

        {loadError && (
          <div className="flex items-center gap-2 p-3 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-700 text-xs font-semibold">
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
          className="metal-inset rounded-2xl p-5 min-h-[320px] max-h-[500px] overflow-y-auto"
        >
          {photos.length === 0 ? (
            <div className="border-2 border-dashed border-[#7a766f] rounded-2xl p-8 sm:p-12 flex flex-col items-center justify-center text-center space-y-4 bg-white/20">
              <div
                onClick={() => fileInputRef.current?.click()}
                className="w-16 h-16 rounded-2xl bg-[#ffc72c] border-2 border-[#bf8a00] flex items-center justify-center text-[#2b2820] shadow-md cursor-pointer hover:scale-105 transition"
              >
                <Plus className="w-8 h-8 stroke-[3]" />
              </div>
              <div>
                <p className="font-black text-sm text-[#2b2b2d] uppercase tracking-wider">
                  Click or Drop Photos Here
                </p>
                <p className="text-xs text-[#5a5752] mt-1">
                  Select between 2 and 20 JPEG, PNG, or WebP images
                </p>
              </div>

              {/* Instant 1-Click Sample Photos Option */}
              <div className="pt-2 border-t border-[#8f8677]/40 w-full max-w-xs">
                <button
                  type="button"
                  onClick={loadSamplePhotos}
                  disabled={loadingSamples}
                  className="w-full py-2.5 rounded-xl btn-brass text-[#2b2820] font-black text-xs uppercase tracking-wider shadow hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  {loadingSamples ? (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  ) : (
                    <Sparkles className="w-4 h-4 text-amber-600" />
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
                  className="group relative rounded-xl bg-white p-2 pb-6 shadow-md hover:shadow-2xl border border-[#d4cdc0] transition-all cursor-grab active:cursor-grabbing hover:-translate-y-1"
                  style={{
                    transform: `rotate(${index % 2 === 0 ? "-0.75deg" : "0.75deg"})`,
                  }}
                >
                  <div className="relative aspect-[3/4] w-full rounded-lg overflow-hidden bg-[#2a2826] border border-black/10">
                    <img
                      src={p.previewUrl}
                      alt={`Photo ${index + 1}`}
                      className="w-full h-full object-cover select-none pointer-events-none"
                    />
                    {/* Stamped Number Pill */}
                    <div className="absolute top-1.5 left-1.5 px-2 py-0.5 rounded bg-[#ffc72c] text-[#2b2820] font-mono font-black text-[10px] shadow-md border border-[#bf8a00]">
                      #{index + 1}
                    </div>

                    {/* Delete Button with btn_delete.png asset */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        removePhoto(p.id);
                      }}
                      className="absolute top-1.5 right-1.5 w-7 h-7 rounded-lg overflow-hidden opacity-0 group-hover:opacity-100 transition shadow-lg hover:scale-110 active:scale-90 focus:opacity-100 bg-[#1e1c1a]/90 p-0.5 border border-white/30 cursor-pointer"
                      title="Remove Photo"
                    >
                      <img
                        src="/assets/images/btn_delete.png"
                        alt="Delete"
                        className="w-full h-full object-contain pointer-events-none"
                      />
                    </button>

                    <div className="absolute bottom-1.5 right-1.5 text-white/90 opacity-0 group-hover:opacity-100 bg-black/50 rounded p-0.5 pointer-events-none">
                      <GripVertical className="w-3.5 h-3.5" />
                    </div>
                  </div>

                  {/* Polaroid Stamped Footer */}
                  <div className="mt-1 px-1 flex items-center justify-between text-[9px] font-mono text-[#7a766e] font-bold select-none">
                    <span>35MM SNAP</span>
                    <span className="text-amber-700">SLIDE {index + 1}</span>
                  </div>
                </div>
              ))}

              {photos.length < 20 && (
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="aspect-[3/4] rounded-xl border-2 border-dashed border-[#7a766f] hover:border-[#2b2b2d] flex flex-col items-center justify-center p-4 text-[#5a5752] hover:text-[#2b2b2d] transition bg-white/20 hover:bg-white/40 shadow-sm"
                >
                  <div className="w-10 h-10 rounded-xl bg-[#ffc72c]/30 border border-[#bf8a00]/40 flex items-center justify-center text-[#2b2820] mb-2 shadow-sm">
                    <Plus className="w-6 h-6 stroke-[3]" />
                  </div>
                  <span className="text-xs font-black uppercase tracking-wider">ADD SLIDE</span>
                  <span className="text-[9px] font-bold text-[#7a766e] mt-0.5">JPEG / PNG</span>
                </button>
              )}
            </div>
          )}
        </div>

        <input
          type="file"
          ref={fileInputRef}
          onChange={(e) => {
            if (e.target.files) addPhotos(e.target.files);
          }}
          multiple
          accept="image/*"
          className="hidden"
        />

        {/* Auto Arrange Toggle */}
        <div className="flex items-center justify-between p-3.5 rounded-2xl metal-inset">
          <div className="flex items-center gap-2">
            <Wand2 className="w-4 h-4 text-[#bf8a00]" />
            <div>
              <p className="font-black text-xs text-[#2b2b2d] uppercase">
                SMART AESTHETIC AUTO-ARRANGE
              </p>
              <p className="text-[10px] text-[#5a5752]">
                Analyzes lighting, color palette, and visual contrast for peak engagement.
              </p>
            </div>
          </div>
          <label className="relative inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              checked={autoArrange}
              onChange={(e) => setAutoArrange(e.target.checked)}
              className="sr-only peer"
            />
            <div className="w-11 h-6 bg-[#7a766f] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#00c853]"></div>
          </label>
        </div>
      </div>
    </div>
  );
}
