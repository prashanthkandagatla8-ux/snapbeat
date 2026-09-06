import os
import re
from pathlib import Path

kt_path = Path(r"C:\MyProjects\SnapBeat\app\src\main\java\com\kiro\snapbeat\MainActivity.kt")
content = kt_path.read_text(encoding="utf-8")

old_templates = 'val templates = arrayOf("Pendulum", "Glide", "Spin")'
new_templates = 'val templates = arrayOf("Pendulum", "Glide", "Sway", "Punch", "Mosaic Reveal", "Spin", "Pulse", "Whip", "Slow Drift", "Auto (Beat Cut)")'

if old_templates in content:
    content = content.replace(old_templates, new_templates)
else:
    print("Could not find old templates array")

old_mapping = """                    val templateName = when(selection) {
                        "Pendulum" -> "pendulum"
                        "Glide" -> "glide-pan"
                        "Spin" -> "beat-spin"
                        else -> "simple"
                    }"""

new_mapping = """                    val templateName = when(selection) {
                        "Pendulum" -> "pendulum"
                        "Glide" -> "glide-pan"
                        "Sway" -> "sway-ballad"
                        "Punch" -> "punch-cut"
                        "Mosaic Reveal" -> "reveal-tiles"
                        "Spin" -> "beat-spin"
                        "Pulse" -> "beat-pulse"
                        "Whip" -> "beat-whip"
                        "Slow Drift" -> "slow-drift"
                        "Auto (Beat Cut)" -> "beat-cut"
                        else -> "simple"
                    }"""

if old_mapping in content:
    content = content.replace(old_mapping, new_mapping)
else:
    print("Could not find old mapping")

kt_path.write_text(content, encoding="utf-8")
print("Successfully patched templates list in MainActivity.kt")
