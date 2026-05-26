"""Replace the logo image on page 1 of Laliguras_Print_Menu.pdf with logo.png.

The original print menu PDF has exactly one embedded image (the cover logo).
Approach: find that single Image XObject on page 1 and rewrite its pixel stream
from the current logo.png, preserving size, orientation, and placement.
"""
from pathlib import Path
from io import BytesIO
import pikepdf
from PIL import Image
import sys

ROOT = Path(r"C:\Users\GME\OneDrive\Desktop\Projects\LG\HwaseongLaliguras")
SRC_PDF = ROOT / "Laliguras_Print_Menu.pdf"
OUT_PDF = ROOT / "Laliguras_Print_Menu.pdf"
BACKUP = ROOT / "Laliguras_Print_Menu.old.pdf"
NEW_LOGO = ROOT / "logo.png"

if not BACKUP.exists():
    BACKUP.write_bytes(SRC_PDF.read_bytes())
    print(f"backup -> {BACKUP.name}")

pdf = pikepdf.open(str(SRC_PDF), allow_overwriting_input=True)
page1 = pdf.pages[0]
images = page1.images  # dict of name -> Image XObject

if not images:
    sys.exit("no images on page 1 — cannot swap")

if len(images) > 1:
    print(f"warning: {len(images)} images on page 1, picking the largest one")

# Pick the largest image (the cover logo dominates the page)
name, target = max(
    images.items(),
    key=lambda kv: int(kv[1].Width) * int(kv[1].Height),
)
orig_w = int(target.Width)
orig_h = int(target.Height)
print(f"target image: /{name}  {orig_w}x{orig_h}")

# Load the new logo and match the original pixel dimensions so the placement
# on the page is unchanged (the PDF references the image via a transform matrix
# that maps the image's pixel rectangle into page units).
new_img = Image.open(NEW_LOGO).convert("RGB")
print(f"new logo source: {new_img.size}")
# Match aspect-ratio of the original; if it differs, fit centered onto a transparent
# canvas resampled to the original's WxH. (For the Hapdeok logo the source is square
# 1134x1134 — same aspect ratio as the original cover image, so no padding needed.)
if new_img.size != (orig_w, orig_h):
    new_img = new_img.resize((orig_w, orig_h), Image.LANCZOS)
    print(f"resized to {new_img.size}")

# Replace the image stream in-place. pikepdf exposes the XObject as a Stream;
# we write fresh JPEG-encoded bytes and update the descriptor entries.
buf = BytesIO()
new_img.save(buf, format="JPEG", quality=92, optimize=True)
jpeg_bytes = buf.getvalue()
target.write(jpeg_bytes, filter=pikepdf.Name.DCTDecode)
target.Width = new_img.width
target.Height = new_img.height
target.ColorSpace = pikepdf.Name.DeviceRGB
target.BitsPerComponent = 8
# Drop any soft-mask the old image used; the new logo is fully opaque RGB.
for key in ("/SMask", "/Mask"):
    if key in target.keys():
        del target[key]
print(f"image stream replaced ({len(jpeg_bytes):,} bytes JPEG)")

pdf.save(OUT_PDF, linearize=True)
pdf.close()
print(f"wrote {OUT_PDF}")
