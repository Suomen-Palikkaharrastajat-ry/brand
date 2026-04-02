module Route.Index exposing (ActionData, Data, Model, Msg, route)

{-| The design-guide home page (`/`).

Displays the organisation's logos, brand colours, and logo-usage guidelines in
a single scrollable page. Content is fetched at build time via `BackendTask`
from the generated `Guide.Logos` and `Guide.Colors` modules.

-}

import BackendTask exposing (BackendTask)
import Component.ColorSwatch as ColorSwatch
import Component.LogoCard as LogoCard
import Component.SectionHeader as SectionHeader
import FatalError exposing (FatalError)
import Guide.Colors as Colors
import Guide.Logos as Logos
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC
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
        [ Html.div
            [ classes
                [ TwEx.max_w_5xl
                , Tw.mx_auto
                , Tw.px Th.s4
                , Tw.py Th.s8
                , Bp.sm [ Tw.py Th.s12 ]
                , TwEx.space_y Th.s14
                , Bp.sm [ TwEx.space_y Th.s20 ]
                ]
            ]
            [ viewPageHeader
            , viewLogotSection
            , viewLogoKayttokontekstit
            , viewVaritSection
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ classes [ TwEx.space_y Th.s2 ] ]
        [ Html.h1 [ classes [ Tw.text_2xl, Bp.sm [ Tw.text_3xl ], Tw.font_bold, Tw.text_simple TC.brand ] ]
            [ Html.text "Suomen Palikkaharrastajat ry" ]
        , Html.p [ classes [ Tw.text_sm, Bp.sm [ Tw.text_base ], Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text "Logot ja värit — visuaalinen yleiskatsaus. Katso myös: "
            , Html.a
                [ Attr.href "/typografia"
                , classes [ Tw.underline, Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors ]
                ]
                [ Html.text "Typografia" ]
            , Html.text " · "
            , Html.a
                [ Attr.href "/komponentit"
                , classes [ Tw.underline, Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors ]
                ]
                [ Html.text "Komponentit" ]
            , Html.text "."
            ]
        ]



-- ── Logot ─────────────────────────────────────────────────────────────────────


viewLogotSection : Html msg
viewLogotSection =
    Html.section
        [ Attr.id "logot"
        , classes [ TwEx.scroll_mt Th.s28, TwEx.space_y Th.s8, Bp.sm [ TwEx.space_y Th.s10 ] ]
        ]
        [ Html.h2 [ classes [ Tw.text_xl, Bp.sm [ Tw.text_2xl ], Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Logot" ]
        , viewSquareLogos
        , viewSquareFullLogos
        , viewHorizontalLogos
        ]


viewSquareLogos : Html msg
viewSquareLogos =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Neliö"
            , description = Just "Hymyilevä minihahmon pää rakennuspalikoista koottuna. Sopii someen ja sovelluskuvakkeisiin."
            }
        , Html.div [ classes [ Tw.grid, Tw.grid_cols_2, Bp.md [ Tw.grid_cols_3 ], Bp.lg [ Tw.grid_cols_4 ], Tw.gap Th.s4 ] ]
            (List.map LogoCard.view Logos.squareVariants)
        ]


viewSquareFullLogos : Html msg
viewSquareFullLogos =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Neliö tekstillä"
            , description = Just "Hymyilevä logo kahdella tekstirivillä alla. Käytä kun tarvitset täydellisen tunnuksen pystysuuntaisessa asettelussa."
            }
        , Html.div [ classes [ Tw.grid, Tw.grid_cols_2, Bp.md [ Tw.grid_cols_3 ], Bp.lg [ Tw.grid_cols_4 ], Tw.gap Th.s4 ] ]
            (List.map LogoCard.view Logos.squareFullVariants)
        ]


viewHorizontalLogos : Html msg
viewHorizontalLogos =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Vaakasuuntainen"
            , description = Just "Neljä minihahmon päätä vierekkäin. Vaakaversio tekstillä sopii esitteisiin ja nettisivuille."
            }
        , Html.div [ classes [ Tw.grid, Tw.grid_cols_1, Bp.sm [ Tw.grid_cols_2 ], Tw.gap Th.s4 ] ]
            (List.map LogoCard.view Logos.horizontalVariants)
        ]



-- ── Värit ─────────────────────────────────────────────────────────────────────


viewVaritSection : Html msg
viewVaritSection =
    Html.section
        [ Attr.id "varit"
        , classes [ TwEx.scroll_mt Th.s28, TwEx.space_y Th.s8, Bp.sm [ TwEx.space_y Th.s10 ] ]
        ]
        [ Html.h2 [ classes [ Tw.text_xl, Bp.sm [ Tw.text_2xl ], Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Värit" ]
        , viewBrandColors
        ]


viewBrandColors : Html msg
viewBrandColors =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub { title = "Merkkivärit", description = Just "Yhdistyksen viralliset päävärit." }
        , Html.div [ classes [ Tw.grid, Tw.grid_cols_2, Bp.md [ Tw.grid_cols_3 ], Bp.lg [ Tw.grid_cols_4 ], Tw.gap Th.s4 ] ]
            (List.map
                (\c -> ColorSwatch.view { hex = c.hex, name = c.name, description = c.description, usageTags = c.usage })
                Colors.brandColors
            )
        ]



-- ── Logon käyttökontekstit ────────────────────────────────────────────────────


viewLogoKayttokontekstit : Html msg
viewLogoKayttokontekstit =
    Html.section
        [ Attr.id "logon-kaytto"
        , classes [ TwEx.scroll_mt Th.s28, TwEx.space_y Th.s8, Bp.sm [ TwEx.space_y Th.s10 ] ]
        ]
        [ Html.div [ classes [ Tw.flex, Tw.items_baseline, Tw.justify_between, Tw.flex_wrap, Tw.gap Th.s4 ] ]
            [ Html.h2 [ classes [ Tw.text_xl, Bp.sm [ Tw.text_2xl ], Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Logon käyttö" ]
            , Html.a
                [ Attr.href "/design-guide/logos.jsonld"
                , classes [ Tw.text_xs, Tw.font_mono, Tw.text_color (Th.gray Th.s400), Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors ]
                ]
                [ Html.text "logos.jsonld" ]
            ]
        , viewLogoUsageRules
        , viewLogoContextMapping
        , viewFaviconSnippets
        ]


viewLogoUsageRules : Html msg
viewLogoUsageRules =
    Html.div
        [ classes
            [ Tw.bg_color (Th.amber Th.s50)
            , Tw.border
            , Tw.border_color (Th.amber Th.s200)
            , Tw.rounded_lg
            , Tw.p Th.s4
            , Tw.text_sm
            , Tw.text_color (Th.amber Th.s800)
            , TwEx.space_y Th.s2
            ]
        ]
        [ Html.p [ classes [ Tw.font_semibold ] ] [ Html.text "Käyttöohjeet" ]
        , Html.ul [ classes [ Tw.list_disc, Tw.list_inside, TwEx.space_y Th.s1, Tw.mt Th.s1 ] ]
            [ Html.li [] [ Html.text "Käytä SVG ensin; WebP PNG-varamenetelmällä" ]
            , Html.li [] [ Html.text "Älä venytä, litistä tai värjää logon osia" ]
            , Html.li [] [ Html.text "Älä käytä animoitua logoa tulostettavissa tai sähköpostissa" ]
            ]
        , Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s4, Tw.pt Th.s1, Tw.border_t, Tw.border_color (Th.amber Th.s200), Tw.mt Th.s2 ] ]
            [ Html.span [] [ Html.text "Minimikoko: ", Html.strong [] [ Html.text "80 px" ], Html.text " (neliö) · ", Html.strong [] [ Html.text "200 px" ], Html.text " (vaaka)" ]
            , Html.span [] [ Html.text "Tyhjä tila: vähintään 25 % logon leveydestä joka suuntaan" ]
            ]
        ]


viewLogoContextMapping : Html msg
viewLogoContextMapping =
    Html.div [ classes [ TwEx.space_y Th.s3 ] ]
        [ SectionHeader.viewSub
            { title = "Mikä logo mihinkin?"
            , description = Just "Valitse variantti käyttökontekstin mukaan."
            }
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_sm, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ logoTh "Konteksti", logoTh "Suositeltu variantti", logoTh "Formaatti" ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
                    (List.map viewContextRow logoContextRows)
                ]
            ]
        ]


logoContextRows : List { context : String, variant : String, format : String }
logoContextRows =
    [ { context = "Sivun header / navigaatio", variant = "square-smile-full tai horizontal-full", format = "SVG" }
    , { context = "Tumma header / footer", variant = "square-smile-full-dark tai horizontal-full-dark", format = "SVG" }
    , { context = "Sosiaalinen media / OG-kuva", variant = "horizontal-full", format = "PNG (1200 × 630)" }
    , { context = "Favicon (selain)", variant = "favicon.ico + favicon-32.png", format = "ICO + PNG" }
    , { context = "PWA / kotinäyttö (Android)", variant = "icon-192.png, icon-512.png", format = "PNG" }
    , { context = "iOS kotinäyttö", variant = "apple-touch-icon.png (180 px)", format = "PNG" }
    , { context = "Painotuotteet", variant = "horizontal-full tai square-smile-full", format = "SVG tai 300 dpi+ PNG" }
    , { context = "Animoitu banneri / hero", variant = "square-animated / horizontal-full-animated", format = "WebP/GIF (ei reduced-motion -käyttäjille)" }
    ]


viewContextRow : { context : String, variant : String, format : String } -> Html msg
viewContextRow row =
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ] ]
        [ Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_color (Th.gray Th.s700) ] ] [ Html.text row.context ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_simple TC.brand ] ] [ Html.text row.variant ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.format ]
        ]


viewFaviconSnippets : Html msg
viewFaviconSnippets =
    Html.div [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.viewSub
            { title = "Koodiesimerkit"
            , description = Just "Liitä seuraavat koodipalat suoraan HTML-tiedostoosi."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Favicon — <head>" ]
                , Html.pre [ classes [ Tw.bg_color (Th.gray Th.s900), Tw.text_color (Th.gray Th.s100), Tw.rounded_lg, Tw.p Th.s4, Tw.text_xs, Tw.leading_relaxed, Tw.overflow_x_auto ] ]
                    [ Html.code []
                        [ Html.text """<link rel="icon" href="/favicon/favicon.ico" sizes="any">
<link rel="icon" href="/favicon/favicon-32.png" type="image/png" sizes="32x32">
<link rel="icon" href="/favicon/favicon-48.png" type="image/png" sizes="48x48">
<link rel="apple-touch-icon" href="/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">""" ]
                    ]
                , Html.p [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ]
                    [ Html.text "Lisää ICO ensin — vanhat selaimet eivät tue PNG-faviconeja. Apple touch icon on 180 × 180 px." ]
                ]
            , Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Logo — <picture> WebP + PNG" ]
                , Html.pre [ classes [ Tw.bg_color (Th.gray Th.s900), Tw.text_color (Th.gray Th.s100), Tw.rounded_lg, Tw.p Th.s4, Tw.text_xs, Tw.leading_relaxed, Tw.overflow_x_auto ] ]
                    [ Html.code []
                        [ Html.text """<picture>
  <source
    srcset="/logo/horizontal/png/horizontal-full.webp"
    type="image/webp">
  <img
    src="/logo/horizontal/png/horizontal-full.png"
    alt="Suomen Palikkaharrastajat ry"
    width="400" height="120">
</picture>""" ]
                    ]
                , Html.p [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ]
                    [ Html.text "Käytä aina "
                    , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "<picture>" ]
                    , Html.text " -elementtiä, jotta selain valitsee WebP:n kun se on tuettu, muuten käytetään PNG-varaversiota."
                    ]
                ]
            ]
        ]


logoTh : String -> Html msg
logoTh label =
    Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ]
        [ Html.text label ]
