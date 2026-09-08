# Google Play Console Submission & Compliance Guide for SnapBeat

Use this guide to complete the Google Play Console App Content & Data Safety questionnaires quickly and guarantee app approval.

---

## 1. Privacy Policy URL
Enter this URL in **App Content > Privacy Policy**:
```
https://github.com/prashanthkandagatla8-ux/snapbeat/blob/android/PRIVACY_POLICY.md
```
*(Or if using GitHub Pages: `https://prashanthkandagatla8-ux.github.io/snapbeat/privacy_policy.html`)*

---

## 2. Data Safety Questionnaire Answers

Go to **Policy and programs > App content > Data safety**:

### A. Overview
* **Does your app collect or share any of the required user data types?**  
  &rarr; Select **Yes**.
* **Is all of the user data collected by your app encrypted in transit?**  
  &rarr; Select **Yes** (All requests use TLS/HTTPS).
* **Do you provide a way for users to request that their data is deleted?**  
  &rarr; Select **Yes** (Uploaded photos and audio are deleted immediately upon render download).

### B. Data Types Collected

#### 1. Photos and Videos > Photos
* **Collected?** &rarr; **Yes**
* **Shared?** &rarr; **No**
* **Is this data processed ephemerally?**  
  &rarr; Select **Yes, this collected data is processed ephemerally**.  
  *(Google Play Definition: "Ephemeral processing means data is only stored in memory and not kept longer than necessary to service the immediate request.")*
* **Is this data required for your app, or can users choose whether it's collected?**  
  &rarr; **Users can choose whether this data is collected** (User voluntarily picks photos for video creation).
* **Why is this user data collected?**  
  &rarr; Check **App functionality**.

#### 2. Audio Files > Voice or sound recordings / Music files
* **Collected?** &rarr; **Yes**
* **Shared?** &rarr; **No**
* **Is this data processed ephemerally?**  
  &rarr; Select **Yes, this collected data is processed ephemerally**.
* **Is this data required, or can users choose?**  
  &rarr; **Users can choose whether this data is collected**.
* **Why is this user data collected?**  
  &rarr; Check **App functionality**.

#### 3. All Other Categories (Location, Personal info, Financial, Health, Contacts, Messages, Browsing, Calendar, Diagnostics)
* &rarr; Select **No** for all other categories.

---

## 3. App Content & Policy Questionnaires

### A. Target Audience and Content
* **Target age groups:** Select **13-15, 16-17, 18 and over**.  
  *(Do NOT select children under 13 to avoid COPPA / Families Policy review complexity).*
* **Could your app appeal to children?** &rarr; Select **No**.

### B. Ads
* **Does your app contain ads?** &rarr; Select **No**.

### C. App Access
* **Are any parts of your app restricted (e.g. login credentials)?** &rarr; Select **All functionality is available without special access**.

### D. News / Financial / Government Apps
* Select **No** for all.

### E. Financial Features
* Select **My app doesn't provide any financial features**.

---

## 4. Foreground Service Declaration (`FOREGROUND_SERVICE_DATA_SYNC`)

When submitting an app targeting Android 14+ (API 34) that declares `FOREGROUND_SERVICE_DATA_SYNC`, Google Play prompts for a justification:

* **Why does your app need the Data Sync foreground service?**  
  *Copy and paste this explanation:*  
  > "SnapBeat creates music videos by synchronizing user-selected photos with audio beats. Rendering high-definition video involves uploading media bundles, processing frame-by-frame video generation, and downloading the rendered MP4 directly to the user's gallery. The `DATA_SYNC` foreground service ensures this multi-step queue operation is not abruptly terminated by the operating system if the user navigates away from the app. A visible, ongoing notification keeps the user informed of upload, render, and download progress with an action to open the finished video."

* **Video Link (if requested):** Provide a short 30-second YouTube or Drive video showing the background render notification in action.

---

## 5. Summary of Compliance Enhancements in This Release
1. **Photo and Video Permissions Policy:** Removed obsolete `READ_MEDIA_IMAGES` and broad storage permissions from `AndroidManifest.xml`. The app complies 100% with the Android Photo Picker mandate.
2. **Prominent In-App Disclosure:** Non-dismissible first-launch dialog informs users about media processing and ephemeral automatic deletion with explicit consent.
3. **In-App Privacy Access:** Clickable footer link provides instant access to the complete policy inside the app at any time.
4. **Data Minimization:** No advertising SDKs, tracking pixels, or persistent user profiles.
