import Link from "next/link";
import { buildPageMetadata, getWebApplicationSchema, getBreadcrumbSchema } from "@/lib/seo";
import SeoFooter from "@/components/layout/SeoFooter";
import { Clock, Play, BookOpen } from "lucide-react";

export const metadata = buildPageMetadata({
  title: "Ultimate Guide to Instagram Reels Aspect Ratios & Video Dimensions (2026 Edition) | SnapBeat",
  description: "Learn the optimal Instagram Reels aspect ratios, video dimensions, UI safe zones, and compression algorithms to avoid blurriness in 2026.",
  path: "/blog/ultimate-guide-to-instagram-reels-aspect-ratios",
  keywords: ["instagram reels aspect ratio", "reels video dimensions", "instagram safe zones", "video compression", "reels 9:16", "reels resolution"],
});

export default function BlogPost() {
  const breadcrumbs = [
    { name: "Home", path: "/" },
    { name: "Guides & Blog", path: "/blog" },
    { name: "Instagram Reels Aspect Ratios", path: "/blog/ultimate-guide-to-instagram-reels-aspect-ratios" },
  ];

  const schemaJsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      getWebApplicationSchema(),
      getBreadcrumbSchema(breadcrumbs),
      {
        "@type": "Article",
        headline: "Ultimate Guide to Instagram Reels Aspect Ratios & Video Dimensions (2026 Edition)",
        datePublished: "2026-09-26T00:00:00+00:00",
        dateModified: "2026-09-26T00:00:00+00:00",
        author: {
          "@type": "Organization",
          name: "SnapBeat Editorial Team",
        },
        publisher: {
          "@type": "Organization",
          name: "SnapBeat",
          logo: {
            "@type": "ImageObject",
            url: "https://www.snapbeat.app/assets/images/snapbeat_logo_3d.png"
          }
        },
        description: "Deep analysis of 9:16 vertical vs 1:1 square vs 16:9 landscape. Learn UI safe zones, optimal bitrates, and how to avoid blurriness.",
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
            STUDIO
          </span>
        </Link>

        <nav className="flex items-center gap-3 sm:gap-6 text-xs font-black">
          <Link href="/blog" className="hover:text-amber-300 transition hidden sm:inline-block">
            All Guides
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
      <div className="w-full max-w-3xl mx-auto px-4 sm:px-6 pt-4 text-[11px] font-mono text-white/50 flex items-center gap-1.5 flex-wrap">
        <Link href="/" className="hover:text-amber-300 transition">Home</Link>
        <span>/</span>
        <Link href="/blog" className="hover:text-amber-300 transition">Guides &amp; Tutorials</Link>
        <span>/</span>
        <span className="text-amber-300 font-bold">Instagram Reels Aspect Ratios</span>
      </div>

      {/* ARTICLE CONTENT */}
      <main className="w-full max-w-3xl mx-auto px-4 sm:px-6 pt-10 sm:pt-16 pb-20">
        <article className="prose prose-invert prose-amber max-w-none">
          <div className="flex items-center gap-4 mb-8 text-xs font-mono text-white/50">
            <span className="px-2 py-1 rounded-full bg-amber-400/20 text-amber-300 font-bold border border-amber-400/30">
              Technical Guide
            </span>
            <span className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" /> 6 min read
            </span>
            <span>Updated: Sep 2026</span>
          </div>

          <h1 className="text-3xl sm:text-5xl font-black text-white tracking-tight leading-tight mb-8">
            Ultimate Guide to Instagram Reels Aspect Ratios & Video Dimensions (2026 Edition)
          </h1>

          <p className="lead text-lg text-amber-100/80 font-medium">
            Mastering Instagram Reels dimensions is crucial for ensuring your content looks professional, avoids unwanted cropping, and bypasses Instagram's aggressive compression algorithms. This guide covers everything from 9:16 vertical spacing to UI safe zones.
          </p>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">1. The Golden Standard: 9:16 Vertical (1080 x 1920)</h2>
          <p>
            The native format for Instagram Reels, TikTok, and YouTube Shorts is a <strong>9:16 aspect ratio</strong>. The recommended resolution is 1080 pixels wide by 1920 pixels tall. This fully occupies the smartphone screen, providing maximum immersion and capturing 100% of the user's attention.
          </p>
          <div className="bg-white/5 border border-amber-400/30 p-6 rounded-2xl my-8">
            <h3 className="text-amber-300 font-bold mt-0 mb-3 text-lg flex items-center gap-2">
              <BookOpen className="w-5 h-5" /> Quick Specifications Checklist
            </h3>
            <ul className="m-0 space-y-2 text-sm">
              <li><strong>Resolution:</strong> 1080 x 1920 pixels</li>
              <li><strong>Frame Rate:</strong> 30fps (Preferred) or 60fps</li>
              <li><strong>Format:</strong> MP4 or MOV</li>
              <li><strong>Codec:</strong> H.264 or H.265 (HEVC)</li>
              <li><strong>Audio:</strong> AAC format, 44.1kHz or 48kHz, Stereo</li>
            </ul>
          </div>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">2. UI Safe Zones: Don't Let Your Text Get Cut Off</h2>
          <p>
            One of the most common mistakes creators make is placing essential text, captions, or visual hooks in areas that are obscured by Instagram's native User Interface (UI).
          </p>
          <div className="overflow-x-auto my-8">
            <table className="w-full text-sm text-left border-collapse">
              <thead>
                <tr className="bg-white/10 text-amber-300">
                  <th className="p-3 border border-white/20">Zone Area</th>
                  <th className="p-3 border border-white/20">Margin Needed (from edge)</th>
                  <th className="p-3 border border-white/20">What Obscures It?</th>
                </tr>
              </thead>
              <tbody className="text-white/80">
                <tr>
                  <td className="p-3 border border-white/20">Top Margin</td>
                  <td className="p-3 border border-white/20">~15% (220px)</td>
                  <td className="p-3 border border-white/20">Camera notch, following/for you tabs</td>
                </tr>
                <tr>
                  <td className="p-3 border border-white/20">Bottom Margin</td>
                  <td className="p-3 border border-white/20">~20% (340px)</td>
                  <td className="p-3 border border-white/20">Captions, profile handle, audio track name</td>
                </tr>
                <tr>
                  <td className="p-3 border border-white/20">Right Margin</td>
                  <td className="p-3 border border-white/20">~10% (120px)</td>
                  <td className="p-3 border border-white/20">Like, Comment, Share, Save buttons</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p>
            Always keep your core visual content and text hooks in the central <strong>1080 x 1350</strong> safe area.
          </p>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">3. Defeating Compression Algorithms</h2>
          <p>
            Ever noticed your crisp video looking muddy or blurry once uploaded to Instagram? That's because Instagram aggressively compresses video files to save server bandwidth. 
          </p>
          <ul>
            <li><strong>Bitrate Targets:</strong> Aim for an export bitrate between <strong>15 Mbps and 20 Mbps</strong>. Higher bitrates (like 50Mbps) will trigger Instagram's heavy-handed automated compression, often resulting in worse quality than if you had compressed it properly yourself.</li>
            <li><strong>Avoid Fake 4K:</strong> Uploading 4K (2160x3840) videos to Instagram Reels forces the app to downscale the footage on the fly. Downscaling by Instagram's servers is inferior to downscaling in Premiere, Final Cut, or SnapBeat. Always export at 1080p.</li>
            <li><strong>High-Quality Uploads Toggle:</strong> Navigate to Instagram Settings &gt; Account &gt; Data Usage, and ensure <em>"Upload at highest quality"</em> is toggled on. If you skip this, uploads on cellular data will be severely downgraded.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-12 mb-6 text-white border-b border-white/10 pb-2">Frequently Asked Questions</h2>
          <div className="space-y-4">
            <details className="bg-white/5 p-4 rounded-xl border border-white/10 cursor-pointer">
              <summary className="font-bold text-amber-300">Can I upload 1:1 square or 16:9 landscape videos?</summary>
              <p className="mt-2 text-sm text-white/80">Yes, but Instagram will add blurry or black bars (letterboxing) to fill the 9:16 screen. This dramatically reduces engagement, as users prefer full-screen immersive content.</p>
            </details>
            <details className="bg-white/5 p-4 rounded-xl border border-white/10 cursor-pointer">
              <summary className="font-bold text-amber-300">Does 60fps look better than 30fps?</summary>
              <p className="mt-2 text-sm text-white/80">For high-motion content (sports, gaming, dancing), 60fps provides smoother playback. However, for cinematic storytelling and standard photo slideshows, 30fps is the industry standard and reduces file size, aiding in compression.</p>
            </details>
          </div>
        </article>
      </main>
      <SeoFooter className="w-full" />
    </div>
  );
}
