module Main where

import Brand.Colors (darkBg)
import Brand.ElmGen (generateBrandModule)
import Brand.Json (generateBrandJson)
import Control.Monad (forM_)
import Logo.Animate (assembleGif, assembleWebp)
import Logo.Blockify (blockifySvg)
import Logo.Compose (composeLogo)
import Logo.Config (Config (..), parseConfig)
import Logo.Designs (generateAllDesigns)
import Logo.Favicons (generateFavicons)
import Logo.Raster (exportPng, exportWebp)
import System.Directory (createDirectoryIfMissing)
import qualified Data.Text.IO as TIO

main :: IO ()
main = do
    cfg <- parseConfig

    let sqSvg  = cfgSqSvgDir cfg
        hzSvg  = cfgHzSvgDir cfg
        sqPng  = cfgSqPngDir cfg
        hzPng  = cfgHzPngDir cfg
        dDir   = cfgDesignDir cfg

    -- 1. Create output directories
    mapM_
        (createDirectoryIfMissing True)
        [dDir, sqSvg, hzSvg, sqPng, hzPng]

    -- 2. Generate design SVGs from source.svg
    putStrLn "==> designs"
    generateAllDesigns (cfgSourceSvg cfg) dDir

    -- 3. Blockify: design SVGs → brick-art SVGs
    putStrLn "==> logos (blockify)"

    -- Square variants
    forM_ squareVariants $ \stem ->
        blockifySvg
            (dDir ++ "/" ++ stem ++ ".svg")
            (sqSvg ++ "/" ++ stem ++ ".svg")
            (cfgSqPx cfg) (cfgBlkW cfg) (cfgBlkH cfg)
            (cfgPad cfg) (cfgSqPadV cfg) (cfgSqPadV cfg)

    -- Horizontal variants
    forM_ horizontalVariants $ \stem ->
        blockifySvg
            (dDir ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (cfgHzPx cfg) (cfgBlkW cfg) (cfgBlkH cfg)
            (cfgPad cfg) (cfgHzPadTop cfg) 0

    -- 4. Compose: add subtitle text to horizontal variants
    putStrLn "==> compose (add subtitle)"
    forM_ horizontalVariants $ \stem -> do
        -- Light variant
        composeLogo
            (cfgFontPath cfg)
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ "-full.svg")
            (cfgTxtSize cfg)
            Nothing
        -- Dark variant
        composeLogo
            (cfgFontPath cfg)
            (hzSvg ++ "/" ++ stem ++ ".svg")
            (hzSvg ++ "/" ++ stem ++ "-full-dark.svg")
            (cfgTxtSize cfg)
            (Just darkBg)

    -- 5. Export all SVGs to PNG + WebP
    putStrLn "==> raster (PNG + WebP)"
    let rasterTargets =
            [(sqSvg, sqPng, s) | s <- squareVariants]
                ++ [(hzSvg, hzPng, s) | s <- horizontalVariants]
                ++ [(hzSvg, hzPng, s ++ "-full") | s <- horizontalVariants]
                ++ [(hzSvg, hzPng, s ++ "-full-dark") | s <- horizontalVariants]
    forM_ rasterTargets $ \(svgDir, pngDir, stem) -> do
        exportPng  (svgDir ++ "/" ++ stem ++ ".svg") (pngDir ++ "/" ++ stem ++ ".png")  (cfgRasterW cfg)
        exportWebp (svgDir ++ "/" ++ stem ++ ".svg") (pngDir ++ "/" ++ stem ++ ".webp") (cfgRasterW cfg)

    -- 6. Animated GIF + WebP
    putStrLn "==> animate (GIF + WebP)"

    let mkFrames dir stems ext = map (\s -> dir ++ "/" ++ s ++ ext) stems
        ms = cfgAnimMs cfg

    -- Square animated (skin tones)
    assembleGif  (mkFrames sqPng squareSkinTones ".png")  (sqPng ++ "/square-animated.gif")  ms
    assembleWebp (mkFrames sqPng squareSkinTones ".png")  (sqPng ++ "/square-animated.webp") ms

    -- Horizontal animated (skin tones, logo-only)
    assembleGif  (mkFrames hzPng horizontalSkinTones ".png")  (hzPng ++ "/horizontal-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones ".png")  (hzPng ++ "/horizontal-animated.webp") ms

    -- Horizontal-full animated (skin tones, with subtitle, light)
    assembleGif  (mkFrames hzPng horizontalSkinTones "-full.png")  (hzPng ++ "/horizontal-full-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones "-full.png")  (hzPng ++ "/horizontal-full-animated.webp") ms

    -- Horizontal-full-dark animated (skin tones, with subtitle, dark)
    assembleGif  (mkFrames hzPng horizontalSkinTones "-full-dark.png")  (hzPng ++ "/horizontal-full-dark-animated.gif")  ms
    assembleWebp (mkFrames hzPng horizontalSkinTones "-full-dark.png")  (hzPng ++ "/horizontal-full-dark-animated.webp") ms

    -- Horizontal-rainbow animated (7 rainbow rotations)
    assembleGif  (mkFrames hzPng rainbowHzVariants ".png")  (hzPng ++ "/horizontal-rainbow-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants ".png")  (hzPng ++ "/horizontal-rainbow-animated.webp") ms

    -- Horizontal-rainbow-full animated (light)
    assembleGif  (mkFrames hzPng rainbowHzVariants "-full.png")  (hzPng ++ "/horizontal-rainbow-full-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants "-full.png")  (hzPng ++ "/horizontal-rainbow-full-animated.webp") ms

    -- Horizontal-rainbow-full-dark animated
    assembleGif  (mkFrames hzPng rainbowHzVariants "-full-dark.png")  (hzPng ++ "/horizontal-rainbow-full-dark-animated.gif")  ms
    assembleWebp (mkFrames hzPng rainbowHzVariants "-full-dark.png")  (hzPng ++ "/horizontal-rainbow-full-dark-animated.webp") ms

    -- 7. Favicons
    putStrLn "==> favicons"
    generateFavicons (sqSvg ++ "/square.svg") (cfgFaviconDir cfg)

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

