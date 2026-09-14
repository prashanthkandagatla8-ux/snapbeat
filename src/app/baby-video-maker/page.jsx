import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Baby Photo Video & Milestone Reel Maker",
  description: "Preserve monthly milestones and baby memories in beautiful beat-synced videos. Fast, simple, and free online baby photo slideshow creator.",
  path: "/baby-video-maker",
  keywords: ["baby video maker","baby photo video with song","baby milestone slideshow","baby first year video maker","newborn photo video"],
});

export default function BabyVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Baby Photo Video & Milestone Reel Maker", path: "/baby-video-maker" },
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
        "question": "How can I organize monthly milestone photos (Months 1 to 12)?",
        "answer": "Upload your 12 milestone photos and use our visual Photo Bay to ensure they are sequenced chronologically from birth to the first birthday."
    },
    {
        "question": "Is baby content secure and private?",
        "answer": "Yes. Your uploaded photos and rendered videos are processed securely on isolated GPU servers with zero public exposure."
    },
    {
        "question": "Can I create videos for baby showers or gender reveals?",
        "answer": "Yes! SnapBeat is perfect for baby shower countdowns, gender reveal teasers, and 1st birthday parties."
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
      title="Baby Photo Video & Milestone Reel Maker"
      h1="Baby Photo Video & Milestone Reel Maker"
      tagline="CAPTURE PRECIOUS BABY MILESTONES"
      valueProposition="Babies grow in the blink of an eye. Gather monthly milestone photos, first steps, and funny smiles into a heartwarming baby milestone video that grandparents and family will treasure forever."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "slow-drift",
            "name": "Slow Drift",
            "subtitle": "Soft, gentle motion for peaceful newborn shots",
            "emoji": "☁️"
      },
      {
            "id": "beat-bounce",
            "name": "Bounce",
            "subtitle": "Playful kinetic bounce for energetic toddler fun",
            "emoji": "🏀"
      },
      {
            "id": "beat-fade",
            "name": "Fade",
            "subtitle": "Smooth transitions across monthly milestones",
            "emoji": "🌊"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Birthday Video Maker",
            "path": "/birthday-video-maker",
            "desc": "First birthday celebration videos."
      },
      {
            "name": "Photo Slideshow Maker",
            "path": "/photo-slideshow-maker",
            "desc": "Family photo slideshow creator."
      },
      {
            "name": "Templates Hub",
            "path": "/templates",
            "desc": "Explore all motion presets."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
