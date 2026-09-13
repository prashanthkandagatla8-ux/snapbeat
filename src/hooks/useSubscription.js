"use client";

import { useState, useEffect, useCallback } from "react";

const STORAGE_KEY = "snapbeat_pro_subscription";
const SYNC_EVENT = "snapbeat_subscription_sync";

const readSubscriptionFromStorage = () => {
  if (typeof window === "undefined") {
    return { isPro: false, plan: null, expiresAt: null, paymentId: null };
  }

  try {
    const cached = localStorage.getItem(STORAGE_KEY);
    if (!cached) {
      return { isPro: false, plan: null, expiresAt: null, paymentId: null };
    }

    const parsed = JSON.parse(cached);
    const now = Date.now();

    if (parsed && parsed.expiresAt && parsed.expiresAt > now) {
      return {
        isPro: true,
        plan: parsed.plan || "monthly",
        expiresAt: parsed.expiresAt,
        paymentId: parsed.paymentId || null,
      };
    }

    // Expired or invalid
    localStorage.removeItem(STORAGE_KEY);
    return { isPro: false, plan: null, expiresAt: null, paymentId: null };
  } catch {
    return { isPro: false, plan: null, expiresAt: null, paymentId: null };
  }
};

export function useSubscription() {
  const [subscription, setSubscription] = useState({
    isPro: false,
    plan: null,
    expiresAt: null,
    paymentId: null,
  });
  const [isLoaded, setIsLoaded] = useState(false);

  const refreshSubscription = useCallback(() => {
    const current = readSubscriptionFromStorage();
    setSubscription(current);
    setIsLoaded(true);
  }, []);

  useEffect(() => {
    refreshSubscription();

    // Sync across components and tabs
    const handleStorageChange = (e) => {
      if (!e.key || e.key === STORAGE_KEY) {
        refreshSubscription();
      }
    };

    const handleCustomSync = () => {
      refreshSubscription();
    };

    window.addEventListener("storage", handleStorageChange);
    window.addEventListener(SYNC_EVENT, handleCustomSync);

    // Periodic expiry checker (runs every 60s)
    const interval = setInterval(() => {
      const current = readSubscriptionFromStorage();
      setSubscription((prev) => {
        if (prev.isPro !== current.isPro || prev.expiresAt !== current.expiresAt) {
          return current;
        }
        return prev;
      });
    }, 60000);

    return () => {
      window.removeEventListener("storage", handleStorageChange);
      window.removeEventListener(SYNC_EVENT, handleCustomSync);
      clearInterval(interval);
    };
  }, [refreshSubscription]);

  const activatePro = (planId, paymentId = "manual_test") => {
    if (typeof window === "undefined") return;

    // Durations: Weekly = 7 days, Annual/Yearly = 365 days, Monthly = 30 days
    const normalizedPlan = (planId || "monthly").toLowerCase();
    const days = normalizedPlan === "weekly" ? 7 : (normalizedPlan === "annual" || normalizedPlan === "yearly") ? 365 : 30;
    const expiresAt = Date.now() + days * 24 * 60 * 60 * 1000;

    const newSub = {
      isPro: true,
      plan: normalizedPlan === "yearly" ? "annual" : normalizedPlan,
      expiresAt,
      paymentId,
    };

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(newSub));
    } catch {
      // LocalStorage quota or disabled
    }

    setSubscription(newSub);
    window.dispatchEvent(new Event(SYNC_EVENT));
  };

  const cancelPro = () => {
    if (typeof window === "undefined") return;

    try {
      localStorage.removeItem(STORAGE_KEY);
    } catch {
      // LocalStorage error
    }

    const resetSub = {
      isPro: false,
      plan: null,
      expiresAt: null,
      paymentId: null,
    };

    setSubscription(resetSub);
    window.dispatchEvent(new Event(SYNC_EVENT));
  };

  const getDaysRemaining = () => {
    if (!subscription.isPro || !subscription.expiresAt) return 0;
    const diff = subscription.expiresAt - Date.now();
    return Math.max(0, Math.ceil(diff / (24 * 60 * 60 * 1000)));
  };

  const getExpiryDateFormatted = () => {
    if (!subscription.expiresAt) return null;
    try {
      return new Date(subscription.expiresAt).toLocaleDateString(undefined, {
        year: "numeric",
        month: "short",
        day: "numeric",
      });
    } catch {
      return null;
    }
  };

  return {
    isPro: subscription.isPro,
    plan: subscription.plan,
    expiresAt: subscription.expiresAt,
    daysRemaining: getDaysRemaining(),
    expiryDateFormatted: getExpiryDateFormatted(),
    isLoaded,
    activatePro,
    cancelPro,
  };
}

export default useSubscription;
