import os
from pathlib import Path
import shutil

source = Path(r"C:\MyProjects\SnapBeat\References\Icon\2line_no_tag.png")
target_dir = Path(r"C:\MyProjects\SnapBeat\app\src\main\res\mipmap-xxhdpi")
target_dir.mkdir(parents=True, exist_ok=True)

shutil.copy2(source, target_dir / "ic_launcher.png")
shutil.copy2(source, target_dir / "ic_launcher_round.png")

manifest = Path(r"C:\MyProjects\SnapBeat\app\src\main\AndroidManifest.xml")
content = manifest.read_text(encoding="utf-8")
if 'android:icon' not in content:
    content = content.replace('android:allowBackup="true"', 'android:icon="@mipmap/ic_launcher"\n        android:roundIcon="@mipmap/ic_launcher_round"\n        android:allowBackup="true"')
    manifest.write_text(content, encoding="utf-8")
    print("Added icons to manifest!")
else:
    print("Icons already in manifest.")

