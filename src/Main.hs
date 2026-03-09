module Main where

import Brand.Colors (darkBg)
import Brand.ElmGen (generateBrandModule)
import Brand.Json (generateBrandJson)
import Control.Monad (forM_)
import Logo.Animate (assembleGif, assembleWebp)
import Logo.Blockify (blockifySvg)
import Logo.Compose (composeLogo)
import Logo.Designs (generateAllDesigns)
import Logo.Favicons (generateFavicons)
import Logo.Raster (exportPng, exportWebp)
import System.Directory (createDirectoryIfMissing)
import qualified Data.Text.IO as TIO

-- ── Build parameters ────────────────────────────────────────────────────────
sqPx, hzPx, blkW, blkH, pad, txtSize, animMs :: Int
sqPx = 14
hzPx = 62
blkW = 24
blkH = 20
pad = 1
txtSize = 57
animMs = 10000

-- Vertical padding in SVG pixels
sqPadV, hzPadTop :: Int
sqPadV   = 20  -- added to both top and bottom of square logos
hzPadTop = 20  -- added to top of horizontal logos

-- ── Directory constants ──────────────────────────────────────────────────────
designDir, sqSvgDir, hzSvgDir, sqPngDir, hzPngDir :: FilePath
designDir = "design"
sqSvgDir = "logo/square/svg"
hzSvgDir = "logo/horizontal/svg"
sqPngDir = "logo/square/png"
hzPngDir = "logo/horizontal/png"

main :: IO ()
main = do
    -- 1. Create output directories
    mapM_
        (createDirectoryIfMissing True)
        [designDir, sqSvgDir, hzSvgDir, sqPngDir, hzPngDir]

    -- 2. Generate design SVGs from source.svg
    putStrLn "==> designs"
    generateAllDesigns designDir

    -- 3. Blockify: design SVGs → brick-art SVGs
    putStrLn "==> logos (blockify)"

    -- Square variants
    forM_ squareVariants $ \stem ->
        blockifySvg
            (designDir ++ "/" ++ stem ++ ".svg")
            (sqSvgDir ++ "/" ++ stem ++ ".svg")
            sqPx blkW blkH pad sqPadV sqPadV

    -- Horizontal variants
    forM_ horizontalVariants $ \stem ->
        blockifySvg
            (designDir ++ "/" ++ stem ++ ".svg")
            (hzSvgDir ++ "/" ++ stem ++ ".svg")
            hzPx blkW blkH pad hzPadTop 0

    -- 4. Compose: add subtitle text to horizontal variants
    putStrLn "==> compose (add subtitle)"
    forM_ horizontalVariants $ \stem -> do
        -- Light variant
        composeLogo
            (hzSvgDir ++ "/" ++ stem ++ ".svg")
            (hzSvgDir ++ "/" ++ stem ++ "-full.svg")
            txtSize
            Nothing
        -- Dark variant
        composeLogo
            (hzSvgDir ++ "/" ++ stem ++ ".svg")
            (hzSvgDir ++ "/" ++ stem ++ "-full-dark.svg")
            txtSize
            (Just darkBg)

    -- 5. Export all SVGs to PNG + WebP at 800px
    putStrLn "==> raster (PNG + WebP)"
    forM_ allSvgs $ \(svgDir, stem) -> do
        let svg = svgDir ++ "/" ++ stem ++ ".svg"
            pngDir = if svgDir == sqSvgDir then sqPngDir else hzPngDir
        exportPng svg (pngDir ++ "/" ++ stem ++ ".png") 800
        exportWebp svg (pngDir ++ "/" ++ stem ++ ".webp") 800

    -- 6. Animated GIF + WebP
    putStrLn "==> animate (GIF + WebP)"

    -- Square animated (skin tones)
    let sqAnimFrames = map (\s -> sqPngDir ++ "/" ++ s ++ ".png") squareSkinTones
    assembleGif sqAnimFrames (sqPngDir ++ "/square-animated.gif") animMs
    assembleWebp sqAnimFrames (sqPngDir ++ "/square-animated.webp") animMs

    -- Horizontal animated (skin tones, logo-only)
    let hzAnimFrames = map (\s -> hzPngDir ++ "/" ++ s ++ ".png") horizontalSkinTones
    assembleGif hzAnimFrames (hzPngDir ++ "/horizontal-animated.gif") animMs
    assembleWebp hzAnimFrames (hzPngDir ++ "/horizontal-animated.webp") animMs

    -- Horizontal-full animated (skin tones, with subtitle, light)
    let hzFullAnimFrames = map (\s -> hzPngDir ++ "/" ++ s ++ "-full.png") horizontalSkinTones
    assembleGif hzFullAnimFrames (hzPngDir ++ "/horizontal-full-animated.gif") animMs
    assembleWebp hzFullAnimFrames (hzPngDir ++ "/horizontal-full-animated.webp") animMs

    -- Horizontal-full-dark animated (skin tones, with subtitle, dark)
    let hzFullDarkFrames = map (\s -> hzPngDir ++ "/" ++ s ++ "-full-dark.png") horizontalSkinTones
    assembleGif hzFullDarkFrames (hzPngDir ++ "/horizontal-full-dark-animated.gif") animMs
    assembleWebp hzFullDarkFrames (hzPngDir ++ "/horizontal-full-dark-animated.webp") animMs

    -- Horizontal-rainbow animated (7 rainbow rotations)
    let hzRbFrames = map (\s -> hzPngDir ++ "/" ++ s ++ ".png") rainbowHzVariants
    assembleGif hzRbFrames (hzPngDir ++ "/horizontal-rainbow-animated.gif") animMs
    assembleWebp hzRbFrames (hzPngDir ++ "/horizontal-rainbow-animated.webp") animMs

    -- Horizontal-rainbow-full animated (light)
    let hzRbFullFrames = map (\s -> hzPngDir ++ "/" ++ s ++ "-full.png") rainbowHzVariants
    assembleGif hzRbFullFrames (hzPngDir ++ "/horizontal-rainbow-full-animated.gif") animMs
    assembleWebp hzRbFullFrames (hzPngDir ++ "/horizontal-rainbow-full-animated.webp") animMs

    -- Horizontal-rainbow-full-dark animated
    let hzRbFullDarkFrames = map (\s -> hzPngDir ++ "/" ++ s ++ "-full-dark.png") rainbowHzVariants
    assembleGif hzRbFullDarkFrames (hzPngDir ++ "/horizontal-rainbow-full-dark-animated.gif") animMs
    assembleWebp hzRbFullDarkFrames (hzPngDir ++ "/horizontal-rainbow-full-dark-animated.webp") animMs

    -- 7. Favicons
    putStrLn "==> favicons"
    generateFavicons

    -- 8. Brand manifest
    putStrLn "==> brand.json"
    generateBrandJson

    -- 9. Elm codegen (Brand.Generated)
    putStrLn "==> elm codegen (Brand.Generated)"
    let elmBrandSrc = "src/Brand"
    createDirectoryIfMissing True elmBrandSrc
    TIO.writeFile (elmBrandSrc <> "/Generated.elm") generateBrandModule
    putStrLn "Wrote src/Brand/Generated.elm"

    putStrLn "Done."

-- ── File lists ───────────────────────────────────────────────────────────────

squareSkinTones :: [String]
squareSkinTones = ["square", "square-light-nougat", "square-nougat", "square-dark-nougat"]

squareVariants :: [String]
squareVariants =
    squareSkinTones
        ++ ["minifig-colorful", "minifig-rainbow"]

horizontalSkinTones :: [String]
horizontalSkinTones = ["horizontal", "horizontal-rot1", "horizontal-rot2", "horizontal-rot3"]

rainbowHzVariants :: [String]
rainbowHzVariants =
    "horizontal-rainbow"
        : ["horizontal-rainbow-rot" ++ show i | i <- [1 .. 6 :: Int]]

horizontalVariants :: [String]
horizontalVariants = horizontalSkinTones ++ rainbowHzVariants

-- All SVGs to rasterize: (svgDir, stem)
allSvgs :: [(FilePath, String)]
allSvgs =
    [(sqSvgDir, s) | s <- squareVariants]
        ++ [(hzSvgDir, s) | s <- horizontalVariants]
        ++ [(hzSvgDir, s ++ "-full") | s <- horizontalVariants]
        ++ [(hzSvgDir, s ++ "-full-dark") | s <- horizontalVariants]
