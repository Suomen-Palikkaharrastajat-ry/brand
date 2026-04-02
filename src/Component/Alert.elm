module Component.Alert exposing (AlertType(..), view)

{-| Alert / notification banner component.
-}

import Component.CloseButton as CloseButton
import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindExtra as TwEx


type AlertType
    = Info
    | Success
    | Warning
    | Error


view : { alertType : AlertType, title : Maybe String, body : List (Html msg), onDismiss : Maybe msg } -> Html msg
view config =
    Html.div
        (List.filterMap identity
            [ Just (classes (containerTw config.alertType ++ dismissTw config.onDismiss))
            , Maybe.map (\_ -> Attr.attribute "role" "alert") config.onDismiss
            ]
        )
        (List.filterMap identity
            [ Just
                (Html.div [ classes [ Tw.flex ] ]
                    [ Html.div [ classes [ Tw.shrink_0, Tw.leading_none ] ]
                        [ icon config.alertType ]
                    , Html.div [ classes [ Tw.ml Th.s3 ] ]
                        (List.filterMap identity
                            [ Maybe.map
                                (\t ->
                                    Html.p
                                        [ classes ([ Tw.font_semibold ] ++ titleTw config.alertType) ]
                                        [ Html.text t ]
                                )
                                config.title
                            , Just
                                (Html.div
                                    [ classes ([ Tw.text_sm ] ++ bodyTw config.alertType) ]
                                    config.body
                                )
                            ]
                        )
                    ]
                )
            , Maybe.map
                (\msg ->
                    Html.div [ classes [ Tw.absolute, TwEx.top_2, TwEx.right_2 ] ]
                        [ CloseButton.view { onClick = msg, label = "Sulje ilmoitus" } ]
                )
                config.onDismiss
            ]
        )


dismissTw : Maybe msg -> List Tw.Tailwind
dismissTw onDismiss =
    case onDismiss of
        Just _ ->
            [ Tw.relative ]

        Nothing ->
            []


containerTw : AlertType -> List Tw.Tailwind
containerTw alertType =
    [ Tw.rounded_lg, Tw.p Th.s4 ]
        ++ (case alertType of
                Info ->
                    [ Tw.bg_color (Th.blue Th.s50) ]

                Success ->
                    [ Tw.bg_color (Th.green Th.s50) ]

                Warning ->
                    [ Tw.bg_color (Th.yellow Th.s50) ]

                Error ->
                    [ Tw.bg_color (Th.red Th.s50) ]
           )


icon : AlertType -> Html msg
icon alertType =
    (case alertType of
        Info ->
            FeatherIcons.info

        Success ->
            FeatherIcons.checkCircle

        Warning ->
            FeatherIcons.alertTriangle

        Error ->
            FeatherIcons.xCircle
    )
        |> FeatherIcons.withSize 18
        |> FeatherIcons.toHtml []


titleTw : AlertType -> List Tw.Tailwind
titleTw alertType =
    case alertType of
        Info ->
            [ Tw.text_color (Th.blue Th.s800) ]

        Success ->
            [ Tw.text_color (Th.green Th.s800) ]

        Warning ->
            [ Tw.text_color (Th.yellow Th.s800) ]

        Error ->
            [ Tw.text_color (Th.red Th.s800) ]


bodyTw : AlertType -> List Tw.Tailwind
bodyTw alertType =
    case alertType of
        Info ->
            [ Tw.text_color (Th.blue Th.s700) ]

        Success ->
            [ Tw.text_color (Th.green Th.s700) ]

        Warning ->
            [ Tw.text_color (Th.yellow Th.s700) ]

        Error ->
            [ Tw.text_color (Th.red Th.s700) ]
