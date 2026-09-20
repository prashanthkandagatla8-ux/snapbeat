"use client";

import { useState, useEffect } from "react";
import { PRICING_PLANS, TOP_UPS } from "@/lib/constants";
import { Check, Crown, Sparkles, X, ShieldCheck, Lock } from "lucide-react";
import { trackUpgradeViewed, trackPurchaseStarted } from "@/lib/analytics";

export function RetroStoreModal({ isOpen, onClose, onSelectPlan, isPro = false }) {
  const [selectedPlanId, setSelectedPlanId] = useState("monthly");

  // Track upgrade view on open
  useEffect(() => {
    if (isOpen) {
      trackUpgradeViewed("all", "store_modal");
    }
  }, [isOpen]);

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
    if (plan.period === "day" || plan.id === "daily") return "day";
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
        className="relative w-full max-w-4xl sky-glass-panel rounded-3xl p-6 lg:p-8 shadow-2xl overflow-hidden max-h-[92vh] overflow-y-auto border border-[#d4af37]/40 text-white"
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

        {/* Live Payment Gateway Notice */}
        <div className="mb-5 p-3.5 rounded-2xl bg-gradient-to-r from-emerald-500/20 via-amber-500/15 to-emerald-500/20 border border-emerald-400/50 text-left flex items-center justify-between gap-3 backdrop-blur-md shadow-lg">
          <div className="flex items-center gap-2.5">
            <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0" />
            <div>
              <p className="text-xs font-black text-white uppercase tracking-wide">
                INSTANT PRO PASS ACTIVATION
              </p>
              <p className="text-[11px] text-amber-100/80 font-medium">
                UPI (GPay, PhonePe, Paytm, QR), Cards &amp; NetBanking • Cancel anytime
              </p>
            </div>
          </div>
          <span className="hidden sm:inline-block px-2.5 py-1 rounded-full bg-emerald-400/20 border border-emerald-400/40 text-emerald-300 text-[10px] font-mono font-black uppercase tracking-wider">
            LIVE CHECKOUT
          </span>
        </div>

        {/* Pricing Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
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
                onClick={() => {
                  setSelectedPlanId(plan.id);
                  trackPurchaseStarted(plan.id, plan.price, "INR");
                }}
                className={`relative p-5 rounded-2xl transition-all cursor-pointer flex flex-col justify-between border-2 ${
                  isSelected
                    ? "bg-amber-500/20 border-amber-400 shadow-[0_0_30px_rgba(255,199,44,0.35)] transform scale-[1.02]"
                    : "bg-black/40 border-white/15 hover:border-amber-400/50"
                }`}
              >
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

        {/* Action Button: Live Active Checkout */}
        <div className="space-y-2.5">
          <button
            type="button"
            onClick={() => onSelectPlan?.(selectedPlanId)}
            className="w-full py-4 px-6 rounded-full font-black text-sm tracking-wider flex items-center justify-center gap-2 btn-gold-radiant text-[#261b02] shadow-xl hover:scale-[1.02] active:scale-95 transition cursor-pointer"
          >
            <Sparkles className="w-4 h-4 fill-current text-[#261b02]" />
            <span>
              UPGRADE TO {selectedPlan.name.toUpperCase()} (₹{selectedPlan.price}/{formatPeriod(selectedPlan)})
            </span>
          </button>

          <div className="flex items-center justify-center gap-1 text-[11px] text-amber-200/70 font-semibold">
            <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
            <span>256-Bit Encrypted Secure Checkout • Instant Pro Access • Cancel Anytime</span>
          </div>
        </div>

        {/* Top-Ups Section */}
        <div className="mt-8 pt-6 border-t border-white/10">
          <div className="mb-4 text-center">
            <h3 className="text-lg font-black text-white uppercase tracking-wider">CREDIT TOP-UPS</h3>
            <p className="text-xs text-amber-100/70">Top-ups are exclusively available to Pro members.</p>
          </div>
          
          {!isPro ? (
            <div className="p-6 rounded-2xl bg-black/40 border border-white/10 text-center flex flex-col items-center justify-center relative overflow-hidden">
              <Lock className="w-8 h-8 text-amber-500/50 mb-2" />
              <p className="text-sm font-black text-white uppercase">TOP-UPS LOCKED</p>
              <p className="text-xs text-amber-100/70 mt-1 mb-3">Upgrade to any Pro plan above to buy additional credits.</p>
              <div className="absolute inset-0 bg-black/60 backdrop-blur-[2px] z-10 flex items-center justify-center">
                <span className="px-4 py-1.5 rounded-full bg-amber-500 text-[#261b02] text-xs font-black uppercase tracking-wider shadow-lg flex items-center gap-1.5">
                  <Lock className="w-3.5 h-3.5" />
                  SUBSCRIBER ONLY
                </span>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
              {TOP_UPS.map((topup) => (
                <div key={topup.id} className="p-3 rounded-xl bg-black/40 border border-white/15 hover:border-amber-400/50 transition cursor-pointer text-center">
                  <p className="text-sm font-black text-white">{topup.credits} Credits</p>
                  <p className="text-lg font-black text-amber-300">₹{topup.price}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default RetroStoreModal;
