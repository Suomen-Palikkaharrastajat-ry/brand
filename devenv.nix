{ pkgs, ... }:
let
  hsPkgs = pkgs.haskell.packages.ghc96;
  shell =
    { pkgs, ... }:
    {
      # https://devenv.sh/languages/
      languages.elm.enable = true;
      languages.haskell.enable = true;
      # ghcWithPackages pre-compiles all library deps into the GHC package DB so
      # cabal can resolve them with --offline (no Hackage access needed at build time).
      languages.haskell.package = pkgs.haskell.packages.ghc96.ghcWithPackages (
        ps: with ps; [
          xml-conduit
          aeson
          aeson-pretty
          JuicyPixels
          vector
          base64-bytestring
          temporary
          tasty
          tasty-hunit
          tasty-quickcheck
        ]
      );

      packages = [
        hsPkgs.hlint
        hsPkgs.fourmolu
        # External raster/image tools (called via System.Process)
        pkgs.librsvg # provides rsvg-convert
        pkgs.libwebp # provides cwebp, img2webp
        pkgs.gifski # animated GIF
        pkgs.icoutils # provides icotool (favicon.ico)
        pkgs.imagemagick # fallback for animated WebP (convert)
        pkgs.git
        pkgs.treefmt
        # Elm tooling
        pkgs.nodejs
        pkgs.pnpm
        pkgs.elmPackages.elm-format
        pkgs.elmPackages.elm-review
        pkgs.elmPackages.elm-test
        pkgs.elmPackages.elm-json
        pkgs.elmPackages.lamdera
        (pkgs.callPackage ./elm-pages.nix {
          lamdera = pkgs.elmPackages.lamdera;
        })
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
        echo "  make watch    — pipeline + hot-reload site"
        echo "  make render   — regenerate all logo assets"
        echo ""
      '';
    };
in
{
  profiles.shell.module = {
    imports = [ shell ];
  };

  dotenv.disableHint = true;
}
