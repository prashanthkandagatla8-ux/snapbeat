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
import SeoFooter from "@/components/layout/SeoFooter";
import { trackStartCreating, trackRenderStarted, trackUpgradeViewed } from "@/lib/analytics";
import { initializeRazorpayCheckout } from "@/components/billing/RazorpayCheckout";
import { initializeHybridCheckout } from "@/components/billing/HybridCheckout";
import { useSubscription } from "@/hooks/useSubscription";
import { useStudioState } from "@/hooks/useStudioState";
import { useRenderJob } from "@/hooks/useRenderJob";
import { useAuth } from "@/context/AuthContext";
import { SOUND_TRACKS, DEFAULT_SERVER_URL } from "@/lib/constants";
import { ArrowRight, Sparkles } from "lucide-react";

export default function StudioPage() {
  const [viewMode, setViewMode] = useState("showcase"); // "showcase" | "studio"
  const [currentTab, setCurrentTab] = useState("music"); // "music" | "photos" | "render" | "queue"
  const [selectedBuiltInTrack, setSelectedBuiltInTrack] = useState(SOUND_TRACKS[0]);
  const [serverOnline, setServerOnline] = useState(false);
  const [isStoreOpen, setIsStoreOpen] = useState(false);
  const [pastJobs, setPastJobs] = useState([]);

  const { user, openAuthModal, upgradeToPro, authModalConfig } = useAuth();
  const { isPro: subIsPro, daysRemaining, activatePro } = useSubscription();

  // Combine subscription & user account Pro status
  const isPro = Boolean(subIsPro || user?.isPro);
  // Non-switchable: Pro mode is active when Pro pass is active; otherwise Free tier
  const renderMode = isPro ? "pro" : "free";

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

  // Deep-link to studio mode if query param or hash present
  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      if (params.get("view") === "studio" || window.location.hash === "#studio") {
        setViewMode("studio");
      }
    }
  }, []);

  // Auto-verify and activate Pro if redirected back from Cashfree
  useEffect(() => {
    if (typeof window === "undefined") return;
    const params = new URLSearchParams(window.location.search);
    const orderId = params.get("order_id");
    const cfStatus = params.get("cf_status");
    const planId = params.get("plan_id") || "monthly";

    if (orderId) {
      const verifyRedirectPayment = async () => {
        try {
          const res = await fetch("/api/checkout/cashfree/verify", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ orderId, planId }),
          });
          const data = await res.json();
          if (data?.verified) {
            activatePro(data.planId || planId, data.paymentId || `cf_${orderId}`, data.proToken);
            upgradeToPro(data.planId || planId, { paymentId: data.paymentId || `cf_${orderId}`, proToken: data.proToken });
            window.history.replaceState({}, document.title, window.location.pathname);
            alert("🎉 WELCOME TO SNAPBEAT PRO!\n\nYour payment was verified successfully! Pro Studio Pass is now active.");
          }
        } catch (err) {
          console.warn("Could not verify redirect payment:", err);
        }
      };
      verifyRedirectPayment();
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
      trackRenderStarted({
        template: studio.selectedTemplate || "pendulum",
        photoCount: studio.photos?.length || 0,
        outputResolution: isPro && studio.quality === "master" ? "1080p" : "480p",
        aspectRatio: studio.aspectRatio || "9:16",
        isPro: Boolean(isPro),
      });
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

  // Account-level and guest-level persistent storage key
  const getJobsStorageKey = (currentUser) => {
    if (!currentUser) return "snapbeat_jobs_guest";
    if (currentUser.email && !currentUser.isGuest) {
      return `snapbeat_jobs_${currentUser.email.toLowerCase().trim()}`;
    }
    return `snapbeat_jobs_${currentUser.id || "guest"}`;
  };

  // Load account/guest-level queue history whenever user changes
  useEffect(() => {
    if (typeof window === "undefined") return;
    const key = getJobsStorageKey(user);
    try {
      const stored = localStorage.getItem(key);
      let jobs = stored ? JSON.parse(stored) : [];

      // If user is a registered user, check if there are any orphaned guest jobs to merge
      if (user && !user.isGuest && user.email) {
        const guestJobsRaw = localStorage.getItem("snapbeat_jobs_guest");
        if (guestJobsRaw) {
          try {
            const guestJobs = JSON.parse(guestJobsRaw);
            if (Array.isArray(guestJobs) && guestJobs.length > 0) {
              const existingIds = new Set(jobs.map((j) => j.id));
              const newFromGuest = guestJobs.filter((j) => !existingIds.has(j.id));
              if (newFromGuest.length > 0) {
                jobs = [...newFromGuest, ...jobs];
                localStorage.setItem(key, JSON.stringify(jobs));
              }
              localStorage.removeItem("snapbeat_jobs_guest");
            }
          } catch (_) {}
        }
      }

      setPastJobs(Array.isArray(jobs) ? jobs : []);
    } catch (e) {
      console.warn("Could not load account jobs history:", e);
    }
  }, [user?.email, user?.id, user?.isGuest]);

  // Record completed job to history & persist to user account or guest session
  useEffect(() => {
    if (renderJob.videoUrl && renderJob.jobId) {
      setPastJobs((prev) => {
        if (prev.some((j) => j.id === renderJob.jobId)) return prev;
        const newJob = {
          id: renderJob.jobId,
          templateName: studio.selectedTemplate,
          quality: studio.quality,
          videoUrl: renderJob.videoUrl,
          createdAt: new Date().toISOString(),
          aspectRatio: studio.aspectRatio,
        };
        const updated = [newJob, ...prev];
        if (typeof window !== "undefined") {
          try {
            const key = getJobsStorageKey(user);
            localStorage.setItem(key, JSON.stringify(updated));
          } catch (e) {
            console.warn("Failed to persist job to storage:", e);
          }
        }
        return updated;
      });
    }
  }, [renderJob.videoUrl, renderJob.jobId, user, studio.selectedTemplate, studio.quality, studio.aspectRatio]);

  const handleClearPastJobs = () => {
    setPastJobs([]);
    if (typeof window !== "undefined") {
      try {
        const key = getJobsStorageKey(user);
        localStorage.removeItem(key);
      } catch (_) {}
    }
  };

  // Handle plan purchase via Hybrid Gateway (Cashfree Active Live + Razorpay Backup)
  const handleSelectPlan = (planId) => {
    setIsStoreOpen(false);
    initializeHybridCheckout({
      planId,
      user,
      onPaymentSuccess: (purchasedPlanId, paymentId, proToken) => {
        activatePro(purchasedPlanId, paymentId, proToken);
        upgradeToPro(purchasedPlanId, { paymentId, proToken });
        alert(
          "🎉 WELCOME TO SNAPBEAT PRO!\n\n" +
          "Your Pro Studio Pass is now active!\n" +
          "• 1080p Master exports unlocked\n" +
          "• Watermark removed\n" +
          "• All 14 kinetic motion styles unlocked\n" +
          "• Title Card editor unlocked"
        );
      },
      onPaymentCancel: () => {
        // User closed or cancelled checkout
      },
    });
  };

  // Gate studio entry with login requirement (Guest 1-click or account)
  const handleEnterStudio = () => {
    trackStartCreating("/?view=studio", "enter_studio");
    if (user) {
      setViewMode("studio");
      setCurrentTab("music");
    } else {
      openAuthModal();
    }
  };

  // Enforce account sign-in for Pro upgrades (Industry standard: Canva, CapCut, Figma)
  const handleOpenPricing = () => {
    if (!user || user.isGuest) {
      openAuthModal({
        intent: "pro_upgrade",
        title: "ACCOUNT REQUIRED FOR PRO",
        subtitle: "Please sign in with your email or Google account so your Pro pass is safely attached and never lost.",
      });
      return;
    }
    setIsStoreOpen(true);
  };

  const canRender = Boolean(studio.audioFile && studio.photos.length >= 2);

  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-start px-3.5 py-6 sm:px-7 sm:py-9 md:px-10 md:py-12 select-none relative overflow-x-hidden">
      {/* Outer ambient studio desk backdrop depth */}
      <div className="fixed inset-0 pointer-events-none bg-radial from-white/[0.02] via-transparent to-black/75 -z-10" />

      {/* UNIFIED FIXED-SIZE METALLIC CHASSIS CONTAINER FOR ALL PAGES */}
      <div className="w-full max-w-[1040px] mx-auto tablet-frame relative flex flex-col">
        <div className="tablet-inner-screen w-full flex flex-col">
          {viewMode === "showcase" ? (
            <ShowcaseHome
              onEnterStudio={handleEnterStudio}
              onOpenPricing={handleOpenPricing}
            />
          ) : (
          /* VIEW 2: WORKSTATION SCREENS (MUSIC, PHOTOS, RENDER, QUEUE) */
          <div className="w-full sky-canvas flex flex-col min-h-[880px] text-white relative">
          {/* RETRO SKY HEADER */}
          <RetroHeader
            currentTab={currentTab}
            setCurrentTab={setCurrentTab}
            isPro={isPro}
            daysRemaining={daysRemaining}
            onOpenPricing={handleOpenPricing}
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
                    onOpenPricing={handleOpenPricing}
                    onRender={handleStartRender}
                    isRendering={renderJob.isRendering}
                    canRender={canRender}
                    videoUrl={renderJob.videoUrl}
                    onNavigateQueue={() => setCurrentTab("queue")}
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
                    onClearCompleted={handleClearPastJobs}
                    isPro={isPro}
                    onOpenPricing={handleOpenPricing}
                    onRetry={handleStartRender}
                    onDismissError={renderJob.resetJob}
                    onNewReel={() => setCurrentTab("photos")}
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
              <RetroAdBanner isPro={isPro} onOpenPricing={handleOpenPricing} />
            </main>

            {/* SLEEK FROSTED GLASS FOOTER */}
            <footer className="w-full bg-[#08181d]/85 backdrop-blur-xl border-t border-[#d4af37]/25 py-4 px-4 sm:px-8 text-center text-xs text-white/70 flex flex-col sm:flex-row items-center justify-between gap-3 mt-auto relative z-10">
              <p className="font-bold flex items-center justify-center gap-2">
                <span className="w-2 h-2 rounded-full bg-amber-400 animate-pulse" />
                <span>© 2026 SnapBeat. Tactile Audio-Visual Reel Maker.</span>
              </p>
              <div className="flex flex-wrap items-center justify-center gap-x-5 gap-y-2 font-black text-amber-300/90">
                <a href="/privacy" className="hover:text-amber-200 hover:underline transition">Privacy Policy</a>
                <a href="/terms" className="hover:text-amber-200 hover:underline transition">Terms & Refunds</a>
              </div>
            </footer>
          </div>
        )}
        </div>
      </div>

      {/* Crawlable Semantic SEO Footer */}
      <SeoFooter className="w-full max-w-[1040px] mx-auto z-10" />

      {/* PRO STORE MODAL */}
      <RetroStoreModal
        isOpen={isStoreOpen}
        onClose={() => setIsStoreOpen(false)}
        onSelectPlan={handleSelectPlan}
        isPro={isPro}
      />

      {/* AUTH MODAL (1-Click Guest or Account Sign In) */}
      <RetroAuthModal
        onSuccess={(signedUser) => {
          if (signedUser && !signedUser.isGuest && authModalConfig?.intent === "pro_upgrade") {
            setIsStoreOpen(true);
          }
          setViewMode("studio");
          setCurrentTab("music");
        }}
      />
    </div>
  );
}
