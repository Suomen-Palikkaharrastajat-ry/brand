module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Guide.Colors as Colors
import Guide.Logos as Logos
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
            , viewLogoKayttokontekstit
            , viewVaritSection
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
            [ Html.text "Logot ja värit — visuaalinen yleiskatsaus. Katso myös: "
            , Html.a
                [ Attr.href "/typografia"
                , Attr.class "underline hover:text-brand transition-colors"
                ]
                [ Html.text "Typografia" ]
            , Html.text " · "
            , Html.a
                [ Attr.href "/komponentit"
                , Attr.class "underline hover:text-brand transition-colors"
                ]
                [ Html.text "Komponentit" ]
            , Html.text "."
            ]
        ]



-- ── Logot ─────────────────────────────────────────────────────────────────────


viewLogotSection : Html msg
viewLogotSection =
    Html.section [ Attr.id "logot", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Logot" ]
        , viewSquareLogos
        , viewSquareFullLogos
        , viewHorizontalLogos
        ]


viewSquareLogos : Html msg
viewSquareLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Neliö"
            , description = Just "Hymyilevä minihahmon pää rakennuspalikoista koottuna. Sopii someen ja sovelluskuvakkeisiin."
            }
        , Html.div [ Attr.class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map LogoCard.view Logos.squareVariants)
        ]


viewSquareFullLogos : Html msg
viewSquareFullLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Neliö tekstillä"
            , description = Just "Hymyilevä logo kahdella tekstirivillä alla. Käytä kun tarvitset täydellisen tunnuksen pystysuuntaisessa asettelussa."
            }
        , Html.div [ Attr.class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map LogoCard.view Logos.squareFullVariants)
        ]


viewHorizontalLogos : Html msg
viewHorizontalLogos =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub
            { title = "Vaakasuuntainen"
            , description = Just "Neljä minihahmon päätä vierekkäin. Vaakaversio tekstillä sopii esitteisiin ja nettisivuille."
            }
        , Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-4" ]
            (List.map LogoCard.view Logos.horizontalVariants)
        ]



-- ── Värit ─────────────────────────────────────────────────────────────────────


viewVaritSection : Html msg
viewVaritSection =
    Html.section [ Attr.id "varit", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Värit" ]
        , viewBrandColors
        ]


viewBrandColors : Html msg
viewBrandColors =
    Html.div [ Attr.class "space-y-4" ]
        [ SectionHeader.viewSub { title = "Merkkivärit", description = Just "Yhdistyksen viralliset päävärit." }
        , Html.div [ Attr.class "grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4" ]
            (List.map
                (\c -> ColorSwatch.view { hex = c.hex, name = c.name, description = c.description, usageTags = c.usage })
                Colors.brandColors
            )
        ]



-- ── Logon käyttökontekstit ────────────────────────────────────────────────────


viewLogoKayttokontekstit : Html msg
viewLogoKayttokontekstit =
    Html.section [ Attr.id "logon-kaytto", Attr.class "scroll-mt-28 space-y-8 sm:space-y-10" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Logon käyttö" ]
            , Html.a
                [ Attr.href "/design-guide/logos.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "logos.jsonld" ]
            ]
        , viewLogoUsageRules
        , viewLogoContextMapping
        , viewFaviconSnippets
        ]


viewLogoUsageRules : Html msg
viewLogoUsageRules =
    Html.div [ Attr.class "bg-amber-50 border border-amber-200 rounded-lg p-4 text-sm text-amber-800 space-y-2" ]
        [ Html.p [ Attr.class "font-semibold" ] [ Html.text "Käyttöohjeet" ]
        , Html.ul [ Attr.class "list-disc list-inside space-y-1 mt-1" ]
            [ Html.li [] [ Html.text "Käytä SVG ensin; WebP PNG-varamenetelmällä" ]
            , Html.li [] [ Html.text "Älä venytä, litistä tai värjää logon osia" ]
            , Html.li [] [ Html.text "Älä käytä animoitua logoa tulostettavissa tai sähköpostissa" ]
            ]
        , Html.div [ Attr.class "flex flex-wrap gap-4 pt-1 border-t border-amber-200 mt-2" ]
            [ Html.span [] [ Html.text "Minimikoko: ", Html.strong [] [ Html.text "80 px" ], Html.text " (neliö) · ", Html.strong [] [ Html.text "200 px" ], Html.text " (vaaka)" ]
            , Html.span [] [ Html.text "Tyhjä tila: vähintään 25 % logon leveydestä joka suuntaan" ]
            ]
        ]


viewLogoContextMapping : Html msg
viewLogoContextMapping =
    Html.div [ Attr.class "space-y-3" ]
        [ SectionHeader.viewSub
            { title = "Mikä logo mihinkin?"
            , description = Just "Valitse variantti käyttökontekstin mukaan."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "border-b border-gray-200" ]
                        [ logoTh "Konteksti", logoTh "Suositeltu variantti", logoTh "Formaatti" ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
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
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 text-gray-700" ] [ Html.text row.context ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-brand" ] [ Html.text row.variant ]
        , Html.td [ Attr.class "py-2 px-3 text-xs text-gray-500" ] [ Html.text row.format ]
        ]


viewFaviconSnippets : Html msg
viewFaviconSnippets =
    Html.div [ Attr.class "space-y-6" ]
        [ SectionHeader.viewSub
            { title = "Koodiesimerkit"
            , description = Just "Liitä seuraavat koodipalat suoraan HTML-tiedostoosi."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Favicon — <head>" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
                    [ Html.code []
                        [ Html.text """<link rel="icon" href="/favicon/favicon.ico" sizes="any">
<link rel="icon" href="/favicon/favicon-32.png" type="image/png" sizes="32x32">
<link rel="icon" href="/favicon/favicon-48.png" type="image/png" sizes="48x48">
<link rel="apple-touch-icon" href="/favicon/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">""" ]
                        ]
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Lisää ICO ensin — vanhat selaimet eivät tue PNG-faviconeja. Apple touch icon on 180 × 180 px." ]
                ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Logo — <picture> WebP + PNG" ]
                , Html.pre [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
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
                , Html.p [ Attr.class "text-xs text-gray-500" ]
                    [ Html.text "Käytä aina "
                    , Html.code [ Attr.class "font-mono bg-gray-100 px-1 rounded" ] [ Html.text "<picture>" ]
                    , Html.text " -elementtiä, jotta selain valitsee WebP:n kun se on tuettu, muuten käytetään PNG-varaversiota."
                    ]
                ]
            ]
        ]


logoTh : String -> Html msg
logoTh label =
    Html.th [ Attr.class "py-2 px-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider" ]
        [ Html.text label ]



