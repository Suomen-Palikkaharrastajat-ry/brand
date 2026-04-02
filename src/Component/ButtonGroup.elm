module Component.ButtonGroup exposing (Position(..), view, viewButton, viewEllipsis)

{-| Horizontally grouped button component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view buttons =
    Html.div
        [ classes [ Tw.inline_flex, Tw.rounded_md, Tw.shadow_sm ]
        , Attr.attribute "role" "group"
        ]
        buttons


viewButton :
    { label : String
    , onClick : msg
    , active : Bool
    , position : Position
    }
    -> Html msg
viewButton config =
    Html.button
        [ Attr.type_ "button"
        , classes (buttonTw config.active config.position)
        , Events.onClick config.onClick
        ]
        [ Html.text config.label ]


viewEllipsis : Html msg
viewEllipsis =
    Html.span
        [ classes
            [ Tw.inline_flex
            , Tw.items_center
            , Tw.px Th.s3
            , Tw.py Th.s2
            , Tw.type_body_small
            , Tw.border
            , Tw.border_color (Th.gray Th.s300)
            , Tw.border_r_0
            , Tw.bg_simple Th.white
            , Tw.text_color (Th.gray Th.s400)
            , Tw.select_none
            ]
        ]
        [ Html.text "⋯" ]


type Position
    = First
    | Middle
    | Last
    | Only


buttonTw : Bool -> Position -> List Tw.Tailwind
buttonTw active position =
    [ Tw.px Th.s4
    , Tw.py Th.s2
    , Tw.type_body_small
    , Tw.border
    , Tw.transition_colors
    , Tw.cursor_pointer
    , Tw.z_10
    , Bp.focus_visible [ Tw.z_10, Tw.outline_none, Tw.ring_2, TwEx.ring_brand ]
    ]
        ++ cornersTw position
        ++ colorsTw active


cornersTw : Position -> List Tw.Tailwind
cornersTw position =
    case position of
        First ->
            [ Tw.rounded_l_md, Tw.rounded_r_none, Tw.border_r_0 ]

        Middle ->
            [ Tw.rounded_none, Tw.border_r_0 ]

        Last ->
            [ Tw.rounded_r_md, Tw.rounded_l_none ]

        Only ->
            [ Tw.rounded_md ]


colorsTw : Bool -> List Tw.Tailwind
colorsTw active =
    if active then
        [ Tw.bg_simple TC.brand, Tw.text_simple Th.white, Tw.border_simple TC.brand ]

    else
        [ Tw.bg_simple Th.white, Tw.text_color (Th.gray Th.s700), Tw.border_color (Th.gray Th.s300), Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ]
