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

  const handleGoogleSignIn = () => {
    // Fast 1-click Google OAuth / Sign-in prompt
    const promptEmail = window.prompt("Sign in with Google Account (enter your Google email):", "creator@gmail.com");
    if (promptEmail && promptEmail.includes("@")) {
      const loggedUser = signIn(promptEmail, "Google Creator");
      if (onSuccess) onSuccess(loggedUser);
    }
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

        {/* Header with cut-off PNG logo */}
        <div className="text-center space-y-2 mb-6">
          <div className="inline-flex items-center justify-center p-2 rounded-2xl metal-inset shadow-inner mx-auto mb-1">
            <img
              src="/assets/images/snapbeat_app_icon.png"
              alt="SnapBeat"
              className="w-12 h-12 rounded-xl object-contain drop-shadow"
            />
          </div>
          <div className="flex justify-center">
            <img
              src="/assets/images/snapbeat_logo_crop.png"
              alt="SnapBeat"
              className="h-9 w-auto object-contain drop-shadow"
            />
          </div>
          <p className="text-xs text-[#5a5752] font-semibold">
            Track your queued renders, save creations, and manage Pro passes.
          </p>
        </div>

        {/* Google 1-Click Sign-In Button */}
        <div className="space-y-4">
          <button
            type="button"
            onClick={handleGoogleSignIn}
            className="w-full py-3 px-4 rounded-2xl bg-white hover:bg-gray-50 text-gray-800 font-bold text-xs border border-gray-300 shadow flex items-center justify-center gap-3 transition active:scale-[0.98]"
          >
            <svg className="w-4 h-4" viewBox="0 0 24 24">
              <path
                fill="#4285F4"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              />
              <path
                fill="#34A853"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              />
              <path
                fill="#FBBC05"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
              />
              <path
                fill="#EA4335"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
              />
            </svg>
            <span>CONTINUE WITH GOOGLE</span>
          </button>

          {/* Divider */}
          <div className="flex items-center gap-3">
            <div className="h-[1px] flex-1 bg-[#8f8677]/60" />
            <span className="text-[10px] font-mono font-bold text-[#6e695f] uppercase">OR EMAIL</span>
            <div className="h-[1px] flex-1 bg-[#8f8677]/60" />
          </div>

          {/* Email Form */}
          <form onSubmit={handleSubmit} className="space-y-3.5">
            <div>
              <label className="block text-[11px] font-black text-[#4a4743] uppercase tracking-wider mb-1">
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
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl metal-inset text-xs font-bold text-[#2b2b2d] placeholder-[#8f8a80] focus:outline-none focus:ring-2 focus:ring-amber-500 border border-[#8f8677]/60"
                />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-black text-[#4a4743] uppercase tracking-wider mb-1">
                Your Name / Creator Handle (Optional)
              </label>
              <div className="relative flex items-center">
                <User className="w-4 h-4 absolute left-3.5 text-[#6e695f] pointer-events-none" />
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="e.g. Alex"
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl metal-inset text-xs font-bold text-[#2b2b2d] placeholder-[#8f8a80] focus:outline-none focus:ring-2 focus:ring-amber-500 border border-[#8f8677]/60"
                />
              </div>
            </div>

            {error && (
              <p className="text-xs font-bold text-red-600 bg-red-50 p-2 rounded-lg border border-red-200 text-center">
                {error}
              </p>
            )}

            {/* Benefits bullets */}
            <div className="p-2.5 rounded-xl metal-inset space-y-1 text-[11px] font-bold text-[#4a4743]">
              <div className="flex items-center gap-2 text-[#3b3834]">
                <Sparkles className="w-3.5 h-3.5 text-amber-500 shrink-0" />
                <span>Unlimited free 720p beat-synced renders</span>
              </div>
              <div className="flex items-center gap-2 text-[#3b3834]">
                <ShieldCheck className="w-3.5 h-3.5 text-amber-500 shrink-0" />
                <span>Tracks your ₹99 / ₹199 / ₹999 Pro Passes across devices</span>
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
        </div>

        <p className="text-[10px] text-center text-[#6e695f] mt-4 font-semibold">
          By continuing, you agree to SnapBeat's Terms of Service and Privacy Policy.
        </p>
      </div>
    </div>
  );
}
