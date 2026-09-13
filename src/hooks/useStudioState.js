"use client";

import { useState, useCallback } from "react";

export function useStudioState(isPro = false) {
  // Audio state
  const [audioFile, setAudioFile] = useState(null);
  const [audioUrl, setAudioUrl] = useState(null);
  const [audioDuration, setAudioDuration] = useState(0);
  const [audioTrim, setAudioTrim] = useState({ start: 0, end: 0, isFullTrack: true });

  // Photos state
  const [photos, setPhotos] = useState([]);
  const [autoArrange, setAutoArrange] = useState(false);

  // Styling & Controls
  const [selectedTemplate, setSelectedTemplate] = useState("pendulum");
  const [aspectRatio, setAspectRatio] = useState("9:16");
  const [quality, setQuality] = useState("fast"); // "fast" (720p) or "master" (1080p)
  const [watermark, setWatermark] = useState(true);

  // Title card
  const [titleCard, setTitleCard] = useState({
    enabled: false,
    text: "",
    font: "great_vibes",
    duration: 2,
    bg: "black",
    style: "classic",
    frame: "none",
    timing: "before_audio",
  });

  // Audio actions
  const setAudio = useCallback((file) => {
    if (!file) {
      setAudioFile(null);
      setAudioUrl(null);
      setAudioDuration(0);
      return;
    }
    const url = URL.createObjectURL(file);
    setAudioFile(file);
    setAudioUrl(url);

    // Read duration
    const tempAudio = new Audio(url);
    tempAudio.onloadedmetadata = () => {
      const dur = tempAudio.duration || 0;
      setAudioDuration(dur);
      setAudioTrim({ start: 0, end: Math.min(dur, 30), isFullTrack: true });
    };
  }, []);

  // Photos actions
  const addPhotos = useCallback((newFiles) => {
    const valid = Array.from(newFiles).filter((f) =>
      f.type.startsWith("image/") || /\.(jpg|jpeg|png|webp|bmp)$/i.test(f.name)
    );

    const items = valid.map((file, idx) => ({
      id: `${Date.now()}_${idx}_${file.name}`,
      file,
      previewUrl: URL.createObjectURL(file),
      name: file.name,
    }));

    setPhotos((prev) => [...prev, ...items].slice(0, 20));
  }, []);

  const removePhoto = useCallback((id) => {
    setPhotos((prev) => prev.filter((p) => p.id !== id));
  }, []);

  const reorderPhotos = useCallback((fromIndex, toIndex) => {
    setPhotos((prev) => {
      const updated = [...prev];
      const [moved] = updated.splice(fromIndex, 1);
      updated.splice(toIndex, 0, moved);
      return updated;
    });
  }, []);

  const clearPhotos = useCallback(() => {
    setPhotos([]);
  }, []);

  return {
    // Audio
    audioFile,
    audioUrl,
    audioDuration,
    audioTrim,
    setAudio,
    setAudioTrim,

    // Photos
    photos,
    addPhotos,
    removePhoto,
    reorderPhotos,
    clearPhotos,
    autoArrange,
    setAutoArrange,

    // Controls
    selectedTemplate,
    setSelectedTemplate,
    aspectRatio,
    setAspectRatio,
    quality: isPro ? quality : "fast",
    setQuality,
    watermark: isPro ? watermark : true,
    setWatermark,
    titleCard,
    setTitleCard,
  };
}
