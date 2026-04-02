module Component.Tooltip exposing (view)

{-| Tooltip component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx


view : { content : String, children : List (Html msg) } -> Html msg
view config =
    Html.div [ classes [ Tw.relative, Tw.inline_flex, TwEx.group ] ]
        (Html.div
            [ classes
                [ Tw.absolute
                , Tw.bottom_full
                , TwEx.left_half
                , TwEx.neg_translate_x_half
                , Tw.mb Th.s2
                , Tw.px Th.s2
                , Tw.py Th.s1
                , Tw.rounded
                , Tw.bg_color (Th.gray Th.s900)
                , Tw.text_simple Th.white
                , Tw.text_xs
                , Tw.whitespace_nowrap
                , Tw.opacity_0
                , Tw.pointer_events_none
                , Bp.group_hover [ Tw.opacity_100 ]
                , Bp.withVariant "group-focus-within" [ Tw.opacity_100 ]
                , Tw.transition_opacity
                , Tw.z_20
                ]
            , Attr.attribute "role" "tooltip"
            ]
            [ Html.text config.content
            , Html.div
                [ classes
                    [ Tw.absolute
                    , Tw.top_full
                    , TwEx.left_half
                    , TwEx.neg_translate_x_half
                    , Tw.border_4
                    , TwEx.border_transparent
                    , TwEx.border_t_gray_900
                    ]
                ]
                []
            ]
            :: config.children
        )
