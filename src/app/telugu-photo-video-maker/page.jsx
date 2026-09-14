import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Telugu Photo Video Maker with Songs (తెలుగు ఫోటో వీడియోలు)",
  description: "Online Telugu photo to video maker with music. Sync photos to Telugu hit songs with automatic beat detection and cinematic transitions.",
  path: "/telugu-photo-video-maker",
  keywords: ["telugu photo video maker","telugu photo to video with song","telugu songs video maker with photos","photo video maker online telugu","telugu reel maker"],
});

export default function TeluguPhotoVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Telugu Photo Video Maker with Songs", path: "/telugu-photo-video-maker" },
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
        "question": "తెలుగు పాటలతో ఫోటో వీడియో ఎలా చేయాలి?",
        "answer": "1) మీ ఫోటోలను అప్‌లోడ్ చేయండి. 2) మీకు నచ్చిన తెలుగు పాటను ఎంచుకోండి. 3) స్టైల్ ఎంచుకుని రెండర్ బటన్ నొక్కండి. నిమిషంలో మీ వీడియో సిద్ధం!"
    },
    {
        "question": "నా ఫోన్ లో ఉన్న తెలుగు సాంగ్స్ అప్‌లోడ్ చేయవచ్చా?",
        "answer": "అవును, మీ డివైస్ లో ఉన్న ఏ MP3 లేదా ఆడియో ఫైల్ అయినా నేరుగా అప్‌లోడ్ చేయవచ్చు."
    },
    {
        "question": "వీడియో డౌన్‌లోడ్ చేసుకోవడం ఉచితమేనా?",
        "answer": "అవును, SnapBeat లో ఎలాంటి దాగి ఉన్న ఛార్జీలు లేకుండా నేరుగా వీడియో MP4 డౌన్‌లోడ్ చేసుకోవచ్చు."
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
      title="Telugu Photo Video Maker with Songs (తెలుగు ఫోటో వీడియోలు)"
      h1="Telugu Photo Video Maker with Songs"
      tagline="పాటలతో తెలుగు ఫోటో వీడియోలు తయారు చేయండి"
      valueProposition="మీ ఫేవరెట్ తెలుగు పాటలకు మీ ఫోటోలను సింక్ చేసి అద్భుతమైన వీడియోలు మరియు రీల్స్ తయారు చేసుకోండి. ఎలాంటి ఎడిటింగ్ అనుభవం అవసరం లేకుండా క్షణాల్లో రెండర్ చేయండి."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "pendulum",
            "name": "Pendulum (పెండ్యులమ్)",
            "subtitle": "స్టైలిష్ మిర్రర్ బార్డర్ స్వింగ్ కట్స్",
            "emoji": "🪞"
      },
      {
            "id": "slow-drift",
            "name": "Slow Drift (మెలోడీ డ్రిఫ్ట్)",
            "subtitle": "తెలుగు మెలోడీ పాటలకు అనువైన స్లో మోషన్",
            "emoji": "☁️"
      },
      {
            "id": "beat-cut",
            "name": "Beat Cut (బీట్ కట్స్)",
            "subtitle": "తీన్‌మార్ మరియు ఫాస్ట్ సాంగ్స్ కి అదిరిపోయే కట్స్",
            "emoji": "⚡"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Telugu Birthday Video Maker",
            "path": "/telugu-birthday-video-maker",
            "desc": "తెలుగు బర్త్‌డే స్పెషల్ వీడియోలు."
      },
      {
            "name": "Beat Sync Video Maker",
            "path": "/beat-sync-video-maker",
            "desc": "Automatic beat sync studio."
      },
      {
            "name": "Instagram Reel Maker",
            "path": "/instagram-reel-maker",
            "desc": "Vertical video maker."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
