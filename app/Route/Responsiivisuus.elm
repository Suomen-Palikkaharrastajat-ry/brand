module Route.Responsiivisuus exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Brand.Tokens as Tokens
import Component.Alert as Alert
import Component.SectionHeader as SectionHeader
import Effect exposing (Effect)
import FatalError exposing (FatalError)
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
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-8 sm:py-12 space-y-12 sm:space-y-16" ]
            [ viewPageHeader
            , viewMobileFirstSection
            , viewBreakpointsSection
            , viewContainerSection
            , viewGridSection
            , viewTypographySection
            , viewTouchSection
            , viewMotionSection model
            ]
        ]
    }



-- ── Page header ───────────────────────────────────────────────────────────────


viewPageHeader : Html msg
viewPageHeader =
    Html.div [ Attr.class "space-y-3" ]
        [ Html.h1 [ Attr.class "text-2xl sm:text-3xl font-bold text-brand" ] [ Html.text "Responsiivisuus" ]
        , Html.p [ Attr.class "text-gray-500 text-sm sm:text-base" ]
            [ Html.text "Mobiililähtöinen suunnittelujärjestelmä. Koneluettava versio: "
            , Html.a
                [ Attr.href "/design-guide/responsiveness.jsonld"
                , Attr.class "underline hover:text-brand transition-colors font-mono text-xs sm:text-sm"
                ]
                [ Html.text "responsiveness.jsonld" ]
            , Html.text "."
            ]
        ]



-- ── Mobile-first ─────────────────────────────────────────────────────────────


viewMobileFirstSection : Html msg
viewMobileFirstSection =
    Html.section [ Attr.class "space-y-6" ]
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
        , Html.div [ Attr.class "space-y-3" ]
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
    Html.section [ Attr.class "space-y-6" ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-4" ]
            [ Html.h2 [ Attr.class "text-xl sm:text-2xl font-bold text-brand" ] [ Html.text "Murtopisteet" ]
            , Html.a
                [ Attr.href "/design-guide/responsiveness.jsonld"
                , Attr.class "text-xs font-mono text-gray-400 hover:text-brand transition-colors"
                ]
                [ Html.text "responsiveness.jsonld" ]
            ]
        , Html.p [ Attr.class "text-sm text-gray-600" ]
            [ Html.text "Tailwind CSS:n oletusarvoiset murtopisteet. Kaikki murtopisteet ovat "
            , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 py-0.5 rounded" ] [ Html.text "min-width" ]
            , Html.text " -ehtoisia — suunnittele ensin mobiilille."
            ]
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "bg-gray-50 border-b border-gray-200" ]
                        [ th "Etuliite"
                        , th "Min-leveys"
                        , th "Näyttötyyppi"
                        , th "Tailwind-esimerkki"
                        ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
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
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "py-2 px-3 font-mono text-xs font-semibold text-brand" ] [ Html.text row.prefix ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.minWidth ]
        , Html.td [ Attr.class "py-2 px-3 text-gray-700 text-xs" ] [ Html.text row.device ]
        , Html.td [ Attr.class "py-2 px-3 font-mono text-xs text-gray-500" ] [ Html.text row.example ]
        ]



-- ── Container ─────────────────────────────────────────────────────────────────


viewContainerSection : Html msg
viewContainerSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Säilö ja täytteet"
            , description = Just "Kaikki sivun sisältö on sijoitettava sivusäilöön, joka rajoittaa maksimileveyden ja lisää reunatäytteet."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ Html.div [ Attr.class "bg-gray-50 border border-gray-200 rounded-xl p-4 sm:p-6 space-y-3" ]
                [ Html.p [ Attr.class "font-semibold text-brand text-sm" ] [ Html.text "Sivusäilö (page wrapper)" ]
                , Html.code [ Attr.class "block font-mono text-xs bg-white border border-gray-200 rounded px-3 py-2 text-gray-700" ]
                    [ Html.text "max-w-5xl mx-auto px-4" ]
                , Html.ul [ Attr.class "text-xs text-gray-500 space-y-1 list-disc list-inside" ]
                    [ Html.li [] [ Html.text "max-w-5xl = 1024px maksimileveys" ]
                    , Html.li [] [ Html.text "mx-auto = vaakasuuntainen keskitys" ]
                    , Html.li [] [ Html.text "px-4 = 16px reunatäyte kaikilla näyttökoilla" ]
                    ]
                ]
            , Html.div [ Attr.class "bg-gray-50 border border-gray-200 rounded-xl p-4 sm:p-6 space-y-3" ]
                [ Html.p [ Attr.class "font-semibold text-brand text-sm" ] [ Html.text "Navigaatiovisuaalinen esimerkki" ]
                , viewContainerDemo
                ]
            ]
        ]


viewContainerDemo : Html msg
viewContainerDemo =
    Html.div [ Attr.class "space-y-2" ]
        [ Html.div [ Attr.class "bg-brand rounded-lg p-1 text-center" ]
            [ Html.span [ Attr.class "text-xs text-white/60" ] [ Html.text "Koko näyttö (viewport)" ]
            ]
        , Html.div [ Attr.class "bg-brand/20 rounded-lg p-1 mx-2 text-center" ]
            [ Html.span [ Attr.class "text-xs text-brand/70" ] [ Html.text "max-w-5xl mx-auto" ]
            ]
        , Html.div [ Attr.class "bg-brand/10 rounded-lg p-1 mx-6 text-center" ]
            [ Html.span [ Attr.class "text-xs text-brand/50" ] [ Html.text "px-4 (sisältö)" ]
            ]
        ]



-- ── Grid patterns ─────────────────────────────────────────────────────────────


viewGridSection : Html msg
viewGridSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Ruudukkomallit"
            , description = Just "Vakioruudukot komponenttityypeittäin. Käytä aina näitä malleja — älä keksi uusia sarakkemääriä."
            }
        , Html.div [ Attr.class "space-y-4" ]
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
    Html.div [ Attr.class "border border-gray-200 rounded-xl overflow-hidden" ]
        [ Html.div [ Attr.class "bg-gray-50 px-4 py-3 border-b border-gray-200" ]
            [ Html.p [ Attr.class "font-semibold text-sm text-brand" ] [ Html.text p.name ]
            , Html.p [ Attr.class "text-xs text-gray-500 mt-0.5" ] [ Html.text p.desc ]
            ]
        , Html.div [ Attr.class "p-4 space-y-3" ]
            [ Html.div [ Attr.class "grid grid-cols-4 sm:grid-cols-5 gap-2 text-xs" ]
                [ Html.div [ Attr.class "font-semibold text-gray-500 uppercase tracking-wider col-span-1" ] [ Html.text "Näyttö" ]
                , Html.div [ Attr.class "font-semibold text-gray-500 uppercase tracking-wider hidden sm:block" ] [ Html.text "sm (640px)" ]
                , Html.div [ Attr.class "font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "md (768px)" ]
                , Html.div [ Attr.class "font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "lg (1024px)" ]
                , Html.div [ Attr.class "font-semibold text-gray-500 uppercase tracking-wider col-span-1" ] []
                , Html.div [ Attr.class "text-gray-700 col-span-1" ] [ Html.text p.mobile ]
                , Html.div [ Attr.class "text-gray-700 hidden sm:block" ] [ Html.text p.sm ]
                , Html.div [ Attr.class "text-gray-700" ] [ Html.text p.md ]
                , Html.div [ Attr.class "text-gray-700" ] [ Html.text p.lg ]
                , Html.div [] []
                ]
            , Html.code [ Attr.class "block font-mono text-xs bg-gray-100 px-3 py-2 rounded text-gray-600 break-all" ]
                [ Html.text p.tailwind ]
            ]
        ]



-- ── Typography ────────────────────────────────────────────────────────────────


viewTypographySection : Html msg
viewTypographySection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Responsiivinen typografia"
            , description = Just "Fonttikoko pysyy vakiona murtopisteissä. Display-tyyli on tarkoitettu vain suuremmille näytöille."
            }
        , Html.div [ Attr.class "space-y-3" ]
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
        , Html.div [ Attr.class "bg-gray-50 border border-gray-200 rounded-xl p-4 sm:p-6 space-y-3" ]
            [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Esimerkki — otsikkotasot mobiilissa vs. pöytäkoneessa" ]
            , Html.div [ Attr.class "space-y-2" ]
                [ Html.div [ Attr.class "flex items-baseline gap-3 flex-wrap" ]
                    [ Html.span [ Attr.class "text-xs text-gray-400 w-28 flex-shrink-0" ] [ Html.text "Mobiili: H1" ]
                    , Html.span [ Attr.class "text-2xl font-bold text-brand" ] [ Html.text "Suomen Palikkaharrastajat" ]
                    ]
                , Html.div [ Attr.class "flex items-baseline gap-3 flex-wrap" ]
                    [ Html.span [ Attr.class "text-xs text-gray-400 w-28 flex-shrink-0" ] [ Html.text "Desktop: Display" ]
                    , Html.span [ Attr.class "text-5xl font-bold text-brand" ] [ Html.text "Suomen Palikkaharrastajat" ]
                    ]
                ]
            ]
        ]



-- ── Touch targets ─────────────────────────────────────────────────────────────


viewTouchSection : Html msg
viewTouchSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Kosketuskohteet"
            , description = Just "WCAG 2.5.5 (AAA) edellyttää vähintään 44 × 44 px kosketuskohteen kaikille interaktiivisille elementeille."
            }
        , Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-4" ]
            [ viewTouchExample
                "Oikein — riittävä täyte"
                True
                "py-3 px-4"
                "py-3 px-4 font-medium rounded bg-brand-yellow text-brand"
                "Painike"
            , viewTouchExample
                "Vältä — liian pieni"
                False
                "py-1 px-2"
                "py-1 px-2 font-medium rounded bg-gray-200 text-gray-600 text-xs"
                "Painike"
            ]
        , Html.div [ Attr.class "space-y-3" ]
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


viewTouchExample : String -> Bool -> String -> String -> String -> Html msg
viewTouchExample title isGood paddingLabel btnClass btnText =
    Html.div [ Attr.class "border border-gray-200 rounded-xl p-4 space-y-3" ]
        [ Html.div [ Attr.class "flex items-center gap-2" ]
            [ Html.span
                [ Attr.class
                    (if isGood then
                        "text-green-600 font-semibold text-sm"

                     else
                        "text-orange-500 font-semibold text-sm"
                    )
                ]
                [ Html.text
                    (if isGood then
                        "✓ " ++ title

                     else
                        "⚠ " ++ title
                    )
                ]
            ]
        , Html.div [ Attr.class "flex items-center gap-3" ]
            [ Html.button [ Attr.class btnClass ] [ Html.text btnText ]
            , Html.span [ Attr.class "font-mono text-xs text-gray-400" ] [ Html.text paddingLabel ]
            ]
        ]



-- ── Motion ────────────────────────────────────────────────────────────────────


viewMotionSection : Model -> Html (PagesMsg Msg)
viewMotionSection model =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Liike ja prefers-reduced-motion"
            , description = Just "Kaikki animaatiot on pysäytettävä tai korvattava, kun käyttäjä on asettanut prefers-reduced-motion: reduce."
            }
        , Html.div [ Attr.class "bg-gray-50 border border-gray-200 rounded-xl p-4 sm:p-6 space-y-3" ]
            [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "CSS-esimerkki" ]
            , Html.pre [ Attr.class "font-mono text-xs text-gray-700 overflow-x-auto" ]
                [ Html.text """@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}""" ]
            ]
        , Html.div [ Attr.class "space-y-3" ]
            (List.map viewRuleCard
                [ ( "Animoitu logo"
                  , "Käytä <img src=\"square-animated.gif\"> vain silloin, kun prefers-reduced-motion EI ole aktiivinen. Staattinen vaihtoehto: square.png tai square.webp."
                  )
                , ( "Siirtymäajat"
                  , "fast: 150ms (hover/focus), base: 300ms (avautumiset), slow: 500ms (sivutason muutokset). Katso motion-osio design-guide.json:ssa."
                  )
                ]
            )
        , Html.div [ Attr.class "space-y-4" ]
            [ Html.p [ Attr.class "text-xs font-semibold text-gray-500 uppercase tracking-wider" ] [ Html.text "Easing-tokenit — klikkaa toistaaksesi" ]
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
    Html.div
        [ Attr.class "border border-gray-200 rounded-xl p-4 space-y-3 cursor-pointer hover:border-gray-300 transition-colors"
        , Events.onClick (PagesMsg.fromMsg (ToggleEasing name))
        ]
        [ Html.div [ Attr.class "flex items-center justify-between" ]
            [ Html.p [ Attr.class "text-sm font-semibold text-brand" ] [ Html.text label ]
            , Html.span [ Attr.class "text-xs text-gray-400" ]
                [ Html.text
                    (if isPlaying then
                        "Nollaa ↺"

                     else
                        "Toista ▶"
                    )
                ]
            ]
        , Html.div
            [ Attr.class "relative w-full h-6 bg-gray-100 rounded overflow-hidden" ]
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
        , Html.code [ Attr.class "block text-xs font-mono text-gray-500" ] [ Html.text easingValue ]
        , Html.p [ Attr.class "text-xs text-gray-400" ] [ Html.text description ]
        ]



-- ── Helpers ───────────────────────────────────────────────────────────────────


th : String -> Html msg
th label =
    Html.th [ Attr.class "py-2 px-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider" ]
        [ Html.text label ]


viewRuleCard : ( String, String ) -> Html msg
viewRuleCard ( title, body ) =
    Html.div [ Attr.class "border-l-4 border-brand-yellow pl-4 py-1 space-y-1" ]
        [ Html.p [ Attr.class "font-semibold text-sm text-brand" ] [ Html.text title ]
        , Html.p [ Attr.class "text-sm text-gray-600" ] [ Html.text body ]
        ]
