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
import Guide.Types
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

assetUrl :: Text -> Text
assetUrl path = baseUrl <> "/" <> path

-- ── Entry point ───────────────────────────────────────────────────────────────

generateJsonLd :: DesignGuide -> IO ()
generateJsonLd dg = do
    let dir = "design-guide"
    createDirectoryIfMissing True dir
    writeSection (dir <> "/context.jsonld") buildContext
    writeSection (dir <> "/index.jsonld") (buildIndex dg)
    writeSection (dir <> "/colors.jsonld") (buildColorsLd dg)
    writeSection (dir <> "/typography.jsonld") (buildTypographyLd dg)
    writeSection (dir <> "/spacing.jsonld") (buildSpacingLd dg)
    writeSection (dir <> "/motion.jsonld") (buildMotionLd dg)
    writeSection (dir <> "/components.jsonld") (buildComponentsLd dg)
    writeSection (dir <> "/responsiveness.jsonld") (buildResponsivenessLd dg)
    writeSection (dir <> "/all-in-one.jsonld") (buildAllInOneLd dg)

-- ── @context ─────────────────────────────────────────────────────────────────

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
                , "name" .= ("schema:name" :: Text)
                , "description" .= ("dc:description" :: Text)
                , "version" .= ("schema:version" :: Text)
                , "license" .= ("schema:license" :: Text)
                , "url" .= A.object ["@type" .= ("@id" :: Text)]
                , "seeAlso" .= A.object ["@type" .= ("@id" :: Text), "@id" .= ("schema:sameAs" :: Text)]
                , "value" .= ("vocab:value" :: Text)
                , "tokenType" .= ("vocab:tokenType" :: Text)
                , "tailwindClass" .= ("vocab:tailwindClass" :: Text)
                , "cssClass" .= ("vocab:cssClass" :: Text)
                , "wcag" .= ("vocab:wcag" :: Text)
                , "usage" .= A.object ["@id" .= ("vocab:usage" :: Text), "@container" .= ("@set" :: Text)]
                , "tokens" .= A.object ["@id" .= ("vocab:tokens" :: Text), "@container" .= ("@set" :: Text)]
                , "sections" .= A.object ["@id" .= ("schema:hasPart" :: Text), "@container" .= ("@set" :: Text)]
                , "props" .= A.object ["@id" .= ("vocab:props" :: Text), "@container" .= ("@set" :: Text)]
                , "tokenDeps" .= A.object ["@id" .= ("vocab:tokenDependencies" :: Text), "@container" .= ("@set" :: Text)]
                , "DesignGuide" .= ("schema:CreativeWork" :: Text)
                , "ColorToken" .= ("vocab:ColorToken" :: Text)
                , "SemanticColorToken" .= ("vocab:SemanticColorToken" :: Text)
                , "TypographyStyle" .= ("vocab:TypographyStyle" :: Text)
                , "SpacingToken" .= ("vocab:SpacingToken" :: Text)
                , "MotionToken" .= ("vocab:MotionToken" :: Text)
                , "EasingToken" .= ("vocab:EasingToken" :: Text)
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

buildIndex :: DesignGuide -> A.Value
buildIndex dg =
    let m = dgMeta dg
     in A.object
            [ "@context" .= ctxUrl
            , "@type" .= ("DesignGuide" :: Text)
            , "@id" .= dgUrl "index.jsonld"
            , "name" .= metaOrganization m
            , "description" .= ("Machine-readable design guide for " <> metaOrganization m <> ". The design-guide.tokens.json file conforms to W3C Design Tokens 2025.10. Generated \x2014 do not edit by hand.")
            , "conformance"
                .= A.object
                    [ "version" .= ("2025.10" :: Text)
                    , "spec" .= ("https://tr.designtokens.org/format/" :: Text)
                    , "note" .= ("The JSON-LD section files use a custom @context vocabulary and are not directly W3C Design Tokens 2025.10 conformant. The monolithic design-guide.tokens.json uses the standard $value/$type/$extensions format and is the conformant representation." :: Text)
                    ]
            , "version" .= metaVersion m
            , "url" .= baseUrl
            , "seeAlso" .= (baseUrl <> "/design-guide.tokens.json")
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
                            , "url" .= (baseUrl <> "/design-guide.tokens.json")
                            , "description" .= ("Monolithic W3C Design Tokens 2025.10 file. All tokens in one document using $value/$type/$extensions format. Preferred for design-tooling integrations (Style Dictionary, Theo, Figma Tokens)." :: Text)
                            ]
                    ]
            , "sections"
                .= A.toJSON
                    [ section "colors.jsonld" "Värit" "Colour tokens with WCAG contrast data"
                    , section "typography.jsonld" "Typografia" "Type scale and font information"
                    , section "spacing.jsonld" "Välistys" "Spacing scale and layout constants"
                    , section "motion.jsonld" "Animaatiot" "Duration and easing tokens"
                    , section "components.jsonld" "Komponentit" "Elm UI component catalogue"
                    , section "responsiveness.jsonld" "Responsiivisuus" "Breakpoints, grids and mobile-first rules"
                    ]
            ]
  where
    section file name_ desc =
        A.object ["@id" .= dgUrl file, "name" .= (name_ :: Text), "description" .= (desc :: Text)]

-- ── Colors ────────────────────────────────────────────────────────────────────

buildColorsLd :: DesignGuide -> A.Value
buildColorsLd dg =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:ColorSection" :: Text)
        , "@id" .= dgUrl "colors.jsonld"
        , "name" .= ("Värit" :: Text)
        , "description" .= ("Brand colour tokens with WCAG 2.1 contrast ratios. All colour usage must pass at least WCAG AA." :: Text)
        , "seeAlso" .= (baseUrl <> "/design-guide.tokens.json")
        , "tokens" .= A.toJSON (brandToks ++ skinToks ++ semanticToks)
        ]
  where
    brandToks =
        [ A.object
            [ "@type" .= ("ColorToken" :: Text)
            , "@id" .= tokenId "colors" (bcId bc)
            , "name" .= bcName bc
            , "value" .= hexText (bcHex bc)
            , "tokenType" .= ("color" :: Text)
            , "$description" .= bcDescription bc
            , "wcag" .= wcagObj (bcWcag bc)
            ]
        | bc <- dgBrandColors dg
        ]
    skinToks =
        [ A.object
            [ "@type" .= ("ColorToken" :: Text)
            , "@id" .= tokenId "colors" (stId st)
            , "name" .= stName st
            , "value" .= hexText (stHex st)
            , "tokenType" .= ("color" :: Text)
            , "description" .= stDescription st
            , "wcag" .= wcagObj (stWcag st)
            ]
        | st <- dgSkinTones dg
        ]
    semanticToks =
        [ A.object
            [ "@type" .= ("SemanticColorToken" :: Text)
            , "@id" .= tokenId "colors" ("semantic-" <> T.replace "." "-" (scJsonPath sc))
            , "name" .= scJsonPath sc
            , "value" .= scHex sc
            , "tailwindClass" .= scTailwindClass sc
            , "cssVariable" .= scCssVariable sc
            , "tokenType" .= ("color" :: Text)
            , "description" .= scDescription sc
            ]
        | sc <- dgSemanticColors dg
        ]
    wcagObj ws =
        A.object
            [ AK.fromText (wcagOn w) .= wcagRatio w
            | w <- ws
            ]

-- ── Typography ────────────────────────────────────────────────────────────────

lsTailwind :: Double -> Text
lsTailwind ls
    | ls <= -0.05 = "tracking-tighter"
    | ls < 0.0 = "tracking-tight"
    | ls == 0.0 = "tracking-normal"
    | ls <= 0.025 = "tracking-wide"
    | ls <= 0.05 = "tracking-wider"
    | otherwise = "tracking-widest"

buildTypographyLd :: DesignGuide -> A.Value
buildTypographyLd dg =
    let tc = dgTypography dg
        fontStack = T.intercalate ", " (tcFontFamily tc)
     in A.object
            [ "@context" .= ctxUrl
            , "@type" .= ("vocab:TypographySection" :: Text)
            , "@id" .= dgUrl "typography.jsonld"
            , "name" .= ("Typografia" :: Text)
            , "description" .= ("Variable font, weight 100\x2013\&900. All type styles are named tokens; never specify raw sizes in components." :: Text)
            , "primaryFont"
                .= A.object
                    [ "family" .= head (tcFontFamily tc)
                    , "axes" .= A.toJSON [A.object ["tag" .= ("wght" :: Text), "min" .= (100 :: Int), "max" .= (900 :: Int)]]
                    , "fontDisplay" .= ("swap" :: Text)
                    , "license" .= tcFontLicense tc
                    , "url" .= assetUrl (tcFontFile tc)
                    ]
            , "tokens"
                .= A.toJSON
                    ( A.object
                        [ "@type" .= ("TypographyStyle" :: Text)
                        , "@id" .= tokenId "typography" "fontFamily.sans"
                        , "name" .= ("fontFamily.sans" :: Text)
                        , "tokenType" .= ("fontFamily" :: Text)
                        , "value" .= fontStack
                        , "cssVariable" .= ("--font-sans" :: Text)
                        , "fontDisplay" .= ("swap" :: Text)
                        , "tailwindTheme" .= ("@theme { --font-sans: \"" <> head (tcFontFamily tc) <> "\", system-ui, sans-serif; }")
                        , "description" .= ("Primary sans-serif font stack. Use in Tailwind v4 @theme as --font-sans." :: Text)
                        ]
                        : [ let base =
                                    [ "@type" .= ("TypographyStyle" :: Text)
                                    , "@id" .= tokenId "typography" (T.toLower (tseName e))
                                    , "name" .= tseName e
                                    , "tokenType" .= ("typography" :: Text)
                                    , "description" .= tseDescription e
                                    , "fontFamily" .= fontStack
                                    , "fontWeight" .= tseWeight e
                                    , "fontSizeRem" .= tseSizeRem e
                                    , "fontSizePx" .= tseSizePx e
                                    , "lineHeight" .= tseLineHeight e
                                    , "cssClass" .= tseCssClass e
                                    ]
                                lsPairs =
                                    [ "letterSpacing"
                                        .= A.object
                                            [ "value" .= tseLetterSpacingEm e
                                            , "unit" .= ("em" :: Text)
                                            , "cssValue" .= (T.pack (show (tseLetterSpacingEm e)) <> "em")
                                            , "tailwindClass" .= lsTailwind (tseLetterSpacingEm e)
                                            ]
                                    | tseLetterSpacingEm e /= 0.0
                                    ]
                             in A.object (base ++ lsPairs)
                          | e <- tcScale tc
                          ]
                    )
            , "usageRules" .= A.toJSON (tcUsageRules tc)
            ]

-- ── Spacing ───────────────────────────────────────────────────────────────────

buildSpacingLd :: DesignGuide -> A.Value
buildSpacingLd dg =
    let sp = dgSpacing dg
     in A.object
            [ "@context" .= ctxUrl
            , "@type" .= ("vocab:SpacingSection" :: Text)
            , "@id" .= dgUrl "spacing.jsonld"
            , "name" .= ("Välistys" :: Text)
            , "description" .= (T.pack (show (spcBaseUnit sp)) <> "px-base spacing scale. Use only named tokens; never arbitrary pixel values.")
            , "baseUnit" .= A.object ["value" .= spcBaseUnit sp, "tokenType" .= ("dimension" :: Text), "unit" .= ("px" :: Text)]
            , "tokens"
                .= A.toJSON
                    [ A.object
                        [ "@type" .= ("SpacingToken" :: Text)
                        , "@id" .= tokenId "spacing" (ssName s)
                        , "name" .= ssName s
                        , "tokenType" .= ("dimension" :: Text)
                        , "multiplier" .= ssMultiplier s
                        , "value" .= A.object ["value" .= ssPx s, "unit" .= ("px" :: Text)]
                        , "rem" .= ssRem s
                        , "tailwindClass" .= ssTailwindClass s
                        , "description" .= ssDescription s
                        ]
                    | s <- spcScale sp
                    ]
            , "layout"
                .= A.object
                    [ "contentWidth"
                        .= A.object
                            [ "value" .= A.object ["value" .= spcContentWidthPx sp, "unit" .= ("px" :: Text)]
                            , "tailwindClass" .= spcContentWidthTailwind sp
                            ]
                    , "pageWrapper" .= A.object ["tailwindClass" .= spcPageWrapperClass sp]
                    , "breakpoints"
                        .= A.object
                            [ AK.fromText (bpName bp)
                                .= A.object
                                    [ "value" .= A.object ["value" .= bpPx bp, "unit" .= ("px" :: Text)]
                                    , "tokenType" .= ("dimension" :: Text)
                                    ]
                            | bp <- spcBreakpoints sp
                            ]
                    , "borderRadius"
                        .= A.object
                            [ AK.fromText (brName br)
                                .= A.object
                                    [ "value" .= A.object ["value" .= brPx br, "unit" .= ("px" :: Text)]
                                    , "tailwindClass" .= brTailwindClass br
                                    ]
                            | br <- spcBorderRadii sp
                            ]
                    ]
            ]

-- ── Motion ────────────────────────────────────────────────────────────────────

buildMotionLd :: DesignGuide -> A.Value
buildMotionLd dg =
    let mc = dgMotion dg
     in A.object
            [ "@context" .= ctxUrl
            , "@type" .= ("vocab:MotionSection" :: Text)
            , "@id" .= dgUrl "motion.jsonld"
            , "name" .= ("Animaatiot" :: Text)
            , "description" .= ("All animations must respect prefers-reduced-motion: reduce." :: Text)
            , "tokens"
                .= A.toJSON
                    ( [ A.object
                        [ "@type" .= ("MotionToken" :: Text)
                        , "@id" .= tokenId "motion" ("duration-" <> mdName d)
                        , "name" .= ("duration." <> mdName d)
                        , "tokenType" .= ("duration" :: Text)
                        , "value" .= mdMs d
                        , "unit" .= ("ms" :: Text)
                        , "cssVariable" .= mdCssVariable d
                        , "description" .= mdDescription d
                        ]
                      | d <- mcDurations mc
                      ]
                        ++ [ A.object
                            [ "@type" .= ("EasingToken" :: Text)
                            , "@id" .= tokenId "motion" ("easing-" <> meName e)
                            , "name" .= ("easing." <> meName e)
                            , "tokenType" .= ("cubicBezier" :: Text)
                            , "value" .= A.toJSON [meP1x e, meP1y e, meP2x e, meP2y e]
                            , "cssValue"
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
                            , "description" .= meDescription e
                            ]
                           | e <- mcEasings mc
                           ]
                    )
            , "usageRules" .= A.toJSON (mcUsageRules mc)
            ]

-- ── Components ────────────────────────────────────────────────────────────────

buildComponentsLd :: DesignGuide -> A.Value
buildComponentsLd dg =
    A.object
        [ "@context" .= ctxUrl
        , "@type" .= ("vocab:ComponentSection" :: Text)
        , "@id" .= dgUrl "components.jsonld"
        , "name" .= ("Komponentit" :: Text)
        , "description" .= ("Elm UI component catalogue. Import by module name; never copy-paste HTML inline." :: Text)
        , "sourceDir" .= ("src/Component/" :: Text)
        , "tokens"
            .= A.toJSON
                [ A.object
                    [ "@type" .= ("ComponentSpec" :: Text)
                    , "@id" .= tokenId "components" (T.toLower (csName c))
                    , "name" .= csName c
                    , "elmModule" .= csModule c
                    , "description" .= csDescription c
                    , "props" .= A.toJSON (csProps c)
                    , "tokenDeps" .= A.toJSON (csTokenDependencies c)
                    ]
                | c <- dgComponents dg
                ]
        ]

-- ── Responsiveness ────────────────────────────────────────────────────────────

buildResponsivenessLd :: DesignGuide -> A.Value
buildResponsivenessLd dg =
    let sp = dgSpacing dg
     in A.object
            [ "@context" .= ctxUrl
            , "@type" .= ("vocab:ResponsivenessSection" :: Text)
            , "@id" .= dgUrl "responsiveness.jsonld"
            , "name" .= ("Responsiivisuus" :: Text)
            , "description" .= ("Breakpoints, grid patterns and mobile-first layout rules. All values follow W3C Design Tokens 2025.10 dimension format." :: Text)
            , "seeAlso" .= (baseUrl <> "/design-guide.tokens.json")
            , "tokens"
                .= A.toJSON
                    ( [ A.object
                        [ "@type" .= ("BreakpointToken" :: Text)
                        , "@id" .= tokenId "responsiveness" ("bp-" <> bpName bp)
                        , "name" .= ("breakpoint." <> bpName bp)
                        , "tokenType" .= ("dimension" :: Text)
                        , "value" .= A.object ["value" .= bpPx bp, "unit" .= ("px" :: Text)]
                        , "description" .= (bpName bp <> " breakpoint \x2014 screens \x2265" <> T.pack (show (bpPx bp)) <> "px")
                        ]
                      | bp <- spcBreakpoints sp
                      ]
                        ++ [ A.object
                            [ "@type" .= ("ResponsiveGridToken" :: Text)
                            , "@id" .= tokenId "responsiveness" ("grid-" <> rgName rg)
                            , "name" .= ("grid." <> rgName rg)
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
                    )
            , "layout"
                .= A.object
                    [ "contentWidth"
                        .= A.object
                            [ "value" .= A.object ["value" .= spcContentWidthPx sp, "unit" .= ("px" :: Text)]
                            , "tailwindClass" .= spcContentWidthTailwind sp
                            , "description" .= ("Maximum content column width." :: Text)
                            ]
                    , "pagePaddingX"
                        .= A.object
                            [ "value" .= A.object ["value" .= spcPagePaddingXPx sp, "unit" .= ("px" :: Text)]
                            , "tailwindClass" .= spcPagePaddingXTailwind sp
                            ]
                    , "pageWrapper"
                        .= A.object
                            [ "tailwindClass" .= spcPageWrapperClass sp
                            , "description" .= ("Compose of contentWidth + pagePaddingX." :: Text)
                            ]
                    ]
            , "rules" .= A.toJSON (spcResponsiveRules sp)
            ]

-- ── All-in-one bundle ─────────────────────────────────────────────────────────

buildAllInOneLd :: DesignGuide -> A.Value
buildAllInOneLd dg =
    let m = dgMeta dg
     in A.object
            [ "@context" .= ctxUrl
            , "@type" .= ("DesignGuide" :: Text)
            , "@id" .= dgUrl "all-in-one.jsonld"
            , "name" .= metaOrganization m
            , "description" .= ("Complete design guide bundle \x2014 all sections in one document. Use this for single-fetch agent priming. Canonical split files are at design-guide/index.jsonld." :: Text)
            , "version" .= metaVersion m
            , "seeAlso" .= dgUrl "index.jsonld"
            , "colors" .= buildColorsLd dg
            , "typography" .= buildTypographyLd dg
            , "spacing" .= buildSpacingLd dg
            , "motion" .= buildMotionLd dg
            , "components" .= buildComponentsLd dg
            , "responsiveness" .= buildResponsivenessLd dg
            ]
