import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Photo Reel Maker for Social Media (Free)",
  description: "Create viral photo reels for Instagram, TikTok, and YouTube Shorts. Automated beat matching, vertical 9:16 layout, and kinetic camera choreography.",
  path: "/photo-reel-maker",
  keywords: ["photo reel maker","make reels from photos","photo dump reel maker","tiktok photo video maker","reel maker online free"],
});

export default function PhotoReelMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Photo Reel Maker for Social Media", path: "/photo-reel-maker" },
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
        "question": "Why are photo reels performing well on social media?",
        "answer": "Short-form platforms prioritize high retention and loop rates. Beat-synced photo reels combine compelling photography with rhythmic music, encouraging repeated views."
    },
    {
        "question": "What is the optimal video length for reels?",
        "answer": "Reels between 7 and 15 seconds typically achieve the highest completion and replay rates. SnapBeat allows you to trim your music to the most viral section."
    },
    {
        "question": "Are videos exported without watermarks?",
        "answer": "Free users receive high-quality renders with a subtle watermark. Upgrading to a SnapBeat Pro pass (₹99/week or ₹199/month) unlocks 100% watermark-free 1080p master exports."
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
      title="Photo Reel Maker for Social Media (Free)"
      h1="Photo Reel Maker for Social Media"
      tagline="GROW YOUR ENGAGEMENT WITH KINETIC REELS"
      valueProposition="Social media algorithms favor video over static photos. SnapBeat transforms your photo dumps and camera roll highlights into engaging 9:16 reels that keep viewers watching and looping."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "pendulum",
            "name": "Pendulum",
            "subtitle": "Dynamic mirrored border pans designed for vertical screens",
            "emoji": "🪞"
      },
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom",
            "subtitle": "Optical crash zooms that captivate viewers",
            "emoji": "🎬"
      },
      {
            "id": "glide-pan",
            "name": "Glide",
            "subtitle": "Sleek lateral gliding pan motion",
            "emoji": "🛹"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Instagram Reel Maker",
            "path": "/instagram-reel-maker",
            "desc": "Specialized Instagram reel creator."
      },
      {
            "name": "Travel Reel Maker",
            "path": "/travel-reel-maker",
            "desc": "Cinematic vacation and travel montages."
      },
      {
            "name": "Birthday Video Maker",
            "path": "/birthday-video-maker",
            "desc": "Celebration tributes and birthday reels."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
