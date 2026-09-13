"use client";

import { useState, useEffect } from "react";
import { RetroHeader } from "@/components/layout/RetroHeader";
import { RetroTapeDeck } from "@/components/audio/RetroTapeDeck";
import { RetroPhotoStrip } from "@/components/photos/RetroPhotoStrip";
import { RetroRenderStudio } from "@/components/studio/RetroRenderStudio";
import { RetroQueueConsole } from "@/components/queue/RetroQueueConsole";
import { RetroStoreModal } from "@/components/billing/RetroStoreModal";
import { initializeRazorpayCheckout } from "@/components/billing/RazorpayCheckout";
import { useSubscription } from "@/hooks/useSubscription";
import { useStudioState } from "@/hooks/useStudioState";
import { useRenderJob } from "@/hooks/useRenderJob";
import { SOUND_TRACKS, DEFAULT_SERVER_URL } from "@/lib/constants";
import { ArrowRight, Sparkles } from "lucide-react";

export default function StudioPage() {
  const [currentTab, setCurrentTab] = useState("music"); // "music" | "photos" | "render" | "queue"
  const [renderMode, setRenderMode] = useState("auto"); // "auto" | "pro"
  const [selectedBuiltInTrack, setSelectedBuiltInTrack] = useState(SOUND_TRACKS[0]);
  const [serverOnline, setServerOnline] = useState(false);
  const [isStoreOpen, setIsStoreOpen] = useState(false);
  const [pastJobs, setPastJobs] = useState([]);

  const { isPro, daysRemaining, activatePro } = useSubscription();
  const studio = useStudioState(isPro);
  const renderJob = useRenderJob();

  // On initial mount, load the first built-in sound track automatically
  useEffect(() => {
    const loadDefaultTrack = async () => {
      try {
        const res = await fetch(SOUND_TRACKS[0].assetPath);
        if (res.ok) {
          const blob = await res.blob();
          const file = new File([blob], SOUND_TRACKS[0].fileName, { type: "audio/mp3" });
          studio.setAudio(file);
        }
      } catch (e) {
        console.warn("Could not pre-load default track:", e);
      }
    };
    loadDefaultTrack();
  }, []);

  // Server health polling
  useEffect(() => {
    const checkServer = async () => {
      try {
        const res = await fetch(`${DEFAULT_SERVER_URL}/api/health`, { cache: "no-store" });
        if (res.ok) {
          const data = await res.json();
          setServerOnline(data.ok === true || data.status === "ok");
        } else {
          setServerOnline(false);
        }
      } catch {
        setServerOnline(false);
      }
    };
    checkServer();
    const interval = setInterval(checkServer, 10000);
    return () => clearInterval(interval);
  }, []);

  // When a built-in track is selected from library
  const handleSelectBuiltInTrack = async (track) => {
    setSelectedBuiltInTrack(track);
    try {
      const res = await fetch(track.assetPath);
      if (!res.ok) throw new Error("Audio file not found");
      const blob = await res.blob();
      const file = new File([blob], track.fileName, { type: "audio/mp3" });
      studio.setAudio(file);
    } catch (e) {
      alert("Error loading track: " + e.message);
    }
  };

  // Trigger render
  const handleStartRender = async () => {
    try {
      // Auto mode picks a great template automatically if user is on auto
      if (renderMode === "auto") {
        studio.setSelectedTemplate("pendulum");
      }
      setCurrentTab("queue"); // Seamlessly transition to Queue console!
      await renderJob.submitJob(studio);
    } catch (err) {
      alert(err.message || "Failed to submit render");
    }
  };

  // Record completed job to history
  useEffect(() => {
    if (renderJob.videoUrl && renderJob.jobId) {
      setPastJobs((prev) => {
        if (prev.some((j) => j.id === renderJob.jobId)) return prev;
        return [
          {
            id: renderJob.jobId,
            templateName: studio.selectedTemplate,
            quality: studio.quality,
            videoUrl: renderJob.videoUrl,
            createdAt: new Date().toISOString(),
          },
          ...prev,
        ];
      });
    }
  }, [renderJob.videoUrl, renderJob.jobId]);

  // Handle plan purchase
  const handleSelectPlan = (planId) => {
    setIsStoreOpen(false);
    initializeRazorpayCheckout(
      planId,
      (plan, paymentId) => {
        activatePro(plan, paymentId);
        alert(`🎉 Pro activated successfully for ${plan.toUpperCase()}! 1080p Master quality and watermark removal are unlocked.`);
      },
      () => {
        console.log("Payment canceled");
      }
    );
  };

  const canRender = Boolean(studio.audioFile && studio.photos.length >= 2);

  return (
    <div className="min-h-screen flex flex-col bg-[#c2b8a5] text-[#2b2b2d] selection:bg-[#ffc72c] selection:text-[#2b2820]">
      {/* RETRO HARDWARE HEADER */}
      <RetroHeader
        currentTab={currentTab}
        setCurrentTab={setCurrentTab}
        renderMode={renderMode}
        setRenderMode={setRenderMode}
        isPro={isPro}
        daysRemaining={daysRemaining}
        onOpenPricing={() => setIsStoreOpen(true)}
        serverOnline={serverOnline}
        activeQueueCount={renderJob.isRendering ? 1 : 0}
      />

      {/* WORKSTATION BODY */}
      <main className="flex-1 max-w-[1500px] w-full mx-auto p-4 lg:p-8">
        {/* TAB 1: MUSIC & TAPE DECK */}
        {currentTab === "music" && (
          <div className="space-y-4">
            <RetroTapeDeck
              selectedTrack={selectedBuiltInTrack}
              onSelectBuiltInTrack={handleSelectBuiltInTrack}
              audioFile={studio.audioFile}
              audioUrl={studio.audioUrl}
              audioDuration={studio.audioDuration}
              audioTrim={studio.audioTrim}
              setAudio={(file) => {
                setSelectedBuiltInTrack(null);
                studio.setAudio(file);
              }}
              setAudioTrim={studio.setAudioTrim}
            />
            {/* Quick Flow Next Step */}
            <div className="flex justify-end pt-2">
              <button
                onClick={() => setCurrentTab("photos")}
                className="btn-brass px-6 py-3 rounded-2xl font-black text-xs flex items-center gap-2 shadow-md"
              >
                <span>NEXT: CHOOSE PHOTOS</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        {/* TAB 2: PHOTOS BAY */}
        {currentTab === "photos" && (
          <div className="space-y-4">
            <RetroPhotoStrip
              photos={studio.photos}
              addPhotos={studio.addPhotos}
              removePhoto={studio.removePhoto}
              reorderPhotos={studio.reorderPhotos}
              clearPhotos={studio.clearPhotos}
              autoArrange={studio.autoArrange}
              setAutoArrange={studio.setAutoArrange}
            />
            {/* Quick Flow Next Step */}
            <div className="flex items-center justify-between pt-2">
              <button
                onClick={() => setCurrentTab("music")}
                className="px-5 py-2.5 rounded-2xl metal-panel font-black text-xs text-[#2b2b2d] shadow"
              >
                ← BACK TO MUSIC
              </button>
              <button
                onClick={() => setCurrentTab("render")}
                disabled={studio.photos.length < 2}
                className={`px-6 py-3 rounded-2xl font-black text-xs flex items-center gap-2 shadow-md ${
                  studio.photos.length >= 2
                    ? "btn-brass"
                    : "bg-[#8f8677] text-white opacity-60 cursor-not-allowed"
                }`}
              >
                <span>NEXT: STUDIO & RENDER</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        {/* TAB 3: RENDER STUDIO */}
        {currentTab === "render" && (
          <div className="space-y-4">
            <RetroRenderStudio
              renderMode={renderMode}
              setRenderMode={setRenderMode}
              selectedTemplate={studio.selectedTemplate}
              setSelectedTemplate={studio.setSelectedTemplate}
              aspectRatio={studio.aspectRatio}
              setAspectRatio={studio.setAspectRatio}
              quality={studio.quality}
              setQuality={studio.setQuality}
              watermark={studio.watermark}
              setWatermark={studio.setWatermark}
              titleCard={studio.titleCard}
              setTitleCard={studio.setTitleCard}
              isPro={isPro}
              onOpenPricing={() => setIsStoreOpen(true)}
              onRender={handleStartRender}
              isRendering={renderJob.isRendering}
              canRender={canRender}
              videoUrl={renderJob.videoUrl}
            />
          </div>
        )}

        {/* TAB 4: QUEUE CONSOLE */}
        {currentTab === "queue" && (
          <div className="space-y-4">
            <RetroQueueConsole
              jobId={renderJob.jobId}
              isRendering={renderJob.isRendering}
              progress={renderJob.progress}
              stage={renderJob.stage}
              queuePosition={renderJob.queuePosition}
              error={renderJob.error}
              videoUrl={renderJob.videoUrl}
              pastJobs={pastJobs}
              onClearCompleted={() => setPastJobs([])}
            />
          </div>
        )}
      </main>

      {/* HARDWARE FOOTER */}
      <footer className="w-full metal-panel border-t-2 border-[#7a766f] py-4 px-6 text-center text-xs text-[#5a5752] flex flex-col sm:flex-row items-center justify-between gap-3 mt-auto">
        <p className="font-bold">© 2026 SnapBeat Studio. Tactile Audio-Visual Reel Maker.</p>
        <div className="flex items-center gap-4 font-black">
          <a href="/privacy" className="hover:text-[#2b2b2d] transition">Privacy Policy</a>
          <a href="/terms" className="hover:text-[#2b2b2d] transition">Terms & Refunds</a>
          <a href="/join" className="hover:text-[#2b2b2d] transition">Beta Testers Group</a>
          <a href="/beta" className="hover:text-[#2b2b2d] transition">Google Play App</a>
        </div>
      </footer>

      {/* PRO STORE MODAL */}
      <RetroStoreModal
        isOpen={isStoreOpen}
        onClose={() => setIsStoreOpen(false)}
        onSelectPlan={handleSelectPlan}
        isPro={isPro}
      />
    </div>
  );
}
