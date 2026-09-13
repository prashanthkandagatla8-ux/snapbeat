"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

const AuthContext = createContext();

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

  const signIn = (email, name = "") => {
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
        isPro: false,
        planId: null,
        expiresAt: null,
        createdAt: new Date().toISOString(),
      };
    } else {
      // Check Pro expiry
      if (existing.isPro && existing.expiresAt) {
        if (new Date(existing.expiresAt) < new Date()) {
          existing.isPro = false;
          existing.planId = null;
        }
      }
      // Update name if provided
      if (name && name.trim()) {
        existing.name = name.trim();
      }
    }

    // Sync with any device-level subscription active on this machine
    try {
      const cachedSub = localStorage.getItem("snapbeat_pro_subscription");
      if (cachedSub) {
        const parsedSub = JSON.parse(cachedSub);
        if (parsedSub?.isPro && parsedSub.expiresAt && parsedSub.expiresAt > Date.now()) {
          existing.isPro = true;
          existing.planId = parsedSub.plan || existing.planId || "weekly";
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
    return existing;
  };

  const signOut = () => {
    setUser(null);
    try {
      localStorage.removeItem("snapbeat_user");
    } catch (_) {}
  };

  const upgradeToPro = (planId, paymentDetails = {}) => {
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
      lastPayment: {
        planId,
        date: now.toISOString(),
        paymentId: paymentDetails.paymentId || "demo_pay",
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
