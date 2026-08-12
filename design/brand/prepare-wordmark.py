"""Re-key the horizontal wordmark off its solid black plate.

The wordmark master is rendered on an opaque black background. To composite on
any surface it needs an alpha channel, derived from luminance.

The donor branch keyed it with a low floor, which left ~56% of the frame holding
alpha 1-60. That haze is invisible on a near-black surface but reads as a grey
rectangle on a raised card, which is where the install prompt puts it. This
raises the floor so the plate goes fully transparent while the lit metal of the
letterforms is preserved.

Run against the brand master. Writes a derivative; never edits the source.

    python3 design/brand/prepare-wordmark.py <master.png>
"""

from PIL import Image
from pathlib import Path
import numpy as np
import sys

OUT = Path(__file__).resolve().parents[2] / "assets" / "lockup-horizontal-720.webp"

FLOOR = 16.0   # luminance at or below this is plate, not artwork
GAIN = 5.5     # how fast alpha ramps once past the floor
WIDTH = 720


def key(path: Path) -> Image.Image:
    a = np.array(Image.open(path).convert("RGBA")).astype(np.float32)
    lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
    alpha = np.clip((lum - FLOOR) * GAIN, 0, 255)
    im = Image.fromarray(np.dstack([a[..., :3], alpha]).astype(np.uint8), "RGBA")

    ys, xs = np.nonzero(np.array(im)[..., 3] > 8)
    im = im.crop((xs.min() - 10, ys.min() - 10, xs.max() + 10, ys.max() + 10))
    return im.resize((WIDTH, round(WIDTH * im.height / im.width)), Image.LANCZOS)


if __name__ == "__main__":
    out = key(Path(sys.argv[1]))
    out.save(OUT, "WEBP", quality=88, method=6)

    al = np.array(out)[..., 3].astype(int)
    haze = float(((al > 0) & (al < 60)).mean())
    print(f"wrote {OUT.name}  {OUT.stat().st_size // 1024} KB  {out.size}")
    print(f"residual low-alpha haze: {haze:.1%} (donor build was 55.7%)")
