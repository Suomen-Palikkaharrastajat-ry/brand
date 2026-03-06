#!/usr/bin/env python3
"""
Generate brand.json — machine-readable brand manifest for Suomen Palikkaharrastajat ry.

Covers: organization, colors, typography, logos, favicons.
Re-run whenever colors.py, Makefile, or the asset set changes:
  python3 generate_brand_json.py
Or via make:
  make brand
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import colors

BASE_URL = "https://logo.suomenpalikkayhteiso.fi"


def _asset(path):
    """Return both the relative file path and its absolute URL."""
    return {"file": path, "url": f"{BASE_URL}/{path}"}


def build_manifest():
    tones = colors.SKIN_TONES
    tone_meta = [
        {"hex": tones[0], "id": "yellow",       "name": "Yellow",       "description": "Classic minifig"},
        {"hex": tones[1], "id": "light-nougat",  "name": "Light Nougat", "description": "Light skin"},
        {"hex": tones[2], "id": "nougat",        "name": "Nougat",       "description": "Medium skin"},
        {"hex": tones[3], "id": "dark-nougat",   "name": "Dark Nougat",  "description": "Dark skin"},
    ]
    rainbow_meta = [
        {"hex": colors.RAINBOW_COLORS[0], "name": "Salmon",             "description": "Red"},
        {"hex": colors.RAINBOW_COLORS[1], "name": "Light Orange",       "description": "Orange"},
        {"hex": colors.RAINBOW_COLORS[2], "name": "Yellow",             "description": "Yellow"},
        {"hex": colors.RAINBOW_COLORS[3], "name": "Medium Green",       "description": "Green"},
        {"hex": colors.RAINBOW_COLORS[4], "name": "Bright Light Blue",  "description": "Blue"},
        {"hex": colors.RAINBOW_COLORS[5], "name": "Light Lilac",        "description": "Indigo"},
        {"hex": colors.RAINBOW_COLORS[6], "name": "Medium Lavender",    "description": "Violet"},
    ]

    def sq_variant(stem, skin_tone_id, description, extra=None):
        v = {
            "id": stem,
            "description": description,
            "skinTone": skin_tone_id,
            "animated": False,
            "theme": "light",
            "svg":  _asset(f"logo/square/svg/{stem}.svg"),
            "png":  _asset(f"logo/square/png/{stem}.png"),
            "webp": _asset(f"logo/square/png/{stem}.webp"),
        }
        if extra:
            v.update(extra)
        return v

    def hz_variant(stem, description, theme="light", with_text=False, animated=False):
        v = {
            "id": stem,
            "description": description,
            "withText": with_text,
            "animated": animated,
            "theme": theme,
        }
        if animated:
            v["gif"]  = _asset(f"logo/horizontal/png/{stem}.gif")
            v["webp"] = _asset(f"logo/horizontal/png/{stem}.webp")
        else:
            v["svg"]  = _asset(f"logo/horizontal/svg/{stem}.svg")
            v["png"]  = _asset(f"logo/horizontal/png/{stem}.png")
            v["webp"] = _asset(f"logo/horizontal/png/{stem}.webp")
        return v

    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "organization": {
            "name": colors.ASSOCIATION_NAME,
        },

        # ── Colors ────────────────────────────────────────────────────────────
        "colors": {
            "brand": [
                {
                    "hex": "#05131D",
                    "id": "lego-black",
                    "name": "LEGO Black",
                    "usage": ["features", "text", "dark background"],
                },
                {
                    "hex": "#FFFFFF",
                    "id": "lego-white",
                    "name": "LEGO White",
                    "usage": ["eye highlights", "text on dark background"],
                },
            ],
            "skinTones": tone_meta,
            "rainbow": rainbow_meta,
            "text": {
                "onLight": colors.SUBTITLE_ON_LIGHT,
                "onDark":  colors.SUBTITLE_ON_DARK,
            },
            "darkBackground": colors.DARK_BG,
        },

        # ── Typography ────────────────────────────────────────────────────────
        "typography": {
            "primaryFont": {
                "family": "Outfit",
                "style": "variable",
                "axes": [{"tag": "wght", "min": 100, "max": 900}],
                "files": {
                    "variableTTF": _asset("fonts/Outfit-VariableFont_wght.ttf"),
                },
                "license": "OFL-1.1",
                "licenseFile": _asset("fonts/OFL.txt"),
            },
        },

        # ── Logos ─────────────────────────────────────────────────────────────
        "logos": {
            "primaryLogo": "square/square",
            "square": {
                "description": "Square minifig-head logo mark",
                "aspectRatio": "1:1",
                "variants": [
                    sq_variant("square",            "yellow",       "Yellow, classic minifig"),
                    sq_variant("square-light-nougat","light-nougat", "Light Nougat skin tone"),
                    sq_variant("square-nougat",     "nougat",       "Nougat skin tone"),
                    sq_variant("square-dark-nougat","dark-nougat",  "Dark Nougat skin tone"),
                    {
                        "id": "square-animated",
                        "description": "Animated logo cycling through all four skin tones",
                        "animated": True,
                        "frameDurationMs": 10000,
                        "frames": [t["id"] for t in tone_meta],
                        "gif":  _asset("logo/square/png/square-animated.gif"),
                        "webp": _asset("logo/square/png/square-animated.webp"),
                    },
                    {
                        "id": "minifig-colorful",
                        "description": "Minifig head with face divided into horizontal skin-tone bands",
                        "animated": False,
                        "theme": "light",
                        "svg":  _asset("logo/square/svg/minifig-colorful.svg"),
                        "png":  _asset("logo/square/png/minifig-colorful.png"),
                        "webp": _asset("logo/square/png/minifig-colorful.webp"),
                    },
                    {
                        "id": "minifig-rainbow",
                        "description": "Minifig head with face divided into horizontal rainbow bands",
                        "animated": False,
                        "theme": "light",
                        "svg":  _asset("logo/square/svg/minifig-rainbow.svg"),
                        "png":  _asset("logo/square/png/minifig-rainbow.png"),
                        "webp": _asset("logo/square/png/minifig-rainbow.webp"),
                    },
                ],
            },
            "horizontal": {
                "description": "Horizontal logo mark (four heads side-by-side)",
                "aspectRatio": "approx 4.4:1",
                "variants": [
                    hz_variant("horizontal",      "Logo mark only, light theme"),
                    hz_variant("horizontal-full", "Logo mark with association name subtitle, light theme", with_text=True),
                    hz_variant("horizontal-full-dark", "Logo mark with subtitle, dark theme", theme="dark", with_text=True),
                    {
                        "id": "horizontal-animated",
                        "description": "Animated logo mark cycling skin-tone order",
                        "withText": False,
                        "animated": True,
                        "theme": "light",
                        "frameDurationMs": 10000,
                        "gif":  _asset("logo/horizontal/png/horizontal-animated.gif"),
                        "webp": _asset("logo/horizontal/png/horizontal-animated.webp"),
                    },
                    {
                        "id": "horizontal-full-animated",
                        "description": "Animated logo with subtitle cycling skin-tone order, light theme",
                        "withText": True,
                        "animated": True,
                        "theme": "light",
                        "frameDurationMs": 10000,
                        "gif":  _asset("logo/horizontal/png/horizontal-full-animated.gif"),
                        "webp": _asset("logo/horizontal/png/horizontal-full-animated.webp"),
                    },
                    {
                        "id": "horizontal-full-dark-animated",
                        "description": "Animated logo with subtitle cycling skin-tone order, dark theme",
                        "withText": True,
                        "animated": True,
                        "theme": "dark",
                        "frameDurationMs": 10000,
                        "gif":  _asset("logo/horizontal/png/horizontal-full-dark-animated.gif"),
                        "webp": _asset("logo/horizontal/png/horizontal-full-dark-animated.webp"),
                    },
                    hz_variant("horizontal-rainbow", "Rainbow logo mark, sliding window of 4 colors"),
                    {
                        "id": "horizontal-rainbow-animated",
                        "description": "Animated rainbow logo mark cycling all 7 colors one step at a time",
                        "withText": False,
                        "animated": True,
                        "theme": "light",
                        "frameCount": 7,
                        "frameDurationMs": 10000,
                        "colors": [c["hex"] for c in rainbow_meta],
                        "gif":  _asset("logo/horizontal/png/horizontal-rainbow-animated.gif"),
                        "webp": _asset("logo/horizontal/png/horizontal-rainbow-animated.webp"),
                    },
                ],
            },
        },

        # ── Favicons ──────────────────────────────────────────────────────────
        "favicons": {
            "ico": _asset("favicon/favicon.ico"),
            "png": [
                {**_asset(f"favicon/favicon-{s}.png"), "size": s}
                for s in [16, 32, 48]
            ],
            "appleTouchIcon": {**_asset("favicon/apple-touch-icon.png"), "size": 180},
            "webAppIcons": [
                {**_asset(f"favicon/icon-{s}.png"), "size": s}
                for s in [192, 512]
            ],
        },
    }


def main():
    root = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(root, "brand.json")
    manifest = build_manifest()
    with open(out, "w") as fh:
        json.dump(manifest, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
