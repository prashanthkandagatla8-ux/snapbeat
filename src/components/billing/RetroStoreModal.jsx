"use client";

import { useState, useEffect } from "react";
import { PRICING_PLANS } from "@/lib/constants";
import { Check, Crown, Sparkles, X, ShieldCheck } from "lucide-react";

export function RetroStoreModal({ isOpen, onClose, onSelectPlan, isPro = false }) {
  const [selectedPlanId, setSelectedPlanId] = useState("monthly");

  // Close on Escape key press
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === "Escape") {
        onClose?.();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const selectedPlan = PRICING_PLANS.find((p) => p.id === selectedPlanId) || PRICING_PLANS[1];

  const formatPeriod = (plan) => {
    if (plan.period === "week" || plan.id === "weekly") return "week";
    if (plan.period === "month" || plan.id === "monthly") return "month";
    if (plan.period === "year" || plan.id === "annual") return "year";
    return plan.period;
  };

  return (
    <div
      className="fixed inset-0 bg-black/75 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-fade-in"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="store-modal-title"
    >
      <div
        className="relative w-full max-w-2xl sky-glass-panel rounded-3xl p-6 lg:p-8 shadow-2xl overflow-hidden max-h-[92vh] overflow-y-auto border border-[#d4af37]/40 text-white"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          aria-label="Close Store"
          className="absolute top-4 right-4 w-9 h-9 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center font-black transition cursor-pointer"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header with Logo */}
        <div className="text-center space-y-2 mb-6">
          <div className="flex items-center justify-center gap-2">
            <img
              src="/assets/images/snapbeat_logo_3d.png"
              alt="SnapBeat"
              className="h-8 object-contain drop-shadow"
            />
            <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#ffc72c] text-[#241903] text-[10px] font-black tracking-wider uppercase shadow">
              <Crown className="w-3 h-3" />
              <span>PRO STUDIO PASS</span>
            </span>
          </div>
          <h2 id="store-modal-title" className="text-2xl font-black text-white tracking-tight uppercase">
            UPGRADE TO 1080P MASTER &amp; REMOVE WATERMARKS
          </h2>
          <p className="text-xs text-amber-100/70 max-w-md mx-auto font-medium">
            Choose your Pro access pass. Instant activation with unlimited master exports.
          </p>

          {isPro && (
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-emerald-500/20 border border-emerald-400/40 text-emerald-300 text-xs font-black">
              <ShieldCheck className="w-4 h-4 text-emerald-400" />
              <span>You currently have an active Pro Pass. Purchasing extends your duration.</span>
            </div>
          )}
        </div>

        {/* Gateway Pending Notice */}
        <div className="mb-5 p-4 rounded-2xl bg-gradient-to-r from-amber-500/25 via-amber-400/15 to-amber-500/25 border-2 border-amber-400/60 text-left flex items-start gap-3 backdrop-blur-md shadow-lg">
          <Sparkles className="w-5 h-5 text-amber-400 shrink-0 mt-0.5 animate-pulse" />
          <div className="space-y-1">
            <p className="text-xs font-black text-amber-300 uppercase tracking-wide">
              PAYMENT GATEWAY IN REVIEW — PRO PASS COMING SOON
            </p>
            <p className="text-[11px] font-bold text-amber-100/90 leading-relaxed">
              Paid checkout via UPI, Cards, and NetBanking is temporarily disabled while live merchant verification completes. In the meantime, enjoy <strong>100% free unlimited video renders</strong> on our shared GPU cluster!
            </p>
          </div>
        </div>

        {/* Pricing Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3.5 mb-6">
          {PRICING_PLANS.map((plan) => {
            const isSelected = selectedPlanId === plan.id;
            const period = formatPeriod(plan);

            return (
              <div
                key={plan.id}
                role="radio"
                aria-checked={isSelected}
                tabIndex={0}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") {
                    e.preventDefault();
                    setSelectedPlanId(plan.id);
                  }
                }}
                onClick={() => setSelectedPlanId(plan.id)}
                className={`relative p-5 rounded-2xl transition-all cursor-pointer flex flex-col justify-between border-2 ${
                  isSelected
                    ? "bg-amber-500/20 border-amber-400 shadow-[0_0_30px_rgba(255,199,44,0.35)] transform scale-[1.02]"
                    : "bg-black/40 border-white/15 hover:border-amber-400/50"
                }`}
              >
                <div className="absolute -top-2.5 right-3 px-2 py-0.5 rounded-full bg-amber-400/30 border border-amber-400/60 text-amber-200 font-black text-[9px] uppercase tracking-wider shadow">
                  COMING SOON
                </div>

                {plan.badge && (
                  <div className="absolute -top-2.5 left-3 px-2.5 py-0.5 rounded-full bg-[#ffc72c] text-[#241903] font-black text-[9px] shadow">
                    {plan.badge}
                  </div>
                )}

                <div>
                  <h3 className="font-black text-sm text-white uppercase mt-1">{plan.name}</h3>
                  <div className="mt-2 flex items-baseline gap-1">
                    <span className="text-2xl lg:text-3xl font-black text-amber-300">
                      ₹{plan.price}
                    </span>
                    <span className="text-xs text-amber-100/70">/{period}</span>
                  </div>
                  <p className="text-[11px] text-amber-100/70 mt-1">{plan.description}</p>
                </div>

                <div className="mt-4 pt-3 border-t border-white/10 space-y-1.5">
                  {plan.features.slice(0, 3).map((feat, idx) => (
                    <div key={idx} className="flex items-center gap-1.5 text-[11px] text-white font-bold">
                      <Check className="w-3 h-3 text-emerald-400 shrink-0 stroke-[3]" />
                      <span className="truncate">{feat}</span>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {/* Perks Strip */}
        <div className="p-3.5 rounded-2xl bg-black/40 border border-white/10 flex items-center justify-around text-center mb-6">
          <div>
            <p className="text-xs font-black text-white">1080P MASTER</p>
            <p className="text-[10px] text-amber-100/70">High-bitrate clarity</p>
          </div>
          <div className="w-[1px] h-6 bg-white/20" />
          <div>
            <p className="text-xs font-black text-white">NO WATERMARK</p>
            <p className="text-[10px] text-amber-100/70">100% clean output</p>
          </div>
          <div className="w-[1px] h-6 bg-white/20" />
          <div>
            <p className="text-xs font-black text-white">ALL 14 TEMPLATES</p>
            <p className="text-[10px] text-amber-100/70">VIP motion styles</p>
          </div>
        </div>

        {/* Action Button: Disabled & Coming Soon */}
        <div className="space-y-2.5">
          <button
            type="button"
            disabled={true}
            aria-disabled="true"
            className="w-full py-4 px-6 rounded-full font-black text-sm tracking-wider flex items-center justify-center gap-2 bg-gradient-to-r from-amber-500/20 via-amber-400/20 to-amber-500/20 text-amber-200 border-2 border-amber-400/40 cursor-not-allowed shadow-inner select-none opacity-80"
          >
            <Sparkles className="w-4 h-4 text-amber-400 animate-spin" />
            <span>
              {selectedPlan.name.toUpperCase()} (₹{selectedPlan.price}/{formatPeriod(selectedPlan)}) — COMING SOON
            </span>
          </button>

          <div className="flex items-center justify-center gap-1 text-[11px] text-amber-200/70 font-semibold">
            <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
            <span>Payments unlock upon merchant approval • Enjoy 100% free renders today!</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default RetroStoreModal;
