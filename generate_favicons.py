#!/usr/bin/env python3
"""
Generate favicons from the square logo SVGs.

Writes to favicon/:
  favicon.ico           – multi-size ICO (16, 32, 48 px) from yellow square
  favicon-16.png        – 16×16 PNG
  favicon-32.png        – 32×32 PNG
  favicon-48.png        – 48×48 PNG
  apple-touch-icon.png  – 180×180 PNG for iOS home screen
  icon-192.png          – 192×192 PNG for PWA manifest
  icon-512.png          – 512×512 PNG for PWA manifest

Usage:
    python3 generate_favicons.py
Or via make:
    make favicons
"""

import io
import os
import sys
import tempfile

# Register fontconfig before cairosvg import (same pattern as export_raster.py)
_fonts_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fonts')
if os.path.isdir(_fonts_dir):
    _fc_conf = (
        '<?xml version="1.0"?>\n'
        '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n'
        '<fontconfig>\n'
        f'  <dir>{_fonts_dir}</dir>\n'
        '  <include ignore_missing="yes">/etc/fonts/fonts.conf</include>\n'
        '</fontconfig>\n'
    )
    _fc_tmp = tempfile.NamedTemporaryFile(
        suffix='.conf', mode='w', delete=False, prefix='fc_logo_'
    )
    _fc_tmp.write(_fc_conf)
    _fc_tmp.close()
    os.environ['FONTCONFIG_FILE'] = _fc_tmp.name

import cairosvg
from PIL import Image

ROOT      = os.path.dirname(os.path.abspath(__file__))
SRC_SVG   = os.path.join(ROOT, 'logo', 'square', 'svg', 'square.svg')
OUT_DIR   = os.path.join(ROOT, 'favicon')

ICO_SIZES       = [16, 32, 48]
PNG_SIZES       = [16, 32, 48, 180, 192, 512]
PNG_NAMES       = {
    16:  'favicon-16.png',
    32:  'favicon-32.png',
    48:  'favicon-48.png',
    180: 'apple-touch-icon.png',
    192: 'icon-192.png',
    512: 'icon-512.png',
}


def svg_to_png_image(svg_path: str, size: int) -> Image.Image:
    abs_path = os.path.abspath(svg_path)
    with open(abs_path, 'rb') as f:
        svg_bytes = f.read()
    png_bytes = cairosvg.svg2png(
        bytestring=svg_bytes,
        url='file://' + abs_path,
        output_width=size,
        output_height=size,
    )
    return Image.open(io.BytesIO(png_bytes)).convert('RGBA')


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    # Render all needed sizes
    images = {size: svg_to_png_image(SRC_SVG, size) for size in PNG_SIZES}

    # Write individual PNGs
    for size, name in PNG_NAMES.items():
        dst = os.path.join(OUT_DIR, name)
        images[size].save(dst, 'PNG')
        print(f'Wrote {dst}  ({size}×{size})')

    # Write multi-size ICO
    ico_images = [images[s] for s in ICO_SIZES]
    ico_path = os.path.join(OUT_DIR, 'favicon.ico')
    ico_images[0].save(
        ico_path,
        format='ICO',
        sizes=[(s, s) for s in ICO_SIZES],
        append_images=ico_images[1:],
    )
    print(f'Wrote {ico_path}  ({", ".join(str(s) for s in ICO_SIZES)} px)')


if __name__ == '__main__':
    main()
