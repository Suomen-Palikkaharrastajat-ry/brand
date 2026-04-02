module Component.Tabs exposing (view)

{-| Tabbed-panel component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view :
    { tabs : List String
    , activeIndex : Int
    , onTabClick : Int -> msg
    , panels : List (Html msg)
    }
    -> Html msg
view config =
    Html.div []
        [ Html.div
            [ classes [ Tw.flex, Tw.border_b, Tw.border_color (Th.gray Th.s200) ]
            , Attr.attribute "role" "tablist"
            , Events.on "keydown"
                (Json.Decode.field "key" Json.Decode.string
                    |> Json.Decode.andThen
                        (\key ->
                            let
                                count =
                                    List.length config.tabs
                            in
                            case key of
                                "ArrowRight" ->
                                    Json.Decode.succeed
                                        (config.onTabClick
                                            ((config.activeIndex + 1) |> modBy count)
                                        )

                                "ArrowLeft" ->
                                    Json.Decode.succeed
                                        (config.onTabClick
                                            ((config.activeIndex - 1 + count) |> modBy count)
                                        )

                                _ ->
                                    Json.Decode.fail "not an arrow key"
                        )
                )
            ]
            (List.indexedMap (viewTab config) config.tabs)
        , Html.div []
            (List.indexedMap (viewPanel config.activeIndex) config.panels)
        ]


viewTab :
    { tabs : List String, activeIndex : Int, onTabClick : Int -> msg, panels : List (Html msg) }
    -> Int
    -> String
    -> Html msg
viewTab config idx label =
    Html.button
        [ classes (tabTw (idx == config.activeIndex))
        , Events.onClick (config.onTabClick idx)
        , Attr.type_ "button"
        , Attr.attribute "role" "tab"
        , Attr.id ("tab-" ++ String.fromInt idx)
        , Attr.attribute "aria-controls" ("panel-" ++ String.fromInt idx)
        , Attr.attribute "aria-selected"
            (if idx == config.activeIndex then
                "true"

             else
                "false"
            )
        ]
        [ Html.text label ]


viewPanel : Int -> Int -> Html msg -> Html msg
viewPanel activeIndex idx panel =
    Html.div
        [ Attr.attribute "role" "tabpanel"
        , Attr.id ("panel-" ++ String.fromInt idx)
        , Attr.attribute "aria-labelledby" ("tab-" ++ String.fromInt idx)
        , classes
            (if idx == activeIndex then
                [ Tw.block ]

             else
                [ Tw.hidden ]
            )
        ]
        [ panel ]


tabTw : Bool -> List Tw.Tailwind
tabTw active =
    [ Tw.px Th.s4
    , Tw.py Th.s2
    , Tw.type_body_small
    , Tw.border_b_2
    , Tw.transition_colors
    , Tw.cursor_pointer
    ]
        ++ (if active then
                [ Tw.border_simple TC.brand, Tw.text_simple TC.brand ]

            else
                [ TwEx.border_transparent
                , Tw.text_color (Th.gray Th.s500)
                , Bp.hover [ Tw.text_simple TC.brand, Tw.border_color (Th.gray Th.s300) ]
                ]
           )
