import Link from "next/link";
import { buildPageMetadata, getArticleSchema, getBreadcrumbSchema } from "@/lib/seo";
import SeoFooter from "@/components/layout/SeoFooter";
import { Play, Sparkles, Clock, Calendar, ArrowRight, Zap, Music } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "How to Sync Photos to the Beat of Music Automatically",
  description:
    "Discover how AI audio onset detection and beat mapping algorithms cut photos precisely to kicks, snares, and drops without manual keyframing.",
  path: "/blog/how-to-sync-photos-to-music",
  keywords: [
    "sync photos to music beat",
    "beat sync video maker",
    "audio onset detection video",
    "automatic beat matching photo slideshow",
  ],
});

export default function HowToSyncPhotosToMusicPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Blog", path: "/blog" },
    { name: "How to Sync Photos to Music", path: "/blog/how-to-sync-photos-to-music" },
  ];

  const articleSchema = getArticleSchema({
    title: "How to Sync Photos to the Beat of Music Automatically",
    description:
      "Discover how AI audio onset detection and beat mapping algorithms cut photos precisely to kicks, snares, and drops.",
    path: "/blog/how-to-sync-photos-to-music",
    datePublished: "2026-09-02T00:00:00Z",
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
        <span className="text-amber-300 font-bold">Sync Photos to Music</span>
      </div>

      {/* ARTICLE CONTENT */}
      <article className="w-full max-w-3xl mx-auto px-4 sm:px-6 py-10 space-y-8">
        <header className="space-y-3 border-b border-white/10 pb-6">
          <div className="flex items-center gap-3 text-[11px] font-mono text-white/50">
            <span className="px-2.5 py-0.5 rounded-full bg-amber-400/20 text-amber-300 font-bold border border-amber-400/30">
              TECHNICAL GUIDE
            </span>
            <span className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" /> 6 min read
            </span>
            <span className="flex items-center gap-1">
              <Calendar className="w-3.5 h-3.5" /> September 2026
            </span>
          </div>

          <h1 className="text-3xl sm:text-4xl font-black text-white tracking-tight leading-tight">
            How to Sync Photos to the Beat of Music Automatically
          </h1>

          <p className="text-sm text-amber-100/80 font-medium leading-relaxed">
            Why do some social media reels feel instantly viral while others feel sluggish? The secret is mathematical alignment between visual cuts and audio frequency drops.
          </p>
        </header>

        <div className="space-y-6 text-sm text-white/80 leading-relaxed font-sans">
          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2">
            <Zap className="w-5 h-5 text-amber-400" />
            The Science of Audio Onset Detection
          </h2>
          <p>
            When human brains watch a video with sound, audio-visual synchronization produces an emotional feedback loop known as rhythmic entrainment. In traditional editing, video editors manually zoom into the audio waveform timeline to locate transient peaks — the exact millisecond a kick drum or cymbal strikes.
          </p>
          <p>
            SnapBeat automates this process using spectral flux audio analysis:
          </p>
          <ul className="list-disc pl-5 space-y-2 text-xs text-white/80">
            <li><strong>Onset Peak Filtering:</strong> High-frequency spikes (hi-hats, snares) and low-frequency pulses (sub-bass 808s) are identified.</li>
            <li><strong>BPM Grid Alignment:</strong> Even during quiet musical bridges, transitions align with rhythmic bar markers.</li>
            <li><strong>Dynamic Pacing:</strong> Fast songs trigger snappy rapid cuts (0.3s - 0.6s per image), while ballad melodies apply gentle slow zooms (2.0s - 3.5s per image).</li>
          </ul>

          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2 pt-4">
            <Music className="w-5 h-5 text-amber-400" />
            Selecting the Right Motion Style for Your Track
          </h2>
          <p>
            Different music genres require distinct visual pacing:
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
            <div className="p-4 rounded-2xl bg-black/40 border border-white/10 space-y-1">
              <p className="font-bold text-white text-xs">High-BPM Electronic / Trap</p>
              <p className="text-xs text-white/70">Use <strong>Beat Cut</strong> or <strong>Punch</strong> to slam into beat drops with maximum punch.</p>
            </div>
            <div className="p-4 rounded-2xl bg-black/40 border border-white/10 space-y-1">
              <p className="font-bold text-white text-xs">Emotional / Acoustic Ballads</p>
              <p className="text-xs text-white/70">Use <strong>Slow Drift</strong> or <strong>Fade</strong> to let tender memories breathe organically.</p>
            </div>
          </div>

          {/* CTA BOX */}
          <div className="mt-8 p-6 rounded-3xl bg-gradient-to-r from-amber-500/20 via-amber-400/10 to-amber-500/20 border border-amber-400/40 text-center space-y-4">
            <h3 className="text-lg font-black text-white">Experience Instant AI Beat Matching</h3>
            <p className="text-xs text-amber-100/80 max-w-md mx-auto">
              Upload your photos and sound track to see automated beat synchronization in action.
            </p>
            <Link
              href="/?view=studio"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow-lg hover:scale-105 transition"
            >
              <span>Launch Beat Sync Studio</span>
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
