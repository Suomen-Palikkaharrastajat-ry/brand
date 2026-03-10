{-# LANGUAGE OverloadedStrings #-}
-- | Single source of truth for all design token constants shared between
-- Brand.Json (design-guide.json generation) and Brand.ElmGen (Tokens.elm
-- generation). Modify this file to change any value in BOTH outputs.
module Brand.DesignData where

import Brand.Colors
import Data.Text (Text)

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

-- | (name, weight, sizeRem, sizePx, lineHeight, letterSpacingEm, cssClass, description)
type TypeScaleRow = (Text, Int, Double, Int, Double, Double, Text, Text)

typeScale :: [TypeScaleRow]
typeScale =
    [ ("Display",   700, 3.0,   48, 1.1,  (-0.02), "text-5xl font-bold",                           "Hero headlines and landing-page titles only.")
    , ("Heading1",  700, 1.875, 30, 1.2,  (-0.01), "text-3xl font-bold",                           "Page-level headings (one per page).")
    , ("Heading2",  700, 1.5,   24, 1.3,  0.0,     "text-2xl font-bold",                           "Section headings.")
    , ("Heading3",  600, 1.25,  20, 1.35, 0.0,     "text-xl font-semibold",                        "Sub-section headings.")
    , ("Body",      400, 1.0,   16, 1.6,  0.0,     "text-base",                                    "Default body copy. Minimum size for accessible reading.")
    , ("BodySmall", 500, 0.875, 14, 1.5,  0.0,     "text-sm font-medium",                          "Secondary labels, UI controls, and form hints.")
    , ("Caption",   400, 0.875, 14, 1.4,  0.02,    "text-sm",                                      "Image captions, footnotes, and metadata.")
    , ("Mono",      400, 0.875, 14, 1.6,  0.0,     "font-mono text-sm",                            "Hex values, IDs, and code snippets.")
    , ("Overline",  600, 0.75,  12, 1.4,  0.08,    "text-xs font-semibold uppercase tracking-wider","Section category labels. Always uppercase.")
    ]

typographyUsageRules :: [Text]
typographyUsageRules =
    [ "Use the Outfit font exclusively; never substitute a system font in designed output."
    , "Minimum body text size is 16px (1rem) at weight 400."
    , "Minimum caption/label text size is 14px (0.875rem); use weight 500 or higher for readability."
    , "Maximum recommended line length is 75 characters for body text."
    , "Heading hierarchy must descend: Display > H1 > H2 > H3. Do not skip levels."
    , "Code and monospace content should use font-family: monospace as a fallback."
    ]

-- ---------------------------------------------------------------------------
-- Spacing
-- ---------------------------------------------------------------------------

-- | (name, multiplier, px, rem, tailwindClass, description)
type SpacingRow = (Text, Int, Int, Double, Text, Text)

spacingScale :: [SpacingRow]
spacingScale =
    [ ("space-1",  1,  4,  0.25, "p-1 / m-1",   "Tight: icon padding, inline gaps.")
    , ("space-2",  2,  8,  0.5,  "p-2 / m-2",   "Compact: button padding, tag gaps.")
    , ("space-3",  3,  12, 0.75, "p-3 / m-3",   "Small: input padding, list item gaps.")
    , ("space-4",  4,  16, 1.0,  "p-4 / m-4",   "Base: card padding, form field gaps.")
    , ("space-6",  6,  24, 1.5,  "p-6 / m-6",   "Medium: section sub-divisions.")
    , ("space-8",  8,  32, 2.0,  "p-8 / m-8",   "Large: card body padding, section gaps.")
    , ("space-12", 12, 48, 3.0,  "p-12 / m-12", "XL: page section vertical margins.")
    , ("space-16", 16, 64, 4.0,  "p-16 / m-16", "2XL: hero and feature block spacing.")
    ]

-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------

-- | (name, ms, description)
motionDurationData :: [(Text, Int, Text)]
motionDurationData =
    [ ("fast",      150,   "Hover states, focus rings, button fills.")
    , ("base",      300,   "Default: card lift, menu open, accordion expand.")
    , ("slow",      500,   "Page-level transitions, large content reveals.")
    , ("logoFrame", 10000, "Animated logo frame hold — do not modify without regenerating assets.")
    ]

-- | (name, p1x, p1y, p2x, p2y, description)
-- Values are the four control-point coordinates of a CSS cubic-bezier curve.
-- The CSS equivalent is: cubic-bezier(p1x, p1y, p2x, p2y)
type EasingRow = (Text, Double, Double, Double, Double, Text)

motionEasingData :: [EasingRow]
motionEasingData =
    [ ("standard",   0.4, 0.0, 0.2, 1.0, "Default easing for elements that both enter and exit.")
    , ("decelerate", 0.0, 0.0, 0.2, 1.0, "Elements entering the screen.")
    , ("accelerate", 0.4, 0.0, 1.0, 1.0, "Elements leaving the screen.")
    ]

motionUsageRules :: [Text]
motionUsageRules =
    [ "Always provide a prefers-reduced-motion alternative."
    , "Animate transform and opacity only; never animate layout properties."
    , "The animated logo must not autoplay when prefers-reduced-motion: reduce is set."
    , "Use duration.fast for hover/focus, duration.base for reveals, duration.slow for page transitions."
    ]

-- ---------------------------------------------------------------------------
-- Semantic colors
-- ---------------------------------------------------------------------------

-- | (elmConstName, jsonPath, hexValue, cssTailwindClass, description)
type SemanticColorRow = (Text, Text, Text, Text, Text)

semanticColors :: [SemanticColorRow]
semanticColors =
    [ ("colorTextPrimary",   "text.primary",       hexText subtitleOnLight, "text-brand",        "Primary body text; use on white or light-gray backgrounds.")
    , ("colorTextOnDark",    "text.onDark",         hexText subtitleOnDark,  "text-white",        "Text on dark or brand-colored backgrounds.")
    , ("colorTextMuted",     "text.muted",          "#6B7280",               "text-gray-500",     "Secondary labels, captions, helper text on light backgrounds.")
    , ("colorTextSubtle",    "text.subtle",         "#9CA3AF",               "text-gray-400",     "De-emphasised metadata; use only for large text.")
    , ("colorBgPage",        "background.page",     "#FFFFFF",               "bg-white",          "Default page/document background.")
    , ("colorBgDark",        "background.dark",     hexText darkBg,          "bg-brand",          "Dark section backgrounds. Pair with colorTextOnDark.")
    , ("colorBgSubtle",      "background.subtle",   "#F9FAFB",               "bg-gray-50",        "Light card and section backgrounds.")
    , ("colorBgAccent",      "background.accent",   "#F2CD37",               "bg-brand-yellow",   "Brand accent CTA color. Always pair with colorTextPrimary.")
    , ("colorBorderDefault", "border.default",      "#E5E7EB",               "border-gray-200",   "Standard card and section divider borders.")
    , ("colorBorderBrand",   "border.brand",        hexText darkBg,          "border-brand",      "Brand-colored borders, left-accent rules, focus rings.")
    ]

-- ---------------------------------------------------------------------------
-- Layout constants
-- ---------------------------------------------------------------------------

contentWidthPx :: Int
contentWidthPx = 1024

contentWidthTailwind :: Text
contentWidthTailwind = "max-w-5xl"

pagePaddingXPx :: Int
pagePaddingXPx = 16

pagePaddingXTailwind :: Text
pagePaddingXTailwind = "px-4"

pageWrapperClass :: Text
pageWrapperClass = "max-w-5xl mx-auto px-4"

breakpoints :: [(Text, Int)]
breakpoints =
    [ ("sm", 640)
    , ("md", 768)
    , ("lg", 1024)
    , ("xl", 1280)
    ]

-- | (name, pxValue, tailwindClass)
borderRadii :: [(Text, Int, Text)]
borderRadii =
    [ ("sm",   4,    "rounded")
    , ("md",   8,    "rounded-lg")
    , ("lg",   12,   "rounded-xl")
    , ("full", 9999, "rounded-full")
    ]

-- ---------------------------------------------------------------------------
-- Responsive layout
-- ---------------------------------------------------------------------------

-- | (name, description, mobileColumns, smColumns, mdColumns, lgColumns, xlColumns)
-- Column counts in a CSS grid or Tailwind grid at each breakpoint.
type ResponsiveGridRow = (Text, Text, Int, Int, Int, Int, Int)

responsiveGrids :: [ResponsiveGridRow]
responsiveGrids =
    [ ("colorSwatches",      "Colour swatch grid",         1, 2, 2, 3, 4)
    , ("logoCards",          "Logo card grid",              1, 2, 2, 3, 3)
    , ("componentPreviews",  "Component preview cards",     1, 1, 2, 2, 3)
    , ("statCards",          "Stats / metric cards",        1, 2, 2, 4, 4)
    ]

responsiveRules :: [Text]
responsiveRules =
    [ "Design mobile-first: write base styles for mobile, then override with sm:, md:, lg: prefixes."
    , "All page content wraps at max-w-5xl (1024px) with px-4 (16px) horizontal padding on all screens."
    , "Stack layouts vertically on mobile; switch to horizontal/grid at sm (640px) or md (768px)."
    , "Tables wider than the viewport must use overflow-x-auto."
    , "Never rely on hover-only interactions; provide touch-friendly tap targets (min 44x44px)."
    , "Use the prefers-reduced-motion media query for all animations."
    , "The Display type style is recommended for screens >= md (768px). Use Heading1 on smaller screens."
    , "Minimum tap target size: 44x44px (WCAG 2.5.5 AAA). Use py-3 px-4 as a minimum for interactive elements."
    ]
