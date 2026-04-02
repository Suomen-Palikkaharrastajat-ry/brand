module Route.Typografia exposing (ActionData, Data, Model, Msg, route)

{-| Typography guide page.

Documents the type scale, font families, line-height, and usage
rules for headings, body text, and brand-specific type styles.

-}

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import FeatherIcons
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
        , description = "Typografiaskaala ja ikonit: type-* apuohjelmat, esimerkit, spec-arvot ja feathericons/elm-feather-kirjasto."
        , locale = Nothing
        , title = "Typografia · " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Typografia · " ++ SiteMeta.organizationName
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
            , viewTypeScaleSection
            , viewDosDontsSection
            , viewUsageSection
            , viewIconsSection
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ classes [ TwEx.space_y Th.s2 ] ]
        [ Html.h1 [ classes [ Tw.text_2xl, Bp.sm [ Tw.text_3xl ], Tw.font_bold, Tw.text_simple TC.brand ] ]
            [ Html.text "Typografia" ]
        , Html.p [ classes [ Tw.text_sm, Bp.sm [ Tw.text_base ], Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text "Outfit-fonttiperhe, typografiaskaala ja "
            , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "type-*" ]
            , Html.text " CSS-apuohjelmat. Nämä apuohjelmat on määritelty "
            , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "brand.css" ]
            , Html.text ":ssä ja "
            , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "style.css" ]
            , Html.text ":ssä."
            ]
        ]



-- ── Type scale section ────────────────────────────────────────────────────────


viewTypeScaleSection : Html msg
viewTypeScaleSection =
    Html.section [ Attr.id "skaala" ]
        [ Html.h2
            [ classes
                [ Tw.text_xl
                , Tw.font_bold
                , Tw.text_simple TC.brand
                , Tw.mb Th.s6
                , Tw.pb Th.s2
                , Tw.border_b
                , Tw.border_color (Th.gray Th.s200)
                ]
            ]
            [ Html.text "Typografiaskaala" ]
        , Html.div [ classes [ TwEx.space_y Th.s10 ] ]
            (List.map viewTypeRow typeScaleRows)
        ]


type alias TypeRow =
    { cls : Tw.Tailwind
    , label : String
    , size : String
    , weight : String
    , lineHeight : String
    , letterSpacing : String
    , usage : String
    , example : String
    }


typeScaleRows : List TypeRow
typeScaleRows =
    [ { cls = TwEx.type_display
      , label = "type-display"
      , size = "3rem (48px)"
      , weight = "700"
      , lineHeight = "1.1"
      , letterSpacing = "-0.02em"
      , usage = "Hero-otsikot ja laskeutumissivujen pääotsikot. Käytä vain suurilla näytöillä (≥ md)."
      , example = "Suomen Palikkaharrastajat"
      }
    , { cls = TwEx.type_h1
      , label = "type-h1"
      , size = "1.875rem (30px)"
      , weight = "700"
      , lineHeight = "1.2"
      , letterSpacing = "-0.01em"
      , usage = "Sivutason pääotsikko (yksi per sivu). Käytä type-display sijaan pienillä näytöillä."
      , example = "Tapahtumakalenteri"
      }
    , { cls = TwEx.type_h2
      , label = "type-h2"
      , size = "1.5rem (24px)"
      , weight = "700"
      , lineHeight = "1.3"
      , letterSpacing = "—"
      , usage = "Osion pääotsikko. Hierarkia: Display > H1 > H2 > H3 > H4."
      , example = "Tulevat tapahtumat"
      }
    , { cls = TwEx.type_h3
      , label = "type-h3"
      , size = "1.25rem (20px)"
      , weight = "600"
      , lineHeight = "1.35"
      , letterSpacing = "—"
      , usage = "Aliosion otsikko tai korttiotsikko."
      , example = "Kevät 2026"
      }
    , { cls = TwEx.type_h4
      , label = "type-h4"
      , size = "1.125rem (18px)"
      , weight = "600"
      , lineHeight = "1.4"
      , letterSpacing = "—"
      , usage = "Kortti- ja widgetotsikot. Käytä H3:n alapuolella."
      , example = "Ilmoittautuminen"
      }
    , { cls = TwEx.type_body
      , label = "type-body"
      , size = "1rem (16px)"
      , weight = "400"
      , lineHeight = "1.6"
      , letterSpacing = "—"
      , usage = "Oletusteksti. Pienin sallittu koko saavutettavalle luettavuudelle."
      , example = "Suomen Palikkaharrastajat ry on LEGO®-rakentajien harrasteyhdistys. Järjestämme näyttelyjä ja tapahtumia ympäri vuoden."
      }
    , { cls = TwEx.type_body_small
      , label = "type-body-small"
      , size = "0.875rem (14px)"
      , weight = "500"
      , lineHeight = "1.5"
      , letterSpacing = "—"
      , usage = "Toissijaiset labelit, käyttöliittymäkontrollit ja lomakevihjeet."
      , example = "Tapahtuma julkaistu · Muokkaa tietoja"
      }
    , { cls = TwEx.type_caption
      , label = "type-caption"
      , size = "0.875rem (14px)"
      , weight = "400"
      , lineHeight = "1.4"
      , letterSpacing = "0.02em"
      , usage = "Kuvatekstit, alaviitteet ja metatiedot."
      , example = "Kuva: LEGO-mallinnos Helsingistä, 2025"
      }
    , { cls = TwEx.type_mono
      , label = "type-mono"
      , size = "0.875rem (14px)"
      , weight = "400"
      , lineHeight = "1.6"
      , letterSpacing = "—"
      , usage = "Hex-arvot, tunnisteet ja koodinpätkät."
      , example = "#05131D · --color-brand · type-h2"
      }
    , { cls = TwEx.type_overline
      , label = "type-overline"
      , size = "0.75rem (12px)"
      , weight = "600"
      , lineHeight = "1.4"
      , letterSpacing = "0.08em"
      , usage = "Osiokategorian labelit. Aina versaalein."
      , example = "TAPAHTUMAT · KILPAILUT"
      }
    ]


viewTypeRow : TypeRow -> Html msg
viewTypeRow row =
    Html.div
        [ classes
            [ Tw.grid
            , Tw.grid_cols_1
            , Bp.md [ Tw.grid_cols_2 ]
            , Tw.gap Th.s4
            , Tw.py Th.s6
            , Tw.border_b
            , Tw.border_color (Th.gray Th.s100)
            , Bp.last [ Tw.border_b_0 ]
            ]
        ]
        [ -- Live example
          Html.div [ classes [ Tw.flex, Tw.flex_col, Tw.justify_center, Tw.min_h Th.s16 ] ]
            [ Html.p [ classes [ row.cls ] ]
                [ Html.text row.example ]
            ]
        , -- Spec and usage
          Html.div [ classes [ TwEx.space_y Th.s2 ] ]
            [ Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
                [ Html.code
                    [ classes
                        [ Tw.font_mono
                        , Tw.text_sm
                        , TwEx.bg_brand_10
                        , Tw.text_simple TC.brand
                        , Tw.px Th.s2
                        , Tw.py Th.s0_dot_5
                        , Tw.rounded
                        , Tw.font_semibold
                        ]
                    ]
                    [ Html.text row.label ]
                ]
            , Html.table [ classes [ Tw.w_full, Tw.text_xs, Tw.text_color (Th.gray Th.s600), Tw.border_collapse ] ]
                [ Html.tbody []
                    [ specRow "Koko" row.size
                    , specRow "Paino" row.weight
                    , specRow "Rivinväli" row.lineHeight
                    , specRow "Kirjainväli" row.letterSpacing
                    ]
                ]
            , Html.p [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500), Tw.italic ] ]
                [ Html.text row.usage ]
            ]
        ]


specRow : String -> String -> Html msg
specRow label value =
    Html.tr []
        [ Html.td [ classes [ Tw.pr Th.s3, Tw.py Th.s0_dot_5, Tw.text_color (Th.gray Th.s400), Tw.font_medium, Tw.w Th.s24 ] ] [ Html.text label ]
        , Html.td [ classes [ Tw.py Th.s0_dot_5, Tw.font_mono ] ] [ Html.text value ]
        ]



-- ── Do / Don't section ────────────────────────────────────────────────────────


viewDosDontsSection : Html msg
viewDosDontsSection =
    Html.section [ Attr.id "ohjeet" ]
        [ Html.h2
            [ classes
                [ Tw.text_xl
                , Tw.font_bold
                , Tw.text_simple TC.brand
                , Tw.mb Th.s6
                , Tw.pb Th.s2
                , Tw.border_b
                , Tw.border_color (Th.gray Th.s200)
                ]
            ]
            [ Html.text "Käyttöohjeet" ]
        , Html.div [ classes [ Tw.grid, Tw.grid_cols_1, Bp.sm [ Tw.grid_cols_2 ], Tw.gap Th.s6 ] ]
            [ viewDoCard
            , viewDontCard
            ]
        ]


viewDoCard : Html msg
viewDoCard =
    Html.div [ classes [ Tw.rounded_xl, Tw.border, Tw.border_color (Th.green Th.s200), Tw.bg_color (Th.green Th.s50), Tw.p Th.s6, TwEx.space_y Th.s4 ] ]
        [ Html.h3 [ classes [ Tw.type_h4, Tw.text_color (Th.green Th.s800), Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
            [ FeatherIcons.check
                |> FeatherIcons.withSize 18
                |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
            , Html.text "Tee näin"
            ]
        , Html.ul [ classes [ TwEx.space_y Th.s2, Tw.text_sm, Tw.text_color (Th.green Th.s900), Tw.list_disc, Tw.list_inside ] ]
            [ Html.li [] [ Html.text "Käytä ", codeInline "type-h2", Html.text " osion otsikoihin" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-body", Html.text " oletustekstiin" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-overline", Html.text " kategorialabeleissa — aina versaalein" ]
            , Html.li [] [ Html.text "Noudata hierarkiaa: Display > H1 > H2 > H3 > H4" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-display", Html.text " vain md-näytöillä tai suuremmilla" ]
            , Html.li [] [ Html.text "Käytä ", codeInline "type-mono", Html.text " hex-arvoihin, CSS-muuttujiin ja koodiin" ]
            ]
        ]


viewDontCard : Html msg
viewDontCard =
    Html.div [ classes [ Tw.rounded_xl, Tw.border, Tw.border_color (Th.red Th.s200), Tw.bg_color (Th.red Th.s50), Tw.p Th.s6, TwEx.space_y Th.s4 ] ]
        [ Html.h3 [ classes [ Tw.type_h4, Tw.text_color (Th.red Th.s800), Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
            [ FeatherIcons.x
                |> FeatherIcons.withSize 18
                |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
            , Html.text "Älä tee näin"
            ]
        , Html.ul [ classes [ TwEx.space_y Th.s2, Tw.text_sm, Tw.text_color (Th.red Th.s900), Tw.list_disc, Tw.list_inside ] ]
            [ Html.li [] [ Html.text "Älä käytä raa'oitaTailwind-luokkia kuten ", codeInlineDont "text-2xl font-bold" ]
            , Html.li [] [ Html.text "Älä ohita hierarkiatasoja (esim. H1 → H3)" ]
            , Html.li [] [ Html.text "Älä aseta ", codeInlineDont "html { font-size: ... }", Html.text " — rikkoo rem-skaalan" ]
            , Html.li [] [ Html.text "Älä korvaa Outfitia järjestelmäfontilla suunnitellussa tulosteessa" ]
            , Html.li [] [ Html.text "Älä käytä ", codeInlineDont "type-caption", Html.text " alle 14 px sisällössä" ]
            ]
        ]


codeInline : String -> Html msg
codeInline s =
    Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.green Th.s100), Tw.text_color (Th.green Th.s800), Tw.px Th.s1, Tw.rounded ] ] [ Html.text s ]


codeInlineDont : String -> Html msg
codeInlineDont s =
    Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.red Th.s100), Tw.text_color (Th.red Th.s800), Tw.px Th.s1, Tw.rounded ] ] [ Html.text s ]



-- ── Usage section ─────────────────────────────────────────────────────────────


viewUsageSection : Html msg
viewUsageSection =
    Html.section [ Attr.id "kaytto" ]
        [ Html.h2
            [ classes
                [ Tw.text_xl
                , Tw.font_bold
                , Tw.text_simple TC.brand
                , Tw.mb Th.s6
                , Tw.pb Th.s2
                , Tw.border_b
                , Tw.border_color (Th.gray Th.s200)
                ]
            ]
            [ Html.text "CSS-esimerkki" ]
        , Html.div [ classes [ TwEx.space_y Th.s6 ] ]
            [ Html.p [ classes [ Tw.type_body, Tw.text_color (Th.gray Th.s600) ] ]
                [ Html.text "Apuohjelmat on määritelty "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_sm ] ] [ Html.text "@utility" ]
                , Html.text "-lohkoilla Tailwind v4:ssä. Käytä luokkanimeä suoraan HTML:ssä:"
                ]
            , Html.pre
                [ classes [ Tw.bg_color (Th.gray Th.s900), Tw.text_color (Th.green Th.s300), Tw.rounded_xl, Tw.p Th.s4, Tw.overflow_x_auto, Tw.text_sm, Tw.font_mono, Tw.leading_relaxed ] ]
                [ Html.text """<!-- Otsikko -->
<h1 class="type-h1 text-brand">Tapahtumakalenteri</h1>

<!-- Osion otsikko -->
<h2 class="type-h2">Tulevat tapahtumat</h2>

<!-- Leipäteksti -->
<p class="type-body">Tapahtuman kuvaus tähän.</p>

<!-- Kategorialabel (overline) -->
<span class="type-overline text-text-muted">Kilpailut</span>

<!-- Kuvateksti -->
<figcaption class="type-caption text-text-muted">Kuva: SPH 2025</figcaption>""" ]
            , Html.p [ classes [ Tw.type_body_small, Tw.text_color (Th.gray Th.s500) ] ]
                [ Html.text "Huom: Tailwind v4 generoi automaattisesti "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "text-*" ]
                , Html.text "-, "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "bg-*" ]
                , Html.text "- ja "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "border-*" ]
                , Html.text "-apuohjelmat "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "@theme" ]
                , Html.text ":n "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "--color-*" ]
                , Html.text "-muuttujista. Esim. "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "--color-text-muted" ]
                , Html.text " → "
                , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded, Tw.text_xs ] ] [ Html.text "text-text-muted" ]
                , Html.text "."
                ]
            ]
        ]



-- ── Ikonit ────────────────────────────────────────────────────────────────────


viewIconsSection : Html msg
viewIconsSection =
    Html.section
        [ Attr.id "ikonit"
        , classes [ TwEx.scroll_mt Th.s28, TwEx.space_y Th.s6 ]
        ]
        [ Html.h2
            [ classes
                [ Tw.text_xl
                , Tw.font_bold
                , Tw.text_simple TC.brand
                , Tw.mb Th.s6
                , Tw.pb Th.s2
                , Tw.border_b
                , Tw.border_color (Th.gray Th.s200)
                ]
            ]
            [ Html.text "Ikonit" ]
        , Html.p [ classes [ Tw.text_sm, Bp.sm [ Tw.text_base ], Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text "Käytämme "
            , Html.a
                [ Attr.href "https://package.elm-lang.org/packages/feathericons/elm-feather/latest/"
                , classes [ Tw.underline, Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors ]
                , Attr.target "_blank"
                , Attr.rel "noopener noreferrer"
                ]
                [ Html.text "feathericons/elm-feather" ]
            , Html.text " (v1.5.0) -kirjastoa. Se tarjoaa yli 280 SVG-ikonia Elm-tyyppiturvallisesti."
            ]
        , viewIconUsage
        , viewIconGrid "Navigaatio" navigationIcons
        , viewIconGrid "Tila ja hälytykset" statusIcons
        , viewIconGrid "Sisältö" contentIcons
        , viewIconGrid "Media" mediaIcons
        , viewIconGrid "Toiminnot" actionIcons
        ]


viewIconUsage : Html msg
viewIconUsage =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
            [ Html.text "Tuo kirjasto Elm-moduuliisi ja käytä ikonia putkioperaattorilla:" ]
        , Html.pre [ classes [ Tw.bg_color (Th.gray Th.s900), Tw.text_color (Th.gray Th.s100), Tw.rounded_lg, Tw.p Th.s4, Tw.text_xs, Tw.leading_relaxed, Tw.overflow_x_auto ] ]
            [ Html.code []
                [ Html.text """import FeatherIcons

-- Perusikoni (oletuskoko 24 px)
FeatherIcons.info |> FeatherIcons.toHtml []

-- Mukautettu koko
FeatherIcons.alertTriangle |> FeatherIcons.withSize 18 |> FeatherIcons.toHtml []

-- Lisäattribuutit SVG-elementille
FeatherIcons.check |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [ Attr.class "text-green-500" ]""" ]
            ]
        , Html.p [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text "Ikonit perivät nykyisen tekstivärin ("
            , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "currentColor" ]
            , Html.text "), joten voit värittää ne Tailwind-väriluokilla kuten "
            , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "text-brand" ]
            , Html.text " tai "
            , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "text-red-500" ]
            , Html.text "."
            ]
        ]


type alias IconEntry =
    { name : String
    , icon : FeatherIcons.Icon
    }


navigationIcons : List IconEntry
navigationIcons =
    [ { name = "menu", icon = FeatherIcons.menu }
    , { name = "x", icon = FeatherIcons.x }
    , { name = "arrowUp", icon = FeatherIcons.arrowUp }
    , { name = "arrowDown", icon = FeatherIcons.arrowDown }
    , { name = "arrowLeft", icon = FeatherIcons.arrowLeft }
    , { name = "arrowRight", icon = FeatherIcons.arrowRight }
    , { name = "home", icon = FeatherIcons.home }
    , { name = "search", icon = FeatherIcons.search }
    , { name = "externalLink", icon = FeatherIcons.externalLink }
    , { name = "chevronUp", icon = FeatherIcons.chevronUp }
    , { name = "chevronDown", icon = FeatherIcons.chevronDown }
    , { name = "chevronLeft", icon = FeatherIcons.chevronLeft }
    , { name = "chevronRight", icon = FeatherIcons.chevronRight }
    ]


statusIcons : List IconEntry
statusIcons =
    [ { name = "info", icon = FeatherIcons.info }
    , { name = "alertTriangle", icon = FeatherIcons.alertTriangle }
    , { name = "alertCircle", icon = FeatherIcons.alertCircle }
    , { name = "checkCircle", icon = FeatherIcons.checkCircle }
    , { name = "xCircle", icon = FeatherIcons.xCircle }
    , { name = "check", icon = FeatherIcons.check }
    , { name = "circle", icon = FeatherIcons.circle }
    , { name = "loader", icon = FeatherIcons.loader }
    ]


contentIcons : List IconEntry
contentIcons =
    [ { name = "calendar", icon = FeatherIcons.calendar }
    , { name = "clock", icon = FeatherIcons.clock }
    , { name = "star", icon = FeatherIcons.star }
    , { name = "flag", icon = FeatherIcons.flag }
    , { name = "users", icon = FeatherIcons.users }
    , { name = "user", icon = FeatherIcons.user }
    , { name = "mapPin", icon = FeatherIcons.mapPin }
    , { name = "fileText", icon = FeatherIcons.fileText }
    , { name = "tag", icon = FeatherIcons.tag }
    , { name = "link", icon = FeatherIcons.link }
    , { name = "mail", icon = FeatherIcons.mail }
    , { name = "phone", icon = FeatherIcons.phone }
    ]


mediaIcons : List IconEntry
mediaIcons =
    [ { name = "rss", icon = FeatherIcons.rss }
    , { name = "camera", icon = FeatherIcons.camera }
    , { name = "youtube", icon = FeatherIcons.youtube }
    , { name = "image", icon = FeatherIcons.image }
    , { name = "video", icon = FeatherIcons.video }
    , { name = "music", icon = FeatherIcons.music }
    ]


actionIcons : List IconEntry
actionIcons =
    [ { name = "zap", icon = FeatherIcons.zap }
    , { name = "settings", icon = FeatherIcons.settings }
    , { name = "edit", icon = FeatherIcons.edit }
    , { name = "edit2", icon = FeatherIcons.edit2 }
    , { name = "trash2", icon = FeatherIcons.trash2 }
    , { name = "plus", icon = FeatherIcons.plus }
    , { name = "plusCircle", icon = FeatherIcons.plusCircle }
    , { name = "minus", icon = FeatherIcons.minus }
    , { name = "download", icon = FeatherIcons.download }
    , { name = "upload", icon = FeatherIcons.upload }
    , { name = "share2", icon = FeatherIcons.share2 }
    , { name = "copy", icon = FeatherIcons.copy }
    , { name = "filter", icon = FeatherIcons.filter }
    , { name = "sliders", icon = FeatherIcons.sliders }
    , { name = "lock", icon = FeatherIcons.lock }
    , { name = "unlock", icon = FeatherIcons.unlock }
    ]


viewIconGrid : String -> List IconEntry -> Html msg
viewIconGrid title icons =
    Html.section [ classes [ TwEx.scroll_mt Th.s28, TwEx.space_y Th.s4 ] ]
        [ Html.h3 [ classes [ Tw.text_base, Tw.font_semibold, Tw.text_simple TC.brand ] ] [ Html.text title ]
        , Html.div
            [ classes
                [ Tw.grid
                , Tw.grid_cols_3
                , Bp.sm [ Tw.grid_cols_4 ]
                , Bp.md [ Tw.grid_cols_6 ]
                , Bp.lg [ Tw.grid_cols_8 ]
                , Tw.gap Th.s3
                ]
            ]
            (List.map viewIconCard icons)
        ]


viewIconCard : IconEntry -> Html msg
viewIconCard entry =
    Html.div
        [ classes
            [ Tw.flex
            , Tw.flex_col
            , Tw.items_center
            , Tw.gap Th.s2
            , Tw.p Th.s3
            , Tw.rounded_lg
            , Tw.border
            , Tw.border_color (Th.gray Th.s100)
            , Tw.bg_simple Th.white
            , Bp.hover [ TwEx.border_brand_30, TwEx.bg_brand_5 ]
            , Tw.transition_colors
            , TwEx.group
            ]
        ]
        [ Html.div [ classes [ Tw.text_simple TC.brand ] ]
            [ entry.icon |> FeatherIcons.withSize 24 |> FeatherIcons.toHtml [] ]
        , Html.span
            [ classes
                [ Tw.text_xs
                , Tw.text_color (Th.gray Th.s500)
                , Tw.font_mono
                , Tw.text_center
                , Tw.leading_tight
                , Tw.break_all
                , Bp.group_hover [ Tw.text_simple TC.brand ]
                , Tw.transition_colors
                ]
            ]
            [ Html.text entry.name ]
        ]
