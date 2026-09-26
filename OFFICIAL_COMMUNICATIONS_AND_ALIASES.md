# Official SnapBeat Communications & Namecheap Mailbox Aliases

This document outlines the authoritative list of the **10 official email aliases** routed to the primary mailbox `founder@snapbeat.app` via Namecheap Private Email for SnapBeat Studio.

No other email addresses or legacy aliases (e.g. `@googlegroups.com`, `@gmail.com`, or unverified domains) are permitted in production builds, legal policies, or App Store submissions.

---

## 1. Authoritative 10 Email Aliases & Departmental Routing

| # | Alias | Department / Function | Primary Role & Touchpoints |
|---|---|---|---|
| 1 | `support@snapbeat.app` | Customer Care & App Support | In-app Help, App Store Support URL, User Troubleshooting |
| 2 | `feedback@snapbeat.app` | Tester & Product Feedback | In-app Tester Feedback Dialog, Feature Requests, Beta Surveys |
| 3 | `privacy@snapbeat.app` | Privacy & Compliance | App Privacy Policy, Data Deletion Requests, GDPR/CCPA Inquiries |
| 4 | `legal@snapbeat.app` | Legal & Terms of Service | Terms of Use (EULA), Copyright/DMCA notices, IP compliance |
| 5 | `billing@snapbeat.app` | Subscriptions & Invoicing | StoreKit / Google Play billing questions, refund dispute assistance |
| 6 | `security@snapbeat.app` | Security & Vulnerability Reporting | Responsible disclosure, backend API vulnerability reporting |
| 7 | `contact@snapbeat.app` | General Inquiries | General correspondence, public inquiries |
| 8 | `hello@snapbeat.app` | Community & Welcome | Onboarding greetings, community engagement |
| 9 | `press@snapbeat.app` | Media & Public Relations | Press kits, media interviews, influencer outreach |
| 10 | `admin@snapbeat.app` | System & Operations | Apple Developer, Google Play Console, Domain administrative notices |

---

## 2. In-App Code Locations

- **Tester Feedback**:
  - File: `lib/ui/components/tester_feedback_dialog.dart`
  - Address: `feedback@snapbeat.app`
  - Action: Automatically opens user's email client with app version, build, platform, and feedback payload.

- **Privacy Policy & Data Rights**:
  - File: `lib/ui/components/privacy_policy_dialog.dart`
  - File: `PRIVACY_POLICY.md` (Sections 8, 12)
  - Addresses: `privacy@snapbeat.app`, `support@snapbeat.app`, `legal@snapbeat.app`

- **Legal Terms & EULA**:
  - File: `TERMS_OF_SERVICE.md`
  - Addresses: `legal@snapbeat.app`, `support@snapbeat.app`

- **App Store Connect Metadata**:
  - Support URL: `https://snapbeat.app/support` (contact: `support@snapbeat.app`)
  - Privacy Policy URL: `https://snapbeat.app/privacy` (contact: `privacy@snapbeat.app`)
  - Marketing URL: `https://snapbeat.app` (contact: `hello@snapbeat.app`)

---

## 3. Maintenance Rules

1. **Zero External/Legacy Addresses**: Never hardcode personal emails or legacy group emails in any `.dart` files or markdown documentation.
2. **Mailbox Destination**: All incoming mail to any of these 10 aliases forwards seamlessly to `founder@snapbeat.app`.
3. **DKIM / SPF / DMARC Compliance**: All outgoing responses from these aliases are signed with Namecheap DKIM and strict SPF records for `snapbeat.app`.
