# SnapBeat Android App — Code Review & Improvement Plan

**Reviewed:** September 6, 2026  
**Codebase:** `C:\MyProjects\SnapBeat`  
**Stack:** Kotlin · Android SDK 34 · OkHttp · ViewBinding

---

## Executive Summary

The entire Android app currently lives in a single `MainActivity.kt` (232 lines) that handles UI, networking, file I/O, JSON parsing, polling, and video playback. While functional for a prototype, there are **critical crash bugs**, **memory leaks**, and **architectural issues** that must be fixed before any real-world testing or Play Store release.

---

## PRIORITY 1: Critical Crash & Data Loss Fixes

### 1.1 Out of Memory Crash on Video Download (CRITICAL)

**File:** `MainActivity.kt` — `pollStatusAndDownload()`

**Problem:** Line `response.body?.bytes()` loads the **entire rendered video** into RAM as a `byte[]`. A 1080p video (50MB-200MB+) will exceed Android's per-app heap limit and crash with `OutOfMemoryError`.

**Current (Dangerous):**
```kotlin
val responseData = response.body?.bytes()
val fos = FileOutputStream(outputFile)
fos.write(responseData)
```

**Fix (Stream to disk):**
```kotlin
val inputStream = response.body?.byteStream() ?: throw IOException("Empty response")
val outputFile = File(getExternalFilesDir(null), "SnapBeat_Render_${jobId}.mp4")
FileOutputStream(outputFile).use { fos ->
    val buffer = ByteArray(8192)
    var bytesRead: Int
    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
        fos.write(buffer, 0, bytesRead)
    }
}
inputStream.close()
```

---

### 1.2 Video Never Appears in Gallery

**File:** `MainActivity.kt`

**Problem:** The video is saved to `getExternalFilesDir(null)` which maps to `/Android/data/com.kiro.snapbeat/files/`. Android's MediaScanner **completely ignores** this directory. The video will never show up in the user's Photos or Gallery app.

**Fix (Use MediaStore API for Android 10+):**
```kotlin
import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore

fun saveVideoToGallery(inputStream: InputStream, jobId: Int): Uri? {
    val values = ContentValues().apply {
        put(MediaStore.Video.Media.DISPLAY_NAME, "SnapBeat_${jobId}.mp4")
        put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
        put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/SnapBeat")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            put(MediaStore.Video.Media.IS_PENDING, 1)
        }
    }
    
    val uri = contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)
        ?: return null
    
    contentResolver.openOutputStream(uri)?.use { out ->
        val buffer = ByteArray(8192)
        var bytesRead: Int
        while (inputStream.read(buffer).also { bytesRead = it } != -1) {
            out.write(buffer, 0, bytesRead)
        }
    }
    
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        values.clear()
        values.put(MediaStore.Video.Media.IS_PENDING, 0)
        contentResolver.update(uri, values, null, null)
    }
    
    return uri
}
```

---

### 1.3 FileUriExposedException on Video Playback

**File:** `MainActivity.kt`

**Problem:** `Uri.parse(outputFile.absolutePath)` crashes on Android 7.0+ with `FileUriExposedException`. The empty `catch (e: Exception) {}` silently swallows it, so the video player never opens.

**Fix:** Use `FileProvider`:

**Step 1:** Add to `AndroidManifest.xml` inside `<application>`:
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

**Step 2:** Create `res/xml/file_paths.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path name="videos" path="." />
</paths>
```

**Step 3:** Use FileProvider URI:
```kotlin
val uri = FileProvider.getUriForFile(this, "${packageName}.fileprovider", outputFile)
val intent = Intent(Intent.ACTION_VIEW).apply {
    setDataAndType(uri, "video/mp4")
    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
}
startActivity(intent)
```

*Note: If you implement 1.2 (MediaStore), you already get a content URI and don't need FileProvider for playback.*

---

### 1.4 Cache Files Never Cleaned Up (Storage Leak)

**File:** `MainActivity.kt` — `getFileFromUri()`

**Problem:** Every render copies up to 61 files (1 audio + 60 photos) into `cacheDir` with timestamped names. They are **never deleted**. Repeated renders will consume gigabytes of internal storage.

**Fix:** Delete cache files after successful upload:
```kotlin
// After the upload succeeds, clean up:
val cacheFiles = cacheDir.listFiles() ?: emptyArray()
for (file in cacheFiles) {
    if (file.name.startsWith("music_") || file.name.startsWith("photo_")) {
        file.delete()
    }
}
```

---

## PRIORITY 2: Stability & Robustness

### 2.1 Raw Thread Leaking Activity Context

**File:** `MainActivity.kt` — `uploadAndRender()`

**Problem:** `Thread { ... }.start()` creates an unmanaged background thread that holds a strong reference to the Activity via `this`, `binding`, and `runOnUiThread`. If the user rotates the phone, presses Back, or switches apps, the Activity is destroyed but the thread keeps running, leaking memory and crashing when it tries to update dead views.

**Fix:** Replace raw Thread with Kotlin Coroutines:

**Step 1:** Add dependencies to `app/build.gradle`:
```groovy
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
```

**Step 2:** Replace `Thread { ... }.start()` with:
```kotlin
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.*

lifecycleScope.launch(Dispatchers.IO) {
    try {
        // ... upload logic ...
        withContext(Dispatchers.Main) {
            binding.tvStatus.text = "Uploading..."
        }
    } catch (e: Exception) {
        withContext(Dispatchers.Main) {
            binding.tvStatus.text = "Error: ${e.message}"
        }
    }
}
```

---

### 2.2 Force-Unwrap (`!!`) Crashes

**File:** `MainActivity.kt`

**Problem:** Lines like `getFileFromUri(selectedMusicUri!!, "music")!!` will crash with `NullPointerException` if a URI becomes invalid (e.g., cloud photo not downloaded, file descriptor closed).

**Fix:** Use safe calls with proper error handling:
```kotlin
val musicFile = getFileFromUri(selectedMusicUri!!, "music")
if (musicFile == null) {
    runOnUiThread { binding.tvStatus.text = "Error: Could not read music file" }
    return
}
```

---

### 2.3 Infinite Polling Loop (No Timeout or Retry Logic)

**File:** `MainActivity.kt` — `pollStatusAndDownload()`

**Problem:** The `while (!isDone)` loop has:
- No maximum timeout (loops forever if server hangs)
- No retry count for transient network errors
- No backoff if server returns non-200

**Fix:**
```kotlin
var pollCount = 0
val maxPolls = 600  // 600 * 1.5s = 15 minutes max

while (!isDone && pollCount < maxPolls) {
    Thread.sleep(1500)
    pollCount++
    
    try {
        client.newCall(statusRequest).execute().use { response ->
            if (!response.isSuccessful) {
                // Transient error, retry instead of crashing
                continue
            }
            // ... parse response ...
        }
    } catch (e: IOException) {
        // Network blip, retry up to 3 times
        if (pollCount % 3 == 0) continue
        else throw e
    }
}

if (pollCount >= maxPolls) {
    throw IOException("Render timed out after 15 minutes")
}
```

---

### 2.4 Missing Runtime Permission Requests

**File:** `AndroidManifest.xml` + `MainActivity.kt`

**Problem:** Dangerous permissions (`READ_MEDIA_IMAGES`, `READ_MEDIA_AUDIO`) are declared in the manifest but **never requested at runtime**. On Android 13+ (API 33+), the app silently cannot access media.

**Fix:** Add runtime permission request before file pickers:
```kotlin
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

private fun checkPermissionsAndPick(requestCode: Int) {
    val perms = if (Build.VERSION.SDK_INT >= 33) {
        arrayOf(Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_AUDIO)
    } else {
        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
    }
    
    val needed = perms.filter {
        ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
    }
    
    if (needed.isEmpty()) {
        launchPicker(requestCode)
    } else {
        ActivityCompat.requestPermissions(this, needed.toTypedArray(), requestCode)
    }
}
```

---

## PRIORITY 3: Configuration & Build

### 3.1 Hardcoded Server URL

**Problem:** The IP `192.168.68.104:8772` is hardcoded in 3 places. If the IP changes, the app breaks.

**Fix — Option A (BuildConfig):** Add to `app/build.gradle`:
```groovy
android {
    defaultConfig {
        buildConfigField "String", "SERVER_URL", '"http://192.168.68.104:8772"'
    }
    buildFeatures {
        buildConfig true
    }
}
```
Then use `BuildConfig.SERVER_URL` in Kotlin code.

**Fix — Option B (SharedPreferences with UI):**
Add a Settings screen where the user can type the server IP. Store it in SharedPreferences.

---

### 3.2 Remove Unused Dependencies

**File:** `app/build.gradle`

**Problem:** `retrofit` and `converter-gson` are included but never used.

**Fix:** Remove:
```groovy
// DELETE these two lines:
implementation 'com.squareup.retrofit2:retrofit:2.9.0'
implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
```

---

### 3.3 Remove Unused Maven Repositories

**File:** `settings.gradle`

**Problem:** `chaquo.com/maven` and `jitpack.io` are configured but no dependencies use them.

**Fix:** Remove:
```groovy
// DELETE from both pluginManagement and dependencyResolutionManagement:
maven { url 'https://chaquo.com/maven' }
maven { url 'https://jitpack.io' }
```

---

### 3.4 Scoped Network Security Config

**File:** `AndroidManifest.xml`

**Problem:** `android:usesCleartextTraffic="true"` allows HTTP globally. This is flagged by Google Play security review.

**Fix:** Use a scoped network security config:

**Step 1:** Create `res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">192.168.68.104</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

**Step 2:** Update `AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

## PRIORITY 4: UI & UX Improvements

### 4.1 Wrap Layout in ScrollView

**File:** `activity_main.xml`

**Problem:** Three 75dp buttons plus text views overflow on small screens. No scrolling.

**Fix:** Wrap the `ConstraintLayout` in a `ScrollView`.

---

### 4.2 Extract Hardcoded Strings to `strings.xml`

**Problem:** All text is hardcoded in the XML layout. This prevents localization and is flagged by Android Lint.

**Fix:** Create `res/values/strings.xml`:
```xml
<resources>
    <string name="app_name">SnapBeat</string>
    <string name="title">SNAPBEAT</string>
    <string name="subtitle">let the music decide your edit.</string>
    <string name="pick_tape">PICK A TAPE</string>
    <string name="polaroid_stack">POLAROID STACK</string>
    <string name="render_video">RENDER VIDEO</string>
    <string name="no_tape">no tape selected</string>
    <string name="photos_default">0 photos (tap to load)</string>
</resources>
```

---

### 4.3 Use Modern Activity Result API

**Problem:** `startActivityForResult` and `onActivityResult` are deprecated since AndroidX Activity 1.2.0.

**Fix:** Use `registerForActivityResult`:
```kotlin
private val musicPicker = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
    uri?.let {
        selectedMusicUri = it
        binding.tvMusicStatus.text = "1 tape selected"
    }
}

// In button click:
musicPicker.launch("audio/*")
```

---

### 4.4 Add App Icon

**Problem:** No `android:icon` or `android:roundIcon` in the manifest. The app shows the generic green Android robot icon.

**Fix:** Use Android Studio's Image Asset tool (right-click `res` > New > Image Asset) to generate adaptive icons.

---

## PRIORITY 5: Architecture (Future — MVVM)

### 5.1 Separate Concerns with ViewModel

**Problem:** UI, networking, file I/O, JSON parsing, polling, and video playback are all in one 232-line Activity class ("God Activity").

**Fix:** Move to MVVM architecture:
- `MainViewModel` — Holds UI state (selected URIs, render progress, error messages) in `StateFlow`/`LiveData`. Survives screen rotation.
- `RenderRepository` — Handles all OkHttp networking and JSON parsing.
- `StorageHelper` — Handles MediaStore save and FileProvider.
- `MainActivity` — Only observes ViewModel state and updates UI.

---

## Summary Table

| # | Issue | Severity | Effort |
|---|-------|----------|--------|
| 1.1 | OOM crash on video download | CRITICAL | 15 min |
| 1.2 | Video not visible in gallery | CRITICAL | 30 min |
| 1.3 | FileUriExposedException crash | CRITICAL | 20 min |
| 1.4 | Cache files never cleaned | HIGH | 10 min |
| 2.1 | Raw Thread leaking Activity | HIGH | 30 min |
| 2.2 | Force-unwrap crashes | HIGH | 10 min |
| 2.3 | Infinite polling loop | MEDIUM | 15 min |
| 2.4 | Missing runtime permissions | MEDIUM | 20 min |
| 3.1 | Hardcoded server URL | MEDIUM | 15 min |
| 3.2 | Remove unused dependencies | LOW | 2 min |
| 3.3 | Remove unused repositories | LOW | 2 min |
| 3.4 | Scoped network security config | LOW | 10 min |
| 4.1 | ScrollView for small screens | LOW | 5 min |
| 4.2 | Extract strings to strings.xml | LOW | 10 min |
| 4.3 | Modern Activity Result API | LOW | 15 min |
| 4.4 | Add app icon | LOW | 5 min |
| 5.1 | MVVM architecture refactor | FUTURE | 2-3 hours |
