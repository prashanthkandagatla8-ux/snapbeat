import { NextResponse } from "next/server";
import { PRICING_PLANS } from "@/lib/constants";
import { signProToken } from "@/lib/security";
import { upsertAccount, recordActivation } from "@/lib/serverDb";

/**
 * Cashfree Payment Gateway - Verify Order Endpoint
 * API Version: 2023-08-01
 * Endpoint: GET https://api.cashfree.com/pg/orders/{order_id}
 * Hardened with Anti-Cheat & Persistent SQLite database tracking.
 */
export async function POST(request) {
  try {
    const { orderId, planId, customerEmail, customerId, deviceId } = await request.json();

    if (!orderId) {
      return NextResponse.json({ error: "Missing order_id" }, { status: 400 });
    }

    const appId = (process.env.CASHFREE_APP_ID || "").trim();
    const secretKey = (process.env.CASHFREE_SECRET_KEY || "").trim();
    const isProduction = (process.env.CASHFREE_ENV || "PRODUCTION").toUpperCase() === "PRODUCTION";

    // Anti-cheat: Mock orders strictly blocked
    if (orderId.startsWith("order_sb_mock_") || orderId.startsWith("cf_demo_")) {
      return NextResponse.json(
        { success: false, error: "Mock payments are strictly disabled. Please complete real payment via Cashfree." },
        { status: 403 }
      );
    }

    if (!appId || !secretKey) {
      return NextResponse.json(
        { error: "Payment gateway credentials not configured on server" },
        { status: 500 }
      );
    }

    const baseUrl = isProduction
      ? `https://api.cashfree.com/pg/orders/${orderId}`
      : `https://sandbox.cashfree.com/pg/orders/${orderId}`;

    const res = await fetch(baseUrl, {
      method: "GET",
      headers: {
        "x-client-id": appId,
        "x-client-secret": secretKey,
        "x-api-version": "2023-08-01",
        "Content-Type": "application/json",
      },
      cache: "no-store",
    });

    const orderData = await res.json();

    if (!res.ok) {
      console.error("Cashfree order verification failed:", orderData);
      return NextResponse.json(
        {
          success: false,
          error: orderData.message || "Failed to fetch order status from Cashfree",
        },
        { status: res.status }
      );
    }

    // Cashfree order statuses: PAID, ACTIVE, EXPIRED, TERMINATED
    if (orderData.order_status === "PAID") {
      const plan =
        PRICING_PLANS.find((p) => p.price === Math.round(orderData.order_amount)) ||
        PRICING_PLANS.find((p) => p.id === planId) ||
        PRICING_PLANS[1];

      const now = new Date();
      let days = 7;
      if (plan.id === "daily" || plan.id === "day") days = 1;
      if (plan.id === "monthly") days = 30;
      if (plan.id === "annual") days = 365;
      const expiresAt = new Date(now.getTime() + days * 24 * 60 * 60 * 1000).toISOString();
      const paymentId = `cf_${orderData.order_id}`;

      const finalEmail = customerEmail || orderData.customer_details?.customer_email || "creator@snapbeat.app";
      const finalCustomerId = customerId || orderData.customer_details?.customer_id;

      // Generate cryptographically signed Pro token
      const proToken = signProToken({
        accountId: finalCustomerId,
        email: finalEmail,
        planId: plan.id,
        paymentId,
        expiresAt,
      });

      // Persist in SQLite database
      try {
        const account = upsertAccount({
          id: finalCustomerId,
          email: finalEmail,
          isGuest: !customerEmail || customerEmail.includes("@guest."),
          isPro: true,
          planId: plan.id,
          expiresAt,
          paymentId,
          proToken,
          deviceId,
        });

        recordActivation({
          accountId: account?.id || finalCustomerId,
          email: finalEmail,
          orderId: orderData.order_id,
          paymentId,
          gateway: "cashfree",
          planId: plan.id,
          amount: orderData.order_amount,
          currency: orderData.order_currency || "INR",
          status: "PAID",
          expiresAt,
          proToken,
        });
      } catch (dbErr) {
        console.error("Failed to persist activation in SQLite:", dbErr);
      }

      return NextResponse.json({
        success: true,
        verified: true,
        orderId: orderData.order_id,
        paymentId,
        planId: plan.id,
        amount: orderData.order_amount,
        status: orderData.order_status,
        expiresAt,
        proToken,
      });
    } else {
      return NextResponse.json(
        {
          success: false,
          verified: false,
          orderStatus: orderData.order_status,
          error: `Payment is not completed (Current status: ${orderData.order_status})`,
        },
        { status: 400 }
      );
    }
  } catch (err) {
    console.error("Server error in Cashfree verification:", err);
    return NextResponse.json({ error: err.message || "Internal server error" }, { status: 500 });
  }
}
