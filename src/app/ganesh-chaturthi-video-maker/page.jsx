import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Ganesh Chaturthi Photo Video Maker (వినాయక చవితి రీల్స్)",
  description: "Create devotional Ganesh Chaturthi festival photo videos with dhol tasha and aarti songs. Celebrate Vinayaka Chavithi with festive kinetic video reels.",
  path: "/ganesh-chaturthi-video-maker",
  keywords: ["ganesh chaturthi video maker","vinayaka chavithi photo video","ganpati photo video with song","ganesh festival reel maker","dhol tasha video maker"],
});

export default function GaneshChaturthiVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Ganesh Chaturthi Photo Video Maker", path: "/ganesh-chaturthi-video-maker" },
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
        "question": "Can I use Dhol Tasha or Ganpati Aarti songs?",
        "answer": "Yes! Upload high-energy Dhol Tasha tracks, traditional aartis, or Bollywood devotional anthems to match your pandal photos."
    },
    {
        "question": "Can I make videos for our residential colony or mandal?",
        "answer": "Yes! Many Ganesh mandals and families use SnapBeat to create social media recaps of their 10-day festivities."
    },
    {
        "question": "Is it mobile friendly?",
        "answer": "Yes, SnapBeat works smoothly on Android, iPhone, tablets, and desktop browsers."
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
      title="Ganesh Chaturthi Photo Video Maker (వినాయక చవితి రీల్స్)"
      h1="Ganesh Chaturthi Photo Video Maker"
      tagline="వినాయక చవితి పండుగ రీల్స్ & భక్తి వీడియోలు"
      valueProposition="Celebrate the divine arrival of Lord Ganesha. Combine pooja photos, pandal decorations, and immersion celebrations with energetic dhol tasha beats into breathtaking festival reels."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "punch-cut",
            "name": "Punch (Dhol Tasha Punch)",
            "subtitle": "Slamming transitions synced to pounding dhol beats",
            "emoji": "🥊"
      },
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom (Murti Zoom)",
            "subtitle": "Grand zooms highlighting Ganesh idol details",
            "emoji": "🎬"
      },
      {
            "id": "beat-cut",
            "name": "Beat Cut (Visarjan Rhythm)",
            "subtitle": "Energetic cuts for festive dance celebrations",
            "emoji": "⚡"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Diwali Video Maker",
            "path": "/diwali-video-maker",
            "desc": "Festival of lights photo video creator."
      },
      {
            "name": "Telugu Photo Video Maker",
            "path": "/telugu-photo-video-maker",
            "desc": "Telugu regional video maker."
      },
      {
            "name": "Photo to Music Video",
            "path": "/photo-to-music-video",
            "desc": "Sync music to festival celebrations."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
