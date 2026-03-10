module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Brand.Colors as Colors
import Brand.Logos as Logos
import Component.ColorSwatch as ColorSwatch
import Component.LogoCard as LogoCard
import Component.SectionHeader as SectionHeader
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : RouteBuilder.StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = SiteMeta.organizationName
        , image =
            { url = Pages.Url.external "https://logo.palikkaharrastajat.fi/logo/horizontal/png/horizontal-full.png"
            , alt = SiteMeta.organizationName
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = SiteMeta.description
        , locale = Nothing
        , title = SiteMeta.siteTitle
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = SiteMeta.siteTitle
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-8 sm:py-12 space-y-14 sm:space-y-20" ]
            [ viewPageHeader
            , viewLogotSection
            , viewVaritSection
            , viewTypografiaSection
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ Attr.class "space-y-2" ]
        [ Html.h1 [ Attr.class "text-2xl sm:text-3xl font-bold text-brand" ]
            [ Html.text "Suomen Palikkaharrastajat ry" ]
        , Html.p [ Attr.class "text-sm sm:text-base text-gray-500" ]
            [ Html.text "Logot, värit ja typografia. Koneluettava versio: "
            , Html.a
                [ Attr.href "/design-guide/index.jsonld"
                , Attr.class "underline hover:text-brand transition-colors font-mono text-sm"
                ]
                [ Html.text "design-guide/" ]
            , Html.text "."
            ]
        ]



-- ── Anchor navigation ─────────────────────────────────────────────────────────


viewAnchorNav : Html msg
viewAnchorNav =
    Html.nav
        [ Attr.class "sticky top-16 z-40 bg-white/95 backdrop-blur border-b border-gray-100 -mx-4 px-4 py-2"
        , Attr.attribute "aria-label" "Sivu-navigaatio"
        ]
        [ Html.ul [ Attr.class "flex gap-6 text-sm font-medium" ]
            [ anchorItem "#logot" "Logot"
            , anchorItem "#varit" "Värit"
            , anchorItem "#typografia" "Typografia"
            ]
        ]


anchorItem : String -> String -> Html msg
anchorItem href label =
    Html.li []
        [ Html.a
            [ Attr.href href
            , Attr.class "text-gray-500 hover:text-brand transition-colors"
            ]
            [ Html.text label ]
        ]



-- ── Logot ─────────────────────────────────────────────────────────────────────


viewLogotSection : Html msg
viewLogotSection =
    Html.section [ Attr.id "logot", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Logot" ]
            , Html.a
                [ Attr.href "/design-guide/logos.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "logos.jsonld" ]
            ]
        , viewLogoUsageRules
        , viewSquareLogos
        , viewHorizontalLogos
        ]


viewLogoUsageRules : Html msg
viewLogoUsageRules =
    Html.div [ Attr.class "bg-amber-50 border border-amber-200 rounded-lg p-4 text-sm text-amber-800 space-y-1" ]
        [ Html.p [ Attr.class "font-semibold" ] [ Html.text "Käyttöohjeet" ]
        , Html.ul [ Attr.class "list-disc list-inside space-y-1 mt-1" ]
            [ Html.li [] [ Html.text "Käytä SVG ensin; WebP PNG-varamenetelmällä" ]
            , Html.li [] [ Html.text "Älä venytä, litistä tai värjää logon osia" ]
            , Html.li [] [ Html.text "Älä käytä animoitua logoa tulostettavissa tai sähköpostissa" ]
            ]
        ]


viewSquareLogos : Html msg
viewSquareLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Neliö (square)"
            , description = Just "LEGO-minihahmon pää rakennuspalikoista koottuna. Sopii someen ja sovelluskuvakkeisiin."
            }
        , Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4" ]
            (List.map LogoCard.view Logos.squareVariants)
        ]


viewHorizontalLogos : Html msg
viewHorizontalLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Vaakasuuntainen (horizontal)"
            , description = Just "Neljä minihahmon päätä vierekkäin. Vaakaversio tekstillä sopii esitteisiin ja nettisivuille."
            }
        , Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-4" ]
            (List.map LogoCard.view Logos.horizontalVariants)
        ]



-- ── Värit ─────────────────────────────────────────────────────────────────────


viewVaritSection : Html msg
viewVaritSection =
    Html.section [ Attr.id "varit", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Värit" ]
            , Html.a
                [ Attr.href "/design-guide/colors.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "colors.jsonld" ]
            ]
        , viewBrandColors
        , viewSkinTones
        , viewRainbowColors
        , viewSemanticColors
        ]


viewBrandColors : Html msg
viewBrandColors =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view { title = "Merkkivärit", description = Just "Yhdistyksen viralliset päävärit." }
        , Html.div [ Attr.class "flex flex-wrap gap-6" ]
            (List.map
                (\c -> ColorSwatch.view { hex = c.hex, name = c.name, description = "", usageTags = c.usage })
                Colors.brandColors
            )
        ]


viewSkinTones : Html msg
viewSkinTones =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Ihoteemat"
            , description = Just "Neljä virallista LEGO®-ihonsävyä. Keltainen on yhdistyksen pääaksenttiväri."
            }
        , Html.div [ Attr.class "flex flex-wrap gap-6" ]
            (List.map
                (\c -> ColorSwatch.view { hex = c.hex, name = c.name, description = c.description, usageTags = [] })
                Colors.skinTones
            )
        ]


viewRainbowColors : Html msg
viewRainbowColors =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Sateenkaari"
            , description = Just "Sateenkaarilogoissa käytetyt seitsemän väriä. Käytä vain koristeellisesti."
            }
        , Html.div [ Attr.class "flex flex-wrap gap-6" ]
            (List.map
                (\c -> ColorSwatch.view { hex = c.hex, name = c.name, description = c.description, usageTags = [] })
                Colors.rainbowColors
            )
        ]


viewSemanticColors : Html msg
viewSemanticColors =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Semanttiset värit"
            , description = Just "Käytä aina semanttisia nimiä — älä koodaa heksadesimaaliarvoja suoraan komponentteihin."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "border-b border-gray-200" ]
                        [ th "Nimi", th "Arvo", th "Tailwind", th "Käyttö" ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                    (List.map viewSemanticRow semanticRows)
                ]
            ]
        ]


semanticRows : List { name : String, hex : String, tw : String, desc : String }
semanticRows =
    [ { name = "text.primary", hex = "#05131D", tw = "text-brand", desc = "Pääotsikot ja tärkeä teksti" }
    , { name = "text.onDark", hex = "#FFFFFF", tw = "text-white", desc = "Teksti tummalla taustalla" }
    , { name = "text.muted", hex = "#6B7280", tw = "text-gray-500", desc = "Sekundääri teksti" }
    , { name = "text.subtle", hex = "#9CA3AF", tw = "text-gray-400", desc = "Placeholder, disabled" }
    , { name = "background.page", hex = "#FFFFFF", tw = "bg-white", desc = "Sivun pääväri" }
    , { name = "background.dark", hex = "#05131D", tw = "bg-brand", desc = "Tumma teema, navbar" }
    , { name = "background.subtle", hex = "#F9FAFB", tw = "bg-gray-50", desc = "Korostusalue, kortit" }
    , { name = "background.accent", hex = "#F2CD37", tw = "bg-brand-yellow", desc = "Keltainen aksentti" }
    , { name = "border.default", hex = "#E5E7EB", tw = "border-gray-200", desc = "Kortit, taulukot" }
    , { name = "border.brand", hex = "#05131D", tw = "border-brand", desc = "Aktiiviset elementit" }
    ]


viewSemanticRow : { name : String, hex : String, tw : String, desc : String } -> Html msg
viewSemanticRow row =
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-700" ] [ Html.text row.name ]
        , Html.td [ Attr.class "py-2 px-3" ]
            [ Html.div [ Attr.class "flex items-center gap-2" ]
                [ Html.span
                    [ Attr.class "w-5 h-5 rounded border border-gray-200 flex-shrink-0"
                    , Attr.style "background-color" row.hex
                    ]
                    []
                , Html.span [ Attr.class "font-mono text-xs text-gray-500" ] [ Html.text row.hex ]
                ]
            ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand" ] [ Html.text row.tw ]
        , Html.td [ Attr.class "py-2 px-3 text-gray-500 text-xs" ] [ Html.text row.desc ]
        ]


th : String -> Html msg
th label =
    Html.th [ Attr.class "py-2 px-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider" ]
        [ Html.text label ]



-- ── Typografia ────────────────────────────────────────────────────────────────


viewTypografiaSection : Html msg
viewTypografiaSection =
    Html.section [ Attr.id "typografia", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Typografia" ]
            , Html.a
                [ Attr.href "/design-guide/typography.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "typography.jsonld" ]
            ]
        , viewFontCard
        , viewTypeScale
        , viewWeightSpecimens
        ]


viewFontCard : Html msg
viewFontCard =
    Html.div [ Attr.class "bg-white border border-gray-200 rounded-xl p-4 sm:p-6 space-y-3" ]
        [ Html.div [ Attr.class "flex items-start justify-between flex-wrap gap-4" ]
            [ Html.div []
                [ Html.p [ Attr.class "text-2xl font-bold text-brand" ] [ Html.text "Outfit" ]
                , Html.p [ Attr.class "text-gray-500 mt-0.5" ]
                    [ Html.text "Variable font · paino 100–900 · SIL Open Font License 1.1" ]
                ]
            , Html.a
                [ Attr.href "/fonts/Outfit-VariableFont_wght.ttf"
                , Attr.download ""
                , Attr.class "inline-flex items-center gap-2 bg-brand-yellow text-brand px-4 py-2 rounded font-semibold hover:opacity-90 transition-opacity text-sm"
                ]
                [ Html.text "Lataa TTF" ]
            ]
        , Html.p [ Attr.class "text-gray-600 text-sm" ]
            [ Html.text "Outfit on moderni geometrinen groteski, joka toimii hyvin sekä otsikoissa että leipätekstissä. Google Fonts / SIL OFL." ]
        ]


viewTypeScale : Html msg
viewTypeScale =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Tyyliaste"
            , description = Just "Käytä aina nimettyjä tyylejä — älä määritä fonttikokoja suoraan komponenteissa."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "border-b border-gray-200" ]
                        [ th "Nimi", th "Paino", th "Koko (rem)", th "Rivinorkeus", th "Esimerkki" ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                    (List.map viewTypeRow typeScaleRows)
                ]
            ]
        ]


typeScaleRows : List { name : String, weight : String, size : String, lineHeight : String }
typeScaleRows =
    [ { name = "Display", weight = "800", size = "3.5rem", lineHeight = "1.1" }
    , { name = "H1", weight = "700", size = "2.25rem", lineHeight = "1.2" }
    , { name = "H2", weight = "700", size = "1.875rem", lineHeight = "1.25" }
    , { name = "H3", weight = "600", size = "1.5rem", lineHeight = "1.3" }
    , { name = "H4", weight = "600", size = "1.25rem", lineHeight = "1.4" }
    , { name = "Body", weight = "400", size = "1rem", lineHeight = "1.6" }
    , { name = "BodySmall", weight = "400", size = "0.875rem", lineHeight = "1.6" }
    , { name = "Caption", weight = "400", size = "0.75rem", lineHeight = "1.5" }
    , { name = "Overline", weight = "600", size = "0.75rem", lineHeight = "1.5" }
    ]


viewTypeRow : { name : String, weight : String, size : String, lineHeight : String } -> Html msg
viewTypeRow row =
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand font-medium" ] [ Html.text row.name ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.weight ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.size ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.lineHeight ]
        , Html.td [ Attr.class "py-2 px-3 text-brand overflow-hidden max-w-xs" ]
            [ Html.span
                [ Attr.style "font-weight" row.weight
                , Attr.style "font-size" row.size
                , Attr.style "line-height" row.lineHeight
                , Attr.class "whitespace-nowrap"
                ]
                [ Html.text "Nopea ruskea kettu hyppää laiskan koiran yli" ]
            ]
        ]


viewWeightSpecimens : Html msg
viewWeightSpecimens =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.view { title = "Painovariannit", description = Nothing }
        , Html.div [ Attr.class "space-y-2" ]
            (List.map
                (\( weight, label ) ->
                    Html.div
                        [ Attr.class "flex items-baseline gap-4 border-l-4 border-brand-yellow pl-4 py-2 bg-white rounded-r" ]
                        [ Html.span
                            [ Attr.class "text-xs text-gray-400 w-20 sm:w-28 flex-shrink-0 font-mono" ]
                            [ Html.text (String.fromInt weight ++ " · " ++ label) ]
                        , Html.span
                            [ Attr.style "font-weight" (String.fromInt weight)
                            , Attr.class "text-lg text-brand"
                            ]
                            [ Html.text "Nopea ruskea kettu hyppää laiskan koiran yli" ]
                        ]
                )
                [ ( 100, "Thin" )
                , ( 200, "ExtraLight" )
                , ( 300, "Light" )
                , ( 400, "Regular" )
                , ( 500, "Medium" )
                , ( 600, "SemiBold" )
                , ( 700, "Bold" )
                , ( 800, "ExtraBold" )
                , ( 900, "Black" )
                ]
            )
        ]
