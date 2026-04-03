.PHONY: help all build assets site dev dev-watch deploy install test check format clean watch repl develop shell

# ── PATH trimming (prevents E2BIG when cabal spawns GHC) ─────────────────────
_GHC_BIN   := $(shell dirname $(shell which ghc   2>/dev/null) 2>/dev/null)
_CABAL_BIN := $(shell dirname $(shell which cabal 2>/dev/null) 2>/dev/null)
_SLIM_PATH := $(_GHC_BIN):$(_CABAL_BIN):/usr/bin:/bin
CABAL      := env PATH="$(_SLIM_PATH)" cabal

HS_SOURCES := $(shell find src app -name '*.hs') logo.cabal $(wildcard cabal.project*)

# ── Phony help ────────────────────────────────────────────────────────────────

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

all: site ## Build everything: Haskell -> assets -> elm-pages -> dist/

# ── Haskell ───────────────────────────────────────────────────────────────────

build: ## Compile all Haskell executables (no run)
	$(CABAL) build --offline

# ── brand-gen: design-guide.tokens.json + JSON-LD + Elm tokens + brand.css ────

design-guide.tokens.json src/Guide/Tokens.elm public/brand.css &: $(HS_SOURCES) design-guide.toml | build
	$(CABAL) run --offline brand-gen -- \
	  --elm-tokens-out src/Guide/Tokens.elm \
	  --css-out public/brand.css

# ── elm-pages site ────────────────────────────────────────────────────────────

ELM_TAILWIND_GEN := node_modules/.bin/elm-tailwind-classes gen
ELM_PAGES        ?= elm-pages

install: ## Install pnpm deps and resolve Elm packages (run once after checkout)
	pnpm install
	$(ELM_TAILWIND_GEN)

assets: ## Copy generated assets into public/ for elm-pages
	$(CABAL) run --offline brand-gen -- \
	  --elm-tokens-out src/Guide/Tokens.elm \
	  --css-out public/brand.css
	rm -rf public/fonts public/design-guide.tokens.json public/design-guide
	cp -r fonts design-guide.tokens.json design-guide public/

site: assets ## Production build: pipeline -> copy assets -> elm-pages build -> dist/
	$(ELM_TAILWIND_GEN)
	chmod -R u+w .elm-pages/ elm-stuff/elm-pages/ 2>/dev/null || true
	$(ELM_PAGES) build

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
	elm-format --yes app/ src/Component/

# ── Watching ──────────────────────────────────────────────────────────────────

watch: assets ## elm-pages dev server only (assumes assets already in public/)
	$(ELM_TAILWIND_GEN)
	chmod -R u+w .elm-pages/ elm-stuff/elm-pages/ 2>/dev/null || true
	$(ELM_PAGES) dev

# ── REPL ──────────────────────────────────────────────────────────────────────

repl: ## Open GHCi REPL
	$(CABAL) repl --offline

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean: ## Remove all generated files, build artifacts, and dist/
	$(CABAL) clean
	rm -rf design-guide.json design-guide.tokens.json design-guide/ __pycache__
	rm -rf dist/ .elm-pages/ .elm-tailwind/
	rm -f src/Guide/Tokens.elm
	rm -rf public/design-guide.json public/design-guide.tokens.json public/design-guide public/fonts

# ── Devenv ────────────────────────────────────────────────────────────────────

develop: devenv.local.nix devenv.local.yaml ## Bootstrap devenv shell + VS Code
	devenv shell --profile=devcontainer -- code .

shell: ## Enter devenv shell
	devenv shell

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml

