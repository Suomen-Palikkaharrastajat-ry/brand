module Component.FeatureGrid exposing (Feature, view)

{-| Feature-highlight grid component.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


type alias Feature msg =
    { icon : Maybe String
    , title : String
    , description : List (Html msg)
    }


view : { columns : Int, features : List (Feature msg) } -> Html msg
view config =
    Html.div
        [ classes [ Tw.py Th.s12 ] ]
        [ Html.div
            [ classes (gridTw config.columns) ]
            (List.map viewFeature config.features)
        ]


viewFeature : Feature msg -> Html msg
viewFeature feature =
    Html.div
        [ classes [ Tw.flex, Tw.flex_col ] ]
        [ case feature.icon of
            Just ico ->
                Html.div
                    [ classes
                        [ Tw.mb Th.s4
                        , Tw.flex
                        , Tw.h Th.s10
                        , Tw.w Th.s10
                        , Tw.items_center
                        , Tw.justify_center
                        , Tw.rounded_lg
                        , Tw.bg_simple TC.brandYellow
                        , Tw.text_simple TC.brand
                        , Tw.type_h4
                        ]
                    ]
                    [ Html.text ico ]

            Nothing ->
                Html.text ""
        , Html.h3
            [ classes [ Tw.type_h4, TwEx.leading_7, Tw.text_simple TC.textPrimary ] ]
            [ Html.text feature.title ]
        , Html.div
            [ classes [ Tw.mt Th.s2, Tw.type_caption, TwEx.leading_7, Tw.text_simple TC.textMuted ] ]
            feature.description
        ]


gridTw : Int -> List Tw.Tailwind
gridTw columns =
    [ Tw.grid, Tw.gap_x Th.s8, Tw.gap_y Th.s10 ]
        ++ (case columns of
                2 ->
                    [ Bp.sm [ Tw.grid_cols_2 ] ]

                3 ->
                    [ Bp.sm [ Tw.grid_cols_2 ], Bp.lg [ Tw.grid_cols_3 ] ]

                4 ->
                    [ Bp.sm [ Tw.grid_cols_2 ], Bp.lg [ Tw.grid_cols_4 ] ]

                _ ->
                    [ Bp.sm [ Tw.grid_cols_2 ], Bp.lg [ Tw.grid_cols_3 ] ]
           )
