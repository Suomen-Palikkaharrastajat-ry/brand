module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Browser.Events
import Component.MobileDrawer as MobileDrawer
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import FeatherIcons
import Html exposing (Html)
import Ports
import Html.Attributes as Attr
import Html.Events
import Json.Decode
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type alias Data =
    ()


type SharedMsg
    = NoOp
    | ToggleMenu
    | CloseMenu


type Msg
    = SharedMsg SharedMsg


type alias Model =
    { menuOpen : Bool }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : Maybe Route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init _ _ =
    ( { menuOpen = False }, Effect.none )


update : Msg -> Model -> ( Model, Effect msg )
update msg model =
    case msg of
        SharedMsg ToggleMenu ->
            if model.menuOpen then
                ( { model | menuOpen = False }, Effect.none )

            else
                ( { model | menuOpen = True }, Effect.fromCmd (Ports.focusMobileNav ()) )

        SharedMsg CloseMenu ->
            ( { model | menuOpen = False }, Effect.none )

        SharedMsg _ ->
            ( model, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ model =
    if model.menuOpen then
        Browser.Events.onKeyDown
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if key == "Escape" then
                            Json.Decode.succeed (SharedMsg CloseMenu)

                        else
                            Json.Decode.fail "not escape"
                    )
            )

    else
        Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    -> { path : UrlPath, route : Maybe Route }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view _ page model toMsg pageView =
    { title = pageView.title
    , body =
        [ Html.div [ Attr.class "min-h-screen flex flex-col font-sans" ]
            [ viewNavbar model (toMsg << SharedMsg)
            , Html.main_ [ Attr.class "flex-1" ] pageView.body
            , viewFooter
            , MobileDrawer.viewOverlay { isOpen = model.menuOpen, onClose = toMsg (SharedMsg CloseMenu), breakpoint = MobileDrawer.Sm }
            , viewMobileDrawer page.path model (toMsg << SharedMsg)
            ]
        ]
    }


viewNavbar : Model -> (SharedMsg -> msg) -> Html msg
viewNavbar model toMsg =
    Html.nav
        [ Attr.class "bg-brand sticky top-0 z-50 shadow-md" ]
        [ Html.div
            [ Attr.class "max-w-5xl mx-auto px-4" ]
            [ Html.div
                [ Attr.class "flex items-center py-2 sm:py-3" ]
                [ Html.a
                    [ Attr.href "/"
                    , Attr.class "flex-shrink-0 mr-auto focus:outline-none focus:ring-2 focus:ring-brand-yellow rounded"
                    , Html.Events.onClick (toMsg CloseMenu)
                    ]
                    [ Html.node "picture"
                        []
                        [ Html.node "source"
                            [ Attr.attribute "media" "(min-width: 640px)"
                            , Attr.attribute "srcset" "/logo/horizontal/svg/horizontal-full-dark.svg"
                            ]
                            []
                        , Html.img
                            [ Attr.src "/logo/horizontal/svg/horizontal.svg"
                            , Attr.alt "Suomen Palikkaharrastajat ry"
                            , Attr.class "h-10 sm:h-14"
                            ]
                            []
                        ]
                    ]
                , Html.button
                    [ Attr.class "sm:hidden text-white p-2 ml-2 rounded focus:outline-none focus:ring-2 focus:ring-brand-yellow cursor-pointer"
                    , Html.Events.onClick (toMsg ToggleMenu)
                    , Attr.attribute "aria-label"
                        (if model.menuOpen then
                            "Sulje valikko"

                         else
                            "Avaa valikko"
                        )
                    , Attr.attribute "aria-expanded"
                        (if model.menuOpen then
                            "true"

                         else
                            "false"
                        )
                    , Attr.attribute "aria-controls" "mobile-nav"
                    ]
                    [ if model.menuOpen then
                        FeatherIcons.x |> FeatherIcons.withSize 24 |> FeatherIcons.toHtml []

                      else
                        FeatherIcons.menu |> FeatherIcons.withSize 24 |> FeatherIcons.toHtml []
                    ]
                , Html.ul
                    [ Attr.class "hidden sm:flex flex-wrap gap-0.5 list-none m-0 p-0" ]
                    [ desktopNavLink "/typografia" "Typografia"
                    , desktopNavLink "/komponentit" "Komponentit"
                    , desktopNavLink "/responsiivisuus" "Responsiivisuus"
                    , desktopNavLink "/saavutettavuus" "Saavutettavuus"
                    ]
                ]
            ]
        ]


desktopNavLink : String -> String -> Html msg
desktopNavLink href label =
    Html.li []
        [ Html.a
            [ Attr.href href
            , Attr.class "text-white/80 hover:text-brand-yellow font-medium px-2 sm:px-3 py-1 rounded transition-colors text-sm cursor-pointer focus:outline-none focus:ring-2 focus:ring-brand-yellow"
            ]
            [ Html.text label ]
        ]



viewMobileDrawer : UrlPath -> Model -> (SharedMsg -> msg) -> Html msg
viewMobileDrawer currentPath model toMsg =
    let
        isActive href =
            "/" ++ UrlPath.toRelative currentPath == href

        close =
            toMsg CloseMenu
    in
    MobileDrawer.view
        { isOpen = model.menuOpen
        , id = "mobile-nav"
        , onClose = close
        , breakpoint = MobileDrawer.Sm
        , content =
            [ Html.nav [ Attr.class "p-4" ]
                [ Html.ul [ Attr.class "flex flex-col gap-1 list-none m-0 p-0" ]
                    [ MobileDrawer.viewNavLink { href = "/", label = "Logot ja värit", isActive = isActive "/", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/typografia", label = "Typografia", isActive = isActive "/typografia", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/komponentit", label = "Komponentit", isActive = isActive "/komponentit", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/responsiivisuus", label = "Responsiivisuus", isActive = isActive "/responsiivisuus", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/saavutettavuus", label = "Saavutettavuus", isActive = isActive "/saavutettavuus", onClose = close }
                    ]
                ]
            ]
        }


viewFooter : Html msg
viewFooter =
    Html.footer
        [ Attr.class "bg-brand text-white mt-16 py-12 px-4" ]
        [ Html.div
            [ Attr.class "max-w-5xl mx-auto" ]
            [ Html.div
                [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-8" ]
                [ -- Col 1: logo + org name & legal side by side
                  Html.div [ Attr.class "flex items-start gap-4" ]
                    [ Html.img
                        [ Attr.src "/logo/square/svg/square-smile.svg"
                        , Attr.alt ""
                        , Attr.attribute "aria-hidden" "true"
                        , Attr.class "h-25 w-25 flex-shrink-0"
                        ]
                        []
                    , Html.div [ Attr.class "space-y-1" ]
                        [ Html.p [ Attr.class "font-semibold text-white text-sm" ]
                            [ Html.a
                                [ Attr.href "https://palikkaharrastajat.fi"
                                , Attr.class "text-white/80 hover:text-white transition-colors"
                                ]
                                [ Html.text "Suomen Palikkaharrastajat ry" ]
                            ]
                        , Html.div [ Attr.class "space-y-1 text-xs text-white/50" ]
                            [ Html.p [] [ Html.text "© 2026 Suomen Palikkaharrastajat ry" ]
                            , Html.p [] [ Html.text "Fontit: Outfit (SIL Open Font License) · Logot: CC BY 4.0" ]
                            , Html.p [] [ Html.text "LEGO® on LEGO Groupin rekisteröity tavaramerkki" ]
                            , Html.p []
                                [ Html.a
                                    [ Attr.href "/design-guide/index.jsonld"
                                    , Attr.class "underline hover:text-white/80 transition-colors"
                                    ]
                                    [ Html.text "design-guide/ (JSON-LD)" ]
                                ]
                            ]
                        ]
                    ]
                , -- Col 2: service links
                  Html.div [ Attr.class "space-y-3 pl-29 sm:pl-0" ]
                    [ Html.p [ Attr.class "text-xs font-semibold text-white/50 uppercase tracking-wider" ]
                        [ Html.text "Yhdistys" ]
                    , Html.ul [ Attr.class "space-y-2 list-none m-0 p-0" ]
                        [ Html.li []
                            [ Html.a
                                [ Attr.href "https://palikkaharrastajat.fi"
                                , Attr.class "text-sm text-white/80 hover:text-white underline transition-colors"
                                ]
                                [ Html.text "Kotisivut" ]
                            ]
                        , Html.li []
                            [ Html.a
                                [ Attr.href "https://kalenteri.palikkaharrastajat.fi"
                                , Attr.class "text-sm text-white/80 hover:text-white underline transition-colors"
                                ]
                                [ Html.text "Palikkakalenteri" ]
                            ]
                        , Html.li []
                            [ Html.a
                                [ Attr.href "https://linkit.palikkaharrastajat.fi"
                                , Attr.class "text-sm text-white/80 hover:text-white underline transition-colors"
                                ]
                                [ Html.text "Palikkalinkit" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
