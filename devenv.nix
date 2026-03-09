{ pkgs, ... }:
let
  hsPkgs = pkgs.haskell.packages.ghc96;

  # Build the project as a proper Nix derivation via cabal2nix.
  # developPackage reads logo.cabal and resolves every dep from the Nix store —
  # no Hackage access, no cabal store, no ARG_MAX blowups.
  logoDrv = hsPkgs.developPackage {
    root = pkgs.lib.cleanSource ./.;
    modifier = drv: pkgs.haskell.lib.addBuildTools drv (with hsPkgs; [
      cabal-install
      haskell-language-server
      hlint
      fourmolu
    ]);
  };

  elm-pages = pkgs.callPackage ./elm-pages.nix {
    lamdera = pkgs.elmPackages.lamdera;
  };
in {
  profiles.shell.module = {
    languages.elm.enable = true;

    # logoDrv.nativeBuildInputs / buildInputs carry GHC (with all project deps
    # pre-registered in a unified package-db) plus the modifier build tools.
    # In older nixpkgs these were accessed via logoDrv.env.*; newer nixpkgs
    # exposes them directly on the derivation.
    packages =
      logoDrv.nativeBuildInputs
      ++ logoDrv.buildInputs
      ++ [
        pkgs.claude-code
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
      ];

    enterShell = ''
      git --version
      cabal --version
      elm-pages --version
    '';
  };
}
