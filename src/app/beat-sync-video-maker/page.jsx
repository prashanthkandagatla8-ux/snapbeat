import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "AI Beat Sync Video Maker | Sync Photos to Rhythm",
  description: "Automated AI beat sync video maker. Detect audio transients, sync photo cuts to kicks and drops, and export high-energy reels with 14 camera styles.",
  path: "/beat-sync-video-maker",
  keywords: ["beat sync video maker","sync video to beat","ai beat sync","music beat synced slideshow","beat synced photo video"],
});

export default function BeatSyncVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "AI Beat Sync Video Maker", path: "/beat-sync-video-maker" },
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
      desc: "Enjoy 100% free unlimited video renders during our open public beta period.",
    },
  ];

  const faqs = [
    {
        "question": "What is AI beat synchronization?",
        "answer": "Beat synchronization uses digital signal processing to calculate audio onset envelopes and tempo (BPM), triggering visual transitions at the exact millisecond musical peaks occur."
    },
    {
        "question": "Do I need video editing experience?",
        "answer": "None at all. Just add your photos and pick a song. SnapBeat handles 100% of the choreography, timeline pacing, and rendering automatically."
    },
    {
        "question": "Can I customize the video speed?",
        "answer": "The video speed naturally adapts to the BPM of your chosen soundtrack — high-energy songs produce fast cuts, while downtempo beats trigger gentle, dreamy motion."
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
      title="AI Beat Sync Video Maker | Sync Photos to Rhythm"
      h1="AI Beat Sync Video Maker"
      tagline="MATHEMATICALLY SYNCHRONIZED VISUALS"
      valueProposition="Eliminate hours of manual keyframing. SnapBeat automatically scans your audio waveform for kicks, claps, and bass drops, cutting your photos in perfect rhythmic synchronization."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "beat-bounce",
            "name": "Bounce",
            "subtitle": "Kinetic bassline scale bounces",
            "emoji": "🏀"
      },
      {
            "id": "punch-cut",
            "name": "Punch",
            "subtitle": "Slam into beat drops with maximum impact",
            "emoji": "🥊"
      },
      {
            "id": "beat-cut",
            "name": "Beat Cut",
            "subtitle": "Snappy rhythmic transitions on audio transients",
            "emoji": "⚡"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Photo to Music Video",
            "path": "/photo-to-music-video",
            "desc": "Music videos from your photo memories."
      },
      {
            "name": "Instagram Reel Maker",
            "path": "/instagram-reel-maker",
            "desc": "Reels optimized for social algorithms."
      },
      {
            "name": "Templates Hub",
            "path": "/templates",
            "desc": "Browse all 14 motion choreography presets."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
