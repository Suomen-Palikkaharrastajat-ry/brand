module Component.Timeline exposing (view, viewItem)

{-| Vertical timeline component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view : List (Html msg) -> Html msg
view items =
    Html.ol
        [ classes
            [ TwEx.not_prose
            , Tw.relative
            , Tw.border_s_2
            , Tw.border_color (Th.gray Th.s200)
            , TwEx.space_y Th.s0
            , TwEx.ms_8
            ]
        ]
        items


viewItem : { date : String, title : String, children : List (Html msg), icon : Maybe (Html msg), image : Maybe String } -> Html msg
viewItem config =
    Html.li
        [ classes [ Tw.mb Th.s10, TwEx.ms_12 ] ]
        [ Html.span
            [ classes
                [ Tw.absolute
                , TwEx.neg_start_6
                , Tw.flex
                , Tw.h Th.s12
                , Tw.w Th.s12
                , Tw.items_center
                , Tw.justify_center
                , Tw.rounded_full
                , Tw.bg_simple TC.brandYellow
                ]
            ]
            [ case config.icon of
                Nothing ->
                    Html.span [ classes [ Tw.block, Tw.h Th.s4, Tw.w Th.s4, Tw.rounded_full, Tw.bg_simple TC.brand ] ] []

                Just icon ->
                    Html.span [ classes [ Tw.text_simple TC.brand ] ] [ icon ]
            ]
        , Html.div [ classes [ Tw.flex, Tw.items_start, Tw.gap Th.s4 ] ]
            [ Html.div [ classes [ Tw.flex_1, Tw.min_w Th.s0 ] ]
                [ Html.time
                    [ classes [ Tw.mb Th.s1, Tw.block, Tw.text_xs, Tw.font_normal, Tw.leading_none, Tw.text_color (Th.gray Th.s400) ] ]
                    [ Html.text config.date ]
                , Html.h3
                    [ classes [ Tw.type_body_small, Tw.text_simple TC.brand ] ]
                    [ Html.text config.title ]
                , Html.div
                    [ classes [ Tw.mt Th.s1, Tw.text_sm, TwEx.leading_6, Tw.text_color (Th.gray Th.s600) ] ]
                    config.children
                ]
            , case config.image of
                Nothing ->
                    Html.text ""

                Just src ->
                    Html.img
                        [ Attr.src src
                        , Attr.alt ""
                        , classes [ Tw.w Th.s24, Tw.h Th.s24, Tw.object_cover, Tw.rounded_lg, Tw.shrink_0 ]
                        ]
                        []
            ]
        ]
