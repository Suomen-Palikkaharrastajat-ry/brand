module Route.Komponentit exposing (ActionData, Data, Model, Msg, route)

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
import Component.ListGroup as ListGroup
import Component.Pagination as Pagination
import Component.Placeholder as Placeholder
import Component.Progress as Progress
import Component.Spinner as Spinner
import Component.Stats as Stats
import Component.Tag as Tag
import Component.Tabs as Tabs
import Component.Timeline as Timeline
import Component.Toast as Toast
import Component.Toggle as Toggle
import Component.Tooltip as Tooltip
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App)
import Shared
import SiteMeta
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
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-12 space-y-6" ]
            [ Html.div [ Attr.class "space-y-2" ]
                [ Html.h1 [ Attr.class "text-3xl font-bold text-brand" ]
                    [ Html.text "Komponentit" ]
                , Html.p [ Attr.class "text-gray-500" ]
                    [ Html.text "Kaikki komponentit hakemistossa "
                    , Html.code [ Attr.class "font-mono text-sm bg-gray-100 px-1 rounded" ]
                        [ Html.text "src/Component/" ]
                    , Html.text ". Koneluettava: "
                    , Html.a
                        [ Attr.href "/design-guide/components.jsonld"
                        , Attr.class "underline hover:text-brand transition-colors font-mono text-sm"
                        ]
                        [ Html.text "components.jsonld" ]
                    , Html.text "."
                    ]
                ]
            , viewCompIndex
            , viewConventions
            , Html.div [ Attr.class "space-y-16 pt-4" ]
                [ viewAlert model
                , viewAccordion model
                , viewBadge model
                , viewBreadcrumb model
                , viewButton model
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
                ]
            ]
        ]
    }


viewConventions : Html (PagesMsg Msg)
viewConventions =
    Html.div
        [ Attr.class "bg-blue-50 border border-blue-200 rounded-lg p-4 text-sm text-blue-900 space-y-2" ]
        [ Html.p [ Attr.class "font-semibold" ] [ Html.text "UI-konventiot" ]
        , Html.ul [ Attr.class "list-disc list-inside space-y-1 text-blue-800" ]
            [ Html.li [] [ Html.text "Kaikilla painikemaisilla elementeillä tulee olla ", Html.code [ Attr.class "font-mono bg-blue-100 px-1 rounded" ] [ Html.text "cursor-pointer" ], Html.text " — myös ButtonGroup, CloseButton, Pagination ja ListGroup." ]
            , Html.li [] [ Html.text "Poistettu/disabled-tila käyttää ", Html.code [ Attr.class "font-mono bg-blue-100 px-1 rounded" ] [ Html.text "cursor-not-allowed" ], Html.text "." ]
            , Html.li [] [ Html.text "Kaikki interaktiiviset elementit tarjoavat ", Html.code [ Attr.class "font-mono bg-blue-100 px-1 rounded" ] [ Html.text "focus:ring-2 focus:ring-brand" ], Html.text " näppäimistökäyttöä varten." ]
            ]
        ]


viewCompIndex : Html (PagesMsg Msg)
viewCompIndex =
    Html.nav [ Attr.class "flex flex-wrap gap-2" ]
        (List.map
            (\name ->
                Html.a
                    [ Attr.href ("#" ++ String.toLower name)
                    , Attr.class "px-3 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-600 hover:bg-brand hover:text-white transition-colors"
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
        , Attr.class "scroll-mt-20 space-y-3"
        ]
        [ Html.div [ Attr.class "flex items-baseline justify-between flex-wrap gap-2" ]
            [ Html.h2 [ Attr.class "text-xl font-bold text-brand" ] [ Html.text name ]
            , Html.span [ Attr.class "text-sm text-gray-400 font-mono" ]
                [ Html.text ("Component." ++ name) ]
            ]
        , Html.p [ Attr.class "text-sm text-gray-500" ] [ Html.text description ]
        , Tabs.view
            { tabs = [ "Esikatselu", "Elm-koodi", "JSON-LD" ]
            , activeIndex = tabIndex (activeTab model name)
            , onTabClick =
                \i -> PagesMsg.fromMsg (SelectTab name (tabFromIndex i))
            , panels =
                [ Html.div [ Attr.class "p-6 bg-gray-50 rounded-lg border border-gray-200" ]
                    [ preview ]
                , codePanel elmCode
                , jsonPanel jsonLd
                ]
            }
        ]


codePanel : String -> Html msg
codePanel src =
    Html.div [ Attr.class "overflow-x-auto" ]
        [ Html.pre
            [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-5 text-xs leading-relaxed overflow-x-auto" ]
            [ Html.code [] [ Html.text src ] ]
        ]


jsonPanel : String -> Html msg
jsonPanel src =
    Html.div [ Attr.class "overflow-x-auto" ]
        [ Html.pre
            [ Attr.class "bg-gray-900 text-emerald-300 rounded-lg p-5 text-xs leading-relaxed overflow-x-auto" ]
            [ Html.code [] [ Html.text src ] ]
        ]



-- ── Alert ─────────────────────────────────────────────────────────────────────


viewAlert : Model -> Html (PagesMsg Msg)
viewAlert model =
    compCard model
        "Alert"
        "Kontekstuaalinen palauteviesti neljässä tyypissä. Tukee myös suljettavaa varianttia (onDismiss)."
        (Html.div [ Attr.class "space-y-3" ]
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
        (Html.div [ Attr.class "space-y-3" ]
            [ Html.div [ Attr.class "flex flex-wrap gap-3 items-center" ]
                [ Badge.view { label = "Gray", color = Badge.Gray, size = Badge.Medium }
                , Badge.view { label = "Blue", color = Badge.Blue, size = Badge.Medium }
                , Badge.view { label = "Green", color = Badge.Green, size = Badge.Medium }
                , Badge.view { label = "Yellow", color = Badge.Yellow, size = Badge.Medium }
                , Badge.view { label = "Red", color = Badge.Red, size = Badge.Medium }
                , Badge.view { label = "Purple", color = Badge.Purple, size = Badge.Medium }
                , Badge.view { label = "Indigo", color = Badge.Indigo, size = Badge.Medium }
                ]
            , Html.div [ Attr.class "flex flex-wrap gap-3 items-center" ]
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
        (Html.div [ Attr.class "space-y-4" ]
            [ Html.div [ Attr.class "flex flex-wrap gap-3 items-center" ]
                [ Button.viewLink { label = "Primary", variant = Button.Primary, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Secondary", variant = Button.Secondary, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Ghost", variant = Button.Ghost, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Danger", variant = Button.Danger, size = Button.Medium, href = "#" }
                ]
            , Html.div [ Attr.class "flex flex-wrap gap-3 items-center" ]
                [ Button.viewLink { label = "Small", variant = Button.Primary, size = Button.Small, href = "#" }
                , Button.viewLink { label = "Medium", variant = Button.Primary, size = Button.Medium, href = "#" }
                , Button.viewLink { label = "Large", variant = Button.Primary, size = Button.Large, href = "#" }
                ]
            , Html.div [ Attr.class "flex flex-wrap gap-3 items-center" ]
                [ Button.view { label = "Normal", variant = Button.Primary, size = Button.Medium, onClick = PagesMsg.fromMsg (SelectTab "Button" PreviewTab), disabled = False, loading = False }
                , Button.view { label = "Disabled", variant = Button.Primary, size = Button.Medium, onClick = PagesMsg.fromMsg (SelectTab "Button" PreviewTab), disabled = True, loading = False }
                , Button.view { label = "Lataa", variant = Button.Primary, size = Button.Medium, onClick = PagesMsg.fromMsg (SelectTab "Button" PreviewTab), disabled = False, loading = True }
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
        (Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-3 gap-4" ]
            [ Card.viewSimple [ Html.p [ Attr.class "text-sm text-gray-600" ] [ Html.text "viewSimple" ] ]
            , Card.view
                { header = Just (Html.span [ Attr.class "font-semibold text-brand" ] [ Html.text "Otsikko" ])
                , body = [ Html.p [ Attr.class "text-sm text-gray-600" ] [ Html.text "Kortti otsikolla." ] ]
                , footer = Just (Html.span [ Attr.class "text-xs text-gray-400" ] [ Html.text "Alatunniste" ])
                , image = Nothing
                , shadow = Card.Sm
                }
            , Card.view
                { header = Nothing
                , body = [ Html.p [ Attr.class "text-sm text-gray-600" ] [ Html.text "shadow = Md" ] ]
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
        (Html.div [ Attr.class "flex items-center gap-4" ]
            [ CloseButton.view { onClick = SelectTab "CloseButton" PreviewTab, label = "Sulje" }
                |> Html.map PagesMsg.fromMsg
            , Html.span [ Attr.class "text-sm text-gray-400" ] [ Html.text "← Klikkaa (ei virhettä = OK)" ]
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
        (Html.div [ Attr.class "space-y-2" ]
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
        (Html.div [ Attr.class "flex flex-col gap-4" ]
            [ Button.view
                { label = "Avaa modaali"
                , variant = Button.Primary
                , size = Button.Medium
                , onClick = PagesMsg.fromMsg OpenDialog
                , disabled = False
                , loading = False
                }
            , Dialog.view
                { title = "Esimerkki-modaali"
                , body = [ Html.p [ Attr.class "text-sm text-gray-600" ] [ Html.text "Tämä on modaalin sisältö. Sulje Escape-näppäimellä tai X-painikkeella." ] ]
                , footer =
                    Just
                        (Html.div [ Attr.class "flex justify-end gap-2" ]
                            [ Button.view { label = "Sulje", variant = Button.Secondary, size = Button.Medium, onClick = PagesMsg.fromMsg CloseDialog, disabled = False, loading = False }
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
        (Html.div [ Attr.class "flex gap-4 flex-wrap items-start" ]
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
            [ Placeholder.viewBlock { widthClass = "w-16", heightClass = "h-16" }
            , Placeholder.view
                [ Placeholder.viewLine { widthClass = "w-3/4" }
                , Placeholder.viewLine { widthClass = "w-full" }
                , Placeholder.viewLine { widthClass = "w-1/2" }
                ]
            ]
        )
        """import Component.Placeholder as Placeholder

Placeholder.view
    [ Placeholder.viewBlock { widthClass = "w-16", heightClass = "h-16" }
    , Placeholder.viewLine { widthClass = "w-full" }
    , Placeholder.viewLine { widthClass = "w-3/4" }
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
        (Html.div [ Attr.class "space-y-4" ]
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
        (Html.div [ Attr.class "flex flex-wrap gap-6 items-center" ]
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
        (Html.div [ Attr.class "flex flex-wrap gap-2 items-center" ]
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
            [ Timeline.viewItem { date = "2026", title = "Brändiohjeistus julkaistu", children = [ Html.text "JSON-LD-pohjainen koneluettava ohjeistus." ], icon = Nothing }
            , Timeline.viewItem { date = "2025", title = "Haskell-pipeline uudistettu", children = [ Html.text "Puhdas Haskell-rasterointi." ], icon = Nothing }
            , Timeline.viewItem { date = "2024", title = "Logo suunniteltu", children = [ Html.text "Minihahmon tiilimosaiikkilogo." ], icon = Nothing }
            , Timeline.viewItem { date = "2026", title = "Tapahtuma", children = [ Html.text "Kuvake: tapahtuma (⊙)." ], icon = Just "⊙" }
            , Timeline.viewItem { date = "2026", title = "Uutinen", children = [ Html.text "Kuvake: uutinen (◆)." ], icon = Just "◆" }
            , Timeline.viewItem { date = "2026", title = "Huomio", children = [ Html.text "Kuvake: huutomerkki (!)." ], icon = Just "!" }
            , Timeline.viewItem { date = "2026", title = "Tärkeä", children = [ Html.text "Kuvake: tähti (★)." ], icon = Just "★" }
            , Timeline.viewItem { date = "2026", title = "Valmis", children = [ Html.text "Kuvake: valmis (✓)." ], icon = Just "✓" }
            ]
        )
        """import Component.Timeline as Timeline

Timeline.view
    [ Timeline.viewItem
        { date     = "2026"
        , title    = "Versio 1.0"
        , children = [ Html.text "Ensimmäinen julkaisu." ]
        , icon     = Nothing
        }
    , Timeline.viewItem
        { date     = "2026"
        , title    = "Tärkeä tapahtuma"
        , children = [ Html.text "Kuvakkeella." ]
        , icon     = Just "★"
        }
    ]"""
        (jsonLdSnippet "timeline"
            "Timeline"
            "Component.Timeline"
            "Vertical timeline for changelogs and version history."
            [ "items: List { date: String, title: String, children: List (Html msg), icon: Maybe String }" ]
            [ "colors.semantic.border.default" ]
        )



-- ── Toast ─────────────────────────────────────────────────────────────────────


viewToast : Model -> Html (PagesMsg Msg)
viewToast model =
    compCard model
        "Toast"
        "Ilmoitusviesti neljässä variantissa."
        (Html.div [ Attr.class "space-y-3" ]
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
        (Html.div [ Attr.class "flex flex-col gap-4" ]
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
        (Html.div [ Attr.class "flex flex-wrap gap-6 items-end" ]
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
                        }
                    ]
                }
            , Tooltip.view
                { content = "#F2CD37 — brand yellow"
                , children =
                    [ ColorSwatch.view
                        { hex = "#F2CD37"
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
