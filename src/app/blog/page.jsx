import Link from "next/link";
import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema } from "@/lib/seo";
import SeoFooter from "@/components/layout/SeoFooter";
import { Sparkles, BookOpen, Clock, ArrowRight, Play } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "Reel Creation Guides & Video Tutorials",
  description:
    "Master the art of beat-synced photo slideshows and Instagram reels. Expert tutorials on rhythm matching, photography selection, and kinetic motion.",
  path: "/blog",
  keywords: [
    "photo video tutorials",
    "how to make video from photos",
    "photo reel ideas",
    "sync photos to beat",
    "instagram reel guide",
  ],
});

export default function BlogHubPage() {
  const articles = [
    {
      slug: "how-to-make-video-from-photos",
      title: "How to Make a Video from Photos with Music (Step-by-Step)",
      excerpt:
        "Learn the simplest way to turn your smartphone and camera photos into a high-energy video reel synchronized with your favorite soundtrack.",
      date: "September 2026",
      readTime: "5 min read",
      category: "Beginner Guide",
    },
    {
      slug: "how-to-sync-photos-to-music",
      title: "How to Sync Photos to the Beat of Music Automatically",
      excerpt:
        "Discover how audio onset detection and beat-mapping algorithms cut images perfectly on snare hits, kicks, and drop points.",
      date: "September 2026",
      readTime: "6 min read",
      category: "Audio Sync",
    },
    {
      slug: "best-photo-reel-ideas",
      title: "Top 10 Photo Reel Ideas for Birthdays, Travel & Celebrations",
      excerpt:
        "Creative themes, sequencing tips, and music recommendations to make your memories stand out on Instagram, TikTok, and YouTube Shorts.",
      date: "September 2026",
      readTime: "7 min read",
      category: "Inspiration",
    },
  ];

  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Guides & Blog", path: "/blog" },
  ];

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      getWebApplicationSchema(),
      getBreadcrumbSchema(breadcrumbs),
      {
        "@type": "Blog",
        name: "SnapBeat Guides & Video Tutorials",
        url: "https://www.snapbeat.app/blog",
        description: "Tutorials, workflows, and creative guides for beat-synced photo-to-video reels.",
      },
    ],
  };

  return (
    <div className="min-h-screen w-full bg-[#0c0d10] text-[#f1f1f1] flex flex-col items-center select-none overflow-x-hidden">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(schemaJsonLd) }}
      />

      {/* HEADER */}
      <header className="w-full max-w-6xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between border-b border-white/10 z-20">
        <Link href="/" className="flex items-center gap-2.5">
          <img
            src="/assets/images/snapbeat_logo_3d.png"
            alt="SnapBeat"
            className="h-8 sm:h-9 w-auto object-contain drop-shadow"
          />
          <span className="hidden sm:inline-block px-2 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] text-[9px] font-black uppercase tracking-wider shadow">
            BETA
          </span>
        </Link>

        <nav className="flex items-center gap-3 sm:gap-6 text-xs font-black">
          <Link href="/templates" className="hover:text-amber-300 transition hidden sm:inline-block">
            Templates
          </Link>
          <Link
            href="/?view=studio"
            className="px-4 py-2 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow hover:scale-105 active:scale-95 transition flex items-center gap-1.5"
          >
            <Play className="w-3.5 h-3.5 fill-current" />
            <span>Open Studio</span>
          </Link>
        </nav>
      </header>

      {/* BREADCRUMBS */}
      <div className="w-full max-w-6xl mx-auto px-4 sm:px-6 pt-4 text-[11px] font-mono text-white/50 flex items-center gap-1.5 flex-wrap">
        <Link href="/" className="hover:text-amber-300 transition">
          Home
        </Link>
        <span>/</span>
        <span className="text-amber-300 font-bold">Guides &amp; Tutorials</span>
      </div>

      {/* HERO */}
      <main className="w-full max-w-5xl mx-auto px-4 sm:px-6 pt-10 sm:pt-16 pb-8 flex flex-col items-center text-center space-y-4">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/15 border border-amber-400/30 text-amber-300 text-[10px] font-mono font-black uppercase tracking-widest">
          <BookOpen className="w-3.5 h-3.5" />
          <span>CREATOR ACADEMY</span>
        </div>

        <h1 className="text-3xl sm:text-5xl font-black text-white tracking-tight max-w-3xl leading-tight">
          SnapBeat Creator Guides &amp; Video Tutorials
        </h1>

        <p className="text-sm sm:text-base text-amber-100/70 max-w-2xl font-medium leading-relaxed">
          Master the fundamentals of audio onset detection, kinetic camera choreography, and short-form storytelling.
        </p>
      </main>

      {/* ARTICLE CARDS */}
      <section className="w-full max-w-5xl mx-auto px-4 sm:px-6 py-10">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {articles.map((art) => (
            <Link
              key={art.slug}
              href={`/blog/${art.slug}`}
              className="sky-glass-panel rounded-3xl p-6 border border-white/10 hover:border-amber-400/40 transition-all flex flex-col justify-between shadow-xl group cursor-pointer"
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between text-[10px] font-mono text-white/50">
                  <span className="px-2 py-0.5 rounded-full bg-amber-400/20 text-amber-300 font-bold border border-amber-400/30">
                    {art.category}
                  </span>
                  <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3" /> {art.readTime}
                  </span>
                </div>

                <h2 className="text-lg font-black text-white tracking-tight group-hover:text-amber-300 transition leading-snug">
                  {art.title}
                </h2>

                <p className="text-xs text-amber-100/70 font-medium leading-relaxed">
                  {art.excerpt}
                </p>
              </div>

              <div className="pt-6 mt-4 flex items-center justify-between text-xs font-bold text-amber-300 border-t border-white/10">
                <span>Read Full Guide</span>
                <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition" />
              </div>
            </Link>
          ))}
        </div>
      </section>

      {/* FOOTER */}
      <SeoFooter className="w-full" />
    </div>
  );
}
