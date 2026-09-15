import Link from "next/link";
import { ArrowLeft, Home, Film, Sparkles } from "lucide-react";

export const metadata = {
  title: "404 — Page Not Found",
  description: "The page you are looking for does not exist. Return to SnapBeat to create beat-synced photo reels.",
};

export default function NotFound() {
  return (
    <main className="min-h-screen w-full flex flex-col items-center justify-center p-4 text-center select-none sky-canvas">
      <div className="w-full max-w-md sky-glass-panel rounded-3xl p-8 border border-white/20 shadow-2xl space-y-6">
        <div className="space-y-2">
          <p className="font-mono text-xs font-black text-amber-400 uppercase tracking-widest">
            ERROR CODE 404
          </p>
          <h1 className="text-4xl sm:text-5xl font-black text-white tracking-tight">
            Track Not Found
          </h1>
          <p className="text-xs sm:text-sm text-amber-100/80 leading-relaxed">
            The page or reel you requested has dropped off the beat. Let's get you back to the studio.
          </p>
        </div>

        <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3">
          <Link
            href="/"
            className="w-full sm:w-auto px-6 py-3 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow hover:scale-105 active:scale-95 transition flex items-center justify-center gap-2 cursor-pointer"
          >
            <Home className="w-4 h-4" />
            <span>Go to Home</span>
          </Link>

          <Link
            href="/templates"
            className="w-full sm:w-auto px-6 py-3 rounded-full bg-white/10 hover:bg-white/20 text-white text-xs font-black uppercase tracking-wider border border-white/20 transition flex items-center justify-center gap-2 cursor-pointer"
          >
            <Film className="w-4 h-4 text-amber-300" />
            <span>Browse Templates</span>
          </Link>
        </div>

        <div className="pt-4 border-t border-white/10 text-left space-y-2">
          <p className="text-[10px] font-mono font-bold text-amber-300/80 uppercase">
            Popular Video Makers:
          </p>
          <div className="flex flex-wrap gap-2 text-[11px] text-white/70">
            <Link href="/photo-to-video" className="hover:text-amber-300 transition hover:underline">
              Photo to Video
            </Link>
            <span>•</span>
            <Link href="/birthday-video-maker" className="hover:text-amber-300 transition hover:underline">
              Birthday Videos
            </Link>
            <span>•</span>
            <Link href="/photo-reel-maker" className="hover:text-amber-300 transition hover:underline">
              Instagram Reels
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
