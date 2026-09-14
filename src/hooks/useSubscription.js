"use client";

import { useState, useEffect, useCallback } from "react";

const STORAGE_KEY = "snapbeat_pro_subscription";
const DEVICE_KEY = "snapbeat_device_id";
const TOKEN_KEY = "snapbeat_pro_token";
const SYNC_EVENT = "snapbeat_subscription_sync";

export const getOrCreateDeviceId = () => {
  if (typeof window === "undefined") return "server_device";
  try {
    let devId = localStorage.getItem(DEVICE_KEY);
    if (!devId) {
      devId = "sb_dev_" + Date.now() + "_" + Math.random().toString(36).slice(2, 9);
      localStorage.setItem(DEVICE_KEY, devId);
    }
    return devId;
  } catch {
    return "fallback_device";
  }
};

const readSubscriptionFromStorage = () => {
  if (typeof window === "undefined") {
    return { isPro: false, plan: null, expiresAt: null, paymentId: null, token: null };
  }

  try {
    const cached = localStorage.getItem(STORAGE_KEY);
    const token = localStorage.getItem(TOKEN_KEY);
    if (!cached) {
      return { isPro: false, plan: null, expiresAt: null, paymentId: null, token: null };
    }

    const parsed = JSON.parse(cached);
    const now = Date.now();

    const isRealPayment =
      typeof parsed.paymentId === "string" &&
      (parsed.paymentId.startsWith("cf_") ||
        parsed.paymentId.startsWith("pay_") ||
        parsed.paymentId.startsWith("cashfree_") ||
        parsed.paymentId.startsWith("order_"));

    if (parsed && parsed.expiresAt && parsed.expiresAt > now && isRealPayment) {
      return {
        isPro: true,
        plan: parsed.plan || "monthly",
        expiresAt: parsed.expiresAt,
        paymentId: parsed.paymentId,
        token: token || parsed.token || null,
      };
    }

    // Expired: clear out
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(TOKEN_KEY);
    return { isPro: false, plan: null, expiresAt: null, paymentId: null, token: null };
  } catch {
    return { isPro: false, plan: null, expiresAt: null, paymentId: null, token: null };
  }
};

export function useSubscription() {
  const [subscription, setSubscription] = useState({
    isPro: false,
    plan: null,
    expiresAt: null,
    paymentId: null,
    token: null,
  });
  const [isLoaded, setIsLoaded] = useState(false);

  const refreshSubscription = useCallback(() => {
    const current = readSubscriptionFromStorage();
    setSubscription(current);
    setIsLoaded(true);
  }, []);

  // Server-side ground truth verification (Anti-Cheat & Cross-Device Sync)
  const verifyWithServer = useCallback(async () => {
    if (typeof window === "undefined") return;
    try {
      const deviceId = getOrCreateDeviceId();
      const token = localStorage.getItem(TOKEN_KEY);
      const userCached = localStorage.getItem("snapbeat_user");
      let email = null;
      try {
        email = userCached ? JSON.parse(userCached).email : null;
      } catch (_) {}

      const res = await fetch("/api/account/status", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token, email, deviceId }),
      });

      if (res.ok) {
        const data = await res.json();
        if (data.isPro && data.valid) {
          const expiresAt = data.expiresAt ? new Date(data.expiresAt).getTime() : Date.now() + 30 * 86400000;
          const updated = {
            isPro: true,
            plan: data.planId || "monthly",
            expiresAt,
            paymentId: data.paymentId || "verified",
            token: data.proToken || token,
          };
          localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
          if (data.proToken) localStorage.setItem(TOKEN_KEY, data.proToken);
          setSubscription(updated);
        } else {
          // If server reports not pro or invalid token, revoke any tampered local state
          const cached = localStorage.getItem(STORAGE_KEY);
          if (cached) {
            localStorage.removeItem(STORAGE_KEY);
            localStorage.removeItem(TOKEN_KEY);
            setSubscription({ isPro: false, plan: null, expiresAt: null, paymentId: null, token: null });
            window.dispatchEvent(new Event(SYNC_EVENT));
          }
        }
      }
    } catch (e) {
      console.warn("Could not verify subscription with server:", e);
    }
  }, []);

  useEffect(() => {
    refreshSubscription();
    verifyWithServer();

    // Sync across components and tabs
    const handleStorageChange = (e) => {
      if (!e.key || e.key === STORAGE_KEY || e.key === TOKEN_KEY) {
        refreshSubscription();
      }
    };

    const handleCustomSync = () => {
      refreshSubscription();
    };

    window.addEventListener("storage", handleStorageChange);
    window.addEventListener(SYNC_EVENT, handleCustomSync);

    // Periodic check (runs every 60s)
    const interval = setInterval(() => {
      const current = readSubscriptionFromStorage();
      setSubscription((prev) => {
        if (prev.isPro !== current.isPro || prev.expiresAt !== current.expiresAt) {
          return current;
        }
        return prev;
      });
      verifyWithServer();
    }, 60000);

    return () => {
      window.removeEventListener("storage", handleStorageChange);
      window.removeEventListener(SYNC_EVENT, handleCustomSync);
      clearInterval(interval);
    };
  }, [refreshSubscription, verifyWithServer]);

  const activatePro = (planId, paymentId = "", proToken = null) => {
    if (typeof window === "undefined") return;

    const isRealPayment =
      typeof paymentId === "string" &&
      (paymentId.startsWith("cf_") ||
        paymentId.startsWith("pay_") ||
        paymentId.startsWith("cashfree_") ||
        paymentId.startsWith("order_"));

    if (!paymentId || !isRealPayment) {
      alert("Pro passes require a verified payment gateway transaction. Please complete payment via Cashfree or Razorpay.");
      return;
    }

    const normalizedPlan = (planId || "monthly").toLowerCase();
    const days = normalizedPlan === "weekly" ? 7 : (normalizedPlan === "annual" || normalizedPlan === "yearly") ? 365 : 30;
    const expiresAt = Date.now() + days * 24 * 60 * 60 * 1000;

    const newSub = {
      isPro: true,
      plan: normalizedPlan === "yearly" ? "annual" : normalizedPlan,
      expiresAt,
      paymentId,
      token: proToken,
    };

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(newSub));
      if (proToken) {
        localStorage.setItem(TOKEN_KEY, proToken);
      }
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
      localStorage.removeItem(TOKEN_KEY);
    } catch {
      // LocalStorage error
    }

    const resetSub = {
      isPro: false,
      plan: null,
      expiresAt: null,
      paymentId: null,
      token: null,
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
    token: subscription.token,
    isLoaded,
    activatePro,
    cancelPro,
  };
}

export default useSubscription;
