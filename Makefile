PYTHON = python3

# ── Brick parameters ────────────────────────────────────────────────────────────
SQ_PX  = 14  # raster pixel width for square logo   (lower = blockier)
HZ_PX  = 62   # raster pixel width for horizontal logo (4×14 heads + 3×2 gap bricks)
BLK_W  = 24   # SVG width of a 2×2 brick (1×1 = half)
BLK_H  = 20   # SVG height of all bricks
PAD    = 1    # transparent stud columns added on each side of brick output
TXT_SIZE = 57  # subtitle font size in SVG units (text is stretched to full logo width)
ANIM_MS  = 10000  # milliseconds per frame in animated logo
DARK_BG  = \#05131D  # dark background color for dark-theme variants

# ── Directories ─────────────────────────────────────────────────────────────────
DESIGN_DIR  = design
SQ_DIR      = logo/square/svg
HZ_DIR      = logo/horizontal/svg
SQ_PNG      = logo/square/png
HZ_PNG      = logo/horizontal/png
FAVICON_DIR = favicon

# ── Design sources (populated by `make designs`) ────────────────────────────────
DESIGN_SQ       = $(DESIGN_DIR)/square.svg
DESIGN_SQ_LN    = $(DESIGN_DIR)/square-light-nougat.svg
DESIGN_SQ_N     = $(DESIGN_DIR)/square-nougat.svg
DESIGN_SQ_DN    = $(DESIGN_DIR)/square-dark-nougat.svg
DESIGN_HZ       = $(DESIGN_DIR)/horizontal.svg
DESIGN_HZ_R1    = $(DESIGN_DIR)/horizontal-rot1.svg
DESIGN_HZ_R2    = $(DESIGN_DIR)/horizontal-rot2.svg
DESIGN_HZ_R3    = $(DESIGN_DIR)/horizontal-rot3.svg
DESIGN_COLORFUL = $(DESIGN_DIR)/minifig-colorful.svg
DESIGN_RAINBOW  = $(DESIGN_DIR)/minifig-rainbow.svg

# ── Generated brick SVGs ────────────────────────────────────────────────────────
SQ_SVG       = $(SQ_DIR)/square.svg
SQ_LN_SVG    = $(SQ_DIR)/square-light-nougat.svg
SQ_N_SVG     = $(SQ_DIR)/square-nougat.svg
SQ_DN_SVG    = $(SQ_DIR)/square-dark-nougat.svg
HZ_SVG          = $(HZ_DIR)/horizontal.svg
HZ_R1_SVG       = $(HZ_DIR)/horizontal-rot1.svg
HZ_R2_SVG       = $(HZ_DIR)/horizontal-rot2.svg
HZ_R3_SVG       = $(HZ_DIR)/horizontal-rot3.svg
HZ_FULL_SVG         = $(HZ_DIR)/horizontal-full.svg
HZ_FULL_R1_SVG      = $(HZ_DIR)/horizontal-full-rot1.svg
HZ_FULL_R2_SVG      = $(HZ_DIR)/horizontal-full-rot2.svg
HZ_FULL_R3_SVG      = $(HZ_DIR)/horizontal-full-rot3.svg
HZ_FULL_DARK_SVG    = $(HZ_DIR)/horizontal-full-dark.svg
HZ_FULL_DARK_R1_SVG = $(HZ_DIR)/horizontal-full-dark-rot1.svg
HZ_FULL_DARK_R2_SVG = $(HZ_DIR)/horizontal-full-dark-rot2.svg
HZ_FULL_DARK_R3_SVG = $(HZ_DIR)/horizontal-full-dark-rot3.svg
COLORFUL_SVG = $(SQ_DIR)/minifig-colorful.svg
RAINBOW_SVG  = $(SQ_DIR)/minifig-rainbow.svg

ALL_SVGS = $(SQ_SVG) $(SQ_LN_SVG) $(SQ_N_SVG) $(SQ_DN_SVG) \
           $(HZ_SVG) $(HZ_R1_SVG) $(HZ_R2_SVG) $(HZ_R3_SVG) \
           $(HZ_FULL_SVG) $(HZ_FULL_R1_SVG) $(HZ_FULL_R2_SVG) $(HZ_FULL_R3_SVG) \
           $(HZ_FULL_DARK_SVG) $(HZ_FULL_DARK_R1_SVG) $(HZ_FULL_DARK_R2_SVG) $(HZ_FULL_DARK_R3_SVG) \
           $(COLORFUL_SVG) $(RAINBOW_SVG)

# ── Generated raster outputs ────────────────────────────────────────────────────
SQ_PNG_OUT    = $(SQ_PNG)/square.png
SQ_WEBP       = $(SQ_PNG)/square.webp
SQ_LN_PNG     = $(SQ_PNG)/square-light-nougat.png
SQ_LN_WEBP    = $(SQ_PNG)/square-light-nougat.webp
SQ_N_PNG      = $(SQ_PNG)/square-nougat.png
SQ_N_WEBP     = $(SQ_PNG)/square-nougat.webp
SQ_DN_PNG     = $(SQ_PNG)/square-dark-nougat.png
SQ_DN_WEBP    = $(SQ_PNG)/square-dark-nougat.webp
ANIM_FRAMES   = $(SQ_PNG_OUT) $(SQ_LN_PNG) $(SQ_N_PNG) $(SQ_DN_PNG)
ANIM_GIF      = $(SQ_PNG)/square-animated.gif
ANIM_WEBP     = $(SQ_PNG)/square-animated.webp
HZ_PNG_OUT       = $(HZ_PNG)/horizontal.png
HZ_WEBP          = $(HZ_PNG)/horizontal.webp
HZ_R1_PNG        = $(HZ_PNG)/horizontal-rot1.png
HZ_R1_WEBP       = $(HZ_PNG)/horizontal-rot1.webp
HZ_R2_PNG        = $(HZ_PNG)/horizontal-rot2.png
HZ_R2_WEBP       = $(HZ_PNG)/horizontal-rot2.webp
HZ_R3_PNG        = $(HZ_PNG)/horizontal-rot3.png
HZ_R3_WEBP       = $(HZ_PNG)/horizontal-rot3.webp
HZ_FULL_PNG      = $(HZ_PNG)/horizontal-full.png
HZ_FULL_WEBP     = $(HZ_PNG)/horizontal-full.webp
HZ_FULL_R1_PNG   = $(HZ_PNG)/horizontal-full-rot1.png
HZ_FULL_R1_WEBP  = $(HZ_PNG)/horizontal-full-rot1.webp
HZ_FULL_R2_PNG   = $(HZ_PNG)/horizontal-full-rot2.png
HZ_FULL_R2_WEBP  = $(HZ_PNG)/horizontal-full-rot2.webp
HZ_FULL_R3_PNG   = $(HZ_PNG)/horizontal-full-rot3.png
HZ_FULL_R3_WEBP  = $(HZ_PNG)/horizontal-full-rot3.webp
HZ_ANIM_FRAMES      = $(HZ_PNG_OUT) $(HZ_R1_PNG) $(HZ_R2_PNG) $(HZ_R3_PNG)
HZ_FULL_ANIM_FRAMES = $(HZ_FULL_PNG) $(HZ_FULL_R1_PNG) $(HZ_FULL_R2_PNG) $(HZ_FULL_R3_PNG)
HZ_ANIM_GIF         = $(HZ_PNG)/horizontal-animated.gif
HZ_ANIM_WEBP        = $(HZ_PNG)/horizontal-animated.webp
HZ_FULL_ANIM_GIF    = $(HZ_PNG)/horizontal-full-animated.gif
HZ_FULL_ANIM_WEBP   = $(HZ_PNG)/horizontal-full-animated.webp
HZ_FULL_DARK_PNG    = $(HZ_PNG)/horizontal-full-dark.png
HZ_FULL_DARK_WEBP   = $(HZ_PNG)/horizontal-full-dark.webp
HZ_FULL_DARK_R1_PNG = $(HZ_PNG)/horizontal-full-dark-rot1.png
HZ_FULL_DARK_R2_PNG = $(HZ_PNG)/horizontal-full-dark-rot2.png
HZ_FULL_DARK_R3_PNG = $(HZ_PNG)/horizontal-full-dark-rot3.png
HZ_FULL_DARK_ANIM_FRAMES = $(HZ_FULL_DARK_PNG) $(HZ_FULL_DARK_R1_PNG) $(HZ_FULL_DARK_R2_PNG) $(HZ_FULL_DARK_R3_PNG)
HZ_FULL_DARK_ANIM_GIF    = $(HZ_PNG)/horizontal-full-dark-animated.gif
HZ_FULL_DARK_ANIM_WEBP   = $(HZ_PNG)/horizontal-full-dark-animated.webp
COLORFUL_PNG  = $(SQ_PNG)/minifig-colorful.png
COLORFUL_WEBP = $(SQ_PNG)/minifig-colorful.webp
RAINBOW_PNG   = $(SQ_PNG)/minifig-rainbow.png
RAINBOW_WEBP  = $(SQ_PNG)/minifig-rainbow.webp

ALL_PNGS = $(SQ_PNG_OUT) $(SQ_WEBP) \
           $(SQ_LN_PNG) $(SQ_LN_WEBP) \
           $(SQ_N_PNG) $(SQ_N_WEBP) \
           $(SQ_DN_PNG) $(SQ_DN_WEBP) \
           $(ANIM_GIF) $(ANIM_WEBP) \
           $(HZ_PNG_OUT) $(HZ_WEBP) \
           $(HZ_R1_PNG) $(HZ_R1_WEBP) \
           $(HZ_R2_PNG) $(HZ_R2_WEBP) \
           $(HZ_R3_PNG) $(HZ_R3_WEBP) \
           $(HZ_FULL_PNG) $(HZ_FULL_WEBP) \
           $(HZ_FULL_R1_PNG) $(HZ_FULL_R1_WEBP) \
           $(HZ_FULL_R2_PNG) $(HZ_FULL_R2_WEBP) \
           $(HZ_FULL_R3_PNG) $(HZ_FULL_R3_WEBP) \
           $(HZ_ANIM_GIF) $(HZ_ANIM_WEBP) \
           $(HZ_FULL_ANIM_GIF) $(HZ_FULL_ANIM_WEBP) \
           $(HZ_FULL_DARK_PNG) $(HZ_FULL_DARK_WEBP) \
           $(HZ_FULL_DARK_R1_PNG) $(HZ_FULL_DARK_R2_PNG) $(HZ_FULL_DARK_R3_PNG) \
           $(HZ_FULL_DARK_ANIM_GIF) $(HZ_FULL_DARK_ANIM_WEBP) \
           $(COLORFUL_PNG) $(COLORFUL_WEBP) \
           $(RAINBOW_PNG) $(RAINBOW_WEBP)

# ── Top-level targets ───────────────────────────────────────────────────────────
# ── Favicon outputs ─────────────────────────────────────────────────────────────
FAVICON_ICO   = $(FAVICON_DIR)/favicon.ico
FAVICON_FILES = $(FAVICON_ICO) \
                $(FAVICON_DIR)/favicon-16.png \
                $(FAVICON_DIR)/favicon-32.png \
                $(FAVICON_DIR)/favicon-48.png \
                $(FAVICON_DIR)/apple-touch-icon.png \
                $(FAVICON_DIR)/icon-192.png \
                $(FAVICON_DIR)/icon-512.png

# ── Top-level targets ───────────────────────────────────────────────────────────
.PHONY: all logos pngs designs favicons clean help shell develop

all: logos pngs favicons ## Build everything (design sources → brick SVGs → PNG/WebP → favicons)

logos: designs $(ALL_SVGS) ## Build all brick SVGs

pngs: logos $(ALL_PNGS) ## Export all PNGs and WebPs

favicons: pngs $(FAVICON_FILES) ## Generate favicon.ico and PNG variants

designs: $(DESIGN_SQ) $(DESIGN_SQ_LN) $(DESIGN_SQ_N) $(DESIGN_SQ_DN) \
         $(DESIGN_HZ) $(DESIGN_HZ_R1) $(DESIGN_HZ_R2) $(DESIGN_HZ_R3) \
         $(DESIGN_COLORFUL) $(DESIGN_RAINBOW) ## Populate design/ from source.svg and colors.py

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Remove all generated files (design/, logo outputs, and Python cache)
	rm -f $(DESIGN_SQ) $(DESIGN_SQ_LN) $(DESIGN_SQ_N) $(DESIGN_SQ_DN) \
	      $(DESIGN_HZ) $(DESIGN_HZ_R1) $(DESIGN_HZ_R2) $(DESIGN_HZ_R3) \
	      $(DESIGN_COLORFUL) $(DESIGN_RAINBOW)
	rm -f $(ALL_SVGS) $(ALL_PNGS)
	rm -f $(FAVICON_FILES)
	rm -rf __pycache__

shell: ## Enter devenv shell
	devenv shell

develop: devenv.local.nix devenv.local.yaml ## Bootstrap development environment
	devenv shell --profile=devcontainer -- code .

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml

# ── Design sources ──────────────────────────────────────────────────────────────
$(DESIGN_DIR):
	mkdir -p $@

# All designs generated by generate_designs.py from source.svg + colors.py
$(DESIGN_SQ) $(DESIGN_SQ_LN) $(DESIGN_SQ_N) $(DESIGN_SQ_DN) \
$(DESIGN_HZ) $(DESIGN_HZ_R1) $(DESIGN_HZ_R2) $(DESIGN_HZ_R3) \
$(DESIGN_COLORFUL) $(DESIGN_RAINBOW): source.svg colors.py generate_designs.py | $(DESIGN_DIR)
	$(PYTHON) generate_designs.py

# ── Square brick SVGs ────────────────────────────────────────────────────────────
$(SQ_DIR):
	mkdir -p $@

$(SQ_SVG): $(DESIGN_SQ) | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(SQ_LN_SVG): $(DESIGN_SQ_LN) | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(SQ_N_SVG): $(DESIGN_SQ_N) | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(SQ_DN_SVG): $(DESIGN_SQ_DN) | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

# ── Colorful / rainbow variant brick SVGs ───────────────────────────────────────
$(COLORFUL_SVG): $(DESIGN_COLORFUL) | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(RAINBOW_SVG): $(DESIGN_RAINBOW) | $(SQ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(SQ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

# ── Horizontal brick SVGs ───────────────────────────────────────────────────────
$(HZ_DIR):
	mkdir -p $@

$(HZ_SVG): $(DESIGN_HZ) | $(HZ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(HZ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(HZ_R1_SVG): $(DESIGN_HZ_R1) | $(HZ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(HZ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(HZ_R2_SVG): $(DESIGN_HZ_R2) | $(HZ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(HZ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(HZ_R3_SVG): $(DESIGN_HZ_R3) | $(HZ_DIR)
	$(PYTHON) brick_blockify.py $< $@ $(HZ_PX) $(BLK_W) $(BLK_H) auto $(PAD)

$(HZ_FULL_SVG): $(HZ_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE)

$(HZ_FULL_R1_SVG): $(HZ_R1_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE)

$(HZ_FULL_R2_SVG): $(HZ_R2_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE)

$(HZ_FULL_R3_SVG): $(HZ_R3_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE)

$(HZ_FULL_DARK_SVG): $(HZ_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE) '$(DARK_BG)'

$(HZ_FULL_DARK_R1_SVG): $(HZ_R1_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE) '$(DARK_BG)'

$(HZ_FULL_DARK_R2_SVG): $(HZ_R2_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE) '$(DARK_BG)'

$(HZ_FULL_DARK_R3_SVG): $(HZ_R3_SVG)
	$(PYTHON) compose_logo.py $< $@ $(TXT_SIZE) '$(DARK_BG)'

# ── Square PNG / WebP ───────────────────────────────────────────────────────────
$(SQ_PNG):
	mkdir -p $@

$(SQ_PNG)/%.png: $(SQ_DIR)/%.svg | $(SQ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

$(SQ_PNG)/%.webp: $(SQ_DIR)/%.svg | $(SQ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

# ── Animated skin-tone logo (GIF + WebP) ────────────────────────────────────────
$(ANIM_GIF): $(ANIM_FRAMES) | $(SQ_PNG)
	$(PYTHON) animate_logo.py $(ANIM_FRAMES) $@ $(ANIM_MS)

$(ANIM_WEBP): $(ANIM_FRAMES) | $(SQ_PNG)
	$(PYTHON) animate_logo.py $(ANIM_FRAMES) $@ $(ANIM_MS)

# ── Animated horizontal logos (GIF + WebP) ──────────────────────────────────────
$(HZ_ANIM_GIF): $(HZ_ANIM_FRAMES) | $(HZ_PNG)
	$(PYTHON) animate_logo.py $(HZ_ANIM_FRAMES) $@ $(ANIM_MS)

$(HZ_ANIM_WEBP): $(HZ_ANIM_FRAMES) | $(HZ_PNG)
	$(PYTHON) animate_logo.py $(HZ_ANIM_FRAMES) $@ $(ANIM_MS)

$(HZ_FULL_ANIM_GIF): $(HZ_FULL_ANIM_FRAMES) | $(HZ_PNG)
	$(PYTHON) animate_logo.py $(HZ_FULL_ANIM_FRAMES) $@ $(ANIM_MS)

$(HZ_FULL_ANIM_WEBP): $(HZ_FULL_ANIM_FRAMES) | $(HZ_PNG)
	$(PYTHON) animate_logo.py $(HZ_FULL_ANIM_FRAMES) $@ $(ANIM_MS)

$(HZ_FULL_DARK_ANIM_GIF): $(HZ_FULL_DARK_ANIM_FRAMES) | $(HZ_PNG)
	$(PYTHON) animate_logo.py $(HZ_FULL_DARK_ANIM_FRAMES) $@ $(ANIM_MS)

$(HZ_FULL_DARK_ANIM_WEBP): $(HZ_FULL_DARK_ANIM_FRAMES) | $(HZ_PNG)
	$(PYTHON) animate_logo.py $(HZ_FULL_DARK_ANIM_FRAMES) $@ $(ANIM_MS)

# ── Horizontal PNG / WebP ───────────────────────────────────────────────────────
$(HZ_PNG):
	mkdir -p $@

$(HZ_PNG)/%.png: $(HZ_DIR)/%.svg | $(HZ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

$(HZ_PNG)/%.webp: $(HZ_DIR)/%.svg | $(HZ_PNG)
	$(PYTHON) export_raster.py $< $@ 800

# ── Favicons ────────────────────────────────────────────────────────────────────
$(FAVICON_DIR):
	mkdir -p $@

$(FAVICON_FILES): $(SQ_SVG) generate_favicons.py | $(FAVICON_DIR)
	$(PYTHON) generate_favicons.py

