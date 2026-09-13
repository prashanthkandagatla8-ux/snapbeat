"use client";

import React, { useRef, useState } from "react";
import { Images, Plus, Trash2, Shuffle, Wand2, GripVertical, Sparkles, Loader2 } from "lucide-react";
import RetroMechanicalButton from "@/components/ui/RetroMechanicalButton";

export function RetroPhotoStrip({
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

  const shufflePhotos = () => {
    if (photos.length < 2) return;
    const shuffled = [...photos].sort(() => Math.random() - 0.5);
    shuffled.forEach((p, i) => reorderPhotos(photos.indexOf(p), i));
  };

  const loadSamplePhotos = async () => {
    setLoadingSamples(true);
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
          const blob = await res.blob();
          return new File([blob], `sample_0${idx + 1}.jpg`, { type: "image/jpeg" });
        })
      );
      addPhotos(files);
    } catch (err) {
      console.error("Failed to load sample photos", err);
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
              onClick={loadSamplePhotos}
              disabled={loadingSamples}
              className="px-3 py-1.5 rounded-xl btn-brass text-[#2b2820] text-xs font-black flex items-center gap-1.5 shadow hover:brightness-110 active:scale-95 transition"
              title="Load 8 sample photos from the mobile app"
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
                onClick={shufflePhotos}
                className="px-3 py-1.5 rounded-xl metal-inset text-xs font-bold text-[#2b2b2d] flex items-center gap-1.5 hover:bg-black/10 transition shadow-inner"
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

        {/* Photos Well */}
        <div
          onDragOver={(e) => e.preventDefault()}
          onDrop={(e) => {
            e.preventDefault();
            if (e.dataTransfer.files) addPhotos(e.dataTransfer.files);
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
                  onClick={loadSamplePhotos}
                  disabled={loadingSamples}
                  className="w-full py-2.5 rounded-xl btn-brass text-[#2b2820] font-black text-xs uppercase tracking-wider shadow hover:brightness-110 active:scale-95 transition flex items-center justify-center gap-2"
                >
                  {loadingSamples ? (
                    <Loader2 className="w-4 h-4 animate-spin" />
                  ) : (
                    <Sparkles className="w-4 h-4 text-amber-600" />
                  )}
                  <span>OR LOAD 8 SAMPLE PHOTOS</span>
                </button>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3.5">
              {photos.map((p, index) => (
                <div
                  key={p.id}
                  draggable
                  onDragStart={(e) => e.dataTransfer.setData("text/plain", index)}
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={(e) => {
                    e.preventDefault();
                    const fromIndex = parseInt(e.dataTransfer.getData("text/plain"), 10);
                    if (!isNaN(fromIndex) && fromIndex !== index) {
                      reorderPhotos(fromIndex, index);
                    }
                  }}
                  className="group relative aspect-[3/4] rounded-2xl overflow-hidden bg-[#2a2826] border-2 border-[#5a5752] hover:border-[#ffc72c] transition-all cursor-grab active:cursor-grabbing shadow-lg"
                >
                  <img
                    src={p.previewUrl}
                    alt={`Photo ${index + 1}`}
                    className="w-full h-full object-cover select-none"
                  />
                  {/* Stamped Number Pill */}
                  <div className="absolute top-2 left-2 px-2 py-0.5 rounded-md bg-[#ffc72c] text-[#2b2820] font-mono font-black text-[11px] shadow-md border border-[#bf8a00]">
                    #{index + 1}
                  </div>
                  {/* Delete Button */}
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      removePhoto(p.id);
                    }}
                    className="absolute top-2 right-2 w-6 h-6 rounded-full bg-[#d62828] text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition shadow-md font-black"
                  >
                    ×
                  </button>
                  <div className="absolute bottom-2 right-2 text-white opacity-0 group-hover:opacity-75">
                    <GripVertical className="w-4 h-4" />
                  </div>
                </div>
              ))}

              {photos.length < 20 && (
                <button
                  onClick={() => fileInputRef.current?.click()}
                  className="aspect-[3/4] rounded-2xl border-2 border-dashed border-[#7a766f] hover:border-[#2b2b2d] flex flex-col items-center justify-center p-4 text-[#5a5752] hover:text-[#2b2b2d] transition bg-white/10 hover:bg-white/20"
                >
                  <Plus className="w-8 h-8 mb-1 text-[#bf8a00]" />
                  <span className="text-xs font-black uppercase tracking-wider">ADD MORE</span>
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
