# Suomen Palikkaharrastajat ry — Brändiohjeistus

Brand assets and design guide for Suomen Palikkaharrastajat ry. The logo mark
is a LEGO minifig head rendered as brick art. A full Finnish-language design
guide is served at [logo.palikkaharrastajat.fi](https://logo.palikkaharrastajat.fi).

## Brand Colors

| Color | Hex |
|-------|-----|
| **LEGO Yellow** | `#F2CD37` |
| **LEGO Black** | `#05131D` |
| **LEGO White** | `#FFFFFF` |

## Quick start

```bash
devenv shell           # enter the Nix dev environment (GHC + Elm + Node.js)
make install           # npm install + elm-json install (once after checkout)
make dev               # full pipeline → copy assets → elm-pages dev server
```

## Makefile targets

| Target | What it does |
|--------|-------------|
| `make all` | **Build everything**: pipeline → assets → `npx elm-pages build` → `dist/` |
| `make dev-watch` | **Build all static assets, then watch**: pipeline → assets → `npx elm-pages dev` |
| `make run` | Haskell pipeline: generate `logo/`, `favicon/`, `brand.json`, `src/Brand/Generated.elm` |
| `make assets` | `make run` + copy `logo/`, `favicon/`, `fonts/`, `brand.json` into `public/` |
| `make site` | `make assets` + `npx elm-pages build` → `dist/` (production) |
| `make dev` | `make assets` + `npx elm-pages dev` (hot-reload dev server) |
| `make dev-watch` | `make assets` then elm-pages dev with hot reload |
| `make install` | `npm install` + `elm-json install --yes` |
| `make deploy` | `git push origin main` (triggers GitHub Actions) |
| `make build` | Compile Haskell only (no run) |
| `make test` | `cabal test` + `hlint src tests` |
| `make check` | `hlint src tests` only |
| `make watch` | Re-run pipeline on `.hs` changes (requires `entr`) |
| `make watch-elm` | elm-pages dev only (assumes assets already in `public/`) |
| `make clean` | Remove all generated files, `dist/`, `src/Brand/Generated.elm` |

## Build

### Haskell pipeline (asset generation)

The executable (`cabal run logo-gen` / `make run`) runs a sequential pipeline:

```
source.svg + Brand.Colors → Logo.Designs → design/ (19 SVG files)
design/*.svg → Logo.Blockify (rsvg-convert + JuicyPixels) → logo/*/svg/*.svg
logo/horizontal/svg/*.svg → Logo.Compose → *-full.svg, *-full-dark.svg
logo/**/*.svg → Logo.Raster (rsvg-convert + cwebp) → logo/**/*.{png,webp}
PNGs → Logo.Animate (gifski + img2webp) → *-animated.{gif,webp}
logo/square/svg/square.svg → Logo.Favicons → favicon/
Brand.Colors → Brand.Json → brand.json
Brand.Colors → Brand.ElmGen → src/Brand/Generated.elm
```

### elm-pages design-guide site

The site sources live in `app/` (routes), `src/` (Elm modules), and `public/`
(static assets). Tailwind CSS v4 is used for styling.

```bash
make dev               # pipeline → copy assets → elm-pages dev server (hot reload)
make site              # pipeline → copy assets → elm-pages build → dist/
make deploy            # push main (triggers GitHub Actions → GitHub Pages)
```

## Pipeline

```
source.svg
  └─ Logo.Designs ──────────────────── design/*.svg (19 variants)
       └─ Logo.Blockify ─────────────── logo/*/svg/*.svg (brick-art SVG)
            ├─ Logo.Compose ──────────── *-full.svg, *-full-dark.svg
            ├─ Logo.Raster ───────────── *.png, *.webp (800 px)
            └─ Logo.Animate ──────────── *-animated.gif, *-animated.webp
Logo.Favicons ────────────────────────── favicon/{ico,png,apple-touch-icon}
Brand.Json ───────────────────────────── brand.json
Brand.ElmGen ─────────────────────────── src/Brand/Generated.elm
```

## Source layout

| Path | Purpose |
|------|---------|
| `source.svg` | Master minifig head SVG |
| `src/Brand/Colors.hs` | Brand colors + constants (single source of truth) |
| `src/Brand/Json.hs` | Generates `brand.json` |
| `src/Brand/ElmGen.hs` | Generates `src/Brand/Generated.elm` |
| `src/Logo/Designs.hs` | SVG design variants |
| `src/Logo/Blockify.hs` | SVG → brick-art SVG |
| `src/Logo/Compose.hs` | Appends subtitle text |
| `src/Logo/Raster.hs` | SVG → PNG/WebP |
| `src/Logo/Animate.hs` | PNG frames → GIF/WebP |
| `src/Logo/Favicons.hs` | Favicon assets |
| `src/Main.hs` | Pipeline orchestration |
| `app/` | elm-pages route modules |
| `src/*.elm` | Reusable Elm modules |
| `public/` | Static assets for elm-pages |
| `scripts/` | Helper scripts (svg_rasterize.py, svg_to_png.py) |

## Requirements

Provided by `devenv.nix`:

- GHC 9.6 + cabal
- rsvg-convert (librsvg)
- cwebp, img2webp (libwebp)
- gifski
- icotool (icoutils)
- Node.js + npm
- elm, elm-format, elm-json, elm-review

## Fonts

Outfit variable font (SIL Open Font License 1.1) — `fonts/`.
