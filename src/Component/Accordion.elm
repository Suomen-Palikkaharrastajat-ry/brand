module Component.Accordion exposing (view, viewItem)

{-| Collapsible accordion component.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.div
        [ classes
            [ Tw.divide_y
            , TwEx.divide_color (Th.gray Th.s200)
            , Tw.border
            , Tw.border_color (Th.gray Th.s200)
            , Tw.rounded_lg
            , Tw.overflow_hidden
            ]
        ]
        items


viewItem : { title : String, body : List (Html msg) } -> Html msg
viewItem config =
    Html.details
        [ classes [ TwEx.group, Tw.bg_simple Th.white ] ]
        [ Html.summary
            [ classes
                [ Tw.flex
                , Tw.cursor_pointer
                , Tw.items_center
                , Tw.justify_between
                , Tw.px Th.s6
                , Tw.py Th.s4
                , Tw.font_medium
                , Tw.text_simple TC.brand
                , Tw.select_none
                , Bp.hover [ Tw.bg_color (Th.gray Th.s50) ]
                ]
            ]
            [ Html.span [] [ Html.text config.title ]
            , Html.span
                [ classes
                    [ Tw.ml Th.s4
                    , Tw.shrink_0
                    , Tw.text_color (Th.gray Th.s400)
                    , Tw.transition_transform
                    , Bp.withVariant "group-open" [ Tw.rotate_180 ]
                    ]
                ]
                [ Html.text "▾" ]
            ]
        , Html.div
            [ classes
                [ Tw.px Th.s6
                , Tw.py Th.s4
                , Tw.text_sm
                , Tw.text_color (Th.gray Th.s600)
                , Tw.border_t
                , Tw.border_color (Th.gray Th.s100)
                ]
            ]
            config.body
        ]
