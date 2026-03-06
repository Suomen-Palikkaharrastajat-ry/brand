#!/usr/bin/env python3
"""
Generate design SVGs for the logo build pipeline from source.svg + colors.py.

Writes:
  design/square.svg              – source.svg recolored with SKIN_TONES[0] (yellow)
  design/square-light-nougat.svg – source.svg recolored with SKIN_TONES[1]
  design/square-nougat.svg       – source.svg recolored with SKIN_TONES[2]
  design/square-dark-nougat.svg  – source.svg recolored with SKIN_TONES[3]
  design/horizontal.svg          – 4 heads side-by-side with SKIN_TONES (rotation 0)
  design/horizontal-rot1.svg    – same, rotated 1 step left
  design/horizontal-rot2.svg    – same, rotated 2 steps left
  design/horizontal-rot3.svg    – same, rotated 3 steps left
  design/minifig-colorful.svg    – single head with horizontal skin-tone bands
  design/minifig-rainbow.svg     – single head with horizontal pastel rainbow bands

Re-run whenever source.svg or colors.py changes:  python3 generate_designs.py
Or via make:                                     make designs
"""

import os
import re
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(__file__))
import colors

# Face fill color used in source.svg (Inkscape yellow — replaced with skin tones)
HEAD_SVG_FACE_COLOR = '#f8c70b'

# Horizontal layout: gap between heads expressed as brick units.
# gap in SVG units = _GAP_BRICKS * (head_w / _SQ_PX), giving exactly _GAP_BRICKS
# pixels after brick_blockify rasterization.  Keep HZ_PX = n*_SQ_PX + (n-1)*_GAP_BRICKS.
_SQ_PX = 14      # pixels per head (matches Makefile SQ_PX)
_GAP_BRICKS = 2  # gap bricks between heads (Makefile HZ_PX = 4*14 + 3*2 = 62)

ROOT = os.path.dirname(os.path.abspath(__file__))
HEAD_SVG_PATH = os.path.join(ROOT, 'source.svg')


# ── SVG helpers ─────────────────────────────────────────────────────────────────

def _svg_viewbox(svg_content):
    """Return (vb_x, vb_y, vb_w, vb_h) from the SVG viewBox attribute."""
    m = re.search(r'viewBox="([^"]+)"', svg_content)
    if not m:
        raise ValueError('No viewBox found in SVG')
    return tuple(map(float, m.group(1).split()))


def _svg_inner_content(svg_content):
    """Strip XML declaration and outer <svg> wrapper, returning just the inner elements."""
    content = re.sub(r'<\?xml[^?]*\?>\s*', '', svg_content)
    content = re.sub(r'<!--[^-]*-->\s*', '', content)          # strip comments
    content = re.sub(r'<svg\b[^>]*>\s*', '', content, count=1, flags=re.DOTALL)
    content = re.sub(r'\s*</svg>\s*$', '', content, flags=re.DOTALL)
    return content.strip()


def _recolor_head(svg_content, face_color):
    """Replace the face fill color in source.svg content with face_color."""
    return svg_content.replace(HEAD_SVG_FACE_COLOR, face_color.lower())


# ── Design generators ───────────────────────────────────────────────────────────

def square_svg(face_color):
    """Generate design/square.svg: source.svg recolored with face_color."""
    with open(HEAD_SVG_PATH) as f:
        content = f.read()
    return _recolor_head(content, face_color)


def horizontal_svg(skin_tones):
    """
    Generate horizontal SVG: len(skin_tones) heads side-by-side.

    Each head is a recolored copy of source.svg. A gap of _GAP_BRICKS bricks
    separates the heads so they align cleanly at HZ_PX pixel width.
    """
    with open(HEAD_SVG_PATH) as f:
        sq_content = f.read()

    _, _, vb_w, vb_h = _svg_viewbox(sq_content)
    inner = _svg_inner_content(sq_content)
    n = len(skin_tones)
    gap = _GAP_BRICKS * (vb_w / _SQ_PX)
    total_w = n * vb_w + (n - 1) * gap

    heads = ''
    for i, tone in enumerate(skin_tones):
        x = i * (vb_w + gap)
        colored = _recolor_head(inner, tone)
        heads += f'  <g transform="translate({x:.6f}, 0)">\n    {colored}\n  </g>\n'

    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg width="{total_w:.6f}" height="{vb_h:.6f}"'
        f' viewBox="0 0 {total_w:.6f} {vb_h:.6f}"\n'
        f'     xmlns="http://www.w3.org/2000/svg">\n'
        f'{heads}'
        '</svg>\n'
    )


def _minifig_banded_svg(band_colors):
    """
    Face divided into equal horizontal bands, one per color in band_colors.

    A clipPath from the face path clips the bands to the head shape.
    Dark features (eyes, smile) from source.svg are rendered on top.
    """
    ET.register_namespace('', 'http://www.w3.org/2000/svg')
    ns = 'http://www.w3.org/2000/svg'

    with open(HEAD_SVG_PATH) as f:
        sq_content = f.read()

    _, _, vb_w, vb_h = _svg_viewbox(sq_content)

    tree = ET.parse(HEAD_SVG_PATH)
    root = tree.getroot()

    face_path_elem = None
    for elem in root.iter(f'{{{ns}}}path'):
        if HEAD_SVG_FACE_COLOR in elem.get('style', ''):
            face_path_elem = elem
            break
    face_d = face_path_elem.get('d', '') if face_path_elem is not None else ''

    n = len(band_colors)
    band_h = vb_h / n
    bands = ''
    for i, color in enumerate(band_colors):
        y = i * band_h
        h = band_h if i < n - 1 else vb_h - i * band_h
        bands += f'    <rect x="0" y="{y:.4f}" width="{vb_w:.4f}" height="{h:.4f}" fill="{color}"/>\n'

    inner_parts = []
    for elem in root:
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        if tag == 'defs' or elem is face_path_elem:
            continue
        inner_parts.append(ET.tostring(elem, encoding='unicode'))
    features = '\n  '.join(inner_parts)

    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg width="{vb_w:.6f}" height="{vb_h:.6f}"'
        f' viewBox="0 0 {vb_w:.6f} {vb_h:.6f}"\n'
        f'     xmlns="http://www.w3.org/2000/svg">\n'
        f'  <defs>\n'
        f'    <clipPath id="face-clip"><path d="{face_d}"/></clipPath>\n'
        f'  </defs>\n'
        f'  <g clip-path="url(#face-clip)">\n'
        f'{bands}'
        f'  </g>\n'
        f'  {features}\n'
        '</svg>\n'
    )


def minifig_colorful_svg(skin_tones):
    """Colorful variant: source.svg face divided into horizontal skin-tone bands."""
    return _minifig_banded_svg(skin_tones)


def minifig_rainbow_svg(rainbow_colors):
    """Rainbow variant: source.svg face divided into horizontal rainbow bands."""
    return _minifig_banded_svg(rainbow_colors)


def main():
    design_dir = os.path.join(ROOT, 'design')
    os.makedirs(design_dir, exist_ok=True)

    tones = colors.SKIN_TONES
    designs = [
        ('square.svg',              square_svg(tones[0])),
        ('square-light-nougat.svg', square_svg(tones[1])),
        ('square-nougat.svg',       square_svg(tones[2])),
        ('square-dark-nougat.svg',  square_svg(tones[3])),
        ('horizontal.svg',          horizontal_svg(tones)),
        ('horizontal-rot1.svg',     horizontal_svg(tones[1:] + tones[:1])),
        ('horizontal-rot2.svg',     horizontal_svg(tones[2:] + tones[:2])),
        ('horizontal-rot3.svg',     horizontal_svg(tones[3:] + tones[:3])),
        ('minifig-colorful.svg',    minifig_colorful_svg(tones)),
        ('minifig-rainbow.svg',     minifig_rainbow_svg(colors.RAINBOW_COLORS)),
    ]

    # Horizontal rainbow: 7 frames, each a sliding window of 4 colors
    rb = colors.RAINBOW_COLORS
    n_rb = len(rb)
    for i in range(n_rb):
        window = [rb[(i + j) % n_rb] for j in range(4)]
        stem = 'horizontal-rainbow' if i == 0 else f'horizontal-rainbow-rot{i}'
        designs.append((f'{stem}.svg', horizontal_svg(window)))
    for name, content in designs:
        dst = os.path.join(design_dir, name)
        with open(dst, 'w') as fh:
            fh.write(content)
        print(f'Wrote {dst}')


if __name__ == '__main__':
    main()
