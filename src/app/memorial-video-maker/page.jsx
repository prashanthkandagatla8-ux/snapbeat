import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Memorial Video Maker | Celebration of Life Slideshow with Music",
  description:
    "Create touching memorial video slideshows and celebration of life tribute videos from photos with music. Gentle transitions, atmospheric drifts, and peaceful pacing.",
  path: "/memorial-video-maker",
  keywords: [
    "memorial video maker",
    "celebration of life video maker",
    "tribute slideshow with music",
    "funeral photo video maker",
    "memorial photo slideshow online free",
  ],
});

export default function MemorialVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Memorial Video Maker", path: "/memorial-video-maker" },
  ];

  const howItWorks = [
    {
      step: "01",
      title: "Upload Cherished Photos",
      desc: "Gather between 2 and 20 photographs honoring your loved one's lifetime, family milestones, and joyful memories.",
    },
    {
      step: "02",
      title: "Select a Peaceful Melody",
      desc: "Choose from emotional piano or acoustic soundtracks, or upload a song that holds deep personal meaning.",
    },
    {
      step: "03",
      title: "Export Tribute Video",
      desc: "Our engine pairs gentle kinetic drifts with subtle pacing, delivering a respectful, broadcast-quality tribute in seconds.",
    },
  ];

  const benefits = [
    {
      title: "Respectful, Graceful Motion",
      desc: "Atmospheric slow drifts, gentle crossfades, and soft optical zooms that honor your loved one's memory.",
    },
    {
      title: "Acoustic & Classical Soundtracks",
      desc: "Pre-cleared peaceful piano, acoustic guitar, and ambient tracks suited for solemn tributes.",
    },
    {
      title: "TV & Screen Ready (16:9 & 9:16)",
      desc: "Export in widescreen 16:9 for memorial services and TV screens, or 9:16 for family sharing.",
    },
    {
      title: "Instant 1-Click Guest Access",
      desc: "Zero sign-up hassle during difficult times. Create and download your tribute immediately.",
    },
    {
      title: "Private & Secure Processing",
      desc: "Family photos are processed on secure isolated cloud GPUs and never published publicly.",
    },
    {
      title: "100% Free to Use",
      desc: "Unlimited free renders to support families and loved ones during celebration of life planning.",
    },
  ];

  const faqs = [
    {
      question: "Can I play the memorial video on a projector or TV at a service?",
      answer:
        "Yes! SnapBeat allows you to choose 16:9 Landscape mode, which exports in standard full-screen resolution ideal for memorial service displays and televisions.",
    },
    {
      question: "Can I upload my loved one's favorite song?",
      answer:
        "Yes, simply upload any MP3 or audio file from your device and use our audio trimmer to set the start and end points.",
    },
    {
      question: "How many photos should I include?",
      answer:
        "We recommend between 10 and 20 photos. You can easily reorder them chronologically in our photo bay.",
    },
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
      title="Memorial Video Maker | Celebration of Life Slideshow with Music"
      h1="Memorial & Tribute Video Maker from Photos"
      tagline="HONOR CHERISHED MEMORIES WITH GRACE"
      valueProposition="Honor a lifetime of love and joy. SnapBeat weaves family photographs and meaningful music into a dignified, beautifully choreographed memorial video for celebration of life services and family keepsakes."
      primaryCtaText="Create Your Tribute Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
        {
          id: "slow-drift",
          name: "Slow Drift",
          subtitle: "Atmospheric, gentle cinematic motion honoring precious memories",
          emoji: "☁️",
        },
        {
          id: "beat-fade",
          name: "Fade",
          subtitle: "Silky, respectful dissolves aligned to acoustic chords",
          emoji: "🌊",
        },
        {
          id: "sway-ballad",
          name: "Sway",
          subtitle: "Warm, gentle cadence for peaceful melodies",
          emoji: "🍃",
        },
      ]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
        {
          name: "Photo Slideshow Maker",
          path: "/photo-slideshow-maker",
          desc: "Cinematic slideshows with custom music.",
        },
        {
          name: "Anniversary Video Maker",
          path: "/anniversary-video-maker",
          desc: "Celebrate lifelong love stories.",
        },
        {
          name: "Templates Hub",
          path: "/templates",
          desc: "Explore peaceful and gentle motion presets.",
        },
      ]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
