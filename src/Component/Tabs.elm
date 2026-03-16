module Component.Tabs exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode


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
            [ Attr.class "flex border-b border-gray-200"
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
        [ Attr.class (tabClass (idx == config.activeIndex))
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
        , Attr.class
            (if idx == activeIndex then
                "block"

             else
                "hidden"
            )
        ]
        [ panel ]


tabClass : Bool -> String
tabClass active =
    "px-4 py-2 text-sm font-medium border-b-2 transition-colors cursor-pointer "
        ++ (if active then
                "border-brand text-brand"

            else
                "border-transparent text-gray-500 hover:text-brand hover:border-gray-300"
           )
