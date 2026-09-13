"use client";

import { PRICING_PLANS } from "@/lib/constants";

/**
 * Executes demo simulation checkout when no live key is available or network fails.
 */
function runDemoCheckout(plan, onPaymentSuccess, onPaymentCancel) {
  if (typeof window === "undefined") return;

  const periodLabel = plan.period || (plan.id === "weekly" ? "week" : plan.id === "annual" ? "year" : "month");
  const confirmPayment = window.confirm(
    `[SNAPBEAT PRO STUDIO — DEMO CHECKOUT]\n\n` +
    `Plan: ${plan.name} (₹${plan.price}/${periodLabel})\n` +
    `Perks: 1080p Master Quality + Zero Watermark + All 14 Templates + Title Cards\n\n` +
    `Click OK to simulate a successful payment and activate Pro instantly!`
  );

  if (confirmPayment) {
    if (typeof onPaymentSuccess === "function") {
      onPaymentSuccess(plan.id, `sim_${Date.now()}`);
    }
  } else {
    if (typeof onPaymentCancel === "function") {
      onPaymentCancel();
    }
  }
}

/**
 * Initializes Razorpay Standard Checkout or gracefully falls back to Demo mode.
 */
export function initializeRazorpayCheckout(planId, onPaymentSuccess, onPaymentCancel) {
  if (typeof window === "undefined") return;

  const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];
  const razorpayKey = (process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID || "").trim();
  const periodLabel = plan.period || (plan.id === "weekly" ? "week" : plan.id === "annual" ? "year" : "month");

  const openRazorpayModal = () => {
    try {
      const options = {
        key: razorpayKey,
        amount: plan.price * 100, // in paise
        currency: "INR",
        name: "SnapBeat Pro Studio",
        description: `${plan.name} (₹${plan.price}/${periodLabel}) - 1080p Master & No Watermark`,
        image: "/assets/images/snapbeat_app_icon.png",
        theme: { color: "#ffc72c" },
        handler: function (response) {
          if (typeof onPaymentSuccess === "function") {
            onPaymentSuccess(plan.id, response.razorpay_payment_id || `rzp_${Date.now()}`);
          }
        },
        modal: {
          ondismiss: function () {
            if (typeof onPaymentCancel === "function") {
              onPaymentCancel();
            }
          },
        },
      };

      const rzp = new window.Razorpay(options);
      rzp.on("payment.failed", function (response) {
        alert(`Payment failed: ${response.error?.description || "Unknown error"}`);
        if (typeof onPaymentCancel === "function") {
          onPaymentCancel();
        }
      });
      rzp.open();
    } catch (err) {
      alert("Error opening payment window: " + (err.message || "Unknown error"));
      runDemoCheckout(plan, onPaymentSuccess, onPaymentCancel);
    }
  };

  // If Razorpay live/test key is present, open Razorpay Standard Checkout
  if (razorpayKey) {
    if (window.Razorpay) {
      openRazorpayModal();
      return;
    }

    // Check if script is already injected
    const existingScript = document.querySelector('script[src="https://checkout.razorpay.com/v1/checkout.js"]');
    if (existingScript) {
      existingScript.addEventListener("load", openRazorpayModal);
      return;
    }

    const script = document.createElement("script");
    script.src = "https://checkout.razorpay.com/v1/checkout.js";
    script.async = true;
    script.onload = openRazorpayModal;
    script.onerror = () => {
      runDemoCheckout(plan, onPaymentSuccess, onPaymentCancel);
    };
    document.body.appendChild(script);
    return;
  }

  // If key not configured, run demo simulation checkout
  runDemoCheckout(plan, onPaymentSuccess, onPaymentCancel);
}

export default initializeRazorpayCheckout;
