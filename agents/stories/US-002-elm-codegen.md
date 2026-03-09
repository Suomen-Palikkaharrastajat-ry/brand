# US-002: Haskell generates Elm brand constants

As a developer building the elm-pages site,
I want brand constants (colors, name, base URL) available as
type-safe Elm values at compile time,
so that I do not need runtime JSON decoders for stable brand data.

## Acceptance criteria

- `cabal run logo-gen` writes `src/Brand/Generated.elm`
- The generated file exports `associationName`, `featureColor`,
  `highlightColor`, `darkBackground`, `logoBaseUrl`, `skinTones`,
  `rainbowColors`
- `elm make` succeeds with the generated file in place
- `make dev` generates the file before starting elm-pages dev server
- `src/Brand/Generated.elm` is in `.gitignore`

## Implementation

`Brand.ElmGen.generateBrandModule :: Text` emits the complete Elm source
as a `Text` value by concatenating lines with `T.unlines`. No ADT, no
intermediate representation — mirrors planet's `ElmGen.hs` approach.

`Main.hs` calls `TIO.writeFile "src/Brand/Generated.elm" generateBrandModule`
after all other pipeline steps (step 9).

## Out of scope

- Generating the full logo variant list (use brand.json BackendTask for that)
- Design tokens / spacing constants (future work)
