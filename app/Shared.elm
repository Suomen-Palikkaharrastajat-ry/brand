module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Browser.Events
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
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
            ( { model | menuOpen = not model.menuOpen }, Effect.none )

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
                    [ Html.span [ Attr.class "block w-6 h-0.5 bg-white mb-1.5" ] []
                    , Html.span [ Attr.class "block w-6 h-0.5 bg-white mb-1.5" ] []
                    , Html.span [ Attr.class "block w-6 h-0.5 bg-white" ] []
                    ]
                , Html.ul
                    [ Attr.class "hidden sm:flex flex-wrap gap-0.5 list-none m-0 p-0" ]
                    [ desktopNavLink "/komponentit" "Komponentit"
                    , desktopNavLink "/responsiivisuus" "Responsiivisuus"
                    , desktopNavLink "/saavutettavuus" "Saavutettavuus"
                    ]
                ]
            , if model.menuOpen then
                Html.ul
                    [ Attr.id "mobile-nav"
                    , Attr.class "sm:hidden flex flex-col items-end gap-1 list-none m-0 p-0 pb-3"
                    ]
                    [ mobileNavLink "/" "Logot, värit ja fontit" toMsg
                    , mobileNavLink "/komponentit" "Komponentit" toMsg
                    , mobileNavLink "/responsiivisuus" "Responsiivisuus" toMsg
                    , mobileNavLink "/saavutettavuus" "Saavutettavuus" toMsg
                    ]

              else
                Html.text ""
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


mobileNavLink : String -> String -> (SharedMsg -> msg) -> Html msg
mobileNavLink href label toMsg =
    Html.li []
        [ Html.a
            [ Attr.href href
            , Attr.class "block text-white/90 hover:text-white hover:underline font-medium px-3 py-2 rounded transition-colors text-sm cursor-pointer focus:outline-none focus:ring-2 focus:ring-brand-yellow"
            , Html.Events.onClick (toMsg CloseMenu)
            ]
            [ Html.text label ]
        ]


viewFooter : Html msg
viewFooter =
    Html.footer
        [ Attr.class "bg-brand text-white mt-16 py-8 px-4" ]
        [ Html.div
            [ Attr.class "max-w-5xl mx-auto text-center space-y-2" ]
            [ Html.p [ Attr.class "text-sm text-white/80" ]
                [ Html.text "© 2026 Suomen Palikkaharrastajat ry" ]
            , Html.p [ Attr.class "text-xs text-white/50" ]
                [ Html.text "Fontit: Outfit (SIL Open Font License) · Logot: CC BY 4.0" ]
            , Html.p [ Attr.class "text-xs text-white/50" ]
                [ Html.text "LEGO® on LEGO Groupin rekisteröity tavaramerkki" ]
            , Html.p [ Attr.class "text-xs text-white/50" ]
                [ Html.a
                    [ Attr.href "/design-guide/index.jsonld"
                    , Attr.class "underline hover:text-white/80 transition-colors"
                    ]
                    [ Html.text "design-guide/ (JSON-LD)" ]
                ]
            ]
        ]
