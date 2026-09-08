# Privacy Policy for SnapBeat

**Effective Date:** September 8, 2026  
**Last Updated:** September 8, 2026  

SnapBeat ("we", "our", or "us") is dedicated to protecting your privacy. This Privacy Policy outlines how our mobile application collects, uses, processes, and protects your data when you use SnapBeat.

---

## 1. Information We Process

SnapBeat is designed with a privacy-first approach. We only process data that is strictly necessary for the core functionality of generating beat-synced music videos:

### A. User-Selected Media (Photos and Audio)
* **Photos & Images:** Only the specific photos you select from your device's photo picker to create your video. SnapBeat **never** accesses your full photo library, camera roll, or unselected media.
* **Audio Files:** Only the music track you select to sync with your video.
* **Ephemeral Processing:** Your selected photos and audio are transmitted via secure encrypted channels (TLS/HTTPS) to our cloud rendering engine solely to analyze beat markers, apply video transitions, and render the final MP4 video file.
* **Automatic Deletion:** Once your video rendering is complete and downloaded to your device gallery (or within 24 hours at maximum), your uploaded photos, audio tracks, and temporary rendering files are **permanently and automatically deleted** from our servers. We do not store, archive, or retain your personal photos or audio.

### B. AI-Assisted Arrangement & Analysis
* If you use our AI Smart Arrangement feature, visual analysis (such as color vibrance, tempo matching, and composition) is performed exclusively to determine the dramatic order of photos in your video.
* Your media is **never** used to train public machine learning models, and is never shared with unauthorized third parties.

### C. Device & Technical Information
* We do **not** collect advertising identifiers, GPS locations, contacts, or personal biometric profiles.
* Standard technical logs (e.g. error codes, rendering progress) are processed solely for performance monitoring and troubleshooting.

---

## 2. Permissions We Request

SnapBeat requests only the minimal permissions required to function:
* **Internet (`android.permission.INTERNET`):** To connect with the rendering engine for video processing.
* **Notifications (`android.permission.POST_NOTIFICATIONS`):** Optional. Used exclusively on Android 13+ to notify you when your background video render has finished and is saved to your gallery.
* **Foreground Service (`android.permission.FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_DATA_SYNC`):** Used strictly to allow your video rendering and download to complete smoothly in the background if you switch apps.

SnapBeat does **NOT** request broad storage permissions (`MANAGE_EXTERNAL_STORAGE` or `READ_EXTERNAL_STORAGE`), relying instead on Android's secure Photo Picker.

---

## 3. Data Sharing & Third Parties

* We **do not sell, rent, or trade** your personal data or media files to advertisers, data brokers, or third parties.
* Media processing takes place on our secure Google Cloud infrastructure located in compliance with modern data protection standards.

---

## 4. Data Security

We implement industry-standard administrative, technical, and physical security measures to protect your media during transmission and processing:
* Secure communication via HTTPS / TLS encryption.
* Isolated sandbox environments for each rendering job.
* Automated file deletion immediately upon job download.

---

## 5. Children's Privacy (COPPA Compliance)

SnapBeat is not intended for or directed to children under the age of 13. We do not knowingly collect or solicit personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will delete such data immediately.

---

## 6. Your Rights & Data Deletion

Because our processing is entirely ephemeral and files are deleted immediately after video generation, we do not maintain persistent databases of user personal media. However, you retain full rights to:
* Opt out of background notifications at any time via Android settings.
* Request confirmation of data deletion or inquire about our privacy practices by contacting us.

---

## 7. Contact Us

If you have any questions, feedback, or data privacy requests regarding SnapBeat, please contact our developer team at:

* **Email:** snapbeat.app@gmail.com
* **Project Repository:** https://github.com/prashanthkandagatla8-ux/snapbeat
