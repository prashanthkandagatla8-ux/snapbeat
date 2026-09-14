"use client";

import { useState, useEffect } from "react";
import { RetroHeader } from "@/components/layout/RetroHeader";
import ShowcaseHome from "@/components/home/ShowcaseHome";
import { RetroTapeDeck } from "@/components/audio/RetroTapeDeck";
import { RetroPhotoStrip } from "@/components/photos/RetroPhotoStrip";
import { RetroRenderStudio } from "@/components/studio/RetroRenderStudio";
import { RetroQueueConsole } from "@/components/queue/RetroQueueConsole";
import { RetroStoreModal } from "@/components/billing/RetroStoreModal";
import RetroAuthModal from "@/components/auth/RetroAuthModal";
import RetroAdBanner from "@/components/ads/RetroAdBanner";
import { initializeRazorpayCheckout } from "@/components/billing/RazorpayCheckout";
import { useSubscription } from "@/hooks/useSubscription";
import { useStudioState } from "@/hooks/useStudioState";
import { useRenderJob } from "@/hooks/useRenderJob";
import { useAuth } from "@/context/AuthContext";
import { SOUND_TRACKS, DEFAULT_SERVER_URL } from "@/lib/constants";
import { ArrowRight, Sparkles } from "lucide-react";

export default function StudioPage() {
  const [viewMode, setViewMode] = useState("showcase"); // "showcase" | "studio"
  const [currentTab, setCurrentTab] = useState("music"); // "music" | "photos" | "render" | "queue"
  const [renderMode, setRenderMode] = useState("free"); // "free" | "pro"
  const [selectedBuiltInTrack, setSelectedBuiltInTrack] = useState(SOUND_TRACKS[0]);
  const [serverOnline, setServerOnline] = useState(false);
  const [isStoreOpen, setIsStoreOpen] = useState(false);
  const [pastJobs, setPastJobs] = useState([]);

  const { user, upgradeToPro } = useAuth();
  const { isPro: subIsPro, daysRemaining, activatePro } = useSubscription();

  // Combine subscription & user account Pro status
  const isPro = Boolean(subIsPro || user?.isPro);

  const studio = useStudioState(isPro);
  const renderJob = useRenderJob();

  // Auto-sync renderMode if user has Pro
  useEffect(() => {
    if (isPro && renderMode === "free") {
      setRenderMode("pro");
    }
  }, [isPro]);

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

  // Deep-link to studio mode if query param or hash present
  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      if (params.get("view") === "studio" || window.location.hash === "#studio") {
        setViewMode("studio");
      }
    }
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
      setCurrentTab("queue"); // Transition to Queue console
      if (typeof window !== "undefined") {
        window.scrollTo({ top: 0, behavior: "smooth" });
      }
      await renderJob.submitJob(studio);
      // For free users, automatically rotate to a different template for the next creation
      if (!isPro && typeof studio.rotateAutoTemplate === "function") {
        studio.rotateAutoTemplate();
      }
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

  // Handle plan purchase (Disabled during merchant review)
  const handleSelectPlan = (planId) => {
    setIsStoreOpen(false);
    alert("Payment gateway integration is currently in progress. Pro Pass purchases will unlock soon! In the meantime, enjoy 100% free unlimited video renders.");
  };

  const canRender = Boolean(studio.audioFile && studio.photos.length >= 2);

  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-start p-2 sm:p-4 md:p-6 lg:p-8 select-none relative overflow-x-hidden">
      {/* Outer ambient studio desk backdrop depth */}
      <div className="fixed inset-0 pointer-events-none bg-radial from-amber-500/5 via-transparent to-black/60 -z-10" />

      {/* TOP ANNOUNCEMENT BANNER: Free Beta & Queue Transparency (Overlayed on Dark Grey Background) */}
      <aside
        aria-label="Public Beta Announcement"
        className="w-full max-w-[1200px] mb-3 sm:mb-4 bg-gradient-to-r from-amber-500/20 via-amber-400/15 to-amber-500/20 border border-amber-400/30 rounded-2xl px-4 py-2.5 backdrop-blur-md flex items-center justify-center gap-3 text-white text-xs font-semibold select-none shadow-[0_10px_25px_rgba(0,0,0,0.5)] z-20"
      >
        <div className="flex items-center gap-2 flex-wrap mx-auto text-center justify-center">
          <span className="px-2.5 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] font-black text-[10px] uppercase tracking-wider shadow">
            🚀 PUBLIC BETA LIVE
          </span>
          <span className="text-amber-200 font-bold">
            100% Free Unlimited Video Renders Today!
          </span>
          <span className="hidden sm:inline text-white/40">•</span>
          <span className="text-amber-100/90 text-[11px]">
            Free renders process sequentially 1-at-a-time in our shared GPU cluster (~30–60s) • Pro dedicated cluster coming soon!
          </span>
        </div>
      </aside>

      {/* VIEW 1: FIRST PAGE (AUTHENTIC METAL EDGE FRAME) */}
      {viewMode === "showcase" ? (
        <div className="w-full max-w-[1000px] mx-auto relative">
          <ShowcaseHome
            onEnterStudio={() => {
              setViewMode("studio");
              setCurrentTab("music");
            }}
            onOpenPricing={() => setIsStoreOpen(true)}
          />
        </div>
      ) : (
        /* VIEW 2: WORKSTATION SCREENS (MUSIC, PHOTOS, RENDER, QUEUE) */
        <div className="w-full max-w-[1400px] mx-auto rounded-3xl bg-[#08181c]/95 border border-white/10 shadow-2xl backdrop-blur-xl overflow-hidden flex flex-col min-h-[90vh]">
          {/* RETRO SKY HEADER */}
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
            onShowcaseClick={() => setViewMode("showcase")}
          />

          {/* WORKSTATION BODY: RENDERS ACTIVE SCREEN */}
          <main className="flex-1 w-full p-3 sm:p-5 lg:p-8">
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
                      className="btn-brass px-6 py-3 rounded-2xl font-black text-xs flex items-center gap-2 shadow-md hover:brightness-110 active:scale-95 transition"
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
                    shufflePhotos={studio.shufflePhotos}
                    clearPhotos={studio.clearPhotos}
                    autoArrange={studio.autoArrange}
                    setAutoArrange={studio.setAutoArrange}
                  />
                  {/* Quick Flow Navigation */}
                  <div className="flex items-center justify-between pt-2">
                    <button
                      onClick={() => setCurrentTab("music")}
                      className="px-5 py-2.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-black text-xs shadow backdrop-blur-md active:scale-95 transition border border-white/10"
                    >
                      ← BACK TO MUSIC
                    </button>
                    <button
                      onClick={() => setCurrentTab("render")}
                      disabled={studio.photos.length < 2}
                      className={`px-6 py-3 rounded-2xl font-black text-xs flex items-center gap-2 shadow-md transition ${
                        studio.photos.length >= 2
                          ? "btn-brass hover:brightness-110 active:scale-95 cursor-pointer"
                          : "bg-white/10 text-white/40 border border-white/5 cursor-not-allowed"
                      }`}
                    >
                      <span>NEXT: RENDER</span>
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
                  {/* Flow navigation */}
                  <div className="flex items-center justify-between pt-2">
                    <button
                      onClick={() => setCurrentTab("photos")}
                      className="px-5 py-2.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-black text-xs shadow backdrop-blur-md active:scale-95 transition border border-white/10"
                    >
                      ← BACK TO PHOTOS
                    </button>
                    <button
                      onClick={() => setCurrentTab("queue")}
                      className="px-5 py-2.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-black text-xs shadow backdrop-blur-md flex items-center gap-1.5 active:scale-95 transition border border-white/10"
                    >
                      <span>VIEW QUEUE</span>
                      <ArrowRight className="w-3.5 h-3.5" />
                    </button>
                  </div>
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
                    isPro={isPro}
                    onOpenPricing={() => setIsStoreOpen(true)}
                    onRetry={handleStartRender}
                    onDismissError={renderJob.resetJob}
                  />
                  {/* Flow navigation */}
                  <div className="flex items-center justify-between pt-2">
                    <button
                      onClick={() => setCurrentTab("render")}
                      className="px-5 py-2.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-black text-xs shadow backdrop-blur-md active:scale-95 transition border border-white/10"
                    >
                      ← BACK TO RENDER
                    </button>
                  </div>
                </div>
              )}

              {/* RETRO SPONSOR BANNER (HIDDEN FOR PRO SUBSCRIBERS) */}
              <RetroAdBanner isPro={isPro} onOpenPricing={() => setIsStoreOpen(true)} />
            </main>

            {/* SLEEK FROSTED GLASS FOOTER */}
            <footer className="w-full bg-[#08181d]/85 backdrop-blur-xl border-t border-[#d4af37]/25 py-4 px-4 sm:px-8 text-center text-xs text-white/70 flex flex-col sm:flex-row items-center justify-between gap-3 mt-auto relative z-10">
              <p className="font-bold flex items-center justify-center gap-2">
                <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse" />
                <span>© 2026 SnapBeat Studio. Tactile Audio-Visual Reel Maker.</span>
              </p>
              <div className="flex flex-wrap items-center justify-center gap-x-5 gap-y-2 font-black text-amber-300/90">
                <a href="/privacy" className="hover:text-amber-200 hover:underline transition">Privacy Policy</a>
                <a href="/terms" className="hover:text-amber-200 hover:underline transition">Terms & Refunds</a>
              </div>
            </footer>
          </div>
        )}

      {/* PRO STORE MODAL */}
      <RetroStoreModal
        isOpen={isStoreOpen}
        onClose={() => setIsStoreOpen(false)}
        onSelectPlan={handleSelectPlan}
        isPro={isPro}
      />

      {/* AUTH MODAL */}
      <RetroAuthModal onSuccess={() => setViewMode("studio")} />
    </div>
  );
}
