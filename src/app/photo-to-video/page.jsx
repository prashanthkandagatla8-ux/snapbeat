import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Free Photo to Video Maker with Music",
  description: "Convert photos into beat-synced videos and reels online for free. AI beat detection, 14 kinetic camera motion styles, and instant 1080p MP4 exports.",
  path: "/photo-to-video",
  keywords: ["photo to video maker","turn photos into video","photo video with song","online video maker from photos","free photo video converter"],
});

export default function PhotoToVideoPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Free Photo to Video Maker with Music", path: "/photo-to-video" },
  ];

  const howItWorks = [
    {
      step: "01",
      title: "Upload Photos",
      desc: "Add between 2 and 20 photos from your phone or camera. Reorder, shuffle, or auto-arrange in our tactile Photo Bay.",
    },
    {
      step: "02",
      title: "Pick Music & Motion",
      desc: "Choose a soundtrack or upload your own audio. Select one of 14 kinetic camera choreography presets.",
    },
    {
      step: "03",
      title: "Export Beat-Synced Video",
      desc: "Our GPU cluster analyzes acoustic drop points and renders a high-definition MP4 reel in seconds.",
    },
  ];

  const benefits = [
    {
      title: "Automated AI Beat Detection",
      desc: "No manual timeline editing. Our audio engine calculates exact acoustic transients and drop points.",
    },
    {
      title: "14 Kinetic Camera Styles",
      desc: "From snappy beat cuts and bassline bounces to cinematic zooms, slow drifts, and mirrored pendulums.",
    },
    {
      title: "All Social Formats",
      desc: "Export in 9:16 Portrait for Reels, Shorts, and TikTok; 1:1 Square for feeds; or 16:9 Landscape for TV.",
    },
    {
      title: "Instant 1-Click Guest Access",
      desc: "Zero signup friction. Jump straight into the workstation and export your reel in seconds.",
    },
    {
      title: "High-Speed GPU Renders",
      desc: "Powered by high-performance cloud GPUs for fast sub-minute video encoding and instant delivery.",
    },
    {
      title: "Free Unlimited Creation",
      desc: "Enjoy 100% free unlimited video renders with instant guest access and no credit card required.",
    },
  ];

  const faqs = [
    {
        "question": "Is SnapBeat free to use?",
        "answer": "Yes! SnapBeat offers 100% free unlimited video renders with instant guest access with instant guest access. No account or credit card required."
    },
    {
        "question": "How many photos can I add to a video?",
        "answer": "You can add between 2 and 20 photos per video reel. Our sequencer allows you to arrange, shuffle, and auto-order them effortlessly."
    },
    {
        "question": "Can I upload my own songs?",
        "answer": "Absolutely. You can choose from our curated built-in soundtracks or upload your own MP3, WAV, or AAC audio files with precision audio trimming."
    }
];

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      getWebApplicationSchema(),
      getBreadcrumbSchema(breadcrumbs),
      getFaqSchema(faqs),
    ],
  };

  return (
    <SeoLandingPage
      title="Free Photo to Video Maker with Music"
      h1="Free Photo to Video Maker with Music"
      tagline="INSTANT AI PHOTO TO VIDEO CONVERTER"
      valueProposition="SnapBeat transforms your still photo collections into rhythmically synchronized short-form videos. Simply upload your pictures, select your favorite music track, and let our AI engine automatically match transitions to the beat."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "pendulum",
            "name": "Pendulum",
            "subtitle": "Swinging rhythmic cuts with mirrored borders",
            "emoji": "🪞"
      },
      {
            "id": "beat-cut",
            "name": "Beat Cut",
            "subtitle": "Snappy transitions synced directly to kick drums",
            "emoji": "⚡"
      },
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom",
            "subtitle": "Optical crash zooms on high-energy beat drops",
            "emoji": "🎬"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Photo Slideshow Maker",
            "path": "/photo-slideshow-maker",
            "desc": "Create cinematic slideshows with smooth pacing."
      },
      {
            "name": "Beat Sync Video Maker",
            "path": "/beat-sync-video-maker",
            "desc": "Automated waveform beat-matching."
      },
      {
            "name": "Instagram Reel Maker",
            "path": "/instagram-reel-maker",
            "desc": "9:16 vertical reels optimized for social media."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
