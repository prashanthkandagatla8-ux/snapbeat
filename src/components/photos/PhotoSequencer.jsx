"use client";

import { useRef } from "react";
import { Images, Trash2, Wand2, Plus, GripVertical } from "lucide-react";

export function PhotoSequencer({ photos, addPhotos, removePhoto, reorderPhotos, clearPhotos, autoArrange, setAutoArrange }) {
  const fileInputRef = useRef(null);

  const handleFiles = (e) => {
    if (e.target.files) {
      addPhotos(e.target.files);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    if (e.dataTransfer.files) {
      addPhotos(e.dataTransfer.files);
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
        {photos.length > 0 && (
          <button
            onClick={clearPhotos}
            className="text-[11px] text-rose-400 hover:text-rose-300 flex items-center gap-1 transition"
          >
            <Trash2 className="w-3 h-3" />
            Clear
          </button>
        )}
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
            {/* Remove Button */}
            <button
              onClick={(e) => {
                e.stopPropagation();
                removePhoto(p.id);
              }}
              className="absolute top-1.5 right-1.5 w-5 h-5 rounded-full bg-rose-500/90 hover:bg-rose-600 text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition shadow"
            >
              ×
            </button>
            <div className="absolute bottom-1 right-1 opacity-0 group-hover:opacity-75 text-white">
              <GripVertical className="w-3 h-3" />
            </div>
          </div>
        ))}

        {photos.length < 20 && (
          <button
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
