import { NextResponse } from "next/server";
import { verifyProToken } from "@/lib/security";
import { getAccountByEmail, getAccountById, getAccountByDeviceId } from "@/lib/serverDb";

/**
 * Validates and syncs Pro status from signed token or database.
 * Supports both registered email accounts and persistent guest device tokens.
 */
export async function POST(request) {
  try {
    const { token, email, deviceId, accountId } = await request.json();

    // 1. Verify cryptographic token if provided
    let tokenPayload = null;
    if (token) {
      tokenPayload = verifyProToken(token);
    }

    // 2. Fetch ground-truth account from database
    let dbAccount = null;
    if (email) {
      dbAccount = getAccountByEmail(email);
    } else if (accountId) {
      dbAccount = getAccountById(accountId);
    } else if (deviceId) {
      dbAccount = getAccountByDeviceId(deviceId);
    }

    const isTokenValid = Boolean(tokenPayload && (!tokenPayload.expiresAt || new Date(tokenPayload.expiresAt) > new Date()));
    const isDbPro = Boolean(dbAccount?.isPro);

    if (isTokenValid || isDbPro) {
      return NextResponse.json({
        isPro: true,
        planId: tokenPayload?.planId || dbAccount?.planId || "monthly",
        expiresAt: tokenPayload?.expiresAt || dbAccount?.expiresAt,
        paymentId: tokenPayload?.paymentId || dbAccount?.paymentId,
        account: dbAccount || null,
        valid: true,
      });
    }

    return NextResponse.json({
      isPro: false,
      valid: false,
    });
  } catch (err) {
    console.error("Account status check failed:", err);
    return NextResponse.json({ isPro: false, error: err.message }, { status: 500 });
  }
}
