import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Friendship Photo Video Maker | Best Friends Reel Maker",
  description:
    "Create heartwarming friendship photo videos and best friend reels with music. Sync graduation, college, and best friend memories into beat-synced video reels for free.",
  path: "/friendship-video-maker",
  keywords: [
    "friendship video maker",
    "best friends photo video with song",
    "friendship day reel maker",
    "friends photo slideshow with music",
    "college memories video maker",
  ],
});

export default function FriendshipVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Friendship Video Maker", path: "/friendship-video-maker" },
  ];

  const howItWorks = [
    {
      step: "01",
      title: "Upload Friends Photos",
      desc: "Gather between 2 and 20 photos of your best friends, college days, road trips, and fun adventures.",
    },
    {
      step: "02",
      title: "Pick an Anthem or Melody",
      desc: "Choose an upbeat celebration song or upload your friend group's favorite track with easy audio trimming.",
    },
    {
      step: "03",
      title: "Export & Share Instantly",
      desc: "Our AI engine synchronizes transitions with the rhythm and delivers a polished MP4 reel in seconds.",
    },
  ];

  const benefits = [
    {
      title: "Automated AI Beat Detection",
      desc: "Transitions snap smoothly to song drops and acoustic beats without complicated video editing.",
    },
    {
      title: "14 Kinetic Motion Presets",
      desc: "From upbeat bounces and rapid beat cuts to nostalgic slow drifts and mirrored pendulum swings.",
    },
    {
      title: "Native Vertical 9:16 Format",
      desc: "Optimized for Instagram Stories, WhatsApp status, and TikTok reels to surprise your friends.",
    },
    {
      title: "Instant 1-Click Guest Access",
      desc: "Create and download videos right away with zero sign-up friction.",
    },
    {
      title: "High-Speed Cloud Encoding",
      desc: "Sub-minute video processing on dedicated cloud GPUs for immediate sharing.",
    },
    {
      title: "100% Free Unlimited Creation",
      desc: "Make as many friend tributes and celebration reels as you like with instant guest access.",
    },
  ];

  const faqs = [
    {
      question: "How can I make a best friends throwback reel?",
      answer:
        "Upload a sequence starting with childhood or early college memories leading up to your recent adventures. Use our visual Photo Bay to order them chronologically.",
    },
    {
      question: "Can I use popular friendship songs?",
      answer:
        "Yes, you can upload any MP3 or audio file from your device, or pick from our curated collection of upbeat and emotional tracks.",
    },
    {
      question: "Is it easy to share directly with my friends on WhatsApp?",
      answer:
        "Yes! SnapBeat exports standard MP4 video files that can be sent directly over WhatsApp, Telegram, or posted to social feeds.",
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
      title="Friendship Photo Video Maker | Best Friends Reel Maker"
      h1="Friendship Photo Video Maker with Music"
      tagline="CELEBRATE YOUR BEST FRIENDS IN MOTION"
      valueProposition="Celebrate your unforgettable friendship memories. SnapBeat turns spontaneous selfies, road trip snapshots, and shared laughs into a dynamic, rhythmically synchronized tribute video for your best friends."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
        {
          id: "pendulum",
          name: "Pendulum",
          subtitle: "Elegant mirrored swings honoring shared years of friendship",
          emoji: "🪞",
        },
        {
          id: "cinematic-zoom",
          name: "Cinematic Zoom",
          subtitle: "Optical zooms spotlighting candid smiles and memories",
          emoji: "🎬",
        },
        {
          id: "beat-cut",
          name: "Beat Cut",
          subtitle: "Fast upbeat cuts for party and adventure moments",
          emoji: "⚡",
        },
      ]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
        {
          name: "Party Video Maker",
          path: "/party-video-maker",
          desc: "High-energy celebration reels.",
        },
        {
          name: "Birthday Video Maker",
          path: "/birthday-video-maker",
          desc: "Birthday tributes for your best friends.",
        },
        {
          name: "Travel Reel Maker",
          path: "/travel-reel-maker",
          desc: "Vacation and trip montages with friends.",
        },
      ]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
