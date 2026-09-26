import Link from "next/link";
import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema } from "@/lib/seo";
import SeoFooter from "@/components/layout/SeoFooter";
import { Clock, Play, BookOpen } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "10 Cinematic Photo Sequencing Techniques for Slideshows | SnapBeat",
  description: "Learn how to arrange photos to tell a compelling story using narrative arcs, match cutting, visual rhymes, and focal point anchoring.",
  path: "/blog/cinematic-photo-sequencing-techniques",
  keywords: ["photo sequencing", "cinematic slideshows", "narrative arc", "match cutting", "visual rhymes", "photo editing techniques"],
});

export default function BlogPost() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Guides & Blog", path: "/blog" },
    { name: "Cinematic Photo Sequencing", path: "/blog/cinematic-photo-sequencing-techniques" },
  ];

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      getWebApplicationSchema(),
      getBreadcrumbSchema(breadcrumbs),
      {
        "@type": "Article",
        headline: "10 Cinematic Photo Sequencing Techniques for High-Impact Slideshows",
        datePublished: "2026-09-26T00:00:00+00:00",
        dateModified: "2026-09-26T00:00:00+00:00",
        author: { "@type": "Organization", name: "SnapBeat Editorial Team" },
        publisher: {
          "@type": "Organization",
          name: "SnapBeat",
          logo: { "@type": "ImageObject", url: "https://www.snapbeat.app/assets/images/snapbeat_logo_3d.png" }
        },
        description: "Arrange photos to tell a compelling story using narrative arcs, match cutting, visual rhymes, and focal point anchoring.",
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
          <img src="/assets/images/snapbeat_logo_3d.png" alt="SnapBeat" className="h-8 sm:h-9 w-auto object-contain drop-shadow" />
          <span className="hidden sm:inline-block px-2 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] text-[9px] font-black uppercase tracking-wider shadow">STUDIO</span>
        </Link>
        <nav className="flex items-center gap-3 sm:gap-6 text-xs font-black">
          <Link href="/blog" className="hover:text-amber-300 transition hidden sm:inline-block">All Guides</Link>
          <Link href="/?view=studio" className="px-4 py-2 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow hover:scale-105 active:scale-95 transition flex items-center gap-1.5">
            <Play className="w-3.5 h-3.5 fill-current" />
            <span>Open Studio</span>
          </Link>
        </nav>
      </header>

      {/* BREADCRUMBS */}
      <div className="w-full max-w-3xl mx-auto px-4 sm:px-6 pt-4 text-[11px] font-mono text-white/50 flex items-center gap-1.5 flex-wrap">
        <Link href="/" className="hover:text-amber-300 transition">Home</Link>
        <span>/</span>
        <Link href="/blog" className="hover:text-amber-300 transition">Guides &amp; Tutorials</Link>
        <span>/</span>
        <span className="text-amber-300 font-bold">Cinematic Sequencing</span>
      </div>

      <main className="w-full max-w-3xl mx-auto px-4 sm:px-6 pt-10 sm:pt-16 pb-20">
        <article className="prose prose-invert prose-amber max-w-none">
          <div className="flex items-center gap-4 mb-8 text-xs font-mono text-white/50">
            <span className="px-2 py-1 rounded-full bg-amber-400/20 text-amber-300 font-bold border border-amber-400/30">Creative Workflows</span>
            <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" /> 7 min read</span>
            <span>Updated: Sep 2026</span>
          </div>

          <h1 className="text-3xl sm:text-5xl font-black text-white tracking-tight leading-tight mb-8">
            10 Cinematic Photo Sequencing Techniques for High-Impact Slideshows
          </h1>

          <p className="lead text-lg text-amber-100/80 font-medium">
            Throwing a bunch of photos onto a timeline and adding music is easy. Arranging them to tell a visceral, emotional story requires technique. Let's explore ten cinematic editing principles derived from filmmaking to elevate your reels.
          </p>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">1. Narrative Arcs in 30 Seconds</h2>
          <p>
            Even a short Reel needs a three-act structure.
          </p>
          <ul>
            <li><strong>Act 1: The Hook (0-3s):</strong> Start with an intriguing, dynamic, or high-contrast image. Place a text overlay that sets up a question or context.</li>
            <li><strong>Act 2: Escalation (3-20s):</strong> Build energy by steadily increasing the speed of the cuts. Move from wide establishing shots to medium shots.</li>
            <li><strong>Act 3: Resolution & Payoff (20-30s):</strong> The grand finale. Show the climactic moment (the kiss, the sunset, the jump). Slow the pacing down to let the final image breathe.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">2. Match Cutting & Visual Rhymes</h2>
          <p>
            Match cutting involves transitioning between two photos that share similar graphical compositions, shapes, or movements. 
          </p>
          <div className="bg-white/5 border border-amber-400/30 p-6 rounded-2xl my-8">
            <h3 className="text-amber-300 font-bold mt-0 mb-3 text-lg flex items-center gap-2">
              <BookOpen className="w-5 h-5" /> Examples of Visual Rhymes:
            </h3>
            <ul className="m-0 space-y-2 text-sm">
              <li>Cutting from a round pizza to a round bicycle wheel.</li>
              <li>Cutting from a subject jumping in the air at the beach, to the same subject mid-jump in the mountains.</li>
              <li>Aligning the horizon line perfectly across three consecutive landscape photos.</li>
            </ul>
          </div>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">3. Focal Point Anchoring</h2>
          <p>
            When cycling through photos quickly (e.g., 4 photos per second), the viewer's eye doesn't have time to scan the frame. <strong>Focal Point Anchoring</strong> is the practice of ensuring the primary subject (like a person's face) remains in the exact same location on the screen from one photo to the next.
          </p>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">4. Tempo Acceleration</h2>
          <p>
            Aligning your image durations with rising musical intensity is critical. As the EDM track builds up, your photos should flash faster. When the bass drops, transition to a slow-motion video clip or hold on a single powerful, high-contrast photo for maximum impact.
          </p>
          
          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">Common Mistakes to Avoid</h2>
          <div className="overflow-x-auto my-8">
            <table className="w-full text-sm text-left border-collapse">
              <thead>
                <tr className="bg-white/10 text-amber-300">
                  <th className="p-3 border border-white/20">Mistake</th>
                  <th className="p-3 border border-white/20">Why it fails</th>
                  <th className="p-3 border border-white/20">The Fix</th>
                </tr>
              </thead>
              <tbody className="text-white/80">
                <tr>
                  <td className="p-3 border border-white/20">Random Pacing</td>
                  <td className="p-3 border border-white/20">Creates a chaotic, disconnected feeling.</td>
                  <td className="p-3 border border-white/20">Sync strictly to the music's BPM using beat detection.</td>
                </tr>
                <tr>
                  <td className="p-3 border border-white/20">Too Many Group Shots</td>
                  <td className="p-3 border border-white/20">Hard to parse quickly on mobile screens.</td>
                  <td className="p-3 border border-white/20">Mix wide establishing shots with extreme close-ups (macro).</td>
                </tr>
                <tr>
                  <td className="p-3 border border-white/20">Overusing Crossfades</td>
                  <td className="p-3 border border-white/20">Feels dated, like a 1990s PowerPoint.</td>
                  <td className="p-3 border border-white/20">Use hard cuts on the beat, or fast directional wipes.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </article>
      </main>
      <SeoFooter className="w-full" />
    </div>
  );
}
