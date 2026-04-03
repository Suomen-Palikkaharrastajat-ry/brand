{-# LANGUAGE OverloadedStrings #-}

{- | Shared ADTs for the design-guide pipeline.

All generators (Guide.Json, Guide.JsonLd, Guide.ElmGen, Guide.CssGen)
consume these types.  The canonical source of values is design-guide.toml,
parsed by Guide.Toml.
-}
module Guide.Types
    ( -- * Top-level
      DesignGuide (..)

      -- * Metadata
    , Meta (..)

      -- * Hex wrapper (re-exported for backward compat)
    , Hex (..)
    , hexText

      -- * Colors
    , BrandColor (..)
    , WcagContrast (..)
    , SkinTone (..)
    , RainbowColor (..)
    , SemanticColor (..)

      -- * Typography
    , TypographyConfig (..)
    , TypeScaleEntry (..)

      -- * Spacing
    , SpacingConfig (..)
    , SpacingStep (..)

      -- * Motion
    , MotionConfig (..)
    , MotionDuration (..)
    , MotionEasing (..)

      -- * Layout
    , LayoutConfig (..)
    , Breakpoint (..)
    , BorderRadius (..)
    , ResponsiveGrid (..)

      -- * Components
    , ComponentSpec (..)
    )
where

import Data.Text (Text)

-- ---------------------------------------------------------------------------
-- Hex
-- ---------------------------------------------------------------------------

newtype Hex = Hex Text deriving (Show, Eq)

hexText :: Hex -> Text
hexText (Hex t) = t

-- ---------------------------------------------------------------------------
-- Top-level
-- ---------------------------------------------------------------------------

data DesignGuide = DesignGuide
    { dgMeta :: Meta
    , dgBrandColors :: [BrandColor]
    , dgSkinTones :: [SkinTone]
    , dgRainbowColors :: [RainbowColor]
    , dgSemanticColors :: [SemanticColor]
    , dgTypography :: TypographyConfig
    , dgSpacing :: SpacingConfig
    , dgMotion :: MotionConfig
    , dgLayout :: LayoutConfig
    , dgComponents :: [ComponentSpec]
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Metadata
-- ---------------------------------------------------------------------------

data Meta = Meta
    { metaVersion :: Text
    , metaOrganization :: Text
    , metaCanonicalUrl :: Text
    , metaBrandGuideUrl :: Text
    , metaFeatureColor :: Hex
    , metaHighlightColor :: Hex
    , metaDarkBg :: Hex
    , metaSubtitleOnLight :: Hex
    , metaSubtitleOnDark :: Hex
    , metaHeadSvgFaceColor :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------

data WcagContrast = WcagContrast
    { wcagOn :: Text -- ^ e.g. "onWhite", "onBlack", "onBrand"
    , wcagRatio :: Double
    , wcagRating :: Text -- ^ "AAA", "AA", "fail"
    }
    deriving (Show, Eq)

data BrandColor = BrandColor
    { bcId :: Text
    , bcName :: Text
    , bcHex :: Hex
    , bcDescription :: Text
    , bcUsage :: [Text]
    , bcWcag :: [WcagContrast]
    }
    deriving (Show, Eq)

data SkinTone = SkinTone
    { stId :: Text
    , stName :: Text
    , stHex :: Hex
    , stDescription :: Text
    , stWcag :: [WcagContrast]
    }
    deriving (Show, Eq)

data RainbowColor = RainbowColor
    { rcId :: Text
    , rcName :: Text
    , rcHex :: Hex
    , rcDescription :: Text
    }
    deriving (Show, Eq)

data SemanticColor = SemanticColor
    { scElmName :: Text -- ^ e.g. "colorTextPrimary"
    , scJsonPath :: Text -- ^ e.g. "text.primary"
    , scHex :: Text -- ^ resolved hex value
    , scTailwindClass :: Text
    , scCssVariable :: Text
    , scDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

data TypographyConfig = TypographyConfig
    { tcFontFamily :: [Text] -- ^ e.g. ["Outfit", "system-ui", "sans-serif"]
    , tcFontFile :: Text
    , tcFontLicense :: Text
    , tcFontLicenseFile :: Text
    , tcScale :: [TypeScaleEntry]
    , tcUsageRules :: [Text]
    }
    deriving (Show, Eq)

data TypeScaleEntry = TypeScaleEntry
    { tseName :: Text
    , tseWeight :: Int
    , tseSizeRem :: Double
    , tseSizePx :: Int
    , tseLineHeight :: Double
    , tseLetterSpacingEm :: Double
    , tseCssClass :: Text
    , tseDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Spacing
-- ---------------------------------------------------------------------------

data SpacingConfig = SpacingConfig
    { spcBaseUnit :: Int
    , spcScale :: [SpacingStep]
    , spcContentWidthPx :: Int
    , spcContentWidthTailwind :: Text
    , spcPagePaddingXPx :: Int
    , spcPagePaddingXTailwind :: Text
    , spcPageWrapperClass :: Text
    , spcBreakpoints :: [Breakpoint]
    , spcBorderRadii :: [BorderRadius]
    , spcResponsiveGrids :: [ResponsiveGrid]
    , spcResponsiveRules :: [Text]
    }
    deriving (Show, Eq)

data SpacingStep = SpacingStep
    { ssName :: Text
    , ssMultiplier :: Int
    , ssPx :: Int
    , ssRem :: Double
    , ssTailwindClass :: Text
    , ssDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Layout
-- ---------------------------------------------------------------------------

data LayoutConfig = LayoutConfig
    { lcContentWidthPx :: Int
    , lcContentWidthTailwind :: Text
    , lcPagePaddingXPx :: Int
    , lcPagePaddingXTailwind :: Text
    , lcPageWrapperClass :: Text
    }
    deriving (Show, Eq)

data Breakpoint = Breakpoint
    { bpName :: Text
    , bpPx :: Int
    }
    deriving (Show, Eq)

data BorderRadius = BorderRadius
    { brName :: Text
    , brPx :: Int
    , brTailwindClass :: Text
    }
    deriving (Show, Eq)

data ResponsiveGrid = ResponsiveGrid
    { rgName :: Text
    , rgDescription :: Text
    , rgMobile :: Int
    , rgSm :: Int
    , rgMd :: Int
    , rgLg :: Int
    , rgXl :: Int
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------

data MotionConfig = MotionConfig
    { mcDurations :: [MotionDuration]
    , mcEasings :: [MotionEasing]
    , mcUsageRules :: [Text]
    }
    deriving (Show, Eq)

data MotionDuration = MotionDuration
    { mdName :: Text
    , mdMs :: Int
    , mdCssVariable :: Text
    , mdDescription :: Text
    }
    deriving (Show, Eq)

data MotionEasing = MotionEasing
    { meName :: Text
    , meP1x :: Double
    , meP1y :: Double
    , meP2x :: Double
    , meP2y :: Double
    , meDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Components
-- ---------------------------------------------------------------------------

data ComponentSpec = ComponentSpec
    { csName :: Text
    , csModule :: Text
    , csDescription :: Text
    , csProps :: [Text]
    , csTokenDependencies :: [Text]
    }
    deriving (Show, Eq)
