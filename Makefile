.PHONY: help all build blay-compose-all assets assets-from-blay site dev dev-watch deploy install test check format clean watch watch-elm repl develop shell render outline-text

# Use pnpm exec for elm-pages so the project-local writable node_modules are used.
# This avoids the Nix store's read-only node_modules being added to PATH (which
# causes the lamdera JS wrapper to attempt hard-linking into the Nix store → EPERM).

# ── Pipeline constants ────────────────────────────────────────────────────────
# Single source of truth — forwarded verbatim as CLI flags to the executables.
# Change a value here; no Haskell rebuild required.

FONT_PATH := fonts/Outfit-VariableFont_wght.ttf
SUBTITLE  := Suomen Palikkaharrastajat ry

BLK_W     := 24
BLK_H     := 20
SQ_PAD_V  := 20
HZ_PAD_TOP:= 20
GAP_STUDS := 2
TXT_SIZE       := 63
TXT_SIZE_SQ    := 24
TXT_WEIGHT_BOLD := 700
HZ_BOLD_PAD_X  := 40
SUBTITLE_LINE1 := Suomen
SUBTITLE_LINE2 := Palikkaharrastajat ry
ANIM_MS        := 10000
RASTER_W  := 800

# Subtitle colours (6-digit hex, no #)
SUBTITLE_LIGHT := 05131D
SUBTITLE_DARK  := FFFFFF

# Placeholder and skin-tone colours in master .blay files (6-digit hex, no #)
FACE_PH           := F2CD37
SKIN_WHITE        := FFFFFF
SKIN_YELLOW       := F2CD37
SKIN_LIGHT_NOUGAT := F6D7B3
SKIN_NOUGAT       := D09168
SKIN_DARK_NOUGAT  := AD6140

# Rainbow colours (6-digit hex, no #)
RB_SALMON   := F2705E
RB_ORANGE   := F9BA61
RB_YELLOW   := F2CD37
RB_GREEN    := 73DCA1
RB_BLUE     := 9FC3E9
RB_INDIGO   := 9195CA
RB_LAVENDER := AC78BA

_HZ_TILE := --tile --gap-studs $(GAP_STUDS) --pad-top $(HZ_PAD_TOP) --pad-bottom $(HZ_PAD_TOP)

# ── PATH trimming (prevents E2BIG when cabal spawns GHC) ─────────────────────
_GHC_BIN    := $(shell dirname $(shell which ghc          2>/dev/null) 2>/dev/null)
_CABAL_BIN  := $(shell dirname $(shell which cabal        2>/dev/null) 2>/dev/null)
_RSVG_BIN   := $(shell dirname $(shell which rsvg-convert 2>/dev/null) 2>/dev/null)
_WEBP_BIN   := $(shell dirname $(shell which cwebp        2>/dev/null) 2>/dev/null)
_GIFSKI_BIN := $(shell dirname $(shell which gifski       2>/dev/null) 2>/dev/null)
_ICO_BIN    := $(shell dirname $(shell which icotool      2>/dev/null) 2>/dev/null)
_MAGICK_BIN := $(shell dirname $(shell which convert      2>/dev/null) 2>/dev/null)
_SLIM_PATH  := $(_GHC_BIN):$(_CABAL_BIN):$(_RSVG_BIN):$(_WEBP_BIN):$(_GIFSKI_BIN):$(_ICO_BIN):$(_MAGICK_BIN):/usr/bin:/bin
CABAL       := env PATH="$(_SLIM_PATH)" cabal

HS_SOURCES := $(shell find src app -name '*.hs') logo.cabal $(wildcard cabal.project*)

# ── Output roots ─────────────────────────────────────────────────────────────
SQ_SVG := logo/square/svg
SQ_PNG := logo/square/png
HZ_SVG := logo/horizontal/svg
HZ_PNG := logo/horizontal/png

# ── Phony help ────────────────────────────────────────────────────────────────

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

all: site ## Build everything: Haskell -> assets -> elm-pages -> dist/

# ── Haskell ───────────────────────────────────────────────────────────────────

build: ## Compile all Haskell executables (no run)
	$(CABAL) build --offline

# ── blay-compose: derive .blay files from masters (run locally; commit outputs)
#
# Masters: layout/head-basic.blay ... layout/head-laugh.blay use FACE_PH as placeholder.
# Draft a new master from a source SVG:
#   cabal run --offline blay-draft -- --source SRC.svg --output layout/head-basic.blay

_COMPOSE = $(CABAL) run --offline blay-compose --

# Square smiley blays
layout/square-basic.blay: layout/head-basic.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_YELLOW) --output $@

layout/square-smile.blay: layout/head-smile.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_YELLOW) --output $@

layout/square-blink.blay: layout/head-blink.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_YELLOW) --output $@

layout/square-laugh.blay: layout/head-laugh.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_YELLOW) --output $@

# Black-and-white square blays (white face, dark details)
layout/square-bw-basic.blay: layout/head-basic.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_WHITE) --output $@

layout/square-bw-smile.blay: layout/head-smile.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_WHITE) --output $@

layout/square-bw-blink.blay: layout/head-blink.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_WHITE) --output $@

layout/square-bw-laugh.blay: layout/head-laugh.blay $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_WHITE) --output $@

_SQ_BLAYS := layout/square-basic.blay layout/square-smile.blay layout/square-blink.blay layout/square-laugh.blay

# Horizontal smiley blays
layout/horizontal.blay: $(_SQ_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/square-basic.blay --input layout/square-smile.blay --input layout/square-blink.blay --input layout/square-laugh.blay $(_HZ_TILE) --output $@

layout/horizontal-rot1.blay: $(_SQ_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/square-smile.blay --input layout/square-blink.blay --input layout/square-laugh.blay --input layout/square-basic.blay $(_HZ_TILE) --output $@

layout/horizontal-rot2.blay: $(_SQ_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/square-blink.blay --input layout/square-laugh.blay --input layout/square-basic.blay --input layout/square-smile.blay $(_HZ_TILE) --output $@

layout/horizontal-rot3.blay: $(_SQ_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/square-laugh.blay --input layout/square-basic.blay --input layout/square-smile.blay --input layout/square-blink.blay $(_HZ_TILE) --output $@

_MASTER_BLAYS := layout/square-basic.blay layout/square-smile.blay layout/square-blink.blay layout/square-laugh.blay

# Horizontal rainbow blays — sliding windows of 4 from 7 rainbow colours
layout/horizontal-rainbow.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_SALMON) --input layout/head-smile.blay:$(FACE_PH):$(RB_ORANGE) --input layout/head-blink.blay:$(FACE_PH):$(RB_YELLOW) --input layout/head-laugh.blay:$(FACE_PH):$(RB_GREEN) $(_HZ_TILE) --output $@

layout/horizontal-rainbow-rot1.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_ORANGE) --input layout/head-smile.blay:$(FACE_PH):$(RB_YELLOW) --input layout/head-blink.blay:$(FACE_PH):$(RB_GREEN) --input layout/head-laugh.blay:$(FACE_PH):$(RB_BLUE) $(_HZ_TILE) --output $@

layout/horizontal-rainbow-rot2.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_YELLOW) --input layout/head-smile.blay:$(FACE_PH):$(RB_GREEN) --input layout/head-blink.blay:$(FACE_PH):$(RB_BLUE) --input layout/head-laugh.blay:$(FACE_PH):$(RB_INDIGO) $(_HZ_TILE) --output $@

layout/horizontal-rainbow-rot3.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_GREEN) --input layout/head-smile.blay:$(FACE_PH):$(RB_BLUE) --input layout/head-blink.blay:$(FACE_PH):$(RB_INDIGO) --input layout/head-laugh.blay:$(FACE_PH):$(RB_LAVENDER) $(_HZ_TILE) --output $@

layout/horizontal-rainbow-rot4.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_BLUE) --input layout/head-smile.blay:$(FACE_PH):$(RB_INDIGO) --input layout/head-blink.blay:$(FACE_PH):$(RB_LAVENDER) --input layout/head-laugh.blay:$(FACE_PH):$(RB_SALMON) $(_HZ_TILE) --output $@

layout/horizontal-rainbow-rot5.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_INDIGO) --input layout/head-smile.blay:$(FACE_PH):$(RB_LAVENDER) --input layout/head-blink.blay:$(FACE_PH):$(RB_SALMON) --input layout/head-laugh.blay:$(FACE_PH):$(RB_ORANGE) $(_HZ_TILE) --output $@

layout/horizontal-rainbow-rot6.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(RB_LAVENDER) --input layout/head-smile.blay:$(FACE_PH):$(RB_SALMON) --input layout/head-blink.blay:$(FACE_PH):$(RB_ORANGE) --input layout/head-laugh.blay:$(FACE_PH):$(RB_YELLOW) $(_HZ_TILE) --output $@

# Horizontal skintone blays — sliding 4 skin colors
layout/horizontal-skintone.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_YELLOW) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_LIGHT_NOUGAT) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_NOUGAT) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_DARK_NOUGAT) $(_HZ_TILE) --output $@

layout/horizontal-skintone-rot1.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_LIGHT_NOUGAT) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_NOUGAT) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_DARK_NOUGAT) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_YELLOW) $(_HZ_TILE) --output $@

layout/horizontal-skintone-rot2.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_NOUGAT) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_DARK_NOUGAT) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_YELLOW) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_LIGHT_NOUGAT) $(_HZ_TILE) --output $@

layout/horizontal-skintone-rot3.blay: $(_MASTER_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_DARK_NOUGAT) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_YELLOW) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_LIGHT_NOUGAT) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_NOUGAT) $(_HZ_TILE) --output $@

_BW_SQ_BLAYS := layout/square-bw-basic.blay layout/square-bw-smile.blay layout/square-bw-blink.blay layout/square-bw-laugh.blay

# Black-and-white horizontal blays (white face, dark details)
layout/horizontal-bw.blay: $(_BW_SQ_BLAYS) $(HS_SOURCES)
	$(_COMPOSE) --input layout/head-basic.blay:$(FACE_PH):$(SKIN_WHITE) --input layout/head-smile.blay:$(FACE_PH):$(SKIN_WHITE) --input layout/head-blink.blay:$(FACE_PH):$(SKIN_WHITE) --input layout/head-laugh.blay:$(FACE_PH):$(SKIN_WHITE) $(_HZ_TILE) --output $@

DERIVED_BLAYS := \
  layout/square-basic.blay layout/square-smile.blay \
  layout/square-blink.blay layout/square-laugh.blay \
  layout/square-bw-basic.blay layout/square-bw-smile.blay \
  layout/square-bw-blink.blay layout/square-bw-laugh.blay \
  layout/horizontal.blay layout/horizontal-rot1.blay \
  layout/horizontal-rot2.blay layout/horizontal-rot3.blay \
  layout/horizontal-rainbow.blay layout/horizontal-rainbow-rot1.blay \
  layout/horizontal-rainbow-rot2.blay layout/horizontal-rainbow-rot3.blay \
  layout/horizontal-rainbow-rot4.blay layout/horizontal-rainbow-rot5.blay \
  layout/horizontal-rainbow-rot6.blay \
  layout/horizontal-skintone.blay layout/horizontal-skintone-rot1.blay \
  layout/horizontal-skintone-rot2.blay layout/horizontal-skintone-rot3.blay \
  layout/horizontal-bw.blay

blay-compose-all: build $(DERIVED_BLAYS) ## Derive all .blay files (run locally; commit outputs)

# ── blay-render: .blay -> SVG + PNG + WebP ───────────────────────────────────
# Each .blay is an independent Make target: one run produces all formats.
# No stamp files — the output files themselves are the targets.

_RENDER = $(CABAL) run --offline blay-render --

_COMPOSE_FLAGS := \
  --compose-font '$(FONT_PATH)' \
  --compose-text '$(SUBTITLE)' \
  --compose-text-weight 400 \
  --compose-text-size $(TXT_SIZE) \
  --compose-light-color $(SUBTITLE_LIGHT) \
  --compose-dark-color $(SUBTITLE_DARK) \
  --compose-pad-bottom 0

_COMPOSE_FLAGS_BOLD := \
  --compose-font '$(FONT_PATH)' \
  --compose-text '$(SUBTITLE)' \
  --compose-text-weight $(TXT_WEIGHT_BOLD) \
  --compose-text-size $(TXT_SIZE) \
  --compose-light-color $(SUBTITLE_LIGHT) \
  --compose-dark-color $(SUBTITLE_DARK) \
  --compose-pad-bottom 0 \
  --compose-pad-x $(HZ_BOLD_PAD_X)

_COMPOSE_FLAGS_SQ := \
  --compose-font '$(FONT_PATH)' \
  --compose-text '$(SUBTITLE_LINE1)' \
  --compose-text2 '$(SUBTITLE_LINE2)' \
  --compose-text-weight 400 \
  --compose-text-size $(TXT_SIZE_SQ) \
  --compose-light-color $(SUBTITLE_LIGHT) \
  --compose-dark-color $(SUBTITLE_DARK) \
  --compose-pad-bottom 0 \
  --compose-square

_COMPOSE_FLAGS_SQ_BOLD := \
  --compose-font '$(FONT_PATH)' \
  --compose-text '$(SUBTITLE_LINE1)' \
  --compose-text2 '$(SUBTITLE_LINE2)' \
  --compose-text-weight $(TXT_WEIGHT_BOLD) \
  --compose-text-size $(TXT_SIZE_SQ) \
  --compose-light-color $(SUBTITLE_LIGHT) \
  --compose-dark-color $(SUBTITLE_DARK) \
  --compose-pad-bottom 0 \
  --compose-square

# Macro: render a square-basic.blay => SVG + PNG + WebP (no subtitle composition)
# $(1) = stem (e.g. square-basic)
define render_square
$(SQ_SVG)/$(1).svg $(SQ_PNG)/$(1).png $(SQ_PNG)/$(1).webp &: layout/$(1).blay $(HS_SOURCES) | build
	@mkdir -p $(SQ_SVG) $(SQ_PNG)
	$(_RENDER) \
	  --input layout/$(1).blay \
	  --svg-out  $(SQ_SVG)/$(1).svg \
	  --png-out  $(SQ_PNG)/$(1).png \
	  --webp-out $(SQ_PNG)/$(1).webp \
	  --width $(RASTER_W)
endef

# Macro: render a horizontal blay => SVG + PNG + WebP + light/dark composed variants
# (regular weight 400 + bold weight 700)
# $(1) = stem (e.g. horizontal)
define render_horizontal
$(HZ_SVG)/$(1).svg $(HZ_PNG)/$(1).png $(HZ_PNG)/$(1).webp \
$(HZ_SVG)/$(1)-full.svg $(HZ_PNG)/$(1)-full.png $(HZ_PNG)/$(1)-full.webp \
$(HZ_SVG)/$(1)-full-dark.svg $(HZ_PNG)/$(1)-full-dark.png $(HZ_PNG)/$(1)-full-dark.webp \
$(HZ_SVG)/$(1)-full-bold.svg $(HZ_PNG)/$(1)-full-bold.png $(HZ_PNG)/$(1)-full-bold.webp \
$(HZ_SVG)/$(1)-full-dark-bold.svg $(HZ_PNG)/$(1)-full-dark-bold.png $(HZ_PNG)/$(1)-full-dark-bold.webp &: layout/$(1).blay $(FONT_PATH) $(HS_SOURCES) | build
	@mkdir -p $(HZ_SVG) $(HZ_PNG)
	$(_RENDER) \
	  --input    layout/$(1).blay \
	  --svg-out  $(HZ_SVG)/$(1).svg \
	  --png-out  $(HZ_PNG)/$(1).png \
	  --webp-out $(HZ_PNG)/$(1).webp \
	  --width $(RASTER_W) \
	  $(_COMPOSE_FLAGS) \
	  --compose-svg-out       $(HZ_SVG)/$(1)-full.svg \
	  --compose-png-out       $(HZ_PNG)/$(1)-full.png \
	  --compose-webp-out      $(HZ_PNG)/$(1)-full.webp \
	  --compose-dark-svg-out  $(HZ_SVG)/$(1)-full-dark.svg \
	  --compose-dark-png-out  $(HZ_PNG)/$(1)-full-dark.png \
	  --compose-dark-webp-out $(HZ_PNG)/$(1)-full-dark.webp
	$(_RENDER) \
	  --input    layout/$(1).blay \
	  --width $(RASTER_W) \
	  $(_COMPOSE_FLAGS_BOLD) \
	  --compose-svg-out       $(HZ_SVG)/$(1)-full-bold.svg \
	  --compose-png-out       $(HZ_PNG)/$(1)-full-bold.png \
	  --compose-webp-out      $(HZ_PNG)/$(1)-full-bold.webp \
	  --compose-dark-svg-out  $(HZ_SVG)/$(1)-full-dark-bold.svg \
	  --compose-dark-png-out  $(HZ_PNG)/$(1)-full-dark-bold.png \
	  --compose-dark-webp-out $(HZ_PNG)/$(1)-full-dark-bold.webp
endef

# square-basic is rendered by the favicon rule below (single grouped target);
# the remaining square faces go through the render_square macro.
_SQ_DERIVED := square-laugh square-blink square-basic square-bw-basic square-bw-smile square-bw-blink square-bw-laugh
SQ_STEMS    := square-smile $(_SQ_DERIVED)
HZ_STEMS    := \
  horizontal horizontal-rot1 horizontal-rot2 horizontal-rot3 \
  horizontal-rainbow horizontal-rainbow-rot1 horizontal-rainbow-rot2 \
  horizontal-rainbow-rot3 horizontal-rainbow-rot4 \
  horizontal-rainbow-rot5 horizontal-rainbow-rot6 \
  horizontal-skintone horizontal-skintone-rot1 horizontal-skintone-rot2 \
  horizontal-skintone-rot3 \
  horizontal-bw

$(foreach s,$(_SQ_DERIVED),$(eval $(call render_square,$(s))))
$(foreach s,$(HZ_STEMS),$(eval $(call render_horizontal,$(s))))

# Favicons — generated alongside the square-smile PNG (the primary neutral face)
$(SQ_SVG)/square-smile.svg $(SQ_PNG)/square-smile.png $(SQ_PNG)/square-smile.webp favicon/favicon.ico &: layout/square-smile.blay $(HS_SOURCES) | build
	@mkdir -p $(SQ_SVG) $(SQ_PNG) favicon
	$(_RENDER) \
	  --input    layout/square-smile.blay \
	  --svg-out  $(SQ_SVG)/square-smile.svg \
	  --png-out  $(SQ_PNG)/square-smile.png \
	  --webp-out $(SQ_PNG)/square-smile.webp \
	  --width $(RASTER_W) \
	  --favicon-dir favicon

# Square logo with two-line centered text below (normal + bold, light + dark)
$(SQ_SVG)/square-smile-full.svg $(SQ_PNG)/square-smile-full.png $(SQ_PNG)/square-smile-full.webp \
$(SQ_SVG)/square-smile-full-dark.svg $(SQ_PNG)/square-smile-full-dark.png $(SQ_PNG)/square-smile-full-dark.webp \
$(SQ_SVG)/square-smile-full-bold.svg $(SQ_PNG)/square-smile-full-bold.png $(SQ_PNG)/square-smile-full-bold.webp \
$(SQ_SVG)/square-smile-full-dark-bold.svg $(SQ_PNG)/square-smile-full-dark-bold.png $(SQ_PNG)/square-smile-full-dark-bold.webp &: layout/square-smile.blay $(FONT_PATH) $(HS_SOURCES) | build
	@mkdir -p $(SQ_SVG) $(SQ_PNG)
	$(_RENDER) \
	  --input layout/square-smile.blay \
	  --width $(RASTER_W) \
	  $(_COMPOSE_FLAGS_SQ) \
	  --compose-svg-out       $(SQ_SVG)/square-smile-full.svg \
	  --compose-png-out       $(SQ_PNG)/square-smile-full.png \
	  --compose-webp-out      $(SQ_PNG)/square-smile-full.webp \
	  --compose-dark-svg-out  $(SQ_SVG)/square-smile-full-dark.svg \
	  --compose-dark-png-out  $(SQ_PNG)/square-smile-full-dark.png \
	  --compose-dark-webp-out $(SQ_PNG)/square-smile-full-dark.webp
	$(_RENDER) \
	  --input layout/square-smile.blay \
	  --width $(RASTER_W) \
	  $(_COMPOSE_FLAGS_SQ_BOLD) \
	  --compose-svg-out       $(SQ_SVG)/square-smile-full-bold.svg \
	  --compose-png-out       $(SQ_PNG)/square-smile-full-bold.png \
	  --compose-webp-out      $(SQ_PNG)/square-smile-full-bold.webp \
	  --compose-dark-svg-out  $(SQ_SVG)/square-smile-full-dark-bold.svg \
	  --compose-dark-png-out  $(SQ_PNG)/square-smile-full-dark-bold.png \
	  --compose-dark-webp-out $(SQ_PNG)/square-smile-full-dark-bold.webp

_SQ_FULL_OUTPUTS := \
  $(SQ_SVG)/square-smile-full.svg $(SQ_PNG)/square-smile-full.png $(SQ_PNG)/square-smile-full.webp \
  $(SQ_SVG)/square-smile-full-dark.svg $(SQ_PNG)/square-smile-full-dark.png $(SQ_PNG)/square-smile-full-dark.webp \
  $(SQ_SVG)/square-smile-full-bold.svg $(SQ_PNG)/square-smile-full-bold.png $(SQ_PNG)/square-smile-full-bold.webp \
  $(SQ_SVG)/square-smile-full-dark-bold.svg $(SQ_PNG)/square-smile-full-dark-bold.png $(SQ_PNG)/square-smile-full-dark-bold.webp

ALL_SQ_OUTPUTS := $(foreach s,$(SQ_STEMS),$(SQ_SVG)/$(s).svg $(SQ_PNG)/$(s).png $(SQ_PNG)/$(s).webp) $(_SQ_FULL_OUTPUTS)
ALL_HZ_OUTPUTS := $(foreach s,$(HZ_STEMS), \
  $(HZ_SVG)/$(s).svg $(HZ_PNG)/$(s).png $(HZ_PNG)/$(s).webp \
  $(HZ_SVG)/$(s)-full.svg $(HZ_PNG)/$(s)-full.png $(HZ_PNG)/$(s)-full.webp \
  $(HZ_SVG)/$(s)-full-dark.svg $(HZ_PNG)/$(s)-full-dark.png $(HZ_PNG)/$(s)-full-dark.webp \
  $(HZ_SVG)/$(s)-full-bold.svg $(HZ_PNG)/$(s)-full-bold.png $(HZ_PNG)/$(s)-full-bold.webp \
  $(HZ_SVG)/$(s)-full-dark-bold.svg $(HZ_PNG)/$(s)-full-dark-bold.png $(HZ_PNG)/$(s)-full-dark-bold.webp)

# ── blay-animate: PNG frames -> animated GIF + WebP ──────────────────────────

_ANIMATE = $(CABAL) run --offline blay-animate --
# Yellow-face stems only — bw variants are excluded from the animation
_SQ_ANIM_STEMS   := square-smile square-laugh square-blink square-basic
_SQ_FRAMES       := $(foreach s,$(_SQ_ANIM_STEMS),$(SQ_PNG)/$(s).png)
_HZ_SKIN_STEMS   := horizontal horizontal-rot1 horizontal-rot2 horizontal-rot3
_RB_STEMS        := horizontal-rainbow horizontal-rainbow-rot1 horizontal-rainbow-rot2 horizontal-rainbow-rot3 horizontal-rainbow-rot4 horizontal-rainbow-rot5 horizontal-rainbow-rot6
_SC_STEMS        := horizontal-skintone horizontal-skintone-rot1 horizontal-skintone-rot2 horizontal-skintone-rot3
_HZ_FRAMES           := $(foreach s,$(_HZ_SKIN_STEMS),$(HZ_PNG)/$(s).png)
_HZ_FULL_FRAMES      := $(foreach s,$(_HZ_SKIN_STEMS),$(HZ_PNG)/$(s)-full.png)
_HZ_DARK_FRAMES      := $(foreach s,$(_HZ_SKIN_STEMS),$(HZ_PNG)/$(s)-full-dark.png)
_HZ_BOLD_FRAMES      := $(foreach s,$(_HZ_SKIN_STEMS),$(HZ_PNG)/$(s)-full-bold.png)
_HZ_DARK_BOLD_FRAMES := $(foreach s,$(_HZ_SKIN_STEMS),$(HZ_PNG)/$(s)-full-dark-bold.png)
_RB_FRAMES       := $(foreach s,$(_RB_STEMS),$(HZ_PNG)/$(s).png)
_RB_FULL_FRAMES  := $(foreach s,$(_RB_STEMS),$(HZ_PNG)/$(s)-full.png)
_RB_DARK_FRAMES  := $(foreach s,$(_RB_STEMS),$(HZ_PNG)/$(s)-full-dark.png)
_SC_FRAMES       := $(foreach s,$(_SC_STEMS),$(HZ_PNG)/$(s).png)
_SC_FULL_FRAMES  := $(foreach s,$(_SC_STEMS),$(HZ_PNG)/$(s)-full.png)
_SC_DARK_FRAMES  := $(foreach s,$(_SC_STEMS),$(HZ_PNG)/$(s)-full-dark.png)

$(SQ_PNG)/square-animated.gif $(SQ_PNG)/square-animated.webp &: $(_SQ_FRAMES) | build
	@mkdir -p $(SQ_PNG)
	$(_ANIMATE) $(foreach f,$(_SQ_FRAMES),--input $(f)) --gif-out $(SQ_PNG)/square-animated.gif --webp-out $(SQ_PNG)/square-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-animated.gif $(HZ_PNG)/horizontal-animated.webp &: $(_HZ_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_HZ_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-animated.gif --webp-out $(HZ_PNG)/horizontal-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-full-animated.gif $(HZ_PNG)/horizontal-full-animated.webp &: $(_HZ_FULL_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_HZ_FULL_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-full-animated.gif --webp-out $(HZ_PNG)/horizontal-full-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-full-dark-animated.gif $(HZ_PNG)/horizontal-full-dark-animated.webp &: $(_HZ_DARK_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_HZ_DARK_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-full-dark-animated.gif --webp-out $(HZ_PNG)/horizontal-full-dark-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-full-bold-animated.gif $(HZ_PNG)/horizontal-full-bold-animated.webp &: $(_HZ_BOLD_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_HZ_BOLD_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-full-bold-animated.gif --webp-out $(HZ_PNG)/horizontal-full-bold-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-full-dark-bold-animated.gif $(HZ_PNG)/horizontal-full-dark-bold-animated.webp &: $(_HZ_DARK_BOLD_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_HZ_DARK_BOLD_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-full-dark-bold-animated.gif --webp-out $(HZ_PNG)/horizontal-full-dark-bold-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-rainbow-animated.gif $(HZ_PNG)/horizontal-rainbow-animated.webp &: $(_RB_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_RB_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-rainbow-animated.gif --webp-out $(HZ_PNG)/horizontal-rainbow-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-rainbow-full-animated.gif $(HZ_PNG)/horizontal-rainbow-full-animated.webp &: $(_RB_FULL_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_RB_FULL_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-rainbow-full-animated.gif --webp-out $(HZ_PNG)/horizontal-rainbow-full-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-rainbow-full-dark-animated.gif $(HZ_PNG)/horizontal-rainbow-full-dark-animated.webp &: $(_RB_DARK_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_RB_DARK_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-rainbow-full-dark-animated.gif --webp-out $(HZ_PNG)/horizontal-rainbow-full-dark-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-skintone-animated.gif $(HZ_PNG)/horizontal-skintone-animated.webp &: $(_SC_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_SC_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-skintone-animated.gif --webp-out $(HZ_PNG)/horizontal-skintone-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-skintone-full-animated.gif $(HZ_PNG)/horizontal-skintone-full-animated.webp &: $(_SC_FULL_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_SC_FULL_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-skintone-full-animated.gif --webp-out $(HZ_PNG)/horizontal-skintone-full-animated.webp --anim-ms $(ANIM_MS)

$(HZ_PNG)/horizontal-skintone-full-dark-animated.gif $(HZ_PNG)/horizontal-skintone-full-dark-animated.webp &: $(_SC_DARK_FRAMES) | build
	@mkdir -p $(HZ_PNG)
	$(_ANIMATE) $(foreach f,$(_SC_DARK_FRAMES),--input $(f)) --gif-out $(HZ_PNG)/horizontal-skintone-full-dark-animated.gif --webp-out $(HZ_PNG)/horizontal-skintone-full-dark-animated.webp --anim-ms $(ANIM_MS)


ALL_ANIMATIONS := \
  $(SQ_PNG)/square-animated.gif $(SQ_PNG)/square-animated.webp \
  $(HZ_PNG)/horizontal-animated.gif $(HZ_PNG)/horizontal-animated.webp \
  $(HZ_PNG)/horizontal-full-animated.gif $(HZ_PNG)/horizontal-full-animated.webp \
  $(HZ_PNG)/horizontal-full-dark-animated.gif $(HZ_PNG)/horizontal-full-dark-animated.webp \
  $(HZ_PNG)/horizontal-full-bold-animated.gif $(HZ_PNG)/horizontal-full-bold-animated.webp \
  $(HZ_PNG)/horizontal-full-dark-bold-animated.gif $(HZ_PNG)/horizontal-full-dark-bold-animated.webp \
  $(HZ_PNG)/horizontal-rainbow-animated.gif $(HZ_PNG)/horizontal-rainbow-animated.webp \
  $(HZ_PNG)/horizontal-rainbow-full-animated.gif $(HZ_PNG)/horizontal-rainbow-full-animated.webp \
  $(HZ_PNG)/horizontal-rainbow-full-dark-animated.gif $(HZ_PNG)/horizontal-rainbow-full-dark-animated.webp \
  $(HZ_PNG)/horizontal-skintone-animated.gif $(HZ_PNG)/horizontal-skintone-animated.webp \
  $(HZ_PNG)/horizontal-skintone-full-animated.gif $(HZ_PNG)/horizontal-skintone-full-animated.webp \
  $(HZ_PNG)/horizontal-skintone-full-dark-animated.gif $(HZ_PNG)/horizontal-skintone-full-dark-animated.webp

# ── brand-gen: design-guide.json + JSON-LD + Elm tokens + brand.css ──────────

design-guide.json src/Guide/Tokens.elm public/brand.css &: $(HS_SOURCES) | build
	$(CABAL) run --offline brand-gen -- \
	  --elm-tokens-out src/Guide/Tokens.elm \
	  --css-out public/brand.css

# ── Text outlining (post-process full composed SVGs) ─────────────────────────
ALL_FULL_SVGS := $(foreach s,$(HZ_STEMS),$(HZ_SVG)/$(s)-full.svg $(HZ_SVG)/$(s)-full-dark.svg $(HZ_SVG)/$(s)-full-bold.svg $(HZ_SVG)/$(s)-full-dark-bold.svg) \
  $(SQ_SVG)/square-smile-full.svg $(SQ_SVG)/square-smile-full-dark.svg \
  $(SQ_SVG)/square-smile-full-bold.svg $(SQ_SVG)/square-smile-full-dark-bold.svg

outline-text: $(ALL_FULL_SVGS) ## Outline subtitle text in composed horizontal SVGs
	python3 scripts/text_to_path.py '$(FONT_PATH)' $(ALL_FULL_SVGS)

# ── render: all static logo assets ───────────────────────────────────────────

render: $(ALL_SQ_OUTPUTS) $(ALL_HZ_OUTPUTS) $(ALL_ANIMATIONS) design-guide.json favicon/favicon.ico ## Render all .blay files to logo/, favicon/, tokens

# ── elm-pages site ────────────────────────────────────────────────────────────

ELM_TAILWIND_GEN := node_modules/.bin/elm-tailwind-classes gen

install: ## Install pnpm deps and resolve Elm packages (run once after checkout)
	pnpm install
	$(ELM_TAILWIND_GEN)

assets-from-blay: assets ## CI alias: render .blay files then copy assets to public/

assets: render ## Copy generated assets into public/ for elm-pages
	rm -rf public/logo public/favicon public/fonts public/design-guide.json public/design-guide
	cp -r logo favicon fonts design-guide.json design-guide public/

site: assets ## Production build: pipeline -> copy assets -> elm-pages build -> dist/
	$(ELM_TAILWIND_GEN)
	chmod -R u+w .elm-pages/ elm-stuff/elm-pages/ 2>/dev/null || true
	elm-pages build

deploy: ## Push main branch to trigger GitHub Actions deploy
	git push origin main

# ── Testing & linting ─────────────────────────────────────────────────────────

test: ## Run Haskell test suite and hlint
	$(CABAL) test --offline
	$(MAKE) check

check: ## Run hlint static analysis and elm-review
	hlint src tests
	elm-review

cabal-check: ## Check the package for common errors
	$(CABAL) check

format: ## Auto-format Haskell and Elm source files
	find src app -name '*.hs' | xargs fourmolu --mode inplace
	elm-format --yes app/ src/Component/ src/Guide/Colors.elm src/Guide/Logos.elm

# ── Watching ──────────────────────────────────────────────────────────────────

watch: assets ## elm-pages dev server only (assumes assets already in public/)
	$(ELM_TAILWIND_GEN)
	chmod -R u+w .elm-pages/ elm-stuff/elm-pages/ 2>/dev/null || true
	elm-pages dev

watch-hs: ## Re-run render on .hs/.cabal changes (requires entr)
	find src app tests -name '*.hs' -o -name '*.cabal' | entr -r $(MAKE) render

# ── REPL ──────────────────────────────────────────────────────────────────────

repl: ## Open GHCi REPL
	$(CABAL) repl --offline

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean: ## Remove all generated files, build artifacts, and dist/
	$(CABAL) clean
	rm -rf logo/ favicon/ design-guide.json design-guide/ __pycache__
	rm -rf dist/ .elm-pages/ .elm-tailwind/
	rm -f src/Guide/Tokens.elm
	rm -rf public/design-guide.json public/design-guide public/logo public/favicon public/fonts

# ── Devenv ────────────────────────────────────────────────────────────────────

develop: devenv.local.nix devenv.local.yaml ## Bootstrap devenv shell + VS Code
	devenv shell --profile=devcontainer -- code .

shell: ## Enter devenv shell
	devenv shell

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml
