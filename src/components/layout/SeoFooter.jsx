import Link from "next/link";

export default function SeoFooter({ className = "" }) {
  return (
    <footer className={`w-full text-white/70 text-xs border-t border-white/10 pt-8 pb-10 mt-12 select-none ${className}`}>
      <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-2 md:grid-cols-4 gap-8">
        {/* Col 1: Core Tools */}
        <div className="space-y-3">
          <p className="font-mono text-[11px] font-black text-amber-300 uppercase tracking-wider">
            Video Creation Tools
          </p>
          <ul className="space-y-2 text-[11px]">
            <li>
              <Link href="/photo-to-video" className="hover:text-amber-300 transition">
                Photo to Video Maker
              </Link>
            </li>
            <li>
              <Link href="/photo-slideshow-maker" className="hover:text-amber-300 transition">
                Photo Slideshow Maker
              </Link>
            </li>
            <li>
              <Link href="/photo-to-music-video" className="hover:text-amber-300 transition">
                Photo to Music Video
              </Link>
            </li>
            <li>
              <Link href="/beat-sync-video-maker" className="hover:text-amber-300 transition">
                Beat Sync Video Maker
              </Link>
            </li>
            <li>
              <Link href="/photo-reel-maker" className="hover:text-amber-300 transition">
                Photo Reel Maker
              </Link>
            </li>
            <li>
              <Link href="/instagram-reel-maker" className="hover:text-amber-300 transition">
                Instagram Reel Maker
              </Link>
            </li>
          </ul>
        </div>

        {/* Col 2: Occasions & Milestones */}
        <div className="space-y-3">
          <p className="font-mono text-[11px] font-black text-amber-300 uppercase tracking-wider">
            Occasions & Events
          </p>
          <ul className="space-y-2 text-[11px]">
            <li>
              <Link href="/birthday-video-maker" className="hover:text-amber-300 transition">
                Birthday Video Maker
              </Link>
            </li>
            <li>
              <Link href="/wedding-video-maker" className="hover:text-amber-300 transition">
                Wedding Photo Video Maker
              </Link>
            </li>
            <li>
              <Link href="/anniversary-video-maker" className="hover:text-amber-300 transition">
                Anniversary Video Maker
              </Link>
            </li>
            <li>
              <Link href="/baby-video-maker" className="hover:text-amber-300 transition">
                Baby Photo Video Maker
              </Link>
            </li>
            <li>
              <Link href="/travel-reel-maker" className="hover:text-amber-300 transition">
                Travel Photo Reel Maker
              </Link>
            </li>
          </ul>
        </div>

        {/* Col 3: Celebrations & Life */}
        <div className="space-y-3">
          <p className="font-mono text-[11px] font-black text-amber-300 uppercase tracking-wider">
            Celebrations & Life
          </p>
          <ul className="space-y-2 text-[11px]">
            <li>
              <Link href="/party-video-maker" className="hover:text-amber-300 transition">
                Party & Celebration Video Maker
              </Link>
            </li>
            <li>
              <Link href="/friendship-video-maker" className="hover:text-amber-300 transition">
                Friendship & Best Friends Reels
              </Link>
            </li>
            <li>
              <Link href="/memorial-video-maker" className="hover:text-amber-300 transition">
                Memorial & Tribute Slideshow
              </Link>
            </li>
            <li>
              <Link href="/graduation-video-maker" className="hover:text-amber-300 transition">
                Graduation Photo Video Maker
              </Link>
            </li>
          </ul>
        </div>

        {/* Col 4: Resources & Product */}
        <div className="space-y-3">
          <p className="font-mono text-[11px] font-black text-amber-300 uppercase tracking-wider">
            Resources & Templates
          </p>
          <ul className="space-y-2 text-[11px]">
            <li>
              <Link href="/templates" className="hover:text-amber-300 transition">
                14 Kinetic Templates Hub
              </Link>
            </li>
            <li>
              <Link href="/about" className="hover:text-amber-300 transition">
                About SnapBeat
              </Link>
            </li>
            <li>
              <Link href="/contact" className="hover:text-amber-300 transition">
                Contact Support
              </Link>
            </li>
            <li>
              <Link href="/blog" className="hover:text-amber-300 transition">
                Reel Creation Guides & Blog
              </Link>
            </li>
            <li>
              <Link href="/cookies" className="hover:text-amber-300 transition">
                Cookie Policy
              </Link>
            </li>
            <li>
              <Link href="/disclaimer" className="hover:text-amber-300 transition">
                Disclaimer
              </Link>
            </li>
            <li>
              <Link href="/privacy" className="hover:text-amber-300 transition">
                Privacy Policy
              </Link>
            </li>
            <li>
              <Link href="/terms" className="hover:text-amber-300 transition">
                Terms & Refunds
              </Link>
            </li>
          </ul>
        </div>
      </div>

      {/* Bottom Copyright */}
      <div className="max-w-6xl mx-auto px-4 sm:px-6 pt-8 mt-8 border-t border-white/5 flex flex-col sm:flex-row items-center justify-between text-[11px] text-white/50 gap-2">
        <p>© 2026 SnapBeat. Automated AI Beat-Synced Photo to Video Reel Maker.</p>
        <div className="flex items-center gap-4">
          <Link href="/?view=studio" className="text-amber-300/80 hover:text-amber-200 transition font-bold">
            Launch Studio Workstation ❯
          </Link>
        </div>
      </div>
    </footer>
  );
}
