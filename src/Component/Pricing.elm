module Component.Pricing exposing (Tier, view)

{-| Pricing-table component.
-}

import FeatherIcons
import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


type alias Tier msg =
    { name : String
    , price : String
    , period : Maybe String
    , features : List String
    , cta : Html msg
    , highlighted : Bool
    }


view : List (Tier msg) -> Html msg
view tiers =
    Html.div
        [ classes [ Tw.py Th.s12 ] ]
        [ Html.div
            [ classes [ Tw.grid, Tw.gap Th.s8, Bp.sm [ Tw.grid_cols_2 ], Bp.lg [ Tw.grid_cols_3 ] ] ]
            (List.map viewTier tiers)
        ]


viewTier : Tier msg -> Html msg
viewTier tier =
    Html.div
        [ classes (tierTw tier.highlighted) ]
        [ Html.div [ classes [ Tw.p Th.s8 ] ]
            [ Html.h3
                [ classes (tierNameTw tier.highlighted) ]
                [ Html.text tier.name ]
            , Html.div [ classes [ Tw.mt Th.s4, Tw.flex, Tw.items_baseline, Tw.gap_x Th.s2 ] ]
                [ Html.span
                    [ classes (priceTw tier.highlighted) ]
                    [ Html.text tier.price ]
                , case tier.period of
                    Just p ->
                        Html.span
                            [ classes (periodTw tier.highlighted) ]
                            [ Html.text ("/ " ++ p) ]

                    Nothing ->
                        Html.text ""
                ]
            , Html.ul
                [ classes [ Tw.mt Th.s8, TwEx.space_y Th.s3 ] ]
                (List.map (viewFeature tier.highlighted) tier.features)
            , Html.div [ classes [ Tw.mt Th.s8 ] ] [ tier.cta ]
            ]
        ]


viewFeature : Bool -> String -> Html msg
viewFeature highlighted feature =
    Html.li
        [ classes [ Tw.flex, Tw.items_center, Tw.gap_x Th.s3, Tw.type_caption ] ]
        [ Html.span
            [ classes
                (Tw.type_h4
                    :: (if highlighted then
                            [ TwEx.text_white_70 ]

                        else
                            [ Tw.text_simple TC.brandYellow ]
                       )
                )
            ]
            [ FeatherIcons.check |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [] ]
        , Html.span
            [ classes
                (if highlighted then
                    [ Tw.text_simple Th.white ]

                 else
                    [ Tw.text_simple TC.textPrimary ]
                )
            ]
            [ Html.text feature ]
        ]


tierTw : Bool -> List Tw.Tailwind
tierTw highlighted =
    [ Tw.rounded_n2xl, Tw.border, Tw.overflow_hidden ]
        ++ (if highlighted then
                [ Tw.bg_simple TC.brand, Tw.border_simple TC.brand ]

            else
                [ Tw.bg_simple Th.white, Tw.border_simple TC.borderDefault, Tw.shadow_sm ]
           )


tierNameTw : Bool -> List Tw.Tailwind
tierNameTw highlighted =
    Tw.type_h4
        :: (if highlighted then
                [ Tw.text_simple Th.white ]

            else
                [ Tw.text_simple TC.textPrimary ]
           )


priceTw : Bool -> List Tw.Tailwind
priceTw highlighted =
    [ Tw.type_display, Tw.tracking_tight ]
        ++ (if highlighted then
                [ Tw.text_simple Th.white ]

            else
                [ Tw.text_simple TC.textPrimary ]
           )


periodTw : Bool -> List Tw.Tailwind
periodTw highlighted =
    Tw.type_body_small
        :: (if highlighted then
                [ TwEx.text_white_70 ]

            else
                [ Tw.text_simple TC.textMuted ]
           )
