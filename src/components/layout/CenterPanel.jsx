"use client";

import { VideoStage } from "@/components/render/VideoStage";
import { ProgressOverlay } from "@/components/render/ProgressOverlay";

export function CenterPanel({
  videoUrl,
  aspectRatio,
  isRendering,
  progress,
  stage,
  queuePosition,
  error,
  onCancel,
}) {
  return (
    <div className="relative rounded-2xl bg-[#151922] border border-[#242b38] p-4 flex flex-col items-center justify-center min-h-[480px] h-full shadow-sm overflow-hidden">
      <VideoStage
        videoUrl={videoUrl}
        aspectRatio={aspectRatio}
        isRendering={isRendering}
      />
      <ProgressOverlay
        isRendering={isRendering}
        progress={progress}
        stage={stage}
        queuePosition={queuePosition}
        error={error}
        onCancel={onCancel}
      />
    </div>
  );
}
