"use client";

import { useState, useRef, useCallback } from "react";
import { DEFAULT_SERVER_URL } from "@/lib/constants";

export function useRenderJob() {
  const [jobId, setJobId] = useState(null);
  const [isRendering, setIsRendering] = useState(false);
  const [stage, setStage] = useState("");
  const [progress, setProgress] = useState(0);
  const [queuePosition, setQueuePosition] = useState(0);
  const [videoUrl, setVideoUrl] = useState(null);
  const [error, setError] = useState(null);
  const pollTimerRef = useRef(null);

  const cancelPolling = useCallback(() => {
    if (pollTimerRef.current) {
      clearInterval(pollTimerRef.current);
      pollTimerRef.current = null;
    }
  }, []);

  const submitJob = useCallback(
    async (studioState, serverUrl = DEFAULT_SERVER_URL) => {
      const {
        audioFile,
        photos,
        selectedTemplate,
        aspectRatio,
        quality,
        watermark,
        audioTrim,
        titleCard,
        autoArrange,
      } = studioState;

      if (!audioFile) {
        throw new Error("Please upload an audio track before rendering.");
      }
      if (photos.length < 2) {
        throw new Error("Please upload at least 2 photos.");
      }

      setIsRendering(true);
      setProgress(2);
      setStage("Preparing reel upload...");
      setError(null);
      setVideoUrl(null);
      setQueuePosition(0);

      const frameMap = {
        "9:16": "portrait",
        "1:1": "square",
        "16:9": "landscape",
      };

      const formData = new FormData();
      formData.append("audio", audioFile);
      photos.forEach((p) => {
        formData.append("photos", p.file);
      });

      formData.append("template", selectedTemplate);
      formData.append("frame", frameMap[aspectRatio] || "portrait");
      formData.append("quality", quality || "fast");
      formData.append("watermark", watermark ? "true" : "false");
      formData.append("render_type", "free_queue");
      formData.append("audio_start", String(audioTrim.start || 0));
      formData.append("audio_end", String(audioTrim.end || 0));
      formData.append("full_track", audioTrim.isFullTrack ? "true" : "false");
      formData.append("auto_arrange", autoArrange ? "auto" : "none");

      if (titleCard.enabled && titleCard.text.trim()) {
        formData.append("title_text", titleCard.text.trim());
        formData.append("title_font", titleCard.font || "great_vibes");
        formData.append("title_duration", String(titleCard.duration || 2));
        formData.append("title_bg", titleCard.bg || "black");
        formData.append("title_style", titleCard.style || "classic");
        formData.append("title_frame", titleCard.frame || "none");
        formData.append("title_audio", titleCard.timing || "before_audio");
      }

      try {
        const response = await fetch(`${serverUrl}/api/render/mobile`, {
          method: "POST",
          body: formData,
        });

        if (!response.ok) {
          const errText = await response.text();
          throw new Error(`Server returned ${response.status}: ${errText}`);
        }

        const data = await response.json();
        const newJobId = data.job_id;
        setJobId(newJobId);
        setStage("Queued in render pipeline...");

        // Start polling
        cancelPolling();
        pollTimerRef.current = setInterval(async () => {
          try {
            const statusRes = await fetch(`${serverUrl}/api/render/status/${newJobId}`);
            if (!statusRes.ok) return;

            const statusData = await statusRes.json();
            setProgress(statusData.progress || 0);
            setStage(statusData.stage || statusData.status);
            setQueuePosition(statusData.queue_position || 0);

            if (statusData.status === "done") {
              cancelPolling();
              setIsRendering(false);
              setStage("Render complete!");
              setProgress(100);
              setVideoUrl(`${serverUrl}/api/render/download/${newJobId}`);
            } else if (statusData.status === "failed") {
              cancelPolling();
              setIsRendering(false);
              setError(statusData.error || "Render job failed on server");
            }
          } catch (pollErr) {
            console.warn("Polling error:", pollErr);
          }
        }, 1200);
      } catch (err) {
        setIsRendering(false);
        setError(err.message || "Failed to submit render job");
        throw err;
      }
    },
    [cancelPolling]
  );

  return {
    jobId,
    isRendering,
    stage,
    progress,
    queuePosition,
    videoUrl,
    error,
    submitJob,
    cancelPolling,
  };
}
