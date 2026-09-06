import re
from pathlib import Path

kt_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\java\com\kiro\snapbeat\MainActivity.kt")
content = kt_path.read_text(encoding="utf-8")

old_templates_line = 'val templates = arrayOf("Auto (Beat Cut)", "Simple", "Pendulum")'
new_templates_line = 'val templates = arrayOf("Pendulum", "Glide", "Spin")'

if old_templates_line in content:
    content = content.replace(old_templates_line, new_templates_line)
else:
    print("Could not find templates line")

# Update the template selection logic
old_logic = """                    val templateName = when(selection) {
                        "Simple" -> "simple"
                        "Pendulum" -> "pendulum"
                        else -> "beat-cut"
                    }"""

new_logic = """                    val templateName = when(selection) {
                        "Pendulum" -> "pendulum"
                        "Glide" -> "glide-pan"
                        "Spin" -> "beat-spin"
                        else -> "simple"
                    }"""

if old_logic in content:
    content = content.replace(old_logic, new_logic)
else:
    print("Could not find mapping logic")

kt_path.write_text(content, encoding="utf-8")
print("Patched MainActivity.kt")

