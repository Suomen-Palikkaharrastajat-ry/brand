module Component.Timeline exposing (view, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr


view : List (Html msg) -> Html msg
view items =
    Html.ol
        [ Attr.class "not-prose relative border-s-2 border-gray-200 space-y-0 ms-8" ]
        items


viewItem : { date : String, title : String, children : List (Html msg), icon : Maybe (Html msg), image : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ Attr.class "mb-10 ms-12" ]
        [ Html.span
            [ Attr.class "absolute -start-6 flex h-12 w-12 items-center justify-center rounded-full bg-brand-yellow" ]
            [ case config.icon of
                Nothing ->
                    Html.span [ Attr.class "block h-4 w-4 rounded-full bg-brand" ] []

                Just icon ->
                    Html.span [ Attr.class "text-brand" ] [ icon ]
            ]
        , Html.div [ Attr.class "flex items-start gap-4" ]
            [ Html.div [ Attr.class "flex-1 min-w-0" ]
                [ Html.time
                    [ Attr.class "mb-1 block text-xs font-normal leading-none text-gray-400" ]
                    [ Html.text config.date ]
                , Html.h3
                    [ Attr.class "text-sm font-semibold text-brand" ]
                    [ Html.text config.title ]
                , Html.div
                    [ Attr.class "mt-1 text-sm leading-6 text-gray-600" ]
                    config.children
                ]
            , case config.image of
                Nothing ->
                    Html.text ""

                Just src ->
                    Html.img
                        [ Attr.src src
                        , Attr.alt ""
                        , Attr.class "w-24 h-24 object-cover rounded-lg flex-shrink-0"
                        ]
                        []
            ]
        ]
