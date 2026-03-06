#!/usr/bin/env python3
"""
Create an animated GIF or WebP cycling through skin-tone square logo PNGs.

Usage:
    python3 animate_logo.py <frame1.png> [frame2.png ...] <output.gif|.webp> <frame_ms>
"""

import sys
from PIL import Image

*input_paths, output_path, frame_ms_str = sys.argv[1:]
frame_ms = int(frame_ms_str)

frames = [Image.open(p).convert('RGBA') for p in input_paths]

if output_path.endswith('.webp'):
    frames[0].save(
        output_path,
        format='WEBP',
        save_all=True,
        append_images=frames[1:],
        duration=frame_ms,
        loop=0,
    )
else:
    frames[0].save(
        output_path,
        format='GIF',
        save_all=True,
        append_images=frames[1:],
        duration=frame_ms,
        loop=0,
        disposal=2,
    )

print(f'Animated {output_path}  ({len(frames)} frames × {frame_ms}ms)')
