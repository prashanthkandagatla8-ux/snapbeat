"use client";

import React, { useState, useEffect, useRef } from "react";
import { useAuth } from "@/context/AuthContext";
import { X, Mail, User, ShieldCheck, Sparkles, AlertCircle } from "lucide-react";

export default function RetroAuthModal({ onSuccess }) {
  const { isAuthModalOpen, closeAuthModal, signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [error, setError] = useState("");

  const handleClose = () => {
    setError("");
    closeAuthModal();
  };

  // Keyboard escape listener to dismiss modal
  useEffect(() => {
    if (!isAuthModalOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === "Escape") {
        handleClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isAuthModalOpen]);

  if (!isAuthModalOpen) return null;

  const [googleScriptLoaded, setGoogleScriptLoaded] = useState(false);
  const [googleModeNotice, setGoogleModeNotice] = useState(false);
  const googleBtnRef = useRef(null);

  // Load Google Identity Services (GIS)
  useEffect(() => {
    if (typeof window === "undefined") return;

    // Check if script already added
    if (document.getElementById("google-gsi-client")) {
      setGoogleScriptLoaded(true);
      return;
    }

    const script = document.createElement("script");
    script.id = "google-gsi-client";
    script.src = "https://accounts.google.com/gsi/client";
    script.async = true;
    script.defer = true;
    script.onload = () => {
      setGoogleScriptLoaded(true);
    };
    script.onerror = () => {
      console.warn("Google Identity Services script failed to load");
    };
    document.body.appendChild(script);
  }, []);

  // Initialize GIS if Google Client ID is configured
  useEffect(() => {
    if (!googleScriptLoaded || !window.google?.accounts?.id) return;

    const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;
    if (!clientId) return;

    try {
      window.google.accounts.id.initialize({
        client_id: clientId,
        callback: handleGoogleCredentialResponse,
        auto_select: false,
        cancel_on_tap_outside: true,
      });

      if (googleBtnRef.current) {
        googleBtnRef.current.innerHTML = "";
        window.google.accounts.id.renderButton(googleBtnRef.current, {
          theme: "outline",
          size: "large",
          type: "standard",
          shape: "rectangular",
          text: "continue_with",
          logo_alignment: "left",
          width: 320,
        });
      }
    } catch (err) {
      console.error("GIS initialization error:", err);
    }
  }, [googleScriptLoaded, isAuthModalOpen]);

  // Decode JWT payload safely without extra libraries
  const decodeJwt = (token) => {
    try {
      const base64Url = token.split(".")[1];
      const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
      const jsonPayload = decodeURIComponent(
        atob(base64)
          .split("")
          .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
          .join("")
      );
      return JSON.parse(jsonPayload);
    } catch (e) {
      console.error("Failed to decode token", e);
      return null;
    }
  };

  const handleGoogleCredentialResponse = (response) => {
    if (response?.credential) {
      const payload = decodeJwt(response.credential);
      if (payload && payload.email) {
        setError("");
        const realName = payload.name || payload.given_name || payload.email.split("@")[0];
        const realEmail = payload.email;
        const realPicture = payload.picture || "";
        const loggedUser = signIn(realEmail, realName, realPicture);
        if (onSuccess) onSuccess(loggedUser);
      }
    }
  };

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

  const handleGoogleSignInClick = () => {
    setError("");
    // If user already typed an email, use it directly
    if (email.trim() && email.includes("@")) {
      const loggedUser = signIn(email.trim(), name.trim() || email.trim().split("@")[0]);
      if (onSuccess) onSuccess(loggedUser);
      return;
    }

    // If Google GIS client ID is not configured in environment, prompt user to enter their actual email
    setGoogleModeNotice(true);
    const emailInput = document.getElementById("auth-email-input");
    if (emailInput) {
      emailInput.focus();
    }
  };

  return (
    <div
      onClick={(e) => {
        if (e.target === e.currentTarget) handleClose();
      }}
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn"
      role="dialog"
      aria-modal="true"
      aria-labelledby="auth-modal-title"
    >
      <div className="relative w-full max-w-md metal-panel rounded-3xl p-6 sm:p-8 shadow-2xl border-2 border-[#7a766f] animate-scaleUp">
        {/* Brass Screws */}
        <div className="metal-screw top-3 left-3 pointer-events-none" />
        <div className="metal-screw top-3 right-3 pointer-events-none" />
        <div className="metal-screw bottom-3 left-3 pointer-events-none" />
        <div className="metal-screw bottom-3 right-3 pointer-events-none" />

        {/* Close Button */}
        <button
          type="button"
          onClick={handleClose}
          aria-label="Close sign-in modal"
          className="absolute top-4 right-4 p-1.5 rounded-full hover:bg-black/10 text-[#4a4743] hover:text-[#2b2b2d] transition"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header with PNG logo */}
        <div className="text-center space-y-2 mb-6">
          <div className="inline-flex items-center justify-center p-2 rounded-2xl metal-inset shadow-inner mx-auto mb-1">
            <img
              src="/assets/images/snapbeat_app_icon.png"
              alt="SnapBeat App Icon"
              className="w-12 h-12 rounded-xl object-contain drop-shadow"
            />
          </div>
          <div className="flex justify-center" id="auth-modal-title">
            <img
              src="/assets/images/snapbeat_logo_crop.png"
              alt="SnapBeat Logo"
              className="h-9 w-auto object-contain drop-shadow"
            />
          </div>
          <p className="text-xs text-[#5a5752] font-semibold">
            Track your queued renders, save creations, and manage Pro passes.
          </p>
        </div>

        {/* Google 1-Click Sign-In Container */}
        <div className="space-y-4">
          {/* Official Google Identity Services Button Container (if GIS client id configured) */}
          <div ref={googleBtnRef} className="w-full flex justify-center empty:hidden" />

          {/* Standard Google Sign-In Button */}
          {(!process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || !googleScriptLoaded) && (
            <button
              type="button"
              onClick={handleGoogleSignInClick}
              className="w-full py-3 px-4 rounded-2xl bg-white hover:bg-gray-50 text-gray-800 font-bold text-xs border border-gray-300 shadow flex items-center justify-center gap-3 transition active:scale-[0.98] cursor-pointer"
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
          )}

          {googleModeNotice && (
            <div className="p-2.5 rounded-xl bg-amber-500/15 border border-amber-500/40 text-amber-950 text-[11px] font-bold flex items-center gap-2 animate-fadeIn">
              <AlertCircle className="w-4 h-4 text-amber-600 shrink-0" />
              <span>Please enter your Google or creator email below to sign in:</span>
            </div>
          )}

          {/* Divider */}
          <div className="flex items-center gap-3">
            <div className="h-[1px] flex-1 bg-[#8f8677]/60" />
            <span className="text-[10px] font-mono font-bold text-[#6e695f] uppercase">OR EMAIL ACCOUNT</span>
            <div className="h-[1px] flex-1 bg-[#8f8677]/60" />
          </div>

          {/* Email Form */}
          <form onSubmit={handleSubmit} className="space-y-3.5">
            <div>
              <label htmlFor="auth-email-input" className="block text-[11px] font-black text-[#4a4743] uppercase tracking-wider mb-1">
                Your Email Address <span className="text-amber-600">*</span>
              </label>
              <div className="relative flex items-center">
                <Mail className="w-4 h-4 absolute left-3.5 text-[#6e695f] pointer-events-none" />
                <input
                  id="auth-email-input"
                  type="email"
                  required
                  autoComplete="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@example.com"
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl metal-inset text-xs font-bold text-[#2b2b2d] placeholder-[#8f8a80] focus:outline-none focus:ring-2 focus:ring-amber-500 border border-[#8f8677]/60"
                />
              </div>
            </div>

            <div>
              <label htmlFor="auth-name-input" className="block text-[11px] font-black text-[#4a4743] uppercase tracking-wider mb-1">
                Your Name / Creator Handle (Optional)
              </label>
              <div className="relative flex items-center">
                <User className="w-4 h-4 absolute left-3.5 text-[#6e695f] pointer-events-none" />
                <input
                  id="auth-name-input"
                  type="text"
                  autoComplete="name"
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
