module Component.Alert exposing (AlertType(..), view)

import Component.CloseButton as CloseButton
import Html exposing (Html)
import Html.Attributes as Attr


type AlertType
    = Info
    | Success
    | Warning
    | Error


view : { alertType : AlertType, title : Maybe String, body : List (Html msg), onDismiss : Maybe msg } -> Html msg
view config =
    Html.div
        (List.filterMap identity
            [ Just (Attr.class (containerClasses config.alertType ++ dismissClass config.onDismiss))
            , Maybe.map (\_ -> Attr.attribute "role" "alert") config.onDismiss
            ]
        )
        (List.filterMap identity
            [ Just
                (Html.div [ Attr.class "flex" ]
                    [ Html.div [ Attr.class "flex-shrink-0 text-lg leading-6" ]
                        [ Html.text (icon config.alertType) ]
                    , Html.div [ Attr.class "ml-3" ]
                        (List.filterMap identity
                            [ Maybe.map
                                (\t ->
                                    Html.p
                                        [ Attr.class ("font-semibold " ++ titleClass config.alertType) ]
                                        [ Html.text t ]
                                )
                                config.title
                            , Just
                                (Html.div
                                    [ Attr.class ("text-sm " ++ bodyClass config.alertType) ]
                                    config.body
                                )
                            ]
                        )
                    ]
                )
            , Maybe.map
                (\msg ->
                    Html.div [ Attr.class "absolute top-2 right-2" ]
                        [ CloseButton.view { onClick = msg, label = "Sulje ilmoitus" } ]
                )
                config.onDismiss
            ]
        )


dismissClass : Maybe msg -> String
dismissClass onDismiss =
    case onDismiss of
        Just _ ->
            " relative"

        Nothing ->
            ""


containerClasses : AlertType -> String
containerClasses alertType =
    "rounded-lg p-4 "
        ++ (case alertType of
                Info ->
                    "bg-blue-50"

                Success ->
                    "bg-green-50"

                Warning ->
                    "bg-yellow-50"

                Error ->
                    "bg-red-50"
           )


icon : AlertType -> String
icon alertType =
    case alertType of
        Info ->
            "ℹ"

        Success ->
            "✓"

        Warning ->
            "⚠"

        Error ->
            "✕"


titleClass : AlertType -> String
titleClass alertType =
    case alertType of
        Info ->
            "text-blue-800"

        Success ->
            "text-green-800"

        Warning ->
            "text-yellow-800"

        Error ->
            "text-red-800"


bodyClass : AlertType -> String
bodyClass alertType =
    case alertType of
        Info ->
            "text-blue-700"

        Success ->
            "text-green-700"

        Warning ->
            "text-yellow-700"

        Error ->
            "text-red-700"
