module Component.Stats exposing (view, viewItem)

{-| Statistics / KPI cards component.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.dl
        [ classes
            [ TwEx.not_prose
            , Tw.grid
            , Tw.grid_cols_1
            , Tw.gap_px
            , Tw.bg_color (Th.gray Th.s200)
            , Tw.rounded_lg
            , Tw.overflow_hidden
            , Bp.sm [ Tw.grid_cols_2 ]
            , Bp.lg [ Tw.grid_cols_4 ]
            ]
        ]
        items


viewItem : { label : String, value : String, change : Maybe String } -> Html msg
viewItem config =
    Html.div
        [ classes
            [ Tw.flex
            , Tw.flex_wrap
            , Tw.items_baseline
            , Tw.justify_between
            , Tw.gap_x Th.s4
            , Tw.gap_y Th.s2
            , Tw.bg_simple Th.white
            , Tw.px Th.s6
            , Tw.py Th.s5
            , Bp.sm [ Tw.px Th.s8 ]
            ]
        ]
        [ Html.dt
            [ classes [ Tw.type_body_small, TwEx.leading_6, Tw.text_color (Th.gray Th.s500) ] ]
            [ Html.text config.label ]
        , case config.change of
            Just change ->
                Html.dd [ classes [ Tw.text_xs, Tw.font_medium, Tw.text_simple TC.brand ] ] [ Html.text change ]

            Nothing ->
                Html.text ""
        , Html.dd
            [ classes [ Tw.w_full, Tw.flex_none, Tw.text_n3xl, Tw.font_medium, TwEx.leading_10, Tw.tracking_tight, Tw.text_simple TC.brand ] ]
            [ Html.text config.value ]
        ]
