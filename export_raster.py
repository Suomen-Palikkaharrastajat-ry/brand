#!/usr/bin/env python3
"""
Export an SVG to PNG and WebP at a given output width.

Usage:
    python3 export_raster.py <input.svg> <output.png|.webp> <width>
"""
import io
import os
import sys
import tempfile

# Register the project fonts directory with fontconfig BEFORE importing
# cairosvg/cairo/pango, so fonts like Outfit are resolvable by the font
# renderer.  cairosvg renders text via Pango which uses fontconfig; @font-face
# CSS inside the SVG is not enough — the font must be in fontconfig's search
# path.
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

input_svg, output_path, width = sys.argv[1], sys.argv[2], int(sys.argv[3])

# Read SVG content explicitly so cairosvg never does its own file-URL fetch
# (which is unreliable with relative paths in some environments).
# Pass the absolute file:// URL as the base URL so relative references inside
# the SVG (e.g. @font-face src) are still resolved correctly.
abs_path = os.path.abspath(input_svg)
with open(abs_path, 'rb') as _f:
    _svg_bytes = _f.read()
png_bytes = cairosvg.svg2png(
    bytestring=_svg_bytes,
    url='file://' + abs_path,
    output_width=width,
)

if output_path.endswith('.webp'):
    img = Image.open(io.BytesIO(png_bytes))
    img.save(output_path, 'WEBP', quality=95)
else:
    with open(output_path, 'wb') as f:
        f.write(png_bytes)
