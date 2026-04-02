module Component.Navbar exposing (NavLink, view)

{-| Top navigation bar component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


type alias NavLink =
    { label : String
    , href : String
    }


view :
    { logo : Html msg
    , links : List NavLink
    , action : Maybe (Html msg)
    }
    -> Html msg
view config =
    Html.nav
        [ classes [ Tw.bg_simple Th.white, Tw.border_b, Tw.border_simple TC.borderDefault ] ]
        [ Html.div
            [ classes [ Tw.mx_auto, TwEx.max_w_7xl, Tw.px Th.s6, Bp.lg [ Tw.px Th.s8 ] ] ]
            [ Html.div
                [ classes [ Tw.flex, Tw.h Th.s16, Tw.items_center, Tw.justify_between ] ]
                [ Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap_x Th.s8 ] ]
                    [ config.logo
                    , Html.div [ classes [ Tw.hidden, Bp.md [ Tw.flex ], Tw.items_center, Tw.gap_x Th.s6 ] ]
                        (List.map viewLink config.links)
                    ]
                , case config.action of
                    Just btn ->
                        Html.div [] [ btn ]

                    Nothing ->
                        Html.text ""
                ]
            ]
        ]


viewLink : NavLink -> Html msg
viewLink link =
    Html.a
        [ Attr.href link.href
        , classes
            [ Tw.type_body_small
            , Tw.text_simple TC.textMuted
            , Bp.hover [ Tw.text_simple TC.textPrimary ]
            , Bp.withVariant "motion-safe" [ Tw.transition_colors ]
            ]
        ]
        [ Html.text link.label ]
