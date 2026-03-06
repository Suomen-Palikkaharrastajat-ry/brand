# TODO

Checklist of improvements for the Suomen Palikkaharrastajat ry logo project.

---

## Stale Files — Delete

- [x] Delete `brick_blockify_full.py` — old script that split "SPY" text from subtitle for the previous letter-brick logo; no longer referenced anywhere
- [x] Delete `update_logos.py` — old generator for the SPY letter-brick SVGs; fully superseded by `generate_designs.py` + `brick_blockify.py` pipeline
- [x] Delete `generate_all_brick_variants.sh` — old nix-shell batch script; fully superseded by the Makefile
- [x] Remove root-level `horizontal.png` and `square.png` — leftover manual test previews; not part of the build

---

## Documentation — Update

- [x] Rewrite `README.md` — currently documents the old SPY multicolor scheme (aqua/purple/blue palette, spy-* filenames, outlined/ subdirectories); replace with the current minifig-head system and build instructions
- [x] Rewrite or delete `BRICK_README.md` — describes the old pipeline (nix-shell, `brick/` subdirectories, outlined/ paths, `spy-*` filenames, `make brick`, `make test-brick-*`); none of this reflects the current build
- [x] Fix or delete `_config.yml` — the `.nojekyll` file disables Jekyll entirely on GitHub Pages, so this config is dead; it also references non-existent files (`colors.txt`, `LOGO-SUMMARY.md`, `logo/README.md`, `logo/horizontal/svg/README.md`) and has the wrong site title ("SPY Brand Guide")
- [x] Fix `index.html` — the "Katso GitHubissa" link points to `https://github.com/datakurre/spy-brand` (old repo); update to the actual repository URL
- [x] Fix `index.html` footer — still reads "SPY Brändiopas"; remove the "SPY" prefix or replace with the association name
- [x] Fix `colors.py` docstring — says "All colors are valid LEGO® colors from the Rebrickable palette (colors.csv)" but the values are hardcoded; `colors.csv` is never read by the code

---

## `.gitignore` — Fix

- [x] Add `__pycache__/` and `*.pyc` — Python cache directory is currently present in the working tree but untracked
- [x] Add root-level test previews — `horizontal.png` and `square.png` (or a pattern like `/horizontal.png` and `/square.png`) so they are not accidentally committed
- [x] Consider whether `colors.csv` belongs in `.gitignore` or in the repository — it is a large reference file that is not read by any script; if kept, note its purpose in the README

---

## Build Artifacts — Commit

- [x] Generate and commit `design/minifig-yellow.svg` — `minifig-black.svg` and `minifig-white.svg` exist but the yellow variant is missing from `design/`; run `make designs` and commit the result
- [x] Stage and commit all new `logo/` output files — current untracked files include all `minifig-*` SVG, PNG and WebP outputs; since build artifacts are intentionally committed, these need to be added
- [x] Stage and commit deletion of old `spy-*` logo files — the old files are staged for deletion but not yet committed; complete the transition

---

## Code Quality — `Makefile`

- [x] Deduplicate PNG/WebP conversion rules — the square and horizontal targets contain identical inline Python one-liners for `cairosvg.svg2png` and PIL WebP conversion; extract into a small helper script (e.g. `export_raster.py input.svg output width`) to keep the Makefile DRY
- [x] Add `design/` to the `clean` target — currently `make clean` removes `logo/` outputs but leaves the generated `design/*.svg` files behind
- [x] Add `__pycache__` cleanup to the `clean` target

---

## Code Quality — `brick_blockify.py`

- [x] Remove the unused `opacity` parameter from `create_brick_side_view` — the parameter is accepted but explicitly ignored by a comment ("Use ONLY original color — absolutely NO opacity variations"); callers never pass a non-default value
- [x] Remove the unused `show_studs` parameter from `create_brick_side_view` — always `True` in `image_to_brick_svg`; the conditional branch for `show_studs=False` is dead code
- [x] Deduplicate stud-height calculation — `stud_height` / `body_height` / `inner_stud_height` / `inner_body_height` are computed twice in `image_to_brick_svg` (once for SVG sizing, once for drawing); hoist to a single calculation
- [ ] Document or remove the non-`auto` fixed brick-type code paths — the `1x1` and `2x2` branches in `image_to_brick_svg` were never updated to support 3x3/4x4 sizing that `auto` mode uses; either note the limitation or remove the dead branches since `auto` is the only mode the Makefile uses

---

## Code Quality — `compose_logo.py`

- [x] Replace filename-sniffing for subtitle color — `if 'white' in fname` is fragile; a `minifig-white` logo needs light-bg text but so would any future dark-background variant that doesn't have "white" in its name; pass the color explicitly via `colors.py` (e.g. a dict mapping variant name → subtitle color)

---

## Code Quality — `generate_designs.py`

- [x] Use `__file__`-relative output path — `os.makedirs('design', exist_ok=True)` and `os.path.join('design', filename)` depend on the current working directory being the project root; use `os.path.join(os.path.dirname(__file__), 'design')` for robustness

---

## GitHub Pages Workflow

- [x] Exclude source files from the Pages artifact — `.github/workflows/static.yml` uploads the entire repository (`path: '.'`), which means Python scripts, Makefile, devenv files, etc. are served as public files; consider uploading only `index.html`, `fonts/`, and `logo/` directories

---

## Devcontainer

- [x] Commit `.devcontainer.json` — the file exists and is untracked; if it's useful for Codespaces / VS Code devcontainer setup it should be committed (or added to `.gitignore` if it's personal only)
