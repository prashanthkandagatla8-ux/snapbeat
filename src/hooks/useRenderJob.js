"use client";

import { useState, useRef, useCallback, useEffect } from "react";
import { DEFAULT_SERVER_URL } from "@/lib/constants";
import { trackRenderCompleted, trackRenderFailed } from "@/lib/analytics";

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

  const resetJob = useCallback(() => {
    cancelPolling();
    setIsRendering(false);
    setProgress(0);
    setStage("");
    setQueuePosition(0);
    setError(null);
    setVideoUrl(null);
    setJobId(null);
  }, [cancelPolling]);

  // Clean up timer on unmount
  useEffect(() => {
    return () => {
      if (pollTimerRef.current) {
        clearInterval(pollTimerRef.current);
        pollTimerRef.current = null;
      }
    };
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
        isPro,
        renderMode,
      } = studioState;

      if (!audioFile) {
        throw new Error("Please upload an audio track before rendering.");
      }
      if (!photos || photos.length < 2) {
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

      const userIsPro = Boolean(isPro);
      const applyWatermark = userIsPro ? false : Boolean(watermark);

      const formData = new FormData();
      formData.append("audio", audioFile);
      photos.forEach((p) => {
        if (p.file) formData.append("photos", p.file);
      });

      formData.append("template", renderMode === "auto" ? "auto" : (selectedTemplate || "pendulum"));
      formData.append("frame", frameMap[aspectRatio] || "portrait");
      formData.append("quality", userIsPro && quality === "master" ? "master" : "fast");
      formData.append("watermark", applyWatermark ? "true" : "false");
      formData.append("render_type", userIsPro ? "pro_priority" : "free_queue");
      formData.append("client", "web");
      formData.append("audio_start", String(audioTrim?.start || 0));
      formData.append("audio_end", String(audioTrim?.end || 0));
      formData.append("full_track", audioTrim?.isFullTrack ? "true" : "false");
      formData.append("auto_arrange", autoArrange ? "auto" : "none");

      if (titleCard?.enabled && titleCard?.text?.trim()) {
        formData.append("title_text", titleCard.text.trim());
        formData.append("title_font", titleCard.font || "great_vibes");
        formData.append("title_font_size", titleCard.fontSize || "large");
        formData.append("title_duration", String(titleCard.duration || 2));
        formData.append("title_bg", titleCard.bg || "black");
        formData.append("title_style", titleCard.style || "classic");
        formData.append("title_frame", titleCard.frame || "none");
        formData.append("title_audio", titleCard.timing || "before_audio");
        if (titleCard.subtitle?.trim()) {
          formData.append("title_subtitle", titleCard.subtitle.trim());
        }
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
        if (!newJobId) {
          throw new Error("Server did not return a valid job ID");
        }

        setJobId(newJobId);
        setStage("Queued in render pipeline...");

        // Start polling
        cancelPolling();
        let consecutiveFailures = 0;

        pollTimerRef.current = setInterval(async () => {
          try {
            const statusRes = await fetch(`${serverUrl}/api/render/status/${newJobId}`);
            if (!statusRes.ok) {
              consecutiveFailures += 1;
              if (consecutiveFailures > 15) {
                cancelPolling();
                setIsRendering(false);
                setError("Lost communication with render server. Please try again.");
              }
              return;
            }

            consecutiveFailures = 0;
            const statusData = await statusRes.json();
            setProgress(statusData.progress || 0);
            setStage(statusData.stage || statusData.status);
            setQueuePosition(statusData.queue_position || 0);

            if (statusData.status === "done") {
              cancelPolling();
              setIsRendering(false);
              setStage("Render complete! Auto-saved to Downloads");
              setProgress(100);

              const downloadUrl = `${serverUrl}/api/render/download/${newJobId}?delete_after=true`;

              // Auto-download to device and set local blob URL for player
              try {
                const dlResp = await fetch(downloadUrl);
                if (dlResp.ok) {
                  const blob = await dlResp.blob();
                  const localBlobUrl = URL.createObjectURL(blob);
                  setVideoUrl(localBlobUrl);

                  // Trigger browser auto-download
                  const safeTemplate = (studioState?.selectedTemplate || "Reel").replace(/[^a-zA-Z0-9_-]/g, "_");
                  const dlLink = document.createElement("a");
                  dlLink.href = localBlobUrl;
                  dlLink.download = `SnapBeat_${safeTemplate}_${Date.now()}.mp4`;
                  document.body.appendChild(dlLink);
                  dlLink.click();
                  document.body.removeChild(dlLink);

                  // Fire server cleanup
                  fetch(`${serverUrl}/api/render/cleanup/${newJobId}`, { method: "POST" }).catch(() => {});
                } else {
                  setVideoUrl(downloadUrl);
                }
              } catch (dlErr) {
                console.warn("Auto-download fetch error, using direct URL:", dlErr);
                setVideoUrl(downloadUrl);
              }

              trackRenderCompleted({
                jobId: newJobId,
                template: studioState?.selectedTemplate || "pendulum",
                outputResolution: userIsPro && quality === "master" ? "1080p" : "480p",
                isPro: userIsPro,
              });
            } else if (statusData.status === "failed") {
              cancelPolling();
              setIsRendering(false);
              setError(statusData.error || "Render job failed on server");
              trackRenderFailed({
                template: studioState?.selectedTemplate || "pendulum",
                errorCategory: "processing_error",
                stage: statusData.stage || "failed",
              });
            }
          } catch (pollErr) {
            consecutiveFailures += 1;
            console.warn("Polling error:", pollErr);
            if (consecutiveFailures > 15) {
              cancelPolling();
              setIsRendering(false);
              setError("Network error communicating with render server.");
              trackRenderFailed({
                template: studioState?.selectedTemplate || "pendulum",
                errorCategory: "network_error",
                stage: "polling",
              });
            }
          }
        }, 1200);
      } catch (err) {
        setIsRendering(false);
        setError(err.message || "Failed to submit render job");
        trackRenderFailed({
          template: studioState?.selectedTemplate || "pendulum",
          errorCategory: "upload_error",
          stage: "submission",
        });
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
    resetJob,
  };
}
