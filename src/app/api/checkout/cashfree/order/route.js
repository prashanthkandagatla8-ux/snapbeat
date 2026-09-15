import { NextResponse } from "next/server";
import { PRICING_PLANS } from "@/lib/constants";
import { getCashfreeCredentials } from "@/lib/cashfreeConfig";

/**
 * Cashfree Payment Gateway - Create Order Endpoint
 * API Version: 2023-08-01
 * Endpoint: POST https://api.cashfree.com/pg/orders (Production)
 *           POST https://sandbox.cashfree.com/pg/orders (Sandbox)
 */
export async function POST(request) {
  try {
    const body = await request.json();
    const { planId, customerEmail, customerPhone, customerName, customerId } = body;

    if (body.isGuest || (customerEmail && (customerEmail.startsWith("guest_") || customerEmail.includes("@guest.")))) {
      return NextResponse.json(
        { error: "Please sign in with your email or Google account before purchasing Pro so your subscription is safely saved." },
        { status: 400 }
      );
    }

    const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];

    const { appId, secretKey, isProduction } = getCashfreeCredentials();

    const baseUrl = isProduction
      ? "https://api.cashfree.com/pg/orders"
      : "https://sandbox.cashfree.com/pg/orders";

    // Cashfree PG is approved and active: keys must be present
    if (!appId || !secretKey) {
      return NextResponse.json(
        { error: "Cashfree live payment gateway configuration is missing." },
        { status: 500 }
      );
    }

    const orderId = `sb_${plan.id}_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    const cleanPhone = (customerPhone || "9999999999").replace(/\D/g, "").slice(-10) || "9999999999";
    const cleanEmail = customerEmail && customerEmail.includes("@") ? customerEmail : "creator@snapbeat.app";
    const cleanCustomerId = customerId || `cust_${Date.now()}`;

    // Get origin for return URL
    const host = request.headers.get("host") || "snapbeat.app";
    const protocol = host.includes("localhost") ? "http" : "https";
    const origin = `${protocol}://${host}`;

    const payload = {
      order_id: orderId,
      order_amount: Number(plan.price),
      order_currency: "INR",
      customer_details: {
        customer_id: cleanCustomerId,
        customer_email: cleanEmail,
        customer_phone: cleanPhone,
        customer_name: customerName || "SnapBeat Creator",
      },
      order_meta: {
        return_url: `${origin}/?cf_status={payment_status}&order_id={order_id}&plan_id=${plan.id}`,
        notify_url: `${origin}/api/checkout/cashfree/webhook`,
      },
      order_note: `SnapBeat Pro Studio Pass (${plan.name}) - 1080p Master & No Watermark`,
      order_tags: {
        plan_id: plan.id,
        plan_name: plan.name,
      },
    };

    const res = await fetch(baseUrl, {
      method: "POST",
      headers: {
        "x-client-id": appId,
        "x-client-secret": secretKey,
        "x-api-version": "2023-08-01",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const data = await res.json();

    if (!res.ok) {
      console.error("Cashfree order creation error:", data);
      return NextResponse.json(
        {
          error: data.message || "Failed to create Cashfree order",
          details: data,
        },
        { status: res.status }
      );
    }

    return NextResponse.json({
      order_id: data.order_id,
      payment_session_id: data.payment_session_id,
      order_status: data.order_status,
      order_amount: data.order_amount,
      order_currency: data.order_currency,
      mode: isProduction ? "production" : "sandbox",
    });
  } catch (err) {
    console.error("Server error in Cashfree order:", err);
    return NextResponse.json({ error: err.message || "Internal server error" }, { status: 500 });
  }
}
