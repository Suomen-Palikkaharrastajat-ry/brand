module Component.Badge exposing (Color(..), Size(..), view)

import Html exposing (Html)
import Html.Attributes as Attr


type Color
    = Gray
    | Blue
    | Green
    | Yellow
    | Red
    | Purple
    | Indigo


type Size
    = Small
    | Medium
    | Large


view : { label : String, color : Color, size : Size } -> Html msg
view config =
    Html.span
        [ Attr.class (badgeClasses config.color config.size) ]
        [ Html.text config.label ]


badgeClasses : Color -> Size -> String
badgeClasses color size =
    "inline-flex items-center rounded-full font-medium "
        ++ sizeClasses size
        ++ " "
        ++ colorClasses color


sizeClasses : Size -> String
sizeClasses size =
    case size of
        Small ->
            "px-1.5 py-px text-xs"

        Medium ->
            "px-2.5 py-0.5 text-xs"

        Large ->
            "px-3 py-1 text-sm"


colorClasses : Color -> String
colorClasses color =
    case color of
        Gray ->
            "bg-gray-100 text-gray-700"

        Blue ->
            "bg-blue-100 text-blue-700"

        Green ->
            "bg-green-100 text-green-700"

        Yellow ->
            "bg-yellow-100 text-yellow-800"

        Red ->
            "bg-red-100 text-red-700"

        Purple ->
            "bg-purple-100 text-purple-700"

        Indigo ->
            "bg-indigo-100 text-indigo-700"
