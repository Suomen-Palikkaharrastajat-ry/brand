module Component.Spinner exposing (Size(..), view)

{-| Loading spinner component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindExtra as TwEx


view : { size : Size, label : String } -> Html msg
view config =
    Html.div
        [ classes [ Tw.inline_flex, Tw.items_center, Tw.gap Th.s2 ]
        , Attr.attribute "role" "status"
        ]
        [ Html.div
            [ classes
                ([ Tw.animate_spin
                 , Tw.rounded_full
                 , Tw.border_2
                 , Tw.border_color (Th.gray Th.s200)
                 , TwEx.border_t_brand
                 ]
                    ++ sizeTw config.size
                )
            ]
            []
        , Html.span [ classes [ Tw.sr_only ] ] [ Html.text config.label ]
        ]


type Size
    = Small
    | Medium
    | Large


sizeTw : Size -> List Tw.Tailwind
sizeTw size =
    case size of
        Small ->
            [ Tw.w Th.s4, Tw.h Th.s4 ]

        Medium ->
            [ Tw.w Th.s6, Tw.h Th.s6 ]

        Large ->
            [ Tw.w Th.s10, Tw.h Th.s10 ]
