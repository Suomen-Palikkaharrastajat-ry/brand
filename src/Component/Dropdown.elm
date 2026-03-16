module Component.Dropdown exposing (view, viewDivider, viewItem)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode


{-| An accessible ARIA menu dropdown.
The caller owns open/close state via isOpen, onToggle, and onClose.
-}
view :
    { trigger : Html msg
    , items : List (Html msg)
    , isOpen : Bool
    , onToggle : msg
    , onClose : msg
    }
    -> Html msg
view config =
    Html.div
        [ Attr.class "relative inline-block"
        , Events.on "keydown"
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if key == "Escape" then
                            Json.Decode.succeed config.onClose

                        else
                            Json.Decode.fail "not escape"
                    )
            )
        ]
        [ Html.button
            [ Attr.type_ "button"
            , Attr.class "list-none cursor-pointer inline-flex items-center gap-1 px-4 py-2 text-sm font-medium bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-brand select-none"
            , Attr.attribute "aria-haspopup" "menu"
            , Attr.attribute "aria-expanded"
                (if config.isOpen then
                    "true"

                 else
                    "false"
                )
            , Events.onClick config.onToggle
            ]
            [ config.trigger
            , Html.span [ Attr.class "text-gray-400" ] [ Html.text "▾" ]
            ]
        , if config.isOpen then
            Html.div
                [ Attr.attribute "role" "menu"
                , Attr.class "absolute left-0 top-full mt-1 z-10 w-48 rounded-md border border-gray-200 bg-white shadow-lg py-1"
                ]
                config.items

          else
            Html.text ""
        ]


viewItem : { label : String, href : String } -> Html msg
viewItem config =
    Html.a
        [ Attr.href config.href
        , Attr.attribute "role" "menuitem"
        , Attr.class "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-brand"
        ]
        [ Html.text config.label ]


viewDivider : Html msg
viewDivider =
    Html.hr [ Attr.class "my-1 border-gray-200" ] []
