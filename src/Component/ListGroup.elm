module Component.ListGroup exposing (view, viewActionItem, viewItem)

{-| Vertical list-group component.
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
view items =
    Html.ul
        [ classes
            [ Tw.divide_y
            , TwEx.divide_color (Th.gray Th.s200)
            , Tw.rounded_lg
            , Tw.border
            , Tw.border_color (Th.gray Th.s200)
            , Tw.overflow_hidden
            ]
        ]
        items


viewItem : { label : String, badge : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ classes [ Tw.flex, Tw.items_center, Tw.justify_between, Tw.bg_simple Th.white, Tw.px Th.s4, Tw.py Th.s3, Tw.text_sm, Tw.text_color (Th.gray Th.s800) ] ]
        [ Html.span [] [ Html.text config.label ]
        , case config.badge of
            Just b ->
                Html.span
                    [ classes [ Tw.inline_flex, Tw.items_center, Tw.rounded_full, TwEx.bg_brand_10, Tw.px Th.s2, Tw.py Th.s0_dot_5, Tw.text_xs, Tw.font_medium, Tw.text_simple TC.brand ] ]
                    [ Html.text b ]

            Nothing ->
                Html.text ""
        ]


viewActionItem : { label : String, onClick : msg, active : Bool } -> Html msg
viewActionItem config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , classes
                ([ Tw.w_full, Tw.text_left, Tw.px Th.s4, Tw.py Th.s3, Tw.cursor_pointer ]
                    ++ (if config.active then
                            [ Tw.type_body_small, Tw.bg_simple TC.brand, Tw.text_simple Th.white ]

                        else
                            [ Tw.text_sm, Tw.text_color (Th.gray Th.s800), Tw.bg_simple Th.white, Bp.hover [ Tw.bg_color (Th.gray Th.s50), Tw.text_simple TC.brand ], Tw.transition_colors ]
                       )
                )
            , Events.onClick config.onClick
            ]
            [ Html.text config.label ]
        ]
