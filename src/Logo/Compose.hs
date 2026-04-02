{-# LANGUAGE OverloadedStrings #-}

{- | Compose a brick-logo SVG with a subtitle text element below it.

No brand constants are hardcoded here; all text and colours are supplied
by the caller.
-}
module Logo.Compose (
    PadXMode (..),
    loadFont,
    composeLogoWith,
    composeLogoFrom,
) where

import Data.ByteString qualified as BS
import Data.ByteString.Base64 qualified as B64
import Data.ByteString.Char8 qualified as BC
import Data.ByteString.Lazy qualified as LBS
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding qualified as TE
import Text.XML qualified as XML

-- | Gap in SVG px between the brick grid and the subtitle text.
_GAP :: Int
_GAP = 24

-- | Padding below the subtitle text, in SVG px.
_BOTTOM_PAD :: Int
_BOTTOM_PAD = 20

-- | Parse width and height from SVG text using the XML parser.
parseSvgDimensions :: Text -> (Int, Int)
parseSvgDimensions t =
    case XML.parseLBS XML.def (LBS.fromStrict (TE.encodeUtf8 t)) of
        Left _ -> (0, 0)
        Right doc ->
            let attrs = XML.elementAttributes (XML.documentRoot doc)
                readAttr k = case Map.lookup (XML.Name k Nothing Nothing) attrs of
                    Nothing -> 0
                    Just v -> case reads (T.unpack v) of
                        [(n, _)] -> n
                        _ -> 0
             in (readAttr "width", readAttr "height")

-- | Load a font file and return it as a @data:@ URI string.
loadFont :: FilePath -> IO String
loadFont fontPath = do
    fontBytes <- BS.readFile fontPath
    return $ "data:font/truetype;base64," ++ BC.unpack (B64.encode fontBytes)

{- | Compose a full logo from an in-memory brick SVG.

Pure variant: the caller supplies an already-loaded font data URI
(see 'loadFont').  'subtitleColor' should be a CSS colour value,
e.g. @\"#05131D\"@.

Pass 'Nothing' for the second text line to get a single-line layout.
Pass e.g. @Just \"Palikkaharrastajat ry\"@ to render a second line below.

| How to determine the horizontal padding added on each side of the canvas.
-}
data PadXMode
    = -- | Fixed SVG px each side (use 0 for no extra padding)
      FixedPadX Int
    | -- | Compute padding so that canvasW == canvasH
      AutoSquare

-- 'padXMode' controls extra horizontal whitespace beyond the brick SVG's own
-- padding.  Use 'FixedPadX 0' for the default layout, 'AutoSquare' to make
-- the composed canvas square (useful for square logo marks).
composeLogoWith ::
    -- | Font data URI (from 'loadFont')
    String ->
    -- | Subtitle text line 1
    Text ->
    -- | Subtitle text line 2 (Nothing = single-line)
    Maybe Text ->
    -- | Subtitle CSS colour (e.g. @\"#05131D\"@)
    Text ->
    -- | Input brick SVG text
    Text ->
    -- | Font size in SVG units
    Int ->
    -- | Font weight (e.g. 400 or 700)
    Int ->
    -- | Horizontal padding mode
    PadXMode ->
    Text
composeLogoWith fontDataUri subtitleText mSubtitleText2 subtitleColor srcText txtSize fontWeight padXMode =
    let (brickW, brickH) = parseSvgDimensions srcText
        lineGap = (txtSize * 13) `div` 10 -- 1.3× line spacing for second line
        canvasH =
            brickH
                + _GAP
                + txtSize
                + maybe 0 (const lineGap) mSubtitleText2
                + _BOTTOM_PAD
        -- For AutoSquare: canvasW = canvasH exactly (guaranteed square regardless
        -- of parity), translate the brick group by a fractional SVG offset.
        (canvasW, translateX) = case padXMode of
            FixedPadX n ->
                ( brickW + 2 * n
                , fromIntegral n :: Double
                )
            AutoSquare ->
                ( canvasH
                , fromIntegral (canvasH - brickW) / 2.0
                )
     in buildFullSvg
            srcText
            canvasW
            canvasH
            brickH
            txtSize
            fontWeight
            subtitleColor
            fontDataUri
            subtitleText
            mSubtitleText2
            lineGap
            translateX

-- | Convenience wrapper: load the font from disk then call 'composeLogoWith'.
composeLogoFrom ::
    -- | Outfit variable-font path
    FilePath ->
    -- | Subtitle text line 1
    Text ->
    -- | Subtitle text line 2 (Nothing = single-line)
    Maybe Text ->
    -- | Subtitle CSS colour (e.g. @\"#05131D\"@)
    Text ->
    -- | Input brick SVG text
    Text ->
    -- | Font size in SVG units
    Int ->
    -- | Font weight (e.g. 400 or 700)
    Int ->
    -- | Horizontal padding mode
    PadXMode ->
    IO Text
composeLogoFrom fontPath subtitleText mSubtitleText2 subtitleColor srcText txtSize fontWeight padXMode = do
    fontDataUri <- loadFont fontPath
    return $ composeLogoWith fontDataUri subtitleText mSubtitleText2 subtitleColor srcText txtSize fontWeight padXMode

-- ── Internal SVG builder ─────────────────────────────────────────────────────

buildFullSvg ::
    -- | brick SVG source
    Text ->
    -- | canvasW
    Int ->
    -- | canvasH
    Int ->
    -- | brickH
    Int ->
    -- | txtSize
    Int ->
    -- | fontWeight (e.g. 400, 700)
    Int ->
    -- | subtitle colour
    Text ->
    -- | font data URI
    String ->
    -- | subtitle text line 1
    Text ->
    -- | subtitle text line 2 (Nothing = single-line)
    Maybe Text ->
    -- | line gap for line 2 (ignored when Nothing)
    Int ->
    -- | brick group translate-X (SVG units, may be fractional)
    Double ->
    Text
buildFullSvg srcText canvasW canvasH brickH txtSize fontWeight subtitleColor fontDataUri subtitleText mSubtitleText2 lineGap translateX =
    T.concat
        [ "<?xml version='1.0' encoding='utf-8'?>\n"
        , "<svg"
        , " xmlns=\"http://www.w3.org/2000/svg\""
        , " width=\"" <> showI canvasW <> "\""
        , " height=\"" <> showI canvasH <> "\""
        , " viewBox=\"0 0 " <> showI canvasW <> " " <> showI canvasH <> "\""
        , ">\n"
        , defsElem
        , if translateX > 0
            then "<g transform=\"translate(" <> T.pack (show translateX) <> ",0)\">"
            else "<g>"
        , innerContent srcText
        , "</g>"
        , textElems
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

    cx = canvasW `div` 2

    -- y1: baseline of first text line
    y1 = brickH + _GAP + txtSize

    sharedAttrs =
        " font-family=\"Outfit, sans-serif\""
            <> " font-size=\""
            <> showI txtSize
            <> "\""
            <> " font-weight=\""
            <> showI fontWeight
            <> "\""
            <> " text-anchor=\"middle\""
            <> " fill=\""
            <> subtitleColor
            <> "\""

    mkTextElem y txt =
        "<text"
            <> " x=\""
            <> showI cx
            <> "\""
            <> " y=\""
            <> T.pack (show (fromIntegral y :: Double))
            <> "\""
            <> sharedAttrs
            <> ">"
            <> txt
            <> "</text>"

    textElems =
        mkTextElem y1 subtitleText
            <> case mSubtitleText2 of
                Nothing -> ""
                Just line2 -> mkTextElem (y1 + lineGap) line2

    innerContent t =
        let noDecl = snd $ T.breakOn "<svg" t
            afterOpen = T.drop 1 $ snd $ T.breakOn ">" noDecl
            s = T.stripEnd afterOpen
            noClose =
                if "</svg>" `T.isSuffixOf` s
                    then T.dropEnd (T.length "</svg>") s
                    else s
         in T.stripStart noClose
