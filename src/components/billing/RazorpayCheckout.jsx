"use client";

import { useEffect } from "react";
import { PRICING_PLANS } from "@/lib/constants";

export function initializeRazorpayCheckout(planId, onPaymentSuccess, onPaymentCancel) {
  const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];
  const razorpayKey = process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID || "";

  // If Razorpay live key is present, open Razorpay Standard Checkout
  if (razorpayKey && typeof window !== "undefined") {
    const script = document.createElement("script");
    script.src = "https://checkout.razorpay.com/v1/checkout.js";
    script.async = true;
    script.onload = () => {
      const options = {
        key: razorpayKey,
        amount: plan.price * 100, // in paise
        currency: "INR",
        name: "SnapBeat Pro Studio",
        description: `${plan.name} (${plan.period}) - 1080p Master Exports & No Watermark`,
        theme: { color: "#e6a100" },
        handler: function (response) {
          onPaymentSuccess(plan.id, response.razorpay_payment_id || "rzp_test_success");
        },
        modal: {
          ondismiss: function () {
            if (onPaymentCancel) onPaymentCancel();
          },
        },
      };

      const rzp = new window.Razorpay(options);
      rzp.open();
    };
    document.body.appendChild(script);
    return;
  }

  // If key not configured yet, present a test checkout confirmation
  const confirmPayment = window.confirm(
    `[TEST MODE / DEMO CHECKOUT]\n\nPlan: ${plan.name} (₹${plan.price} / ${plan.period})\nFeatures: 1080p Master + No Watermark + All Templates\n\nClick OK to simulate successful payment and unlock Pro!`
  );

  if (confirmPayment) {
    onPaymentSuccess(plan.id, `sim_${Date.now()}`);
  } else if (onPaymentCancel) {
    onPaymentCancel();
  }
}
