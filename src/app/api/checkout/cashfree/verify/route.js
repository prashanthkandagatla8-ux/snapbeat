import { NextResponse } from "next/server";
import { PRICING_PLANS } from "@/lib/constants";

/**
 * Cashfree Payment Gateway - Verify Order Endpoint
 * API Version: 2023-08-01
 * Endpoint: GET https://api.cashfree.com/pg/orders/{order_id}
 */
export async function POST(request) {
  try {
    const { orderId, planId } = await request.json();

    if (!orderId) {
      return NextResponse.json({ error: "Missing order_id" }, { status: 400 });
    }

    const appId = (process.env.CASHFREE_APP_ID || "").trim();
    const secretKey = (process.env.CASHFREE_SECRET_KEY || "").trim();
    const isProduction = (process.env.CASHFREE_ENV || "PRODUCTION").toUpperCase() === "PRODUCTION";

    // If running in mock/demo mode without keys
    if (!appId || !secretKey || orderId.startsWith("order_sb_mock_")) {
      const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];
      return NextResponse.json({
        success: true,
        verified: true,
        orderId,
        paymentId: `cf_demo_${orderId}`,
        planId: plan.id,
        amount: plan.price,
        mode: "mock",
        message: "Payment successfully simulated for demo environment.",
      });
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

      return NextResponse.json({
        success: true,
        verified: true,
        orderId: orderData.order_id,
        paymentId: `cf_${orderData.order_id}`,
        planId: plan.id,
        amount: orderData.order_amount,
        status: orderData.order_status,
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
