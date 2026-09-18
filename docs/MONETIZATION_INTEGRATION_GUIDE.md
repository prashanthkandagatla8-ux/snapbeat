# SnapBeat Studio — Monetization Integration Guide

Complete end-to-end guide for deploying, configuring, and testing the **SnapBeat Pro Monetization System** across Flutter client and Python FastAPI backend.

---

## 1. System Architecture & Flow

```
┌─────────────────────────────────────────────────────────────┐
│                       Flutter App                           │
│  (in_app_purchase + SubscriptionManager + RetroPaywall)     │
└──────────────┬───────────────────────────────▲──────────────┘
               │ 1. buySubscription()          │ 4. Pro Entitlement
               ▼                               │    (isPro=true, token)
┌──────────────────────────────┐               │
│   App Store / Google Play    │               │
│   (StoreKit 2 / Billing v6)  │               │
└──────────────┬───────────────┘               │
               │ 2. Purchase Receipt           │
               ▼                               │
┌──────────────────────────────────────────────┴──────────────┐
│                    Python Backend API                       │
│             (/api/billing/verify-receipt)                   │
├─────────────────────────────────────────────────────────────┤
│  • Verify cryptographic signature (JWS / Google API)        │
│  • SQLite Anti-Replay Ledger (billing_transactions)         │
│  • Check expiration date > current UTC time                 │
│  • Issue HMAC-SHA256 Token (X-SnapBeat-Entitlement)         │
└──────────────────────────────┬──────────────────────────────┘
                               │ 5. Render Reel (Token verified)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 FastAPI Render Engine                       │
│  • Verified Pro: watermark=false, quality=1080p, priority   │
│  • Free Tier: watermark=true, quality=720p, free_queue      │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Google Play Console Configuration

### A. Subscription Setup
1. Sign in to [Google Play Console](https://play.google.com/console).
2. Select **SnapBeat Studio** (`com.kiro.snapbeat`).
3. In the sidebar under **Monetize with Play**, go to **Products** &rarr; **Subscriptions**.
4. Click **Create subscription**:
   - **Subscription ID**: `snapbeat_pro`
   - **Name**: `SnapBeat Pro Subscription`
5. Create **Base Plans**:
   - **Daily Plan**: ID `daily-plan` | Auto-renewing | Billing period: `1 day` | Price: `₹49.00`
   - **Weekly Plan**: ID `weekly-plan` | Auto-renewing | Billing period: `1 week` | Price: `₹149.00`
   - **Monthly Plan**: ID `monthly-plan` | Auto-renewing | Billing period: `1 month` | Price: `₹349.00`
   - **Annual Plan**: ID `annual-plan` | Auto-renewing | Billing period: `1 year` | Price: `₹899.00`

> **Note on Direct Product IDs**: For backwards compatibility with single-ID querying in Flutter, you can also define separate individual subscriptions with IDs matching iOS:
> - `snapbeat_pro_daily`
> - `snapbeat_pro_weekly`
> - `snapbeat_pro_monthly`
> - `snapbeat_pro_yearly`

### B. Google Play Developer API (Service Account)
1. Go to **Google Cloud Console** for your project.
2. Create a Service Account with role `Google Play Android Developer`.
3. Generate and download JSON Key (`service-account.json`).
4. In Play Console &rarr; **Users and permissions** &rarr; Invite the service account email and grant `View financial data` and `Manage orders and subscriptions`.
5. Set on server:
   ```bash
   GOOGLE_SERVICE_ACCOUNT_JSON="/path/to/service-account.json"
   GOOGLE_PLAY_PACKAGE_NAME="com.kiro.snapbeat"
   ```

---

## 3. Server Configuration & Environment Variables

Add the following environment variables to your `.env` or production server launch environment (`C:\MyProjects\SnapBeatServer-Beast`):

```bash
# SnapBeat Anti-Fraud & Token Security
SNAPBEAT_BILLING_SECRET="SnapBeat_Super_Secret_Cryptographic_HMAC_Key_2026"
SNAPBEAT_BILLING_DB="data/billing.db"

# Apple In-App Purchase
APPLE_IAP_SHARED_SECRET="<apple_app_specific_shared_secret>"
APPLE_API_KEY_ID="<your_key_id>"
APPLE_API_ISSUER_ID="<your_issuer_uuid>"
APPLE_API_PRIVATE_KEY="<path_to_p8_file>"

# Google Play Billing
GOOGLE_PLAY_PACKAGE_NAME="com.kiro.snapbeat"
GOOGLE_SERVICE_ACCOUNT_JSON="<path_to_google_service_account.json>"
```

---

## 4. Local Testing with StoreKit Configuration File (`.storekit`)

You can test auto-renewable subscriptions in the iOS Simulator or Xcode without creating test users in App Store Connect:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. The StoreKit configuration file is included at `ios/SnapBeat.storekit`.
3. Go to **Product** &rarr; **Scheme** &rarr; **Edit Scheme...** &rarr; **Run (Debug)** &rarr; **Options** tab.
4. Under **StoreKit Configuration**, select `SnapBeat.storekit`.
5. Run the app! All 4 subscription tiers can now be purchased, renewed, and restored instantly in local debug mode.

---

## 5. Security & Anti-Fraud Features

1. **Anti-Replay Ledger**:
   - Every transaction ID is indexed in SQLite `billing_transactions` with `UNIQUE(transaction_id)`.
   - Replay attacks where an attacker copies a valid transaction ID to another user account or device are immediately rejected.
2. **Tamper-Proof Entitlement Tokens**:
   - Client-side storage of Pro status is protected with an SHA-256 integrity hash (`sha256(isPro + tier + expiresAt + secretSalt)`). If an attacker tampers with Android `shared_prefs` or iOS `UserDefaults`, the app detects the corrupted hash and resets status.
   - When rendering, the app passes a server-signed HMAC token (`X-SnapBeat-Entitlement`). The server verifies the token before stripping the watermark or granting 1080p quality. Unverified requests are strictly clamped to the Free tier.
3. **Grace Period & Expiration Handling**:
   - The server verifies timestamps against UTC time.
   - Expired subscriptions immediately lose watermark-free and 1080p privileges on subsequent renders.
