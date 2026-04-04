{-# LANGUAGE OverloadedStrings #-}

{- | Generate a publishable Elm package from design tokens.

Output is a list of (relative path, file content) pairs rooted at
@dist/design-tokens-elm/@.
-}
module DesignTokensGen.ElmGen (generateElmPackage) where

import Data.Char (toLower, toUpper)
import Data.Text (Text)
import Data.Text qualified as T
import DesignTokensGen.Types

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

{- | Generate all files for the Elm package.  Each pair is
  @(relativePath, fileContent)@.
-}
generateElmPackage :: DesignGuide -> [(FilePath, Text)]
generateElmPackage dg =
    [ ("elm.json", elmJson)
    , ("src/DesignTokens.elm", rootModule dg)
    , ("src/DesignTokens/Colors.elm", colorsModule dg)
    , ("src/DesignTokens/Typography.elm", typographyModule dg)
    , ("src/DesignTokens/Spacing.elm", spacingModule dg)
    , ("src/DesignTokens/Motion.elm", motionModule dg)
    , ("src/DesignTokens/Effects.elm", effectsModule dg)
    , ("src/DesignTokens/Accessibility.elm", accessibilityModule dg)
    , ("src/DesignTokens/Opacity.elm", opacityModule dg)
    , ("src/DesignTokens/Components.elm", componentsModule dg)
    , ("src/DesignTokens/Guide/Colors.elm", guideColorsModule dg)
    , ("src/DesignTokens/Guide/Logos.elm", guideLogosModule dg)
    ]

-- ---------------------------------------------------------------------------
-- elm.json
-- ---------------------------------------------------------------------------

elmJson :: Text
elmJson =
    T.unlines
        [ "{"
        , "    \"type\": \"package\","
        , "    \"name\": \"palikkaharrastajat/design-tokens\","
        , "    \"summary\": \"Design tokens for Suomen Palikkaharrastajat ry\","
        , "    \"license\": \"BSD-3-Clause\","
        , "    \"version\": \"1.0.0\","
        , "    \"exposed-modules\": ["
        , "        \"DesignTokens\","
        , "        \"DesignTokens.Colors\","
        , "        \"DesignTokens.Typography\","
        , "        \"DesignTokens.Spacing\","
        , "        \"DesignTokens.Motion\","
        , "        \"DesignTokens.Effects\","
        , "        \"DesignTokens.Accessibility\","
        , "        \"DesignTokens.Opacity\","
        , "        \"DesignTokens.Components\","
        , "        \"DesignTokens.Guide.Colors\","
        , "        \"DesignTokens.Guide.Logos\""
        , "    ],"
        , "    \"elm-version\": \"0.19.0 <= v < 0.20.0\","
        , "    \"dependencies\": {"
        , "        \"elm/core\": \"1.0.0 <= v < 2.0.0\""
        , "    },"
        , "    \"test-dependencies\": {}"
        , "}"
        ]

-- ---------------------------------------------------------------------------
-- Root module
-- ---------------------------------------------------------------------------

rootModule :: DesignGuide -> Text
rootModule dg =
    T.unlines
        [ "module DesignTokens exposing (version)"
        , ""
        , ""
        , "{-| Design tokens for Suomen Palikkaharrastajat ry."
        , ""
        , "Import sub-modules directly:"
        , ""
        , "    import DesignTokens.Colors"
        , "    import DesignTokens.Typography"
        , "    import DesignTokens.Spacing"
        , "    import DesignTokens.Motion"
        , "    import DesignTokens.Effects"
        , "    import DesignTokens.Accessibility"
        , "    import DesignTokens.Opacity"
        , "    import DesignTokens.Components"
        , ""
        , "-}"
        , ""
        , ""
        , "{-| Token version. -}"
        , "version : String"
        , "version ="
        , "    " <> quote (metaVersion $ dgMeta dg)
        ]

-- ---------------------------------------------------------------------------
-- Colors module
-- ---------------------------------------------------------------------------

colorsModule :: DesignGuide -> Text
colorsModule dg =
    let exports =
            map (elmName . bcId) (dgBrandColors dg)
                ++ map (\st -> "skinTone" <> pascal (stId st)) (dgSkinTones dg)
                ++ map (\rc -> "rainbow" <> pascal (rcId rc)) (dgRainbowColors dg)
                ++ map (elmName . scId) (dgSemanticColors dg)
     in T.unlines $
            [ moduleHeader "DesignTokens.Colors" exports
            , ""
            , ""
            , "{-| Brand, skin-tone, rainbow, and semantic color tokens."
            , ""
            , "All values are CSS hex strings (e.g. \"#05131D\")."
            , ""
            , "-}"
            , ""
            ]
                ++ concatMap brandColorDef (dgBrandColors dg)
                ++ ["", ""]
                ++ concatMap skinToneDef (dgSkinTones dg)
                ++ ["", ""]
                ++ concatMap rainbowDef (dgRainbowColors dg)
                ++ ["", ""]
                ++ concatMap semanticDef (dgSemanticColors dg)

brandColorDef :: BrandColor -> [Text]
brandColorDef bc =
    [ ""
    , "{-| " <> bcName bc <> " — " <> bcDescription bc <> " -}"
    , elmName (bcId bc) <> " : String"
    , elmName (bcId bc) <> " ="
    , "    " <> quote (hexText $ bcHex bc)
    ]

skinToneDef :: SkinTone -> [Text]
skinToneDef st =
    [ ""
    , "{-| " <> stName st <> " — " <> stDescription st <> " -}"
    , "skinTone" <> pascal (stId st) <> " : String"
    , "skinTone" <> pascal (stId st) <> " ="
    , "    " <> quote (hexText $ stHex st)
    ]

rainbowDef :: RainbowColor -> [Text]
rainbowDef rc =
    [ ""
    , "{-| " <> rcName rc <> " — " <> rcDescription rc <> " -}"
    , "rainbow" <> pascal (rcId rc) <> " : String"
    , "rainbow" <> pascal (rcId rc) <> " ="
    , "    " <> quote (hexText $ rcHex rc)
    ]

semanticDef :: SemanticColor -> [Text]
semanticDef sc =
    [ ""
    , "{-| " <> scDescription sc <> " -}"
    , elmName (scId sc) <> " : String"
    , elmName (scId sc) <> " ="
    , "    " <> quote (scHex sc)
    ]

-- ---------------------------------------------------------------------------
-- Typography module
-- ---------------------------------------------------------------------------

typographyModule :: DesignGuide -> Text
typographyModule dg =
    let tc = dgTypography dg
        scaleExports ts =
            let n = elmName (tseName ts)
             in [n <> "SizePx", n <> "SizeRem", n <> "Weight", n <> "LineHeight"]
        exports = "fontFamily" : concatMap scaleExports (tcScale tc)
     in T.unlines $
            [ moduleHeader "DesignTokens.Typography" exports
            , ""
            , ""
            , "{-| Typography tokens — font family and type scale. -}"
            , ""
            , ""
            , "{-| Primary font stack. -}"
            , "fontFamily : List String"
            , "fontFamily ="
            , "    " <> elmList (map quote $ tcFontFamily tc)
            ]
                ++ concatMap scaleDef (tcScale tc)

scaleDef :: TypeScaleEntry -> [Text]
scaleDef ts =
    let n = elmName (tseName ts)
     in [ ""
        , ""
        , "{-| " <> tseDescription ts <> " -}"
        , n <> "SizePx : Int"
        , n <> "SizePx ="
        , "    " <> showT (tseSizePx ts)
        , ""
        , ""
        , n <> "SizeRem : Float"
        , n <> "SizeRem ="
        , "    " <> showDouble (tseSizeRem ts)
        , ""
        , ""
        , n <> "Weight : Int"
        , n <> "Weight ="
        , "    " <> showT (tseWeight ts)
        , ""
        , ""
        , n <> "LineHeight : Float"
        , n <> "LineHeight ="
        , "    " <> showDouble (tseLineHeight ts)
        ]

-- ---------------------------------------------------------------------------
-- Spacing module
-- ---------------------------------------------------------------------------

spacingModule :: DesignGuide -> Text
spacingModule dg =
    let sp = dgSpacing dg
        exports =
            ["baseUnit"]
                ++ map (elmName . ssName) (spcScale sp)
                ++ map (\bp -> "breakpoint" <> pascal (bpName bp)) (spcBreakpoints sp)
                ++ map (\br -> "borderRadius" <> pascal (brName br)) (spcBorderRadii sp)
     in T.unlines $
            [ moduleHeader "DesignTokens.Spacing" exports
            , ""
            , ""
            , "{-| Spacing scale, breakpoints, and border radii. -}"
            , ""
            , ""
            , "{-| Base spacing unit in pixels. -}"
            , "baseUnit : Int"
            , "baseUnit ="
            , "    " <> showT (spcBaseUnit sp)
            ]
                ++ concatMap spacingStepDef (spcScale sp)
                ++ ["", ""]
                ++ concatMap breakpointDef (spcBreakpoints sp)
                ++ ["", ""]
                ++ concatMap borderRadiusDef (spcBorderRadii sp)

spacingStepDef :: SpacingStep -> [Text]
spacingStepDef ss =
    let n = elmName (ssName ss)
     in [ ""
        , ""
        , "{-| " <> ssDescription ss <> " -}"
        , n <> " : Int"
        , n <> " ="
        , "    " <> showT (ssPx ss)
        ]

breakpointDef :: Breakpoint -> [Text]
breakpointDef bp =
    [ ""
    , "{-| Breakpoint " <> bpName bp <> " in pixels. -}"
    , "breakpoint" <> pascal (bpName bp) <> " : Int"
    , "breakpoint" <> pascal (bpName bp) <> " ="
    , "    " <> showT (bpPx bp)
    ]

borderRadiusDef :: BorderRadius -> [Text]
borderRadiusDef br =
    [ ""
    , "{-| Border radius " <> brName br <> " in pixels. -}"
    , "borderRadius" <> pascal (brName br) <> " : Int"
    , "borderRadius" <> pascal (brName br) <> " ="
    , "    " <> showT (brPx br)
    ]

-- ---------------------------------------------------------------------------
-- Motion module
-- ---------------------------------------------------------------------------

motionModule :: DesignGuide -> Text
motionModule dg =
    let mc = dgMotion dg
        exports =
            map (\md -> "duration" <> pascal (mdName md)) (mcDurations mc)
                ++ map (\me -> "easing" <> pascal (meName me)) (mcEasings mc)
     in T.unlines $
            [ moduleHeader "DesignTokens.Motion" exports
            , ""
            , ""
            , "{-| Motion tokens — durations (ms) and cubic-bezier easings. -}"
            , ""
            ]
                ++ concatMap durationDef (mcDurations mc)
                ++ ["", ""]
                ++ concatMap easingDef (mcEasings mc)

durationDef :: MotionDuration -> [Text]
durationDef md =
    [ ""
    , "{-| " <> mdDescription md <> " -}"
    , "duration" <> pascal (mdName md) <> " : Int"
    , "duration" <> pascal (mdName md) <> " ="
    , "    " <> showT (mdMs md)
    ]

easingDef :: MotionEasing -> [Text]
easingDef me =
    let n = "easing" <> pascal (meName me)
     in [ ""
        , "{-| " <> meDescription me <> " -}"
        , n <> " : { p1x : Float, p1y : Float, p2x : Float, p2y : Float }"
        , n <> " ="
        , "    { p1x = " <> showDouble (meP1x me)
        , "    , p1y = " <> showDouble (meP1y me)
        , "    , p2x = " <> showDouble (meP2x me)
        , "    , p2y = " <> showDouble (meP2y me)
        , "    }"
        ]

-- ---------------------------------------------------------------------------
-- Effects module
-- ---------------------------------------------------------------------------

effectsModule :: DesignGuide -> Text
effectsModule dg =
    let ec = dgEffects dg
        exports =
            map (elmName . shName) (ecShadows ec)
                ++ map (elmName . ziName) (ecZIndices ec)
     in T.unlines $
            [ moduleHeader "DesignTokens.Effects" exports
            , ""
            , ""
            , "{-| Shadow and z-index tokens. -}"
            , ""
            ]
                ++ concatMap shadowDef (ecShadows ec)
                ++ ["", ""]
                ++ concatMap zIndexDef (ecZIndices ec)

shadowDef :: Shadow -> [Text]
shadowDef s =
    let n = elmName (shName s)
     in [ ""
        , "{-| " <> shDescription s <> " -}"
        , n <> " : String"
        , n <> " ="
        , "    " <> quote (shValue s)
        ]

zIndexDef :: ZIndex -> [Text]
zIndexDef z =
    [ ""
    , "{-| " <> ziDescription z <> " -}"
    , elmName (ziName z) <> " : Int"
    , elmName (ziName z) <> " ="
    , "    " <> showT (ziValue z)
    ]

-- ---------------------------------------------------------------------------
-- Accessibility module
-- ---------------------------------------------------------------------------

accessibilityModule :: DesignGuide -> Text
accessibilityModule dg =
    let ac = dgAccessibility dg
        ringExports fr =
            let n = elmName (frName fr)
             in [n <> "WidthPx", n <> "OffsetPx", n <> "Color", n <> "TailwindClass"]
        exports = concatMap ringExports (acFocusRings ac)
     in T.unlines $
            [ moduleHeader "DesignTokens.Accessibility" exports
            , ""
            , ""
            , "{-| Focus ring tokens for accessible interactive elements. -}"
            , ""
            ]
                ++ concatMap focusRingDef (acFocusRings ac)

focusRingDef :: FocusRing -> [Text]
focusRingDef fr =
    let n = elmName (frName fr)
     in [ ""
        , "{-| " <> frDescription fr <> " -}"
        , n <> "WidthPx : Int"
        , n <> "WidthPx ="
        , "    " <> showT (frWidthPx fr)
        , ""
        , ""
        , n <> "OffsetPx : Int"
        , n <> "OffsetPx ="
        , "    " <> showT (frOffsetPx fr)
        , ""
        , ""
        , n <> "Color : String"
        , n <> "Color ="
        , "    " <> quote (frColor fr)
        , ""
        , ""
        , n <> "TailwindClass : String"
        , n <> "TailwindClass ="
        , "    " <> quote (frTailwindClass fr)
        ]

-- ---------------------------------------------------------------------------
-- Opacity module
-- ---------------------------------------------------------------------------

opacityModule :: DesignGuide -> Text
opacityModule dg =
    let exports = map (elmName . osName) (ocScale $ dgOpacity dg)
     in T.unlines $
            [ moduleHeader "DesignTokens.Opacity" exports
            , ""
            , ""
            , "{-| Opacity scale tokens (0–100). -}"
            , ""
            ]
                ++ concatMap opacityDef (ocScale $ dgOpacity dg)

opacityDef :: OpacityStep -> [Text]
opacityDef os =
    [ ""
    , "{-| " <> osDescription os <> " -}"
    , elmName (osName os) <> " : Int"
    , elmName (osName os) <> " ="
    , "    " <> showT (osValue os)
    ]

-- ---------------------------------------------------------------------------
-- Components module
-- ---------------------------------------------------------------------------

componentsModule :: DesignGuide -> Text
componentsModule dg =
    let exports = map (\cs -> elmName (csName cs) <> "TokenDeps") (dgComponents dg)
     in T.unlines $
            [ moduleHeader "DesignTokens.Components" exports
            , ""
            , ""
            , "{-| Component token mappings."
            , ""
            , "Each value lists the design token paths that the component depends on."
            , ""
            , "-}"
            , ""
            ]
                ++ concatMap componentDef (dgComponents dg)

componentDef :: ComponentSpec -> [Text]
componentDef cs =
    let n = elmName (csName cs)
     in [ ""
        , "{-| " <> csDescription cs <> " -}"
        , n <> "TokenDeps : List String"
        , n <> "TokenDeps ="
        , "    " <> elmList (map quote $ csTokenDependencies cs)
        ]

-- ---------------------------------------------------------------------------
-- Guide.Colors module
-- ---------------------------------------------------------------------------

guideColorsModule :: DesignGuide -> Text
guideColorsModule dg =
    T.unlines $
        [ moduleHeader
            "DesignTokens.Guide.Colors"
            [ "ColorEntry"
            , "SkinToneEntry"
            , "RainbowColor"
            , "brandColors"
            , "skinTones"
            , "rainbowColors"
            ]
        , ""
        , ""
        , "{-| Structured colour data for brand guide pages."
        , ""
        , "Use these lists to render colour palettes, swatches, and documentation."
        , "Hex values are kept in sync with 'DesignTokens.Colors'."
        , ""
        , "-}"
        , ""
        , ""
        , "{-| A brand colour entry with display metadata. -}"
        , "type alias ColorEntry ="
        , "    { hex : String"
        , "    , id : String"
        , "    , name : String"
        , "    , description : String"
        , "    , usage : List String"
        , "    }"
        , ""
        , ""
        , "{-| A skin-tone entry with display metadata. -}"
        , "type alias SkinToneEntry ="
        , "    { hex : String"
        , "    , id : String"
        , "    , name : String"
        , "    , description : String"
        , "    }"
        , ""
        , ""
        , "{-| A rainbow colour entry with display metadata. -}"
        , "type alias RainbowColor ="
        , "    { hex : String"
        , "    , name : String"
        , "    , description : String"
        , "    }"
        , ""
        , ""
        , "{-| Brand colour palette. -}"
        , "brandColors : List ColorEntry"
        , "brandColors ="
        , "    " <> elmRecordList (map brandColorRecord $ dgBrandColors dg)
        , ""
        , ""
        , "{-| Minifig skin-tone palette. -}"
        , "skinTones : List SkinToneEntry"
        , "skinTones ="
        , "    " <> elmRecordList (map skinToneRecord $ dgSkinTones dg)
        , ""
        , ""
        , "{-| Rainbow colour palette. -}"
        , "rainbowColors : List RainbowColor"
        , "rainbowColors ="
        , "    " <> elmRecordList (map rainbowRecord $ dgRainbowColors dg)
        ]

brandColorRecord :: BrandColor -> Text
brandColorRecord bc =
    elmRecord
        [ ("hex", quote $ hexText $ bcHex bc)
        , ("id", quote $ bcId bc)
        , ("name", quote $ bcName bc)
        , ("description", quote $ bcDescriptionFi bc)
        , ("usage", elmList (map quote $ bcUsage bc))
        ]

skinToneRecord :: SkinTone -> Text
skinToneRecord st =
    elmRecord
        [ ("hex", quote $ hexText $ stHex st)
        , ("id", quote $ stId st)
        , ("name", quote $ stName st)
        , ("description", quote $ stDescription st)
        ]

rainbowRecord :: RainbowColor -> Text
rainbowRecord rc =
    elmRecord
        [ ("hex", quote $ hexText $ rcHex rc)
        , ("name", quote $ rcName rc)
        , ("description", quote $ rcDescription rc)
        ]

-- ---------------------------------------------------------------------------
-- Guide.Logos module
-- ---------------------------------------------------------------------------

guideLogosModule :: DesignGuide -> Text
guideLogosModule dg =
    let lg = dgLogos dg
     in T.unlines $
            [ moduleHeader
                "DesignTokens.Guide.Logos"
                [ "LogoVariant"
                , "squareVariants"
                , "squareFullVariants"
                , "horizontalVariants"
                ]
            , ""
            , ""
            , "{-| Structured logo variant data for brand guide pages."
            , ""
            , "Use these lists to render logo galleries and download links."
            , ""
            , "-}"
            , ""
            , ""
            , "{-| One downloadable logo variant with all its rendering properties. -}"
            , "type alias LogoVariant ="
            , "    { id : String"
            , "    , description : String"
            , "    , theme : String"
            , "    , animated : Bool"
            , "    , withText : Bool"
            , "    , bold : Bool"
            , "    , highlight : Bool"
            , "    , svgUrl : Maybe String"
            , "    , pngUrl : Maybe String"
            , "    , webpUrl : Maybe String"
            , "    , gifUrl : Maybe String"
            , "    }"
            , ""
            , ""
            , "{-| Square (icon-only) logo variants. -}"
            , "squareVariants : List LogoVariant"
            , "squareVariants ="
            , "    " <> elmRecordList (map logoVariantRecord $ lgSquare lg)
            , ""
            , ""
            , "{-| Square logo variants with two-line text. -}"
            , "squareFullVariants : List LogoVariant"
            , "squareFullVariants ="
            , "    " <> elmRecordList (map logoVariantRecord $ lgSquareFull lg)
            , ""
            , ""
            , "{-| Horizontal logo variants. -}"
            , "horizontalVariants : List LogoVariant"
            , "horizontalVariants ="
            , "    " <> elmRecordList (map logoVariantRecord $ lgHorizontal lg)
            ]

logoVariantRecord :: LogoVariant -> Text
logoVariantRecord lv =
    elmRecord
        [ ("id", quote $ lvId lv)
        , ("description", quote $ lvDescription lv)
        , ("theme", quote $ lvTheme lv)
        , ("animated", elmBool $ lvAnimated lv)
        , ("withText", elmBool $ lvWithText lv)
        , ("bold", elmBool $ lvBold lv)
        , ("highlight", elmBool $ lvHighlight lv)
        , ("svgUrl", elmMaybe quote $ lvSvgUrl lv)
        , ("pngUrl", elmMaybe quote $ lvPngUrl lv)
        , ("webpUrl", elmMaybe quote $ lvWebpUrl lv)
        , ("gifUrl", elmMaybe quote $ lvGifUrl lv)
        ]

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- | Build a module header line with explicit export list.
moduleHeader :: Text -> [Text] -> Text
moduleHeader name exports =
    case exports of
        [] -> "module " <> name <> " exposing (..)"
        [x] -> "module " <> name <> " exposing (" <> x <> ")"
        (x : xs) ->
            "module "
                <> name
                <> " exposing\n    ( "
                <> x
                <> T.concat (map ("\n    , " <>) xs)
                <> "\n    )"

-- | Kebab-case or PascalCase id to camelCase Elm name.
elmName :: Text -> Text
elmName t =
    let parts = T.splitOn "-" t
     in case parts of
            [] -> ""
            (x : xs) -> lowerFirst x <> T.concat (map capitalFirst xs)

-- | Kebab-case to PascalCase.
pascal :: Text -> Text
pascal t =
    let parts = T.splitOn "-" t
     in T.concat (map capitalFirst parts)

capitalFirst :: Text -> Text
capitalFirst t = case T.uncons t of
    Nothing -> ""
    Just (c, rest) -> T.cons (toUpper c) rest

lowerFirst :: Text -> Text
lowerFirst t = case T.uncons t of
    Nothing -> ""
    Just (c, rest) -> T.cons (toLower c) rest

quote :: Text -> Text
quote t = "\"" <> escapeElmString t <> "\""

escapeElmString :: Text -> Text
escapeElmString = T.concatMap escapeChar
  where
    escapeChar '\\' = "\\\\"
    escapeChar '"' = "\\\""
    escapeChar '\n' = "\\n"
    escapeChar c = T.singleton c

showT :: (Show a) => a -> Text
showT = T.pack . show

showDouble :: Double -> Text
showDouble d
    | d == fromIntegral (round d :: Int) = T.pack (show (round d :: Int)) <> ".0"
    | otherwise = T.pack (show d)

elmList :: [Text] -> Text
elmList [] = "[]"
elmList [x] = "[ " <> x <> " ]"
elmList xs = "[ " <> T.intercalate "\n    , " xs <> "\n    ]"

elmBool :: Bool -> Text
elmBool True = "True"
elmBool False = "False"

elmMaybe :: (Text -> Text) -> Maybe Text -> Text
elmMaybe _ Nothing = "Nothing"
elmMaybe f (Just t) = "Just " <> f t

-- | Render a record literal from a list of (field, value) pairs.
elmRecord :: [(Text, Text)] -> Text
elmRecord [] = "{}"
elmRecord ((k, v) : rest) =
    "{ "
        <> k
        <> " = "
        <> v
        <> T.concat (map (\(fk, fv) -> "\n    , " <> fk <> " = " <> fv) rest)
        <> "\n    }"

-- | Render a list of record literals with aligned indentation.
elmRecordList :: [Text] -> Text
elmRecordList [] = "[]"
elmRecordList [x] = "[ " <> T.replace "\n" "\n  " x <> "\n  ]"
elmRecordList (x : xs) =
    "[ "
        <> T.replace "\n" "\n  " x
        <> T.concat (map (\r -> "\n  , " <> T.replace "\n" "\n    " r) xs)
        <> "\n  ]"
