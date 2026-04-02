{-# LANGUAGE OverloadedStrings #-}

{- | JSON-LD design-guide section files.

Generates design-guide/*.jsonld — one file per concern.
Each file is self-contained (has its own @context reference) so
agents can fetch only what they need.

Vocabulary base: https://logo.palikkaharrastajat.fi/design-guide/vocab#
Standard prefixes: schema (schema.org), dc (Dublin Core), xsd.
-}
module Guide.JsonLd (generateJsonLd) where

import Data.Aeson ((.=))
import Data.Aeson qualified as A
import Data.Aeson.Encode.Pretty qualified as AP
import Data.Aeson.Key qualified as AK
import Data.ByteString.Lazy qualified as BSL
import Data.Text (Text)
import Data.Text qualified as T
import Guide.Colors (associationName)
import Guide.DesignData
import System.Directory (createDirectoryIfMissing)

-- ── Helpers ───────────────────────────────────────────────────────────────────

baseUrl :: Text
baseUrl = "https://logo.palikkaharrastajat.fi"

dgUrl :: Text -> Text
dgUrl p = baseUrl <> "/design-guide/" <> p

ctxUrl :: Text
ctxUrl = dgUrl "context.jsonld"

tokenId :: Text -> Text -> Text
tokenId section name = dgUrl (section <> ".jsonld#") <> name

ppCfg :: AP.Config
ppCfg = AP.defConfig{AP.confIndent = AP.Spaces 2, AP.confTrailingNewline = True}

writeSection :: FilePath -> A.Value -> IO ()
writeSection path val = do
    BSL.writeFile path (AP.encodePretty' ppCfg val)
    putStrLn $ "    " <> path

-- ── Entry point ───────────────────────────────────────────────────────────────

generateJsonLd :: IO ()
generateJsonLd = do
    let dir = "design-guide"
    createDirectoryIfMissing True dir
    writeSection (dir <> "/context.jsonld") buildContext
    writeSection (dir <> "/index.jsonld") buildIndex
    writeSection (dir <> "/colors.jsonld") buildColorsLd
    writeSection (dir <> "/typography.jsonld") buildTypographyLd
    writeSection (dir <> "/spacing.jsonld") buildSpacingLd
    writeSection (dir <> "/motion.jsonld") buildMotionLd
    writeSection (dir <> "/logos.jsonld") buildLogosLd
    writeSection (dir <> "/components.jsonld") buildComponentsLd
    writeSection (dir <> "/responsiveness.jsonld") buildResponsivenessLd
    writeSection (dir <> "/all-in-one.jsonld") buildAllInOneLd

-- ── @context ─────────────────────────────────────────────────────────────────
--
-- The context file defines the shared vocabulary so individual section
-- files stay lean. Agents should resolve this URL before parsing tokens.

buildContext :: A.Value
buildContext =
    A.object
        [ "@id" .= dgUrl "context.jsonld"
        , "@context"
            .= A.object
                [ "@vocab" .= ("https://logo.palikkaharrastajat.fi/design-guide/vocab#" :: Text)
                , "schema" .= ("https://schema.org/" :: Text)
                , "dc" .= ("http://purl.org/dc/terms/" :: Text)
                , "xsd" .= ("http://www.w3.org/2001/XMLSchema#" :: Text)
                , -- Standard metadata
                  "name" .= ("schema:name" :: Text)
                , "description" .= ("dc:description" :: Text)
                , "version" .= ("schema:version" :: Text)
                , "license" .= ("schema:license" :: Text)
                , "url" .= A.object ["@type" .= ("@id" :: Text)]
                , "seeAlso" .= A.object ["@type" .= ("@id" :: Text), "@id" .= ("schema:sameAs" :: Text)]
                , -- Design token primitives (DTCG-inspired)
                  "value" .= ("vocab:value" :: Text)
                , "tokenType" .= ("vocab:tokenType" :: Text)
                , "tailwindClass" .= ("vocab:tailwindClass" :: Text)
                , "cssClass" .= ("vocab:cssClass" :: Text)
                , "wcag" .= ("vocab:wcag" :: Text)
                , "usage" .= A.object ["@id" .= ("vocab:usage" :: Text), "@container" .= ("@set" :: Text)]
                , "tokens" .= A.object ["@id" .= ("vocab:tokens" :: Text), "@container" .= ("@set" :: Text)]
                , "sections" .= A.object ["@id" .= ("schema:hasPart" :: Text), "@container" .= ("@set" :: Text)]
                , "props" .= A.object ["@id" .= ("vocab:props" :: Text), "@container" .= ("@set" :: Text)]
                , "tokenDeps" .= A.object ["@id" .= ("vocab:tokenDependencies" :: Text), "@container" .= ("@set" :: Text)]
                , -- Named types
                  "DesignGuide" .= ("schema:CreativeWork" :: Text)
                , "ColorToken" .= ("vocab:ColorToken" :: Text)
                , "SemanticColorToken" .= ("vocab:SemanticColorToken" :: Text)
                , "TypographyStyle" .= ("vocab:TypographyStyle" :: Text)
                , "SpacingToken" .= ("vocab:SpacingToken" :: Text)
                , "MotionToken" .= ("vocab:MotionToken" :: Text)
                , "EasingToken" .= ("vocab:EasingToken" :: Text)
                , "LogoVariant" .= ("vocab:LogoVariant" :: Text)
                , "FaviconAsset" .= ("vocab:FaviconAsset" :: Text)
                , "ComponentSpec" .= ("vocab:ComponentSpec" :: Text)
                , "BreakpointToken" .= ("vocab:BreakpointToken" :: Text)
                , "ResponsiveGridToken" .= ("vocab:ResponsiveGridToken" :: Text)
                ]
        , "description" .= ("Shared JSON-LD context for the Suomen Palikkaharrastajat ry design guide. All section files reference this document via @context. Vocabulary base: https://logo.palikkaharrastajat.fi/design-guide/vocab#" :: Text)
        , "vocabSummary"
            .= A.object
                [ "BreakpointToken" .= ("A CSS breakpoint dimension token (min-width value in px). Used in responsiveness.jsonld." :: Text)
                , "ColorToken" .= ("A primitive brand colour with hex value and WCAG contrast data. Used in colors.jsonld." :: Text)
                , "ComponentSpec" .= ("An Elm UI component definition with module name, props, and token dependencies. Used in components.jsonld." :: Text)
                , "DesignGuide" .= ("The root design guide document (mapped to schema:CreativeWork). Used in index.jsonld." :: Text)
                , "EasingToken" .= ("A CSS cubic-bezier easing curve. Value is a [p1x, p1y, p2x, p2y] array. Used in motion.jsonld." :: Text)
                , "FaviconAsset" .= ("A favicon or app-icon PNG/ICO asset with size metadata. Used in logos.jsonld." :: Text)
                , "LogoVariant" .= ("A logo variant with SVG, PNG and WebP asset URLs. Used in logos.jsonld." :: Text)
                , "MotionToken" .= ("A duration token in milliseconds. Includes cssVariable for @theme integration. Used in motion.jsonld." :: Text)
                , "ResponsiveGridToken" .= ("A named responsive grid pattern with column counts per breakpoint. Used in responsiveness.jsonld." :: Text)
                , "SemanticColorToken" .= ("A semantic colour alias with Tailwind class, CSS variable name, and usage description. Used in colors.jsonld." :: Text)
                , "SpacingToken" .= ("A spacing step on the 4px base scale with rem value and Tailwind class. Used in spacing.jsonld." :: Text)
                , "TypographyStyle" .= ("A named type-scale entry with font size, weight, line height and Tailwind CSS class. Used in typography.jsonld." :: Text)
                , "cssClass" .= ("The Tailwind CSS utility class string for a token." :: Text)
                , "tailwindClass" .= ("Canonical Tailwind utility class for a semantic token (e.g. text-brand, bg-brand-yellow)." :: Text)
                , "tokenType" .= ("DTCG-inspired token type discriminator: color | dimension | duration | cubicBezier | typography | fontFamily." :: Text)
                , "wcag" .= ("WCAG 2.1 contrast ratio data for a colour token, keyed by background (onWhite, onBlack, onBrand)." :: Text)
                ]
        ]

-- ── Root index ────────────────────────────────────────────────────────────────

buildIndex :: A.Value
buildIndex =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("DesignGuide" :: Text)
        , "@id" .= dgUrl "index.jsonld"
        , "name" .= associationName
        , "description" .= ("Machine-readable design guide for Suomen Palikkaharrastajat ry. The design-guide.json file conforms to W3C Design Tokens 2025.10. Generated — do not edit by hand." :: Text)
        , "conformance"
            .= A.object
                [ "version" .= ("2025.10" :: Text)
                , "spec" .= ("https://tr.designtokens.org/format/" :: Text)
                , "note" .= ("The JSON-LD section files use a custom @context vocabulary and are not directly W3C Design Tokens 2025.10 conformant. The monolithic design-guide.json uses the standard $value/$type/$extensions format and is the conformant representation." :: Text)
                ]
        , "version" .= ("2025.10" :: Text)
        , "updatedAt" .= ("2026-03-18" :: Text)
        , "url" .= baseUrl
        , "seeAlso" .= (baseUrl <> "/design-guide.json")
        , "representations"
            .= A.object
                [ "jsonld"
                    .= A.object
                        [ "canonical" .= True
                        , "url" .= dgUrl "index.jsonld"
                        , "description" .= ("Split JSON-LD files (this index + one file per section). Preferred for agents: fetch only the sections you need. Each section file is self-contained with its own @context reference." :: Text)
                        ]
                , "jsonldBundle"
                    .= A.object
                        [ "canonical" .= False
                        , "url" .= dgUrl "all-in-one.jsonld"
                        , "description" .= ("All sections in one JSON-LD document. Use for single-fetch agent priming when latency matters more than payload size." :: Text)
                        ]
                , "json"
                    .= A.object
                        [ "canonical" .= False
                        , "url" .= (baseUrl <> "/design-guide.json")
                        , "description" .= ("Monolithic W3C Design Tokens 2025.10 file. All tokens in one document using $value/$type/$extensions format. Preferred for design-tooling integrations (Style Dictionary, Theo, Figma Tokens)." :: Text)
                        ]
                ]
        , "sections"
            .= A.toJSON
                [ section "colors.jsonld" "Värit" "Colour tokens with WCAG contrast data"
                , section "typography.jsonld" "Typografia" "Type scale and font information"
                , section "spacing.jsonld" "Välistys" "Spacing scale and layout constants"
                , section "motion.jsonld" "Animaatiot" "Duration and easing tokens"
                , section "logos.jsonld" "Logot" "Logo variants with usage rules"
                , section "components.jsonld" "Komponentit" "Elm UI component catalogue"
                , section "responsiveness.jsonld" "Responsiivisuus" "Breakpoints, grids and mobile-first rules"
                ]
        ]
  where
    section file name_ desc =
        A.object ["@id" .= dgUrl file, "name" .= (name_ :: Text), "description" .= (desc :: Text)]

-- ── Colors ────────────────────────────────────────────────────────────────────

buildColorsLd :: A.Value
buildColorsLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:ColorSection" :: Text)
        , "@id" .= dgUrl "colors.jsonld"
        , "name" .= ("Värit" :: Text)
        , "description" .= ("Brand colour tokens with WCAG 2.1 contrast ratios. All colour usage must pass at least WCAG AA." :: Text)
        , "seeAlso" .= (baseUrl <> "/design-guide.json")
        , "tokens" .= A.toJSON (brandTokens ++ skinToneTokens ++ semanticTokens)
        ]
  where
    brandTokens =
        [ colorTok
            "brand-black"
            "Black"
            "#05131D"
            "Primary brand colour. Never hard-code — use Guide.Tokens in Elm."
            (A.object ["onWhite" .= (17.3 :: Double), "onWhiteRating" .= ("AAA" :: Text)])
        , colorTok
            "brand-white"
            "White"
            "#FFFFFF"
            "Use for eye highlights and text on dark/brand backgrounds."
            (A.object ["onBrand" .= (17.3 :: Double), "onBrandRating" .= ("AAA" :: Text)])
        , colorTok
            "red"
            "Red"
            "#C91A09"
            "Accent colour from the Blacktron series. Use for highlights, danger states, and emphasis."
            (A.object ["onWhite" .= (5.0 :: Double), "onWhiteRating" .= ("AA" :: Text), "onBlack" .= (4.2 :: Double), "onBlackRating" .= ("AA" :: Text)])
        ]

    skinData :: [(Text, Text, Text, Text, A.Value)]
    skinData =
        [
            ( "yellow"
            , "Yellow"
            , "#FAC80A"
            , "Classic LEGO minifig yellow. Brand accent colour."
            , A.object ["onWhite" .= (1.5 :: Double), "onWhiteRating" .= ("fail" :: Text), "onBlack" .= (11.5 :: Double), "onBlackRating" .= ("AAA" :: Text)]
            )
        ,
            ( "light-nougat"
            , "Light Nougat"
            , "#F6D7B3"
            , "Light skin tone. Decorative only."
            , A.object ["onWhite" .= (1.4 :: Double), "onWhiteRating" .= ("fail" :: Text), "onBlack" .= (12.4 :: Double), "onBlackRating" .= ("AAA" :: Text)]
            )
        ,
            ( "nougat"
            , "Nougat"
            , "#D09168"
            , "Medium skin tone."
            , A.object ["onWhite" .= (2.6 :: Double), "onWhiteRating" .= ("fail" :: Text), "onBlack" .= (6.7 :: Double), "onBlackRating" .= ("AA" :: Text)]
            )
        ,
            ( "dark-nougat"
            , "Dark Nougat"
            , "#AD6140"
            , "Dark skin tone."
            , A.object ["onWhite" .= (4.4 :: Double), "onWhiteRating" .= ("AA" :: Text), "onBlack" .= (4.0 :: Double), "onBlackRating" .= ("AA" :: Text)]
            )
        ]

    skinToneTokens = [colorTok sid sname hex desc wcag | (sid, sname, hex, desc, wcag) <- skinData]

    colorTok tid tname hex desc wcag =
        A.object
            [ "@type" .= ("ColorToken" :: Text)
            , "@id" .= tokenId "colors" tid
            , "name" .= (tname :: Text)
            , "value" .= (hex :: Text)
            , "tokenType" .= ("color" :: Text)
            , "description" .= (desc :: Text)
            , "wcag" .= wcag
            ]

    semanticTokens =
        [ A.object
            [ "@type" .= ("SemanticColorToken" :: Text)
            , "@id" .= tokenId "colors" ("semantic-" <> T.replace "." "-" p)
            , "name" .= p
            , "value" .= val
            , "tailwindClass" .= tw
            , "cssVariable" .= cssVar
            , "tokenType" .= ("color" :: Text)
            , "description" .= desc
            ]
        | (_, p, val, tw, cssVar, desc) <- semanticColors
        ]

-- ── Typography ────────────────────────────────────────────────────────────────

-- | Map a letter-spacing em value to the closest Tailwind tracking class.
lsTailwind :: Double -> Text
lsTailwind ls
    | ls <= -0.05 = "tracking-tighter"
    | ls < 0.0 = "tracking-tight"
    | ls == 0.0 = "tracking-normal"
    | ls <= 0.025 = "tracking-wide"
    | ls <= 0.05 = "tracking-wider"
    | otherwise = "tracking-widest"

buildTypographyLd :: A.Value
buildTypographyLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:TypographySection" :: Text)
        , "@id" .= dgUrl "typography.jsonld"
        , "name" .= ("Typografia" :: Text)
        , "description" .= ("Outfit variable font, weight 100–900. All type styles are named tokens; never specify raw sizes in components." :: Text)
        , "primaryFont"
            .= A.object
                [ "family" .= ("Outfit" :: Text)
                , "axes" .= A.toJSON [A.object ["tag" .= ("wght" :: Text), "min" .= (100 :: Int), "max" .= (900 :: Int)]]
                , "fontDisplay" .= ("swap" :: Text)
                , "license" .= ("OFL-1.1" :: Text)
                , "url" .= (baseUrl <> "/fonts/Outfit-VariableFont_wght.ttf")
                ]
        , "tokens"
            .= A.toJSON
                ( A.object
                    [ "@type" .= ("TypographyStyle" :: Text)
                    , "@id" .= tokenId "typography" "fontFamily.sans"
                    , "name" .= ("fontFamily.sans" :: Text)
                    , "tokenType" .= ("fontFamily" :: Text)
                    , "value" .= ("Outfit, system-ui, sans-serif" :: Text)
                    , "cssVariable" .= ("--font-sans" :: Text)
                    , "fontDisplay" .= ("swap" :: Text)
                    , "tailwindTheme" .= ("@theme { --font-sans: \"Outfit\", system-ui, sans-serif; }" :: Text)
                    , "description" .= ("Primary sans-serif font stack. Use in Tailwind v4 @theme as --font-sans." :: Text)
                    ]
                    : [ let base =
                                [ "@type" .= ("TypographyStyle" :: Text)
                                , "@id" .= tokenId "typography" (T.toLower name)
                                , "name" .= name
                                , "tokenType" .= ("typography" :: Text)
                                , "description" .= desc
                                , "fontFamily" .= ("Outfit, system-ui, sans-serif" :: Text)
                                , "fontWeight" .= weight
                                , "fontSizeRem" .= sizeRem
                                , "fontSizePx" .= sizePx
                                , "lineHeight" .= lh
                                , "cssClass" .= cssClass
                                ]
                            lsPairs =
                                [ "letterSpacing"
                                    .= A.object
                                        [ "value" .= ls
                                        , "unit" .= ("em" :: Text)
                                        , "cssValue" .= (T.pack (show ls) <> "em")
                                        , "tailwindClass" .= lsTailwind ls
                                        ]
                                | ls /= 0.0
                                ]
                         in A.object (base ++ lsPairs)
                      | (name, weight, sizeRem, sizePx, lh, ls, cssClass, desc) <- typeScale
                      ]
                )
        , "usageRules" .= A.toJSON typographyUsageRules
        ]

-- ── Spacing ───────────────────────────────────────────────────────────────────

buildSpacingLd :: A.Value
buildSpacingLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:SpacingSection" :: Text)
        , "@id" .= dgUrl "spacing.jsonld"
        , "name" .= ("Välistys" :: Text)
        , "description" .= ("4px-base spacing scale. Use only named tokens; never arbitrary pixel values." :: Text)
        , "baseUnit" .= A.object ["value" .= (4 :: Int), "tokenType" .= ("dimension" :: Text), "unit" .= ("px" :: Text)]
        , "tokens"
            .= A.toJSON
                [ A.object
                    [ "@type" .= ("SpacingToken" :: Text)
                    , "@id" .= tokenId "spacing" name
                    , "name" .= name
                    , "tokenType" .= ("dimension" :: Text)
                    , "multiplier" .= mult
                    , "value" .= A.object ["value" .= px, "unit" .= ("px" :: Text)]
                    , "rem" .= rem_
                    , "tailwindClass" .= tw
                    , "description" .= desc
                    ]
                | (name, mult, px, rem_, tw, desc) <- spacingScale
                ]
        , "shadows"
            .= A.object
                [ "none" .= A.object ["@id" .= tokenId "spacing" "shadow-none", "tokenType" .= ("shadow" :: Text), "tailwindClass" .= ("shadow-none" :: Text), "description" .= ("No shadow. Use for flat UI elements." :: Text)]
                , "sm" .= A.object ["@id" .= tokenId "spacing" "shadow-sm", "tokenType" .= ("shadow" :: Text), "tailwindClass" .= ("shadow-sm" :: Text), "value" .= ("0 1px 2px 0 rgb(0 0 0 / 0.05)" :: Text), "description" .= ("Subtle shadow for cards and panels." :: Text)]
                , "md" .= A.object ["@id" .= tokenId "spacing" "shadow-md", "tokenType" .= ("shadow" :: Text), "tailwindClass" .= ("shadow" :: Text), "value" .= ("0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)" :: Text), "description" .= ("Standard shadow for elevated cards and dropdowns." :: Text)]
                , "lg" .= A.object ["@id" .= tokenId "spacing" "shadow-lg", "tokenType" .= ("shadow" :: Text), "tailwindClass" .= ("shadow-lg" :: Text), "value" .= ("0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)" :: Text), "description" .= ("Prominent shadow for modals and floating panels." :: Text)]
                ]
        , "layout"
            .= A.object
                [ "contentWidth"
                    .= A.object
                        [ "value" .= A.object ["value" .= contentWidthPx, "unit" .= ("px" :: Text)]
                        , "tailwindClass" .= contentWidthTailwind
                        ]
                , "pageWrapper" .= A.object ["tailwindClass" .= pageWrapperClass]
                , "breakpoints"
                    .= A.object
                        [ AK.fromText bp
                            .= A.object
                                [ "value" .= A.object ["value" .= bpx, "unit" .= ("px" :: Text)]
                                , "tokenType" .= ("dimension" :: Text)
                                ]
                        | (bp, bpx) <- breakpoints
                        ]
                , "borderRadius"
                    .= A.object
                        [ AK.fromText n
                            .= A.object
                                [ "value" .= A.object ["value" .= v, "unit" .= ("px" :: Text)]
                                , "tailwindClass" .= tw
                                ]
                        | (n, v, tw) <- borderRadii
                        ]
                ]
        ]

-- ── Motion ────────────────────────────────────────────────────────────────────

buildMotionLd :: A.Value
buildMotionLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:MotionSection" :: Text)
        , "@id" .= dgUrl "motion.jsonld"
        , "name" .= ("Animaatiot" :: Text)
        , "description" .= ("All animations must respect prefers-reduced-motion: reduce." :: Text)
        , "tokens"
            .= A.toJSON
                ( [ A.object
                    [ "@type" .= ("MotionToken" :: Text)
                    , "@id" .= tokenId "motion" ("duration-" <> name)
                    , "name" .= ("duration." <> name)
                    , "tokenType" .= ("duration" :: Text)
                    , "value" .= ms
                    , "unit" .= ("ms" :: Text)
                    , "cssVariable" .= cssVar
                    , "description" .= desc
                    ]
                  | (name, ms, cssVar, desc) <- motionDurationData
                  ]
                    ++ [ A.object
                        [ "@type" .= ("EasingToken" :: Text)
                        , "@id" .= tokenId "motion" ("easing-" <> name)
                        , "name" .= ("easing." <> name)
                        , "tokenType" .= ("cubicBezier" :: Text)
                        , "value" .= A.toJSON [p1x, p1y, p2x, p2y]
                        , "cssValue"
                            .= ( "cubic-bezier("
                                    <> T.pack (show p1x)
                                    <> ", "
                                    <> T.pack (show p1y)
                                    <> ", "
                                    <> T.pack (show p2x)
                                    <> ", "
                                    <> T.pack (show p2y)
                                    <> ")"
                               )
                        , "description" .= desc
                        ]
                       | (name, p1x, p1y, p2x, p2y, desc) <- motionEasingData
                       ]
                )
        , "usageRules" .= A.toJSON motionUsageRules
        ]

-- ── Logos ─────────────────────────────────────────────────────────────────────

buildLogosLd :: A.Value
buildLogosLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:LogoSection" :: Text)
        , "@id" .= dgUrl "logos.jsonld"
        , "name" .= ("Logot" :: Text)
        , "description" .= ("All logo variants with usage rules and prohibitions." :: Text)
        , "contextMapping" .= logoContextMapping
        , "variantGuidance" .= logoVariantGuidance
        , "usageRules" .= logoUsageRules
        , "tokens" .= A.toJSON (squareTokens ++ horizontalTokens ++ faviconTokens)
        ]
  where
    logoContextMapping =
        A.object
            [ "pageHeader" .= A.object ["variant" .= ("square-smile-full or horizontal-full" :: Text), "format" .= ("SVG" :: Text)]
            , "pageHeaderDark" .= A.object ["variant" .= ("square-smile-full-dark or horizontal-full-dark" :: Text), "format" .= ("SVG" :: Text)]
            , "socialMediaOg" .= A.object ["variant" .= ("horizontal-full" :: Text), "format" .= ("PNG (1200x630)" :: Text)]
            , "faviconBrowser" .= A.object ["variant" .= ("favicon.ico + favicon-32.png" :: Text), "format" .= ("ICO + PNG" :: Text)]
            , "pwaAndroid" .= A.object ["variant" .= ("icon-192.png + icon-512.png" :: Text), "format" .= ("PNG" :: Text)]
            , "iosHomeScreen" .= A.object ["variant" .= ("apple-touch-icon.png (180px)" :: Text), "format" .= ("PNG" :: Text)]
            , "print" .= A.object ["variant" .= ("horizontal-full or square-smile-full" :: Text), "format" .= ("SVG or 300dpi+ PNG" :: Text)]
            , "animatedBanner" .= A.object ["variant" .= ("square-animated or horizontal-full-animated" :: Text), "format" .= ("WebP/GIF (not for prefers-reduced-motion users)" :: Text)]
            ]
    logoVariantGuidance =
        A.object
            [ "standard"
                .= A.object
                    [ "description" .= ("The default brand logo set. Use in all standard contexts — page headers, favicons, social media." :: Text)
                    , "variants" .= A.toJSON (["square-basic", "square-smile", "square-blink", "square-laugh", "horizontal", "horizontal-full", "horizontal-full-dark"] :: [Text])
                    ]
            , "rainbow"
                .= A.object
                    [ "description" .= ("Celebratory / Pride variant. Decorative only — do not use as the primary brand identifier." :: Text)
                    , "usageContext" .= ("Pride Month, LEGO Fan events, community celebrations." :: Text)
                    , "restrictions"
                        .= A.toJSON
                            [ "Do not use rainbow variants in formal or legal documents."
                            , "Do not substitute for the standard logo in press releases or official communications." ::
                                Text
                            ]
                    ]
            , "skintone"
                .= A.object
                    [ "description" .= ("Inclusive skin-tone variant using the nougat palette. Decorative only." :: Text)
                    , "usageContext" .= ("Diversity-focused communications, inclusive event materials." :: Text)
                    , "restrictions"
                        .= A.toJSON
                            [ "Do not use as the primary brand logo in navigation or headers."
                            , "Do not combine with rainbow variant." ::
                                Text
                            ]
                    ]
            , "animated"
                .= A.object
                    [ "description" .= ("Animated GIF/WebP variants with looping face expressions. For digital use only." :: Text)
                    , "usageContext" .= ("Hero sections, splash screens, social media posts." :: Text)
                    , "animatedLogoRules"
                        .= A.toJSON
                            [ "Never autoplay when prefers-reduced-motion: reduce is active — show the static PNG fallback instead."
                            , "Do not use in print, PDF, or static email."
                            , "Frame hold duration token: duration.logoFrame (10 000 ms)." ::
                                Text
                            ]
                    ]
            ]
    logoUsageRules =
        A.object
            [ "clearSpace" .= ("Minimum 25% of logo width on all four sides." :: Text)
            , "minimumSize" .= A.object ["digital" .= ("80px wide (square) / 200px wide (horizontal)" :: Text), "print" .= ("20mm wide" :: Text)]
            , "preferredFormat"
                .= A.object
                    [ "web" .= ("SVG first; WebP with PNG fallback" :: Text)
                    , "print" .= ("SVG or 300dpi+ PNG" :: Text)
                    ]
            , "prohibitions"
                .= A.toJSON
                    [ "Do not stretch, squash, or distort the logo."
                    , "Do not recolour logo elements."
                    , "Do not apply drop shadows or outer strokes."
                    , "Do not use the animated logo in print or static email."
                    , "Do not display animated logo when prefers-reduced-motion is active." ::
                        Text
                    ]
            ]
    asset path = baseUrl <> "/" <> path
    squareSkins = ["square-basic", "square-smile", "square-blink", "square-laugh"]
    squareTokens =
        [ A.object
            [ "@type" .= ("LogoVariant" :: Text)
            , "@id" .= tokenId "logos" stem
            , "name" .= (stem :: Text)
            , "shape" .= ("square" :: Text)
            , "svg" .= asset ("logo/square/svg/" <> stem <> ".svg")
            , "png" .= asset ("logo/square/png/" <> stem <> ".png")
            , "webp" .= asset ("logo/square/png/" <> stem <> ".webp")
            ]
        | stem <- squareSkins
        ]
    horizontalSkins =
        [ "horizontal"
        , "horizontal-full"
        , "horizontal-full-dark"
        , "horizontal-rainbow"
        , "horizontal-rainbow-full"
        , "horizontal-rainbow-full-dark"
        , "horizontal-skintone"
        , "horizontal-skintone-full"
        , "horizontal-skintone-full-dark"
        ]
    horizontalTokens =
        [ A.object
            [ "@type" .= ("LogoVariant" :: Text)
            , "@id" .= tokenId "logos" stem
            , "name" .= (stem :: Text)
            , "shape" .= ("horizontal" :: Text)
            , "svg" .= asset ("logo/horizontal/svg/" <> stem <> ".svg")
            , "png" .= asset ("logo/horizontal/png/" <> stem <> ".png")
            , "webp" .= asset ("logo/horizontal/png/" <> stem <> ".webp")
            ]
        | stem <- horizontalSkins
        ]
    faviconTokens =
        -- Browser favicons
        [ favTok "favicon-16" 16 "Browser favicon (16×16)"
        , favTok "favicon-32" 32 "Browser favicon (32×32)"
        , favTok "favicon-48" 48 "Browser favicon (48×48)"
        , favTok "favicon-64" 64 "Browser favicon (64×64)"
        , -- Apple touch icons
          favTok "apple-touch-icon-120" 120 "Apple touch icon for iPhone retina (120×120)"
        , favTok "apple-touch-icon-152" 152 "Apple touch icon for iPad (152×152)"
        , favTok "apple-touch-icon-167" 167 "Apple touch icon for iPad Pro (167×167)"
        , favTok "apple-touch-icon" 180 "Apple touch icon default (180×180)"
        , -- PWA / maskable icons
          favTok "icon-192" 192 "PWA icon (192×192)"
        , favTok "icon-512" 512 "PWA icon and splash screen (512×512)"
        , -- Multi-size ICO bundle
          A.object
            [ "@type" .= ("FaviconAsset" :: Text)
            , "@id" .= tokenId "logos" "favicon/favicon"
            , "name" .= ("favicon" :: Text)
            , "description" .= ("Multi-size ICO bundle (16, 32, 48, 64px)" :: Text)
            , "ico" .= asset ("favicon/favicon.ico" :: Text)
            ]
        ]
    favTok stem sz desc =
        A.object
            [ "@type" .= ("FaviconAsset" :: Text)
            , "@id" .= tokenId "logos" ("favicon/" <> stem)
            , "name" .= (stem :: Text)
            , "sizePx" .= (sz :: Int)
            , "description" .= (desc :: Text)
            , "png" .= asset ("favicon/" <> stem <> ".png")
            ]

-- ── Components ────────────────────────────────────────────────────────────────

buildComponentsLd :: A.Value
buildComponentsLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:ComponentSection" :: Text)
        , "@id" .= dgUrl "components.jsonld"
        , "name" .= ("Komponentit" :: Text)
        , "description" .= ("Elm UI component catalogue. Import by module name; never copy-paste HTML inline." :: Text)
        , "sourceDir" .= ("src/Component/" :: Text)
        , "tokens" .= A.toJSON (map componentTok preCatalog ++ [buttonTok] ++ map componentTok postCatalog)
        ]
  where
    componentTok (name, modName, desc, props, deps) =
        A.object
            [ "@type" .= ("ComponentSpec" :: Text)
            , "@id" .= tokenId "components" (T.toLower name)
            , "name" .= (name :: Text)
            , "elmModule" .= (modName :: Text)
            , "description" .= (desc :: Text)
            , "props" .= A.toJSON (props :: [Text])
            , "tokenDeps" .= A.toJSON (deps :: [Text])
            ]

    buttonTok :: A.Value
    buttonTok =
        A.object
            [ "@type" .= ("ComponentSpec" :: Text)
            , "@id" .= tokenId "components" "button"
            , "name" .= ("Button" :: Text)
            , "elmModule" .= ("Component.Button" :: Text)
            , "description" .= ("Action button or link-button. Variants: Primary, Secondary, Ghost, Danger." :: Text)
            , "props"
                .= A.toJSON
                    [ "label: String"
                    , "variant: Variant (Primary|Secondary|Ghost|Danger)"
                    , "size: Size (Small|Medium|Large)"
                    , "onClick: msg  OR  href: String"
                    , "disabled: Bool"
                    , "loading: Bool" ::
                        Text
                    ]
            , "tokenDeps" .= A.toJSON (["colors.semantic.background.accent"] :: [Text])
            , "focusStyle" .= ("focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2" :: Text)
            , "notes"
                .= A.toJSON
                    [ "Use focus-visible: not focus: so the ring only shows for keyboard navigation."
                    , "Toggle/filter buttons must include aria-pressed attribute (true|false)." ::
                        Text
                    ]
            , "variants"
                .= A.object
                    [ "Primary" .= A.object ["base" .= ("bg-brand-yellow text-brand font-semibold rounded" :: Text), "hover" .= ("hover:opacity-90" :: Text), "focusVisible" .= ("focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2" :: Text), "disabled" .= ("opacity-40 cursor-not-allowed" :: Text)]
                    , "Secondary" .= A.object ["base" .= ("bg-white border border-gray-300 text-brand font-semibold rounded" :: Text), "hover" .= ("hover:bg-gray-50" :: Text), "focusVisible" .= ("focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2" :: Text), "disabled" .= ("opacity-40 cursor-not-allowed" :: Text)]
                    , "Ghost" .= A.object ["base" .= ("bg-transparent text-brand font-semibold rounded" :: Text), "hover" .= ("hover:bg-gray-100" :: Text), "focusVisible" .= ("focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2" :: Text), "disabled" .= ("opacity-40 cursor-not-allowed" :: Text)]
                    , "Danger" .= A.object ["base" .= ("bg-red-600 text-white font-semibold rounded" :: Text), "hover" .= ("hover:bg-red-700" :: Text), "focusVisible" .= ("focus-visible:ring-2 focus-visible:ring-red-500 focus-visible:ring-offset-2" :: Text), "disabled" .= ("opacity-40 cursor-not-allowed" :: Text)]
                    ]
            ]

    -- Components before Button (alphabetical)
    preCatalog :: [(Text, Text, Text, [Text], [Text])]
    preCatalog =
        [ ("Alert", "Component.Alert", "Contextual feedback message. Types: Info, Success, Warning, Error.", ["alertType: AlertType", "title: Maybe String", "body: List (Html msg)"], [])
        , ("Accordion", "Component.Accordion", "Collapsible sections using native <details>.", ["items: List { title: String, body: List (Html msg) }"], ["colors.semantic.border.default"])
        , ("Badge", "Component.Badge", "Small inline label. Colors: Gray, Blue, Green, Yellow, Red, Purple, Indigo.", ["label: String", "color: Color"], [])
        , ("Breadcrumb", "Component.Breadcrumb", "Navigation breadcrumb trail.", ["items: List { label: String, href: Maybe String }"], [])
        ]

    -- Components after Button (alphabetical)
    postCatalog :: [(Text, Text, Text, [Text], [Text])]
    postCatalog =
        [ ("ButtonGroup", "Component.ButtonGroup", "Horizontally grouped buttons sharing a border.", ["buttons: List (Html msg)"], [])
        , ("Card", "Component.Card", "Content container with optional header, footer, image, shadow.", ["body, header, footer: Maybe Html", "shadow: Shadow (None | Sm | Md | Lg)"], ["colors.semantic.border.default", "spacing.shadows"])
        , ("CloseButton", "Component.CloseButton", "Accessible close/dismiss button.", ["onClick: msg", "label: String"], [])
        , ("Collapse", "Component.Collapse", "Single collapsible section using <details>.", ["summary: Html msg", "body: List (Html msg)", "open: Bool"], [])
        , ("ColorSwatch", "Component.ColorSwatch", "Colour token display with hex, name, description, usage tags.", ["hex, name, description: String", "usageTags: List String"], ["colors.semantic.text.primary"])
        , ("Dialog", "Component.Dialog", "Modal dialog with title, body, footer and close handler.", ["title: String", "body: List (Html msg)", "footer: Maybe (Html msg)", "isOpen: Bool", "onClose: msg"], [])
        , ("DownloadButton", "Component.DownloadButton", "Styled download link button.", ["label: String", "href: String"], [])
        , ("Dropdown", "Component.Dropdown", "Disclosure dropdown using <details>/<summary>.", ["trigger: Html msg", "items: List (Html msg)"], [])
        , ("ListGroup", "Component.ListGroup", "Vertical list with optional active states and badges.", ["items: List (Html msg)"], ["colors.semantic.border.default"])
        , ("LogoCard", "Component.LogoCard", "Logo variant gallery card with download links.", ["id, description, theme, animated, svgUrl, pngUrl, webpUrl"], ["colors.semantic.background.dark"])
        , ("Pagination", "Component.Pagination", "Page navigation control.", ["currentPage: Int", "totalPages: Int", "onPageClick: Int -> msg"], [])
        , ("Placeholder", "Component.Placeholder", "Animated loading skeleton.", ["items: List (Html msg)"], [])
        , ("Progress", "Component.Progress", "Horizontal progress bar.", ["value: Int", "max: Int", "label: Maybe String", "color: Color"], [])
        , ("SectionHeader", "Component.SectionHeader", "Section heading with optional description.", ["title: String", "description: Maybe String"], ["typography.scale[Heading2]"])
        , ("Spinner", "Component.Spinner", "Loading spinner animation.", ["size: Size (Small|Medium|Large)", "label: String"], [])
        , ("Stats", "Component.Stats", "Metric display grid.", ["items: List { label, value, change }"], ["colors.semantic.text.muted"])
        , ("Tabs", "Component.Tabs", "Tab navigation strip (stateless — caller provides active index).", ["tabs: List String", "activeIndex: Int", "onTabClick: Int -> msg"], [])
        , ("Timeline", "Component.Timeline", "Vertical timeline for changelogs.", ["items: List { date, title, children }"], ["colors.semantic.border.default"])
        , ("Toast", "Component.Toast", "Notification toast. Variants: Default, Success, Warning, Danger.", ["title: String", "body: String", "variant: Variant", "onClose: Maybe msg"], [])
        , ("Tag", "Component.Tag", "Removable inline label chip.", ["label: String", "onRemove: Maybe msg"], [])
        , ("Toggle", "Component.Toggle", "Accessible on/off toggle switch.", ["id: String", "label: String", "checked: Bool", "onToggle: Bool -> msg", "disabled: Bool"], [])
        , ("Tooltip", "Component.Tooltip", "Hover/focus tooltip wrapping arbitrary content.", ["content: String", "children: List (Html msg)"], [])
        ]

-- ── Responsiveness ────────────────────────────────────────────────────────────

buildResponsivenessLd :: A.Value
buildResponsivenessLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:ResponsivenessSection" :: Text)
        , "@id" .= dgUrl "responsiveness.jsonld"
        , "name" .= ("Responsiivisuus" :: Text)
        , "description" .= ("Breakpoints, grid patterns and mobile-first layout rules. All values follow W3C Design Tokens 2025.10 dimension format." :: Text)
        , "seeAlso" .= (baseUrl <> "/design-guide.json")
        , "tokens"
            .= A.toJSON
                ( [ A.object
                    [ "@type" .= ("BreakpointToken" :: Text)
                    , "@id" .= tokenId "responsiveness" ("bp-" <> bp)
                    , "name" .= ("breakpoint." <> bp)
                    , "tokenType" .= ("dimension" :: Text)
                    , "value" .= A.object ["value" .= bpx, "unit" .= ("px" :: Text)]
                    , "description" .= (bp <> " breakpoint — screens ≥" <> T.pack (show bpx) <> "px")
                    ]
                  | (bp, bpx) <- breakpoints
                  ]
                    ++ [ A.object
                        [ "@type" .= ("ResponsiveGridToken" :: Text)
                        , "@id" .= tokenId "responsiveness" ("grid-" <> name)
                        , "name" .= ("grid." <> name)
                        , "description" .= desc
                        , "columns"
                            .= A.object
                                [ "mobile" .= mobile
                                , "sm" .= sm_
                                , "md" .= md_
                                , "lg" .= lg_
                                , "xl" .= xl_
                                ]
                        ]
                       | (name, desc, mobile, sm_, md_, lg_, xl_) <- responsiveGrids
                       ]
                )
        , "layout"
            .= A.object
                [ "contentWidth"
                    .= A.object
                        [ "value" .= A.object ["value" .= contentWidthPx, "unit" .= ("px" :: Text)]
                        , "tailwindClass" .= contentWidthTailwind
                        , "description" .= ("Maximum content column width. Apply max-w-5xl mx-auto px-4 to every page wrapper." :: Text)
                        ]
                , "pagePaddingX"
                    .= A.object
                        [ "value" .= A.object ["value" .= pagePaddingXPx, "unit" .= ("px" :: Text)]
                        , "tailwindClass" .= pagePaddingXTailwind
                        ]
                , "pageWrapper"
                    .= A.object
                        [ "tailwindClass" .= pageWrapperClass
                        , "description" .= ("Compose of contentWidth + pagePaddingX: max-w-5xl mx-auto px-4." :: Text)
                        ]
                ]
        , "rules" .= A.toJSON responsiveRules
        ]

-- ── All-in-one bundle ─────────────────────────────────────────────────────────
--
-- Single document containing all sections for agents that prefer one HTTP fetch.
-- Each section is embedded verbatim under a key matching its file stem.

buildAllInOneLd :: A.Value
buildAllInOneLd =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("DesignGuide" :: Text)
        , "@id" .= dgUrl "all-in-one.jsonld"
        , "name" .= associationName
        , "description" .= ("Complete design guide bundle — all sections in one document. Use this for single-fetch agent priming. Canonical split files are at design-guide/index.jsonld." :: Text)
        , "version" .= ("2025.10" :: Text)
        , "updatedAt" .= ("2026-03-18" :: Text)
        , "seeAlso" .= dgUrl "index.jsonld"
        , "colors" .= buildColorsLd
        , "typography" .= buildTypographyLd
        , "spacing" .= buildSpacingLd
        , "motion" .= buildMotionLd
        , "logos" .= buildLogosLd
        , "components" .= buildComponentsLd
        , "responsiveness" .= buildResponsivenessLd
        ]
