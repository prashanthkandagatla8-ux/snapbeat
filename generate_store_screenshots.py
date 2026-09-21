"""
SnapBeat Studio — App Store Screenshot Formatter & Asset Generator
Converts raw captured UI frames into exact Apple App Store Connect specifications:
- 6.7" Super Retina XDR (1290 x 2796, 24-bit RGB, No Alpha)
- 6.5" Super Retina HD (1284 x 2778 / 1242 x 2688, 24-bit RGB, No Alpha)
- In-App Purchase Review Screenshots (1290 x 2796, 1284 x 2778, 1242 x 2688)
"""
import os
import sys
from pathlib import Path
from PIL import Image

BASE_DIR = Path(__file__).resolve().parent
RAW_DIR = BASE_DIR / "store_assets" / "screenshots"
OUT_67 = BASE_DIR / "store_assets" / "ios_screenshots_6.7"
OUT_65 = BASE_DIR / "store_assets" / "ios_screenshots_6.5"
OUT_IAP = BASE_DIR / "store_assets" / "iap_review_screenshots"

OUT_67.mkdir(parents=True, exist_ok=True)
OUT_65.mkdir(parents=True, exist_ok=True)
OUT_IAP.mkdir(parents=True, exist_ok=True)

SCREENS = [
    "01_music_deck.png",
    "02_photos_stage.png",
    "03_render_auto.png",
    "04_render_pro.png",
    "05_queue_vault.png",
]

def format_image(src_path: Path, target_w: int, target_h: int) -> Image.Image:
    """Resize source image preserving aspect ratio with centered dark console padding."""
    im = Image.open(src_path)
    if im.mode != "RGBA":
        im = im.convert("RGBA")

    # Calculate scale to fit inside target dimensions
    scale = min(target_w / im.width, target_h / im.height)
    new_w = int(round(im.width * scale))
    new_h = int(round(im.height * scale))

    resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # Base canvas matching dark console backdrop (#0B0D10)
    canvas = Image.new("RGB", (target_w, target_h), (11, 13, 16))
    offset_x = (target_w - new_w) // 2
    offset_y = (target_h - new_h) // 2

    canvas.paste(resized, (offset_x, offset_y), resized)
    return canvas

def main():
    print("[*] Processing App Store Screenshots...")

    # 1. Generate 6.7" Screenshots (1290 x 2796)
    print("\n--- Generating 6.7\" Display Screenshots (1290 x 2796) ---")
    for name in SCREENS:
        src = RAW_DIR / name
        if not src.exists():
            print(f"[!] Warning: {src} not found, skipping.")
            continue
        dst = OUT_67 / name
        img = format_image(src, 1290, 2796)
        img.save(dst, format="PNG")
        print(f"  [+] Saved {dst.name}: {img.size} {img.mode} ({os.path.getsize(dst):,} bytes)")

    # 2. Generate 6.5" Screenshots (1284 x 2778)
    print("\n--- Generating 6.5\" Display Screenshots (1284 x 2778) ---")
    for name in SCREENS:
        src = RAW_DIR / name
        if not src.exists():
            continue
        dst = OUT_65 / name
        img = format_image(src, 1284, 2778)
        img.save(dst, format="PNG")
        print(f"  [+] Saved {dst.name}: {img.size} {img.mode} ({os.path.getsize(dst):,} bytes)")

    # 3. Generate IAP Review Screenshots from 06_subscription_review.png
    sub_src = RAW_DIR / "06_subscription_review.png"
    if sub_src.exists():
        print("\n--- Generating In-App Purchase Review Screenshots ---")
        # 1290x2796
        img_67 = format_image(sub_src, 1290, 2796)
        p_67_png = OUT_IAP / "iap_screenshot_1290x2796.png"
        p_67_jpg = OUT_IAP / "iap_screenshot_1290x2796.jpg"
        img_67.save(p_67_png, format="PNG")
        img_67.save(p_67_jpg, format="JPEG", quality=95)
        print(f"  [+] Saved {p_67_png.name} & {p_67_jpg.name}: {img_67.size}")

        # 1284x2778
        img_65 = format_image(sub_src, 1284, 2778)
        p_65_png = OUT_IAP / "iap_screenshot_1284x2778.png"
        p_65_jpg = OUT_IAP / "iap_screenshot_1284x2778.jpg"
        img_65.save(p_65_png, format="PNG")
        img_65.save(p_65_jpg, format="JPEG", quality=95)
        print(f"  [+] Saved {p_65_png.name} & {p_65_jpg.name}: {img_65.size}")

        # 1242x2688
        img_1242 = format_image(sub_src, 1242, 2688)
        p_1242_png = OUT_IAP / "iap_screenshot_1242x2688.png"
        p_1242_jpg = OUT_IAP / "iap_screenshot_1242x2688.jpg"
        img_1242.save(p_1242_png, format="PNG")
        img_1242.save(p_1242_jpg, format="JPEG", quality=95)
        print(f"  [+] Saved {p_1242_png.name} & {p_1242_jpg.name}: {img_1242.size}")

        # Root store_assets review screenshots
        root_sub_png = BASE_DIR / "store_assets" / "subscription_review_screenshot.png"
        root_sub_jpg = BASE_DIR / "store_assets" / "subscription_review_screenshot.jpg"
        img_67.save(root_sub_png, format="PNG")
        img_67.save(root_sub_jpg, format="JPEG", quality=95)
        print(f"  [+] Saved root subscription review assets.")

    print("\n[SUCCESS] All App Store screenshots generated and verified!")

if __name__ == "__main__":
    main()
