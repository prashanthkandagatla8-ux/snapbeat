import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Make Music Videos from Photos Automatically",
  description: "Create viral music videos from still photos. SnapBeat uses AI beat detection to synchronize image cuts and kinetic transitions with your music track.",
  path: "/photo-to-music-video",
  keywords: ["photo to music video","make music video from photos","picture music video maker","sync photos to music","music video slideshow"],
});

export default function PhotoToMusicVideoPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Make Music Videos from Photos Automatically", path: "/photo-to-music-video" },
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
        "question": "How does SnapBeat sync photos to the music?",
        "answer": "Our audio engine performs spectral flux onset detection to identify rhythmic peaks, snares, and drops in the audio waveform, aligning every transition with musical precision."
    },
    {
        "question": "What audio formats can I upload?",
        "answer": "SnapBeat accepts MP3, WAV, M4A, and AAC files. You can trim the exact start and end points using our interactive tape deck waveform."
    },
    {
        "question": "Is video export quality full 1080p?",
        "answer": "Yes! SnapBeat renders high-bitrate MP4 files with crisp audio encoding for seamless uploading across all major streaming and social platforms."
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
      title="Make Music Videos from Photos Automatically"
      h1="Make Music Videos from Photos Automatically"
      tagline="AI-POWERED PHOTO MUSIC VIDEO STUDIO"
      valueProposition="Bring your favorite soundtrack to life with still pictures. SnapBeat pairs intelligent audio onset analysis with dynamic optical zooms, lateral glides, and snappy cuts to produce broadcast-grade music videos."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "beat-cut",
            "name": "Beat Cut",
            "subtitle": "Rapid rhythmic cuts aligned to kick drums",
            "emoji": "⚡"
      },
      {
            "id": "punch-cut",
            "name": "Punch",
            "subtitle": "High-impact kinetic punches on music drops",
            "emoji": "🥊"
      },
      {
            "id": "beat-whip",
            "name": "Whip",
            "subtitle": "High-velocity directional whip pan transitions",
            "emoji": "🌪️"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Beat Sync Video Maker",
            "path": "/beat-sync-video-maker",
            "desc": "Automatic rhythmic audio alignment."
      },
      {
            "name": "Photo Reel Maker",
            "path": "/photo-reel-maker",
            "desc": "High-energy reels for social media."
      },
      {
            "name": "Instagram Reel Maker",
            "path": "/instagram-reel-maker",
            "desc": "Vertical videos ready for Instagram."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
