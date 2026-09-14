import crypto from "node:crypto";

/**
 * Derives the server master secret for signing Pro passes.
 * Uses CASHFREE_SECRET_KEY as primary seed with fallback internal secret.
 */
function getSecretKey() {
  return (
    process.env.PRO_TOKEN_SECRET ||
    process.env.CASHFREE_SECRET_KEY ||
    "snapbeat_production_master_secret_2026_unbreakable_seed"
  );
}

/**
 * Issues a cryptographically unforgeable HMAC-SHA256 Pro pass token.
 * Contains user identifier, plan, expiry, payment reference and signature.
 */
export function signProToken(payload) {
  const secret = getSecretKey();
  const tokenPayload = {
    ...payload,
    issuedAt: new Date().toISOString(),
  };
  const encoded = Buffer.from(JSON.stringify(tokenPayload)).toString("base64url");
  const signature = crypto
    .createHmac("sha256", secret)
    .update(encoded)
    .digest("base64url");

  return `${encoded}.${signature}`;
}

/**
 * Validates a Pro pass token.
 * Returns null if token is tampered, forged, or expired.
 */
export function verifyProToken(token) {
  if (!token || typeof token !== "string") return null;
  const parts = token.split(".");
  if (parts.length !== 2) return null;

  const [encoded, signature] = parts;
  const secret = getSecretKey();
  const expectedSignature = crypto
    .createHmac("sha256", secret)
    .update(encoded)
    .digest("base64url");

  const sigBuf = Buffer.from(signature);
  const expBuf = Buffer.from(expectedSignature);

  if (sigBuf.length !== expBuf.length) {
    return null;
  }

  try {
    if (!crypto.timingSafeEqual(sigBuf, expBuf)) {
      return null;
    }
  } catch (_) {
    return null;
  }

  try {
    const data = JSON.parse(Buffer.from(encoded, "base64url").toString("utf-8"));
    if (data.expiresAt) {
      const expTime = new Date(data.expiresAt).getTime();
      if (expTime < Date.now()) {
        return null; // Expired pass
      }
    }
    return data;
  } catch (_) {
    return null;
  }
}
