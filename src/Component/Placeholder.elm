module Component.Placeholder exposing (view, viewBlock, viewLine)

{-| Loading-skeleton placeholder component.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindExtra as TwEx


view : List (Html msg) -> Html msg
view items =
    Html.div [ classes [ Tw.animate_pulse, TwEx.space_y Th.s3 ] ] items


viewLine : { widthClass : List Tw.Tailwind } -> Html msg
viewLine config =
    Html.div
        [ classes ([ Tw.h Th.s4, Tw.bg_color (Th.gray Th.s200), Tw.rounded ] ++ config.widthClass) ]
        []


viewBlock : { widthClass : List Tw.Tailwind, heightClass : List Tw.Tailwind } -> Html msg
viewBlock config =
    Html.div
        [ classes ([ Tw.bg_color (Th.gray Th.s200), Tw.rounded ] ++ config.widthClass ++ config.heightClass) ]
        []
