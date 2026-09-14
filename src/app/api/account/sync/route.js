import { NextResponse } from "next/server";
import { linkGuestToAccount, upsertAccount, getAccountByEmail } from "@/lib/serverDb";
import { verifyProToken, signProToken } from "@/lib/security";

/**
 * Links a guest device session to a registered email account or syncs account details.
 * Seamlessly migrates guest Pro pass to permanent email account.
 */
export async function POST(request) {
  try {
    const { email, name, picture, deviceId, currentToken } = await request.json();

    if (!email) {
      return NextResponse.json({ error: "Missing email" }, { status: 400 });
    }

    const cleanEmail = email.trim().toLowerCase();

    // If device had a guest pro pass, link it to the email account
    let updatedAccount = null;
    if (deviceId) {
      updatedAccount = linkGuestToAccount(deviceId, cleanEmail, name);
    }

    if (!updatedAccount) {
      const existing = getAccountByEmail(cleanEmail);
      let isPro = existing?.isPro || false;
      let planId = existing?.planId || null;
      let expiresAt = existing?.expiresAt || null;
      let paymentId = existing?.paymentId || null;
      let proToken = existing?.proToken || null;

      // If token provided is valid, accept it
      if (currentToken) {
        const payload = verifyProToken(currentToken);
        if (payload) {
          isPro = true;
          planId = payload.planId;
          expiresAt = payload.expiresAt;
          paymentId = payload.paymentId;
          proToken = currentToken;
        }
      }

      updatedAccount = upsertAccount({
        email: cleanEmail,
        name: name || cleanEmail.split("@")[0],
        picture: picture || null,
        isGuest: false,
        isPro,
        planId,
        expiresAt,
        paymentId,
        proToken,
        deviceId,
      });
    }

    // Refresh token if Pro is active
    let token = updatedAccount.proToken;
    if (updatedAccount.isPro) {
      token = signProToken({
        accountId: updatedAccount.id,
        email: updatedAccount.email,
        planId: updatedAccount.planId,
        paymentId: updatedAccount.paymentId,
        expiresAt: updatedAccount.expiresAt,
      });
    }

    return NextResponse.json({
      success: true,
      account: updatedAccount,
      proToken: token,
      isPro: updatedAccount.isPro,
    });
  } catch (err) {
    console.error("Account sync error:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
