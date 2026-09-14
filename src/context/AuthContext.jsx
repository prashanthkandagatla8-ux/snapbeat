"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { trackGuestStarted, trackSignupCompleted } from "@/lib/analytics";


const AuthContext = createContext();

const isValidPaymentId = (pid) =>
  typeof pid === "string" &&
  (pid.startsWith("pay_") || pid.startsWith("cf_") || pid.startsWith("cashfree_") || pid.startsWith("order_"));

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);

  // Load stored user from localStorage on mount
  useEffect(() => {
    try {
      const stored = localStorage.getItem("snapbeat_user");
      if (stored) {
        const parsed = JSON.parse(stored);
        // Clear any simulated Pro status if no real payment ID exists
        if (parsed.isPro && !isValidPaymentId(parsed.paymentId)) {
          parsed.isPro = false;
          parsed.planId = null;
          parsed.expiresAt = null;
          localStorage.setItem("snapbeat_user", JSON.stringify(parsed));
        }
        // Check if pro subscription has expired
        if (parsed.isPro && parsed.expiresAt) {
          if (new Date(parsed.expiresAt) < new Date()) {
            parsed.isPro = false;
            parsed.planId = null;
            localStorage.setItem("snapbeat_user", JSON.stringify(parsed));
          }
        }
        setUser(parsed);
      }
    } catch (err) {
      console.error("Failed to load user session", err);
    } finally {
      setLoading(false);
    }
  }, []);

  const signIn = (email, name = "", picture = "") => {
    const cleanEmail = email.trim().toLowerCase();
    // Check if we have records for this user in accounts DB (stored in localStorage under all_users)
    let allUsers = {};
    try {
      allUsers = JSON.parse(localStorage.getItem("snapbeat_all_accounts") || "{}");
    } catch (_) {}

    let existing = allUsers[cleanEmail];
    if (!existing) {
      existing = {
        id: `usr_${Date.now()}`,
        email: cleanEmail,
        name: name.trim() || cleanEmail.split("@")[0],
        picture: picture || null,
        isPro: false,
        planId: null,
        expiresAt: null,
        createdAt: new Date().toISOString(),
      };
    } else {
      // Clear unverified Pro
      if (existing.isPro && !isValidPaymentId(existing.paymentId)) {
        existing.isPro = false;
        existing.planId = null;
      }
      // Check Pro expiry
      if (existing.isPro && existing.expiresAt) {
        if (new Date(existing.expiresAt) < new Date()) {
          existing.isPro = false;
          existing.planId = null;
        }
      }
      // Update name and picture if provided
      if (name && name.trim()) {
        existing.name = name.trim();
      }
      if (picture && picture.trim()) {
        existing.picture = picture.trim();
      }
    }

    // Sync only with real verified payment subscriptions
    try {
      const cachedSub = localStorage.getItem("snapbeat_pro_subscription");
      if (cachedSub) {
        const parsedSub = JSON.parse(cachedSub);
        if (parsedSub?.isPro && isValidPaymentId(parsedSub.paymentId) && parsedSub.expiresAt && parsedSub.expiresAt > Date.now()) {
          existing.isPro = true;
          existing.planId = parsedSub.plan || existing.planId || "weekly";
          existing.paymentId = parsedSub.paymentId;
          existing.expiresAt = new Date(parsedSub.expiresAt).toISOString();
        }
      }
    } catch (_) {}

    allUsers[cleanEmail] = existing;
    try {
      localStorage.setItem("snapbeat_all_accounts", JSON.stringify(allUsers));
      localStorage.setItem("snapbeat_user", JSON.stringify(existing));
    } catch (err) {
      console.warn("Storage write failed", err);
    }

    setUser(existing);
    setIsAuthModalOpen(false);
    trackSignupCompleted("credential", false);
    return existing;
  };

  const signOut = () => {
    setUser(null);
    try {
      localStorage.removeItem("snapbeat_user");
    } catch (_) {}
  };

  const upgradeToPro = (planId, paymentDetails = {}) => {
    if (!paymentDetails?.paymentId || !paymentDetails.paymentId.startsWith("pay_")) {
      console.warn("Pro upgrade blocked: Requires valid payment transaction ID.");
      return;
    }
    const now = new Date();
    let days = 7;
    if (planId === "monthly") days = 30;
    if (planId === "annual") days = 365;

    const expiresAt = new Date(now.getTime() + days * 24 * 60 * 60 * 1000).toISOString();

    const baseUser = user || {
      id: `usr_${Date.now()}`,
      email: "creator@snapbeat.app",
      name: "SnapBeat Creator",
      createdAt: now.toISOString(),
    };

    const updatedUser = {
      ...baseUser,
      isPro: true,
      planId,
      expiresAt,
      paymentId: paymentDetails.paymentId,
      lastPayment: {
        planId,
        date: now.toISOString(),
        paymentId: paymentDetails.paymentId,
      },
    };

    setUser(updatedUser);
    try {
      localStorage.setItem("snapbeat_user", JSON.stringify(updatedUser));
      const allUsers = JSON.parse(localStorage.getItem("snapbeat_all_accounts") || "{}");
      allUsers[updatedUser.email] = updatedUser;
      localStorage.setItem("snapbeat_all_accounts", JSON.stringify(allUsers));
      localStorage.setItem(
        "snapbeat_pro_subscription",
        JSON.stringify({
          isPro: true,
          plan: planId,
          expiresAt: new Date(expiresAt).getTime(),
          paymentId: paymentDetails.paymentId || "demo_pay",
        })
      );
    } catch (_) {}

    return updatedUser;
  };

  const loginAsGuest = () => {
    let guestCount = 1;
    try {
      guestCount = parseInt(localStorage.getItem("snapbeat_guest_count") || "1", 10);
      localStorage.setItem("snapbeat_guest_count", String(guestCount + 1));
    } catch (_) {}

    const guestUser = {
      id: `guest_${Date.now()}`,
      email: `guest_${guestCount}@snapbeat.app`,
      name: `Guest Creator #${guestCount}`,
      picture: null,
      isGuest: true,
      isPro: false,
      planId: null,
      expiresAt: null,
      createdAt: new Date().toISOString(),
    };

    try {
      localStorage.setItem("snapbeat_user", JSON.stringify(guestUser));
    } catch (err) {
      console.warn("Storage write failed", err);
    }

    setUser(guestUser);
    setIsAuthModalOpen(false);
    trackGuestStarted("instant_guest");
    trackSignupCompleted("guest", true);
    return guestUser;
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isPro: Boolean(user?.isPro),
        loading,
        isAuthModalOpen,
        openAuthModal: () => setIsAuthModalOpen(true),
        closeAuthModal: () => setIsAuthModalOpen(false),
        signIn,
        loginAsGuest,
        signOut,
        upgradeToPro,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
