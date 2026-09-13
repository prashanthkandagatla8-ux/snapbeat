"use client";

import React, { useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { X, Mail, User, ShieldCheck, Sparkles } from "lucide-react";

export default function RetroAuthModal({ onSuccess }) {
  const { isAuthModalOpen, closeAuthModal, signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [error, setError] = useState("");

  if (!isAuthModalOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!email.trim() || !email.includes("@")) {
      setError("Please enter a valid email address");
      return;
    }
    setError("");
    const loggedUser = signIn(email, name);
    if (onSuccess) onSuccess(loggedUser);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn">
      <div className="relative w-full max-w-md metal-panel rounded-3xl p-6 sm:p-8 shadow-2xl border-2 border-[#7a766f] animate-scaleUp">
        {/* Brass Screws */}
        <div className="metal-screw top-3 left-3" />
        <div className="metal-screw top-3 right-3" />
        <div className="metal-screw bottom-3 left-3" />
        <div className="metal-screw bottom-3 right-3" />

        {/* Close Button */}
        <button
          onClick={closeAuthModal}
          className="absolute top-4 right-4 p-1.5 rounded-full hover:bg-black/10 text-[#4a4743] hover:text-[#2b2b2d] transition"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header */}
        <div className="text-center space-y-2 mb-6">
          <div className="inline-flex items-center justify-center p-2 rounded-2xl metal-inset shadow-inner mx-auto">
            <img
              src="/assets/images/snapbeat_app_icon.png"
              alt="SnapBeat"
              className="w-14 h-14 rounded-xl object-contain drop-shadow"
            />
          </div>
          <h2 className="text-xl font-black tracking-wider text-[#2b2b2d] uppercase">
            Sign In to SnapBeat
          </h2>
          <p className="text-xs text-[#5a5752] font-semibold">
            Track your queued renders, unlock Pro passes, and save your creations.
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-[11px] font-black text-[#4a4743] uppercase tracking-wider mb-1.5">
              Your Email Address <span className="text-amber-600">*</span>
            </label>
            <div className="relative flex items-center">
              <Mail className="w-4 h-4 absolute left-3.5 text-[#6e695f] pointer-events-none" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@example.com"
                className="w-full pl-10 pr-4 py-3 rounded-xl metal-inset text-sm font-bold text-[#2b2b2d] placeholder-[#8f8a80] focus:outline-none focus:ring-2 focus:ring-amber-500 border border-[#8f8677]/60"
              />
            </div>
          </div>

          <div>
            <label className="block text-[11px] font-black text-[#4a4743] uppercase tracking-wider mb-1.5">
              Your Name / Creator Handle (Optional)
            </label>
            <div className="relative flex items-center">
              <User className="w-4 h-4 absolute left-3.5 text-[#6e695f] pointer-events-none" />
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Alex"
                className="w-full pl-10 pr-4 py-3 rounded-xl metal-inset text-sm font-bold text-[#2b2b2d] placeholder-[#8f8a80] focus:outline-none focus:ring-2 focus:ring-amber-500 border border-[#8f8677]/60"
              />
            </div>
          </div>

          {error && (
            <p className="text-xs font-bold text-red-600 bg-red-50 p-2 rounded-lg border border-red-200 text-center">
              {error}
            </p>
          )}

          {/* Benefits bullets */}
          <div className="p-3 rounded-xl metal-inset space-y-1.5 text-[11px] font-bold text-[#4a4743]">
            <div className="flex items-center gap-2 text-[#3b3834]">
              <Sparkles className="w-3.5 h-3.5 text-amber-500 shrink-0" />
              <span>Unlimited free 720p beat-synced renders</span>
            </div>
            <div className="flex items-center gap-2 text-[#3b3834]">
              <ShieldCheck className="w-3.5 h-3.5 text-amber-500 shrink-0" />
              <span>Securely links your ₹99 / ₹199 / ₹999 Pro Passes</span>
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full py-3.5 rounded-2xl font-black text-xs uppercase tracking-wider btn-brass text-[#2b2820] shadow-md hover:brightness-110 active:scale-[0.98] transition flex items-center justify-center gap-2"
          >
            <span>CONTINUE TO STUDIO</span>
          </button>
        </form>

        <p className="text-[10px] text-center text-[#6e695f] mt-4 font-semibold">
          By continuing, you agree to SnapBeat's Terms of Service and Privacy Policy.
        </p>
      </div>
    </div>
  );
}
