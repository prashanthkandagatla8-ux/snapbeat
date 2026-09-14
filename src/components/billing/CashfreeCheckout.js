import { PRICING_PLANS } from "@/lib/constants";
import { trackPurchaseStarted, trackPurchaseCompleted } from "@/lib/analytics";

let cashfreeSdkPromise = null;

/**
 * Dynamically loads the official Cashfree JS SDK v3
 */
function loadCashfreeSDK() {
  if (typeof window === "undefined") return Promise.reject(new Error("Window not available"));
  if (window.Cashfree) return Promise.resolve(window.Cashfree);

  if (!cashfreeSdkPromise) {
    cashfreeSdkPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = "https://sdk.cashfree.com/js/v3/cashfree.js";
      script.async = true;
      script.onload = () => {
        if (window.Cashfree) {
          resolve(window.Cashfree);
        } else {
          reject(new Error("Cashfree SDK failed to initialize"));
        }
      };
      script.onerror = () => {
        reject(new Error("Failed to load Cashfree checkout SDK. Please check your connection."));
      };
      document.body.appendChild(script);
    });
  }

  return cashfreeSdkPromise;
}

/**
 * Initializes Cashfree Seamless Checkout
 *
 * @param {string} planId - "weekly" | "monthly" | "annual"
 * @param {object} user - current user session (optional)
 * @param {function} onPaymentSuccess - callback(planId, paymentId)
 * @param {function} onPaymentCancel - callback()
 */
export async function initializeCashfreeCheckout({
  planId,
  user = null,
  onPaymentSuccess,
  onPaymentCancel,
}) {
  if (typeof window === "undefined") return;

  const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];

  trackPurchaseStarted({
    planName: plan.id,
    value: plan.price,
    currency: "INR",
  });

  try {
    // 1. Create Order Session from backend
    const orderRes = await fetch("/api/checkout/cashfree/order", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        planId: plan.id,
        customerId: user?.id || (user?.email ? `cust_${user.email.replace(/[^a-zA-Z0-9]/g, "_")}` : undefined),
        customerEmail: user?.email || undefined,
        customerName: user?.name || undefined,
      }),
    });

    const orderData = await orderRes.json();

    if (!orderRes.ok || !orderData.payment_session_id) {
      throw new Error(orderData.error || "Could not create payment session with Cashfree");
    }

    // 2. Demo / Mock Mode Handler
    if (orderData.mode === "mock") {
      const confirmMock = window.confirm(
        `[Cashfree Demo Mode — Pro Pass: ₹${plan.price}]\n\n` +
        `Cashfree live API keys are not yet configured in your environment.\n\n` +
        `Would you like to simulate a successful payment and immediately unlock Pro Studio Pass (1080p Master, Watermark Removal, Title Cards)?`
      );

      if (confirmMock) {
        // Verify mock payment
        const verifyRes = await fetch("/api/checkout/cashfree/verify", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            orderId: orderData.order_id,
            planId: plan.id,
          }),
        });
        const verifyData = await verifyRes.json();

        trackPurchaseCompleted({
          planName: plan.id,
          value: plan.price,
          currency: "INR",
          transactionId: verifyData.paymentId || `cf_demo_${Date.now()}`,
        });

        if (typeof onPaymentSuccess === "function") {
          onPaymentSuccess(plan.id, verifyData.paymentId || `cf_demo_${Date.now()}`);
        }
      } else {
        if (typeof onPaymentCancel === "function") onPaymentCancel();
      }
      return;
    }

    // 3. Live / Sandbox Mode via Cashfree SDK
    const CashfreeFactory = await loadCashfreeSDK();
    const mode = orderData.mode === "production" ? "production" : "sandbox";
    const cashfree = CashfreeFactory({ mode });

    const checkoutOptions = {
      paymentSessionId: orderData.payment_session_id,
      redirectTarget: "_modal", // Seamless in-app popup modal
    };

    const checkoutResult = await cashfree.checkout(checkoutOptions);

    if (checkoutResult?.error) {
      console.warn("Cashfree checkout error / dismissed:", checkoutResult.error);
      if (typeof onPaymentCancel === "function") onPaymentCancel();
      return;
    }

    if (checkoutResult?.paymentDetails || checkoutResult?.redirect) {
      // 4. Verify payment with backend
      const verifyRes = await fetch("/api/checkout/cashfree/verify", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          orderId: orderData.order_id,
          planId: plan.id,
        }),
      });

      const verifyData = await verifyRes.json();

      if (verifyRes.ok && verifyData.verified) {
        trackPurchaseCompleted({
          planName: plan.id,
          value: plan.price,
          currency: "INR",
          transactionId: verifyData.paymentId,
        });

        if (typeof onPaymentSuccess === "function") {
          onPaymentSuccess(plan.id, verifyData.paymentId);
        }
      } else {
        alert(verifyData.error || "Payment verification failed. If your account was debited, please contact support.");
        if (typeof onPaymentCancel === "function") onPaymentCancel();
      }
    }
  } catch (err) {
    console.error("Cashfree Checkout Error:", err);
    alert(`Payment Gateway Notice: ${err.message || "Could not complete checkout."}`);
    if (typeof onPaymentCancel === "function") onPaymentCancel();
  }
}

export default initializeCashfreeCheckout;
