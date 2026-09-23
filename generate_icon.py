#!/usr/bin/env python3
"""
Generates the app icon for Secret Vault App.
Concept: dark rounded-rect background, a film clapperboard/play icon
         overlaid with a subtle vault dial — all in the app's red & dark palette.
"""

import os
import math
from PIL import Image, ImageDraw

# ── Brand colours ──────────────────────────────────────────────────────────────
BG_DARK   = (18,  18,  18,  255)   # #121212
SURFACE   = (30,  30,  30,  255)   # #1E1E1E
RED       = (229,  9,  20,  255)   # #E50914
RED_DARK  = (178,  7,  16,  255)   # #B20710
WHITE     = (255, 255, 255, 255)
GREY_L    = (224, 224, 224, 255)
GREY_M    = (176, 176, 176, 255)


def draw_icon(size: int) -> Image.Image:
    S = size
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # ── 1. Rounded-rect background ─────────────────────────────────────────────
    r_corner = S * 0.22          # corner radius ≈ 22 % of size
    d.rounded_rectangle([0, 0, S-1, S-1], radius=r_corner, fill=BG_DARK)

    # ── 2. Gradient-style inner glow (two concentric rounded rects) ────────────
    pad = S * 0.04
    d.rounded_rectangle(
        [pad, pad, S-1-pad, S-1-pad],
        radius=r_corner * 0.85,
        fill=SURFACE,
    )

    # ── 3. Film strip top & bottom bars ───────────────────────────────────────
    bar_h   = S * 0.12
    hole_w  = S * 0.055
    hole_h  = bar_h * 0.55
    hole_r  = hole_h * 0.3
    n_holes = 4
    bar_pad = (S - n_holes * hole_w * 2.5) / (n_holes + 1)

    for top in [S * 0.04, S * 0.84]:
        d.rectangle([S*0.04, top, S*0.96, top + bar_h], fill=RED_DARK)
        x_pos = bar_pad
        for _ in range(n_holes):
            hx = x_pos
            hy = top + (bar_h - hole_h) / 2
            d.rounded_rectangle(
                [hx, hy, hx + hole_w, hy + hole_h],
                radius=hole_r,
                fill=BG_DARK,
            )
            x_pos += hole_w + bar_pad

    # ── 4. Centre area background (slightly lighter card) ─────────────────────
    cy1 = S * 0.18
    cy2 = S * 0.82
    d.rectangle([S*0.04, cy1, S*0.96, cy2], fill=(22, 22, 22, 255))

    # ── 5. Play triangle (bold, centred) ──────────────────────────────────────
    cx, cy = S * 0.52, S * 0.50    # slightly right of centre (visual balance)
    tri_r  = S * 0.22              # radius of bounding circle
    # equilateral-ish triangle pointing right
    pts = [
        (cx - tri_r * 0.55, cy - tri_r * 0.90),
        (cx - tri_r * 0.55, cy + tri_r * 0.90),
        (cx + tri_r * 1.0,  cy),
    ]
    # Shadow / depth
    offset = S * 0.018
    shadow_pts = [(x + offset, y + offset) for x, y in pts]
    d.polygon(shadow_pts, fill=RED_DARK)
    d.polygon(pts, fill=RED)

    # ── 6. Vault / lock ring around play button ────────────────────────────────
    ring_r_outer = S * 0.36
    ring_r_inner = S * 0.29
    ring_cx      = S * 0.50
    ring_cy      = S * 0.50
    ring_bbox_o  = [ring_cx - ring_r_outer, ring_cy - ring_r_outer,
                    ring_cx + ring_r_outer, ring_cy + ring_r_outer]
    ring_bbox_i  = [ring_cx - ring_r_inner, ring_cy - ring_r_inner,
                    ring_cx + ring_r_inner, ring_cy + ring_r_inner]

    ring_width = S * 0.025
    d.ellipse(ring_bbox_o, outline=GREY_M, width=int(ring_width))

    # Tick marks on the ring (like a vault dial) — 8 ticks
    n_ticks = 8
    for i in range(n_ticks):
        angle = math.radians(i * 360 / n_ticks - 90)
        is_major = (i % 2 == 0)
        tick_in  = ring_r_outer - (S * 0.055 if is_major else S * 0.03)
        tick_out = ring_r_outer
        x1 = ring_cx + math.cos(angle) * tick_in
        y1 = ring_cy + math.sin(angle) * tick_in
        x2 = ring_cx + math.cos(angle) * tick_out
        y2 = ring_cy + math.sin(angle) * tick_out
        tick_col = WHITE if is_major else GREY_M
        d.line([(x1, y1), (x2, y2)],
               fill=tick_col, width=max(1, int(S * 0.018 if is_major else S * 0.010)))

    # ── 7. Small "keyhole" dot below play button ───────────────────────────────
    kh_r = S * 0.028
    kh_cx = S * 0.50
    kh_cy = S * 0.73
    d.ellipse([kh_cx - kh_r, kh_cy - kh_r, kh_cx + kh_r, kh_cy + kh_r], fill=GREY_M)

    return img


# ── Size tables ────────────────────────────────────────────────────────────────
BASE = "/Users/somchaisik/Desktop/workspace/personal/special"

ANDROID_SIZES = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}

IOS_SIZES = [
    ("Icon-App-20x20@1x.png",      20),
    ("Icon-App-20x20@2x.png",      40),
    ("Icon-App-20x20@3x.png",      60),
    ("Icon-App-29x29@1x.png",      29),
    ("Icon-App-29x29@2x.png",      58),
    ("Icon-App-29x29@3x.png",      87),
    ("Icon-App-40x40@1x.png",      40),
    ("Icon-App-40x40@2x.png",      80),
    ("Icon-App-40x40@3x.png",     120),
    ("Icon-App-60x60@2x.png",     120),
    ("Icon-App-60x60@3x.png",     180),
    ("Icon-App-76x76@1x.png",      76),
    ("Icon-App-76x76@2x.png",     152),
    ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]


def main():
    # Master at 1024 px
    master = draw_icon(1024)

    # Android
    for folder, px in ANDROID_SIZES.items():
        path = os.path.join(BASE, "android", "app", "src", "main", "res", folder, "ic_launcher.png")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = master.resize((px, px), Image.LANCZOS).convert("RGBA")
        # Convert to RGB for Android (no transparency in launcher icons)
        bg = Image.new("RGB", (px, px), (18, 18, 18))
        bg.paste(resized, mask=resized.split()[3])
        bg.save(path, "PNG")
        print(f"  Android {folder}: {px}x{px} → {path}")

    # iOS
    ios_dir = os.path.join(BASE, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    os.makedirs(ios_dir, exist_ok=True)
    for fname, px in IOS_SIZES:
        path = os.path.join(ios_dir, fname)
        resized = master.resize((px, px), Image.LANCZOS).convert("RGBA")
        bg = Image.new("RGB", (px, px), (18, 18, 18))
        bg.paste(resized, mask=resized.split()[3])
        bg.save(path, "PNG")
        print(f"  iOS {fname}: {px}x{px}")

    # Also save a full 1024 master as asset
    master_path = os.path.join(BASE, "assets", "images", "app_icon_master.png")
    os.makedirs(os.path.dirname(master_path), exist_ok=True)
    master_rgb = Image.new("RGB", (1024, 1024), (18, 18, 18))
    master_rgb.paste(master, mask=master.split()[3])
    master_rgb.save(master_path, "PNG")
    print(f"\n  Master: {master_path}")
    print("\nAll icons generated successfully!")


if __name__ == "__main__":
    main()
