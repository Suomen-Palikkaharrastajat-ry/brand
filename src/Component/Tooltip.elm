module Component.Tooltip exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : { content : String, children : List (Html msg) } -> Html msg
view config =
    Html.div [ Attr.class "relative inline-flex group" ]
        (Html.div
            [ Attr.class "absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2 py-1 rounded bg-gray-900 text-white text-xs whitespace-nowrap opacity-0 pointer-events-none group-hover:opacity-100 group-focus-within:opacity-100 transition-opacity z-20"
            , Attr.attribute "role" "tooltip"
            ]
            [ Html.text config.content
            , Html.div
                [ Attr.class "absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-900" ]
                []
            ]
            :: config.children
        )
