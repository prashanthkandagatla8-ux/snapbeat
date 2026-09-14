import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Telugu Birthday Photo Video Maker (తెలుగు బర్త్‌డే రీల్స్)",
  description: "Create Telugu birthday photo videos with songs online. Add Telugu mass beat songs, birthday wishes, and kinetic motion effects. ఉచితంగా వీడియో చేయండి.",
  path: "/telugu-birthday-video-maker",
  keywords: ["telugu birthday video maker","telugu birthday photo video with songs","birthday video maker telugu online","telugu photo video maker","birthday wishes video in telugu"],
});

export default function TeluguBirthdayVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Telugu Birthday Photo Video Maker", path: "/telugu-birthday-video-maker" },
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
        "question": "ఈ వెబ్‌సైట్ లో తెలుగు బర్త్‌డే పాటలు వాడవచ్చా?",
        "answer": "అవును! మీరు మీకు నచ్చిన తెలుగు బర్త్‌డే సాంగ్స్, మాస్ బీట్స్ లేదా డీజే పాటలను సులభంగా అప్‌లోడ్ చేసి వాడవచ్చు."
    },
    {
        "question": "వాట్సాప్ స్టేటస్ కి సరిపోయేలా వీడియో వస్తుందా?",
        "answer": "ఖచ్చితంగా! SnapBeat 9:16 సైజ్ లో హై క్వాలిటీ MP4 వీడియో ఇస్తుంది. మీరు నేరుగా వాట్సాప్ స్టేటస్ లేదా ఇన్‌స్టాగ్రామ్ రీల్స్ లో పెట్టుకోవచ్చు."
    },
    {
        "question": "వీడియో చేయడానికి డబ్బులు కట్టాలా?",
        "answer": "లేదు, SnapBeat లో పబ్లిక్ బీటా సందర్భంగా అన్‌లిమిటెడ్ వీడియో రెండరింగ్ పూర్తిగా ఉచితం."
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
      title="Telugu Birthday Photo Video Maker (తెలుగు బర్త్‌డే రీల్స్)"
      h1="Telugu Birthday Photo Video Maker (తెలుగు బర్త్‌డే రీల్స్)"
      tagline="తెలుగు బర్త్‌డే ఫోటో వీడియో మేకర్"
      valueProposition="మీ స్నేహితులు మరియు కుటుంబ సభ్యుల పుట్టినరోజుల కోసం అదిరిపోయే తెలుగు బర్త్‌డే రీల్స్ మరియు వీడియోలు చేయండి. మాస్ బీట్స్, డిజే సాంగ్స్ మరియు సినీ స్టైల్ కెమెరా మోషన్స్ తో క్షణాల్లో వీడియో రెడీ!"
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "punch-cut",
            "name": "Punch (మాస్ పంచ్)",
            "subtitle": "మాస్ బీట్స్ మరియు డీజే డ్రాప్స్ కి అదిరిపోయే కట్స్",
            "emoji": "🥊"
      },
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom (హీరో జూమ్)",
            "subtitle": "సినిమాటిక్ హీరోయిక్ జూమ్ ఎఫెక్ట్స్",
            "emoji": "🎬"
      },
      {
            "id": "beat-cut",
            "name": "Beat Cut (ఫాస్ట్ బీట్)",
            "subtitle": "డ్రమ్స్ మరియు ధోల్ బీట్స్ కి సూపర్ కట్స్",
            "emoji": "⚡"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Telugu Photo Video Maker",
            "path": "/telugu-photo-video-maker",
            "desc": "తెలుగు ఫోటో వీడియో మేకర్ సాంగ్స్ తో."
      },
      {
            "name": "Birthday Video Maker",
            "path": "/birthday-video-maker",
            "desc": "All birthday video styles."
      },
      {
            "name": "Ganesh Chaturthi Video Maker",
            "path": "/ganesh-chaturthi-video-maker",
            "desc": "వినాయక చవితి భక్తి వీడియోలు."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
