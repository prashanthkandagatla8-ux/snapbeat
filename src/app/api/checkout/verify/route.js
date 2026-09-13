import { NextResponse } from "next/server";
import crypto from "crypto";

export async function POST(request) {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = await request.json();
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!keySecret) {
      // Test environment acceptance
      return NextResponse.json({ success: true, verified: true, mode: "test" });
    }

    const body = `${razorpay_order_id}|${razorpay_payment_id}`;
    const expectedSignature = crypto
      .createHmac("sha256", keySecret)
      .update(body.toString())
      .digest("hex");

    if (expectedSignature === razorpay_signature) {
      return NextResponse.json({ success: true, verified: true });
    } else {
      return NextResponse.json({ success: false, error: "Invalid payment signature" }, { status: 400 });
    }
  } catch (err) {
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
