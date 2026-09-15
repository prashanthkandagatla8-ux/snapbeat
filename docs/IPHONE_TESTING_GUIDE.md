# SnapBeat iOS: Complete iPhone Testing Guide (From Windows)

This guide walks you through testing the SnapBeat iOS app on your physical iPhone without needing to own a Mac.

---

## Step 1: Cloud Build via GitHub Actions

Because Apple's iOS build tools require macOS, we have configured an automated GitHub Actions cloud workflow (`.github/workflows/ios_build.yml`) that runs on Apple-hosted cloud Mac runners.

1. Commit and push your latest code to GitHub:
   ```bash
   cd C:\MyProjects\snapbeat_flutter
   git push origin master
   ```
2. In your web browser, open your GitHub repository:
   `https://github.com/prashanthkandagatla8-ux/snapbeat`
3. Click the **Actions** tab at the top.
4. Select **"SnapBeat iOS Build & Package"** on the left.
5. Click **"Run workflow"** -> **"Run workflow"** (or it will run automatically on push).
6. The cloud Mac will checkout Flutter 3.47.2, build the release iOS bundle, and produce `SnapBeat-Release-v1.0.3+4.ipa`.
7. When complete (~3 to 5 minutes), click on the completed run, scroll to the bottom under **Artifacts**, and download **`SnapBeat-iOS-IPA-v1.0.3+4.zip`**.
8. Unzip it to get `SnapBeat-Release-v1.0.3+4.ipa`.

---

## Step 2: Install the .IPA on Your iPhone (via Sideloadly)

[Sideloadly](https://sideloadly.io/) is the industry-standard, free tool for installing `.ipa` files onto an iPhone from Windows using a normal Apple ID (no $99/yr Apple Developer account needed).

### Installation Steps:
1. Download and install **Sideloadly for Windows (64-bit)** from [https://sideloadly.io/](https://sideloadly.io/).
2. Also ensure you have iTunes or iCloud for Windows installed (Sideloadly uses Apple's driver to communicate with your iPhone).
3. Connect your iPhone to your Windows PC with your USB-C or Lightning cable.
   * If your iPhone asks *"Trust this Computer?"*, tap **Trust** and enter your passcode.
4. Open **Sideloadly**:
   * It will detect your connected iPhone in the **Device** field.
   * In **Apple ID**, enter your normal Apple ID email.
   * Drag and drop `SnapBeat-Release-v1.0.3+4.ipa` into the large icon box on the left.
5. Click **Start**:
   * Sideloadly will ask for your Apple ID password to generate a free personal developer signature.
   * It signs and installs SnapBeat directly onto your iPhone!

---

## Step 3: First-Time Launch Authorization on iPhone

Because this is a developer sideload on iOS:
1. On your iPhone, open **Settings**.
2. Tap **General** -> scroll down to **VPN & Device Management**.
3. Under *Developer App*, tap your Apple ID email.
4. Tap **"Trust [Your Apple ID]"** -> tap **Trust**.
5. *(iOS 16+ only)*: If prompted to enable Developer Mode:
   * Go to **Settings -> Privacy & Security -> Developer Mode** (at the bottom).
   * Toggle it ON, and restart your iPhone when prompted.
6. Open **SnapBeat** from your Home Screen!

---

## What to Test in SnapBeat iOS:
* **Audio Playback**: Tap through the 16 built-in sample tracks; verify waveform scrubbing and play/pause.
* **Photo Stack**: Pick 2 to 60 photos from your iPhone Camera Roll / Recents; verify additive stacking and drag-and-drop reordering.
* **Chassis Aesthetic**: Check the light cream/brushed metal styling and CRT screen framing.
* **Rendering**: Tap **"CREATE REEL"**; verify multipart upload to VPS (`34.93.112.240`), queue progress, and saving the final `.mp4` reel directly to your iPhone Photos app!
