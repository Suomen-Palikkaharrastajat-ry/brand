{- | Shared ADTs for the design-token pipeline.

All generators (DesignTokensGen.Json, DesignTokensGen.ElmGen) consume these types.
The canonical source of values is the content/*.toml directory,
parsed by DesignTokensGen.Toml.
-}
module DesignTokensGen.Types (
    -- * Top-level
    DesignGuide (..),

    -- * Metadata
    Meta (..),

    -- * Hex wrapper
    Hex (..),
    hexText,

    -- * Colors
    BrandColor (..),
    WcagContrast (..),
    SkinTone (..),
    RainbowColor (..),
    SemanticColor (..),

    -- * Typography
    TypographyConfig (..),
    TypeScaleEntry (..),

    -- * Spacing
    SpacingConfig (..),
    SpacingStep (..),

    -- * Motion
    MotionConfig (..),
    MotionDuration (..),
    MotionEasing (..),

    -- * Layout
    LayoutConfig (..),
    Breakpoint (..),
    BorderRadius (..),
    ResponsiveGrid (..),

    -- * Effects
    EffectsConfig (..),
    Shadow (..),
    ZIndex (..),

    -- * Accessibility
    AccessibilityConfig (..),
    FocusRing (..),

    -- * Opacity
    OpacityConfig (..),
    OpacityStep (..),

    -- * Components
    ComponentSpec (..),

    -- * Logos
    LogoVariant (..),
    LogoGroup (..),
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
    , dgEffects :: EffectsConfig
    , dgAccessibility :: AccessibilityConfig
    , dgOpacity :: OpacityConfig
    , dgComponents :: [ComponentSpec]
    , dgLogos :: LogoGroup
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
    { wcagOn :: Text
    , wcagRatio :: Double
    , wcagRating :: Text
    }
    deriving (Show, Eq)

data BrandColor = BrandColor
    { bcId :: Text
    , bcName :: Text
    , bcHex :: Hex
    , bcDescription :: Text
    , bcDescriptionFi :: Text
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
    { scId :: Text
    , scHex :: Text
    , scDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

data TypographyConfig = TypographyConfig
    { tcFontFamily :: [Text]
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
-- Effects
-- ---------------------------------------------------------------------------

data EffectsConfig = EffectsConfig
    { ecShadows :: [Shadow]
    , ecZIndices :: [ZIndex]
    , ecUsageRules :: [Text]
    }
    deriving (Show, Eq)

data Shadow = Shadow
    { shName :: Text
    , shValue :: Text
    , shTailwindClass :: Text
    , shDescription :: Text
    }
    deriving (Show, Eq)

data ZIndex = ZIndex
    { ziName :: Text
    , ziValue :: Int
    , ziDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Accessibility
-- ---------------------------------------------------------------------------

data AccessibilityConfig = AccessibilityConfig
    { acFocusRings :: [FocusRing]
    , acUsageRules :: [Text]
    }
    deriving (Show, Eq)

data FocusRing = FocusRing
    { frName :: Text
    , frWidthPx :: Int
    , frOffsetPx :: Int
    , frColor :: Text
    , frTailwindClass :: Text
    , frDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Opacity
-- ---------------------------------------------------------------------------

data OpacityConfig = OpacityConfig
    { ocScale :: [OpacityStep]
    , ocUsageRules :: [Text]
    }
    deriving (Show, Eq)

data OpacityStep = OpacityStep
    { osName :: Text
    , osValue :: Int
    , osDescription :: Text
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Components (token mapping only — no Elm implementation)
-- ---------------------------------------------------------------------------

data ComponentSpec = ComponentSpec
    { csName :: Text
    , csDescription :: Text
    , csProps :: [Text]
    , csTokenDependencies :: [Text]
    }
    deriving (Show, Eq)

-- ---------------------------------------------------------------------------
-- Logos
-- ---------------------------------------------------------------------------

data LogoVariant = LogoVariant
    { lvId :: Text
    , lvDescription :: Text
    , lvTheme :: Text
    , lvAnimated :: Bool
    , lvWithText :: Bool
    , lvBold :: Bool
    , lvHighlight :: Bool
    , lvSvgUrl :: Maybe Text
    , lvPngUrl :: Maybe Text
    , lvWebpUrl :: Maybe Text
    , lvGifUrl :: Maybe Text
    }
    deriving (Show, Eq)

data LogoGroup = LogoGroup
    { lgSquare :: [LogoVariant]
    , lgSquareFull :: [LogoVariant]
    , lgHorizontal :: [LogoVariant]
    }
    deriving (Show, Eq)
