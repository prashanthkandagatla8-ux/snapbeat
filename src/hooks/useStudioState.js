"use client";

import { useState, useCallback, useRef, useEffect } from "react";
import { TEMPLATES } from "@/lib/constants";

export function useStudioState(isPro = false) {
  // Audio state
  const [audioFile, setAudioFile] = useState(null);
  const [audioUrl, setAudioUrl] = useState(null);
  const [audioDuration, setAudioDuration] = useState(0);
  const [audioTrim, setAudioTrim] = useState({ start: 0, end: 0, isFullTrack: true });
  const currentObjectUrlRef = useRef(null);

  // Photos state
  const [photos, setPhotos] = useState([]);
  const [autoArrange, setAutoArrange] = useState(false);

  // Styling & Controls
  // Initial template: pick from pool
  const [selectedTemplate, setSelectedTemplate] = useState("pendulum");
  const [aspectRatio, setAspectRatio] = useState("9:16");
  const [quality, setQuality] = useState(isPro ? "master" : "fast"); // "fast" (720p) or "master" (1080p)
  const [watermarkState, setWatermarkState] = useState(true);

  // Auto-rotate template for free users (guarantees a different template each time)
  const rotateAutoTemplate = useCallback(() => {
    setSelectedTemplate((current) => {
      const allIds = TEMPLATES.map((t) => t.id);
      const candidates = allIds.filter((id) => id !== current);
      const nextId = candidates[Math.floor(Math.random() * candidates.length)] || allIds[0];
      try {
        localStorage.setItem("snapbeat_last_free_template", nextId);
      } catch (e) {}
      return nextId;
    });
  }, []);

  // On mount or when isPro turns false, auto-select a unique template for free tier
  useEffect(() => {
    if (!isPro) {
      rotateAutoTemplate();
    }
  }, [isPro, rotateAutoTemplate]);

  // Guard manual template selection: Disabled for free users, enabled for Pro only
  const setTemplateGuarded = useCallback(
    (newTemplate) => {
      if (!isPro) {
        // Free users cannot manually select or change template
        return;
      }
      setSelectedTemplate(newTemplate);
    },
    [isPro]
  );

  // Title card
  const [titleCard, setTitleCard] = useState({
    enabled: false,
    text: "",
    subtitle: "",
    font: "great_vibes",
    duration: 2,
    bg: "black",
    style: "classic",
    frame: "none",
    timing: "before_audio",
  });

  // Audio actions
  const setAudio = useCallback((file) => {
    // Revoke previous blob URL if created
    if (currentObjectUrlRef.current) {
      URL.revokeObjectURL(currentObjectUrlRef.current);
      currentObjectUrlRef.current = null;
    }

    if (!file) {
      setAudioFile(null);
      setAudioUrl(null);
      setAudioDuration(0);
      setAudioTrim({ start: 0, end: 0, isFullTrack: true });
      return;
    }

    let resolvedUrl = null;
    let fileObj = null;

    if (typeof file === "string") {
      resolvedUrl = file;
      const fileName = file.split("/").pop() || "audio.mp3";
      fileObj = { name: fileName, url: file };
    } else if (file instanceof Blob || file instanceof File) {
      resolvedUrl = URL.createObjectURL(file);
      currentObjectUrlRef.current = resolvedUrl;
      fileObj = file;
    } else if (file && typeof file === "object" && file.url) {
      resolvedUrl = file.url;
      fileObj = file;
    }

    if (!resolvedUrl) return;

    setAudioFile(fileObj);
    setAudioUrl(resolvedUrl);

    // Read duration safely
    const tempAudio = new Audio();
    tempAudio.preload = "metadata";

    const onLoaded = () => {
      const dur = isFinite(tempAudio.duration) && tempAudio.duration > 0 ? tempAudio.duration : 0;
      setAudioDuration(dur);
      setAudioTrim((prev) => ({
        start: 0,
        end: dur > 0 ? Math.min(dur, 30) : 30,
        isFullTrack: prev?.isFullTrack ?? true,
      }));
      tempAudio.removeEventListener("loadedmetadata", onLoaded);
      tempAudio.removeEventListener("error", onError);
    };

    const onError = (e) => {
      console.warn("Could not load audio metadata:", e);
      tempAudio.removeEventListener("loadedmetadata", onLoaded);
      tempAudio.removeEventListener("error", onError);
    };

    tempAudio.addEventListener("loadedmetadata", onLoaded);
    tempAudio.addEventListener("error", onError);
    tempAudio.src = resolvedUrl;
  }, []);

  // Photos actions
  const addPhotos = useCallback((newFiles) => {
    if (!newFiles) return;
    const fileArray = Array.isArray(newFiles) ? newFiles : Array.from(newFiles);

    const valid = fileArray.filter((f) => {
      if (!f) return false;
      if (typeof f === "string") return true;
      if (f.previewUrl) return true;
      return (
        (f.type && f.type.startsWith("image/")) ||
        /\.(jpg|jpeg|png|webp|bmp|gif)$/i.test(f.name || "")
      );
    });

    const items = valid.map((file, idx) => {
      if (typeof file === "string") {
        return {
          id: `${Date.now()}_${idx}_${Math.random().toString(36).slice(2, 7)}`,
          file: null,
          previewUrl: file,
          name: file.split("/").pop() || `photo_${idx + 1}.jpg`,
        };
      }
      if (file.previewUrl && file.id) {
        return file;
      }
      return {
        id: `${Date.now()}_${idx}_${(file.name || "photo").replace(/[^a-zA-Z0-9_.-]/g, "_")}`,
        file,
        previewUrl: URL.createObjectURL(file),
        name: file.name || `photo_${idx + 1}.jpg`,
      };
    });

    setPhotos((prev) => {
      const combined = [...prev, ...items];
      if (combined.length > 20) {
        // Revoke excess blob URLs
        const excess = combined.slice(20);
        excess.forEach((p) => {
          if (p?.previewUrl?.startsWith("blob:")) {
            URL.revokeObjectURL(p.previewUrl);
          }
        });
        return combined.slice(0, 20);
      }
      return combined;
    });
  }, []);

  const removePhoto = useCallback((id) => {
    setPhotos((prev) => {
      const target = prev.find((p) => p.id === id);
      if (target?.previewUrl?.startsWith("blob:")) {
        URL.revokeObjectURL(target.previewUrl);
      }
      return prev.filter((p) => p.id !== id);
    });
  }, []);

  const reorderPhotos = useCallback((fromIndex, toIndex) => {
    setPhotos((prev) => {
      if (
        fromIndex < 0 ||
        fromIndex >= prev.length ||
        toIndex < 0 ||
        toIndex >= prev.length ||
        fromIndex === toIndex
      ) {
        return prev;
      }
      const updated = [...prev];
      const [moved] = updated.splice(fromIndex, 1);
      if (moved) {
        updated.splice(toIndex, 0, moved);
      }
      return updated;
    });
  }, []);

  const shufflePhotos = useCallback(() => {
    setPhotos((prev) => {
      if (prev.length < 2) return prev;
      const shuffled = [...prev];
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
      }
      return shuffled;
    });
  }, []);

  const clearPhotos = useCallback(() => {
    setPhotos((prev) => {
      prev.forEach((p) => {
        if (p?.previewUrl?.startsWith("blob:")) {
          URL.revokeObjectURL(p.previewUrl);
        }
      });
      return [];
    });
  }, []);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (currentObjectUrlRef.current) {
        URL.revokeObjectURL(currentObjectUrlRef.current);
      }
    };
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
    shufflePhotos,
    clearPhotos,
    autoArrange,
    setAutoArrange,

    // Controls
    selectedTemplate,
    setSelectedTemplate: setTemplateGuarded,
    rotateAutoTemplate,
    aspectRatio,
    setAspectRatio,
    quality: isPro ? quality : "fast",
    setQuality,
    // Requirement 7: Watermark is informative status pill only (Free shows "REMOVE (PRO)", Pro shows "REMOVED")
    // Pro tier has watermark removed (false), Free tier has watermark enabled (true)
    watermark: isPro ? false : true,
    setWatermark: setWatermarkState,
    // Requirement 5: Title Card is Pro-only feature
    titleCard: {
      ...titleCard,
      enabled: isPro ? Boolean(titleCard.enabled) : false,
    },
    setTitleCard,
  };
}

