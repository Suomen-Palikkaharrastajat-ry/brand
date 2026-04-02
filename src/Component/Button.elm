module Component.Button exposing (Size(..), Variant(..), view, viewLink)

{-| Button component with multiple variants and sizes.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


type Variant
    = Primary
    | Secondary
    | Ghost
    | Danger


type Size
    = Small
    | Medium
    | Large


view : { label : String, variant : Variant, size : Size, onClick : msg, disabled : Bool, loading : Bool, ariaPressedState : Maybe Bool } -> Html msg
view config =
    let
        isInactive =
            config.disabled || config.loading

        baseAttrs =
            [ classes
                (buttonTw config.variant config.size
                    ++ (if isInactive then
                            [ Tw.cursor_not_allowed, Tw.opacity_50 ]

                        else
                            []
                       )
                )
            , Attr.type_ "button"
            , Attr.disabled isInactive
            ]

        loadingAttrs =
            if config.loading then
                [ Attr.attribute "aria-busy" "true"
                , Attr.attribute "aria-label" config.label
                ]

            else
                []

        pressedAttrs =
            case config.ariaPressedState of
                Just pressed ->
                    [ Attr.attribute "aria-pressed"
                        (if pressed then
                            "true"

                         else
                            "false"
                        )
                    ]

                Nothing ->
                    []

        clickAttrs =
            if isInactive then
                []

            else
                [ Events.onClick config.onClick ]

        content =
            if config.loading then
                Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s1 ] ]
                    [ Html.span
                        [ classes [ Tw.w Th.s1_dot_5, Tw.h Th.s1_dot_5, Tw.rounded_full, TwEx.bg_current, Tw.animate_bounce ]
                        , Attr.style "animation-delay" "0ms"
                        ]
                        []
                    , Html.span
                        [ classes [ Tw.w Th.s1_dot_5, Tw.h Th.s1_dot_5, Tw.rounded_full, TwEx.bg_current, Tw.animate_bounce ]
                        , Attr.style "animation-delay" "150ms"
                        ]
                        []
                    , Html.span
                        [ classes [ Tw.w Th.s1_dot_5, Tw.h Th.s1_dot_5, Tw.rounded_full, TwEx.bg_current, Tw.animate_bounce ]
                        , Attr.style "animation-delay" "300ms"
                        ]
                        []
                    ]

            else
                Html.text config.label
    in
    Html.button
        (baseAttrs ++ loadingAttrs ++ pressedAttrs ++ clickAttrs)
        [ content ]


viewLink : { label : String, variant : Variant, size : Size, href : String } -> Html msg
viewLink config =
    Html.a
        [ Attr.href config.href
        , classes (buttonTw config.variant config.size)
        ]
        [ Html.text config.label ]


buttonTw : Variant -> Size -> List Tw.Tailwind
buttonTw variant size =
    [ Tw.inline_flex
    , Tw.items_center
    , Tw.justify_center
    , Tw.font_semibold
    , Tw.rounded
    , Tw.transition_all
    , Tw.cursor_pointer
    , Bp.focus_visible [ Tw.outline_none, Tw.ring_2, Tw.ring_offset_2 ]
    ]
        ++ variantTw variant
        ++ sizeTw size


variantTw : Variant -> List Tw.Tailwind
variantTw variant =
    case variant of
        Primary ->
            [ Tw.bg_simple TC.brandYellow
            , Tw.text_simple TC.brand
            , Bp.hover [ Tw.opacity_90 ]
            , Bp.focus_visible [ TwEx.ring_brand_yellow ]
            ]

        Secondary ->
            [ Tw.bg_simple Th.white
            , Tw.text_simple TC.brand
            , Tw.border
            , Tw.border_simple TC.brand
            , Bp.hover [ Tw.bg_color (Th.gray Th.s50) ]
            , Bp.focus_visible [ TwEx.ring_brand ]
            ]

        Ghost ->
            [ TwEx.bg_transparent
            , Tw.text_simple TC.brand
            , Bp.hover [ TwEx.bg_brand_5 ]
            , Bp.focus_visible [ TwEx.ring_brand ]
            ]

        Danger ->
            [ Tw.bg_color (Th.red Th.s600)
            , Tw.text_simple Th.white
            , Bp.hover [ Tw.bg_color (Th.red Th.s700) ]
            , Bp.focus_visible [ Tw.ring_color (Th.red Th.s500) ]
            ]


sizeTw : Size -> List Tw.Tailwind
sizeTw size =
    case size of
        Small ->
            [ Tw.px Th.s3, Tw.py Th.s1_dot_5, Tw.text_sm ]

        Medium ->
            [ Tw.px Th.s4, Tw.py Th.s2, Tw.text_sm ]

        Large ->
            [ Tw.px Th.s6, Tw.py Th.s3, Tw.text_base ]
