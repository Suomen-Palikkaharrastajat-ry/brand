#!/usr/bin/env python3
"""
Compose a full logo by appending a subtitle text element to a brick SVG.

The canvas is widened with horizontal padding so the subtitle text has room.
The brick art is centred inside the wider canvas.

Usage:
    python3 compose_logo.py <input-brick.svg> <output-full.svg> [font_size] [bg_color]

bg_color is an optional hex color (e.g. #05131D) that fills the canvas background.
When set, subtitle text is rendered in white instead of dark.
"""

import base64
import os
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import colors

FONT_REL_PATH      = 'fonts/Outfit-VariableFont_wght.ttf'
SUBTITLE_FONT_SIZE = 18    # SVG units (nominal; SVG textLength stretches to full width)
GAP                = 24    # gap between bottom of brick art and text baseline
BOTTOM_PAD         = 20    # space below text baseline

ET.register_namespace('', 'http://www.w3.org/2000/svg')


def compose(input_svg: str, output_svg: str, font_size: int = SUBTITLE_FONT_SIZE, bg_color: str = None) -> None:
    tree = ET.parse(input_svg)
    root = tree.getroot()

    ns = 'http://www.w3.org/2000/svg'

    brick_w = float(root.get('width'))
    brick_h = float(root.get('height'))

    # Canvas matches brick art width; text is stretched to fill it via textLength
    canvas_w = brick_w
    canvas_h = brick_h + GAP + font_size + BOTTOM_PAD

    # Subtitle color: white when a background color is provided, otherwise look
    # up per-variant mapping in colors.py.
    if bg_color:
        subtitle_color = colors.SUBTITLE_ON_DARK
    else:
        stem = os.path.splitext(os.path.basename(input_svg))[0].removesuffix('-full')
        subtitle_color = colors.SUBTITLE_COLOR.get(stem, colors.SUBTITLE_ON_LIGHT)

    # Update root SVG canvas
    root.set('width',   str(int(canvas_w)))
    root.set('height',  str(int(canvas_h)))
    root.set('viewBox', f'0 0 {int(canvas_w)} {int(canvas_h)}')

    # Wrap existing brick content in a <g> (no horizontal shift needed)
    g = ET.Element(f'{{{ns}}}g')
    for child in list(root):
        root.remove(child)
        g.append(child)
    root.insert(0, g)

    # Embed font as base64 data URI so the SVG is self-contained and cairosvg
    # can always resolve it regardless of working directory or base URL.
    project_root = os.path.dirname(os.path.abspath(__file__))
    font_abs     = os.path.join(project_root, FONT_REL_PATH)
    with open(font_abs, 'rb') as _ff:
        font_b64 = base64.b64encode(_ff.read()).decode('ascii')
    font_data_uri = f'data:font/truetype;base64,{font_b64}'

    # Prepend <defs> with @font-face
    defs  = ET.Element(f'{{{ns}}}defs')
    style = ET.SubElement(defs, f'{{{ns}}}style')
    style.text = (
        "@font-face {"
        " font-family: 'Outfit';"
        f" src: url('{font_data_uri}') format('truetype');"
        " }"
    )
    root.insert(0, defs)

    # Optional background fill rect (for dark-theme variants)
    if bg_color:
        bg_rect = ET.Element(f'{{{ns}}}rect')
        bg_rect.set('x',      '0')
        bg_rect.set('y',      '0')
        bg_rect.set('width',  str(int(canvas_w)))
        bg_rect.set('height', str(int(canvas_h)))
        bg_rect.set('fill',   bg_color)
        root.insert(1, bg_rect)

    # Append subtitle <text> stretched to the full brick width
    text = ET.SubElement(root, f'{{{ns}}}text')
    text.set('x',              str(int(canvas_w // 2)))
    text.set('y',              str(brick_h + GAP + font_size))
    text.set('font-family',    'Outfit, sans-serif')
    text.set('font-size',      str(font_size))
    text.set('font-weight',    '400')
    text.set('text-anchor',    'middle')
    text.set('fill',           subtitle_color)
    text.text = colors.ASSOCIATION_NAME

    os.makedirs(os.path.dirname(os.path.abspath(output_svg)), exist_ok=True)
    tree.write(output_svg, encoding='unicode', xml_declaration=True)
    print(f'Composed {output_svg}  ({int(canvas_w)}×{int(canvas_h)})')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(f'Usage: {sys.argv[0]} <input-brick.svg> <output-full.svg> [font_size]')
        sys.exit(1)
    font_size = int(sys.argv[3]) if len(sys.argv) > 3 else SUBTITLE_FONT_SIZE
    bg_color  = sys.argv[4] if len(sys.argv) > 4 else None
    compose(sys.argv[1], sys.argv[2], font_size, bg_color)
