import { PRICING_PLANS } from "@/lib/constants";
import { trackPurchaseCompleted } from "@/lib/analytics";

/**
 * Initializes Razorpay Standard Checkout or informs user that payments are currently pending approval.
 */
export function initializeRazorpayCheckout(planId, onPaymentSuccess, onPaymentCancel) {
  if (typeof window === "undefined") return;

  const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];
  const razorpayKey = (process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID || "").trim();
  const periodLabel = plan.period || (plan.id === "weekly" ? "week" : plan.id === "annual" ? "year" : "month");

  // If Razorpay live/test key is configured, attempt real checkout
  if (razorpayKey) {
    const openRazorpayModal = () => {
      try {
        const options = {
          key: razorpayKey,
          amount: plan.price * 100, // in paise
          currency: "INR",
          name: "SnapBeat Pro Studio",
          description: `${plan.name} (₹${plan.price}/${periodLabel}) - 1080p Master & No Watermark`,
          image: "/assets/images/snapbeat_logo_crop.png",
          theme: { color: "#ffc72c" },
          handler: function (response) {
            if (response?.razorpay_payment_id) {
              trackPurchaseCompleted({
                planName: plan.id,
                value: plan.price,
                currency: "INR",
                transactionId: response.razorpay_payment_id,
              });
              if (typeof onPaymentSuccess === "function") {
                onPaymentSuccess(plan.id, response.razorpay_payment_id);
              }
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
          alert(`Payment failed: ${response.error?.description || "Payment was not completed"}`);
          if (typeof onPaymentCancel === "function") {
            onPaymentCancel();
          }
        });
        rzp.open();
      } catch (err) {
        alert("Payment gateway error: " + (err.message || "Could not initialize checkout"));
        if (typeof onPaymentCancel === "function") {
          onPaymentCancel();
        }
      }
    };

    if (window.Razorpay) {
      openRazorpayModal();
      return;
    }

    const script = document.createElement("script");
    script.src = "https://checkout.razorpay.com/v1/checkout.js";
    script.async = true;
    script.onload = openRazorpayModal;
    script.onerror = () => {
      alert("Unable to load Razorpay payment gateway. Please check your internet connection.");
      if (typeof onPaymentCancel === "function") onPaymentCancel();
    };
    document.body.appendChild(script);
    return;
  }

  // If Razorpay is not yet approved / configured, do NOT activate Pro!
  alert(
    "PRO STUDIO PASS — PAYMENT GATEWAY IN REVIEW\n\n" +
    "Online payments via Razorpay are currently under verification and will go live shortly.\n\n" +
    "Free tier reel renders remain available for all creators!"
  );
  if (typeof onPaymentCancel === "function") {
    onPaymentCancel();
  }
}

export default initializeRazorpayCheckout;
