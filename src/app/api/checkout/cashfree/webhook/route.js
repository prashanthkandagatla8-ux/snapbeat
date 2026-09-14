import { NextResponse } from "next/server";

/**
 * Cashfree Payment Gateway - Webhook Handler
 * Receives asynchronous server-to-server notifications from Cashfree
 */
export async function POST(request) {
  try {
    const rawBody = await request.text();
    let eventData;
    try {
      eventData = JSON.parse(rawBody);
    } catch {
      eventData = {};
    }

    console.log("Cashfree Webhook Received:", eventData?.type || "unknown event");

    // Acknowledge receipt to Cashfree
    return NextResponse.json({ status: "OK", received: true }, { status: 200 });
  } catch (err) {
    console.error("Webhook processing error:", err);
    return NextResponse.json({ status: "ERROR", error: err.message }, { status: 200 });
  }
}
