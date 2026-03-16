{-# LANGUAGE OverloadedStrings #-}
-- | Intermediate brick-layout representation.
--
-- A 'BrickLayout' captures the result of blockifying one design SVG: a grid
-- of rows where each row is a list of (stud_count, color) pairs.  Transparent
-- cells are represented as @Nothing@.
--
-- The format can be serialised to a human-readable, hand-editable ASCII file
-- (@.blay@) and later parsed back for Stage-2 SVG rendering.
--
-- == ASCII file format
--
-- > # brick-layout v1
-- > blk-w: 24
-- > blk-h: 20
-- > pad-top: 20
-- > pad-bottom: 20
-- > pad-left: 0
-- > pad-right: 0
-- > palette:
-- >   . = transparent
-- >   A = d09168
-- >   B = 000000
-- > # grid: 16×12
-- > grid:
-- > ....|AAAA|AAAA|....
-- > ....|AA|BBBB|AA|....
--
-- Each character in a grid row represents one stud column; '|' separates
-- adjacent bricks.  To split a brick, insert '|'; to merge, remove it.
module Logo.BrickLayout
    ( -- * Geometry
      BrickGeom (..)
    , mkBrickGeom
      -- * Layout type
    , RGB
    , BrickColor
    , BrickRow
    , BrickLayout (..)
    , layoutCols
    , layoutRows
      -- * Conversion
    , imageAndMapToLayout
      -- * ASCII serialisation
    , exportBrickLayout
    , parseBrickLayout
    , writeBrickLayout
    , readBrickLayout
    , parseHex
      -- * Layout manipulation
    , recolorLayout
    , composeLayouts
      -- * SVG rendering
    , layoutToSvg
    ) where

import Codec.Picture (Image (..), PixelRGBA8 (..), pixelAt)
import Data.Char (digitToInt, isHexDigit)
import Data.List (intercalate, nub, sortBy, transpose)
import Data.Maybe (catMaybes)
import Data.Ord (comparing)
import Data.Word (Word8)
import qualified Data.Map.Strict as Map
import qualified Data.ByteString as BS
import qualified Data.Text as T
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8, encodeUtf8)
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)
import Text.Printf (printf)

-- ── Brick geometry ────────────────────────────────────────────────────────────

data BrickGeom = BrickGeom
    { bgBodyH      :: !Int -- ^ Brick body height in SVG px (e.g., 17)
    , bgInnerBodyH :: !Int -- ^ Vertical row pitch / v_pitch (e.g., 15)
    , bgHPitch     :: !Int -- ^ Horizontal column pitch / h_pitch (e.g., 12)
    }

-- | Derive brick geometry from the two tunable constants @blkW@ and @blkH@.
-- Matches the Python / original Haskell formulas exactly.
mkBrickGeom :: Int -> Int -> BrickGeom
mkBrickGeom blkW blkH =
    let studH      = max 2 (blkH * 15 `div` 100)
        bodyH      = blkH - studH
        innerStudH = max 2 (bodyH * 15 `div` 100)
        innerBodyH = bodyH - innerStudH
        hPitch     = blkW `div` 2
     in BrickGeom bodyH innerBodyH hPitch

-- ── Types ─────────────────────────────────────────────────────────────────────

type RGB = (Word8, Word8, Word8)

-- | @Nothing@ = transparent (no brick rendered); @Just rgb@ = opaque brick.
type BrickColor = Maybe RGB

-- | One row of bricks, left-to-right.  Each entry is @(stud_count, color)@.
-- Transparent entries are kept so that the total width (sum of stud counts)
-- is constant across all rows.
type BrickRow = [(Int, BrickColor)]

-- | A complete brick layout ready for ASCII export or SVG rendering.
data BrickLayout = BrickLayout
    { blBlkW      :: !Int       -- ^ Brick SVG unit width (e.g., 24 → hPitch = 12)
    , blBlkH      :: !Int       -- ^ Brick SVG unit height (e.g., 20)
    , blPadTop    :: !Int       -- ^ Extra SVG pixels above the brick grid
    , blPadBottom :: !Int       -- ^ Extra SVG pixels below the brick grid
    , blPadLeft   :: !Int       -- ^ Extra SVG pixels left of the brick grid
    , blPadRight  :: !Int       -- ^ Extra SVG pixels right of the brick grid
    , blRows      :: [BrickRow] -- ^ Grid rows, top-to-bottom
    } deriving (Show, Eq)

-- | Total stud-columns per row (derived from the first row).
layoutCols :: BrickLayout -> Int
layoutCols bl = sum (map fst (head (blRows bl)))

-- | Number of brick rows.
layoutRows :: BrickLayout -> Int
layoutRows = length . blRows

-- ── Conversion from rasterised image + brick-size map ────────────────────────

-- | Build a 'BrickLayout' from a processed image and the brick-size map
-- returned by @Logo.Blockify.autoBrickSizes@.
--
-- The map stores @(col, row) → svg_pixel_width@, where:
--
--   * key absent  → transparent pixel
--   * value @> 0@ → brick starts here (width in SVG pixels = @studs × hPitch@)
--   * value @= 0@ → pixel consumed by an earlier brick in the same row
imageAndMapToLayout
    :: Image PixelRGBA8
    -> Map.Map (Int, Int) Int -- ^ @(col, row)@ → SVG pixel width
    -> Int                    -- ^ @blkW@
    -> Int                    -- ^ @blkH@
    -> Int                    -- ^ @padTop@
    -> Int                    -- ^ @padBottom@
    -> BrickLayout
imageAndMapToLayout img brickMap blkW blkH padTop padBottom =
    let hPitch = blkW `div` 2
     in BrickLayout
            { blBlkW      = blkW
            , blBlkH      = blkH
            , blPadTop    = padTop
            , blPadBottom = padBottom
            , blPadLeft   = 0
            , blPadRight  = 0
            , blRows      = map (buildRow img brickMap hPitch (imageWidth img))
                                [0 .. imageHeight img - 1]
            }

buildRow :: Image PixelRGBA8 -> Map.Map (Int, Int) Int -> Int -> Int -> Int -> BrickRow
buildRow img brickMap hPitch w row = go 0
  where
    go col
        | col >= w  = []
        | otherwise = case Map.lookup (col, row) brickMap of
            Nothing ->
                -- Transparent: accumulate a run of consecutive absent positions.
                let run = length $ takeWhile
                        (\i -> col + i < w && Map.notMember (col + i, row) brickMap)
                        [0 ..]
                 in (run, Nothing) : go (col + run)
            Just 0 ->
                -- Consumed by a previous brick (should not be reached in a
                -- well-formed map because we jump by stud count below).
                go (col + 1)
            Just svgW ->
                let studs              = svgW `div` hPitch
                    PixelRGBA8 r g b _ = pixelAt img col row
                 in (studs, Just (r, g, b)) : go (col + studs)

-- ── ASCII serialisation ───────────────────────────────────────────────────────

-- | Assign a single letter to each unique opaque colour.
buildPalette :: [BrickRow] -> Map.Map RGB Char
buildPalette rows =
    let colors  = nub [c | row <- rows, (_, Just c) <- row]
        letters = filter (\c -> c /= '.' && c /= '|') (['A' .. 'Z'] ++ ['a' .. 'z'])
     in Map.fromList (zip colors letters)

-- | Encode one 'BrickRow' as text.
encodeRow :: Map.Map RGB Char -> BrickRow -> Text
encodeRow palette = T.intercalate "|" . map encodeBrick
  where
    encodeBrick (n, Nothing) = T.replicate n "."
    encodeBrick (n, Just c)  = T.replicate n (T.singleton (palette Map.! c))

-- | Export a 'BrickLayout' to its ASCII @.blay@ text.
exportBrickLayout :: BrickLayout -> Text
exportBrickLayout bl =
    let palette    = buildPalette (blRows bl)
        invPalette = Map.fromList [(ch, rgb) | (rgb, ch) <- Map.toList palette]
        cols       = layoutCols bl
        nRows      = layoutRows bl
        metaLines  = T.unlines
            [ "# brick-layout v1"
            , "blk-w: "      <> tshow (blBlkW bl)
            , "blk-h: "      <> tshow (blBlkH bl)
            , "pad-top: "    <> tshow (blPadTop bl)
            , "pad-bottom: " <> tshow (blPadBottom bl)
            , "pad-left: "   <> tshow (blPadLeft bl)
            , "pad-right: "  <> tshow (blPadRight bl)
            ]
        palHeader  = "# palette: char = RRGGBB  (. = transparent)\npalette:\n  . = transparent\n"
        palLines   = T.unlines
            [ "  " <> T.singleton ch <> " = " <> rgbToHex rgb
            | (ch, rgb) <- sortBy (comparing fst) (Map.toList invPalette)
            ]
        gridHeader = "# grid: " <> tshow cols <> T.singleton '×' <> tshow nRows <> "\ngrid:\n"
        gridLines  = T.unlines (map (encodeRow palette) (blRows bl))
     in metaLines <> palHeader <> palLines <> gridHeader <> gridLines
  where
    tshow = T.pack . show

-- | Write a 'BrickLayout' to a @.blay@ file, creating parent dirs as needed.
writeBrickLayout :: FilePath -> BrickLayout -> IO ()
writeBrickLayout path bl = do
    createDirectoryIfMissing True (takeDirectory path)
    BS.writeFile path (encodeUtf8 (exportBrickLayout bl))
    putStrLn $ "  Saved " ++ path

-- ── ASCII parsing ─────────────────────────────────────────────────────────────

-- | Parse a 'BrickLayout' from @.blay@ text.
parseBrickLayout :: Text -> Either String BrickLayout
parseBrickLayout txt = do
    -- Drop blank lines; keep comment lines only when they are section markers.
    let ls = filter (not . T.null . T.strip) (T.lines txt)
        -- Separate comment lines from content lines for key-value lookup.
        content = filter (not . T.isPrefixOf "#" . T.strip) ls

    -- Split on "palette:" header.
    let (kvLines, rest0) = break ((== "palette:") . T.strip) content
    rest1 <- case rest0 of
        [] -> Left "missing 'palette:' section"
        _  -> Right (drop 1 rest0)

    -- Split on "grid:" header.
    let (palLines, rest2) = break ((== "grid:") . T.strip) rest1
    gridLines <- case rest2 of
        [] -> Left "missing 'grid:' section"
        _  -> Right (drop 1 rest2)

    blkW      <- findInt        "blk-w"      kvLines
    blkH      <- findInt        "blk-h"      kvLines
    padTop    <- findInt        "pad-top"    kvLines
    padBottom <- findInt        "pad-bottom" kvLines
    let padLeft  = findIntDefault "pad-left"  0 kvLines
        padRight = findIntDefault "pad-right" 0 kvLines

    palette   <- parsePaletteLines palLines
    rows      <- mapM (parseRow palette) gridLines

    Right BrickLayout
        { blBlkW      = blkW
        , blBlkH      = blkH
        , blPadTop    = padTop
        , blPadBottom = padBottom
        , blPadLeft   = padLeft
        , blPadRight  = padRight
        , blRows      = rows
        }

findInt :: Text -> [Text] -> Either String Int
findInt key ls =
    case filter (T.isPrefixOf (key <> ": ")) ls of
        [] -> Left $ "missing key: " ++ T.unpack key
        (l : _) ->
            let v = T.strip $ T.drop (T.length key + 2) l
             in case reads (T.unpack v) of
                    [(n, "")] -> Right n
                    _         -> Left $ "bad integer for " ++ T.unpack key ++ ": " ++ T.unpack v

findIntDefault :: Text -> Int -> [Text] -> Int
findIntDefault key def ls =
    case filter (T.isPrefixOf (key <> ": ")) ls of
        [] -> def
        (l : _) ->
            let v = T.strip $ T.drop (T.length key + 2) l
             in case reads (T.unpack v) of
                    [(n, "")] -> n
                    _         -> def

parsePaletteLines :: [Text] -> Either String (Map.Map Char RGB)
parsePaletteLines ls = do
    pairs <- mapM parseLine ls
    Right $ Map.fromList (catMaybes pairs)
  where
    parseLine l =
        let ws = T.words (T.strip l)
         in case ws of
                [c, "=", "transparent"] | T.length c == 1 ->
                    Right Nothing  -- '.' handled in parseRow
                [c, "=", hex] | T.length c == 1 && T.length hex == 6 ->
                    case parseHex hex of
                        Just rgb -> Right (Just (T.head c, rgb))
                        Nothing  -> Left $ "bad hex color: " ++ T.unpack hex
                _ -> Left $ "bad palette line: " ++ T.unpack l

parseHex :: Text -> Maybe RGB
parseHex h
    | T.length h == 6 && T.all isHexDigit h =
        let cs = T.unpack h
            hv x y = fromIntegral (digitToInt x * 16 + digitToInt y)
            r = hv (head cs) (cs !! 1)
            g = hv (cs !! 2) (cs !! 3)
            b = hv (cs !! 4) (cs !! 5)
         in Just (r, g, b)
    | otherwise = Nothing

parseRow :: Map.Map Char RGB -> Text -> Either String BrickRow
parseRow palette l = mapM parseSeg (T.splitOn "|" l)
  where
    parseSeg seg
        | T.null seg         = Left "empty segment in grid row"
        | T.all (== '.') seg = Right (T.length seg, Nothing)
        | otherwise =
            let ch = T.head seg
             in if T.all (== ch) seg
                    then case Map.lookup ch palette of
                        Nothing  -> Left $ "unknown color char: " ++ [ch]
                        Just rgb -> Right (T.length seg, Just rgb)
                    else Left $ "mixed chars in segment: " ++ T.unpack seg

-- | Read and parse a @.blay@ file (always decoded as UTF-8).
readBrickLayout :: FilePath -> IO BrickLayout
readBrickLayout path = do
    txt <- decodeUtf8 <$> BS.readFile path
    case parseBrickLayout txt of
        Left err -> error $ "readBrickLayout: " ++ path ++ ": " ++ err
        Right bl -> return bl

-- ── Layout manipulation ───────────────────────────────────────────────────────

-- | Replace every brick cell whose colour matches @old@ with @new@.
-- Transparent cells are unaffected.
recolorLayout :: RGB -> RGB -> BrickLayout -> BrickLayout
recolorLayout old new bl =
    bl { blRows = map (map recolorCell) (blRows bl) }
  where
    recolorCell (n, Just c)  | c == old = (n, Just new)
    recolorCell cell                    = cell

-- | Compose multiple 'BrickLayout' values side-by-side into a single layout,
-- inserting @gapStuds@ transparent stud-columns between each adjacent pair.
-- All layouts must share the same @blkW@, @blkH@, and row count.
-- Padding from individual source layouts is discarded: pad-left, pad-right,
-- pad-top, and pad-bottom are all reset to 0.  The caller (e.g. blay-compose)
-- can override them afterwards via @--pad-top@/@--pad-bottom@.
composeLayouts :: Int -> [BrickLayout] -> BrickLayout
composeLayouts _        []         = error "composeLayouts: empty list"
composeLayouts _        [bl]       = bl
composeLayouts gapStuds bls@(bl0 : _) =
    bl0
        { blPadTop    = 0
        , blPadBottom = 0
        , blPadLeft   = 0
        , blPadRight  = 0
        , blRows      = map composeRow (transpose (map blRows bls))
        }
  where
    gap        = [(gapStuds, Nothing)]
    composeRow = foldr1 (\r acc -> r ++ gap ++ acc)

-- ── SVG rendering ─────────────────────────────────────────────────────────────

rgbStr :: RGB -> String
rgbStr (r, g, b) = printf "rgb(%d,%d,%d)" r g b

rgbToHex :: RGB -> Text
rgbToHex (r, g, b) = T.pack $ printf "%02x%02x%02x" r g b

-- | Render one brick as SVG elements (body rect, 4 hairline borders, studs).
-- Matches the original Python / Haskell @create_brick_side_view@ exactly.
brickSvgElements :: Int -> Int -> Int -> RGB -> BrickGeom -> [String]
brickSvgElements brickX brickY brickW color geom =
    let r       = rgbStr color
        bc      = "rgb(0,0,0)"
        studHt  = max 2 (bgBodyH geom * 15 `div` 100)   -- 2
        actBH   = bgBodyH geom - studHt                  -- 15
        hP      = bgHPitch geom
        bodyY   = brickY + studHt
        bY2     = brickY + bgBodyH geom
        sCount  = brickW `div` hP
        body    = printf "  <rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"%s\"/>"
                      brickX bodyY brickW actBH r
        lTop    = printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.25\" opacity=\"1.0\"/>"
                      brickX bodyY (brickX + brickW) bodyY bc
        lBottom = printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.25\" opacity=\"1.0\"/>"
                      brickX bY2 (brickX + brickW) bY2 bc
        lLeft   = printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.25\" opacity=\"1.0\"/>"
                      brickX bodyY brickX bY2 bc
        lRight  = printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\" stroke-width=\"0.25\" opacity=\"1.0\"/>"
                      (brickX + brickW) bodyY (brickX + brickW) bY2 bc
        studs   = concatMap (mkStud brickX brickY r bc studHt hP) [0 .. sCount - 1]
     in body : lTop : lBottom : lLeft : lRight : studs

mkStud :: Int -> Int -> String -> String -> Int -> Int -> Int -> [String]
mkStud brickX brickY r bc studHt hPitch i =
    let studW = 7 :: Int
        studX = fromIntegral brickX
                    + fromIntegral (hPitch * i)
                    + (fromIntegral hPitch - 7.0 :: Double) / 2.0
        studY = brickY :: Int
        sRect = printf "  <rect x=\"%.1f\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"%s\"/>"
                    studX studY studW studHt r
        sBdr  = printf "  <rect x=\"%.1f\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"none\" stroke=\"%s\" stroke-width=\"0.25\" opacity=\"1.0\"/>"
                    studX studY studW studHt bc
     in [sRect, sBdr]

-- | Render a list of rows into brick SVG elements, bottom-to-top (so upper
-- bricks visually overlap the studs of the row below).
-- @xOff@ is a pixel offset added to every brick's X coordinate.
renderRows :: [BrickRow] -> BrickGeom -> Int -> Int -> [String]
renderRows rows geom vertOff xOff =
    [ line
    | (rowIdx, brickRow) <- reverse (zip [0 ..] rows)
    , let rowY = rowIdx * bgInnerBodyH geom + vertOff
    , (colOff, studs, color) <- brickPositions brickRow
    , let brickX = xOff + colOff * bgHPitch geom
          brickW = studs * bgHPitch geom
    , line <- brickSvgElements brickX rowY brickW color geom
    ]

-- | Enumerate opaque bricks in a row with their column offsets (in studs).
brickPositions :: BrickRow -> [(Int, Int, RGB)]
brickPositions = go 0
  where
    go _ []                        = []
    go col ((n, Nothing) : rest)   = go (col + n) rest
    go col ((n, Just c)  : rest)   = (col, n, c) : go (col + n) rest

-- | Render a single 'BrickLayout' to an SVG string.
-- Vertical centering is applied when the grid is square (cols == rows), as
-- in the original @imageToBrickSvg@.
layoutToSvg :: BrickLayout -> String
layoutToSvg bl =
    let geom       = mkBrickGeom (blBlkW bl) (blBlkH bl)
        hP         = bgHPitch geom
        innerBodyH = bgInnerBodyH geom
        bodyH      = bgBodyH geom
        cols       = layoutCols bl
        nRows      = layoutRows bl
        padTop     = blPadTop bl
        padBottom  = blPadBottom bl
        padLeft    = blPadLeft bl
        padRight   = blPadRight bl
        svgW       = cols * hP + padLeft + padRight
        contentH   = (nRows - 1) * innerBodyH + bodyH
        (baseSvgH, baseVertOff)
            | cols == nRows = let sh = max (cols * hP) contentH
                               in (sh, (sh - contentH) `div` 2)
            | otherwise     = (contentH, 0)
        svgH    = baseSvgH + padTop + padBottom
        vertOff = baseVertOff + padTop
        header  =
            [ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
            , printf "<svg width=\"%d\" height=\"%d\" viewBox=\"0 0 %d %d\" "
                  svgW svgH svgW svgH
            , "     xmlns=\"http://www.w3.org/2000/svg\">"
            , "  <desc>Brick-style blocky version - auto bricks side view</desc>"
            ]
        footer  = ["</svg>"]
        bricks  = renderRows (blRows bl) geom vertOff padLeft
     in intercalate "\n" (header ++ bricks ++ footer)

