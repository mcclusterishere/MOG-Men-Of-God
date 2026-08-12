from PIL import Image, ImageFilter, ImageOps
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parent
SOURCE_DIRS = [ROOT / "identity", ROOT / "glyphs"]
MASK_ROOT = ROOT / "material-masks"


def derive_masks(path: Path) -> None:
    im = Image.open(path).convert("RGBA")
    rgb = im.convert("RGB")
    alpha = im.getchannel("A").point(lambda x: 255 if x > 16 else 0)

    hsv = rgb.convert("HSV")
    h, s, v = [np.array(ch) for ch in hsv.split()]
    a = np.array(alpha)

    # Staging-only approximations. Review before production use.
    gold = ((h >= 12) & (h <= 45) & (s >= 55) & (v >= 85) & (a > 0)).astype("uint8") * 255
    specular = ((v >= 190) & (a > 0)).astype("uint8") * 255
    dark_metal = ((v < 150) & (a > 0)).astype("uint8") * 255

    gray = ImageOps.grayscale(rgb)
    edges = gray.filter(ImageFilter.FIND_EDGES).filter(ImageFilter.GaussianBlur(0.7))
    detail = ((np.array(edges) >= 32) & (a > 0)).astype("uint8") * 255

    out = MASK_ROOT / path.stem
    out.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.array(alpha)).save(out / "alpha-mask.png")
    Image.fromarray(gold).save(out / "gold-mask.png")
    Image.fromarray(specular).save(out / "specular-mask.png")
    Image.fromarray(dark_metal).save(out / "dark-metal-mask.png")
    Image.fromarray(detail).save(out / "detail-mask.png")


if __name__ == "__main__":
    for directory in SOURCE_DIRS:
        if not directory.exists():
            continue
        for path in directory.glob("*.png"):
            derive_masks(path)
            print(f"generated staging masks for {path.relative_to(ROOT)}")

    print("IMPORTANT: detail-mask is not a semantic crack mask. Hand-author exact masks when needed.")
