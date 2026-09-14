import Link from "next/link";
import { buildPageMetadata, getArticleSchema, getBreadcrumbSchema } from "@/lib/seo";
import SeoFooter from "@/components/layout/SeoFooter";
import { Play, Sparkles, Clock, Calendar, ArrowRight, Heart, Plane, Gift } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "Top 10 Photo Reel Ideas for Birthdays, Travel & Celebrations",
  description:
    "Explore 10 creative concepts and themes to transform everyday photos into viral short-form reels for Instagram, TikTok, and milestone memories.",
  path: "/blog/best-photo-reel-ideas",
  keywords: [
    "photo reel ideas",
    "instagram reel ideas with photos",
    "birthday photo video ideas",
    "travel reel concepts",
  ],
});

export default function BestPhotoReelIdeasPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Blog", path: "/blog" },
    { name: "Top Photo Reel Ideas", path: "/blog/best-photo-reel-ideas" },
  ];

  const articleSchema = getArticleSchema({
    title: "Top 10 Photo Reel Ideas for Birthdays, Travel & Celebrations",
    description:
      "Explore 10 creative concepts and themes to transform everyday photos into viral short-form reels.",
    path: "/blog/best-photo-reel-ideas",
    datePublished: "2026-09-03T00:00:00Z",
    dateModified: "2026-09-14T00:00:00Z",
  });

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [getBreadcrumbSchema(breadcrumbs), articleSchema],
  };

  return (
    <div className="min-h-screen w-full bg-[#0c0d10] text-[#f1f1f1] flex flex-col items-center select-none overflow-x-hidden">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(schemaJsonLd) }}
      />

      {/* HEADER */}
      <header className="w-full max-w-4xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between border-b border-white/10 z-20">
        <Link href="/" className="flex items-center gap-2.5">
          <img
            src="/assets/images/snapbeat_logo_3d.png"
            alt="SnapBeat"
            className="h-8 w-auto object-contain drop-shadow"
          />
        </Link>
        <Link
          href="/?view=studio"
          className="px-4 py-2 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow hover:scale-105 transition flex items-center gap-1.5"
        >
          <Play className="w-3.5 h-3.5 fill-current" />
          <span>Open Studio</span>
        </Link>
      </header>

      {/* BREADCRUMBS */}
      <div className="w-full max-w-4xl mx-auto px-4 sm:px-6 pt-4 text-[11px] font-mono text-white/50 flex items-center gap-1.5 flex-wrap">
        <Link href="/" className="hover:text-amber-300 transition">
          Home
        </Link>
        <span>/</span>
        <Link href="/blog" className="hover:text-amber-300 transition">
          Guides
        </Link>
        <span>/</span>
        <span className="text-amber-300 font-bold">Top Photo Reel Ideas</span>
      </div>

      {/* ARTICLE CONTENT */}
      <article className="w-full max-w-3xl mx-auto px-4 sm:px-6 py-10 space-y-8">
        <header className="space-y-3 border-b border-white/10 pb-6">
          <div className="flex items-center gap-3 text-[11px] font-mono text-white/50">
            <span className="px-2.5 py-0.5 rounded-full bg-amber-400/20 text-amber-300 font-bold border border-amber-400/30">
              INSPIRATION
            </span>
            <span className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" /> 7 min read
            </span>
            <span className="flex items-center gap-1">
              <Calendar className="w-3.5 h-3.5" /> September 2026
            </span>
          </div>

          <h1 className="text-3xl sm:text-4xl font-black text-white tracking-tight leading-tight">
            Top 10 Photo Reel Ideas for Birthdays, Travel &amp; Celebrations
          </h1>

          <p className="text-sm text-amber-100/80 font-medium leading-relaxed">
            Stuck on how to assemble your camera roll photos into an engaging reel? Here are our top creative formulas that consistently capture viewer attention.
          </p>
        </header>

        <div className="space-y-6 text-sm text-white/80 leading-relaxed font-sans">
          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2">
            <Plane className="w-5 h-5 text-amber-400" />
            1. The "24 Hours In..." Rapid Vacation Montage
          </h2>
          <p>
            Instead of a slow chronological recap, group photos by color palette or sensory moments: boarding pass, airplane wing, coffee cup, golden hour street, and nighttime skyline. Match this with an upbeat nu-funk or electronic beat.
          </p>

          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2 pt-3">
            <Gift className="w-5 h-5 text-amber-400" />
            2. The Birthday Tribute "Throwback to Present"
          </h2>
          <p>
            Start with vintage childhood photos and gradually transition toward recent celebrations. SnapBeat's <strong>Pendulum</strong> or <strong>Cinematic Zoom</strong> template creates a nostalgic rhythm that emphasizes growth and shared memories.
          </p>

          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2 pt-3">
            <Heart className="w-5 h-5 text-amber-400" />
            3. Romantic Anniversary &amp; Wedding Milestones
          </h2>
          <p>
            Combine engagement portraits with intimate unposed candid shots. Pair with a warm acoustic or lo-fi soundtrack using SnapBeat's <strong>Slow Drift</strong> kinetic preset for a dreamy, cinematic atmosphere.
          </p>

          {/* CTA BOX */}
          <div className="mt-8 p-6 rounded-3xl bg-gradient-to-r from-amber-500/20 via-amber-400/10 to-amber-500/20 border border-amber-400/40 text-center space-y-4">
            <h3 className="text-lg font-black text-white">Create Your Next Viral Reel in Seconds</h3>
            <p className="text-xs text-amber-100/80 max-w-md mx-auto">
              Choose your photos, pick a soundtrack, and let SnapBeat choreograph the motion automatically.
            </p>
            <Link
              href="/?view=studio"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow-lg hover:scale-105 transition"
            >
              <span>Start Making Reels Free</span>
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </article>

      {/* FOOTER */}
      <SeoFooter className="w-full" />
    </div>
  );
}
