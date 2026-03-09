module ErrorPage exposing (ErrorPage(..), Model, Msg, head, init, internalError, notFound, statusCode, update, view)

import Effect exposing (Effect)
import Head
import Html exposing (Html)
import Html.Attributes as Attr
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
                [ Html.main_ [ Attr.class "min-h-screen flex items-center justify-center p-8" ]
                    [ Html.div [ Attr.class "text-center" ]
                        [ Html.h1 [ Attr.class "text-4xl font-bold text-brand mb-4" ]
                            [ Html.text "404" ]
                        , Html.p [ Attr.class "text-xl text-gray-600 mb-8" ]
                            [ Html.text "Sivua ei löydy" ]
                        , Html.a
                            [ Attr.href "/"
                            , Attr.class "bg-brand-yellow text-brand px-6 py-3 rounded font-semibold hover:opacity-90 transition-opacity"
                            ]
                            [ Html.text "Etusivulle" ]
                        ]
                    ]
                ]
            }

        InternalError message ->
            { title = "Virhe — Suomen Palikkaharrastajat ry"
            , body =
                [ Html.main_ [ Attr.class "min-h-screen flex items-center justify-center p-8" ]
                    [ Html.div [ Attr.class "text-center" ]
                        [ Html.h1 [ Attr.class "text-4xl font-bold text-brand mb-4" ]
                            [ Html.text "500" ]
                        , Html.p [ Attr.class "text-xl text-gray-600 mb-4" ]
                            [ Html.text "Sisäinen virhe" ]
                        , Html.p [ Attr.class "text-sm text-gray-400 font-mono" ]
                            [ Html.text message ]
                        ]
                    ]
                ]
            }
