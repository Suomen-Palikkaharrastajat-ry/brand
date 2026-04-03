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
          toml-parser
          temporary
          tasty
          tasty-hunit
          tasty-quickcheck
        ]
      );

      packages = [
        hsPkgs.hlint
        hsPkgs.fourmolu
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
        pkgs.vim
      ];

      enterShell = ''
        echo ""
        echo "── logo dev environment ─────────────────────────────"
        echo "  GHC:       $(ghc --version)"
        echo "  Cabal:     $(cabal --version | head -1)"
        echo "  Elm:       $(elm --version)"
        echo "  elm-pages: $(elm-pages --version)"
        echo ""
        echo "  make assets   — run brand-gen + copy assets"
        echo "  make site     — full build to dist/"
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
