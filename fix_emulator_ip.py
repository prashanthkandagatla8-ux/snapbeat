import os
from pathlib import Path

bg_path = Path(r"C:\MyProjects\SnapBeat\app\build.gradle")
content = bg_path.read_text(encoding="utf-8")

old_str = 'buildConfigField "String", "SERVER_URL", \'"http://192.168.68.104:8772"\''
new_str = 'buildConfigField "String", "SERVER_URL", \'"http://10.0.2.2:8772"\''

if old_str in content:
    content = content.replace(old_str, new_str)
    bg_path.write_text(content, encoding="utf-8")
    print("Fixed SERVER_URL for emulator!")
else:
    print("Still could not find it")

