import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Wedding Photo Video Maker & Cinematic Slideshows",
  description: "Transform wedding and engagement photography into breathtaking cinematic video slideshows. Emotional music sync, graceful motion, and 1080p exports.",
  path: "/wedding-video-maker",
  keywords: ["wedding photo video maker","wedding slideshow with music","marriage photo video maker","wedding photo reel","cinematic wedding video maker"],
});

export default function WeddingVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Wedding Photo Video Maker & Cinematic Slideshows", path: "/wedding-video-maker" },
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
        "question": "Is SnapBeat suitable for professional wedding photographers?",
        "answer": "Yes! Photographers use SnapBeat to deliver quick-turnaround social media teaser reels to clients within 24 hours of the wedding."
    },
    {
        "question": "Can I output in widescreen for TV displays?",
        "answer": "Yes, SnapBeat supports 16:9 Landscape mode, perfect for screening at receptions or viewing on living room smart TVs."
    },
    {
        "question": "Can I add custom couple names to the video?",
        "answer": "Yes, SnapBeat Pro allows you to include elegant title card typography with the couple’s names and wedding date."
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
      title="Wedding Photo Video Maker & Cinematic Slideshows"
      h1="Wedding Photo Video Maker"
      tagline="CINEMATIC ELEGANCE FOR YOUR SPECIAL DAY"
      valueProposition="Your wedding day deserves more than static albums. SnapBeat turns your ceremony portraits, bridal preparations, and reception dances into a fluid cinematic film set to your romantic song."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "slow-drift",
            "name": "Slow Drift",
            "subtitle": "Dreamy slow drift for bridal portraits",
            "emoji": "☁️"
      },
      {
            "id": "beat-fade",
            "name": "Fade",
            "subtitle": "Gentle dissolve transitions matching romantic ballads",
            "emoji": "🌊"
      },
      {
            "id": "sway-ballad",
            "name": "Sway",
            "subtitle": "Graceful cadence for first dance photos",
            "emoji": "🍃"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Anniversary Video Maker",
            "path": "/anniversary-video-maker",
            "desc": "Celebrate relationship milestones."
      },
      {
            "name": "Photo Slideshow Maker",
            "path": "/photo-slideshow-maker",
            "desc": "General cinematic slideshows."
      },
      {
            "name": "Templates Hub",
            "path": "/templates",
            "desc": "Choose elegant motion presets."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
