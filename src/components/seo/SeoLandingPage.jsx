"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  Sparkles,
  Play,
  ArrowRight,
  CheckCircle2,
  ChevronDown,
  Film,
  Zap,
  Music,
  Share2,
  Clock,
  Layers,
} from "lucide-react";
import SeoFooter from "@/components/layout/SeoFooter";
import { trackStartCreating } from "@/lib/analytics";

export default function SeoLandingPage({
  title,
  h1,
  tagline,
  valueProposition,
  primaryCtaText = "Create Your Video Free",
  ctaUrl = "/?view=studio",
  breadcrumbs = [],
  howItWorks = [],
  recommendedTemplates = [],
  benefits = [],
  faqs = [],
  relatedPages = [],
  schemaJsonLd = null,
}) {
  const [openFaq, setOpenFaq] = useState(null);

  const toggleFaq = (idx) => {
    setOpenFaq(openFaq === idx ? null : idx);
  };

  const handleCtaClick = (entryPoint = "seo_hero_cta") => {
    trackStartCreating(typeof window !== "undefined" ? window.location.pathname : "/seo", entryPoint);
  };

  return (
    <div className="min-h-screen w-full bg-[#0c0d10] text-[#f1f1f1] flex flex-col items-center select-none overflow-x-hidden">
      {/* Inject Structured Data Schemas */}
      {schemaJsonLd && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(schemaJsonLd) }}
        />
      )}

      {/* TOP NAVIGATION BAR */}
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
          <Link href="/templates" className="hover:text-amber-300 transition hidden sm:inline-block">
            Templates
          </Link>
          <Link href="/blog" className="hover:text-amber-300 transition hidden sm:inline-block">
            Guides
          </Link>
          <Link
            href={ctaUrl}
            onClick={() => handleCtaClick("nav_studio")}
            className="px-4 py-2 rounded-full btn-gold-radiant text-[#261b02] text-xs font-black uppercase tracking-wider shadow hover:scale-105 active:scale-95 transition flex items-center gap-1.5"
          >
            <Play className="w-3.5 h-3.5 fill-current" />
            <span>Open Studio</span>
          </Link>
        </nav>
      </header>

      {/* BREADCRUMBS */}
      {breadcrumbs.length > 0 && (
        <div className="w-full max-w-6xl mx-auto px-4 sm:px-6 pt-4 text-[11px] font-mono text-white/50 flex items-center gap-1.5 flex-wrap">
          <Link href="/" className="hover:text-amber-300 transition">
            Home
          </Link>
          {breadcrumbs.map((b, i) => (
            <React.Fragment key={b.path || i}>
              <span>/</span>
              {i === breadcrumbs.length - 1 ? (
                <span className="text-amber-300 font-bold">{b.name}</span>
              ) : (
                <Link href={b.path} className="hover:text-amber-300 transition">
                  {b.name}
                </Link>
              )}
            </React.Fragment>
          ))}
        </div>
      )}

      {/* HERO SECTION */}
      <main className="w-full max-w-5xl mx-auto px-4 sm:px-6 pt-8 sm:pt-14 pb-12 flex flex-col items-center text-center space-y-6">
        {tagline && (
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/15 border border-amber-400/30 text-amber-300 text-[10px] font-mono font-black uppercase tracking-widest animate-fadeIn">
            <Sparkles className="w-3.5 h-3.5" />
            <span>{tagline}</span>
          </div>
        )}

        {/* PRIMARY H1 HEADING */}
        <h1 className="text-3xl sm:text-5xl md:text-6xl font-black text-white tracking-tight max-w-3xl leading-[1.15]">
          {h1}
        </h1>

        {/* VALUE PROPOSITION COPY */}
        <p className="text-sm sm:text-lg text-amber-100/80 max-w-2xl font-medium leading-relaxed">
          {valueProposition}
        </p>

        {/* PRIMARY CTA */}
        <div className="pt-3 flex flex-col sm:flex-row items-center justify-center gap-3 w-full sm:w-auto">
          <Link
            href={ctaUrl}
            onClick={() => handleCtaClick("hero_primary")}
            className="w-full sm:w-auto px-9 py-4 rounded-full btn-gold-radiant text-[#261b02] text-sm font-black uppercase tracking-wider shadow-2xl hover:scale-105 active:scale-95 transition flex items-center justify-center gap-2.5 border border-[#fff4b8]"
          >
            <Play className="w-4 h-4 fill-current" />
            <span>{primaryCtaText}</span>
          </Link>

          <Link
            href="/templates"
            className="w-full sm:w-auto px-7 py-4 rounded-full bg-white/10 hover:bg-white/20 text-white text-xs font-black uppercase tracking-wider border border-white/20 transition flex items-center justify-center gap-2"
          >
            <Film className="w-4 h-4 text-amber-300" />
            <span>Browse 14 Templates</span>
          </Link>
        </div>

        <p className="text-[11px] text-amber-200/60 font-mono">
          ⚡ 100% Free Unlimited Renders • Instant 1-Click Guest Access • No Sign-Up Required
        </p>

        {/* HERO MOCKUP / TABLET SHOWCASE PREVIEW */}
        <div className="pt-6 w-full max-w-2xl mx-auto">
          <div className="relative aspect-[16/10] w-full rounded-3xl overflow-hidden shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_40px_rgba(255,199,44,0.15)] border-2 border-amber-400/40 bg-[#091519] group">
            <img
              src="/assets/images/snapbeat_camera_art.png"
              alt={h1}
              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent flex flex-col justify-end p-6 text-left">
              <span className="px-2.5 py-1 rounded-full bg-[#ffc72c] text-[#261b02] text-[10px] font-mono font-black uppercase w-fit mb-2 shadow">
                AI BEAT-SYNC PIPELINE
              </span>
              <p className="text-white text-base sm:text-xl font-black">
                {title}
              </p>
              <p className="text-amber-200/80 text-xs mt-1">
                Upload photos, select a rhythm, and export high-impact reels in seconds.
              </p>
            </div>
          </div>
        </div>
      </main>

      {/* HOW IT WORKS SECTION */}
      {howItWorks.length > 0 && (
        <section className="w-full max-w-5xl mx-auto px-4 sm:px-6 py-12 border-t border-white/10">
          <div className="text-center space-y-2 mb-10">
            <h2 className="text-2xl sm:text-3xl font-black text-white uppercase tracking-tight">
              How It Works in 3 Simple Steps
            </h2>
            <p className="text-xs sm:text-sm text-amber-100/70 max-w-lg mx-auto">
              No complex timelines, keyframes, or editing expertise required.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {howItWorks.map((step, idx) => (
              <div
                key={idx}
                className="sky-glass-panel rounded-2xl p-6 relative border border-white/15 shadow-xl space-y-3"
              >
                <div className="w-9 h-9 rounded-xl bg-amber-400/20 border border-amber-400/40 text-amber-300 font-mono font-black text-sm flex items-center justify-center shadow">
                  0{idx + 1}
                </div>
                <h3 className="text-base font-black text-white">{step.title}</h3>
                <p className="text-xs text-amber-100/75 leading-relaxed">
                  {step.description}
                </p>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* RECOMMENDED TEMPLATES FOR THIS USE CASE */}
      {recommendedTemplates.length > 0 && (
        <section className="w-full max-w-5xl mx-auto px-4 sm:px-6 py-12 border-t border-white/10">
          <div className="text-center space-y-2 mb-10">
            <h2 className="text-2xl sm:text-3xl font-black text-white uppercase tracking-tight">
              Curated Motion Templates
            </h2>
            <p className="text-xs sm:text-sm text-amber-100/70 max-w-lg mx-auto">
              Choose from 14 kinetic motion presets tailored for rhythm-synchronized cuts.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {recommendedTemplates.map((tpl) => (
              <div
                key={tpl.id}
                className="sky-glass-panel rounded-2xl p-5 border border-white/15 shadow-lg flex flex-col justify-between space-y-4 hover:border-amber-400/50 transition group"
              >
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-2xl">{tpl.emoji || "⚡"}</span>
                    <span className="px-2 py-0.5 rounded-full bg-amber-400/20 text-amber-300 font-mono text-[9px] font-bold border border-amber-400/30">
                      {tpl.badge || "MOTION PRESET"}
                    </span>
                  </div>
                  <h3 className="text-base font-black text-white group-hover:text-amber-300 transition">
                    {tpl.name}
                  </h3>
                  <p className="text-xs text-amber-100/70 leading-snug">
                    {tpl.subtitle || tpl.description}
                  </p>
                </div>

                <Link
                  href={`/?view=studio&template=${tpl.id}`}
                  onClick={() => handleCtaClick(`template_${tpl.id}`)}
                  className="w-full py-2.5 rounded-xl bg-white/10 hover:bg-amber-400 hover:text-black text-white text-xs font-black uppercase tracking-wider transition flex items-center justify-center gap-1.5"
                >
                  <span>Use This Template</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* KEY BENEFITS / FEATURES */}
      {benefits.length > 0 && (
        <section className="w-full max-w-5xl mx-auto px-4 sm:px-6 py-12 border-t border-white/10">
          <div className="text-center space-y-2 mb-10">
            <h2 className="text-2xl sm:text-3xl font-black text-white uppercase tracking-tight">
              Why Creators Choose SnapBeat
            </h2>
            <p className="text-xs sm:text-sm text-amber-100/70 max-w-lg mx-auto">
              Automated choreography engineered for viral Instagram Reels, YouTube Shorts, and WhatsApp Status.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {benefits.map((b, idx) => (
              <div
                key={idx}
                className="sky-glass-panel rounded-2xl p-5 border border-white/15 flex items-start gap-4"
              >
                <div className="p-2.5 rounded-xl bg-amber-400/20 text-amber-300 shrink-0">
                  <CheckCircle2 className="w-5 h-5" />
                </div>
                <div className="space-y-1">
                  <h3 className="text-sm font-black text-white">{b.title}</h3>
                  <p className="text-xs text-amber-100/75 leading-relaxed">
                    {b.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* FAQ SECTION (ACCORDION + SCHEMA) */}
      {faqs.length > 0 && (
        <section className="w-full max-w-4xl mx-auto px-4 sm:px-6 py-12 border-t border-white/10">
          <div className="text-center space-y-2 mb-10">
            <h2 className="text-2xl sm:text-3xl font-black text-white uppercase tracking-tight">
              Frequently Asked Questions
            </h2>
            <p className="text-xs sm:text-sm text-amber-100/70 max-w-lg mx-auto">
              Everything you need to know about creating beat-synced videos with SnapBeat.
            </p>
          </div>

          <div className="space-y-3">
            {faqs.map((faq, idx) => {
              const isOpen = openFaq === idx;
              return (
                <div
                  key={idx}
                  className="sky-glass-panel rounded-2xl border border-white/15 overflow-hidden transition"
                >
                  <button
                    type="button"
                    onClick={() => toggleFaq(idx)}
                    className="w-full p-4 sm:p-5 text-left flex items-center justify-between gap-3 text-sm font-black text-white hover:text-amber-300 transition cursor-pointer"
                  >
                    <span>{faq.question}</span>
                    <ChevronDown
                      className={`w-4 h-4 text-amber-400 shrink-0 transition-transform duration-300 ${
                        isOpen ? "rotate-180" : ""
                      }`}
                    />
                  </button>

                  {isOpen && (
                    <div className="px-4 sm:px-5 pb-5 pt-1 text-xs text-amber-100/80 leading-relaxed border-t border-white/10 animate-fadeIn">
                      {faq.answer}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </section>
      )}

      {/* RELATED USE CASES & TOOLS */}
      {relatedPages.length > 0 && (
        <section className="w-full max-w-5xl mx-auto px-4 sm:px-6 py-10 border-t border-white/10">
          <h2 className="text-lg font-black text-white uppercase tracking-wider mb-4 text-center sm:text-left">
            Explore Related Video Makers
          </h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
            {relatedPages.map((rp) => (
              <Link
                key={rp.path}
                href={rp.path}
                className="p-3 rounded-xl bg-white/5 hover:bg-amber-400/15 border border-white/10 hover:border-amber-400/40 text-xs font-bold text-white/90 hover:text-amber-300 transition flex items-center justify-between"
              >
                <span className="truncate">{rp.title}</span>
                <ArrowRight className="w-3 h-3 shrink-0 ml-1 text-amber-400" />
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* FINAL CONVERSION BOTTOM CTA */}
      <section className="w-full max-w-5xl mx-auto px-4 sm:px-6 py-14">
        <div className="sky-glass-panel rounded-3xl p-8 sm:p-12 text-center border-2 border-amber-400/40 shadow-2xl space-y-5 relative overflow-hidden">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-400/20 text-amber-300 text-xs font-mono font-black uppercase tracking-wider">
            <Zap className="w-3.5 h-3.5 fill-current" />
            <span>START CREATING IN 30 SECONDS</span>
          </div>

          <h2 className="text-2xl sm:text-4xl font-black text-white uppercase tracking-tight max-w-xl mx-auto">
            Ready to Turn Your Photos Into a Kinetic Video Reel?
          </h2>

          <p className="text-xs sm:text-sm text-amber-100/80 max-w-lg mx-auto leading-relaxed">
            Upload your photos, pick a track, and let our audio engine choreograph the perfect reel. 100% free with instant guest access.
          </p>

          <div className="pt-2">
            <Link
              href={ctaUrl}
              onClick={() => handleCtaClick("bottom_cta")}
              className="inline-flex px-10 py-4 rounded-full btn-gold-radiant text-[#261b02] text-sm font-black uppercase tracking-wider shadow-2xl hover:scale-105 active:scale-95 transition items-center gap-2 border border-[#fff4b8]"
            >
              <Play className="w-4 h-4 fill-current" />
              <span>{primaryCtaText}</span>
            </Link>
          </div>
        </div>
      </section>

      {/* FOOTER DIRECTORY */}
      <SeoFooter />
    </div>
  );
}
