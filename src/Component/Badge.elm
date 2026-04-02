module Component.Badge exposing (Color(..), Size(..), view)

{-| Small status badge component.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th


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
        [ classes
            ([ Tw.inline_flex, Tw.items_center, Tw.rounded_full, Tw.font_medium ]
                ++ sizeTw config.size
                ++ colorTw config.color
            )
        ]
        [ Html.text config.label ]


sizeTw : Size -> List Tw.Tailwind
sizeTw size =
    case size of
        Small ->
            [ Tw.px Th.s1_dot_5, Tw.py_px, Tw.text_xs ]

        Medium ->
            [ Tw.px Th.s2_dot_5, Tw.py Th.s0_dot_5, Tw.text_xs ]

        Large ->
            [ Tw.px Th.s3, Tw.py Th.s1, Tw.text_sm ]


colorTw : Color -> List Tw.Tailwind
colorTw color =
    case color of
        Gray ->
            [ Tw.bg_color (Th.gray Th.s100), Tw.text_color (Th.gray Th.s700) ]

        Blue ->
            [ Tw.bg_color (Th.blue Th.s100), Tw.text_color (Th.blue Th.s700) ]

        Green ->
            [ Tw.bg_color (Th.green Th.s100), Tw.text_color (Th.green Th.s700) ]

        Yellow ->
            [ Tw.bg_color (Th.yellow Th.s100), Tw.text_color (Th.yellow Th.s800) ]

        Red ->
            [ Tw.bg_color (Th.red Th.s100), Tw.text_color (Th.red Th.s700) ]

        Purple ->
            [ Tw.bg_color (Th.purple Th.s100), Tw.text_color (Th.purple Th.s700) ]

        Indigo ->
            [ Tw.bg_color (Th.indigo Th.s100), Tw.text_color (Th.indigo Th.s700) ]
