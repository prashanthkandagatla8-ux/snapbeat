import Link from "next/link";
import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema } from "@/lib/seo";
import { TEMPLATES } from "@/lib/constants";
import SeoFooter from "@/components/layout/SeoFooter";
import { Play, Sparkles, Film, ArrowRight, Layers, Smartphone, Monitor, Square } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "14+ Kinetic Photo Video Templates & Motion Styles",
  description:
    "Explore SnapBeat's collection of 14 AI-driven kinetic photo video templates. From snappy beat cuts to cinematic drifts, pendulum mirrors, and glitch zooms.",
  path: "/templates",
  keywords: [
    "photo video templates",
    "beat sync video templates",
    "reel templates",
    "photo slideshow effects",
    "kinetic video transitions",
    "instagram reel templates",
  ],
});

export default function TemplatesPage() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Templates Hub", path: "/templates" },
  ];

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      getWebApplicationSchema(),
      getBreadcrumbSchema(breadcrumbs),
      {
        "@type": "CollectionPage",
        name: "SnapBeat Kinetic Video Templates Hub",
        url: "https://www.snapbeat.app/templates",
        description: "Browse 14+ automated AI kinetic video templates designed for beat-synced photo slideshows.",
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
          <Link href="/blog" className="hover:text-amber-300 transition hidden sm:inline-block">
            Guides
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
        <span className="text-amber-300 font-bold">Templates Hub</span>
      </div>

      {/* HERO */}
      <main className="w-full max-w-5xl mx-auto px-4 sm:px-6 pt-10 sm:pt-16 pb-8 flex flex-col items-center text-center space-y-4">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/15 border border-amber-400/30 text-amber-300 text-[10px] font-mono font-black uppercase tracking-widest">
          <Sparkles className="w-3.5 h-3.5" />
          <span>CAMERA CHOREOGRAPHY LIBRARY</span>
        </div>

        <h1 className="text-3xl sm:text-5xl font-black text-white tracking-tight max-w-3xl leading-tight">
          14+ Kinetic Motion Templates for Every Music Genre
        </h1>

        <p className="text-sm sm:text-base text-amber-100/70 max-w-2xl font-medium leading-relaxed">
          SnapBeat analyzes your song's acoustic drop points, snares, and BPM to trigger camera zooms, whip pans, and mirrored pendulum cuts with zero manual keyframing.
        </p>

        <div className="flex items-center gap-4 pt-2">
          <Link
            href="/?view=studio"
            className="px-6 py-3 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black tracking-wider uppercase shadow-xl hover:scale-105 active:scale-95 transition flex items-center gap-2"
          >
            <span>START CREATING NOW</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </main>

      {/* TEMPLATE GRID */}
      <section className="w-full max-w-6xl mx-auto px-4 sm:px-6 py-10">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {TEMPLATES.map((tmpl) => (
            <div
              key={tmpl.id}
              className="sky-glass-panel rounded-3xl p-6 border border-white/10 hover:border-amber-400/40 transition-all group flex flex-col justify-between shadow-xl"
            >
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-3xl p-2 rounded-2xl bg-white/5 border border-white/10">
                    {tmpl.emoji}
                  </span>
                  <span
                    className={`px-2.5 py-0.5 rounded-full text-[9px] font-mono font-bold uppercase tracking-wider ${
                      tmpl.isPro
                        ? "bg-amber-400/20 text-amber-300 border border-amber-400/40"
                        : "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
                    }`}
                  >
                    {tmpl.isPro ? "PRO MOTION" : "FREE MOTION"}
                  </span>
                </div>

                <div>
                  <h2 className="text-xl font-black text-white tracking-tight group-hover:text-amber-300 transition">
                    {tmpl.name}
                  </h2>
                  <p className="text-xs text-amber-100/70 mt-1 font-medium leading-relaxed">
                    {tmpl.subtitle}
                  </p>
                </div>

                <div className="flex items-center gap-3 pt-2 text-[10px] font-mono text-white/50 border-t border-white/10">
                  <span className="flex items-center gap-1">
                    <Smartphone className="w-3 h-3 text-amber-300" /> 9:16 Reel
                  </span>
                  <span className="flex items-center gap-1">
                    <Square className="w-3 h-3 text-amber-300" /> 1:1 Post
                  </span>
                  <span className="flex items-center gap-1">
                    <Monitor className="w-3 h-3 text-amber-300" /> 16:9 Landscape
                  </span>
                </div>
              </div>

              <div className="pt-6 mt-4">
                <Link
                  href={`/?view=studio&template=${tmpl.id}`}
                  className="w-full py-2.5 rounded-2xl bg-white/10 hover:bg-amber-400 hover:text-[#261b02] text-white text-xs font-black uppercase tracking-wider transition-all flex items-center justify-center gap-2 border border-white/10"
                >
                  <Play className="w-3.5 h-3.5 fill-current" />
                  <span>Use This Style</span>
                </Link>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* SEO FOOTER */}
      <SeoFooter className="w-full" />
    </div>
  );
}
