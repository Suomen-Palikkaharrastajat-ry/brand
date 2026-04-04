{-# LANGUAGE OverloadedStrings #-}

{- | Parse design tokens from the content/ directory.

Each .toml file in content/ contains one section of the design guide.
The parser reads every file and merges the results into a single 'DesignGuide'.
-}
module DesignTokensGen.Toml (parseContentDir) where

import Data.List (sort)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import DesignTokensGen.Types
import System.Directory (listDirectory)
import System.FilePath (takeExtension, (</>))
import Toml (Result (..), decode)
import Toml.Schema

-- ---------------------------------------------------------------------------
-- Entry point
-- ---------------------------------------------------------------------------

parseContentDir :: FilePath -> IO DesignGuide
parseContentDir dir = do
    files <- sort . filter isToml <$> listDirectory dir
    sections <- mapM (parseSection dir) files
    mergeSections sections
  where
    isToml f = takeExtension f == ".toml"

-- ---------------------------------------------------------------------------
-- Section sum type
-- ---------------------------------------------------------------------------

data Section
    = SMeta Meta
    | SColors [BrandColor] [SkinTone] [RainbowColor] [SemanticColor]
    | STypography TypographyConfig
    | SSpacing SpacingConfig
    | SMotion MotionConfig
    | SEffects EffectsConfig
    | SAccessibility AccessibilityConfig
    | SOpacity OpacityConfig
    | SComponents [ComponentSpec]
    | SLogos LogoGroup

parseSection :: FilePath -> FilePath -> IO Section
parseSection dir file = do
    raw <- TIO.readFile (dir </> file)
    case file of
        "meta.toml" -> do
            WrapMeta m <- decodeOrFail file raw
            pure (SMeta m)
        "colors.toml" -> do
            WrapColors ct <- decodeOrFail file raw
            pure (SColors (ctBrand ct) (ctSkinTones ct) (ctRainbow ct) (ctSemantic ct))
        "typography.toml" -> do
            WrapTypography t <- decodeOrFail file raw
            pure (STypography t)
        "spacing.toml" -> do
            WrapSpacing sp <- decodeOrFail file raw
            pure (SSpacing sp)
        "motion.toml" -> do
            WrapMotion mo <- decodeOrFail file raw
            pure (SMotion mo)
        "components.toml" -> do
            WrapComponents cs <- decodeOrFail file raw
            pure (SComponents cs)
        "effects.toml" -> do
            WrapEffects ef <- decodeOrFail file raw
            pure (SEffects ef)
        "accessibility.toml" -> do
            WrapAccessibility ac <- decodeOrFail file raw
            pure (SAccessibility ac)
        "opacity.toml" -> do
            WrapOpacity op <- decodeOrFail file raw
            pure (SOpacity op)
        "logos.toml" -> do
            WrapLogos lg <- decodeOrFail file raw
            pure (SLogos lg)
        _ -> fail $ "Unknown content file: " ++ file

decodeOrFail :: (FromValue a) => String -> T.Text -> IO a
decodeOrFail name raw =
    case decode raw of
        Failure errs ->
            fail $ name ++ ": parse errors:\n" ++ unlines errs
        Success _warnings val -> pure val

mergeSections :: [Section] -> IO DesignGuide
mergeSections sections = do
    m <- requireOne "meta.toml" [x | SMeta x <- sections]
    (bc, st, rc, sc) <- requireOne "colors.toml" [(b, s, r, sem) | SColors b s r sem <- sections]
    tp <- requireOne "typography.toml" [x | STypography x <- sections]
    sp <- requireOne "spacing.toml" [x | SSpacing x <- sections]
    mo <- requireOne "motion.toml" [x | SMotion x <- sections]
    ef <- requireOne "effects.toml" [x | SEffects x <- sections]
    ac <- requireOne "accessibility.toml" [x | SAccessibility x <- sections]
    op <- requireOne "opacity.toml" [x | SOpacity x <- sections]
    cs <- requireOne "components.toml" [x | SComponents x <- sections]
    lg <- requireOne "logos.toml" [x | SLogos x <- sections]
    pure
        DesignGuide
            { dgMeta = m
            , dgBrandColors = bc
            , dgSkinTones = st
            , dgRainbowColors = rc
            , dgSemanticColors = sc
            , dgTypography = tp
            , dgSpacing = sp
            , dgMotion = mo
            , dgLayout = spacingToLayout sp
            , dgEffects = ef
            , dgAccessibility = ac
            , dgOpacity = op
            , dgComponents = cs
            , dgLogos = lg
            }

requireOne :: String -> [a] -> IO a
requireOne label [] = fail $ "Missing required content file: " ++ label
requireOne _ (x : _) = pure x

spacingToLayout :: SpacingConfig -> LayoutConfig
spacingToLayout sp =
    LayoutConfig
        { lcContentWidthPx = spcContentWidthPx sp
        , lcContentWidthTailwind = spcContentWidthTailwind sp
        , lcPagePaddingXPx = spcPagePaddingXPx sp
        , lcPagePaddingXTailwind = spcPagePaddingXTailwind sp
        , lcPageWrapperClass = spcPageWrapperClass sp
        }

-- ---------------------------------------------------------------------------
-- Root wrappers (each file has a top-level key)
-- ---------------------------------------------------------------------------

newtype WrapMeta = WrapMeta Meta
instance FromValue WrapMeta where
    fromValue = parseTableFromValue $ WrapMeta <$> reqKey "meta"

newtype WrapColors = WrapColors ColorTable
instance FromValue WrapColors where
    fromValue = parseTableFromValue $ WrapColors <$> reqKey "color"

newtype WrapTypography = WrapTypography TypographyConfig
instance FromValue WrapTypography where
    fromValue = parseTableFromValue $ WrapTypography <$> reqKey "typography"

newtype WrapSpacing = WrapSpacing SpacingConfig
instance FromValue WrapSpacing where
    fromValue = parseTableFromValue $ WrapSpacing <$> reqKey "spacing"

newtype WrapMotion = WrapMotion MotionConfig
instance FromValue WrapMotion where
    fromValue = parseTableFromValue $ WrapMotion <$> reqKey "motion"

newtype WrapEffects = WrapEffects EffectsConfig
instance FromValue WrapEffects where
    fromValue = parseTableFromValue $ WrapEffects <$> reqKey "effects"

newtype WrapAccessibility = WrapAccessibility AccessibilityConfig
instance FromValue WrapAccessibility where
    fromValue = parseTableFromValue $ WrapAccessibility <$> reqKey "accessibility"

newtype WrapOpacity = WrapOpacity OpacityConfig
instance FromValue WrapOpacity where
    fromValue = parseTableFromValue $ WrapOpacity <$> reqKey "opacity"

newtype WrapComponents = WrapComponents [ComponentSpec]
instance FromValue WrapComponents where
    fromValue = parseTableFromValue $ WrapComponents <$> reqKey "component"

newtype WrapLogos = WrapLogos LogoGroup
instance FromValue WrapLogos where
    fromValue = parseTableFromValue $ WrapLogos <$> reqKey "logo"

-- ---------------------------------------------------------------------------
-- Intermediate color table
-- ---------------------------------------------------------------------------

data ColorTable = ColorTable
    { ctBrand :: [BrandColor]
    , ctSkinTones :: [SkinTone]
    , ctRainbow :: [RainbowColor]
    , ctSemantic :: [SemanticColor]
    }

instance FromValue ColorTable where
    fromValue = parseTableFromValue $ do
        b <- reqKey "brand"
        s <- reqKey "skin-tone"
        r <- reqKey "rainbow"
        sem <- reqKey "semantic"
        pure ColorTable{ctBrand = b, ctSkinTones = s, ctRainbow = r, ctSemantic = sem}

-- ---------------------------------------------------------------------------
-- FromValue: Meta
-- ---------------------------------------------------------------------------

instance FromValue Meta where
    fromValue = parseTableFromValue $ do
        ver <- reqKey "version"
        org <- reqKey "organization"
        curl <- reqKey "canonical-url"
        burl <- reqKey "brand-guide-url"
        fc <- reqKey "feature-color"
        hc <- reqKey "highlight-color"
        db <- reqKey "dark-bg"
        sol <- reqKey "subtitle-on-light"
        sod <- reqKey "subtitle-on-dark"
        hsfc <- reqKey "head-svg-face-color"
        pure
            Meta
                { metaVersion = ver
                , metaOrganization = org
                , metaCanonicalUrl = curl
                , metaBrandGuideUrl = burl
                , metaFeatureColor = Hex fc
                , metaHighlightColor = Hex hc
                , metaDarkBg = Hex db
                , metaSubtitleOnLight = Hex sol
                , metaSubtitleOnDark = Hex sod
                , metaHeadSvgFaceColor = hsfc
                }

-- ---------------------------------------------------------------------------
-- FromValue: Colors
-- ---------------------------------------------------------------------------

instance FromValue WcagContrast where
    fromValue = parseTableFromValue $ do
        o <- reqKey "on"
        r <- reqKey "ratio"
        rt <- reqKey "rating"
        pure WcagContrast{wcagOn = o, wcagRatio = r, wcagRating = rt}

instance FromValue BrandColor where
    fromValue = parseTableFromValue $ do
        i <- reqKey "id"
        n <- reqKey "name"
        h <- reqKey "hex"
        d <- reqKey "description"
        dfi <- reqKey "description_fi"
        u <- reqKey "usage"
        w <- reqKey "wcag"
        pure
            BrandColor
                { bcId = i
                , bcName = n
                , bcHex = Hex h
                , bcDescription = d
                , bcDescriptionFi = dfi
                , bcUsage = u
                , bcWcag = w
                }

instance FromValue SkinTone where
    fromValue = parseTableFromValue $ do
        i <- reqKey "id"
        n <- reqKey "name"
        h <- reqKey "hex"
        d <- reqKey "description"
        w <- reqKey "wcag"
        pure
            SkinTone
                { stId = i
                , stName = n
                , stHex = Hex h
                , stDescription = d
                , stWcag = w
                }

instance FromValue RainbowColor where
    fromValue = parseTableFromValue $ do
        i <- reqKey "id"
        n <- reqKey "name"
        h <- reqKey "hex"
        d <- reqKey "description"
        pure
            RainbowColor
                { rcId = i
                , rcName = n
                , rcHex = Hex h
                , rcDescription = d
                }

instance FromValue SemanticColor where
    fromValue = parseTableFromValue $ do
        i <- reqKey "id"
        h <- reqKey "hex"
        d <- reqKey "description"
        pure
            SemanticColor
                { scId = i
                , scHex = h
                , scDescription = d
                }

-- ---------------------------------------------------------------------------
-- FromValue: Typography
-- ---------------------------------------------------------------------------

instance FromValue TypographyConfig where
    fromValue = parseTableFromValue $ do
        ff <- reqKey "font-family"
        file <- reqKey "font-file"
        lic <- reqKey "font-license"
        licf <- reqKey "font-license-file"
        sc <- reqKey "scale"
        ur <- reqKey "usage-rules"
        pure
            TypographyConfig
                { tcFontFamily = ff
                , tcFontFile = file
                , tcFontLicense = lic
                , tcFontLicenseFile = licf
                , tcScale = sc
                , tcUsageRules = ur
                }

instance FromValue TypeScaleEntry where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        w <- reqKey "weight"
        sr <- reqKey "size-rem"
        sp <- reqKey "size-px"
        lh <- reqKey "line-height"
        ls <- reqKey "letter-spacing-em"
        cc <- reqKey "css-class"
        d <- reqKey "description"
        pure
            TypeScaleEntry
                { tseName = n
                , tseWeight = w
                , tseSizeRem = sr
                , tseSizePx = sp
                , tseLineHeight = lh
                , tseLetterSpacingEm = ls
                , tseCssClass = cc
                , tseDescription = d
                }

-- ---------------------------------------------------------------------------
-- FromValue: Spacing
-- ---------------------------------------------------------------------------

instance FromValue SpacingConfig where
    fromValue = parseTableFromValue $ do
        bu <- reqKey "base-unit"
        sc <- reqKey "scale"
        cwp <- reqKey "content-width-px"
        cwt <- reqKey "content-width-tailwind"
        ppx <- reqKey "page-padding-x-px"
        ppt <- reqKey "page-padding-x-tailwind"
        pwc <- reqKey "page-wrapper-class"
        bps <- reqKey "breakpoint"
        brs <- reqKey "border-radius"
        rgs <- reqKey "responsive-grid"
        rr <- reqKey "responsive-rules"
        pure
            SpacingConfig
                { spcBaseUnit = bu
                , spcScale = sc
                , spcContentWidthPx = cwp
                , spcContentWidthTailwind = cwt
                , spcPagePaddingXPx = ppx
                , spcPagePaddingXTailwind = ppt
                , spcPageWrapperClass = pwc
                , spcBreakpoints = bps
                , spcBorderRadii = brs
                , spcResponsiveGrids = rgs
                , spcResponsiveRules = rr
                }

instance FromValue SpacingStep where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        m <- reqKey "multiplier"
        p <- reqKey "px"
        r <- reqKey "rem"
        tc <- reqKey "tailwind-class"
        d <- reqKey "description"
        pure
            SpacingStep
                { ssName = n
                , ssMultiplier = m
                , ssPx = p
                , ssRem = r
                , ssTailwindClass = tc
                , ssDescription = d
                }

instance FromValue Breakpoint where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        p <- reqKey "px"
        pure Breakpoint{bpName = n, bpPx = p}

instance FromValue BorderRadius where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        p <- reqKey "px"
        tc <- reqKey "tailwind-class"
        pure BorderRadius{brName = n, brPx = p, brTailwindClass = tc}

instance FromValue ResponsiveGrid where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        d <- reqKey "description"
        mob <- reqKey "mobile"
        sm_ <- reqKey "sm"
        md_ <- reqKey "md"
        lg_ <- reqKey "lg"
        xl_ <- reqKey "xl"
        pure
            ResponsiveGrid
                { rgName = n
                , rgDescription = d
                , rgMobile = mob
                , rgSm = sm_
                , rgMd = md_
                , rgLg = lg_
                , rgXl = xl_
                }

-- ---------------------------------------------------------------------------
-- FromValue: Motion
-- ---------------------------------------------------------------------------

instance FromValue MotionConfig where
    fromValue = parseTableFromValue $ do
        ds <- reqKey "duration"
        es <- reqKey "easing"
        ur <- reqKey "usage-rules"
        pure MotionConfig{mcDurations = ds, mcEasings = es, mcUsageRules = ur}

instance FromValue MotionDuration where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        m <- reqKey "ms"
        cv <- reqKey "css-variable"
        d <- reqKey "description"
        pure
            MotionDuration
                { mdName = n
                , mdMs = m
                , mdCssVariable = cv
                , mdDescription = d
                }

instance FromValue MotionEasing where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        p1x <- reqKey "p1x"
        p1y <- reqKey "p1y"
        p2x <- reqKey "p2x"
        p2y <- reqKey "p2y"
        d <- reqKey "description"
        pure
            MotionEasing
                { meName = n
                , meP1x = p1x
                , meP1y = p1y
                , meP2x = p2x
                , meP2y = p2y
                , meDescription = d
                }

-- ---------------------------------------------------------------------------
-- FromValue: Effects
-- ---------------------------------------------------------------------------

instance FromValue EffectsConfig where
    fromValue = parseTableFromValue $ do
        sh <- reqKey "shadow"
        zi <- reqKey "z-index"
        ur <- reqKey "usage-rules"
        pure EffectsConfig{ecShadows = sh, ecZIndices = zi, ecUsageRules = ur}

instance FromValue Shadow where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        v <- reqKey "value"
        tc <- reqKey "tailwind-class"
        d <- reqKey "description"
        pure Shadow{shName = n, shValue = v, shTailwindClass = tc, shDescription = d}

instance FromValue ZIndex where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        v <- reqKey "value"
        d <- reqKey "description"
        pure ZIndex{ziName = n, ziValue = v, ziDescription = d}

-- ---------------------------------------------------------------------------
-- FromValue: Accessibility
-- ---------------------------------------------------------------------------

instance FromValue AccessibilityConfig where
    fromValue = parseTableFromValue $ do
        fr <- reqKey "focus-ring"
        ur <- reqKey "usage-rules"
        pure AccessibilityConfig{acFocusRings = fr, acUsageRules = ur}

instance FromValue FocusRing where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        w <- reqKey "width-px"
        o <- reqKey "offset-px"
        c <- reqKey "color"
        tc <- reqKey "tailwind-class"
        d <- reqKey "description"
        pure
            FocusRing
                { frName = n
                , frWidthPx = w
                , frOffsetPx = o
                , frColor = c
                , frTailwindClass = tc
                , frDescription = d
                }

-- ---------------------------------------------------------------------------
-- FromValue: Opacity
-- ---------------------------------------------------------------------------

instance FromValue OpacityConfig where
    fromValue = parseTableFromValue $ do
        sc <- reqKey "scale"
        ur <- reqKey "usage-rules"
        pure OpacityConfig{ocScale = sc, ocUsageRules = ur}

instance FromValue OpacityStep where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        v <- reqKey "value"
        d <- reqKey "description"
        pure OpacityStep{osName = n, osValue = v, osDescription = d}

-- ---------------------------------------------------------------------------
-- FromValue: Components
-- ---------------------------------------------------------------------------

instance FromValue ComponentSpec where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        d <- reqKey "description"
        p <- reqKey "props"
        td <- reqKey "token-deps"
        pure
            ComponentSpec
                { csName = n
                , csDescription = d
                , csProps = p
                , csTokenDependencies = td
                }

-- ---------------------------------------------------------------------------
-- FromValue: Logos
-- ---------------------------------------------------------------------------

instance FromValue LogoGroup where
    fromValue = parseTableFromValue $ do
        sq <- reqKey "square"
        sqf <- reqKey "square-full"
        hz <- reqKey "horizontal"
        pure LogoGroup{lgSquare = sq, lgSquareFull = sqf, lgHorizontal = hz}

instance FromValue LogoVariant where
    fromValue = parseTableFromValue $ do
        i <- reqKey "id"
        d <- reqKey "description"
        th <- reqKey "theme"
        an <- reqKey "animated"
        wt <- reqKey "with-text"
        bo <- reqKey "bold"
        hi <- reqKey "highlight"
        sv <- optKey "svg-url"
        pn <- optKey "png-url"
        wp <- optKey "webp-url"
        gi <- optKey "gif-url"
        pure
            LogoVariant
                { lvId = i
                , lvDescription = d
                , lvTheme = th
                , lvAnimated = an
                , lvWithText = wt
                , lvBold = bo
                , lvHighlight = hi
                , lvSvgUrl = sv
                , lvPngUrl = pn
                , lvWebpUrl = wp
                , lvGifUrl = gi
                }
