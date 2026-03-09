{-# LANGUAGE OverloadedStrings #-}
module Logo.Compose (composeLogo) where

import Brand.Colors
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as B64
import qualified Data.ByteString.Char8 as BC
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Directory (createDirectoryIfMissing)
import System.FilePath (takeDirectory)

-- Default constants (matching Python pipeline)
_GAP :: Int
_GAP = 24

_BOTTOM_PAD :: Int
_BOTTOM_PAD = 20

-- | Parse width and height from SVG text.
-- Returns (width, height) as integers (truncated from the SVG float values).
parseSvgDimensions :: Text -> (Int, Int)
parseSvgDimensions t =
    let wStr = extract "width=\""
        hStr = extract "height=\""
     in (readI wStr, readI hStr)
  where
    extract attr =
        T.takeWhile (/= '"') $
            T.drop (T.length attr) $
                snd $ T.breakOn attr t
    readI s = case reads (T.unpack s) of
        [(n, _)] -> n
        _ -> 0

-- | Compose a full logo by appending subtitle text below the brick SVG.
-- Background is always transparent. Nothing = dark text, Just _ = light text.
composeLogo
    :: FilePath
    -- ^ Outfit font path (e.g. @fonts/Outfit-VariableFont_wght.ttf@)
    -> FilePath
    -- ^ input brick SVG
    -> FilePath
    -- ^ output full SVG
    -> Int
    -- ^ txtSize (font size in SVG units)
    -> Maybe Hex
    -- ^ Nothing = light bg (dark text), Just _ = dark bg (light text)
    -> IO ()
composeLogo fontPath inSvg outSvg txtSize mbBg = do
    srcText <- TIO.readFile inSvg
    fontBytes <- BS.readFile fontPath
    let (brickW, brickH) = parseSvgDimensions srcText
        canvasW = brickW
        canvasH = brickH + _GAP + txtSize + _BOTTOM_PAD
        subtitleColor = case mbBg of
            Nothing -> hexText subtitleOnLight
            Just _ -> hexText subtitleOnDark
        fontB64 = BC.unpack (B64.encode fontBytes)
        fontDataUri = "data:font/truetype;base64," ++ fontB64
    let newSvg = buildFullSvg srcText canvasW canvasH brickH txtSize subtitleColor fontDataUri
    createDirectoryIfMissing True (takeDirectory outSvg)
    TIO.writeFile outSvg newSvg
    putStrLn $ "  Composed " ++ outSvg ++ "  (" ++ show canvasW ++ "x" ++ show canvasH ++ ")"

buildFullSvg :: Text -> Int -> Int -> Int -> Int -> Text -> String -> Text
buildFullSvg srcText canvasW canvasH brickH txtSize subtitleColor fontDataUri =
    T.concat
        [ "<?xml version='1.0' encoding='utf-8'?>\n"
        , "<svg"
        , " xmlns=\"http://www.w3.org/2000/svg\""
        , " width=\"" <> showI canvasW <> "\""
        , " height=\"" <> showI canvasH <> "\""
        , " viewBox=\"0 0 " <> showI canvasW <> " " <> showI canvasH <> "\""
        , ">\n"
        , defsElem
        , "<g>"
        , innerContent srcText
        , "</g>"
        , textElem
        , "</svg>"
        ]
  where
    showI = T.pack . show

    defsElem =
        "  <defs><style>"
            <> T.pack
                ( "@font-face { font-family: 'Outfit';"
                    ++ " src: url('"
                    ++ fontDataUri
                    ++ "') format('truetype'); }"
                )
            <> "</style></defs>"

    -- Float y position matching Python: brick_h + GAP + font_size displayed as float
    yFloat = T.pack $ show (fromIntegral (brickH + _GAP + txtSize) :: Double)

    textElem =
        "<text"
            <> " x=\""
            <> showI (canvasW `div` 2)
            <> "\""
            <> " y=\""
            <> yFloat
            <> "\""
            <> " font-family=\"Outfit, sans-serif\""
            <> " font-size=\""
            <> showI txtSize
            <> "\""
            <> " font-weight=\"400\""
            <> " text-anchor=\"middle\""
            <> " textLength=\""
            <> showI canvasW
            <> "\""
            <> " lengthAdjust=\"spacingAndGlyphs\""
            <> " fill=\""
            <> subtitleColor
            <> "\""
            <> ">"
            <> associationName
            <> "</text>"

    -- Strip outer SVG wrapper; preserve trailing newline (last element tail)
    innerContent t =
        let noDecl = stripXmlDecl t
            afterOpen = dropSvgOpenTag noDecl
            noClose = dropSvgClose afterOpen
         in T.stripStart noClose

    stripXmlDecl t =
        case T.breakOn "<svg" t of
            (_, rest) -> rest

    dropSvgOpenTag t =
        case T.breakOn ">" t of
            (_, rest) -> T.drop 1 rest

    dropSvgClose t =
        let s = T.stripEnd t
         in if "</svg>" `T.isSuffixOf` s
                then T.dropEnd (T.length "</svg>") s
                else s
