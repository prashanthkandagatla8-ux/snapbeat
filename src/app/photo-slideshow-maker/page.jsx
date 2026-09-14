import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Photo Slideshow Maker with Music & Motion",
  description: "Create cinematic photo slideshows with background music and kinetic motion transitions. Free online tool with automated timing and aspect ratio support.",
  path: "/photo-slideshow-maker",
  keywords: ["photo slideshow maker","slideshow maker with music","picture slideshow with songs","online slideshow creator","make slideshow from photos"],
});

export default function PhotoSlideshowMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Photo Slideshow Maker with Music & Motion", path: "/photo-slideshow-maker" },
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
        "question": "What makes SnapBeat different from traditional slideshow makers?",
        "answer": "Unlike rigid slideshow creators that simply switch photos every 3 seconds, SnapBeat analyzes acoustic drops and tempo variations in your music to dynamically choreograph transitions."
    },
    {
        "question": "What aspect ratios are supported?",
        "answer": "SnapBeat supports 9:16 Portrait (Reels, TikTok, Shorts), 1:1 Square (Instagram Posts), and 16:9 Landscape (YouTube, TV screens)."
    },
    {
        "question": "Can I reorder photos in the slideshow?",
        "answer": "Yes, our visual Photo Bay allows you to drag-and-drop to reorder, shuffle randomly, or automatically organize your photos."
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
      title="Photo Slideshow Maker with Music & Motion"
      h1="Photo Slideshow Maker with Music & Motion"
      tagline="CINEMATIC PHOTO SLIDESHOWS IN SECONDS"
      valueProposition="Say goodbye to boring, static slideshows. SnapBeat combines audio onset detection with 14 kinetic camera movements to turn your cherished memories into fluid, professional video montages."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
      {
            "id": "slow-drift",
            "name": "Slow Drift",
            "subtitle": "Atmospheric slow cinematic drift for emotional memories",
            "emoji": "☁️"
      },
      {
            "id": "beat-fade",
            "name": "Fade",
            "subtitle": "Silky smooth crossfades for ambient acoustic songs",
            "emoji": "🌊"
      },
      {
            "id": "sway-ballad",
            "name": "Sway",
            "subtitle": "Gentle cadence matching acoustic guitar chords",
            "emoji": "🍃"
      }
]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
      {
            "name": "Photo to Video Maker",
            "path": "/photo-to-video",
            "desc": "Turn photos into beat-synced videos."
      },
      {
            "name": "Photo to Music Video",
            "path": "/photo-to-music-video",
            "desc": "Music videos from your photo memories."
      },
      {
            "name": "Templates Hub",
            "path": "/templates",
            "desc": "Explore all 14 kinetic motion styles."
      }
]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
