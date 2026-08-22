"""Generates the Android notification small icon (white location-pin silhouette).

Android tints the small icon and keeps only its alpha channel, so the artwork
must be pure white on transparency. Run from the repo root:

    python tool/gen_notification_icon.py
"""

import os

from PIL import Image, ImageDraw

# Android small-icon densities, in px, for a 24dp icon.
DENSITIES = {
    "drawable-mdpi": 24,
    "drawable-hdpi": 36,
    "drawable-xhdpi": 48,
    "drawable-xxhdpi": 72,
    "drawable-xxxhdpi": 96,
}

RES_DIR = os.path.join("android", "app", "src", "main", "res")
SS = 8  # supersample factor for antialiasing
WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)


def draw_pin(size: int) -> Image.Image:
    """A map pin drawn in a 24x24 design grid, scaled to `size`."""
    canvas = size * SS
    unit = canvas / 24.0
    img = Image.new("RGBA", (canvas, canvas), CLEAR)
    draw = ImageDraw.Draw(img)

    def px(*values):
        return [v * unit for v in values]

    head_cx, head_cy, head_r = 12.0, 9.5, 6.6
    draw.ellipse(
        px(head_cx - head_r, head_cy - head_r, head_cx + head_r, head_cy + head_r),
        fill=WHITE,
    )

    # Tail: a triangle from the circle's lower flanks down to the point.
    draw.polygon(
        [
            tuple(px(6.3, 13.4)),
            tuple(px(17.7, 13.4)),
            tuple(px(12.0, 21.6)),
        ],
        fill=WHITE,
    )

    hole_r = 2.6
    draw.ellipse(
        px(head_cx - hole_r, head_cy - hole_r, head_cx + hole_r, head_cy + hole_r),
        fill=CLEAR,
    )

    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    for folder, size in DENSITIES.items():
        out_dir = os.path.join(RES_DIR, folder)
        os.makedirs(out_dir, exist_ok=True)
        path = os.path.join(out_dir, "ic_notification.png")
        draw_pin(size).save(path)
        print(f"wrote {path} ({size}x{size})")


if __name__ == "__main__":
    main()
