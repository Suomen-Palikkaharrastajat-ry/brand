module Component.Dialog exposing (view)

{-| Modal dialog / overlay component.
-}

import FeatherIcons
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
    { title : String
    , body : List (Html msg)
    , footer : Maybe (Html msg)
    , isOpen : Bool
    , onClose : msg
    }
    -> Html msg
view config =
    if config.isOpen then
        Html.div
            [ classes [ Tw.fixed, TwEx.inset_0, Tw.z_50, Tw.flex, Tw.items_center, Tw.justify_center ] ]
            [ Html.div
                [ classes [ Tw.absolute, TwEx.inset_0, TwEx.bg_black_50 ]
                , Events.onClick config.onClose
                ]
                []
            , Html.node "dialog"
                [ Attr.attribute "open" ""
                , classes
                    [ Tw.relative
                    , Tw.rounded_xl
                    , Tw.shadow_xl
                    , Tw.p Th.s0
                    , Tw.max_w Th.s0
                    , TwEx.max_w_lg
                    , Tw.w_full
                    , Tw.mx Th.s4
                    , Tw.flex
                    , Tw.flex_col
                    , Tw.z_10
                    ]
                , Events.on "cancel" (Json.Decode.succeed config.onClose)
                ]
                [ Html.div
                    [ classes [ Tw.flex, Tw.items_center, Tw.justify_between, Tw.px Th.s6, Tw.py Th.s4 ] ]
                    [ Html.h2 [ classes [ Tw.type_h4, Tw.text_simple TC.brand ] ] [ Html.text config.title ]
                    , Html.button
                        [ Attr.type_ "button"
                        , classes
                            [ Tw.inline_flex
                            , Tw.items_center
                            , Tw.justify_center
                            , Tw.w Th.s11
                            , Tw.h Th.s11
                            , Tw.rounded
                            , Tw.text_color (Th.gray Th.s400)
                            , Bp.hover [ Tw.text_color (Th.gray Th.s600), Tw.bg_color (Th.gray Th.s100) ]
                            , Tw.transition_colors
                            , Tw.cursor_pointer
                            , Bp.focus_visible [ Tw.outline_none, Tw.ring_2, TwEx.ring_brand, Tw.ring_offset_2 ]
                            ]
                        , Attr.attribute "aria-label" "Sulje"
                        , Attr.attribute "autofocus" ""
                        , Events.onClick config.onClose
                        ]
                        [ FeatherIcons.x |> FeatherIcons.withSize 18 |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                        ]
                    ]
                , Html.div [ classes [ Tw.px Th.s6, Tw.py Th.s4, Tw.flex_1 ] ] config.body
                , case config.footer of
                    Nothing ->
                        Html.text ""

                    Just f ->
                        Html.div [ classes [ Tw.px Th.s6, Tw.py Th.s4 ] ] [ f ]
                ]
            ]

    else
        Html.text ""
