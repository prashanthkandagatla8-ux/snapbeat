"use client";

import { useState } from "react";
import { PRICING_PLANS } from "@/lib/constants";
import { Check, Crown, Sparkles, X, ShieldCheck } from "lucide-react";

export function ProPricingModal({ isOpen, onClose, onSelectPlan, isPro }) {
  const [selectedPlanId, setSelectedPlanId] = useState("monthly");

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md flex items-center justify-center p-4 z-50 animate-fade-in">
      <div className="relative w-full max-w-2xl bg-[#141822] border border-[#2d3748] rounded-3xl p-6 lg:p-8 shadow-2xl overflow-hidden max-h-[90vh] overflow-y-auto">
        {/* Glow Accent */}
        <div className="absolute top-0 right-1/4 w-72 h-72 bg-amber-500/10 rounded-full blur-3xl pointer-events-none" />

        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-5 right-5 text-gray-400 hover:text-white p-2 rounded-full hover:bg-white/5 transition"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Modal Header */}
        <div className="text-center space-y-2 mb-6">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/10 border border-amber-500/20 text-amber-400 text-xs font-black tracking-wider uppercase">
            <Crown className="w-3.5 h-3.5" />
            <span>SnapBeat Pro Studio</span>
          </div>
          <h2 className="text-2xl lg:text-3xl font-black text-white tracking-tight">
            Unlock Full High-Definition Reels
          </h2>
          <p className="text-xs lg:text-sm text-gray-400 max-w-md mx-auto">
            Render crisp 1080p master quality, remove watermarks, and unlock all 14 motion choreography templates.
          </p>
        </div>

        {/* Plan Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3.5 mb-6">
          {PRICING_PLANS.map((plan) => {
            const isSelected = selectedPlanId === plan.id;
            return (
              <div
                key={plan.id}
                onClick={() => setSelectedPlanId(plan.id)}
                className={`relative p-5 rounded-2xl border transition-all cursor-pointer flex flex-col justify-between ${
                  isSelected
                    ? "bg-gradient-to-b from-amber-500/20 to-amber-500/5 border-amber-400 shadow-xl shadow-amber-500/10 transform scale-[1.02]"
                    : "bg-[#181e2b] border-[#263142] hover:border-gray-500 hover:bg-[#1a2130]"
                }`}
              >
                {plan.badge && (
                  <div className="absolute -top-2.5 left-1/2 -translate-x-1/2 px-2.5 py-0.5 rounded-full bg-gradient-to-r from-amber-500 to-yellow-400 text-black font-black text-[9px] shadow">
                    {plan.badge}
                  </div>
                )}

                <div>
                  <h3 className="font-bold text-sm text-white">{plan.name}</h3>
                  <div className="mt-2 flex items-baseline gap-1">
                    <span className="text-2xl lg:text-3xl font-black text-white">
                      ₹{plan.price}
                    </span>
                    <span className="text-xs text-gray-400">/{plan.period}</span>
                  </div>
                  <p className="text-[11px] text-gray-400 mt-1">{plan.description}</p>
                </div>

                <div className="mt-4 pt-3 border-t border-[#263142] space-y-2">
                  {plan.features.slice(0, 3).map((feat, idx) => (
                    <div key={idx} className="flex items-center gap-1.5 text-[11px] text-gray-300">
                      <Check className="w-3 h-3 text-amber-400 shrink-0" />
                      <span className="truncate">{feat}</span>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {/* Feature Highlights */}
        <div className="p-3.5 rounded-2xl bg-[#11141c] border border-[#222938] flex items-center justify-around text-center mb-6">
          <div>
            <p className="text-xs font-bold text-white">1080p Master</p>
            <p className="text-[10px] text-gray-400">Uncompressed clarity</p>
          </div>
          <div className="w-[1px] h-6 bg-[#222938]" />
          <div>
            <p className="text-xs font-bold text-white">Zero Watermark</p>
            <p className="text-[10px] text-gray-400">100% clean output</p>
          </div>
          <div className="w-[1px] h-6 bg-[#222938]" />
          <div>
            <p className="text-xs font-bold text-white">All 14 Templates</p>
            <p className="text-[10px] text-gray-400">VIP motion effects</p>
          </div>
        </div>

        {/* Checkout Action */}
        <div className="space-y-3">
          <button
            onClick={() => onSelectPlan(selectedPlanId)}
            className="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-amber-500 via-amber-400 to-yellow-400 hover:from-amber-400 hover:to-yellow-300 text-black font-black text-sm tracking-wide flex items-center justify-center gap-2 shadow-lg shadow-amber-500/20 transition transform hover:scale-[1.01] active:scale-[0.99]"
          >
            <Sparkles className="w-4 h-4 fill-black" />
            <span>
              CONTINUE WITH{" "}
              {PRICING_PLANS.find((p) => p.id === selectedPlanId)?.name.toUpperCase()} (₹
              {PRICING_PLANS.find((p) => p.id === selectedPlanId)?.price})
            </span>
          </button>

          <div className="flex items-center justify-center gap-1.5 text-[11px] text-gray-400">
            <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
            <span>Secure 256-bit payment via UPI, Cards, Netbanking</span>
          </div>
        </div>
      </div>
    </div>
  );
}
