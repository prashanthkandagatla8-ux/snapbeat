"use client";

import { useState } from "react";
import { Header } from "@/components/layout/Header";
import { LeftPanel } from "@/components/layout/LeftPanel";
import { CenterPanel } from "@/components/layout/CenterPanel";
import { RightPanel } from "@/components/layout/RightPanel";
import { ProPricingModal } from "@/components/billing/ProPricingModal";
import { initializeRazorpayCheckout } from "@/components/billing/RazorpayCheckout";
import { useSubscription } from "@/hooks/useSubscription";
import { useStudioState } from "@/hooks/useStudioState";
import { useRenderJob } from "@/hooks/useRenderJob";

export default function StudioPage() {
  const { isPro, daysRemaining, activatePro } = useSubscription();
  const [isPricingOpen, setIsPricingOpen] = useState(false);

  // Studio state
  const studio = useStudioState(isPro);

  // Render job state
  const renderJob = useRenderJob();

  // Handle plan purchase
  const handleSelectPlan = (planId) => {
    setIsPricingOpen(false);
    initializeRazorpayCheckout(
      planId,
      (plan, paymentId) => {
        activatePro(plan, paymentId);
        alert(`🎉 Congratulations! Pro activated successfully for ${plan.toUpperCase()}! 1080p Master exports and watermark removal are now unlocked.`);
      },
      () => {
        console.log("Payment canceled");
      }
    );
  };

  const handleStartRender = async () => {
    try {
      await renderJob.submitJob(studio);
    } catch (err) {
      alert(err.message || "Failed to submit render");
    }
  };

  const canRender = Boolean(studio.audioFile && studio.photos.length >= 2);

  return (
    <div className="flex flex-col min-h-screen bg-[#0e1117]">
      {/* Studio Header */}
      <Header
        isPro={isPro}
        daysRemaining={daysRemaining}
        onOpenPricing={() => setIsPricingOpen(true)}
      />

      {/* Main Studio 3-Panel Layout */}
      <main className="flex-1 max-w-[1680px] w-full mx-auto p-3 lg:p-6 grid grid-cols-1 lg:grid-cols-12 gap-4 lg:gap-6">
        {/* Left Panel: Media Intake (3.5 cols) */}
        <section className="lg:col-span-4 xl:col-span-3.5 h-full">
          <LeftPanel
            audioFile={studio.audioFile}
            audioUrl={studio.audioUrl}
            audioDuration={studio.audioDuration}
            audioTrim={studio.audioTrim}
            setAudio={studio.setAudio}
            setAudioTrim={studio.setAudioTrim}
            photos={studio.photos}
            addPhotos={studio.addPhotos}
            removePhoto={studio.removePhoto}
            reorderPhotos={studio.reorderPhotos}
            clearPhotos={studio.clearPhotos}
            autoArrange={studio.autoArrange}
            setAutoArrange={studio.setAutoArrange}
          />
        </section>

        {/* Center Panel: Interactive Stage (5 cols) */}
        <section className="lg:col-span-4 xl:col-span-5 h-full min-h-[460px]">
          <CenterPanel
            videoUrl={renderJob.videoUrl}
            aspectRatio={studio.aspectRatio}
            isRendering={renderJob.isRendering}
            progress={renderJob.progress}
            stage={renderJob.stage}
            queuePosition={renderJob.queuePosition}
            error={renderJob.error}
            onCancel={renderJob.cancelPolling}
          />
        </section>

        {/* Right Panel: Template & Controls (3.5 cols) */}
        <section className="lg:col-span-4 xl:col-span-3.5 h-full">
          <RightPanel
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
            onOpenPricing={() => setIsPricingOpen(true)}
            onRender={handleStartRender}
            isRendering={renderJob.isRendering}
            canRender={canRender}
          />
        </section>
      </main>

      {/* Footer */}
      <footer className="w-full bg-[#0b0e14] border-t border-[#1a202c] py-4 px-6 text-center text-xs text-gray-500 flex flex-col sm:flex-row items-center justify-between gap-2">
        <p>© 2026 SnapBeat Studio. All rights reserved.</p>
        <div className="flex items-center gap-4">
          <a href="/privacy" className="hover:text-amber-400 transition">Privacy Policy</a>
          <a href="/terms" className="hover:text-amber-400 transition">Terms of Service</a>
          <a href="/join" className="hover:text-amber-400 transition">Beta Testers Group</a>
          <a href="/beta" className="hover:text-amber-400 transition">Google Play App</a>
        </div>
      </footer>

      {/* Pricing Modal */}
      <ProPricingModal
        isOpen={isPricingOpen}
        onClose={() => setIsPricingOpen(false)}
        onSelectPlan={handleSelectPlan}
        isPro={isPro}
      />
    </div>
  );
}
