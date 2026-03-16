module Component.Timeline exposing (view, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr


view : List (Html msg) -> Html msg
view items =
    Html.ol
        [ Attr.class "not-prose relative border-s border-gray-200 space-y-0" ]
        items


viewItem : { date : String, title : String, children : List (Html msg), icon : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ Attr.class "mb-10 ms-6" ]
        [ Html.span
            [ Attr.class "absolute -start-3 flex h-6 w-6 items-center justify-center rounded-full bg-brand-yellow ring-4 ring-white" ]
            [ case config.icon of
                Nothing ->
                    Html.span [ Attr.class "block h-2 w-2 rounded-full bg-brand" ] []

                Just icon ->
                    Html.span [ Attr.class "text-xs font-bold text-brand leading-none select-none" ] [ Html.text icon ]
            ]
        , Html.time
            [ Attr.class "mb-1 block text-xs font-normal leading-none text-gray-400" ]
            [ Html.text config.date ]
        , Html.h3
            [ Attr.class "text-sm font-semibold text-brand" ]
            [ Html.text config.title ]
        , Html.div
            [ Attr.class "mt-1 text-sm leading-6 text-gray-600" ]
            config.children
        ]
