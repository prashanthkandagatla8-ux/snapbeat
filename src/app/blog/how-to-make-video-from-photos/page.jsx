import Link from "next/link";
import { buildPageMetadata, getArticleSchema, getBreadcrumbSchema } from "@/lib/seo";
import SeoFooter from "@/components/layout/SeoFooter";
import { Play, Sparkles, Clock, Calendar, ArrowRight, CheckCircle2 } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "How to Make a Video from Photos with Music (Step-by-Step)",
  description:
    "Learn how to turn static photos into a beat-synced music video in under 60 seconds using SnapBeat. Step-by-step tutorial on selecting photos, picking soundtracks, and exporting 1080p reels.",
  path: "/blog/how-to-make-video-from-photos",
  keywords: [
    "how to make video from photos",
    "photo to video tutorial",
    "turn pictures into video with music",
    "create photo slideshow online free",
  ],
});

export default function HowToMakeVideoFromPhotosPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Blog", path: "/blog" },
    { name: "How to Make Video from Photos", path: "/blog/how-to-make-video-from-photos" },
  ];

  const articleSchema = getArticleSchema({
    title: "How to Make a Video from Photos with Music (Step-by-Step)",
    description:
      "Learn how to turn static photos into a beat-synced music video in under 60 seconds using SnapBeat.",
    path: "/blog/how-to-make-video-from-photos",
    datePublished: "2026-09-01T00:00:00Z",
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
        <span className="text-amber-300 font-bold">How to Make Video from Photos</span>
      </div>

      {/* ARTICLE CONTENT */}
      <article className="w-full max-w-3xl mx-auto px-4 sm:px-6 py-10 space-y-8">
        <header className="space-y-3 border-b border-white/10 pb-6">
          <div className="flex items-center gap-3 text-[11px] font-mono text-white/50">
            <span className="px-2.5 py-0.5 rounded-full bg-amber-400/20 text-amber-300 font-bold border border-amber-400/30">
              BEGINNER TUTORIAL
            </span>
            <span className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" /> 5 min read
            </span>
            <span className="flex items-center gap-1">
              <Calendar className="w-3.5 h-3.5" /> September 2026
            </span>
          </div>

          <h1 className="text-3xl sm:text-4xl font-black text-white tracking-tight leading-tight">
            How to Make a Video from Photos with Music (Step-by-Step Guide)
          </h1>

          <p className="text-sm text-amber-100/80 font-medium leading-relaxed">
            Creating a high-impact reel from your favorite still memories no longer requires hours of manual timeline editing or complex video software. Here is how to create a professional beat-synced video in 3 quick steps.
          </p>
        </header>

        <div className="space-y-6 text-sm text-white/80 leading-relaxed font-sans">
          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2">
            <span className="w-6 h-6 rounded-full bg-amber-400 text-black font-mono font-bold text-xs flex items-center justify-center">1</span>
            Curate and Upload Your High-Resolution Photos
          </h2>
          <p>
            The secret to a visually compelling reel is variety in framing and perspective. Gather between 4 and 20 photos that tell a chronological or emotional story. Mix wide landscape shots with tight emotional portraits and candid action shots.
          </p>
          <div className="p-4 rounded-2xl bg-black/40 border border-white/10 space-y-2">
            <p className="text-xs font-black text-amber-300 uppercase">Pro Tip for Best Results:</p>
            <p className="text-xs text-white/70">
              Use vertical (9:16) portrait photos when targeting Instagram Reels, TikTok, or YouTube Shorts. SnapBeat's smart frame centering ensures your subjects remain perfectly centered during kinetic pans and zooms.
            </p>
          </div>

          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2 pt-4">
            <span className="w-6 h-6 rounded-full bg-amber-400 text-black font-mono font-bold text-xs flex items-center justify-center">2</span>
            Select Music and Kinetic Camera Choreography
          </h2>
          <p>
            Music sets the emotional heartbeat of your video. In SnapBeat's <strong>Soundtrack Bay</strong>, you can pick from curated royalty-free tracks spanning lo-fi chill, festival anthems, and cinematic beats, or upload your own audio file.
          </p>
          <p>
            Next, select a <strong>Kinetic Motion Preset</strong>. Popular choices include:
          </p>
          <ul className="list-disc pl-5 space-y-2 text-xs text-white/80">
            <li><strong>Beat Cut:</strong> High-energy rapid cuts synchronized with heavy drum beats.</li>
            <li><strong>Pendulum:</strong> Elegant swinging pans with mirrored border reflections.</li>
            <li><strong>Cinematic Zoom:</strong> Optical crash zooms that draw viewers into important focal points.</li>
            <li><strong>Slow Drift:</strong> Atmospheric, gentle motion ideal for romantic or milestone memories.</li>
          </ul>

          <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2 pt-4">
            <span className="w-6 h-6 rounded-full bg-amber-400 text-black font-mono font-bold text-xs flex items-center justify-center">3</span>
            Render on GPU &amp; Export Your Finished Video
          </h2>
          <p>
            Click the master <strong>Render</strong> button. SnapBeat's GPU render cluster processes audio onset waveforms, synchronizes image transition timestamps with rhythm peaks, and renders an MP4 video reel in seconds.
          </p>
          <p>
            Once completed, preview your video with instant playback and click <strong>Download Reel MP4</strong> to share on Instagram, WhatsApp status, or YouTube Shorts!
          </p>

          {/* CTA BOX */}
          <div className="mt-8 p-6 rounded-3xl bg-gradient-to-r from-amber-500/20 via-amber-400/10 to-amber-500/20 border border-amber-400/40 text-center space-y-4">
            <h3 className="text-lg font-black text-white">Ready to Turn Your Photos into Video?</h3>
            <p className="text-xs text-amber-100/80 max-w-md mx-auto">
              No registration or credit card required. Experience 100% free unlimited renders on SnapBeat today.
            </p>
            <Link
              href="/?view=studio"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow-lg hover:scale-105 transition"
            >
              <span>Create Your Video Free</span>
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
