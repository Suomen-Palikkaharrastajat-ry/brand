module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Html.Attributes as Attr
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


type Msg
    = SharedMsg SharedMsg


type alias Model =
    {}


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
    ( {}, Effect.none )


update : Msg -> Model -> ( Model, Effect msg )
update msg model =
    case msg of
        SharedMsg _ ->
            ( model, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
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
view _ page _ toMsg pageView =
    { title = pageView.title
    , body =
        [ Html.div [ Attr.class "min-h-screen flex flex-col font-sans" ]
            [ viewNavbar (toMsg << SharedMsg)
            , Html.main_ [ Attr.class "flex-1" ] pageView.body
            , viewFooter
            ]
        ]
    }


viewNavbar : (SharedMsg -> msg) -> Html msg
viewNavbar toMsg =
    Html.nav
        [ Attr.class "bg-brand sticky top-0 z-50 shadow-md" ]
        [ Html.div
            [ Attr.class "max-w-5xl mx-auto px-4 py-3 flex items-center justify-between gap-6" ]
            [ Html.a
                [ Attr.href "/"
                , Attr.class "flex-shrink-0"
                ]
                [ Html.img
                    [ Attr.src "/logo/horizontal/svg/horizontal-full-dark.svg"
                    , Attr.alt "Suomen Palikkaharrastajat ry"
                    , Attr.class "h-14"
                    ]
                    []
                ]
            , Html.ul
                [ Attr.class "flex gap-1 list-none m-0 p-0" ]
                [ navLink "/logot" "Logot"
                , navLink "/varit" "Värit"
                , navLink "/typografia" "Typografia"
                ]
            ]
        ]


navLink : String -> String -> Html msg
navLink href label =
    Html.li []
        [ Html.a
            [ Attr.href href
            , Attr.class "text-white/80 hover:text-brand-yellow font-medium px-3 py-1 rounded transition-colors"
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
                [ Html.text "© 2026 Suomen Palikkaharrastajat ry · Logo ja värit" ]
            , Html.p [ Attr.class "text-xs text-white/50" ]
                [ Html.text "Fontit: Outfit (SIL Open Font License) · Logot: CC BY 4.0" ]
            , Html.p [ Attr.class "text-xs text-white/50" ]
                [ Html.a
                    [ Attr.href "/brand.json"
                    , Attr.class "underline hover:text-white/80 transition-colors"
                    ]
                    [ Html.text "brand.json (koneluettava)" ]
                ]
            ]
        ]
