import os
from pathlib import Path

xml_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\res\layout\activity_main.xml")
content = xml_path.read_text(encoding="utf-8")

old_str = 'app:layout_constraintTop_toBottomOf="@+id/proModeContainer"'
new_str = 'app:layout_constraintTop_toBottomOf="@+id/tvSubtitle"'

if old_str in content:
    content = content.replace(old_str, new_str)
    xml_path.write_text(content, encoding="utf-8")
    print("Fixed layout constraint bug!")
else:
    print("Could not find the buggy constraint string.")

