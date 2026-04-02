module Component.Hero exposing (view)

{-| Hero / banner section component.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view :
    { title : String
    , subtitle : Maybe String
    , cta : List (Html msg)
    }
    -> Html msg
view config =
    Html.section
        [ classes [ Tw.bg_simple Th.white, Tw.py Th.s16, Bp.sm [ Tw.py Th.s24 ] ] ]
        [ Html.div
            [ classes [ Tw.mx_auto, TwEx.max_w_4xl, Tw.px Th.s6, Bp.lg [ Tw.px Th.s8 ], Tw.text_center ] ]
            [ Html.h1
                [ classes [ Tw.type_display, Tw.tracking_tight, Tw.text_simple TC.textPrimary ] ]
                [ Html.text config.title ]
            , case config.subtitle of
                Just sub ->
                    Html.p
                        [ classes [ Tw.mt Th.s6, Tw.type_body, Tw.leading_relaxed, Tw.text_simple TC.textMuted, TwEx.max_w_2xl, Tw.mx_auto ] ]
                        [ Html.text sub ]

                Nothing ->
                    Html.text ""
            , if List.isEmpty config.cta then
                Html.text ""

              else
                Html.div
                    [ classes [ Tw.mt Th.s10, Tw.flex, Tw.items_center, Tw.justify_center, Tw.gap_x Th.s6, Tw.flex_wrap, Tw.gap_y Th.s4 ] ]
                    config.cta
            ]
        ]
