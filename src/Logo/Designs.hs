{-# LANGUAGE OverloadedStrings #-}
module Logo.Designs
    ( generateAllDesigns
    , svgViewBox
    , svgInnerContent
    , recolorFace
    , squareSvg
    , horizontalSvg
    , minifigBandedSvg
    ) where

import Brand.Colors
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Data.ByteString as BS
import Data.Text.Encoding (decodeUtf8, encodeUtf8)
import qualified Data.Text.Lazy as TL
import Data.Text (Text)
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import Text.XML
    ( Document (..)
    , Element (..)
    , Name (..)
    , Node (..)
    , def
    , parseText
    , renderText
    )

-- | Parse viewBox="x y w h" from SVG text. Returns (x, y, w, h).
svgViewBox :: Text -> (Double, Double, Double, Double)
svgViewBox t =
    let after = snd $ T.breakOn "viewBox=\"" t
        inner = T.takeWhile (/= '"') $ T.drop (T.length "viewBox=\"") after
        parts = map (read . T.unpack) $ T.splitOn " " inner
     in case parts of
            [x, y, w, h] -> (x, y, w, h)
            _ -> error $ "svgViewBox: cannot parse: " ++ T.unpack inner

-- | Strip <?xml> declaration and outer <svg> wrapper, returning inner elements.
svgInnerContent :: Text -> Text
svgInnerContent t =
    let noDecl = stripXmlDecl (T.strip t)
        afterOpen = T.drop 1 $ snd $ T.breakOn ">" $ snd $ T.breakOn "<svg" noDecl
        noClose = T.strip afterOpen
     in if "</svg>" `T.isSuffixOf` noClose
            then T.strip $ T.dropEnd (T.length "</svg>") noClose
            else noClose
  where
    stripXmlDecl s =
        case T.breakOn "<?" s of
            (_, rest) | not (T.null rest) ->
                let (_, after) = T.breakOn "?>" rest
                 in T.strip $ T.drop 2 after
            _ -> s

-- | Replace headSvgFaceColor with given hex in raw SVG text.
recolorFace :: Hex -> Text -> Text
recolorFace (Hex newColor) = T.replace headSvgFaceColor (T.toLower newColor)

-- | Generate square SVG: source.svg recolored with faceColor.
squareSvg :: Hex -> Text -> Text
squareSvg = recolorFace

-- | Generate horizontal SVG: n heads side-by-side.
horizontalSvg :: [Hex] -> Text -> Text
horizontalSvg tones srcContent =
    let (_, _, vbW, vbH) = svgViewBox srcContent
        inner = svgInnerContent srcContent
        n = length tones
        gap = fromIntegral _GAP_BRICKS * (vbW / fromIntegral _SQ_PX) :: Double
        totalW = fromIntegral n * vbW + fromIntegral (n - 1) * gap
        heads = T.concat $ zipWith (mkHead vbW gap inner) [0 :: Int ..] tones
     in T.concat
            [ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            , "<svg width=\"" <> showD totalW <> "\""
            , " height=\"" <> showD vbH <> "\""
            , " viewBox=\"0 0 " <> showD totalW <> " " <> showD vbH <> "\"\n"
            , "     xmlns=\"http://www.w3.org/2000/svg\">\n"
            , heads
            , "</svg>\n"
            ]
  where
    _SQ_PX = 14 :: Int
    _GAP_BRICKS = 2 :: Int
    mkHead vbW gap inner i tone =
        let x = fromIntegral i * (vbW + gap) :: Double
            colored = recolorFace tone inner
         in "  <g transform=\"translate(" <> showD x <> ", 0)\">\n"
                <> "    "
                <> colored
                <> "\n  </g>\n"

-- | Build minifig design with horizontal color bands clipped to face path.
minifigBandedSvg :: [Hex] -> Text -> Text
minifigBandedSvg bandColors srcContent =
    let (_, _, vbW, vbH) = svgViewBox srcContent
        faceD = extractFacePathD srcContent
        n = length bandColors
        bandH = vbH / fromIntegral n
        bands = T.concat
            [ "    <rect x=\"0\" y=\""
                <> showD4 (fromIntegral i * bandH)
                <> "\" width=\"" <> showD4 vbW
                <> "\" height=\"" <> showD4 (if i < n - 1 then bandH else vbH - fromIntegral i * bandH)
                <> "\" fill=\"" <> hexText c <> "\"/>\n"
            | (i, c) <- zip [0 ..] bandColors
            ]
        features = extractFeaturesText srcContent
     in T.concat
            [ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            , "<svg width=\"" <> showD vbW <> "\""
            , " height=\"" <> showD vbH <> "\""
            , " viewBox=\"0 0 " <> showD vbW <> " " <> showD vbH <> "\"\n"
            , "     xmlns=\"http://www.w3.org/2000/svg\">\n"
            , "  <defs>\n"
            , "    <clipPath id=\"face-clip\"><path d=\"" <> faceD <> "\"/></clipPath>\n"
            , "  </defs>\n"
            , "  <g clip-path=\"url(#face-clip)\">\n"
            , bands
            , "  </g>\n"
            , "  " <> features <> "\n"
            , "</svg>\n"
            ]

-- | Make a Name with no namespace or prefix.
mkName :: Text -> Name
mkName n = Name n Nothing Nothing

-- | Look up an attribute by local name (ignoring namespace).
attrVal :: Text -> Map.Map Name Text -> Text
attrVal localName = Map.findWithDefault "" (mkName localName)

-- | Extract the 'd' attribute of the face path element using xml-conduit.
extractFacePathD :: Text -> Text
extractFacePathD srcContent =
    case parseText def (TL.fromStrict srcContent) of
        Left _ -> ""
        Right doc ->
            let root = documentRoot doc
             in findFacePathD (elementNodes root)
  where
    findFacePathD [] = ""
    findFacePathD (NodeElement el : rest)
        | isFacePath el =
            attrVal "d" (elementAttributes el)
        | otherwise =
            let inner = findFacePathD (elementNodes el)
             in if T.null inner then findFacePathD rest else inner
    findFacePathD (_ : rest) = findFacePathD rest

    isFacePath el =
        nameLocalName (elementName el) == "path"
            && hasFaceColor (elementAttributes el)

    hasFaceColor attrs =
        T.isInfixOf headSvgFaceColor (attrVal "style" attrs)
            || T.isInfixOf headSvgFaceColor (attrVal "fill" attrs)

-- | Extract non-face-path, non-defs feature nodes as SVG text by
-- re-rendering a filtered version of the source SVG's inner content.
extractFeaturesText :: Text -> Text
extractFeaturesText srcContent =
    case parseText def (TL.fromStrict srcContent) of
        Left _ -> ""
        Right doc ->
            let root = documentRoot doc
                filteredNodes = filter (not . shouldExclude) (elementNodes root)
                filteredRoot = root{elementNodes = filteredNodes}
                filteredDoc = doc{documentRoot = filteredRoot}
                rendered = TL.toStrict $ renderText def filteredDoc
             in extractInnerText rendered
  where
    shouldExclude (NodeElement el) =
        nameLocalName (elementName el) == "defs"
            || isFacePathElem el
    shouldExclude (NodeContent c) = T.null (T.strip c)
    shouldExclude _ = False

    isFacePathElem el =
        nameLocalName (elementName el) == "path"
            && hasFaceColor (elementAttributes el)

    hasFaceColor attrs =
        T.isInfixOf headSvgFaceColor (attrVal "style" attrs)
            || T.isInfixOf headSvgFaceColor (attrVal "fill" attrs)

    extractInnerText t =
        let noDecl = snd $ T.breakOn "<svg" t
            afterOpen = T.drop 1 $ snd $ T.breakOn ">" noDecl
            trimmed = T.strip afterOpen
         in if "</svg>" `T.isSuffixOf` trimmed
                then T.strip $ T.dropEnd (T.length "</svg>") trimmed
                else trimmed

-- ── Number formatting helpers ────────────────────────────────────────────────

showD :: Double -> Text
showD x = T.pack $ formatDouble 6 x

showD4 :: Double -> Text
showD4 x = T.pack $ formatDouble 4 x

formatDouble :: Int -> Double -> String
formatDouble decimals x =
    let factor = 10 ^ decimals :: Integer
        rounded = fromIntegral (round (x * fromIntegral factor) :: Integer) / fromIntegral factor :: Double
        s = show rounded
     in if '.' `elem` s
            then
                let (int, dot_frac) = break (== '.') s
                    frac = tail dot_frac
                    trimmed = reverse $ dropWhile (== '0') $ reverse frac
                 in if null trimmed then int else int ++ "." ++ trimmed
            else s

-- ── Pipeline entry point ────────────────────────────────────────────────────

-- | Generate all 19 design SVGs into the given directory.
generateAllDesigns :: FilePath -> FilePath -> IO ()
generateAllDesigns sourceSvg designDir = do
    createDirectoryIfMissing True designDir
    srcContent <- readFileUtf8 sourceSvg

    let tones = map (\(_, _, h) -> h) skinTones
        rb = map (\(_, _, h, _) -> h) rainbowColors
        nRb = length rb

    -- Square variants (4)
    write "square.svg" $ squareSvg (head tones) srcContent
    write "square-light-nougat.svg" $ squareSvg (tones !! 1) srcContent
    write "square-nougat.svg" $ squareSvg (tones !! 2) srcContent
    write "square-dark-nougat.svg" $ squareSvg (tones !! 3) srcContent

    -- Horizontal skin-tone rotations (4)
    let rotate xs = drop 1 xs ++ take 1 xs
    write "horizontal.svg" $ horizontalSvg tones srcContent
    write "horizontal-rot1.svg" $ horizontalSvg (rotate tones) srcContent
    write "horizontal-rot2.svg" $ horizontalSvg (iterate rotate tones !! 2) srcContent
    write "horizontal-rot3.svg" $ horizontalSvg (iterate rotate tones !! 3) srcContent

    -- Banded single-head variants (2)
    write "minifig-colorful.svg" $ minifigBandedSvg tones srcContent
    write "minifig-rainbow.svg" $ minifigBandedSvg rb srcContent

    -- Horizontal rainbow: 7 frames, each a sliding window of 4 colors
    let windows = [take 4 (drop i (cycle rb)) | i <- [0 .. nRb - 1]]
    write "horizontal-rainbow.svg" $ horizontalSvg (head windows) srcContent
    mapM_
        ( \(i, w) ->
            write ("horizontal-rainbow-rot" <> show (i :: Int) <> ".svg") $
                horizontalSvg w srcContent
        )
        (zip [1 ..] (tail windows))
  where
    write name content = do
        let dst = designDir </> name
        writeFileUtf8 dst content
        putStrLn $ "  Wrote " ++ dst

readFileUtf8 :: FilePath -> IO Text
readFileUtf8 path = decodeUtf8 <$> BS.readFile path

writeFileUtf8 :: FilePath -> Text -> IO ()
writeFileUtf8 path = BS.writeFile path . encodeUtf8
