import { NextResponse } from "next/server";
import { PRICING_PLANS } from "@/lib/constants";

export async function POST(request) {
  try {
    const { planId } = await request.json();
    const plan = PRICING_PLANS.find((p) => p.id === planId) || PRICING_PLANS[1];

    const keyId = process.env.RAZORPAY_KEY_ID;
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!keyId || !keySecret) {
      // Mock order for test environments
      return NextResponse.json({
        order_id: `order_mock_${Date.now()}`,
        amount: plan.price * 100,
        currency: "INR",
        plan: plan.id,
      });
    }

    // Call Razorpay API
    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");
    const res = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        amount: plan.price * 100,
        currency: "INR",
        receipt: `receipt_${Date.now()}`,
        notes: { plan_id: plan.id },
      }),
    });

    const data = await res.json();
    return NextResponse.json(data);
  } catch (err) {
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
