{-# LANGUAGE OverloadedStrings #-}

{- | Generate design-guide.tokens.json — W3C Design Tokens 2025.10 compliant.

Tokens use proper grouped structure with @$type@ / @$value@ on every token.

  * Color: @$type: "color"@, @$value: { colorSpace, components: [r,g,b], hex }@
  * Dimension: @$type: "dimension"@, @$value: { value, unit: "px"|"rem" }@
  * Duration: @$type: "duration"@, @$value: { value, unit: "ms" }@
  * Cubic Bézier: @$type: "cubicBezier"@, @$value: [p1x, p1y, p2x, p2y]@
  * Typography: @$type: "typography"@ composite.

Non-standard metadata goes in @$extensions@ under @fi.palikkaharrastajat:@
vendor prefix (reverse domain notation per spec §5.2.3).
-}
module Guide.Json (generateDesignGuide, generateDesignGuideBS) where

import Data.Aeson ((.=))
import Data.Aeson qualified as A
import Data.Aeson.Encode.Pretty qualified as AP
import Data.Aeson.Key qualified as AK
import Data.Aeson.Types (Pair)
import Data.ByteString.Lazy qualified as BSL
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Guide.Types
import Numeric (readHex)

-- | Vendor extension key with @fi.palikkaharrastajat:@ prefix.
ext :: Text -> AK.Key
ext k = AK.fromText ("fi.palikkaharrastajat:" <> k)

baseUrl :: Text
baseUrl = "https://logo.palikkaharrastajat.fi"

-- ---------------------------------------------------------------------------
-- W3C Design Tokens 2025.10 value helpers
-- ---------------------------------------------------------------------------

hexByte :: String -> Double
hexByte s = case readHex s of
    ((n, _) : _) -> fromIntegral (n :: Int) / 255.0
    [] -> 0.0

r4 :: Double -> Double
r4 x = fromIntegral (round (x * 10000) :: Int) / 10000.0

-- | Convert "#RRGGBB" to @{ colorSpace: "srgb", components: [r,g,b], hex }@.
colorValue :: Text -> A.Value
colorValue hex_ =
    let stripped = T.unpack (T.dropWhile (== '#') hex_)
        rv = r4 $ hexByte (take 2 stripped)
        gv = r4 $ hexByte (take 2 (drop 2 stripped))
        bv = r4 $ hexByte (take 2 (drop 4 stripped))
     in A.object
            [ "colorSpace" .= ("srgb" :: Text)
            , "components" .= A.toJSON [rv, gv, bv]
            , "hex" .= hex_
            ]

dimValuePx :: Int -> A.Value
dimValuePx n = A.object ["value" .= n, "unit" .= ("px" :: Text)]

dimValueRem :: Double -> A.Value
dimValueRem n = A.object ["value" .= n, "unit" .= ("rem" :: Text)]

durValue :: Int -> A.Value
durValue n = A.object ["value" .= n, "unit" .= ("ms" :: Text)]

easingValue :: Double -> Double -> Double -> Double -> A.Value
easingValue p1x p1y p2x p2y = A.toJSON [p1x, p1y, p2x, p2y]

asset :: Text -> A.Value
asset path = A.object ["file" .= path, "url" .= (baseUrl <> "/" <> path)]

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------

buildBrandColors :: [BrandColor] -> [Pair]
buildBrandColors bcs =
    [ "$type" .= ("color" :: Text)
    , "$description" .= ("Primitive brand palette" :: Text)
    ]
        ++ [ AK.fromText (bcId bc)
            .= A.object
                [ "$value" .= colorValue (hexText (bcHex bc))
                , "$description" .= bcDescription bc
                , "$extensions"
                    .= A.object
                        [ ext "usage" .= bcUsage bc
                        , ext "wcag" .= buildWcagObj (bcWcag bc)
                        ]
                ]
           | bc <- bcs
           ]

buildSkinTones :: [SkinTone] -> [Pair]
buildSkinTones sts =
    [ "$type" .= ("color" :: Text)
    , "$description" .= ("LEGO minifig skin tone palette" :: Text)
    ]
        ++ [ AK.fromText (stId st)
            .= A.object
                [ "$value" .= colorValue (hexText (stHex st))
                , "$description" .= stDescription st
                , "$extensions"
                    .= A.object
                        [ext "wcag" .= buildWcagObj (stWcag st)]
                ]
           | st <- sts
           ]

buildRainbow :: [RainbowColor] -> [Pair]
buildRainbow rcs =
    [ "$type" .= ("color" :: Text)
    , "$description" .= ("Rainbow decorative palette. Do not use as text color on light backgrounds." :: Text)
    ]
        ++ [ AK.fromText (rcId rc)
            .= A.object
                [ "$value" .= colorValue (hexText (rcHex rc))
                , "$description" .= rcDescription rc
                , "$extensions"
                    .= A.object
                        [ext "decorativeOnly" .= True]
                ]
           | rc <- rcs
           ]

buildSemantic :: [SemanticColor] -> [Pair]
buildSemantic scs =
    -- Group by first path segment (e.g. "text", "background", "border")
    let grouped :: Map.Map Text [SemanticColor]
        grouped = foldl (\m sc ->
            let (grp, _rest) = T.breakOn "." (scJsonPath sc)
             in Map.insertWith (++) grp [sc] m
            ) Map.empty scs
     in Map.toAscList grouped >>= \(grpName, items) ->
            [ AK.fromText grpName
                .= A.object
                    ( ["$type" .= ("color" :: Text)]
                        ++ concatMap (semanticEntry grpName) items
                    )
            ]
  where
    semanticEntry grpName sc =
        let path = scJsonPath sc
            name_ = case T.stripPrefix (grpName <> ".") path of
                Just rest -> rest
                Nothing -> path
         in [ AK.fromText name_
                .= A.object
                    [ "$value" .= colorValue (scHex sc)
                    , "$description" .= scDescription sc
                    , "$extensions"
                        .= A.object
                            [ ext "tailwindClass" .= scTailwindClass sc
                            , ext "cssVariable" .= scCssVariable sc
                            ]
                    ]
            ]

buildWcagObj :: [WcagContrast] -> A.Value
buildWcagObj ws =
    A.object
        [ AK.fromText (wcagOn w) .= A.object ["ratio" .= wcagRatio w, "rating" .= wcagRating w]
        | w <- ws
        ]

buildColors :: DesignGuide -> A.Value
buildColors dg =
    A.object
        [ "brand" .= A.object (buildBrandColors (dgBrandColors dg))
        , "skin-tones" .= A.object (buildSkinTones (dgSkinTones dg))
        , "rainbow" .= A.object (buildRainbow (dgRainbowColors dg))
        , "semantic" .= A.object (buildSemantic (dgSemanticColors dg))
        ]

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

buildTypography :: DesignGuide -> A.Value
buildTypography dg =
    let tc = dgTypography dg
     in A.object
            [ "primaryFont"
                .= A.object
                    [ "$type" .= ("fontFamily" :: Text)
                    , "$value" .= tcFontFamily tc
                    , "$description" .= ("Self-hosted variable font. Weight range 100\x2013\&900. License: " <> tcFontLicense tc)
                    , "$extensions"
                        .= A.object
                            [ ext "style" .= ("variable" :: Text)
                            , ext "axes" .= A.toJSON [A.object ["tag" .= ("wght" :: Text), "min" .= (100 :: Int), "max" .= (900 :: Int)]]
                            , ext "files" .= A.object ["variableTTF" .= asset (tcFontFile tc)]
                            , ext "license" .= tcFontLicense tc
                            , ext "licenseFile" .= asset (tcFontLicenseFile tc)
                            ]
                    ]
            , "scale"
                .= A.object
                    ( ["$type" .= ("typography" :: Text)]
                        ++ [ AK.fromText (tseName e)
                            .= A.object
                                [ "$value"
                                    .= A.object
                                        [ "fontFamily" .= tcFontFamily tc
                                        , "fontSize" .= A.object ["value" .= tseSizePx e, "unit" .= ("px" :: Text)]
                                        , "fontWeight" .= tseWeight e
                                        , "lineHeight" .= tseLineHeight e
                                        , "letterSpacing" .= A.object ["value" .= tseLetterSpacingEm e, "unit" .= ("em" :: Text)]
                                        ]
                                , "$description" .= tseDescription e
                                , "$extensions"
                                    .= A.object
                                        [ ext "cssClass" .= tseCssClass e
                                        , ext "fontSizeRem" .= tseSizeRem e
                                        ]
                                ]
                           | e <- tcScale tc
                           ]
                    )
            , "$extensions"
                .= A.object
                    [ext "usageRules" .= tcUsageRules tc]
            ]

-- ---------------------------------------------------------------------------
-- Spacing
-- ---------------------------------------------------------------------------

buildSpacing :: DesignGuide -> A.Value
buildSpacing dg =
    let sp = dgSpacing dg
     in A.object
            [ "baseUnit"
                .= A.object
                    [ "$value" .= dimValuePx (spcBaseUnit sp)
                    , "$type" .= ("dimension" :: Text)
                    , "$description" .= ("All spacing values are multiples of " <> T.pack (show (spcBaseUnit sp)) <> "px.")
                    ]
            , "scale"
                .= A.object
                    ( ["$type" .= ("dimension" :: Text)]
                        ++ [ AK.fromText (ssName s)
                            .= A.object
                                [ "$value" .= dimValuePx (ssPx s)
                                , "$description" .= ssDescription s
                                , "$extensions"
                                    .= A.object
                                        [ ext "multiplier" .= ssMultiplier s
                                        , ext "rem" .= ssRem s
                                        , ext "tailwindClass" .= ssTailwindClass s
                                        ]
                                ]
                           | s <- spcScale sp
                           ]
                    )
            , "layout"
                .= A.object
                    [ "contentWidth"
                        .= A.object
                            [ "$value" .= dimValuePx (spcContentWidthPx sp)
                            , "$type" .= ("dimension" :: Text)
                            , "$description" .= ("Maximum content column width." :: Text)
                            , "$extensions" .= A.object [ext "tailwindClass" .= spcContentWidthTailwind sp]
                            ]
                    , "pagePaddingX"
                        .= A.object
                            [ "$value" .= dimValuePx (spcPagePaddingXPx sp)
                            , "$type" .= ("dimension" :: Text)
                            , "$extensions" .= A.object [ext "tailwindClass" .= spcPagePaddingXTailwind sp]
                            ]
                    , "pageWrapper"
                        .= A.object
                            [ "$description" .= ("Apply to every page-level container." :: Text)
                            , "$extensions" .= A.object [ext "tailwindClass" .= spcPageWrapperClass sp]
                            ]
                    , "breakpoints"
                        .= A.object
                            ( ["$type" .= ("dimension" :: Text)]
                                ++ [ AK.fromText (bpName bp)
                                    .= A.object
                                        [ "$value" .= dimValuePx (bpPx bp)
                                        , "$description" .= (bpName bp <> " breakpoint \x2014 min-width " <> T.pack (show (bpPx bp)) <> "px")
                                        ]
                                   | bp <- spcBreakpoints sp
                                   ]
                            )
                    , "borderRadius"
                        .= A.object
                            ( ["$type" .= ("dimension" :: Text)]
                                ++ [ AK.fromText (brName br)
                                    .= A.object
                                        [ "$value" .= dimValuePx (brPx br)
                                        , "$extensions" .= A.object [ext "tailwindClass" .= brTailwindClass br]
                                        ]
                                   | br <- spcBorderRadii sp
                                   ]
                            )
                    ]
            , "$extensions"
                .= A.object
                    [ ext "responsiveGrids"
                        .= A.toJSON
                            [ A.object
                                [ "name" .= rgName rg
                                , "description" .= rgDescription rg
                                , "columns"
                                    .= A.object
                                        [ "mobile" .= rgMobile rg
                                        , "sm" .= rgSm rg
                                        , "md" .= rgMd rg
                                        , "lg" .= rgLg rg
                                        , "xl" .= rgXl rg
                                        ]
                                ]
                            | rg <- spcResponsiveGrids sp
                            ]
                    , ext "responsiveRules" .= spcResponsiveRules sp
                    ]
            ]

-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------

buildMotion :: DesignGuide -> A.Value
buildMotion dg =
    let mc = dgMotion dg
     in A.object
            [ "$description" .= ("All animations must respect prefers-reduced-motion." :: Text)
            , "duration"
                .= A.object
                    ( ["$type" .= ("duration" :: Text)]
                        ++ [ AK.fromText (mdName d)
                            .= A.object
                                [ "$value" .= durValue (mdMs d)
                                , "$description" .= mdDescription d
                                , "$extensions" .= A.object [ext "cssVariable" .= mdCssVariable d]
                                ]
                           | d <- mcDurations mc
                           ]
                    )
            , "easing"
                .= A.object
                    ( ["$type" .= ("cubicBezier" :: Text)]
                        ++ [ AK.fromText (meName e)
                            .= A.object
                                [ "$value" .= easingValue (meP1x e) (meP1y e) (meP2x e) (meP2y e)
                                , "$description" .= meDescription e
                                , "$extensions"
                                    .= A.object
                                        [ ext "cssValue"
                                            .= ( "cubic-bezier("
                                                    <> T.pack (show (meP1x e))
                                                    <> ", "
                                                    <> T.pack (show (meP1y e))
                                                    <> ", "
                                                    <> T.pack (show (meP2x e))
                                                    <> ", "
                                                    <> T.pack (show (meP2y e))
                                                    <> ")"
                                               )
                                        ]
                                ]
                           | e <- mcEasings mc
                           ]
                    )
            , "$extensions" .= A.object [ext "usageRules" .= mcUsageRules mc]
            ]

-- ---------------------------------------------------------------------------
-- Components
-- ---------------------------------------------------------------------------

buildComponents :: DesignGuide -> A.Value
buildComponents dg =
    A.object
        [ "$description" .= ("Elm UI component catalog. All components live in src/Component/." :: Text)
        , "components"
            .= A.toJSON
                [ A.object
                    [ "name" .= csName c
                    , "module" .= csModule c
                    , "$description" .= csDescription c
                    , "props" .= csProps c
                    , "tokenDependencies" .= csTokenDependencies c
                    ]
                | c <- dgComponents dg
                ]
        ]

-- ---------------------------------------------------------------------------
-- Root document
-- ---------------------------------------------------------------------------

buildDesignGuideJson :: DesignGuide -> A.Value
buildDesignGuideJson dg =
    let m = dgMeta dg
     in A.object
            [ "version" .= metaVersion m
            , "$description"
                .= ( "Machine-readable design guide for "
                        <> metaOrganization m
                        <> ". Conforms to W3C Design Tokens 2025.10. Generated by brand-gen \x2014 do not edit by hand."
                   )
            , "organization"
                .= A.object
                    [ "name" .= metaOrganization m
                    , "canonicalUrl" .= metaCanonicalUrl m
                    , "brandGuideUrl" .= metaBrandGuideUrl m
                    ]
            , "colors" .= buildColors dg
            , "typography" .= buildTypography dg
            , "spacing" .= buildSpacing dg
            , "motion" .= buildMotion dg
            , "$extensions"
                .= A.object
                    [ ext "components" .= buildComponents dg
                    ]
            ]

-- | Pure: produce pretty-printed JSON bytes from a 'DesignGuide'.
generateDesignGuideBS :: DesignGuide -> BSL.ByteString
generateDesignGuideBS dg =
    let cfg = AP.defConfig{AP.confIndent = AP.Spaces 2, AP.confTrailingNewline = True}
     in AP.encodePretty' cfg (buildDesignGuideJson dg)

-- | Write @design-guide.tokens.json@ from a 'DesignGuide'.
generateDesignGuide :: DesignGuide -> IO ()
generateDesignGuide dg = do
    BSL.writeFile "design-guide.tokens.json" (generateDesignGuideBS dg)
    putStrLn "Wrote design-guide.tokens.json"
