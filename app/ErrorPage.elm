module ErrorPage exposing (ErrorPage(..), Model, Msg, head, init, internalError, notFound, statusCode, update, view)

{-| elm-pages error page handler.

Renders the 404 (not found) and 500 (internal error) pages. elm-pages calls
`view` automatically when a route returns an error. The `ErrorPage` custom type
is the single source of truth for all error states in the site.

-}

import Effect exposing (Effect)
import Head
import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC
import View exposing (View)


type ErrorPage
    = NotFound
    | InternalError String


type alias Model =
    {}


type alias Msg =
    Never


head : ErrorPage -> List Head.Tag
head _ =
    []


init : ErrorPage -> ( Model, Effect Msg )
init _ =
    ( {}, Effect.none )


update : ErrorPage -> Msg -> Model -> ( Model, Effect Msg )
update _ _ model =
    ( model, Effect.none )


notFound : ErrorPage
notFound =
    NotFound


internalError : String -> ErrorPage
internalError =
    InternalError


statusCode : ErrorPage -> number
statusCode errorPage =
    case errorPage of
        NotFound ->
            404

        InternalError _ ->
            500


view : ErrorPage -> Model -> View Msg
view errorPage _ =
    case errorPage of
        NotFound ->
            { title = "Sivua ei löydy — Suomen Palikkaharrastajat ry"
            , body =
                [ Html.main_
                    [ classes [ Tw.min_h_screen, Tw.flex, Tw.items_center, Tw.justify_center, Tw.p Th.s8 ] ]
                    [ Html.div [ classes [ Tw.text_center ] ]
                        [ Html.h1 [ classes [ Tw.text_4xl, Tw.font_bold, Tw.text_simple TC.brand, Tw.mb Th.s4 ] ]
                            [ Html.text "404" ]
                        , Html.p [ classes [ Tw.text_xl, Tw.text_color (Th.gray Th.s600), Tw.mb Th.s8 ] ]
                            [ Html.text "Sivua ei löydy" ]
                        , Html.a
                            [ Attr.href "/"
                            , classes
                                [ Tw.bg_simple TC.brandYellow
                                , Tw.text_simple TC.brand
                                , Tw.px Th.s6
                                , Tw.py Th.s3
                                , Tw.rounded
                                , Tw.font_semibold
                                , Bp.hover [ Tw.opacity_90 ]
                                , Tw.transition_opacity
                                ]
                            ]
                            [ Html.text "Etusivulle" ]
                        ]
                    ]
                ]
            }

        InternalError message ->
            { title = "Virhe — Suomen Palikkaharrastajat ry"
            , body =
                [ Html.main_
                    [ classes [ Tw.min_h_screen, Tw.flex, Tw.items_center, Tw.justify_center, Tw.p Th.s8 ] ]
                    [ Html.div [ classes [ Tw.text_center ] ]
                        [ Html.h1 [ classes [ Tw.text_4xl, Tw.font_bold, Tw.text_simple TC.brand, Tw.mb Th.s4 ] ]
                            [ Html.text "500" ]
                        , Html.p [ classes [ Tw.text_xl, Tw.text_color (Th.gray Th.s600), Tw.mb Th.s4 ] ]
                            [ Html.text "Sisäinen virhe" ]
                        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s400), Tw.font_mono ] ]
                            [ Html.text message ]
                        ]
                    ]
                ]
            }
