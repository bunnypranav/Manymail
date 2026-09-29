#!/usr/bin/env python3
"""Generate Manymail's launcher icons and Play Store graphics.

Everything here is drawn from code so the artwork can be regenerated at any
size without a design tool, and so the mark stays identical across the
launcher icon, the adaptive icon and the Play listing.

The mark: two sheets of paper peeking out from behind a single envelope --
many letters, one envelope, which is the app in one picture.

Outputs
  android/.../mipmap-*/ic_launcher.png            legacy launcher icon
  android/.../mipmap-*/ic_launcher_foreground.png adaptive foreground layer
  android/.../mipmap-anydpi-v26/ic_launcher.xml   adaptive icon definition
  android/.../values/ic_launcher_background.xml   adaptive background colour
  store/graphics/play-icon-512.png                Play listing icon
  store/graphics/feature-graphic-1024x500.png     Play feature graphic

Usage:  python tool/generate_icons.py
Requires Pillow:  pip install Pillow
"""
import pathlib
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Pillow is required:  pip install Pillow", file=sys.stderr)
    raise SystemExit(1)

ROOT = pathlib.Path(__file__).resolve().parent.parent
RES = ROOT / "android" / "app" / "src" / "main" / "res"
STORE = ROOT / "store" / "graphics"

# Brand palette. The indigo is the same value used for the docs pages.
TOP = (74, 108, 232)
BOTTOM = (40, 58, 156)
BACKGROUND_HEX = "#3A5BD9"

WHITE = (255, 255, 255)
SS = 4  # supersampling factor; everything is drawn big and downscaled


def gradient(size, top, bottom):
    """A vertical gradient, drawn one row at a time."""
    img = Image.new("RGB", (size, size), top)
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / max(size - 1, 1)
        draw.line(
            [(0, y), (size, y)],
            fill=tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)),
        )
    return img


def draw_mark(draw, size, scale=1.0, offset_y=0.0):
    """Draw the envelope mark centred on a canvas of `size` pixels.

    `scale` shrinks the mark within the canvas -- the adaptive foreground needs
    the art inside the 66/108 safe zone, so it passes a smaller value.
    """
    s = size
    cx = s / 2
    cy = s / 2 + offset_y * s

    def px(v):
        return v * s * scale

    # --- the two sheets peeking out behind the envelope ---------------------
    # Drawn first so the envelope overlaps them. Reduced alpha is not available
    # on an RGB canvas, so they are blended towards the background by hand via
    # lighter shades of white.
    for width, top, shade in (
        (0.44, -0.17, (168, 186, 244)),
        (0.58, -0.115, (214, 223, 250)),
    ):
        half = px(width) / 2
        draw.rounded_rectangle(
            [cx - half, cy + px(top), cx + half, cy + px(0.06)],
            radius=px(0.022),
            fill=shade,
        )

    # --- the envelope -------------------------------------------------------
    ex0, ex1 = cx - px(0.36), cx + px(0.36)
    ey0, ey1 = cy - px(0.06), cy + px(0.40)
    draw.rounded_rectangle([ex0, ey0, ex1, ey1], radius=px(0.045), fill=WHITE)

    # --- the flap -----------------------------------------------------------
    # A V knocked out of the envelope in the background colour. Inset from the
    # corners so the envelope keeps a visible white border at small sizes.
    inset = px(0.055)
    draw.line(
        [
            (ex0 + inset, ey0 + inset),
            (cx, ey0 + px(0.235)),
            (ex1 - inset, ey0 + inset),
        ],
        fill=BOTTOM,
        width=max(1, round(px(0.045))),
        joint="curve",
    )


def legacy_icon(size):
    """Full-bleed rounded square. Android masks it further per launcher."""
    big = size * SS
    img = gradient(big, TOP, BOTTOM)

    # Round the corners by compositing through a mask.
    mask = Image.new("L", (big, big), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, big - 1, big - 1], radius=round(big * 0.22), fill=255
    )
    out = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)

    draw_mark(ImageDraw.Draw(out), big, scale=0.88)
    return out.resize((size, size), Image.LANCZOS)


def adaptive_foreground(size):
    """Transparent layer for mipmap-anydpi-v26.

    The adaptive canvas is 108dp but only the central 66dp is guaranteed
    visible under every launcher mask, so the mark is scaled to sit well
    inside that circle.
    """
    big = size * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(img), big, scale=0.52)
    return img.resize((size, size), Image.LANCZOS)


def play_icon(size=512):
    """Play wants a full-bleed square; it applies its own rounding."""
    big = size * SS
    img = gradient(big, TOP, BOTTOM)
    draw_mark(ImageDraw.Draw(img), big, scale=0.80)
    return img.resize((size, size), Image.LANCZOS)


def load_font(names, size):
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def feature_graphic(width=1024, height=500):
    """The 1024x500 banner at the top of the Play listing.

    Play crops this on some surfaces, so the wordmark stays well inside the
    middle and nothing important touches an edge.
    """
    img = Image.new("RGB", (width, height), TOP)
    draw = ImageDraw.Draw(img)
    # Diagonal gradient reads better than vertical at this aspect ratio.
    for x in range(width):
        t = x / (width - 1)
        draw.line(
            [(x, 0), (x, height)],
            fill=tuple(round(TOP[i] + (BOTTOM[i] - TOP[i]) * t) for i in range(3)),
        )

    # The mark, drawn on its own square canvas then pasted.
    mark_size = 300
    big = mark_size * SS
    mark = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(mark), big, scale=0.92)
    mark = mark.resize((mark_size, mark_size), Image.LANCZOS)
    img.paste(mark, (112, (height - mark_size) // 2), mark)

    title_font = load_font(["segoeuib.ttf", "arialbd.ttf", "DejaVuSans-Bold.ttf"], 92)
    tag_font = load_font(["segoeui.ttf", "arial.ttf", "DejaVuSans.ttf"], 40)

    text_x = 112 + mark_size + 56
    draw.text((text_x, 186), "Manymail", font=title_font, fill=WHITE)
    draw.text((text_x, 292), "Many addresses, one app.",
              font=tag_font, fill=(206, 216, 250))
    return img


def main():
    # Legacy launcher icons, one per density bucket.
    densities = {
        "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192,
    }
    for bucket, size in densities.items():
        directory = RES / f"mipmap-{bucket}"
        directory.mkdir(parents=True, exist_ok=True)
        legacy_icon(size).save(directory / "ic_launcher.png")
        # Adaptive layers are 108dp on the same density scale.
        foreground = round(size * 108 / 48)
        adaptive_foreground(foreground).save(
            directory / "ic_launcher_foreground.png")
        print(f"  mipmap-{bucket:8} ic_launcher {size}px, "
              f"foreground {foreground}px")

    # Adaptive icon definition.
    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n",
        encoding="utf-8", newline="\n",
    )
    values = RES / "values"
    values.mkdir(parents=True, exist_ok=True)
    (values / "ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">{BACKGROUND_HEX}</color>\n'
        "</resources>\n",
        encoding="utf-8", newline="\n",
    )
    print("  mipmap-anydpi-v26/ic_launcher.xml + values/ic_launcher_background.xml")

    # Play Store graphics.
    STORE.mkdir(parents=True, exist_ok=True)
    play_icon().save(STORE / "play-icon-512.png")
    feature_graphic().save(STORE / "feature-graphic-1024x500.png")
    print(f"  store/graphics/play-icon-512.png")
    print(f"  store/graphics/feature-graphic-1024x500.png")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
