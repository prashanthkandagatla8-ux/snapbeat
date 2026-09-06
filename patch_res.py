import os
from pathlib import Path

root = Path(r"C:\MyProjects\SnapBeat\app\src\main")

# 1. Update activity_main.xml
activity_xml = """<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fillViewport="true"
    android:background="#FFFCF5">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="24dp">

        <TextView
            android:id="@+id/tvTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="SNAPBEAT"
            android:textColor="#000000"
            android:textSize="42sp"
            android:textStyle="bold"
            android:fontFamily="sans-serif-black"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

        <com.google.android.material.switchmaterial.SwitchMaterial
            android:id="@+id/switchMode"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="BASIC"
            android:textStyle="bold"
            android:checked="true"
            app:layout_constraintBottom_toBottomOf="@+id/tvTitle"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintTop_toTopOf="@+id/tvTitle" />

        <TextView
            android:id="@+id/tvSubtitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:text="let the music decide your edit."
            android:textColor="#555555"
            android:textSize="16sp"
            android:fontFamily="casual"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@+id/tvTitle" />

        <androidx.appcompat.widget.AppCompatButton
            android:id="@+id/btnSelectMusic"
            android:layout_width="0dp"
            android:layout_height="75dp"
            android:layout_marginTop="40dp"
            android:background="@drawable/btn_retro_pink"
            android:text="PICK A TAPE"
            android:textSize="20sp"
            android:textStyle="bold"
            android:textColor="#FFFFFF"
            android:fontFamily="sans-serif-black"
            android:stateListAnimator="@null"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@+id/tvSubtitle" />
            
        <TextView
            android:id="@+id/tvMusicStatus"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="no tape selected"
            android:layout_marginTop="12dp"
            android:textColor="#555555"
            android:fontFamily="casual"
            android:textStyle="bold"
            app:layout_constraintTop_toBottomOf="@+id/btnSelectMusic"
            app:layout_constraintStart_toStartOf="parent" />

        <androidx.appcompat.widget.AppCompatButton
            android:id="@+id/btnSelectPhotos"
            android:layout_width="0dp"
            android:layout_height="75dp"
            android:layout_marginTop="24dp"
            android:background="@drawable/btn_retro_blue"
            android:text="POLAROID STACK"
            android:textSize="20sp"
            android:textStyle="bold"
            android:textColor="#000000"
            android:fontFamily="sans-serif-black"
            android:stateListAnimator="@null"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@+id/tvMusicStatus" />
            
        <TextView
            android:id="@+id/tvPhotosStatus"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="0 photos (tap to load)"
            android:layout_marginTop="12dp"
            android:textColor="#555555"
            android:fontFamily="casual"
            android:textStyle="bold"
            app:layout_constraintTop_toBottomOf="@+id/btnSelectPhotos"
            app:layout_constraintStart_toStartOf="parent" />

        <ProgressBar
            android:id="@+id/progressBar"
            style="?android:attr/progressBarStyleHorizontal"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginTop="40dp"
            android:layout_marginBottom="16dp"
            android:max="100"
            android:visibility="gone"
            app:layout_constraintBottom_toTopOf="@+id/tvStatus"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent" />

        <TextView
            android:id="@+id/tvStatus"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginBottom="24dp"
            android:textAlignment="center"
            android:fontFamily="casual"
            android:textStyle="bold"
            android:textColor="#000000"
            app:layout_constraintBottom_toTopOf="@+id/btnRender"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent" />

        <androidx.appcompat.widget.AppCompatButton
            android:id="@+id/btnRender"
            android:layout_width="0dp"
            android:layout_height="75dp"
            android:layout_marginBottom="40dp"
            android:background="@drawable/btn_retro_yellow"
            android:text="RENDER VIDEO"
            android:textSize="22sp"
            android:textStyle="bold"
            android:textColor="#000000"
            android:fontFamily="sans-serif-black"
            android:stateListAnimator="@null"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent" />

    </androidx.constraintlayout.widget.ConstraintLayout>
</ScrollView>
"""
with open(root / "res/layout/activity_main.xml", "w", encoding="utf-8") as f:
    f.write(activity_xml)

# 2. Add res/xml/file_paths.xml for FileProvider
xml_dir = root / "res/xml"
xml_dir.mkdir(exist_ok=True)
with open(xml_dir / "file_paths.xml", "w", encoding="utf-8") as f:
    f.write('<?xml version="1.0" encoding="utf-8"?><paths><external-files-path name="videos" path="." /></paths>')

# 3. Update AndroidManifest.xml
manifest_path = root / "AndroidManifest.xml"
with open(manifest_path, "r", encoding="utf-8") as f:
    manifest = f.read()

if "<provider" not in manifest:
    provider_str = """        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>"""
    manifest = manifest.replace("</application>", provider_str)
    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(manifest)

# 4. Update build.gradle (app level)
gradle_path = Path(r"C:\MyProjects\SnapBeat\app\build.gradle")
with open(gradle_path, "r", encoding="utf-8") as f:
    gradle = f.read()

if "kotlinx-coroutines-android" not in gradle:
    gradle = gradle.replace("dependencies {", "dependencies {\n    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'\n    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'\n")
    with open(gradle_path, "w", encoding="utf-8") as f:
        f.write(gradle)

print("Android resources updated")
