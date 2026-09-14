import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Diwali Festival Photo Video Maker with Music",
  description: "Make sparkling Diwali festival photo videos with music. Combine family diwali celebrations, rangoli, diyas, and fireworks into cinematic video reels.",
  path: "/diwali-video-maker",
  keywords: ["diwali video maker","diwali photo video with song","diwali slideshow maker","deepavali photo video","happy diwali reel maker"],
});

export default function DiwaliVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Diwali Festival Photo Video Maker with Music", path: "/diwali-video-maker" },
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
        "question": "Can I add traditional Diwali and celebration tracks?",
        "answer": "Yes, upload your favorite festive melodies or pick from SnapBeat’s high-energy celebration sound tracks."
    },
    {
        "question": "Can I send Diwali video greetings to loved ones on WhatsApp?",
        "answer": "Yes! Download the finished MP4 reel directly to your device and send personalized Deepavali video greetings to friends and family."
    },
    {
        "question": "Does SnapBeat support low-light Diwali night photos?",
        "answer": "Yes, our rendering engine preserves the deep shadows and warm highlights of your diya and firecracker photography."
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
      title="Diwali Festival Photo Video Maker with Music"
      h1="Diwali Festival Photo Video Maker with Music"
      tagline="ILLUMINATE YOUR FESTIVAL MEMORIES"
      valueProposition="Light up your social media with sparkling Diwali memories. Turn festive family gatherings, glowing diyas, beautiful rangoli designs, and firework celebrations into a vibrant festival video."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom",
            "subtitle": "Dynamic zooms into glowing diyas and sparklers",
            "emoji": "🎬"
      },
      {
            "id": "beat-bounce",
            "name": "Bounce",
            "subtitle": "Playful kinetic motion for family celebration songs",
            "emoji": "🏀"
      },
      {
            "id": "slow-drift",
            "name": "Slow Drift",
            "subtitle": "Atmospheric warmth for candlelit family gatherings",
            "emoji": "☁️"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Ganesh Chaturthi Video Maker",
            "path": "/ganesh-chaturthi-video-maker",
            "desc": "Ganesh festival videos."
      },
      {
            "name": "Birthday Video Maker",
            "path": "/birthday-video-maker",
            "desc": "Celebration tributes."
      },
      {
            "name": "Photo Reel Maker",
            "path": "/photo-reel-maker",
            "desc": "Create viral festive reels."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
