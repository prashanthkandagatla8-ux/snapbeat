import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Romantic Anniversary Photo Video Maker",
  description: "Celebrate your love story with a romantic anniversary photo video. Sync years of memories to your favorite love song with cinematic motion presets.",
  path: "/anniversary-video-maker",
  keywords: ["anniversary video maker","anniversary photo video with song","romantic photo slideshow","love video maker from photos","wedding anniversary reel"],
});

export default function AnniversaryVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Romantic Anniversary Photo Video Maker", path: "/anniversary-video-maker" },
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
        "question": "What photos work best for an anniversary video?",
        "answer": "A chronological mix of then and now photos — from your early dates to recent vacations — creates the most meaningful emotional journey."
    },
    {
        "question": "Can I use a custom song that means a lot to us?",
        "answer": "Yes! Simply upload your special song file and use our audio trimmer to select the chorus or emotional climax."
    },
    {
        "question": "Is it easy to send to my partner?",
        "answer": "Yes, once rendered, you can download the video directly to your phone or laptop to surprise your partner."
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
      title="Romantic Anniversary Photo Video Maker"
      h1="Romantic Anniversary Photo Video Maker"
      tagline="HONOR YOUR LOVE STORY IN MOTION"
      valueProposition="Celebrate 1 year or 50 years of shared love. Gather your favorite trips, anniversaries, and everyday moments, and let SnapBeat weave them into a poignant anniversary tribute video."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "slow-drift",
            "name": "Slow Drift",
            "subtitle": "Timeless gentle motion for love stories",
            "emoji": "☁️"
      },
      {
            "id": "sway-ballad",
            "name": "Sway",
            "subtitle": "Warm acoustic cadence for romantic songs",
            "emoji": "🍃"
      },
      {
            "id": "pendulum",
            "name": "Pendulum",
            "subtitle": "Mirrored elegance reflecting years together",
            "emoji": "🪞"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Wedding Video Maker",
            "path": "/wedding-video-maker",
            "desc": "Relive wedding ceremony memories."
      },
      {
            "name": "Birthday Video Maker",
            "path": "/birthday-video-maker",
            "desc": "Celebrate special milestones."
      },
      {
            "name": "Photo to Music Video",
            "path": "/photo-to-music-video",
            "desc": "Sync love songs with photo memories."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
