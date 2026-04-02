module Component.Dropdown exposing (view, viewDivider, viewItem)

{-| Accessible ARIA menu dropdown component.
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
        [ classes [ Tw.relative, Tw.inline_block ]
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
            , classes
                [ Tw.list_none
                , Tw.cursor_pointer
                , Tw.inline_flex
                , Tw.items_center
                , Tw.gap Th.s1
                , Tw.px Th.s4
                , Tw.py Th.s2
                , Tw.type_body_small
                , Tw.bg_simple Th.white
                , Tw.border
                , Tw.border_color (Th.gray Th.s300)
                , Tw.rounded_md
                , Tw.shadow_sm
                , Bp.hover [ Tw.bg_color (Th.gray Th.s50) ]
                , Bp.focus_visible [ Tw.outline_none, Tw.ring_2, TwEx.ring_brand ]
                , Tw.select_none
                ]
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
            , Html.span [ classes [ Tw.text_color (Th.gray Th.s400) ] ] [ Html.text "▾" ]
            ]
        , if config.isOpen then
            Html.div
                [ Attr.attribute "role" "menu"
                , classes
                    [ Tw.absolute
                    , TwEx.left_0
                    , Tw.top_full
                    , Tw.mt Th.s1
                    , Tw.z_10
                    , Tw.w Th.s48
                    , Tw.rounded_md
                    , Tw.border
                    , Tw.border_color (Th.gray Th.s200)
                    , Tw.bg_simple Th.white
                    , Tw.shadow_lg
                    , Tw.py Th.s1
                    ]
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
        , classes
            [ Tw.block
            , Tw.px Th.s4
            , Tw.py Th.s2
            , Tw.text_sm
            , Tw.text_color (Th.gray Th.s700)
            , Bp.hover [ Tw.bg_color (Th.gray Th.s100), Tw.text_simple TC.brand ]
            ]
        ]
        [ Html.text config.label ]


viewDivider : Html msg
viewDivider =
    Html.hr
        [ classes [ Tw.my Th.s1, Tw.border_color (Th.gray Th.s200) ] ]
        []
