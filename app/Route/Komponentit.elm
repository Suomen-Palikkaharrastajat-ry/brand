module Route.Komponentit exposing (ActionData, Data, Model, Msg, route)

{-| The component gallery page (`/komponentit`).

Renders a live preview and source-code example for every UI component in the
design system. Each component is shown in a tabbed card (`compCard`) with
Preview, Elm-code, and JSON-LD tabs. State for open dropdowns, dialogs, and
toggles is held in `Model` and updated via `Msg`.

-}

import BackendTask exposing (BackendTask)
import Component.Accordion as Accordion
import Component.Alert as Alert
import Component.Badge as Badge
import Component.Breadcrumb as Breadcrumb
import Component.Button as Button
import Component.ButtonGroup as ButtonGroup
import Component.Card as Card
import Component.CloseButton as CloseButton
import Component.Collapse as Collapse
import Component.ColorSwatch as ColorSwatch
import Component.Dialog as Dialog
import Component.Dropdown as Dropdown
import Component.FeatureGrid as FeatureGrid
import Component.Footer as Footer
import Component.Hero as Hero
import Component.ListGroup as ListGroup
import Component.Navbar as Navbar
import Component.Pagination as Pagination
import Component.Placeholder as Placeholder
import Component.Pricing as Pricing
import Component.Progress as Progress
import Component.SectionHeader as SectionHeader
import Component.Spinner as Spinner
import Component.Stats as Stats
import Component.Tabs as Tabs
import Component.Tag as Tag
import Component.Timeline as Timeline
import Component.Toast as Toast
import Component.Toggle as Toggle
import Component.Tooltip as Tooltip
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import FeatherIcons
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App)
import Shared
import SiteMeta
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC
import UrlPath exposing (UrlPath)
import View exposing (View)



-- ── Types ─────────────────────────────────────────────────────────────────────


type Tab
    = PreviewTab
    | CodeTab
    | JsonTab


type alias Model =
    { tabs : Dict String Tab
    , dropdownOpen : Bool
    , toggleChecked : Bool
    , dialogOpen : Bool
    }


type Msg
    = SelectTab String Tab
    | ToggleDropdown
    | CloseDropdown
    | ToggleChanged Bool
    | OpenDialog
    | CloseDialog


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}



-- ── Route ─────────────────────────────────────────────────────────────────────


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
        , description = "Suomen Palikkaharrastajat ry:n UI-komponenttikirjasto."
        , locale = Nothing
        , title = "Komponentit — " ++ SiteMeta.organizationName
        }
        |> Seo.website


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { tabs = Dict.empty
      , dropdownOpen = False
      , toggleChecked = False
      , dialogOpen = False
      }
    , Effect.none
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SelectTab key tab ->
            ( { model | tabs = Dict.insert key tab model.tabs }, Effect.none )

        ToggleDropdown ->
            ( { model | dropdownOpen = not model.dropdownOpen }, Effect.none )

        CloseDropdown ->
            ( { model | dropdownOpen = False }, Effect.none )

        ToggleChanged checked ->
            ( { model | toggleChecked = checked }, Effect.none )

        OpenDialog ->
            ( { model | dialogOpen = True }, Effect.none )

        CloseDialog ->
            ( { model | dialogOpen = False }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none



-- ── View ──────────────────────────────────────────────────────────────────────


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    { title = "Komponentit — " ++ SiteMeta.organizationName
    , body =
        [ Html.div
            [ classes
                [ TwEx.max_w_5xl
                , Tw.mx_auto
                , Tw.px Th.s4
                , Tw.py Th.s8
                , Bp.sm [ Tw.py Th.s12 ]
                , TwEx.space_y Th.s6
                ]
            ]
            [ Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.h1
                    [ classes
                        [ Tw.text_2xl
                        , Bp.sm [ Tw.text_3xl ]
                        , Tw.font_bold
                        , Tw.text_simple TC.brand
                        ]
                    ]
                    [ Html.text "Komponentit" ]
                , Html.p
                    [ classes
                        [ Tw.text_sm
                        , Bp.sm [ Tw.text_base ]
                        , Tw.text_color (Th.gray Th.s500)
                        ]
                    ]
                    [ Html.text "Kaikki komponentit hakemistossa "
                    , Html.code
                        [ classes
                            [ Tw.font_mono
                            , Tw.text_sm
                            , Tw.bg_color (Th.gray Th.s100)
                            , Tw.px Th.s1
                            , Tw.rounded
                            ]
                        ]
                        [ Html.text "src/Component/" ]
                    , Html.text ". Koneluettava: "
                    , Html.a
                        [ Attr.href "/design-guide/components.jsonld"
                        , classes
                            [ Tw.underline
                            , Bp.hover [ Tw.text_simple TC.brand ]
                            , Tw.transition_colors
                            , Tw.font_mono
                            , Tw.text_sm
                            ]
                        ]
                        [ Html.text "components.jsonld" ]
                    , Html.text "."
                    ]
                ]
            , viewCompIndex
            , viewConventions
            , Html.div [ classes [ TwEx.space_y Th.s16, Tw.pt Th.s4 ] ]
                [ viewAlert model
                , viewAccordion model
                , viewBadge model
                , viewBreadcrumb model
                , viewButton model
                , viewButtonSpec
                , viewButtonGroup model
                , viewCard model
                , viewCloseButton model
                , viewCollapse model
                , viewDialog model
                , viewDropdown model
                , viewListGroup model
                , viewPagination model
                , viewPlaceholder model
                , viewProgress model
                , viewSpinner model
                , viewStats model
                , viewTag model
                , viewTimeline model
                , viewToast model
                , viewToggle model
                , viewTooltip model
                , viewToolbar
                , viewSivupohjat
                ]
            ]
        ]
    }


viewConventions : Html (PagesMsg Msg)
viewConventions =
    Html.div
        [ classes
            [ Tw.bg_color (Th.blue Th.s50)
            , Tw.border
            , Tw.border_color (Th.blue Th.s200)
            , Tw.rounded_lg
            , Tw.p Th.s4
            , Tw.text_sm
            , Tw.text_color (Th.blue Th.s900)
            , TwEx.space_y Th.s2
            ]
        ]
        [ Html.p [ classes [ Tw.font_semibold ] ] [ Html.text "UI-konventiot" ]
        , Html.ul
            [ classes
                [ Tw.list_disc
                , Tw.list_inside
                , TwEx.space_y Th.s1
                , Tw.text_color (Th.blue Th.s800)
                ]
            ]
            [ Html.li []
                [ Html.text "Kaikilla painikemaisilla elementeillä tulee olla "
                , Html.code
                    [ classes
                        [ Tw.font_mono
                        , Tw.bg_color (Th.blue Th.s100)
                        , Tw.px Th.s1
                        , Tw.rounded
                        ]
                    ]
                    [ Html.text "cursor-pointer" ]
                , Html.text " — myös ButtonGroup, CloseButton, Pagination ja ListGroup."
                ]
            , Html.li []
                [ Html.text "Poistettu/disabled-tila käyttää "
                , Html.code
                    [ classes
                        [ Tw.font_mono
                        , Tw.bg_color (Th.blue Th.s100)
                        , Tw.px Th.s1
                        , Tw.rounded
                        ]
                    ]
                    [ Html.text "cursor-not-allowed" ]
                , Html.text "."
                ]
            , Html.li []
                [ Html.text "Kaikki interaktiiviset elementit tarjoavat "
                , Html.code
                    [ classes
                        [ Tw.font_mono
                        , Tw.bg_color (Th.blue Th.s100)
                        , Tw.px Th.s1
                        , Tw.rounded
                        ]
                    ]
                    [ Html.text "focus-visible:ring-2 focus-visible:ring-brand" ]
                , Html.text " näppäimistökäyttöä varten (ei hiirellä, vain näppäimistöllä)."
                ]
            ]
        ]


viewCompIndex : Html (PagesMsg Msg)
viewCompIndex =
    Html.nav [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s2 ] ]
        (List.map
            (\name ->
                Html.a
                    [ Attr.href ("#" ++ String.toLower name)
                    , classes
                        [ Tw.px Th.s3
                        , Tw.py Th.s1
                        , Tw.text_xs
                        , Tw.font_medium
                        , Tw.rounded_full
                        , Tw.bg_color (Th.gray Th.s100)
                        , Tw.text_color (Th.gray Th.s600)
                        , Bp.hover [ Tw.bg_simple TC.brand, Tw.text_simple Th.white ]
                        , Tw.transition_colors
                        ]
                    ]
                    [ Html.text name ]
            )
            [ "Alert"
            , "Accordion"
            , "Badge"
            , "Breadcrumb"
            , "Button"
            , "ButtonGroup"
            , "Card"
            , "CloseButton"
            , "Collapse"
            , "Dialog"
            , "Dropdown"
            , "ListGroup"
            , "Pagination"
            , "Placeholder"
            , "Progress"
            , "Spinner"
            , "Stats"
            , "Tag"
            , "Timeline"
            , "Toast"
            , "Toggle"
            , "Tooltip"
            , "FeatureGrid"
            , "Hero"
            , "Navbar"
            , "Footer"
            , "Pricing"
            ]
        )



-- ── Component card helpers ─────────────────────────────────────────────────────


activeTab : Model -> String -> Tab
activeTab model name =
    Dict.get name model.tabs |> Maybe.withDefault PreviewTab


tabIndex : Tab -> Int
tabIndex tab =
    case tab of
        PreviewTab ->
            0

        CodeTab ->
            1

        JsonTab ->
            2


tabFromIndex : Int -> Tab
tabFromIndex i =
    case i of
        1 ->
            CodeTab

        2 ->
            JsonTab

        _ ->
            PreviewTab


compCard :
    Model
    -> String
    -> String
    -> Html (PagesMsg Msg)
    -> String
    -> String
    -> Html (PagesMsg Msg)
compCard model name description preview elmCode jsonLd =
    Html.section
        [ Attr.id (String.toLower name)
        , classes [ TwEx.scroll_mt Th.s20, TwEx.space_y Th.s3 ]
        ]
        [ Html.div
            [ classes
                [ Tw.flex
                , Tw.items_baseline
                , Tw.justify_between
                , Tw.flex_wrap
                , Tw.gap Th.s2
                ]
            ]
            [ Html.h2
                [ classes [ Tw.text_xl, Tw.font_bold, Tw.text_simple TC.brand ] ]
                [ Html.text name ]
            , Html.span
                [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s400), Tw.font_mono ] ]
                [ Html.text ("Component." ++ name) ]
            ]
        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text description ]
        , Tabs.view
            { tabs = [ "Esikatselu", "Elm-koodi", "JSON-LD" ]
            , activeIndex = tabIndex (activeTab model name)
            , onTabClick =
                \i -> PagesMsg.fromMsg (SelectTab name (tabFromIndex i))
            , panels =
                [ Html.div
                    [ classes
                        [ Tw.p Th.s6
                        , Tw.bg_color (Th.gray Th.s50)
                        , Tw.rounded_lg
                        , Tw.border
                        , Tw.border_color (Th.gray Th.s200)
                        ]
                    ]
                    [ preview ]
                , codePanel elmCode
                , jsonPanel jsonLd
                ]
            }
        ]


codePanel : String -> Html msg
codePanel src =
    Html.div [ classes [ Tw.overflow_x_auto ] ]
        [ Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.gray Th.s100)
                , Tw.rounded_lg
                , Tw.p Th.s5
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code [] [ Html.text src ] ]
        ]


jsonPanel : String -> Html msg
jsonPanel src =
    Html.div [ classes [ Tw.overflow_x_auto ] ]
        [ Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.emerald Th.s300)
                , Tw.rounded_lg
                , Tw.p Th.s5
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code [] [ Html.text src ] ]
        ]



-- ── Alert ─────────────────────────────────────────────────────────────────────


viewAlert : Model -> Html (PagesMsg Msg)
viewAlert model =
    compCard model
        "Alert"
        "Kontekstuaalinen palauteviesti neljässä tyypissä. Tukee myös suljettavaa varianttia (onDismiss)."
        (Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            [ Alert.view { alertType = Alert.Info, title = Just "Tietoa", body = [ Html.text "Neutraali ohjeistus tai informaatio." ], onDismiss = Nothing }
            , Alert.view { alertType = Alert.Success, title = Just "Onnistui", body = [ Html.text "Toiminto onnistui onnistuneesti." ], onDismiss = Nothing }
            , Alert.view { alertType = Alert.Warning, title = Just "Varoitus", body = [ Html.text "Tarkista tiedot ennen jatkamista." ], onDismiss = Nothing }
            , Alert.view { alertType = Alert.Error, title = Just "Virhe", body = [ Html.text "Toiminto epäonnistui." ], onDismiss = Nothing }
            ]
        )
        """import Component.Alert as Alert

Alert.view
    { alertType = Alert.Info
    , title = Just "Tietoa"
    , body = [ Html.text "Ohjeteksti tähän." ]
    , onDismiss = Nothing          -- or Just DismissMsg
    }"""
        (jsonLdSnippet "alert"
            "Alert"
            "Component.Alert"
            "Contextual feedback message. Types: Info, Success, Warning, Error."
            [ "alertType: AlertType (Info|Success|Warning|Error)", "title: Maybe String", "body: List (Html msg)", "onDismiss: Maybe msg" ]
            []
        )



-- ── Accordion ─────────────────────────────────────────────────────────────────


viewAccordion : Model -> Html (PagesMsg Msg)
viewAccordion model =
    compCard model
        "Accordion"
        "Tiivistettävät osiot – käyttää selaimen natiivia <details>-elementtiä."
        (Accordion.view
            [ Accordion.viewItem { title = "Mikä on Suomen Palikkaharrastajat ry?", body = [ Html.text "Suomalainen LEGO-harrastajayhdistys." ] }
            , Accordion.viewItem { title = "Miten logoa saa käyttää?", body = [ Html.text "Katso ohjeistus Logot-osiosta." ] }
            , Accordion.viewItem { title = "Missä muodoissa logo on saatavilla?", body = [ Html.text "SVG, PNG, WebP ja animoituna GIF/WebP." ] }
            ]
        )
        """import Component.Accordion as Accordion

Accordion.view
    [ Accordion.viewItem
        { title = "Otsikko"
        , body = [ Html.text "Sisältö" ]
        }
    ]"""
        (jsonLdSnippet "accordion"
            "Accordion"
            "Component.Accordion"
            "Collapsible sections using native <details>."
            [ "items: List { title: String, body: List (Html msg) }" ]
            [ "colors.semantic.border.default" ]
        )



-- ── Badge ─────────────────────────────────────────────────────────────────────


viewBadge : Model -> Html (PagesMsg Msg)
viewBadge model =
    compCard model
        "Badge"
        "Pieni tunniste tilalle, kategorialle tai metatiedolle. Kolme kokoa: Small, Medium, Large."
        (Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            [ Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s3, Tw.items_center ] ]
                [ Badge.view { label = "Gray", color = Badge.Gray, size = Badge.Medium }
                , Badge.view { label = "Blue", color = Badge.Blue, size = Badge.Medium }
                , Badge.view { label = "Green", color = Badge.Green, size = Badge.Medium }
                , Badge.view { label = "Yellow", color = Badge.Yellow, size = Badge.Medium }
                , Badge.view { label = "Red", color = Badge.Red, size = Badge.Medium }
                , Badge.view { label = "Purple", color = Badge.Purple, size = Badge.Medium }
                , Badge.view { label = "Indigo", color = Badge.Indigo, size = Badge.Medium }
                ]
            , Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s3, Tw.items_center ] ]
                [ Badge.view { label = "Small", color = Badge.Blue, size = Badge.Small }
                , Badge.view { label = "Medium", color = Badge.Blue, size = Badge.Medium }
                , Badge.view { label = "Large", color = Badge.Blue, size = Badge.Large }
                ]
            ]
        )
        """import Component.Badge as Badge

Badge.view { label = "Uusi", color = Badge.Green, size = Badge.Medium }"""
        (jsonLdSnippet "badge"
            "Badge"
            "Component.Badge"
            "Small inline label. Colors: Gray, Blue, Green, Yellow, Red, Purple, Indigo. Sizes: Small, Medium, Large."
            [ "label: String", "color: Color (Gray|Blue|Green|Yellow|Red|Purple|Indigo)", "size: Size (Small|Medium|Large)" ]
            []
        )



-- ── Breadcrumb ────────────────────────────────────────────────────────────────


viewBreadcrumb : Model -> Html (PagesMsg Msg)
viewBreadcrumb model =
    compCard model
        "Breadcrumb"
        "Navigointireittipolku sivuston rakenteen osoittamiseksi."
        (Breadcrumb.view
            [ { label = "Etusivu", href = Just "/" }
            , { label = "Ohjeistus", href = Just "/ohjeistus" }
            , { label = "Komponentit", href = Nothing }
            ]
        )
        """import Component.Breadcrumb as Breadcrumb

Breadcrumb.view
    [ { label = "Etusivu",     href = Just "/" }
    , { label = "Komponentit", href = Nothing }
    ]"""
        (jsonLdSnippet "breadcrumb"
            "Breadcrumb"
            "Component.Breadcrumb"
            "Navigation breadcrumb trail."
            [ "items: List { label: String, href: Maybe String }" ]
            []
        )



-- ── Button ────────────────────────────────────────────────────────────────────


viewButton : Model -> Html (PagesMsg Msg)
viewButton model =
    compCard model
        "Button"
        "Toimintopainike tai linkki-painike neljässä variantissa ja kolmessa koossa. Tukee disabled- ja loading-tiloja."
        (Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s3, Tw.items_center ] ]
                [ Button.viewLink { label = "Primary", variant = Button.Primary, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Secondary", variant = Button.Secondary, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Ghost", variant = Button.Ghost, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Danger", variant = Button.Danger, size = Button.Medium, href = "#" }
                ]
            , Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s3, Tw.items_center ] ]
                [ Button.viewLink { label = "Small", variant = Button.Primary, size = Button.Small, href = "#" }
                , Button.viewLink { label = "Medium", variant = Button.Primary, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Large", variant = Button.Primary, size = Button.Large, href = "#" }
                ]
            , Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s3, Tw.items_center ] ]
                [ Button.view { label = "Normal", variant = Button.Primary, size = Button.Medium, onClick = PagesMsg.fromMsg (SelectTab "Button" PreviewTab), disabled = False, loading = False, ariaPressedState = Nothing }
                , Button.view { label = "Disabled", variant = Button.Primary, size = Button.Medium, onClick = PagesMsg.fromMsg (SelectTab "Button" PreviewTab), disabled = True, loading = False, ariaPressedState = Nothing }
                , Button.view { label = "Lataa", variant = Button.Primary, size = Button.Medium, onClick = PagesMsg.fromMsg (SelectTab "Button" PreviewTab), disabled = False, loading = True, ariaPressedState = Nothing }
                ]
            ]
        )
        """import Component.Button as Button

-- Link-button (no Msg needed):
Button.viewLink
    { label = "Klikkaa", variant = Button.Primary
    , size = Button.Medium, href = "/sivu" }

-- Action button:
Button.view
    { label = "Lähetä", variant = Button.Primary
    , size = Button.Medium, onClick = SubmitForm
    , disabled = False, loading = False }"""
        (jsonLdSnippet "button"
            "Button"
            "Component.Button"
            "Action button or link-button. Variants: Primary, Secondary, Ghost, Danger."
            [ "label: String", "variant: Variant (Primary|Secondary|Ghost|Danger)", "size: Size (Small|Medium|Large)", "onClick: msg  OR  href: String", "disabled: Bool", "loading: Bool" ]
            [ "colors.semantic.background.accent" ]
        )


viewButtonSpec : Html msg
viewButtonSpec =
    Html.section
        [ Attr.id "button-spec"
        , classes [ TwEx.scroll_mt Th.s20, TwEx.space_y Th.s4 ]
        ]
        [ Html.h3
            [ classes [ Tw.text_base, Tw.font_semibold, Tw.text_simple TC.brand ] ]
            [ Html.text "Button — täydellinen tila-taulukko" ]
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_xs, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Variantti" ]
                        , Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Normaali" ]
                        , Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Hover" ]
                        , Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Focus-visible" ]
                        , Html.th [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.text_left, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Disabled" ]
                        ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
                    [ viewBtnSpecRow "Primary"
                        "bg-brand-yellow text-brand font-semibold"
                        "hover:opacity-90"
                        "focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2"
                        "opacity-40 cursor-not-allowed"
                    , viewBtnSpecRow "Secondary"
                        "bg-white border border-gray-300 text-brand font-semibold"
                        "hover:bg-gray-50"
                        "focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2"
                        "opacity-40 cursor-not-allowed"
                    , viewBtnSpecRow "Ghost"
                        "bg-transparent text-brand font-semibold"
                        "hover:bg-gray-100"
                        "focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2"
                        "opacity-40 cursor-not-allowed"
                    , viewBtnSpecRow "Danger"
                        "bg-red-600 text-white font-semibold"
                        "hover:bg-red-700"
                        "focus-visible:ring-2 focus-visible:ring-red-500 focus-visible:ring-offset-2"
                        "opacity-40 cursor-not-allowed"
                    ]
                ]
            ]
        , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            [ Html.div
                [ classes
                    [ Tw.border_l_4
                    , Tw.border_simple TC.brandYellow
                    , Tw.pl Th.s4
                    , Tw.py Th.s1
                    , TwEx.space_y Th.s1
                    ]
                ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text "focus-visible, ei focus" ]
                , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
                    [ Html.text "Käytä "
                    , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "focus-visible:" ]
                    , Html.text " eikä "
                    , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "focus:" ]
                    , Html.text " — selain piilottaa kohdistusrenkaan hiirellä klikatuista elementeistä automaattisesti, näyttää sen näppäimistönavigoinnissa."
                    ]
                ]
            , Html.div
                [ classes
                    [ Tw.border_l_4
                    , Tw.border_simple TC.brandYellow
                    , Tw.pl Th.s4
                    , Tw.py Th.s1
                    , TwEx.space_y Th.s1
                    ]
                ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text "aria-pressed — vaihto/toggle-painike" ]
                , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
                    [ Html.text "Suodatin- ja toggle-painikkeisiin täytyy lisätä "
                    , Html.code [ classes [ Tw.font_mono, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "aria-pressed" ]
                    , Html.text " -attribuutti, jotta ruudunlukija kertoo tilan."
                    ]
                , Html.pre
                    [ classes
                        [ Tw.bg_color (Th.gray Th.s900)
                        , Tw.text_color (Th.gray Th.s100)
                        , Tw.rounded_lg
                        , Tw.p Th.s3
                        , Tw.text_xs
                        , Tw.leading_relaxed
                        , Tw.overflow_x_auto
                        , Tw.mt Th.s2
                        ]
                    ]
                    [ Html.code []
                        [ Html.text """Html.button
    [ Attr.attribute "aria-pressed"
        (if model.active then "true" else "false")
    , Attr.class "..."
    ]
    [ Html.text "Suodata: Aktiiviset" ]""" ]
                    ]
                ]
            ]
        ]


viewBtnSpecRow : String -> String -> String -> String -> String -> Html msg
viewBtnSpecRow variant normal hover focus disabled =
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ], Tw.align_top ] ]
        [ Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_semibold, Tw.text_simple TC.brand ] ] [ Html.text variant ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text normal ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text hover ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text focus ]
        , Html.td [ classes [ Tw.py Th.s2, Tw.px Th.s3, Tw.font_mono, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text disabled ]
        ]



-- ── ButtonGroup ───────────────────────────────────────────────────────────────


viewButtonGroup : Model -> Html (PagesMsg Msg)
viewButtonGroup model =
    compCard model
        "ButtonGroup"
        "Vaakasuuntaisesti ryhmitellyt painikkeet jaetulla reunaviivalla."
        (ButtonGroup.view
            [ ButtonGroup.viewButton { label = "Vasen", onClick = SelectTab "ButtonGroup" PreviewTab, active = True, position = ButtonGroup.First }
                |> Html.map PagesMsg.fromMsg
            , ButtonGroup.viewButton { label = "Keski", onClick = SelectTab "ButtonGroup" PreviewTab, active = False, position = ButtonGroup.Middle }
                |> Html.map PagesMsg.fromMsg
            , ButtonGroup.viewEllipsis
            , ButtonGroup.viewButton { label = "Oikea", onClick = SelectTab "ButtonGroup" PreviewTab, active = False, position = ButtonGroup.Last }
                |> Html.map PagesMsg.fromMsg
            ]
        )
        """import Component.ButtonGroup as ButtonGroup

ButtonGroup.view
    [ ButtonGroup.viewButton
        { label = "Vasen", onClick = Msg
        , active = True, position = ButtonGroup.First }
    , ButtonGroup.viewButton
        { label = "Oikea", onClick = Msg
        , active = False, position = ButtonGroup.Last }
    ]"""
        (jsonLdSnippet "buttongroup"
            "ButtonGroup"
            "Component.ButtonGroup"
            "Horizontally grouped buttons sharing a border."
            [ "buttons: List (Html msg)" ]
            []
        )



-- ── Card ──────────────────────────────────────────────────────────────────────


viewCard : Model -> Html (PagesMsg Msg)
viewCard model =
    compCard model
        "Card"
        "Sisältösäiliö valinnaisella otsikolla, alatunnisteella ja varjolla."
        (Html.div
            [ classes
                [ Tw.grid
                , Tw.grid_cols_1
                , Bp.sm [ Tw.grid_cols_3 ]
                , Tw.gap Th.s4
                ]
            ]
            [ Card.viewSimple [ Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text "viewSimple" ] ]
            , Card.view
                { header = Just (Html.span [ classes [ Tw.font_semibold, Tw.text_simple TC.brand ] ] [ Html.text "Otsikko" ])
                , body = [ Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text "Kortti otsikolla." ] ]
                , footer = Just (Html.span [ classes [ Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text "Alatunniste" ])
                , image = Nothing
                , shadow = Card.Sm
                }
            , Card.view
                { header = Nothing
                , body = [ Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text "shadow = Md" ] ]
                , footer = Nothing
                , image = Nothing
                , shadow = Card.Md
                }
            ]
        )
        """import Component.Card as Card

Card.view
    { header = Just (Html.text "Otsikko")
    , body   = [ Html.text "Sisältö" ]
    , footer = Nothing
    , image  = Nothing
    , shadow = Card.Sm
    }"""
        (jsonLdSnippet "card"
            "Card"
            "Component.Card"
            "Content container with optional header, footer, image, shadow."
            [ "body: List (Html msg)", "header, footer: Maybe (Html msg)", "image: Maybe String", "shadow: Shadow (None|Sm|Md|Lg)" ]
            [ "colors.semantic.border.default" ]
        )



-- ── CloseButton ───────────────────────────────────────────────────────────────


viewCloseButton : Model -> Html (PagesMsg Msg)
viewCloseButton model =
    compCard model
        "CloseButton"
        "Saavutettava sulku/hylkäyspainike hälytyksissä, modaaleissa tai korteissa. Koskutusalue 44×44 px (WCAG 2.5.5)."
        (Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s4 ] ]
            [ CloseButton.view { onClick = SelectTab "CloseButton" PreviewTab, label = "Sulje" }
                |> Html.map PagesMsg.fromMsg
            , Html.span [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s400), Tw.inline_flex, Tw.items_center, Tw.gap Th.s1 ] ]
                [ FeatherIcons.arrowLeft
                    |> FeatherIcons.withSize 14
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text "Klikkaa (ei virhettä = OK)"
                ]
            ]
        )
        """import Component.CloseButton as CloseButton

CloseButton.view
    { onClick = CloseAlert
    , label = "Sulje ilmoitus"  -- aria-label
    }"""
        (jsonLdSnippet "closebutton"
            "CloseButton"
            "Component.CloseButton"
            "Accessible close/dismiss button with aria-label. 44×44 px touch target."
            [ "onClick: msg", "label: String (aria-label)" ]
            []
        )



-- ── Collapse ──────────────────────────────────────────────────────────────────


viewCollapse : Model -> Html (PagesMsg Msg)
viewCollapse model =
    compCard model
        "Collapse"
        "Yksittäinen tiivistettävä osio – natiivi <details>-pohjainen."
        (Html.div [ classes [ TwEx.space_y Th.s2 ] ]
            [ Collapse.view
                { summary = Html.text "Näytä lisätiedot"
                , body = [ Html.text "Tässä on piilotettua sisältöä, joka näytetään avattaessa." ]
                , open = False
                }
            , Collapse.view
                { summary = Html.text "Tämä on auki oletuksena"
                , body = [ Html.text "Käytä open = True kun haluat näyttää sisällön oletuksena." ]
                , open = True
                }
            ]
        )
        """import Component.Collapse as Collapse

Collapse.view
    { summary = Html.text "Lisätiedot"
    , body    = [ Html.text "Piilotettu sisältö" ]
    , open    = False
    }"""
        (jsonLdSnippet "collapse"
            "Collapse"
            "Component.Collapse"
            "Single collapsible section using native <details>/<summary>."
            [ "summary: Html msg", "body: List (Html msg)", "open: Bool" ]
            []
        )



-- ── Dialog ────────────────────────────────────────────────────────────────────


viewDialog : Model -> Html (PagesMsg Msg)
viewDialog model =
    compCard model
        "Dialog"
        "Modaali-ikkuna natiivin <dialog>-elementin päällä. Sulkeutuu Escape-näppäimellä ja CloseButton-painikkeesta."
        (Html.div [ classes [ Tw.flex, Tw.flex_col, Tw.gap Th.s4 ] ]
            [ Button.view
                { label = "Avaa modaali"
                , variant = Button.Primary
                , size = Button.Medium
                , onClick = PagesMsg.fromMsg OpenDialog
                , disabled = False
                , loading = False
                , ariaPressedState = Nothing
                }
            , Dialog.view
                { title = "Esimerkki-modaali"
                , body = [ Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text "Tämä on modaalin sisältö. Sulje Escape-näppäimellä tai X-painikkeella." ] ]
                , footer =
                    Just
                        (Html.div [ classes [ Tw.flex, Tw.justify_end, Tw.gap Th.s2 ] ]
                            [ Button.view { label = "Sulje", variant = Button.Secondary, size = Button.Medium, onClick = PagesMsg.fromMsg CloseDialog, disabled = False, loading = False, ariaPressedState = Nothing }
                            ]
                        )
                , isOpen = model.dialogOpen
                , onClose = PagesMsg.fromMsg CloseDialog
                }
            ]
        )
        """import Component.Dialog as Dialog

Dialog.view
    { title  = "Otsikko"
    , body   = [ Html.text "Sisältö" ]
    , footer = Just (Button.view { label = "OK", ... })
    , isOpen = model.dialogOpen
    , onClose = CloseDialog
    }"""
        (jsonLdSnippet "dialog"
            "Dialog"
            "Component.Dialog"
            "Modal dialog using native <dialog> element. Closes on Escape."
            [ "title: String", "body: List (Html msg)", "footer: Maybe (Html msg)", "isOpen: Bool", "onClose: msg" ]
            []
        )



-- ── Dropdown ──────────────────────────────────────────────────────────────────


viewDropdown : Model -> Html (PagesMsg Msg)
viewDropdown model =
    compCard model
        "Dropdown"
        "ARIA-pohjainen valikko — aria-haspopup, aria-expanded, role=menu/menuitem. Sulkeutuu Escape-näppäimellä."
        (Html.div [ classes [ Tw.flex, Tw.gap Th.s4, Tw.flex_wrap, Tw.items_start ] ]
            [ Dropdown.view
                { trigger = Html.text "Valikko"
                , items =
                    [ Dropdown.viewItem { label = "Ohjeistus", href = "/ohjeistus" }
                    , Dropdown.viewItem { label = "Komponentit", href = "/komponentit" }
                    , Dropdown.viewDivider
                    , Dropdown.viewItem { label = "design-guide/", href = "/design-guide/index.jsonld" }
                    ]
                , isOpen = model.dropdownOpen
                , onToggle = PagesMsg.fromMsg ToggleDropdown
                , onClose = PagesMsg.fromMsg CloseDropdown
                }
            ]
        )
        """import Component.Dropdown as Dropdown

Dropdown.view
    { trigger  = Html.text "Valikko"
    , items    =
        [ Dropdown.viewItem { label = "Sivu 1", href = "/sivu1" }
        , Dropdown.viewDivider
        , Dropdown.viewItem { label = "Sivu 2", href = "/sivu2" }
        ]
    , isOpen   = model.dropdownOpen
    , onToggle = ToggleDropdown
    , onClose  = CloseDropdown
    }"""
        (jsonLdSnippet "dropdown"
            "Dropdown"
            "Component.Dropdown"
            "ARIA menu dropdown with aria-haspopup, aria-expanded, role=menu. Closes on Escape."
            [ "trigger: Html msg", "items: List (Html msg)", "isOpen: Bool", "onToggle: msg", "onClose: msg" ]
            []
        )



-- ── ListGroup ─────────────────────────────────────────────────────────────────


viewListGroup : Model -> Html (PagesMsg Msg)
viewListGroup model =
    compCard model
        "ListGroup"
        "Pystysuora lista valinnaisilla tiloilla ja merkeillä."
        (ListGroup.view
            [ ListGroup.viewItem { label = "Logot", badge = Just "19" }
            , ListGroup.viewItem { label = "Värit", badge = Just "9" }
            , ListGroup.viewItem { label = "Komponentit", badge = Just "18" }
            , ListGroup.viewActionItem { label = "Aktiivinen kohde", onClick = SelectTab "ListGroup" PreviewTab, active = True }
                |> Html.map PagesMsg.fromMsg
            ]
        )
        """import Component.ListGroup as ListGroup

ListGroup.view
    [ ListGroup.viewItem
        { label = "Kohde", badge = Just "3" }
    , ListGroup.viewActionItem
        { label = "Aktiivinen", onClick = Msg, active = True }
    ]"""
        (jsonLdSnippet "listgroup"
            "ListGroup"
            "Component.ListGroup"
            "Vertical list with optional active states and badges."
            [ "items: List (Html msg)" ]
            [ "colors.semantic.border.default" ]
        )



-- ── Pagination ────────────────────────────────────────────────────────────────


viewPagination : Model -> Html (PagesMsg Msg)
viewPagination model =
    compCard model
        "Pagination"
        "Sivutuskomponentti numeroituine sivupainikkeineen."
        (Pagination.view
            { currentPage = 3
            , totalPages = 7
            , onPageClick = \_ -> SelectTab "Pagination" PreviewTab
            }
            |> Html.map PagesMsg.fromMsg
        )
        """import Component.Pagination as Pagination

Pagination.view
    { currentPage = model.page
    , totalPages  = totalPages
    , onPageClick = SetPage
    }"""
        (jsonLdSnippet "pagination"
            "Pagination"
            "Component.Pagination"
            "Page navigation control."
            [ "currentPage: Int", "totalPages: Int", "onPageClick: Int -> msg" ]
            []
        )



-- ── Placeholder ───────────────────────────────────────────────────────────────


viewPlaceholder : Model -> Html (PagesMsg Msg)
viewPlaceholder model =
    compCard model
        "Placeholder"
        "Animoitu latausluuranko sisältöä odotellessa."
        (Placeholder.view
            [ Placeholder.viewBlock { widthClass = [ Tw.w Th.s16 ], heightClass = [ Tw.h Th.s16 ] }
            , Placeholder.view
                [ Placeholder.viewLine { widthClass = [ Tw.w_3over4 ] }
                , Placeholder.viewLine { widthClass = [ Tw.w_full ] }
                , Placeholder.viewLine { widthClass = [ Tw.w_1over2 ] }
                ]
            ]
        )
        """import Component.Placeholder as Placeholder
import Tailwind as Tw
import Tailwind.Theme as Th

Placeholder.view
    [ Placeholder.viewBlock { widthClass = [ Tw.w (Th.s16) ], heightClass = [ Tw.h (Th.s16) ] }
    , Placeholder.viewLine { widthClass = [ Tw.w_full ] }
    , Placeholder.viewLine { widthClass = [ Tw.w_3over4 ] }
    ]"""
        (jsonLdSnippet "placeholder"
            "Placeholder"
            "Component.Placeholder"
            "Animated loading skeleton using CSS animate-pulse."
            [ "items: List (Html msg)" ]
            []
        )



-- ── Progress ──────────────────────────────────────────────────────────────────


viewProgress : Model -> Html (PagesMsg Msg)
viewProgress model =
    compCard model
        "Progress"
        "Vaakasuuntainen edistymisindikaattori."
        (Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ Progress.view { value = 75, max = 100, label = Just "Lataus", color = Progress.Brand }
            , Progress.view { value = 45, max = 100, label = Just "Onnistui", color = Progress.Success }
            , Progress.view { value = 30, max = 100, label = Just "Varoitus", color = Progress.Warning }
            , Progress.view { value = 60, max = 100, label = Nothing, color = Progress.Danger }
            ]
        )
        """import Component.Progress as Progress

Progress.view
    { value = 75
    , max   = 100
    , label = Just "Lataus"
    , color = Progress.Brand
    }"""
        (jsonLdSnippet "progress"
            "Progress"
            "Component.Progress"
            "Horizontal progress bar."
            [ "value: Int", "max: Int", "label: Maybe String", "color: Color (Brand|Success|Warning|Danger|Info)" ]
            []
        )



-- ── Spinner ───────────────────────────────────────────────────────────────────


viewSpinner : Model -> Html (PagesMsg Msg)
viewSpinner model =
    compCard model
        "Spinner"
        "Latausspinnerit kolmessa koossa."
        (Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s6, Tw.items_center ] ]
            [ Spinner.view { size = Spinner.Small, label = "Ladataan" }
            , Spinner.view { size = Spinner.Medium, label = "Ladataan" }
            , Spinner.view { size = Spinner.Large, label = "Ladataan" }
            ]
        )
        """import Component.Spinner as Spinner

Spinner.view
    { size  = Spinner.Medium
    , label = "Ladataan..."  -- sr-only aria label
    }"""
        (jsonLdSnippet "spinner"
            "Spinner"
            "Component.Spinner"
            "Loading spinner animation."
            [ "size: Size (Small|Medium|Large)", "label: String (sr-only)" ]
            []
        )



-- ── Stats ─────────────────────────────────────────────────────────────────────


viewStats : Model -> Html (PagesMsg Msg)
viewStats model =
    compCard model
        "Stats"
        "Mittareiden esittelyruudukko."
        (Stats.view
            [ Stats.viewItem { label = "Logovariantteja", value = "19", change = Nothing }
            , Stats.viewItem { label = "Ihonsävyjä", value = "4", change = Nothing }
            , Stats.viewItem { label = "Värejä", value = "9", change = Nothing }
            , Stats.viewItem { label = "Komponentteja", value = "22", change = Nothing }
            ]
        )
        """import Component.Stats as Stats

Stats.view
    [ Stats.viewItem
        { label  = "Käyttäjät"
        , value  = "1 024"
        , change = Just "+12%"
        }
    ]"""
        (jsonLdSnippet "stats"
            "Stats"
            "Component.Stats"
            "Metric display grid."
            [ "items: List { label: String, value: String, change: Maybe String }" ]
            [ "colors.semantic.text.muted" ]
        )



-- ── Tag ───────────────────────────────────────────────────────────────────────


viewTag : Model -> Html (PagesMsg Msg)
viewTag model =
    compCard model
        "Tag"
        "Kompakti inline-tunniste, jonka voi poistaa. Ei sisäistä tilaa."
        (Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s2, Tw.items_center ] ]
            [ Tag.view { label = "Elm", onRemove = Nothing }
            , Tag.view { label = "Haskell", onRemove = Nothing }
            , Tag.view { label = "Poistettava", onRemove = Just (PagesMsg.fromMsg (SelectTab "Tag" PreviewTab)) }
            , Tag.view { label = "Tailwind", onRemove = Just (PagesMsg.fromMsg (SelectTab "Tag" PreviewTab)) }
            ]
        )
        """import Component.Tag as Tag

-- Without remove button:
Tag.view { label = "Elm", onRemove = Nothing }

-- With remove button:
Tag.view { label = "Poistettava", onRemove = Just RemoveTag }"""
        (jsonLdSnippet "tag"
            "Tag"
            "Component.Tag"
            "Compact inline label, optionally removable."
            [ "label: String", "onRemove: Maybe msg" ]
            []
        )



-- ── Timeline ──────────────────────────────────────────────────────────────────


viewTimeline : Model -> Html (PagesMsg Msg)
viewTimeline model =
    compCard model
        "Timeline"
        "Pystysuora aikajana muutoslokeille ja versiohistorioille."
        (Timeline.view
            [ Timeline.viewItem { date = "2026", title = "Brändiohjeistus julkaistu", children = [ Html.text "JSON-LD-pohjainen koneluettava ohjeistus." ], icon = Nothing, image = Nothing }
            , Timeline.viewItem { date = "2025", title = "Haskell-pipeline uudistettu", children = [ Html.text "Puhdas Haskell-rasterointi." ], icon = Nothing, image = Nothing }
            , Timeline.viewItem { date = "2024", title = "Logo suunniteltu", children = [ Html.text "Minihahmon tiilimosaiikkilogo." ], icon = Nothing, image = Nothing }
            , Timeline.viewItem { date = "2026", title = "Tapahtuma", children = [ Html.text "Kalenterikuvake tapahtumalle." ], icon = Just (FeatherIcons.calendar |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml []), image = Nothing }
            , Timeline.viewItem { date = "2026", title = "Uutinen", children = [ Html.text "Megafonikuvake uutiselle." ], icon = Just (FeatherIcons.rss |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml []), image = Nothing }
            , Timeline.viewItem { date = "2026", title = "Tärkeä huomio", children = [ Html.text "Huutomerkkikuvake tärkeälle huomiolle." ], icon = Just (FeatherIcons.alertCircle |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml []), image = Nothing }
            , Timeline.viewItem { date = "2026", title = "Tähtihetki", children = [ Html.text "Tähtikuvake erityiselle saavutukselle." ], icon = Just (FeatherIcons.star |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml []), image = Nothing }
            , Timeline.viewItem { date = "2026", title = "Valmis", children = [ Html.text "Rasti valmistuneelle asialle." ], icon = Just (FeatherIcons.checkCircle |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml []), image = Nothing }
            , Timeline.viewItem { date = "2026", title = "Kuva oikealla", children = [ Html.text "Kohde, jossa kuva kelluu oikealla puolella." ], icon = Just (FeatherIcons.star |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml []), image = Just "/logo/square/png/square-basic.png" }
            ]
        )
        """import Component.Timeline as Timeline

Timeline.view
    [ Timeline.viewItem
        { date     = "2026"
        , title    = "Versio 1.0"
        , children = [ Html.text "Ensimmäinen julkaisu." ]
        , icon     = Nothing
        , image    = Nothing
        }
    , Timeline.viewItem
        { date     = "2026"
        , title    = "Tärkeä tapahtuma"
        , children = [ Html.text "Kuvakkeella ja kuvalla." ]
        , icon     = Just (FeatherIcons.calendar |> FeatherIcons.withSize 22 |> FeatherIcons.toHtml [])
        , image    = Just "/logo/square/png/square-basic.png"
        }
    ]"""
        (jsonLdSnippet "timeline"
            "Timeline"
            "Component.Timeline"
            "Vertical timeline for changelogs and version history."
            [ "items: List { date: String, title: String, children: List (Html msg), icon: Maybe (Html msg), image: Maybe String }" ]
            [ "colors.semantic.border.default" ]
        )



-- ── Toast ─────────────────────────────────────────────────────────────────────


viewToast : Model -> Html (PagesMsg Msg)
viewToast model =
    compCard model
        "Toast"
        "Ilmoitusviesti neljässä variantissa."
        (Html.div [ classes [ TwEx.space_y Th.s3 ] ]
            [ Toast.view { title = "Oletusviesti", body = "Neutraali ilmoitus.", variant = Toast.Default, onClose = Nothing }
            , Toast.view { title = "Onnistui", body = "Tallennus onnistui.", variant = Toast.Success, onClose = Nothing }
            , Toast.view { title = "Varoitus", body = "Tallennuksessa huomioita.", variant = Toast.Warning, onClose = Nothing }
            , Toast.view { title = "Virhe", body = "Tallennus epäonnistui.", variant = Toast.Danger, onClose = Just (SelectTab "Toast" PreviewTab) }
                |> Html.map PagesMsg.fromMsg
            ]
        )
        """import Component.Toast as Toast

Toast.view
    { title   = "Onnistui"
    , body    = "Tallennus onnistui."
    , variant = Toast.Success
    , onClose = Just DismissToast
    }"""
        (jsonLdSnippet "toast"
            "Toast"
            "Component.Toast"
            "Notification toast. Variants: Default, Success, Warning, Danger."
            [ "title: String", "body: String", "variant: Variant (Default|Success|Warning|Danger)", "onClose: Maybe msg" ]
            []
        )



-- ── Toggle ────────────────────────────────────────────────────────────────────


viewToggle : Model -> Html (PagesMsg Msg)
viewToggle model =
    compCard model
        "Toggle"
        "Boolen kytkin <input type=checkbox> -pohjaisena. Kutsuja omistaa tilan."
        (Html.div [ classes [ Tw.flex, Tw.flex_col, Tw.gap Th.s4 ] ]
            [ Toggle.view
                { id = "toggle-demo-1"
                , label = "Ilmoitukset käytössä"
                , checked = model.toggleChecked
                , onToggle = \v -> PagesMsg.fromMsg (ToggleChanged v)
                , disabled = False
                }
            , Toggle.view
                { id = "toggle-demo-2"
                , label = "Käytöstä poistettu"
                , checked = False
                , onToggle = \v -> PagesMsg.fromMsg (ToggleChanged v)
                , disabled = True
                }
            ]
        )
        """import Component.Toggle as Toggle

Toggle.view
    { id       = "notif-toggle"
    , label    = "Ilmoitukset"
    , checked  = model.notifEnabled
    , onToggle = NotifToggled  -- Bool -> msg
    , disabled = False
    }"""
        (jsonLdSnippet "toggle"
            "Toggle"
            "Component.Toggle"
            "Boolean toggle built on <input type=checkbox>. Caller owns state."
            [ "id: String", "label: String", "checked: Bool", "onToggle: Bool -> msg", "disabled: Bool" ]
            []
        )



-- ── Tooltip ───────────────────────────────────────────────────────────────────


viewTooltip : Model -> Html (PagesMsg Msg)
viewTooltip model =
    compCard model
        "Tooltip"
        "CSS-pohjainen tooltip — näkyy hover- ja focus-within-tiloissa. Ei Elm-tilaa."
        (Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s6, Tw.items_end ] ]
            [ Tooltip.view
                { content = "Ensisijainen toiminto"
                , children =
                    [ Button.view
                        { label = "Hover tai fokusoi"
                        , variant = Button.Primary
                        , size = Button.Medium
                        , onClick = PagesMsg.fromMsg (SelectTab "Tooltip" PreviewTab)
                        , disabled = False
                        , loading = False
                        , ariaPressedState = Nothing
                        }
                    ]
                }
            , Tooltip.view
                { content = "#FAC80A — brand yellow"
                , children =
                    [ ColorSwatch.view
                        { hex = "#FAC80A"
                        , name = "Yellow"
                        , description = ""
                        , usageTags = []
                        }
                    ]
                }
            ]
        )
        """import Component.Tooltip as Tooltip

Tooltip.view
    { content  = "Selitysteksti"
    , children = [ Button.view { ... } ]
    }"""
        (jsonLdSnippet "tooltip"
            "Tooltip"
            "Component.Tooltip"
            "CSS-only tooltip shown on hover and focus-within. No Elm state."
            [ "content: String", "children: List (Html msg)" ]
            []
        )



-- ── JSON-LD snippet helper ────────────────────────────────────────────────────


jsonLdSnippet :
    String
    -> String
    -> String
    -> String
    -> List String
    -> List String
    -> String
jsonLdSnippet slug name_ elmModule description props deps =
    let
        propsStr =
            props
                |> List.map (\p -> "    \"" ++ p ++ "\"")
                |> String.join ",\n"

        depsStr =
            if List.isEmpty deps then
                "[]"

            else
                "[\n"
                    ++ (deps
                            |> List.map (\d -> "    \"" ++ d ++ "\"")
                            |> String.join ",\n"
                       )
                    ++ "\n  ]"
    in
    "{\n"
        ++ "  \"@context\": \"https://logo.palikkaharrastajat.fi/design-guide/context.jsonld\",\n"
        ++ "  \"@type\": \"ComponentSpec\",\n"
        ++ "  \"@id\": \"https://logo.palikkaharrastajat.fi/design-guide/components.jsonld#"
        ++ slug
        ++ "\",\n"
        ++ "  \"name\": \""
        ++ name_
        ++ "\",\n"
        ++ "  \"elmModule\": \""
        ++ elmModule
        ++ "\",\n"
        ++ "  \"description\": \""
        ++ description
        ++ "\",\n"
        ++ "  \"props\": [\n"
        ++ propsStr
        ++ "\n  ],\n"
        ++ "  \"tokenDeps\": "
        ++ depsStr
        ++ "\n}"



-- ── Toolbar ───────────────────────────────────────────────────────────────────


viewToolbar : Html (PagesMsg Msg)
viewToolbar =
    Html.section
        [ Attr.id "toolbar"
        , classes
            [ TwEx.scroll_mt Th.s28
            , TwEx.space_y Th.s8
            , Bp.sm [ TwEx.space_y Th.s10 ]
            ]
        ]
        [ Html.h2
            [ classes
                [ Tw.text_xl
                , Bp.sm [ Tw.text_2xl ]
                , Tw.font_bold
                , Tw.text_simple TC.brand
                ]
            ]
            [ Html.text "Toolbar-vaihtoehdot" ]
        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
            [ Html.text "Kaksi virallista toolbar-mallia. Tumma toolbar on suositeltava uusille projekteille." ]
        , viewDarkToolbar
        , viewLightToolbar
        ]


viewDarkToolbar : Html (PagesMsg Msg)
viewDarkToolbar =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "1. Tumma toolbar — neliölogo (suositus)"
            , description = Just "Referenssitoteutus: planet. Korkeus h-14, bg-brand, sticky. Käytä uusissa projekteissa."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200) ] ]
            [ Html.div
                [ classes
                    [ Tw.flex
                    , Tw.items_center
                    , Tw.justify_between
                    , Tw.px Th.s4
                    , Tw.h Th.s14
                    , Tw.bg_simple TC.brand
                    ]
                ]
                [ Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
                    [ Html.img
                        [ Attr.src "/logo/square/square-smile.svg"
                        , Attr.alt ""
                        , Attr.attribute "aria-hidden" "true"
                        , classes [ Tw.h Th.s8, Tw.w Th.s8 ]
                        ]
                        []
                    , Html.span [ classes [ Tw.text_lg, Tw.font_bold, Tw.text_simple Th.white ] ] [ Html.text "Sivuston nimi" ]
                    ]
                , Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s4 ] ]
                    [ Html.span [ classes [ TwEx.text_white_80, Bp.hover [ Tw.text_simple Th.white ], Tw.font_medium, Tw.text_sm, Tw.cursor_pointer ] ] [ Html.text "Etusivu" ]
                    , Html.span [ classes [ TwEx.text_white_80, Bp.hover [ Tw.text_simple Th.white ], Tw.font_medium, Tw.text_sm, Tw.cursor_pointer ] ] [ Html.text "Tapahtumat" ]
                    ]
                ]
            , Html.div [ classes [ Tw.bg_simple Th.white, Tw.p Th.s4, Tw.text_sm, Tw.text_color (Th.gray Th.s500), Tw.flex, Tw.items_center, Tw.gap Th.s1 ] ]
                [ FeatherIcons.arrowUp
                    |> FeatherIcons.withSize 14
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text "Esikatselu — h-14, bg-brand (#05131D), neliölogo 32×32 px, linkit text-white/80"
                ]
            ]
        , Html.div [ classes [ TwEx.space_y Th.s2 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "HTML" ]
            , Html.pre
                [ classes
                    [ Tw.bg_color (Th.gray Th.s900)
                    , Tw.text_color (Th.gray Th.s100)
                    , Tw.rounded_lg
                    , Tw.p Th.s4
                    , Tw.text_xs
                    , Tw.leading_relaxed
                    , Tw.overflow_x_auto
                    ]
                ]
                [ Html.code []
                    [ Html.text """<nav class="bg-brand border-b border-brand sticky top-0 z-50">
  <div class="flex items-center justify-between px-4 h-14">
    <a href="/" class="flex items-center gap-2">
      <img src="/logo/square/square-smile.svg" aria-hidden="true" class="h-8 w-8">
      <span class="text-lg font-bold text-white">Sivuston nimi</span>
    </a>
    <div class="hidden md:flex items-center gap-6">
      <a href="/" class="text-white/80 hover:text-white font-medium text-sm">Etusivu</a>
      <a href="/tapahtumat" class="text-white/80 hover:text-white font-medium text-sm">Tapahtumat</a>
    </div>
    <!-- hamburger (md:hidden) -->
  </div>
</nav>""" ]
                ]
            ]
        ]


viewLightToolbar : Html (PagesMsg Msg)
viewLightToolbar =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "2. Vaakalogo toolbar (vaihtoehto)"
            , description = Just "Vaihtoehto, jos projekti tarvitsee vaakalogon. Myös bg-brand, h-14."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200) ] ]
            [ Html.div
                [ classes
                    [ Tw.flex
                    , Tw.items_center
                    , Tw.justify_between
                    , Tw.px Th.s4
                    , Tw.h Th.s14
                    , Tw.bg_simple TC.brand
                    ]
                ]
                [ Html.node "picture"
                    []
                    [ Html.node "source"
                        [ Attr.attribute "type" "image/svg+xml"
                        , Attr.attribute "srcset" "/logo/horizontal/svg/horizontal-full-dark.svg"
                        ]
                        []
                    , Html.img
                        [ Attr.src "/logo/horizontal/svg/horizontal.svg"
                        , Attr.alt "Suomen Palikkaharrastajat ry"
                        , classes [ Tw.h Th.s10 ]
                        ]
                        []
                    ]
                , Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s4 ] ]
                    [ Html.span [ classes [ TwEx.text_white_80, Tw.font_medium, Tw.text_sm, Tw.cursor_pointer ] ] [ Html.text "Etusivu" ]
                    ]
                ]
            , Html.div [ classes [ Tw.bg_simple Th.white, Tw.p Th.s4, Tw.text_sm, Tw.text_color (Th.gray Th.s500), Tw.flex, Tw.items_center, Tw.gap Th.s1 ] ]
                [ FeatherIcons.arrowUp
                    |> FeatherIcons.withSize 14
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text "Esikatselu — h-14, bg-brand, vaakalogo h-10, picture-elementti (SVG + PNG)"
                ]
            ]
        , Html.div [ classes [ TwEx.space_y Th.s2 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "HTML" ]
            , Html.pre
                [ classes
                    [ Tw.bg_color (Th.gray Th.s900)
                    , Tw.text_color (Th.gray Th.s100)
                    , Tw.rounded_lg
                    , Tw.p Th.s4
                    , Tw.text_xs
                    , Tw.leading_relaxed
                    , Tw.overflow_x_auto
                    ]
                ]
                [ Html.code []
                    [ Html.text """<nav class="bg-brand border-b border-brand sticky top-0 z-50">
  <div class="flex items-center justify-between px-4 h-14">
    <a href="/" class="shrink-0">
      <picture>
        <source type="image/svg+xml" srcset="/logo/horizontal/svg/horizontal-full-dark.svg">
        <img src="/logo/horizontal/png/horizontal-full.png"
             alt="Suomen Palikkaharrastajat ry" class="h-10 w-auto">
      </picture>
    </a>
    <div class="hidden md:flex items-center gap-6">
      <a href="/" class="text-white/80 hover:text-white font-medium text-sm">Etusivu</a>
    </div>
  </div>
</nav>""" ]
                ]
            ]
        ]



-- ── Sivupohjat ────────────────────────────────────────────────────────────────


viewSivupohjat : Html (PagesMsg Msg)
viewSivupohjat =
    Html.section
        [ Attr.id "sivupohjat"
        , classes
            [ TwEx.scroll_mt Th.s28
            , TwEx.space_y Th.s8
            , Bp.sm [ TwEx.space_y Th.s10 ]
            ]
        ]
        [ Html.h2
            [ classes
                [ Tw.text_xl
                , Bp.sm [ Tw.text_2xl ]
                , Tw.font_bold
                , Tw.text_simple TC.brand
                ]
            ]
            [ Html.text "Sivupohjat" ]
        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text "Valmiit sivupohjakomponentit: Hero, Navbar, FeatureGrid, Footer, Pricing. Sopivat suoraan uusille sivustoille." ]
        , viewHeroComp
        , viewNavbarComp
        , viewFeatureGridComp
        , viewFooterComp
        , viewPricingComp
        ]


viewHeroComp : Html (PagesMsg Msg)
viewHeroComp =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Hero"
            , description = Just "Sivun yläosan hero-osio. Otsikko, alaotsikko ja CTA-nappulat."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200) ] ]
            [ Hero.view
                { title = "Tervetuloa!"
                , subtitle = Just "Lyhyt kuvaus sivustosta tai palvelusta."
                , cta =
                    [ Button.viewLink { label = "Aloita", variant = Button.Primary, size = Button.Large, href = "#" }
                    , Button.viewLink { label = "Lue lisää", variant = Button.Ghost, size = Button.Large, href = "#" }
                    ]
                }
            ]
        , Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.gray Th.s100)
                , Tw.rounded_lg
                , Tw.p Th.s4
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code []
                [ Html.text """import Component.Hero as Hero

Hero.view
    { title    = "Tervetuloa!"
    , subtitle = Just "Lyhyt kuvaus."
    , cta      = [ Button.viewLink { label = "Aloita", ... } ]
    }""" ]
            ]
        ]


viewNavbarComp : Html (PagesMsg Msg)
viewNavbarComp =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Navbar"
            , description = Just "Yksinkertainen vaalea navigaatiopalkki. Logolle, linkeille ja toimintopainikkeelle."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200) ] ]
            [ Navbar.view
                { logo = Html.span [ classes [ Tw.font_bold, Tw.text_simple TC.brand, Tw.text_lg ] ] [ Html.text "Logo" ]
                , links =
                    [ { label = "Etusivu", href = "#" }
                    , { label = "Tapahtumat", href = "#" }
                    , { label = "Yhteystiedot", href = "#" }
                    ]
                , action = Just (Button.viewLink { label = "Kirjaudu", variant = Button.Primary, size = Button.Small, href = "#" })
                }
            ]
        , Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.gray Th.s100)
                , Tw.rounded_lg
                , Tw.p Th.s4
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code []
                [ Html.text """import Component.Navbar as Navbar

Navbar.view
    { logo   = Html.img [ Attr.src "/logo.svg" ] []
    , links  = [ { label = "Etusivu", href = "/" } ]
    , action = Just (Button.viewLink { label = "Kirjaudu", ... })
    }""" ]
            ]
        ]


viewFeatureGridComp : Html (PagesMsg Msg)
viewFeatureGridComp =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "FeatureGrid"
            , description = Just "Ominaisuuksien esittelyruudukko. 2–4 saraketta."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200), Tw.bg_simple Th.white ] ]
            [ FeatureGrid.view
                { columns = 3
                , features =
                    [ { icon = Just "🧱", title = "Helppo aloittaa", description = [ Html.text "Kopioi komponentit ja käytä heti." ] }
                    , { icon = Just "🎨", title = "Yhtenäinen ilme", description = [ Html.text "Kaikki noudattavat samaa design-tokenia." ] }
                    , { icon = Just "♿", title = "Saavutettava", description = [ Html.text "WCAG 2.1 AA -tason fokusrenkaat ja ARIA." ] }
                    ]
                }
            ]
        , Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.gray Th.s100)
                , Tw.rounded_lg
                , Tw.p Th.s4
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code []
                [ Html.text """import Component.FeatureGrid as FeatureGrid

FeatureGrid.view
    { columns  = 3
    , features =
        [ { icon = Just "🧱", title = "Otsikko"
          , description = [ Html.text "Kuvaus." ] }
        ]
    }""" ]
            ]
        ]


viewFooterComp : Html (PagesMsg Msg)
viewFooterComp =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Footer"
            , description = Just "Sivun alatunniste linkkiryhmillä ja copyright-tekstillä."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200) ] ]
            [ Footer.view
                { groups =
                    [ { heading = "Palvelut"
                      , links = [ { label = "Kotisivut", href = "#" }, { label = "Kalenteri", href = "#" } ]
                      }
                    , { heading = "Yhdistys"
                      , links = [ { label = "Tietoa meistä", href = "#" }, { label = "Yhteystiedot", href = "#" } ]
                      }
                    ]
                , copyright = "© 2026 Suomen Palikkaharrastajat ry"
                }
            ]
        , Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.gray Th.s100)
                , Tw.rounded_lg
                , Tw.p Th.s4
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code []
                [ Html.text """import Component.Footer as Footer

Footer.view
    { groups =
        [ { heading = "Palvelut"
          , links   = [ { label = "Kotisivut", href = "/" } ]
          }
        ]
    , copyright = "© 2026 Organisaatio"
    }""" ]
            ]
        ]


viewPricingComp : Html (PagesMsg Msg)
viewPricingComp =
    Html.div [ classes [ TwEx.space_y Th.s4 ] ]
        [ SectionHeader.viewSub
            { title = "Pricing"
            , description = Just "Hinnoitteluruudukko. Yksi taso voidaan nostaa esiin (highlighted)."
            }
        , Html.div [ classes [ Tw.rounded_xl, Tw.overflow_hidden, Tw.border, Tw.border_color (Th.gray Th.s200), Tw.bg_simple Th.white ] ]
            [ Pricing.view
                [ { name = "Ilmainen"
                  , price = "0 €"
                  , period = Just "kk"
                  , features = [ "Ominaisuus A", "Ominaisuus B" ]
                  , cta = Button.viewLink { label = "Aloita ilmaiseksi", variant = Button.Secondary, size = Button.Medium, href = "#" }
                  , highlighted = False
                  }
                , { name = "Pro"
                  , price = "9 €"
                  , period = Just "kk"
                  , features = [ "Kaikki ilmaiset", "Ominaisuus C", "Prioriteettituki" ]
                  , cta = Button.viewLink { label = "Valitse Pro", variant = Button.Primary, size = Button.Medium, href = "#" }
                  , highlighted = True
                  }
                ]
            ]
        , Html.pre
            [ classes
                [ Tw.bg_color (Th.gray Th.s900)
                , Tw.text_color (Th.gray Th.s100)
                , Tw.rounded_lg
                , Tw.p Th.s4
                , Tw.text_xs
                , Tw.leading_relaxed
                , Tw.overflow_x_auto
                ]
            ]
            [ Html.code []
                [ Html.text """import Component.Pricing as Pricing

Pricing.view
    [ { name = "Pro", price = "9 €", period = Just "kk"
      , features = [ "Ominaisuus" ]
      , cta = Button.viewLink { ... }
      , highlighted = True
      }
    ]""" ]
            ]
        ]
