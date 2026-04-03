{-# LANGUAGE OverloadedStrings #-}

{- | Parse design-guide.toml into 'DesignGuide'.

Uses the @toml-parser@ library with manual 'FromValue' instances.
-}
module Guide.Toml (parseDesignGuide) where

import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import Guide.Types
import Toml (Result (..), decode)
import Toml.Schema

-- ---------------------------------------------------------------------------
-- Entry point
-- ---------------------------------------------------------------------------

parseDesignGuide :: FilePath -> IO DesignGuide
parseDesignGuide path = do
    raw <- TIO.readFile path
    case decode raw of
        Failure errs ->
            fail $
                "design-guide.toml: parse errors:\n"
                    ++ unlines errs
        Success _warnings val -> pure val

-- ---------------------------------------------------------------------------
-- FromValue instances
-- ---------------------------------------------------------------------------

instance FromValue DesignGuide where
    fromValue = parseTableFromValue $ do
        m <- reqKey "meta"
        colorTbl <- reqKey "color"
        typo <- reqKey "typography"
        sp <- reqKey "spacing"
        mot <- reqKey "motion"
        comps <- reqKey "component"
        pure
            DesignGuide
                { dgMeta = m
                , dgBrandColors = cBrand colorTbl
                , dgSkinTones = cSkinTones colorTbl
                , dgRainbowColors = cRainbow colorTbl
                , dgSemanticColors = cSemantic colorTbl
                , dgTypography = typo
                , dgSpacing = sp
                , dgMotion = mot
                , dgLayout = spacingToLayout sp
                , dgComponents = comps
                }

-- Helper to extract Layout from SpacingConfig (they share the same TOML section)
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
-- Color table (intermediate)
-- ---------------------------------------------------------------------------

data ColorTable = ColorTable
    { cBrand :: [BrandColor]
    , cSkinTones :: [SkinTone]
    , cRainbow :: [RainbowColor]
    , cSemantic :: [SemanticColor]
    }

instance FromValue ColorTable where
    fromValue = parseTableFromValue $ do
        b <- reqKey "brand"
        s <- reqKey "skin-tone"
        r <- reqKey "rainbow"
        sem <- reqKey "semantic"
        pure ColorTable{cBrand = b, cSkinTones = s, cRainbow = r, cSemantic = sem}

-- ---------------------------------------------------------------------------
-- Meta
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
-- Colors
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
        u <- reqKey "usage"
        w <- reqKey "wcag"
        pure
            BrandColor
                { bcId = i
                , bcName = n
                , bcHex = Hex h
                , bcDescription = d
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
        en <- reqKey "elm-name"
        jp <- reqKey "json-path"
        h <- reqKey "hex"
        tc <- reqKey "tailwind-class"
        cv <- reqKey "css-variable"
        d <- reqKey "description"
        pure
            SemanticColor
                { scElmName = en
                , scJsonPath = jp
                , scHex = h
                , scTailwindClass = tc
                , scCssVariable = cv
                , scDescription = d
                }

-- ---------------------------------------------------------------------------
-- Typography
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
-- Spacing
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
-- Motion
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
-- Components
-- ---------------------------------------------------------------------------

instance FromValue ComponentSpec where
    fromValue = parseTableFromValue $ do
        n <- reqKey "name"
        m <- reqKey "module"
        d <- reqKey "description"
        p <- reqKey "props"
        td <- reqKey "token-deps"
        pure
            ComponentSpec
                { csName = n
                , csModule = m
                , csDescription = d
                , csProps = p
                , csTokenDependencies = td
                }
