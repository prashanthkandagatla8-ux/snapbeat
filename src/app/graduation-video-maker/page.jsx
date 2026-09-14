import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema, getFaqSchema } from "@/lib/seo";
import SeoLandingPage from "@/components/seo/SeoLandingPage";

export const metadata = buildPageMetadata({
  title: "Graduation Photo Video Maker with Music | Cap & Gown Reels",
  description:
    "Celebrate academic milestones with a graduation photo video maker. Turn high school, college, and university memories into celebratory beat-synced reels for free.",
  path: "/graduation-video-maker",
  keywords: [
    "graduation video maker",
    "graduation slideshow with music",
    "senior photo video maker",
    "college graduation reel maker",
    "graduation photo montage online",
  ],
});

export default function GraduationVideoMakerPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Graduation Video Maker", path: "/graduation-video-maker" },
  ];

  const howItWorks = [
    {
      step: "01",
      title: "Upload Graduation Photos",
      desc: "Add between 2 and 20 photos of cap and gown portraits, campus memories, study sessions, and commencement ceremony smiles.",
    },
    {
      step: "02",
      title: "Choose an Anthem",
      desc: "Select an uplifting celebratory soundtrack or upload your class song with precision audio trimming.",
    },
    {
      step: "03",
      title: "Export & Celebrate",
      desc: "Our AI engine synchronizes transitions with the musical beat, creating a vibrant video reel ready for social media.",
    },
  ];

  const benefits = [
    {
      title: "Automated AI Beat Synchronization",
      desc: "Transitions snap to inspirational orchestral swells and upbeat drum drops automatically.",
    },
    {
      title: "14 Kinetic Motion Styles",
      desc: "From triumphant optical zooms to energetic bounces, rapid cuts, and mirrored pendulum pans.",
    },
    {
      title: "Native 9:16 Vertical Video",
      desc: "Tailored for Instagram Stories, TikTok, and family sharing over WhatsApp and iMessage.",
    },
    {
      title: "Instant 1-Click Guest Access",
      desc: "Jump straight into creation without sign-up barriers or payment friction.",
    },
    {
      title: "Fast Cloud GPU Rendering",
      desc: "Sub-minute encoding delivers your graduation recap video while the celebration is still underway.",
    },
    {
      title: "Free Unlimited Creation",
      desc: "Make as many tribute videos for classmates, friends, and family as you need.",
    },
  ];

  const faqs = [
    {
      question: "How can I make a senior year retrospective reel?",
      answer:
        "Sequence your photos chronologically from freshman year move-in to senior commencement. Pair it with an uplifting anthem using our visual tape deck.",
    },
    {
      question: "Can I use school or university fight songs?",
      answer:
        "Yes, upload any MP3 or audio file from your device and easily trim it to the celebration climax.",
    },
    {
      question: "Can I export in landscape for graduation parties?",
      answer:
        "Yes! SnapBeat supports 16:9 Landscape format, perfect for projecting onto large screens during graduation dinner parties.",
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
      title="Graduation Photo Video Maker with Music | Cap & Gown Reels"
      h1="Graduation Photo Video Maker with Music"
      tagline="COMMEMORATE ACADEMIC MILESTONES IN MOTION"
      valueProposition="Honor years of hard work, lifelong friendships, and academic triumph. SnapBeat transforms cap-and-gown portraits and campus memories into an inspiring, beat-synced celebration video in seconds."
      primaryCtaText="Create Your Graduation Video Free"
      ctaUrl="/?view=studio"
      breadcrumbs={breadcrumbs}
      howItWorks={howItWorks}
      recommendedTemplates={[
        {
          id: "cinematic-zoom",
          name: "Cinematic Zoom",
          subtitle: "Optical zooms spotlighting diploma handshakes and cap tosses",
          emoji: "🎬",
        },
        {
          id: "beat-cut",
          name: "Beat Cut",
          subtitle: "Snappy upbeat cuts highlighting campus life and friendships",
          emoji: "⚡",
        },
        {
          id: "pendulum",
          name: "Pendulum",
          subtitle: "Elegant mirrored cuts honoring years of growth",
          emoji: "🪞",
        },
      ]}
      benefits={benefits}
      faqs={faqs}
      relatedPages={[
        {
          name: "Friendship Video Maker",
          path: "/friendship-video-maker",
          desc: "Tribute reels with college and high school friends.",
        },
        {
          name: "Party Video Maker",
          path: "/party-video-maker",
          desc: "Graduation party celebration reels.",
        },
        {
          name: "Photo to Video Maker",
          path: "/photo-to-video",
          desc: "Convert photo memories into beat-synced video.",
        },
      ]}
      schemaJsonLd={schemaJsonLd}
    />
  );
}
