import os
from pathlib import Path
from PIL import Image

source_path = r"C:\MyProjects\SnapBeat\References\Icon\2line_no_tag.png"
res_dir = Path(r"C:\MyProjects\SnapBeat\app\src\main\res")

# Create directories
for dir_name in ["mipmap-xxhdpi", "mipmap-anydpi-v26", "values"]:
    (res_dir / dir_name).mkdir(parents=True, exist_ok=True)

# Process Image
img = Image.open(source_path).convert("RGBA")
# Target size for xxhdpi is usually 144x144, but we can just use a large 1024x1024 and let Android scale it.
# Actually, let's make it 1024x1024. Safe zone is 66/108 = 61%. 1024 * 0.61 = 624.
# Let's scale the logo to fit in 600x600.
img.thumbnail((600, 600), Image.Resampling.LANCZOS)

# Create a transparent 1024x1024 canvas for foreground / legacy
canvas = Image.new("RGBA", (1024, 1024), (255, 255, 255, 0))
# Paste in center
offset = ((1024 - img.width) // 2, (1024 - img.height) // 2)
canvas.paste(img, offset, img)

# Save Foreground for Adaptive Icon
canvas.save(res_dir / "mipmap-xxhdpi" / "ic_launcher_foreground.png")

# For legacy devices, maybe a white background looks better if it's currently a transparent square getting forced into a circle.
# Let's make the legacy icon have a white background so it looks like a white circle/square with the logo in it.
# Actually, transparent is fine, Android will just shape it. We'll use the padded one.
canvas.save(res_dir / "mipmap-xxhdpi" / "ic_launcher.png")
canvas.save(res_dir / "mipmap-xxhdpi" / "ic_launcher_round.png")

# Create colors.xml if needed for the background
colors_xml = res_dir / "values" / "colors.xml"
if not colors_xml.exists():
    colors_xml.write_text("""<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#FFFFFF</color>\n</resources>""")
else:
    content = colors_xml.read_text()
    if "ic_launcher_background" not in content:
        content = content.replace("</resources>", '    <color name="ic_launcher_background">#FFFFFF</color>\n</resources>')
        colors_xml.write_text(content)

# Create Adaptive Icon XML
xml_content = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
(res_dir / "mipmap-anydpi-v26" / "ic_launcher.xml").write_text(xml_content)
(res_dir / "mipmap-anydpi-v26" / "ic_launcher_round.xml").write_text(xml_content)

print("Icon processing complete.")
