{ pkgs, ... }:
let
  hsPkgs = pkgs.haskell.packages.ghc96;

  elm-pages = pkgs.callPackage ./elm-pages.nix {
    lamdera = pkgs.elmPackages.lamdera;
  };
in {
  profiles.shell.module = {
    languages.elm.enable = true;
    languages.haskell.enable = true;
    languages.haskell.package = pkgs.haskell.packages.ghc96.ghc;

    dotenv.enable = true;

    packages = [
      hsPkgs.hlint
      hsPkgs.fourmolu
      # External raster/image tools (called via System.Process)
      pkgs.librsvg       # provides rsvg-convert
      pkgs.libwebp       # provides cwebp, img2webp
      pkgs.gifski        # animated GIF
      pkgs.icoutils      # provides icotool (favicon.ico)
      pkgs.imagemagick   # fallback for animated WebP (convert)
      pkgs.git
      pkgs.treefmt
      # Elm tooling
      pkgs.nodejs
      pkgs.elmPackages.elm-format
      pkgs.elmPackages.elm-review
      pkgs.elmPackages.elm-test
      pkgs.elmPackages.elm-json
      pkgs.elmPackages.lamdera
      elm-pages
      # Other CLI tools
      pkgs.entr
      pkgs.vim
      # Python with fontTools for SVG text-to-path conversion
      (pkgs.python3.withPackages (ps: [ ps.fonttools ]))
    ];

    enterShell = ''
      echo ""
      echo "── logo dev environment ─────────────────────────────"
      echo "  GHC:       $(ghc --version)"
      echo "  Cabal:     $(cabal --version | head -1)"
      echo "  Elm:       $(elm --version)"
      echo "  elm-pages: $(elm-pages --version)"
      echo "  rsvg:      $(rsvg-convert --version | head -1)"
      echo ""
      echo "  make dev      — pipeline + hot-reload site"
      echo "  make render   — regenerate all logo assets"
      echo ""
    '';
  };
}
