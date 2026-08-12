"""Derive material-channel masks for the assets actually mounted at runtime.

This is a DERIVATIVE of `generate-material-masks.py`. That script is the canonical
generator and reads `design/brand/identity/` and `design/brand/glyphs/`, which hold
the brand masters. Those master files are not present in this repository, so this
script applies the identical staging thresholds to the rendered runtime assets in
`assets/` instead, and never modifies a source file.

Outputs
-------
design/brand/material-masks/<asset>/   full staging channel set, per the
                                       `mask_contract` in asset-manifest.json
assets/masks/<asset>/                  only the channels the runtime actually
                                       animates, to keep the shipped payload small

Provenance and precision
------------------------
`gold`, `dark-metal`, `specular` and `detail` use the exact thresholds from the
canonical generator. They are STAGING approximations.

`detail` is a high-frequency edge extraction. It is NOT a semantic crack mask and
must not be described as one.

`emissive` is an additional semantic derivation, not part of the canonical staging
set. It isolates the hot orange-red emitting region by hue, saturation and value.
Reviewed visually against the streak crest: it covers the flame tendrils AND the
lit day-marks, and correctly excludes the calendar body. It is therefore an
EMISSIVE mask, not a flame-only mask, and is valid for that artwork only.
"""

from PIL import Image, ImageFilter, ImageOps
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "assets"
STAGING = ROOT / "design" / "brand" / "material-masks"
RUNTIME = ASSETS / "masks"

# asset stem -> channels the runtime needs served
RUNTIME_CHANNELS = {
    "crest-streak-256": ["emissive"],
    "crest-streak-640": ["emissive"],
    "crest-breakthrough-640": ["detail"],
    "badge-rank-128": ["gold"],
    "badge-rank-256": ["gold"],
    "badge-verified-128": ["specular"],
    "badge-verified-256": ["specular"],
    "crest-brotherhood-256": ["gold"],
    "crest-brotherhood-512": ["gold"],
    "art-ring-256": ["specular"],
    "mark-gold-256": ["gold"],
    "lockup-horizontal-720": ["specular"],
}

MASK_SIZE = 256


def channels(path: Path) -> dict:
    im = Image.open(path).convert("RGBA")
    rgb = im.convert("RGB")
    alpha = im.getchannel("A").point(lambda x: 255 if x > 16 else 0)

    h, s, v = [np.array(ch) for ch in rgb.convert("HSV").split()]
    a = np.array(alpha)

    # Thresholds copied verbatim from the canonical generator. Staging only.
    out = {
        "alpha": a,
        "gold": ((h >= 12) & (h <= 45) & (s >= 55) & (v >= 85) & (a > 0)).astype("uint8") * 255,
        "specular": ((v >= 190) & (a > 0)).astype("uint8") * 255,
        "dark-metal": ((v < 150) & (a > 0)).astype("uint8") * 255,
    }

    gray = ImageOps.grayscale(rgb)
    edges = gray.filter(ImageFilter.FIND_EDGES).filter(ImageFilter.GaussianBlur(0.7))
    out["detail"] = ((np.array(edges) >= 32) & (a > 0)).astype("uint8") * 255

    # Semantic addition: hot emitting region. Reviewed against the streak crest.
    out["emissive"] = (((h <= 26) | (h >= 250)) & (s >= 110) & (v >= 140) & (a > 0)).astype("uint8") * 255

    return out


def write(arr, path: Path, size=None) -> None:
    """Masks must keep the base artwork's aspect ratio or they will not register."""
    path.parent.mkdir(parents=True, exist_ok=True)
    im = Image.fromarray(arr, "L")
    if size and max(im.size) > size:
        scale = size / max(im.size)
        im = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
    im.save(path, optimize=True)


if __name__ == "__main__":
    total = 0
    for path in sorted(ASSETS.glob("*.webp")):
        stem = path.stem
        derived = channels(path)

        for name, arr in derived.items():
            write(arr, STAGING / stem / f"{name}-mask.png")

        for name in RUNTIME_CHANNELS.get(stem, []):
            dest = RUNTIME / stem / f"{name}-mask.png"
            write(derived[name], dest, MASK_SIZE)
            total += dest.stat().st_size
            print(f"runtime  {dest.relative_to(ROOT)}  {dest.stat().st_size // 1024} KB")

    print(f"\nruntime mask payload: {total // 1024} KB")
    print("NOTE: detail-mask is an edge extraction, not a semantic crack mask.")
