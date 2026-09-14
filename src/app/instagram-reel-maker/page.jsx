import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Instagram Reel Maker from Photos | Free & Fast",
  description: "Make viral Instagram reels from photos with music. Instant 9:16 vertical exports, beat-synced cuts, and trending motion styles designed for IG growth.",
  path: "/instagram-reel-maker",
  keywords: ["instagram reel maker","instagram reel from photos","make ig reels with photos","photo dump to reel","instagram slideshow reel"],
});

export default function InstagramReelMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Instagram Reel Maker from Photos", path: "/instagram-reel-maker" },
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
        "question": "Does SnapBeat export in native 9:16 resolution?",
        "answer": "Yes, SnapBeat renders in 1080x1920 (9:16 portrait) with smart subject centering, ensuring your video fills mobile screens edge-to-edge."
    },
    {
        "question": "Can I add opening title cards for Instagram?",
        "answer": "Yes! SnapBeat Pro features customizable retro and modern title cards to announce themes like Summer Dump 2026 or Birthday Recap."
    },
    {
        "question": "How quickly can I export an Instagram reel?",
        "answer": "Our dedicated GPU cluster encodes and renders finished MP4 videos in typically under 45 seconds."
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
      title="Instagram Reel Maker from Photos | Free & Fast"
      h1="Instagram Reel Maker from Photos"
      tagline="OPTIMIZED FOR INSTAGRAM ALGORITHMS"
      valueProposition="Turn your best photo dumps into high-retention Instagram reels. SnapBeat automates beat synchronization, frame cropping, and kinetic transitions so you can post stunning content in seconds."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "beat-cut",
            "name": "Beat Cut",
            "subtitle": "Snappy cuts that boost viewer watch time",
            "emoji": "⚡"
      },
      {
            "id": "beat-bounce",
            "name": "Bounce",
            "subtitle": "Kinetic bassline bounce for trending audios",
            "emoji": "🏀"
      },
      {
            "id": "reveal-tiles",
            "name": "Reveal Boxes",
            "subtitle": "Modern mosaic box reveals",
            "emoji": "🔲"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Photo Reel Maker",
            "path": "/photo-reel-maker",
            "desc": "Multi-platform short-form video creator."
      },
      {
            "name": "Travel Reel Maker",
            "path": "/travel-reel-maker",
            "desc": "Vibrant vacation and trip montages."
      },
      {
            "name": "Photo to Music Video",
            "path": "/photo-to-music-video",
            "desc": "Full music synchronization for pictures."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
