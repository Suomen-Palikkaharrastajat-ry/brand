module Component.Toggle exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : { id : String, label : String, checked : Bool, onToggle : Bool -> msg, disabled : Bool } -> Html msg
view config =
    Html.label
        [ Attr.for config.id
        , Attr.class "inline-flex items-center gap-3 cursor-pointer"
        ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.id config.id
            , Attr.checked config.checked
            , Attr.disabled config.disabled
            , Attr.class "sr-only peer"
            , Events.onCheck config.onToggle
            ]
            []
        , Html.div
            [ Attr.class "relative w-11 h-6 rounded-full transition-colors bg-gray-300 peer-checked:bg-brand peer-focus:ring-2 peer-focus:ring-brand peer-focus:ring-offset-2 peer-disabled:opacity-50 peer-disabled:cursor-not-allowed" ]
            [ Html.div
                [ Attr.class "absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5" ]
                []
            ]
        , Html.span [ Attr.class "text-sm text-gray-700" ] [ Html.text config.label ]
        ]
