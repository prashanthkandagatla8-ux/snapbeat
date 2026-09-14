import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Travel Photo Reel Maker with Cinematic Motion",
  description: "Transform vacation photos and trip memories into viral travel reels. AI beat sync, dynamic optical transitions, and vertical 9:16 exports.",
  path: "/travel-reel-maker",
  keywords: ["travel reel maker","vacation photo video maker","travel slideshow with music","travel video from photos","holiday photo reel"],
});

export default function TravelReelMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Travel Photo Reel Maker with Cinematic Motion", path: "/travel-reel-maker" },
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
        "question": "How many travel photos should I include in a reel?",
        "answer": "For a snappy 15-second travel montage, 8 to 15 photos work wonderfully to keep the pace vibrant and engaging."
    },
    {
        "question": "What soundtrack styles work best for travel reels?",
        "answer": "Upbeat electronic, tropical house, or chill lo-fi beats create the perfect wanderlust atmosphere."
    },
    {
        "question": "Can I export in 9:16 for Instagram and TikTok?",
        "answer": "Yes, SnapBeat defaults to 9:16 vertical orientation, optimized for smartphone screens."
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
      title="Travel Photo Reel Maker with Cinematic Motion"
      h1="Travel Photo Reel Maker"
      tagline="BRING YOUR ADVENTURES TO LIFE"
      valueProposition="Don’t let your vacation photos get buried in your camera roll. Turn city explorations, beach sunsets, and mountain hikes into high-octane travel reels set to energetic beats in seconds."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "beat-cut",
            "name": "Beat Cut",
            "subtitle": "Fast cuts showcasing destination highlights",
            "emoji": "⚡"
      },
      {
            "id": "cinematic-zoom",
            "name": "Cinematic Zoom",
            "subtitle": "Optical crash zooms into breathtaking landscapes",
            "emoji": "🎬"
      },
      {
            "id": "beat-whip",
            "name": "Whip",
            "subtitle": "Directional whip pans connecting scenic vistas",
            "emoji": "🌪️"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Instagram Reel Maker",
            "path": "/instagram-reel-maker",
            "desc": "Reels optimized for Instagram feed."
      },
      {
            "name": "Photo Reel Maker",
            "path": "/photo-reel-maker",
            "desc": "Create viral social reels."
      },
      {
            "name": "Templates Hub",
            "path": "/templates",
            "desc": "Browse all 14 kinetic camera styles."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
