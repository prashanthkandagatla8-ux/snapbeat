"use client";

import { useState, useEffect } from "react";

const STORAGE_KEY = "snapbeat_pro_subscription";

export function useSubscription() {
  const [subscription, setSubscription] = useState({
    isPro: false,
    plan: null,
    expiresAt: null,
    paymentId: null,
  });
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    try {
      const cached = localStorage.getItem(STORAGE_KEY);
      if (cached) {
        const parsed = JSON.parse(cached);
        const now = Date.now();
        if (parsed.expiresAt && parsed.expiresAt > now) {
          setSubscription({
            isPro: true,
            plan: parsed.plan,
            expiresAt: parsed.expiresAt,
            paymentId: parsed.paymentId,
          });
        } else {
          // Expired
          localStorage.removeItem(STORAGE_KEY);
        }
      }
    } catch (e) {
      console.warn("Failed to load subscription from storage:", e);
    } finally {
      setIsLoaded(true);
    }
  }, []);

  const activatePro = (planId, paymentId = "manual_test") => {
    const days = planId === "weekly" ? 7 : planId === "annual" ? 365 : 30;
    const expiresAt = Date.now() + days * 24 * 60 * 60 * 1000;
    
    const newSub = {
      isPro: true,
      plan: planId,
      expiresAt,
      paymentId,
    };

    localStorage.setItem(STORAGE_KEY, JSON.stringify(newSub));
    setSubscription(newSub);
  };

  const cancelPro = () => {
    localStorage.removeItem(STORAGE_KEY);
    setSubscription({
      isPro: false,
      plan: null,
      expiresAt: null,
      paymentId: null,
    });
  };

  const getDaysRemaining = () => {
    if (!subscription.isPro || !subscription.expiresAt) return 0;
    const diff = subscription.expiresAt - Date.now();
    return Math.max(0, Math.ceil(diff / (24 * 60 * 60 * 1000)));
  };

  return {
    isPro: subscription.isPro,
    plan: subscription.plan,
    expiresAt: subscription.expiresAt,
    daysRemaining: getDaysRemaining(),
    isLoaded,
    activatePro,
    cancelPro,
  };
}
