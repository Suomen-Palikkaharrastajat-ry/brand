module Route.Responsiivisuus exposing (ActionData, Data, Model, Msg, route)

{-| Responsive-design guide page.

Covers mobile-first principles, breakpoints, container layout, grid
patterns, touch targets, and reduced-motion animation.

-}

import BackendTask exposing (BackendTask)
import Component.Alert as Alert
import Component.SectionHeader as SectionHeader
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import FeatherIcons
import Guide.Tokens as Tokens
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App)
import Set exposing (Set)
import Shared
import SiteMeta
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { playingEasings : Set String }


type Msg
    = ToggleEasing String


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


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
        , description = "Responsiivisuusohjeistus — murtopisteet, ruudukot ja mobiililähtöinen suunnittelu."
        , locale = Nothing
        , title = "Responsiivisuus — " ++ SiteMeta.organizationName
        }
        |> Seo.website


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { playingEasings = Set.empty }, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        ToggleEasing name ->
            if Set.member name model.playingEasings then
                ( { model | playingEasings = Set.remove name model.playingEasings }, Effect.none )

            else
                ( { model | playingEasings = Set.insert name model.playingEasings }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    { title = "Responsiivisuus — " ++ SiteMeta.organizationName
    , body =
        [ Html.div
            [ classes
                [ TwEx.max_w_5xl
                , Tw.mx_auto
                , Tw.px Th.s4
                , Tw.py Th.s8
                , Bp.sm [ Tw.py Th.s12 ]
                , TwEx.space_y Th.s12
                , Bp.sm [ TwEx.space_y Th.s16 ]
                ]
            ]
            [ viewPageHeader
            , viewMobileFirstSection
            , viewBreakpointsSection
            , viewContainerSection
            , viewGridSection
            , viewGeneralLayoutSection
            , viewTypographySection
            , viewTouchSection
            , viewMotionSection model
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ classes [ TwEx.space_y Th.s2 ] ]
        [ Html.h1 [ classes [ Tw.text_2xl, Bp.sm [ Tw.text_3xl ], Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Responsiivisuus" ]
        , Html.p [ classes [ Tw.text_sm, Bp.sm [ Tw.text_base ], Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text "Mobiililähtöinen suunnittelujärjestelmä. Koneluettava versio: "
            , Html.a
                [ Attr.href "/design-guide/responsiveness.jsonld"
                , classes [ Tw.underline, Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors, Tw.font_mono, Tw.text_sm ]
                ]
                [ Html.text "responsiveness.jsonld" ]
            , Html.text "."
            ]
        ]



-- ── Mobile-first ─────────────────────────────────────────────────────────────


viewMobileFirstSection : Html msg
viewMobileFirstSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Mobiililähtöinen suunnittelu"
            , description = Just "Kirjoita tyylit ensin mobiilinäkymälle ja lisää suurempien näyttöjen muokkaukset etuliitteillä sm:, md:, lg:."
            }
        , Alert.view
            { alertType = Alert.Info
            , title = Just "Periaate"
            , body =
                [ Html.text "Jokainen komponentti toimii ensin yhden sarakkeen mobiilinäkymässä. Ruudukot ja rinnakkaiset asettelut lisätään vasta isommille näytöille."
                ]
            , onDismiss = Nothing
            }
        , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            (List.map viewRuleCard
                [ ( "Älä käytä kiinteitä leveysmittoja"
                  , "Vältä px- tai rem-arvoja suoraan komponenttien leveyksissä. Käytä max-w-*, w-full tai Tailwindin flex/grid-luokkia."
                  )
                , ( "Jätä tilaa kosketukselle"
                  , "Kaikkien interaktiivisten elementtien pienin koko on 44 × 44 px (WCAG 2.5.5). Käytä vähintään py-3 px-4 -täytettä napeissa."
                  )
                , ( "Älä nojaa hover-tilaan"
                  , "Kosketusnäytöillä ei ole hover-tilaa. Kaikki toiminnallisuus on oltava saatavilla tap-eleellä."
                  )
                , ( "Taulukot vaativat vaakasuuntaisen vierityksen"
                  , "Kääri taulukot overflow-x-auto -säilöön. Älä pienennä fonttikokoa alle 14px mobiilinäkymässä."
                  )
                ]
            )
        ]



-- ── Breakpoints ───────────────────────────────────────────────────────────────


viewBreakpointsSection : Html msg
viewBreakpointsSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ Html.div [ classes [ Tw.flex, Tw.items_baseline, Tw.justify_between, Tw.flex_wrap, Tw.gap Th.s4 ] ]
            [ Html.h2 [ classes [ Tw.text_xl, Bp.sm [ Tw.text_2xl ], Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Murtopisteet" ]
            , Html.a
                [ Attr.href "/design-guide/responsiveness.jsonld"
                , classes [ Tw.text_xs, Tw.font_mono, Tw.text_color (Th.gray Th.s400), Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors ]
                ]
                [ Html.text "responsiveness.jsonld" ]
            ]
        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
            [ Html.text "Tailwind CSS:n oletusarvoiset murtopisteet. Kaikki murtopisteet ovat "
            , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.py Th.s0_dot_5, Tw.rounded ] ] [ Html.text "min-width" ]
            , Html.text " -ehtoisia — suunnittele ensin mobiilille."
            ]
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_sm, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ th "Etuliite"
                        , th "Min-leveys"
                        , th "Näyttötyyppi"
                        , th "Tailwind-esimerkki"
                        ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
                    (List.map viewBreakpointRow breakpointData)
                ]
            ]
        ]


breakpointData : List { prefix : String, minWidth : String, device : String, example : String }
breakpointData =
    [ { prefix = "(oletus)", minWidth = "0px", device = "Mobiili / puhelin", example = "grid-cols-1" }
    , { prefix = "sm:", minWidth = "640px", device = "Iso puhelin / pieni tabletti", example = "sm:grid-cols-2" }
    , { prefix = "md:", minWidth = "768px", device = "Tabletti", example = "md:flex-row" }
    , { prefix = "lg:", minWidth = "1024px", device = "Kannettava / pöytäkone", example = "lg:grid-cols-3" }
    , { prefix = "xl:", minWidth = "1280px", device = "Iso pöytäkone", example = "xl:grid-cols-4" }
    ]


viewBreakpointRow : { prefix : String, minWidth : String, device : String, example : String } -> Html msg
viewBreakpointRow row =
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ] ]
        [ Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_xs, Tw.font_semibold, Tw.text_simple TC.brand ] ] [ Html.text row.prefix ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.minWidth ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_color (Th.gray Th.s700), Tw.text_xs ] ] [ Html.text row.device ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.example ]
        ]



-- ── Container ─────────────────────────────────────────────────────────────────


viewContainerSection : Html msg
viewContainerSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Säilö ja täytteet"
            , description = Just "Kaikki sivun sisältö on sijoitettava sivusäilöön, joka rajoittaa maksimileveyden ja lisää reunatäytteet."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ Html.div [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_xl, Tw.p Th.s4, Bp.sm [ Tw.p Th.s6 ], TwEx.space_y Th.s3 ] ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_simple TC.brand, Tw.text_sm ] ] [ Html.text "Sivusäilö (page wrapper)" ]
                , Html.code [ classes [ Tw.block, Tw.font_mono, Tw.text_xs, Tw.bg_simple Th.white, Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded, Tw.px Th.s3, Tw.py Th.s2, Tw.text_color (Th.gray Th.s700) ] ]
                    [ Html.text "max-w-5xl mx-auto px-4" ]
                , Html.ul [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500), TwEx.space_y Th.s1, Tw.list_disc, Tw.list_inside ] ]
                    [ Html.li [] [ Html.text "max-w-5xl = 1024px maksimileveys" ]
                    , Html.li [] [ Html.text "mx-auto = vaakasuuntainen keskitys" ]
                    , Html.li [] [ Html.text "px-4 = 16px reunatäyte kaikilla näyttökoilla" ]
                    ]
                ]
            , Html.div [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_xl, Tw.p Th.s4, Bp.sm [ Tw.p Th.s6 ], TwEx.space_y Th.s3 ] ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_simple TC.brand, Tw.text_sm ] ] [ Html.text "Navigaatiovisuaalinen esimerkki" ]
                , viewContainerDemo
                ]
            ]
        ]


viewContainerDemo : Html msg
viewContainerDemo =
    Html.div [ classes [ TwEx.space_y Th.s2 ] ]
        [ Html.div [ classes [ Tw.bg_simple TC.brand, Tw.rounded_lg, Tw.p Th.s1, Tw.text_center ] ]
            [ Html.span [ classes [ Tw.text_xs, TwEx.text_white_60 ] ] [ Html.text "Koko näyttö (viewport)" ]
            ]
        , Html.div [ classes [ TwEx.bg_brand_20, Tw.rounded_lg, Tw.p Th.s1, Tw.mx Th.s2, Tw.text_center ] ]
            [ Html.span [ classes [ Tw.text_xs, TwEx.text_brand_70 ] ] [ Html.text "max-w-5xl mx-auto" ]
            ]
        , Html.div [ classes [ TwEx.bg_brand_10, Tw.rounded_lg, Tw.p Th.s1, Tw.mx Th.s6, Tw.text_center ] ]
            [ Html.span [ classes [ Tw.text_xs, TwEx.text_brand_50 ] ] [ Html.text "px-4 (sisältö)" ]
            ]
        ]



-- ── Grid patterns ─────────────────────────────────────────────────────────────


viewGridSection : Html msg
viewGridSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Ruudukkomallit"
            , description = Just "Vakioruudukot komponenttityypeittäin. Käytä aina näitä malleja — älä keksi uusia sarakkemääriä."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            (List.map viewGridPattern gridPatterns)
        ]


gridPatterns :
    List
        { name : String
        , desc : String
        , mobile : String
        , sm : String
        , md : String
        , lg : String
        , tailwind : String
        }
gridPatterns =
    [ { name = "Väripaletti / logokortit"
      , desc = "Pienet kortit, joissa on edustava väri tai kuva."
      , mobile = "1 sarake"
      , sm = "2 saraketta"
      , md = "2 saraketta"
      , lg = "3 saraketta"
      , tailwind = "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
      }
    , { name = "Komponenttiesittelyt"
      , desc = "Laajemmat esikatselukortit."
      , mobile = "1 sarake"
      , sm = "1 sarake"
      , md = "2 saraketta"
      , lg = "2 saraketta"
      , tailwind = "grid grid-cols-1 md:grid-cols-2 gap-6"
      }
    , { name = "Tilastot / mittarit"
      , desc = "Pienet lukukortit."
      , mobile = "1 sarake"
      , sm = "2 saraketta"
      , md = "2 saraketta"
      , lg = "4 saraketta"
      , tailwind = "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4"
      }
    ]


viewGridPattern :
    { name : String
    , desc : String
    , mobile : String
    , sm : String
    , md : String
    , lg : String
    , tailwind : String
    }
    -> Html msg
viewGridPattern p =
    Html.div [ classes [ Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_xl, Tw.overflow_hidden ] ]
        [ Html.div [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.px Th.s4, Tw.py Th.s3, Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
            [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text p.name ]
            , Html.p [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500), Tw.mt Th.s0_dot_5 ] ] [ Html.text p.desc ]
            ]
        , Html.div [ classes [ Tw.p Th.s4, TwEx.space_y Th.s3 ] ]
            [ Html.div [ classes [ Tw.grid, Tw.grid_cols_4, Bp.sm [ Tw.grid_cols_5 ], Tw.gap Th.s2, Tw.text_xs ] ]
                [ Html.div [ classes [ Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider, Tw.col_span_1 ] ] [ Html.text "Näyttö" ]
                , Html.div [ classes [ Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider, Tw.hidden, Bp.sm [ Tw.block ] ] ] [ Html.text "sm (640px)" ]
                , Html.div [ classes [ Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "md (768px)" ]
                , Html.div [ classes [ Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "lg (1024px)" ]
                , Html.div [ classes [ Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider, Tw.col_span_1 ] ] []
                , Html.div [ classes [ Tw.text_color (Th.gray Th.s700), Tw.col_span_1 ] ] [ Html.text p.mobile ]
                , Html.div [ classes [ Tw.text_color (Th.gray Th.s700), Tw.hidden, Bp.sm [ Tw.block ] ] ] [ Html.text p.sm ]
                , Html.div [ classes [ Tw.text_color (Th.gray Th.s700) ] ] [ Html.text p.md ]
                , Html.div [ classes [ Tw.text_color (Th.gray Th.s700) ] ] [ Html.text p.lg ]
                , Html.div [] []
                ]
            , Html.code [ classes [ Tw.block, Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s3, Tw.py Th.s2, Tw.rounded, Tw.text_color (Th.gray Th.s600), Tw.break_all ] ]
                [ Html.text p.tailwind ]
            ]
        ]



-- ── General layout patterns ───────────────────────────────────────────────────


viewGeneralLayoutSection : Html msg
viewGeneralLayoutSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Yleiset asettelumallit"
            , description = Just "Murtopiste-oletukset eri asettelutyypeille. Käytä näitä malleja yleissisältösivuilla."
            }
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_sm, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ th "Asettelu"
                        , th "Mobiili"
                        , th "Vaihto"
                        , th "Tailwind-luokat"
                        ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
                    (List.map viewLayoutRow layoutBreakpointData)
                ]
            ]
        , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            (List.map viewRuleCard
                [ ( "Tekstisisältö + kuva — vaihda md:ssä"
                  , "Kaksipalstainen teksti–kuva-asettelu vaihtuu md (768px) -pisteessä. Alle sen sisältö pinoutuu pystysuoraan, kuva tulee tekstin alle tai päälle."
                  )
                , ( "Korttiruudukko — vaihda sm:ssä tai md:ssä"
                  , "Pienet kortit (≤ 200px) sopivat 2 sarakkeeseen jo sm (640px). Laajemmat kortit (> 200px) vaihtuvat 2 sarakkeeseen vasta md:ssä."
                  )
                , ( "Sivupalkki — vaihda lg:ssä"
                  , "Sivupalkki vaatii leveämmän näytön. Vaihda lg (1024px) -pisteessä. Alle sen palkki sijoittuu sisällön ylä- tai alapuolelle."
                  )
                , ( "Navigaatio — vaihda md:ssä"
                  , "Hampurilaisvalikko mobiilissa, vaakasuuntainen navigaatiopalkki md (768px) -pisteestä ylöspäin."
                  )
                ]
            )
        ]


layoutBreakpointData : List { layout : String, mobile : String, switchAt : String, tailwind : String }
layoutBreakpointData =
    [ { layout = "Artikkelirunko (teksti)"
      , mobile = "1 sarake, täysleveys"
      , switchAt = "—"
      , tailwind = "max-w-prose mx-auto"
      }
    , { layout = "Teksti + kuva"
      , mobile = "1 sarake (pino)"
      , switchAt = "md (768px)"
      , tailwind = "grid grid-cols-1 md:grid-cols-2 gap-8"
      }
    , { layout = "Korttiruudukko (pienet)"
      , mobile = "1 sarake"
      , switchAt = "sm (640px)"
      , tailwind = "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
      }
    , { layout = "Korttiruudukko (laajat)"
      , mobile = "1 sarake"
      , switchAt = "md (768px)"
      , tailwind = "grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6"
      }
    , { layout = "Sivupalkki + sisältö"
      , mobile = "1 sarake (pino)"
      , switchAt = "lg (1024px)"
      , tailwind = "grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-8"
      }
    , { layout = "Hero / banneri"
      , mobile = "1 sarake, tekstikoko H1"
      , switchAt = "md (768px) → Display"
      , tailwind = "text-3xl md:text-5xl font-bold"
      }
    ]


viewLayoutRow : { layout : String, mobile : String, switchAt : String, tailwind : String } -> Html msg
viewLayoutRow row =
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ] ]
        [ Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_medium, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text row.layout ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_xs, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text row.mobile ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.switchAt ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s400), Tw.break_all ] ] [ Html.text row.tailwind ]
        ]



-- ── Typography ────────────────────────────────────────────────────────────────


viewTypographySection : Html msg
viewTypographySection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Responsiivinen typografia"
            , description = Just "Fonttikoko pysyy vakiona murtopisteissä. Display-tyyli on tarkoitettu vain suuremmille näytöille."
            }
        , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            (List.map viewRuleCard
                [ ( "Display vain ≥ md-näytöille"
                  , "Display-tyyli (48px / 3rem) on tarkoitettu vain näytöille, jotka ovat vähintään 768px leveät. Käytä Heading1 (30px / 1.875rem) mobiilinäkymässä."
                  )
                , ( "Ei alle 16px:n leipätekstiä"
                  , "Body-teksti pysyy 16px:ssä (1rem) kaikilla näyttökoilla. Pienin sallittu Caption/Label-koko on 14px (0.875rem)."
                  )
                , ( "Pitkät rivit rajataan"
                  , "Suositeltu enimmäisrivinpituus on 75 merkkiä. Käytä max-w-prose tai max-w-xl tekstilohkoissa."
                  )
                ]
            )
        , Html.div [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_xl, Tw.p Th.s4, Bp.sm [ Tw.p Th.s6 ], TwEx.space_y Th.s3 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Esimerkki — otsikkotasot mobiilissa vs. pöytäkoneessa" ]
            , Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.div [ classes [ Tw.flex, Tw.items_baseline, Tw.gap Th.s3, Tw.flex_wrap ] ]
                    [ Html.span [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s400), Tw.w Th.s28, Tw.shrink_0 ] ] [ Html.text "Mobiili: H1" ]
                    , Html.span [ classes [ Tw.text_2xl, Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Suomen Palikkaharrastajat" ]
                    ]
                , Html.div [ classes [ Tw.flex, Tw.items_baseline, Tw.gap Th.s3, Tw.flex_wrap ] ]
                    [ Html.span [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s400), Tw.w Th.s28, Tw.shrink_0 ] ] [ Html.text "Desktop: Display" ]
                    , Html.span [ classes [ Tw.text_5xl, Tw.font_bold, Tw.text_simple TC.brand ] ] [ Html.text "Suomen Palikkaharrastajat" ]
                    ]
                ]
            ]
        ]



-- ── Touch targets ─────────────────────────────────────────────────────────────


viewTouchSection : Html msg
viewTouchSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Kosketuskohteet"
            , description = Just "WCAG 2.5.5 (AAA) edellyttää vähintään 44 × 44 px kosketuskohteen kaikille interaktiivisille elementeille."
            }
        , Html.div [ classes [ Tw.grid, Tw.grid_cols_1, Bp.sm [ Tw.grid_cols_2 ], Tw.gap Th.s4 ] ]
            [ viewTouchExample
                "Oikein — riittävä täyte"
                True
                "py-3 px-4"
                [ Tw.py Th.s3, Tw.px Th.s4, Tw.font_medium, Tw.rounded, Tw.bg_simple TC.brandYellow, Tw.text_simple TC.brand ]
                "Painike"
            , viewTouchExample
                "Vältä — liian pieni"
                False
                "py-1 px-2"
                [ Tw.py Th.s1, Tw.px Th.s2, Tw.font_medium, Tw.rounded, Tw.bg_color (Th.gray Th.s200), Tw.text_color (Th.gray Th.s600), Tw.text_xs ]
                "Painike"
            ]
        , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            (List.map viewRuleCard
                [ ( "Linkit navigoinnissa"
                  , "Navigointilinkkien täytteen on oltava riittävä: px-3 py-2 on minimi. Lisää display: block tai padding navigointilinkkeihin."
                  )
                , ( "Kuvakkeet ilman tekstiä"
                  , "Ikonipainikkeet tarvitsevat näkymättömän tekstin (aria-label) ja riittävän kosketusalueen. Käytä p-3 tai p-2 ikonipainikkeiden ympärillä."
                  )
                ]
            )
        ]


viewTouchExample : String -> Bool -> String -> List Tw.Tailwind -> String -> Html msg
viewTouchExample title isGood paddingLabel btnClasses btnText =
    Html.div [ classes [ Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_xl, Tw.p Th.s4, TwEx.space_y Th.s3 ] ]
        [ Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
            [ Html.span
                [ classes
                    (if isGood then
                        [ Tw.text_color (Th.green Th.s600), Tw.font_semibold, Tw.text_sm, Tw.flex, Tw.items_center, Tw.gap Th.s1 ]

                     else
                        [ Tw.text_color (Th.orange Th.s500), Tw.font_semibold, Tw.text_sm, Tw.flex, Tw.items_center, Tw.gap Th.s1 ]
                    )
                ]
                [ (if isGood then
                    FeatherIcons.check

                   else
                    FeatherIcons.alertTriangle
                  )
                    |> FeatherIcons.withSize 14
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text title
                ]
            ]
        , Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s3 ] ]
            [ Html.button [ classes btnClasses ] [ Html.text btnText ]
            , Html.span [ classes [ Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s400) ] ] [ Html.text paddingLabel ]
            ]
        ]



-- ── Motion ────────────────────────────────────────────────────────────────────


viewMotionSection : Model -> Html (PagesMsg Msg)
viewMotionSection model =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Liike ja prefers-reduced-motion"
            , description = Just "Kaikki animaatiot on pysäytettävä tai korvattava, kun käyttäjä on asettanut prefers-reduced-motion: reduce."
            }
        , Html.div [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_xl, Tw.p Th.s4, Bp.sm [ Tw.p Th.s6 ], TwEx.space_y Th.s3 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "CSS-esimerkki" ]
            , Html.pre [ classes [ Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s700), Tw.overflow_x_auto ] ]
                [ Html.text """@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}""" ]
            ]
        , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            (List.map viewRuleCard
                [ ( "Animoitu logo"
                  , "Käytä <img src=\"square-animated.gif\"> vain silloin, kun prefers-reduced-motion EI ole aktiivinen. Staattinen vaihtoehto: square.png tai square.webp."
                  )
                , ( "Siirtymäajat"
                  , "fast: 150ms (hover/focus), base: 300ms (avautumiset), slow: 500ms (sivutason muutokset). Katso motion-osio design-guide.json:ssa."
                  )
                ]
            )
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Easing-tokenit — klikkaa toistaaksesi" ]
            , viewEasingDemo model { name = "standard", label = "Standard", easingValue = Tokens.motionEasingStandard, description = "Yleiskäyttöinen siirtymä — elementit, jotka liikkuvat ruudun sisällä." }
            , viewEasingDemo model { name = "decelerate", label = "Decelerate", easingValue = Tokens.motionEasingDecelerate, description = "Elementit, jotka tulevat näkymään — hidastuvat lopussa." }
            , viewEasingDemo model { name = "accelerate", label = "Accelerate", easingValue = Tokens.motionEasingAccelerate, description = "Elementit, jotka poistuvat näkymästä — kiihtyvät loppua kohti." }
            ]
        ]


viewEasingDemo :
    Model
    -> { name : String, label : String, easingValue : String, description : String }
    -> Html (PagesMsg Msg)
viewEasingDemo model { name, label, easingValue, description } =
    let
        isPlaying =
            Set.member name model.playingEasings
    in
    Html.button
        [ classes
            [ Tw.block
            , Tw.w_full
            , Tw.text_left
            , Tw.border
            , Tw.border_color (Th.gray Th.s200)
            , Tw.rounded_xl
            , Tw.p Th.s4
            , TwEx.space_y Th.s3
            , Tw.cursor_pointer
            , Bp.hover [ Tw.border_color (Th.gray Th.s300) ]
            , Tw.transition_colors
            , TwEx.bg_transparent
            ]
        , Attr.type_ "button"
        , Attr.attribute "aria-pressed"
            (if isPlaying then
                "true"

             else
                "false"
            )
        , Events.onClick (PagesMsg.fromMsg (ToggleEasing name))
        ]
        [ Html.div [ classes [ Tw.flex, Tw.items_center, Tw.justify_between ] ]
            [ Html.p [ classes [ Tw.text_sm, Tw.font_semibold, Tw.text_simple TC.brand ] ] [ Html.text label ]
            , Html.span [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s400), Tw.flex, Tw.items_center, Tw.gap Th.s1 ] ]
                [ (if isPlaying then
                    FeatherIcons.refreshCw

                   else
                    FeatherIcons.play
                  )
                    |> FeatherIcons.withSize 12
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text
                    (if isPlaying then
                        "Nollaa"

                     else
                        "Toista"
                    )
                ]
            ]
        , Html.div
            [ classes [ Tw.relative, Tw.w_full, Tw.h Th.s6, Tw.bg_color (Th.gray Th.s100), Tw.rounded, Tw.overflow_hidden ] ]
            [ Html.div
                [ Attr.style "position" "absolute"
                , Attr.style "top" "4px"
                , Attr.style "width" "16px"
                , Attr.style "height" "16px"
                , Attr.style "background" "#1A1A2E"
                , Attr.style "border-radius" "50%"
                , Attr.style "transition"
                    (if isPlaying then
                        "left 1000ms " ++ easingValue

                     else
                        "none"
                    )
                , Attr.style "left"
                    (if isPlaying then
                        "calc(100% - 16px)"

                     else
                        "0px"
                    )
                ]
                []
            ]
        , Html.code [ classes [ Tw.block, Tw.text_xs, Tw.font_mono, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text easingValue ]
        , Html.p [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s400) ] ] [ Html.text description ]
        ]



-- ── Helpers ───────────────────────────────────────────────────────────────────


th : String -> Html msg
th label =
    Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ]
        [ Html.text label ]


viewRuleCard : ( String, String ) -> Html msg
viewRuleCard ( title, body ) =
    Html.div [ classes [ Tw.border_l_4, Tw.border_simple TC.brandYellow, Tw.pl Th.s4, Tw.py Th.s1, TwEx.space_y Th.s1 ] ]
        [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text title ]
        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text body ]
        ]
