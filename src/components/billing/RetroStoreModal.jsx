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
        className="relative w-full max-w-2xl metal-panel rounded-3xl p-6 lg:p-8 shadow-2xl overflow-hidden max-h-[92vh] overflow-y-auto border-4 border-[#7a766f]"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="absolute top-3 left-3 metal-screw" />
        <div className="absolute top-3 right-3 metal-screw" />
        <div className="absolute bottom-3 left-3 metal-screw" />
        <div className="absolute bottom-3 right-3 metal-screw" />

        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          aria-label="Close Store"
          className="absolute top-4 right-4 w-8 h-8 rounded-full metal-inset text-[#2b2b2d] flex items-center justify-center font-black hover:bg-black/10 transition shadow-inner"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header with Logo */}
        <div className="text-center space-y-2 mb-6">
          <div className="flex items-center justify-center gap-2">
            <img
              src="/assets/images/snapbeat_logo_crop.png"
              alt="SnapBeat"
              className="h-7 object-contain"
            />
            <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-[#ffc72c] border border-[#bf8a00] text-[#2b2820] text-[10px] font-black tracking-wider uppercase shadow-sm">
              <Crown className="w-3 h-3" />
              <span>PRO STUDIO PASS</span>
            </span>
          </div>
          <h2 id="store-modal-title" className="text-2xl font-black text-[#2b2b2d] tracking-tight uppercase">
            UPGRADE TO 1080P MASTER &amp; REMOVE WATERMARKS
          </h2>
          <p className="text-xs text-[#5a5752] max-w-md mx-auto">
            Choose your Pro access pass. Instant activation with unlimited master exports.
          </p>

          {isPro && (
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-emerald-500/15 border border-emerald-600/30 text-emerald-800 text-xs font-black">
              <ShieldCheck className="w-4 h-4 text-emerald-600" />
              <span>You currently have an active Pro Pass. Purchasing extends your duration.</span>
            </div>
          )}
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
                    ? "bg-[#ffc72c]/20 border-[#ffc72c] shadow-lg transform scale-[1.02]"
                    : "metal-inset hover:border-[#7a766f]"
                }`}
              >
                {plan.badge && (
                  <div className="absolute -top-2.5 left-1/2 -translate-x-1/2 px-2.5 py-0.5 rounded-full bg-[#ffc72c] text-[#2b2820] font-black text-[9px] border border-[#bf8a00] shadow">
                    {plan.badge}
                  </div>
                )}

                <div>
                  <h3 className="font-black text-sm text-[#2b2b2d] uppercase">{plan.name}</h3>
                  <div className="mt-2 flex items-baseline gap-1">
                    <span className="text-2xl lg:text-3xl font-black text-[#2b2b2d]">
                      ₹{plan.price}
                    </span>
                    <span className="text-xs text-[#5a5752]">/{period}</span>
                  </div>
                  <p className="text-[11px] text-[#5a5752] mt-1">{plan.description}</p>
                </div>

                <div className="mt-4 pt-3 border-t border-[#8f8677]/40 space-y-1.5">
                  {plan.features.slice(0, 3).map((feat, idx) => (
                    <div key={idx} className="flex items-center gap-1.5 text-[11px] text-[#2b2b2d] font-bold">
                      <Check className="w-3 h-3 text-[#00c853] shrink-0 stroke-[3]" />
                      <span className="truncate">{feat}</span>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {/* Hardware Perks Strip */}
        <div className="p-3.5 rounded-2xl metal-inset flex items-center justify-around text-center mb-6">
          <div>
            <p className="text-xs font-black text-[#2b2b2d]">1080P MASTER</p>
            <p className="text-[10px] text-[#5a5752]">High-bitrate clarity</p>
          </div>
          <div className="w-[1px] h-6 bg-[#8f8677]" />
          <div>
            <p className="text-xs font-black text-[#2b2b2d]">NO WATERMARK</p>
            <p className="text-[10px] text-[#5a5752]">100% clean output</p>
          </div>
          <div className="w-[1px] h-6 bg-[#8f8677]" />
          <div>
            <p className="text-xs font-black text-[#2b2b2d]">ALL 14 TEMPLATES</p>
            <p className="text-[10px] text-[#5a5752]">VIP motion styles</p>
          </div>
        </div>

        {/* Action Button */}
        <div className="space-y-2.5">
          <button
            type="button"
            onClick={() => onSelectPlan(selectedPlanId)}
            className="w-full btn-brass py-3.5 px-6 rounded-2xl font-black text-sm tracking-wide flex items-center justify-center gap-2 shadow-xl hover:brightness-105 active:scale-[0.99] transition cursor-pointer"
          >
            <Sparkles className="w-4 h-4 fill-current" />
            <span>
              CONTINUE WITH {selectedPlan.name.toUpperCase()} (₹{selectedPlan.price}/{formatPeriod(selectedPlan)})
            </span>
          </button>

          <div className="flex items-center justify-center gap-1 text-[11px] text-[#5a5752] font-semibold">
            <ShieldCheck className="w-3.5 h-3.5 text-[#00c853]" />
            <span>Secure payment via UPI, Google Pay, PhonePe, Cards &amp; NetBanking</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default RetroStoreModal;
