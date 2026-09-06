import os
import shutil
from pathlib import Path
from PIL import Image

app_dir = Path(r"C:\MyProjects\SnapBeat\app")
res_dir = app_dir / "src" / "main" / "res"
source_icon = Path(r"C:\MyProjects\SnapBeat\References\Icon\2line_no_tag.png")

# Delete adaptive icons
anydpi_dir = res_dir / "mipmap-anydpi-v26"
if anydpi_dir.exists():
    shutil.rmtree(anydpi_dir)
    print("Deleted adaptive icon XMLs")

# Load original
img = Image.open(source_icon).convert("RGBA")

# Create different sizes for legacy
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192
}

for folder, size in sizes.items():
    out_dir = res_dir / folder
    out_dir.mkdir(exist_ok=True, parents=True)
    
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(out_dir / "ic_launcher.png")
    resized.save(out_dir / "ic_launcher_round.png")
    
    # delete foreground if exists
    fg = out_dir / "ic_launcher_foreground.png"
    if fg.exists():
        fg.unlink()

print("Restored original transparent icons!")
