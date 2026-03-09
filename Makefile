.PHONY: help all build run assets site dev dev-watch deploy install test check clean watch watch-elm repl develop shell

# When elm-pages comes from the Nix store the wrapper does not include the
# package's own node_modules/.bin (elm-optimize-level-2, etc.) in PATH.
# Detect the store root from the resolved elm-pages binary and prepend it.
_ELM_PAGES_BIN  := $(shell which elm-pages 2>/dev/null)
_ELM_PAGES_ROOT := $(shell readlink -f $(_ELM_PAGES_BIN) 2>/dev/null | xargs -I{} dirname {} | xargs -I{} dirname {} 2>/dev/null)
ifneq ($(_ELM_PAGES_ROOT),)
export PATH := $(_ELM_PAGES_ROOT)/lib/node_modules/.bin:$(PATH)
endif

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: site ## Build everything: Haskell pipeline → assets → elm-pages → dist/

# ── Haskell pipeline ─────────────────────────────────────────────────────────

build: ## Compile Haskell executable (no run)
	cabal build

run: ## Haskell pipeline: generate logo/, favicon/, brand.json, Brand.Generated.elm
	cabal run logo-gen

# ── elm-pages site ────────────────────────────────────────────────────────────

install: ## Install npm deps and resolve Elm packages (run once after checkout)
	npm install

assets: run ## Copy generated assets into public/ for elm-pages
	cp -r logo favicon fonts brand.json public/

dev: assets ## Dev server: pipeline → copy assets → elm-pages dev (hot reload)
	elm-pages dev

site: assets ## Production build: pipeline → copy assets → elm-pages build → dist/
	elm-pages build

deploy: ## Push main branch to trigger GitHub Actions deploy
	git push origin main

# ── Testing & linting ─────────────────────────────────────────────────────────

test: ## Run Haskell test suite and hlint
	cabal test
	$(MAKE) check

check: ## Run hlint static analysis
	hlint src tests

# ── Watching ──────────────────────────────────────────────────────────────────

dev-watch: assets ## Build all static assets, then watch with elm-pages dev (hot reload)
	elm-pages dev

watch: ## Re-run Haskell pipeline on .hs source changes (requires entr)
	find src -name '*.hs' | entr -r cabal run logo-gen

watch-elm: ## elm-pages dev server only (assumes assets already in public/)
	elm-pages dev

# ── REPL ──────────────────────────────────────────────────────────────────────

repl: ## Open GHCi REPL
	cabal repl

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
