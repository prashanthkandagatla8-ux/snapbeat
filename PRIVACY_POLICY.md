# Privacy Policy for SnapBeat

**Effective Date:** September 11, 2026  
**Last Updated:** September 11, 2026  

Welcome to **SnapBeat** ("we", "our", or "us"). SnapBeat is a mobile application developed to create dynamic, beat-synced video reels from user-selected photographs and audio tracks.

We take your privacy seriously. This Privacy Policy explains in detail how your data is handled when you use the SnapBeat mobile application and its associated rendering services. SnapBeat is designed with a strict **privacy-by-design** and **ephemeral processing** philosophy: **we do not track you, we do not sell your data, and we do not permanently store your photos or music.**

This Privacy Policy complies with Google Play Developer Policy (including 2026 requirements), General Data Protection Regulation (GDPR), California Consumer Privacy Act (CCPA/CPRA), and the Children's Online Privacy Protection Act (COPPA).

---

## 1. Summary of Key Principles

* **Ephemeral Cloud Rendering:** Photos and audio selected by you are processed temporarily solely to render your requested video reel and are deleted immediately upon completion (`delete_after=true`).
* **Zero AI Model Training:** Your photos, audio, and videos are **never** used to train artificial intelligence, machine learning, or computer vision models.
* **No User Tracking or Profiling:** SnapBeat contains **zero** third-party analytics SDKs, **zero** advertising trackers, and **zero** behavioral fingerprinting libraries.
* **No Account Required:** You can use SnapBeat without creating an account or providing your name, email, or telephone number.
* **No Sale or Rental of Personal Data:** We have never sold, rented, or shared personal media or data with third parties, and never will.

---

## 2. Information We Collect and Process

### A. User-Provided Media Files
SnapBeat only accesses media files that you explicitly and deliberately select:
- **Photos / Images:** Selected via the system photo picker for inclusion in your video reel.
- **Audio Files:** Selected from your local device storage or chosen from our built-in offline royalty-free sound presets.

### B. Device & Technical Information (Non-Identifying)
To fulfill video rendering requests, our rendering API processes strictly necessary technical parameters:
- Requested video dimensions, aspect ratio (e.g., 9:16, 16:9, 1:1), and quality settings (e.g., 720p, 1080p).
- Selected beat template configuration (transition style, cut frequency).
- Audio trim timestamps (start time, end time).
- Temporary task/job identifiers used to associate rendering requests with your session.

### C. Information We DO NOT Collect
- ❌ We do **not** collect your name, email address, phone number, or physical address.
- ❌ We do **not** access your contacts, calendar, GPS location, microphone, or camera hardware.
- ❌ We do **not** collect advertising identifiers (e.g., Google Advertising ID / GAID, IDFA).
- ❌ We do **not** collect biometric data, facial geometry, or scan faces.

---

## 3. How We Use Your Data (Data Usage)

Media files uploaded to our cloud rendering engine are used exclusively for:
1. **Beat-Detection & Audio Analysis:** Inspecting transient beat spikes and tempo (BPM) in your selected audio snippet.
2. **Video Assembly & Rendering:** Synchronizing and stitching your selected photos to musical beats according to your chosen template and duration.
3. **Delivery:** Transmitting the rendered MP4 video file directly back to your device storage.

All data transmission occurs via encrypted, secure protocols (**HTTPS / TLS 1.3**).

---

## 4. Data Retention and Ephemeral Deletion (`delete_after=true`)

SnapBeat enforces strict ephemeral storage policies:
- **Immediate Server Deletion:** As soon as the video compilation completes and the output file is delivered to your client, the source images, audio clips, and intermediate render files are purged immediately from temporary server storage (`delete_after=true`).
- **No Permanent Cloud Storage:** We do not maintain user galleries, cloud backups, or persistent media archives.
- **Local Storage Control:** Rendered video reels downloaded to your device remain strictly under your local control. You can delete them at any time via your device gallery or the in-app reels manager.

---

## 5. Device Permissions

SnapBeat requests minimal, scoped system permissions only when necessary:
- **Photo / Media Access (Android Photo Picker / `READ_MEDIA_IMAGES`):** Required exclusively when you tap the photo selector to pick the images you want to turn into a reel. SnapBeat uses the modern Android system photo picker wherever available, granting access only to selected items rather than your entire photo library.
- **Audio / Storage Access (`READ_MEDIA_AUDIO` / Storage):** Required exclusively to load custom local music tracks that you choose to sync with your photos.
- **Internet Permission (`INTERNET` / `ACCESS_NETWORK_STATE`):** Required to connect via encrypted HTTPS to the cloud rendering engine to process beat synchronization and return your generated video.

---

## 6. Third-Party Sharing, Sales, and Disclosures

- **Zero Third-Party Data Sharing:** We do not share, disclose, or transfer your photos, audio, or generated videos to any marketing agencies, data brokers, advertising networks, or external partners.
- **No AI Training:** Your media files are strictly forbidden from being ingested into generative AI models, foundation model training sets, or algorithmic datasets.
- **Infrastructure Providers:** Rendering occurs on secure cloud compute instances (e.g., AWS / dedicated GPU clusters) bound by strict confidentiality and data-processing terms where files reside only in volatile temporary memory.

---

## 7. Analytics, Advertising, and Tracking

- **No Advertising Networks:** SnapBeat does not display third-party advertisements.
- **No Analytics SDKs:** SnapBeat does not bundle Google Firebase Analytics, Facebook SDK, AppsFlyer, Mixpanel, or any equivalent user tracking tools.
- **No Cross-App Tracking:** We do not track your activity across other apps or websites.

---

## 8. Children's Privacy (COPPA & GDPR Compliance)

SnapBeat does not knowingly collect, solicit, or store personal information from children under the age of 13 (or under 16 in the European Union). Because SnapBeat does not collect personally identifiable information, require user registration, or retain user photos, our service complies with the provisions of COPPA and GDPR. If you believe that personal data has inadvertently been provided to us, please contact us immediately at `support@snapbeat.app` and we will take prompt corrective action.

---

## 9. Your Rights (GDPR / CCPA / CPRA)

Under global data protection regulations (including GDPR and CCPA/CPRA), you have the right to:
- Access, review, or request deletion of personal information.
- Withdraw permission for media processing.
- Exercise your rights without discrimination.

Because SnapBeat operates on an **ephemeral pipeline** without persistent user accounts or stored media, any media uploaded during a rendering job is already purged automatically upon completion.

---

## 10. Security Measures

We implement robust administrative, technical, and physical safeguards:
- All data in transit is protected using industry-standard Transport Layer Security (**TLS 1.3 / HTTPS**).
- Ephemeral server files are isolated in ephemeral sandboxed containers with restricted execution privileges.
- Automated cleanup daemons terminate and sanitize temporary scratch disks upon job completion.

---

## 11. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect changes in legal requirements, Google Play Developer Policies, or our app functionality. When changes are made, we will update the "Last Updated" date at the top of this document. Any material changes will be communicated through an in-app notice.

---

## 12. Contact Us

If you have any questions, concerns, or requests regarding this Privacy Policy or SnapBeat's data practices, please reach out to us:

- **Application Name:** SnapBeat
- **Email:** [support@snapbeat.app](mailto:support@snapbeat.app)
- **Developer / Support:** SnapBeat Development Team
