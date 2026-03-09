module Logo.Blockify (blockifySvg, aspectCorrectionFactor) where

import Codec.Picture
import Data.List (intercalate, maximumBy, sort)
import Data.Maybe (fromMaybe, isJust, isNothing)
import Data.Ord (comparing)
import Data.Word (Word8)
import qualified Data.ByteString as BS
import qualified Data.Map.Strict as Map
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)
import System.Process (createProcess, proc, std_out, StdStream (..), waitForProcess)
import Text.Printf (printf)

type RGB = (Word8, Word8, Word8)
type Pos = (Int, Int) -- (col, row)

-- ── Rendering ────────────────────────────────────────────────────────────────────

-- | Rasterize SVG using rsvg-convert at 4× target width, apply a 3×3 mode
-- filter in Haskell (removes anti-aliasing artefacts), then downscale to
-- target width with centre-of-pixel NEAREST mapping (matches PIL NEAREST).
rasterize :: FilePath -> Int -> IO (Image PixelRGBA8)
rasterize svgPath targetW = do
    (_, Just hout, _, ph) <-
        createProcess
            (proc "rsvg-convert" ["-w", show (targetW * 4), "-f", "png", svgPath])
                { std_out = CreatePipe }
    raw <- BS.hGetContents hout
    _ <- waitForProcess ph
    case decodePng raw of
        Left err -> error $ "rasterize: PNG decode failed for " ++ svgPath ++ ": " ++ err
        Right dynImg ->
            let img4x    = convertRGBA8 dynImg
                filtered = modeFilter img4x
                targetH  = max 1 $ round
                    ( fromIntegral targetW
                    * fromIntegral (imageHeight filtered)
                    / fromIntegral (imageWidth  filtered) :: Double )
             in return $ scaleNearest filtered targetW targetH

-- | 3×3 mode filter: replace each opaque pixel's colour with the most
-- common colour in its 3×3 neighbourhood (matching scripts/svg_rasterize.py).
modeFilter :: Image PixelRGBA8 -> Image PixelRGBA8
modeFilter img = generateImage sample w h
  where
    w = imageWidth img
    h = imageHeight img
    sample x y =
        let PixelRGBA8 r g b a = pixelAt img x y
         in if a < 128
                then PixelRGBA8 r g b a
                else let (dr, dg, db) = dominantColor x y
                      in PixelRGBA8 dr dg db a
    dominantColor x y =
        let neighbors =
                [ (r', g', b')
                | dy <- [-1, 0, 1 :: Int]
                , dx <- [-1, 0, 1 :: Int]
                , let nx = x + dx; ny = y + dy
                , nx >= 0, nx < w, ny >= 0, ny < h
                , let PixelRGBA8 r' g' b' a' = pixelAt img nx ny
                , a' >= 128
                ]
            counts = Map.fromListWith (+) [(c, 1 :: Int) | c <- neighbors]
         in case Map.toList counts of
                []  -> let PixelRGBA8 r0 g0 b0 _ = pixelAt img x y in (r0, g0, b0)
                xs  -> fst $ maximumBy (comparing snd) xs

-- | Nearest-neighbour scale (matches PIL NEAREST).
-- PIL uses centre-of-pixel formula: src = floor((out + 0.5) * src_size / new_size)
-- i.e. src = (2*out + 1) * src_size `div` (2 * new_size)
scaleNearest :: Image PixelRGBA8 -> Int -> Int -> Image PixelRGBA8
scaleNearest src newW newH = generateImage sample newW newH
  where
    sw = imageWidth src
    sh = imageHeight src
    sample x y =
        let sx = (2 * x + 1) * sw `div` (2 * newW)
            sy = (2 * y + 1) * sh `div` (2 * newH)
         in pixelAt src (min sx (sw - 1)) (min sy (sh - 1))


-- | Add transparent padding columns on each side.
addPadding :: Image PixelRGBA8 -> Int -> Image PixelRGBA8
addPadding img pad
    | pad <= 0 = img
    | otherwise = generateImage sample (w + 2 * pad) h
  where
    w = imageWidth img
    h = imageHeight img
    sample x y
        | x < pad || x >= pad + w = PixelRGBA8 0 0 0 0
        | otherwise = pixelAt img (x - pad) y

-- ── Brick geometry ────────────────────────────────────────────────────────────────

-- | Compute the aspect-correction factor h_pitch / v_pitch.
-- With blkW=24, blkH=20: studH=3, bodyH=17, innerStudH=2, vPitch=15, hPitch=12.
aspectCorrectionFactor :: Int -> Int -> Double
aspectCorrectionFactor blkW blkH =
    let studH      = max 2 (blkH * 15 `div` 100)
        bodyH      = blkH - studH
        innerStudH = max 2 (bodyH * 15 `div` 100)
        vPitch     = bodyH - innerStudH
        hPitch     = blkW `div` 2
     in fromIntegral hPitch / fromIntegral vPitch

data BrickGeom = BrickGeom
    { bgStudH      :: !Int -- stud height (2 px)
    , bgBodyH      :: !Int -- brick body height (17 px)
    , bgInnerBodyH :: !Int -- vertical row pitch / v_pitch (15 px)
    , bgHPitch     :: !Int -- horizontal column pitch / h_pitch (12 px)
    }

mkBrickGeom :: Int -> Int -> BrickGeom
mkBrickGeom blkW blkH =
    let studH      = max 2 (blkH * 15 `div` 100)
        bodyH      = blkH - studH
        innerStudH = max 2 (bodyH * 15 `div` 100)
        innerBodyH = bodyH - innerStudH
        hPitch     = blkW `div` 2
     in BrickGeom studH bodyH innerBodyH hPitch

-- ── Auto brick sizing ─────────────────────────────────────────────────────────────

-- | Determine the SVG brick width for every opaque pixel in the image.
-- Returns Map (col,row) → svg_brick_width, where 0 means the pixel is
-- consumed by the brick starting at an earlier column in the same row.
-- Matches Python image_to_brick_svg "auto" mode exactly.
autoBrickSizes :: Image PixelRGBA8 -> Int -> Map.Map Pos Int
autoBrickSizes img hPitch = go 0 Nothing Map.empty Map.empty
  where
    w = imageWidth img
    h = imageHeight img

    isOpaque x y = let PixelRGBA8 _ _ _ a = pixelAt img x y in a >= 128
    rgb x y      = let PixelRGBA8 r g b _ = pixelAt img x y in (r, g, b)

    go row prevFirst prevRowBricks acc
        | row >= h  = acc
        | otherwise =
            let (rowSizes, rowBricks, mFirst) = processRow row prevFirst prevRowBricks
             in go (row + 1) mFirst rowBricks (Map.union acc rowSizes)

    processRow row prevFirst prevBricks =
        let (rawSizes, rawBricks, mFirst) =
                scanRow row 0 Nothing prevFirst prevBricks Map.empty Map.empty
            (sizes', bricks') = postProcess row rawSizes rawBricks
         in (sizes', bricks', mFirst)

    -- Scan one row left-to-right, deciding a brick length for each run.
    -- rowFirst: length (in units) of the first brick placed in this row so far.
    -- prevFirst: length of the first brick of the previous row.
    -- prevBricks: Map col → (length_units, color) for the previous row.
    scanRow row x rowFirst prevFirst prevBricks sizes bricks
        | x >= w    = (sizes, bricks, rowFirst)
        | not (isOpaque x row) =
            scanRow row (x + 1) rowFirst prevFirst prevBricks sizes bricks
        | otherwise =
            let baseColor = rgb x row
                colorRun  = length $ takeWhile
                    (\i -> x + i < w && isOpaque (x + i) row && rgb (x + i) row == baseColor)
                    [0 ..]
                possible = [ l
                           | l <- [4, 3, 2, 1]
                           , x + l <= w
                           , all (\i -> isOpaque (x + i) row && rgb (x + i) row == baseColor)
                                 [0 .. l - 1]
                           ]
                maxLen = chooseBrickLen row x rowFirst prevFirst prevBricks baseColor colorRun possible
                brickW = maxLen * hPitch
                sizes'  = foldr (\i m -> Map.insert (x + i, row) (if i == 0 then brickW else 0) m)
                                sizes [0 .. maxLen - 1]
                bricks' = Map.insert x (maxLen, baseColor) bricks
                rowFirst' = Just (fromMaybe maxLen rowFirst)
             in scanRow row (x + maxLen) rowFirst' prevFirst prevBricks sizes' bricks'

    chooseBrickLen row x rowFirst prevFirst prevBricks baseColor colorRun possible =
        case possible of
            [] -> 1
            (l0 : _) ->
                -- Step 2 (y > 0): avoid stacking same-size same-color bricks
                let l1 =
                        if row > 0
                            then case Map.lookup x prevBricks of
                                    Just (bl, bc)
                                        | bc == baseColor
                                        , colorRun > 2
                                        , bl == l0
                                        , length possible > 1 ->
                                            head [l | l <- possible, l /= l0]
                                    _ -> l0
                            else l0
                 in -- Step 3: vary first brick from previous row's first
                    if isNothing rowFirst && isJust prevFirst
                        then
                            let pf = fromMaybe 0 prevFirst
                                preferred = [l | l <- possible, l /= pf]
                             in if null preferred then l0 else head preferred
                        else l1

    -- Post-process one row: merge adjacent same-colour brick pairs.
    postProcess row sizes bricks =
        runPost row sizes bricks (sort (Map.keys bricks)) 0

    runPost row sizes bricks positions i
        | i >= length positions - 1 = (sizes, bricks)
        | otherwise =
            let x1          = positions !! i
                x2          = positions !! (i + 1)
                (l1, c1)    = bricks Map.! x1
                (l2, c2)    = bricks Map.! x2
                adjacent    = x1 + l1 == x2
             in if colorsSimilar c1 c2 && adjacent
                    then case (l1, l2) of
                        -- 3+3 → 2+4
                        (3, 3) ->
                            let s' = Map.fromList
                                        [ ((x1,     row), 2 * hPitch)
                                        , ((x1 + 1, row), 0)
                                        , ((x1 + 2, row), 4 * hPitch)
                                        , ((x1 + 3, row), 0)
                                        , ((x1 + 4, row), 0)
                                        , ((x1 + 5, row), 0)
                                        ]
                                        `Map.union` sizes
                                b' = Map.insert x1 (2, c1)
                                   . Map.insert (x1 + 2) (4, c1)
                                   . Map.delete x2
                                   $ bricks
                                p' = replaceAt positions (i + 1) (x1 + 2)
                             in runPost row s' b' p' (i + 1)
                        -- 3+2 → 4+1
                        (3, 2) ->
                            let s' = Map.fromList
                                        [ ((x1,     row), 4 * hPitch)
                                        , ((x1 + 1, row), 0)
                                        , ((x1 + 2, row), 0)
                                        , ((x1 + 3, row), 0)
                                        , ((x1 + 4, row), hPitch)
                                        ]
                                        `Map.union` sizes
                                b' = Map.insert x1 (4, c1)
                                   . Map.insert (x1 + 4) (1, c1)
                                   . Map.delete x2
                                   $ bricks
                                p' = replaceAt positions (i + 1) (x1 + 4)
                             in runPost row s' b' p' (i + 1)
                        -- 2+1 or 1+2 → 3
                        (a, b)
                            | (a == 2 && b == 1) || (a == 1 && b == 2) ->
                                let s' = Map.fromList
                                            [ ((x1,     row), 3 * hPitch)
                                            , ((x1 + 1, row), 0)
                                            , ((x1 + 2, row), 0)
                                            ]
                                            `Map.union` sizes
                                    b' = Map.insert x1 (3, c1)
                                       . Map.delete x2
                                       $ bricks
                                    p' = removeAt positions (i + 1)
                                 in runPost row s' b' p' i -- don't advance i
                        _ -> runPost row sizes bricks positions (i + 1)
                    else runPost row sizes bricks positions (i + 1)

colorsSimilar :: RGB -> RGB -> Bool
colorsSimilar (r1, g1, b1) (r2, g2, b2) =
    abs (fi r1 - fi r2) <= 2
        && abs (fi g1 - fi g2) <= 2
        && abs (fi b1 - fi b2) <= 2
  where
    fi = fromIntegral :: Word8 -> Int

replaceAt :: [a] -> Int -> a -> [a]
replaceAt xs i x = take i xs ++ [x] ++ drop (i + 1) xs

removeAt :: [a] -> Int -> [a]
removeAt xs i = take i xs ++ drop (i + 1) xs

-- ── SVG rendering ─────────────────────────────────────────────────────────────────

rgbStr :: RGB -> String
rgbStr (r, g, b) = printf "rgb(%d,%d,%d)" r g b

-- | Render one brick as SVG elements: body rect, 4 hairline borders, studs.
-- Matches Python create_brick_side_view(x, y, brick_width, brick_height=bgBodyH, …)
-- which recomputes its own inner stud from brick_height (bgBodyH=17, not blkH=20).
brickElements :: Int -> Int -> Int -> RGB -> BrickGeom -> [String]
brickElements brickX brickY brickW color geom =
    let r      = rgbStr color
        bc     = "rgb(0,0,0)"
        -- Python: stud_height = max(2, int(brick_height * 0.15))  brick_height = bgBodyH = 17
        --         body_height  = brick_height - stud_height        = 15
        studHt = max 2 (bgBodyH geom * 15 `div` 100)  -- 2
        actBH  = bgBodyH geom - studHt                 -- 15
        hP     = bgHPitch geom
        bodyY  = brickY + studHt
        bY2    = brickY + bgBodyH geom
        sCount = brickW `div` hP

        body =
            printf "  <rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"%s\"/>"
                brickX bodyY brickW actBH r
        lTop =
            printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.5\" opacity=\"0.3\"/>"
                brickX bodyY (brickX + brickW) bodyY bc
        lBottom =
            printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.5\" opacity=\"0.3\"/>"
                brickX bY2 (brickX + brickW) bY2 bc
        lLeft =
            printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.5\" opacity=\"0.3\"/>"
                brickX bodyY brickX bY2 bc
        lRight =
            printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.5\" opacity=\"0.3\"/>"
                (brickX + brickW) bodyY (brickX + brickW) bY2 bc

        studs = concatMap (mkStud brickX brickY r bc studHt hP) [0 .. sCount - 1]
     in body : lTop : lBottom : lLeft : lRight : studs

mkStud :: Int -> Int -> String -> String -> Int -> Int -> Int -> [String]
mkStud brickX brickY r bc studHt hPitch i =
    -- Python: stud_x = x + base_unit * i + (base_unit - stud_width) / 2
    -- stud_width = 7, base_unit = hPitch = 12  →  offset = (12-7)/2 = 2.5
    let studW = 7 :: Int
        studX = fromIntegral brickX
                    + fromIntegral (hPitch * i)
                    + (fromIntegral hPitch - 7.0 :: Double) / 2.0
        studY = brickY :: Int
        sRect =
            printf "  <rect x=\"%.1f\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"%s\"/>"
                studX studY studW studHt r
        sBdr =
            printf "  <rect x=\"%.1f\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"none\" stroke=\"%s\" stroke-width=\"0.5\" opacity=\"0.2\"/>"
                studX studY studW studHt bc
     in [sRect, sBdr]

-- | Convert the processed image + brick-size map to a complete SVG string.
-- padTop / padBottom are extra whitespace in SVG pixels added above / below the bricks.
imageToBrickSvg :: Image PixelRGBA8 -> Map.Map Pos Int -> BrickGeom -> Int -> Int -> String
imageToBrickSvg img brickSizes geom padTop padBottom =
    let w          = imageWidth img
        h          = imageHeight img
        hP         = bgHPitch geom
        bodyH      = bgBodyH geom
        innerBodyH = bgInnerBodyH geom
        svgW       = w * hP
        contentH   = (h - 1) * innerBodyH + bodyH
        (baseSvgH, baseVertOff)
            | w == h    = let sh = max svgW contentH
                           in (sh, (sh - contentH) `div` 2)
            | otherwise = (contentH, 0)
        svgH    = baseSvgH + padTop + padBottom
        vertOff = baseVertOff + padTop

        header =
            [ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
            , printf "<svg width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\" "
                svgW svgH svgW svgH
            , "     xmlns=\"http://www.w3.org/2000/svg\">"
            , "  <desc>Brick-style blocky version - auto bricks side view</desc>"
            ]
        footer = ["</svg>"]

        -- Draw bottom-to-top so upper bricks overlap lower brick studs.
        bricks =
            [ line
            | row <- [h - 1, h - 2 .. 0]
            , col <- [0 .. w - 1]
            , let brickW = Map.findWithDefault 0 (col, row) brickSizes
            , brickW > 0
            , let PixelRGBA8 r g b a = pixelAt img col row
            , a >= 128
            , let color  = (r, g, b)
                  brickX = col * hP
                  brickY = row * innerBodyH + vertOff
            , line <- brickElements brickX brickY brickW color geom
            ]
     in intercalate "\n" (header ++ bricks ++ footer)

-- ── Main entry point ──────────────────────────────────────────────────────────────

blockifySvg
    :: FilePath -- ^ input SVG
    -> FilePath -- ^ output SVG
    -> Int      -- ^ target pixel width (sqPx or hzPx)
    -> Int      -- ^ blkW (2×2 brick SVG width, default 24)
    -> Int      -- ^ blkH (brick SVG height, default 20)
    -> Int      -- ^ pad (transparent column padding each side)
    -> Int      -- ^ padTop (extra SVG pixels above bricks)
    -> Int      -- ^ padBottom (extra SVG pixels below bricks)
    -> IO ()
blockifySvg inSvg outSvg sqPx blkW blkH pad padTop padBottom = do
    putStrLn $ "  blockify " ++ inSvg ++ " -> " ++ outSvg

    -- 1. Rasterize via cairosvg+PIL (mode filter and downscale done in Python)
    raw <- rasterize inSvg sqPx

    -- 2. Aspect-ratio correction: compress height by h_pitch / v_pitch
    let geom   = mkBrickGeom blkW blkH
        origH  = imageHeight raw
        corrH  = max 1 $ round
                     ( fromIntegral origH
                     * fromIntegral (bgHPitch geom)
                     / fromIntegral (bgInnerBodyH geom) :: Double )
        corrected
            | corrH /= origH = scaleNearest raw (imageWidth raw) corrH
            | otherwise      = raw

    -- 3. Add transparent padding columns
    let padded = addPadding corrected pad

    -- 4. Compute adaptive brick sizes
    let sizes = autoBrickSizes padded (bgHPitch geom)

    -- 5. Render and write
    let svg = imageToBrickSvg padded sizes geom padTop padBottom
    createDirectoryIfMissing True (takeDirectory outSvg)
    writeFile outSvg svg
    putStrLn $ "  Saved " ++ outSvg
