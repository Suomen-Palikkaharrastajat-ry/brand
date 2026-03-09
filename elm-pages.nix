# elm-pages CLI packaged via Nix, using the project's own package-lock.json
# so the version is always in sync with package.json.
#
# The derivation installs npm deps in the Nix sandbox (--ignore-scripts skips
# elm-tooling and other postinstall steps that require network access) and
# wraps the resulting elm-pages binary to ensure the Nix-packaged lamdera is
# always found first on PATH.
#
# How to update npmDepsHash after changing package-lock.json:
#   1. Set npmDepsHash = pkgs.lib.fakeHash; below
#   2. Run `devenv shell` — the build will fail with the correct sha256
#   3. Paste that sha256 here
{ pkgs, lamdera }:
let
  # Strip the postinstall script from package.json so that elm-tooling does not
  # run during the Nix npm-deps fetch (it needs network + elm-tooling.json).
  # elm / elm-format come from Nix packages instead.
  patchedSrc = pkgs.runCommand "elm-pages-npm-src" { nativeBuildInputs = [ pkgs.jq ]; } ''
    mkdir $out
    jq 'del(.scripts.postinstall)' ${./package.json} > $out/package.json
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
pkgs.buildNpmPackage {
  pname = "elm-pages";
  version = "3.1.5";

  src = patchedSrc;

  # Computed by building with pkgs.lib.fakeHash and reading the "got:" line.
  # To update after changing package-lock.json: set back to pkgs.lib.fakeHash,
  # run `devenv shell` (or the nix build command in the comment below), then
  # replace this value with the sha256 printed in the error output.
  #   nix build --impure --expr \
  #     'let p=(builtins.getFlake "nixpkgs").legacyPackages.x86_64-linux;
  #      in p.callPackage ./nix/elm-pages.nix {lamdera=p.elmPackages.lamdera;}' \
  #     2>&1 | grep "got:"
  npmDepsHash = "sha256-ljlPBe9aWVgf9Oy/OJsHz2K30AmHO12kkbgIH6CBY7c=";

  # Skip postinstall scripts:
  #   - elm-tooling install  (elm / elm-format come from Nix)
  #   - any native binary download steps (esbuild/rollup ship prebuilt in npm)
  npmInstallFlags = [ "--ignore-scripts" ];

  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r node_modules $out/lib/

    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/elm-pages \
      --add-flags "$out/lib/node_modules/elm-pages/generator/src/cli.js" \
      --prefix PATH : "$out/lib/node_modules/.bin" \
      --prefix PATH : ${lamdera}/bin

    runHook postInstall
  '';
}
