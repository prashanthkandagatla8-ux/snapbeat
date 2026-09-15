# SnapBeat iOS: Complete iPhone Testing Guide (From Windows)

This guide walks you through testing the SnapBeat iOS app on your physical iPhone without needing to own a Mac.

---

## Step 1: Cloud Build via GitHub Actions (Status: COMPLETED & DOWNLOADED)

The cloud build has completed successfully on GitHub Actions macOS runner.
The installable `.ipa` is **already downloaded and extracted right on your PC**:

📍 **Local Path on your computer:**
```
C:\MyProjects\snapbeat_flutter\build_artifacts\SnapBeat-Release-v1.0.3+4.ipa
```

*(If you ever make new code changes in the future, just run `git push origin master` and GitHub Actions will automatically compile a new IPA at [Actions Runs](https://github.com/prashanthkandagatla8-ux/snapbeat/actions)).*

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
