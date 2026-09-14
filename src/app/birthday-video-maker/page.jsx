import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Birthday Photo Video Maker with Music & Wishes",
  description: "Create touching birthday photo video slideshows with celebration music. Free online birthday reel maker with kinetic motion and custom title cards.",
  path: "/birthday-video-maker",
  keywords: ["birthday video maker","birthday photo video with song","birthday slideshow with music","happy birthday reel maker","birthday photo montage"],
});

export default function BirthdayVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Birthday Photo Video Maker with Music & Wishes", path: "/birthday-video-maker" },
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
        "question": "Can I add birthday songs to the video?",
        "answer": "Yes, you can upload popular birthday tracks or choose from our built-in celebration soundtrack library."
    },
    {
        "question": "Can I share the birthday video directly on WhatsApp?",
        "answer": "Yes! SnapBeat generates standard MP4 video files that can be shared instantly as WhatsApp Statuses, Instagram Stories, or private messages."
    },
    {
        "question": "Can I make birthday videos for friends and family?",
        "answer": "Absolutely! Create unlimited videos for your kids, partner, parents, or best friends."
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
      title="Birthday Photo Video Maker with Music & Wishes"
      h1="Birthday Photo Video Maker with Music"
      tagline="CELEBRATE MEMORIES WITH KINETIC MOTION"
      valueProposition="Give the gift of cherished memories. SnapBeat transforms childhood throwbacks, party snapshots, and family memories into a heartwarming birthday tribute video synced to festive music."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "pendulum",
            "name": "Pendulum",
            "subtitle": "Elegant mirrored swings honoring special years",
            "emoji": "🪞"
      },
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom",
            "subtitle": "Spotlight important smiles and celebration moments",
            "emoji": "🎬"
      },
      {
            "id": "slow-drift",
            "name": "Slow Drift",
            "subtitle": "Emotional retrospective drifting motion",
            "emoji": "☁️"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Party Video Maker",
            "path": "/party-video-maker",
            "desc": "High-energy party and celebration reels."
      },
      {
            "name": "Anniversary Video Maker",
            "path": "/anniversary-video-maker",
            "desc": "Romantic anniversary slideshows."
      },
      {
            "name": "Baby Video Maker",
            "path": "/baby-video-maker",
            "desc": "Milestone videos for baby birthdays."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
