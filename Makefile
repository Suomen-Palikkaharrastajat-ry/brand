.PHONY: help all build run assets site dev dev-watch deploy install test check clean watch watch-elm repl develop shell

# When elm-pages comes from the Nix store the wrapper does not include the
# package's own node_modules/.bin (elm-optimize-level-2, etc.) in PATH.
# Detect the store root from the resolved elm-pages binary and prepend it.
_ELM_PAGES_BIN  := $(shell which elm-pages 2>/dev/null)
_ELM_PAGES_ROOT := $(shell readlink -f $(_ELM_PAGES_BIN) 2>/dev/null | xargs -I{} dirname {} | xargs -I{} dirname {} 2>/dev/null)
ifneq ($(_ELM_PAGES_ROOT),)
export PATH := $(_ELM_PAGES_ROOT)/lib/node_modules/.bin:$(PATH)
endif

# ── Pipeline constants ────────────────────────────────────────────────────────
# These are the single documented source of truth for all tunable parameters.
# Changing any value here invalidates logo/.stamp and triggers regeneration.
# They are forwarded verbatim as CLI flags to logo-gen, so no Haskell rebuild
# is needed when you change them.

SOURCE_SVG   := source.svg
FONT_PATH    := fonts/Outfit-VariableFont_wght.ttf

SQ_PX        := 14          # Square blockify target raster width (px)
HZ_PX        := 62          # Horizontal blockify target raster width (px)
BLK_W        := 24          # Brick SVG unit width
BLK_H        := 20          # Brick SVG unit height
PAD          := 1           # Transparent column padding each side
SQ_PAD_V     := 20          # Vertical padding for square logos
HZ_PAD_TOP   := 20          # Top padding for horizontal logos
TXT_SIZE     := 57          # Subtitle font size (SVG units)
ANIM_MS      := 10000       # Animation frame duration (ms)
RASTER_W     := 800         # PNG/WebP export width (px)

LOGO_GEN_ARGS := \
  --source     $(SOURCE_SVG) \
  --font-path  $(FONT_PATH) \
  --sq-px      $(SQ_PX) \
  --hz-px      $(HZ_PX) \
  --blk-w      $(BLK_W) \
  --blk-h      $(BLK_H) \
  --pad        $(PAD) \
  --sq-pad-v   $(SQ_PAD_V) \
  --hz-pad-top $(HZ_PAD_TOP) \
  --txt-size   $(TXT_SIZE) \
  --anim-ms    $(ANIM_MS) \
  --raster-w   $(RASTER_W)

# Haskell source files – stamp depends on these so code changes also invalidate it
HS_SOURCES := $(shell find src app -name '*.hs') logo.cabal

LOGO_STAMP := logo/.stamp

# ── Targets ───────────────────────────────────────────────────────────────────

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: site ## Build everything: Haskell pipeline → assets → elm-pages → dist/

# ── Haskell pipeline ─────────────────────────────────────────────────────────

build: ## Compile Haskell executable (no run)
	cabal build --offline

# Incremental: only re-runs logo-gen when source.svg, fonts/, Haskell source,
# or any constant in this Makefile has changed.
$(LOGO_STAMP): $(SOURCE_SVG) $(FONT_PATH) $(HS_SOURCES) Makefile
	cabal build --offline
	cabal run --offline logo-gen -- $(LOGO_GEN_ARGS)
	@mkdir -p logo
	touch $(LOGO_STAMP)

run: $(LOGO_STAMP) ## Haskell pipeline: generate logo/, favicon/, brand.json, Brand.Generated.elm (incremental)

run-force: ## Force-run logo-gen regardless of stamp
	cabal run --offline logo-gen -- $(LOGO_GEN_ARGS)

# ── elm-pages site ────────────────────────────────────────────────────────────

install: ## Install npm deps and resolve Elm packages (run once after checkout)
	npm install

assets: run ## Copy generated assets into public/ for elm-pages
	rm -rf public/logo public/favicon public/fonts public/brand.json
	cp -r logo favicon fonts brand.json public/

dev: assets ## Dev server: pipeline → copy assets → elm-pages dev (hot reload)
	elm-pages dev

site: assets ## Production build: pipeline → copy assets → elm-pages build → dist/
	elm-pages build

deploy: ## Push main branch to trigger GitHub Actions deploy
	git push origin main

# ── Testing & linting ─────────────────────────────────────────────────────────

test: ## Run Haskell test suite and hlint
	cabal test --offline
	$(MAKE) check

check: ## Run hlint static analysis
	hlint src tests

# ── Watching ──────────────────────────────────────────────────────────────────

dev-watch: assets ## Build all static assets, then watch with elm-pages dev (hot reload)
	elm-pages dev

watch: ## Re-run Haskell pipeline on .hs/.cabal changes (requires entr)
	find src app tests -name '*.hs' -o -name '*.cabal' | entr -r cabal run --offline logo-gen -- $(LOGO_GEN_ARGS)

watch-elm: ## elm-pages dev server only (assumes assets already in public/)
	elm-pages dev

# ── REPL ──────────────────────────────────────────────────────────────────────

repl: ## Open GHCi REPL
	cabal repl --offline

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean: ## Remove all generated files, build artifacts, and dist/
	cabal clean
	rm -rf design/ logo/ favicon/ brand.json __pycache__
	rm -rf dist/ .elm-pages/
	rm -f src/Brand/Generated.elm
	rm -rf public/brand.json public/logo public/favicon public/fonts

# ── Devenv ────────────────────────────────────────────────────────────────────

develop: devenv.local.nix devenv.local.yaml ## Bootstrap devenv shell + VS Code
	devenv shell --profile=devcontainer -- code .

shell: ## Enter devenv shell
	devenv shell

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml
