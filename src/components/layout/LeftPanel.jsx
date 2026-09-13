"use client";

import { AudioDeck } from "@/components/audio/AudioDeck";
import { PhotoSequencer } from "@/components/photos/PhotoSequencer";

export function LeftPanel({
  audioFile,
  audioUrl,
  audioDuration,
  audioTrim,
  setAudio,
  setAudioTrim,
  photos,
  addPhotos,
  removePhoto,
  reorderPhotos,
  clearPhotos,
  autoArrange,
  setAutoArrange,
}) {
  return (
    <div className="flex flex-col gap-4 h-full">
      <AudioDeck
        audioFile={audioFile}
        audioUrl={audioUrl}
        audioDuration={audioDuration}
        audioTrim={audioTrim}
        setAudio={setAudio}
        setAudioTrim={setAudioTrim}
      />
      <div className="flex-1 min-h-[300px]">
        <PhotoSequencer
          photos={photos}
          addPhotos={addPhotos}
          removePhoto={removePhoto}
          reorderPhotos={reorderPhotos}
          clearPhotos={clearPhotos}
          autoArrange={autoArrange}
          setAutoArrange={setAutoArrange}
        />
      </div>
    </div>
  );
}
