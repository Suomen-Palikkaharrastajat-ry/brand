module Component.Breadcrumb exposing (view)

{-| Breadcrumb navigation component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view : List { label : String, href : Maybe String } -> Html msg
view items =
    Html.nav [ Attr.attribute "aria-label" "breadcrumb" ]
        [ Html.ol
            [ classes
                [ Tw.flex
                , Tw.flex_wrap
                , Tw.items_center
                , Tw.gap Th.s1_dot_5
                , Tw.text_sm
                , Tw.text_color (Th.gray Th.s500)
                ]
            ]
            (List.indexedMap (viewItem (List.length items)) items)
        ]


viewItem : Int -> Int -> { label : String, href : Maybe String } -> Html msg
viewItem total idx item =
    let
        isLast =
            idx == total - 1
    in
    Html.li [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s1_dot_5 ] ]
        ([ if isLast then
            Html.span
                [ classes [ Tw.font_medium, Tw.text_color (Th.gray Th.s900) ]
                , Attr.attribute "aria-current" "page"
                ]
                [ Html.text item.label ]

           else
            case item.href of
                Just href ->
                    Html.a
                        [ Attr.href href
                        , classes [ Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors ]
                        ]
                        [ Html.text item.label ]

                Nothing ->
                    Html.span [] [ Html.text item.label ]
         ]
            ++ (if isLast then
                    []

                else
                    [ Html.span [ classes [ Tw.text_color (Th.gray Th.s300), Tw.select_none ] ] [ Html.text "/" ] ]
               )
        )
