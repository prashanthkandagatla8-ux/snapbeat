import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Party Video Maker with Music | Celebration Photo Reels",
  description:
    "Make high-energy party and celebration videos from photos with music. Instant beat-synced cuts, kinetic party transitions, and 1080p MP4 exports for social media.",
  path: "/party-video-maker",
  keywords: [
    "party video maker",
    "celebration video maker with music",
    "party photo slideshow",
    "club party reel maker",
    "night out video maker from photos",
  ],
});

export default function PartyVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Party Video Maker", path: "/party-video-maker" },
  ];

  const howItWorks = [
    {
      step: "01",
      title: "Upload Party Photos",
      desc: "Add between 2 and 20 photos from your night out, birthday bash, or weekend party into the sequence bay.",
    },
    {
      step: "02",
      title: "Pick an Upbeat Soundtrack",
      desc: "Select high-energy dance, nu-funk, or electronic tracks, or upload your favorite party anthem.",
    },
    {
      step: "03",
      title: "Export Beat-Synced Reel",
      desc: "Our GPU cluster detects bass drops and kicks, cutting transitions in perfect rhythmic synchronization.",
    },
  ];

  const benefits = [
    {
      title: "Automated AI Beat Detection",
      desc: "No manual timeline trimming. Cuts snap to kick drums, bass drops, and energetic party rhythms.",
    },
    {
      title: "High-Impact Kinetic Styles",
      desc: "Punch cuts, bassline bounces, and rapid beat drops designed specifically for party atmospheres.",
    },
    {
      title: "Vertical 9:16 Social Layout",
      desc: "Ready to share directly to Instagram Stories, TikTok, and WhatsApp status without cropping headaches.",
    },
    {
      title: "Instant 1-Click Guest Access",
      desc: "No sign-up wall. Jump right into the workstation and export your party video in seconds.",
    },
    {
      title: "High-Speed Cloud Renders",
      desc: "Fast sub-minute video encoding on GPU clusters for immediate party recap sharing.",
    },
    {
      title: "Free Unlimited Creation",
      desc: "Enjoy 100% free unlimited video renders during our open public beta period.",
    },
  ];

  const faqs = [
    {
      question: "What music works best for party videos?",
      answer:
        "High-energy electronic, house, trap, and nu-funk tracks with pronounced drum drops produce the most exciting party reels.",
    },
    {
      question: "Can I add photos taken in low light?",
      answer:
        "Yes! SnapBeat preserves the vibrant colors, neon glows, and ambient lighting of party photography without degrading resolution.",
    },
    {
      question: "Can I trim the audio to the best drop?",
      answer:
        "Yes, our visual audio tape deck waveform lets you scrub and select the exact high-energy chorus or drop point.",
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
      title="Party Video Maker with Music | Celebration Photo Reels"
      h1="Party Video Maker with Music"
      tagline="HIGH-ENERGY CELEBRATION REELS IN SECONDS"
      valueProposition="Turn your party snapshots and night-out photo dumps into pulse-pounding video reels. SnapBeat automatically synchronizes cuts to bass drops, snare hits, and party beats with zero video editing experience required."
      primaryCtaText="Create Your Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
        {
          id: "punch-cut",
          name: "Punch",
          subtitle: "High-impact kinetic punches slamming into party drops",
          emoji: "🥊",
        },
        {
          id: "beat-cut",
          name: "Beat Cut",
          subtitle: "Snappy rapid cuts aligned to dance beats",
          emoji: "⚡",
        },
        {
          id: "beat-bounce",
          name: "Bounce",
          subtitle: "Kinetic bassline scale bounces",
          emoji: "🏀",
        },
      ]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
        {
          name: "Birthday Video Maker",
          path: "/birthday-video-maker",
          desc: "Birthday celebration photo slideshows.",
        },
        {
          name: "Friendship Video Maker",
          path: "/friendship-video-maker",
          desc: "Fun photo reels with best friends.",
        },
        {
          name: "Instagram Reel Maker",
          path: "/instagram-reel-maker",
          desc: "Reels optimized for Instagram feed.",
        },
      ]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
