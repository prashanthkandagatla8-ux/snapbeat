import { initializeRazorpayCheckout } from "./RazorpayCheckout";
import { initializeCashfreeCheckout } from "./CashfreeCheckout";

/**
 * Hybrid Payment Gateway Orchestrator
 *
 * Supported Gateways:
 * - Cashfree Payments (Active Live Gateway now with UPI, Cards, NetBanking)
 * - Razorpay (Preserved in full, ready to be primary once merchant review completes)
 */
export async function initializeHybridCheckout({
  planId,
  user = null,
  preferredGateway = null, // "cashfree" | "razorpay" | null (auto-detect)
  onPaymentSuccess,
  onPaymentCancel,
}) {
  const razorpayKey = (process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID || "").trim();
  const primaryConfig = (process.env.NEXT_PUBLIC_PAYMENT_GATEWAY_PRIMARY || "cashfree").toLowerCase();

  // Determine active gateway
  let activeGateway = preferredGateway || primaryConfig;

  // If Razorpay is set as primary BUT keys are missing, fallback to Cashfree
  if (activeGateway === "razorpay" && !razorpayKey) {
    activeGateway = "cashfree";
  }

  if (activeGateway === "razorpay" && razorpayKey) {
    return initializeRazorpayCheckout(
      planId,
      (plan, paymentId) => onPaymentSuccess?.(plan, paymentId),
      () => onPaymentCancel?.()
    );
  }

  // Default to Cashfree (Activated)
  return initializeCashfreeCheckout({
    planId,
    user,
    onPaymentSuccess: (plan, paymentId, proToken) => onPaymentSuccess?.(plan, paymentId, proToken),
    onPaymentCancel: () => onPaymentCancel?.(),
  });
}

export default initializeHybridCheckout;
