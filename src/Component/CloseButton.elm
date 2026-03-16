module Component.CloseButton exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : { onClick : msg, label : String } -> Html msg
view config =
    Html.button
        [ Attr.type_ "button"
        , Attr.class "inline-flex items-center justify-center w-11 h-11 rounded text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors cursor-pointer focus:outline-none focus:ring-2 focus:ring-brand"
        , Attr.attribute "aria-label" config.label
        , Events.onClick config.onClick
        ]
        [ Html.span [ Attr.attribute "aria-hidden" "true", Attr.class "text-lg leading-none" ]
            [ Html.text "×" ]
        ]
