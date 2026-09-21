# SnapBeat Studio — App Store Connect Configuration Guide

This guide provides step-by-step instructions for configuring the **SnapBeat Pro Auto-Renewable Subscriptions** in **App Store Connect**, complying with Apple App Store Review Guidelines **3.1.2 (Subscriptions)** and **5.6 (Developer Code of Conduct)**.

---

## 1. Subscription Group Setup

In App Store Connect, auto-renewable subscriptions that offer the same level of service with different billing periods must belong to the same **Subscription Group**. This allows users to easily upgrade, downgrade, or switch between billing frequencies without double-billing.

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **My Apps** &rarr; Select **SnapBeat Studio** (Bundle ID: `com.kiro.snapbeat`).
3. In the sidebar under **Monetization**, click **Subscriptions**.
4. Click **Create Subscription Group** (or the `+` button next to Subscription Groups).
   - **Group Reference Name**: `SnapBeat Pro Access`
   - Click **Create**.

---

## 2. Configuring the 4 Subscription Tiers

Inside the `SnapBeat Pro Access` group, create each of the 4 subscription products:

### Tier 1: Daily Pass
- **Reference Name**: `SnapBeat Pro Daily Pass`
- **Product ID**: `snapbeat_pro_daily`
- **Subscription Duration**: `1 Day`
- **Subscription Price**:
  - Currency: **INR (₹)**
  - Base Price: **₹49.00**
  - All other storefront currencies: Let Apple automatically calculate or adjust to Tier equivalents ($0.99 USD, £0.89 GBP, €0.99 EUR).
- **Localization (English - U.S.)**:
  - **Subscription Display Name**: `Daily Pass`
  - **Description**: `24-hour unlimited watermark-free 1080p exports with priority render queue.`

### Tier 2: Weekly Pass
- **Reference Name**: `SnapBeat Pro Weekly Pass`
- **Product ID**: `snapbeat_pro_weekly`
- **Subscription Duration**: `1 Week`
- **Subscription Price**:
  - Currency: **INR (₹)**
  - Base Price: **₹149.00**
- **Localization (English - U.S.)**:
  - **Subscription Display Name**: `Weekly Pass`
  - **Description**: `7 days full Pro access: no watermarks, 1080p master quality, and priority queue.`

### Tier 3: Monthly VIP (Most Popular)
- **Reference Name**: `SnapBeat Pro Monthly VIP`
- **Product ID**: `snapbeat_pro_monthly`
- **Subscription Duration**: `1 Month`
- **Subscription Price**:
  - Currency: **INR (₹)**
  - Base Price: **₹349.00**
- **Localization (English - U.S.)**:
  - **Subscription Display Name**: `Monthly VIP`
  - **Description**: `Full monthly creator access: watermark-free 1080p master renders with priority processing.`

### Tier 4: Annual VIP (Best Value - Save 57%)
- **Reference Name**: `SnapBeat Pro Annual VIP`
- **Product ID**: `snapbeat_pro_yearly`
- **Subscription Duration**: `1 Year`
- **Subscription Price**:
  - Currency: **INR (₹)**
  - Base Price: **₹1,799.00** ($24.99 USD)
  - Margin Protection: Guarantees >= 5.7x gross margin against compute render costs.
- **Localization (English - U.S.)**:
  - **Subscription Display Name**: `Annual VIP`
  - **Description**: `1 full year of unlimited Pro creation: 1080p crisp renders, zero watermarks, and VIP queue.`

---

## 3. Subscription Group Ranking / Level of Service

Because all 4 tiers unlock the **same Pro features** (no watermark, 1080p, priority queue) for different durations:
- Set all 4 subscriptions to **Level 1** (same tier level).
- This ensures moving between Daily, Weekly, Monthly, and Annual is treated by iOS as a **Crossgrade** (takes effect on the next renewal date, or immediately with pro-rated refund per Apple policies).

---

## 4. App Store Server API & Shared Secret

To enable backend cryptographic receipt validation:

### A. App-Specific Shared Secret (StoreKit 1 verifyReceipt Fallback)
1. In App Store Connect &rarr; **My Apps** &rarr; **SnapBeat Studio** &rarr; **Subscriptions**.
2. In the right panel under **App-Specific Shared Secret**, click **Manage**.
3. Generate a new secret and copy it.
4. Set on your server environment:
   ```bash
   APPLE_IAP_SHARED_SECRET="<your_shared_secret_here>"
   ```

### B. App Store Server API Key (StoreKit 2 JWS Modern API)
1. Go to **Users and Access** &rarr; **Integrations** tab &rarr; **In-App Purchase**.
2. Click `+` to generate an API key.
   - **Name**: `SnapBeat Production Server`
   - **Access**: `Admin` or `App Manager`
3. Note down:
   - **Key ID** (e.g. `2X9R4HXF34`)
   - **Issuer ID** (UUID at the top of the page)
   - Download the `.p8` private key file (e.g. `SubscriptionKey_2X9R4HXF34.p8`).
4. Set on your backend server:
   ```bash
   APPLE_API_KEY_ID="2X9R4HXF34"
   APPLE_API_ISSUER_ID="57f3423a-..."
   APPLE_API_PRIVATE_KEY="/path/to/SubscriptionKey_2X9R4HXF34.p8"
   ```

---

## 5. App Store Review Guidelines Compliance Checklist (Guideline 3.1.2)

Apple strictly rejects apps that do not satisfy subscription transparency. Ensure the following:

- [x] **Clear Title & Pricing**: `RetroSubscriptionDialog` displays plan duration and exact currency price directly on the CTA button (`SUBSCRIBE FOR ₹349/MO`).
- [x] **Functional "Restore Purchases" Button**: Placed prominently under the CTA button; calls `InAppPurchase.instance.restorePurchases()`.
- [x] **Terms of Use (EULA) Link**: Clickable link in the modal opening the standard Apple EULA / Terms of Service.
- [x] **Privacy Policy Link**: Clickable link in the modal opening SnapBeat's official Privacy Policy.
- [x] **Auto-Renewal Terms Disclosure**: Text clearly stating that subscriptions renew automatically unless cancelled at least 24 hours prior to expiration, and how users can cancel in iOS Settings.
- [x] **Functional Free Tier**: Free users are never blocked from creating reels — they get full access to all 14 templates and music, with watermark and 720p output clearly explained.
