module Component.Toggle exposing (view)

{-| Toggle / switch input component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


view : { id : String, label : String, checked : Bool, onToggle : Bool -> msg, disabled : Bool } -> Html msg
view config =
    Html.label
        [ Attr.for config.id
        , classes [ Tw.inline_flex, Tw.items_center, Tw.gap Th.s3, Tw.cursor_pointer ]
        ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.id config.id
            , Attr.checked config.checked
            , Attr.disabled config.disabled
            , classes [ Tw.sr_only, TwEx.peer ]
            , Events.onCheck config.onToggle
            ]
            []
        , Html.div
            [ classes
                [ Tw.relative
                , Tw.w Th.s11
                , Tw.h Th.s6
                , Tw.rounded_full
                , Tw.transition_colors
                , Tw.bg_color (Th.gray Th.s300)
                , Bp.withVariant "peer-checked" [ Tw.bg_simple TC.brand ]
                , Bp.withVariant "peer-focus-visible" [ Tw.ring_2, TwEx.ring_brand, Tw.ring_offset_2 ]
                , Bp.withVariant "peer-disabled" [ Tw.opacity_50, Tw.cursor_not_allowed ]
                ]
            ]
            [ Html.div
                [ classes
                    [ Tw.absolute
                    , TwEx.top_0_5
                    , TwEx.left_0_5
                    , Tw.w Th.s5
                    , Tw.h Th.s5
                    , Tw.rounded_full
                    , Tw.bg_simple Th.white
                    , Tw.shadow
                    , Tw.transition_transform
                    , Bp.withVariant "peer-checked" [ TwEx.translate_x_5 ]
                    ]
                ]
                []
            ]
        , Html.span [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s700) ] ] [ Html.text config.label ]
        ]
