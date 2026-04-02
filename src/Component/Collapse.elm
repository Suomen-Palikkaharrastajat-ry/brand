module Component.Collapse exposing (view)

{-| CSS-only collapsible section component using the HTML `<details>`/`<summary>` elements.
-}

import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


{-| A CSS-only collapsible section using <details>/<summary>.
For JS-driven collapse, manage visibility with Elm model state instead.
-}
view : { summary : Html msg, body : List (Html msg), open : Bool } -> Html msg
view config =
    Html.details
        (classes [ TwEx.group ]
            :: (if config.open then
                    [ Attr.attribute "open" "" ]

                else
                    []
               )
        )
        [ Html.summary
            [ classes
                [ Tw.flex
                , Tw.cursor_pointer
                , Tw.items_center
                , Tw.gap Th.s2
                , Tw.select_none
                , Tw.list_none
                , Tw.py Th.s2
                , Tw.font_medium
                , Tw.text_simple TC.brand
                , Bp.hover [ TwEx.text_brand_80 ]
                ]
            ]
            [ Html.span [ classes [ Tw.transition_transform, Bp.withVariant "group-open" [ Tw.rotate_90 ], Tw.leading_none ] ]
                [ FeatherIcons.chevronRight
                    |> FeatherIcons.withSize 16
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                ]
            , config.summary
            ]
        , Html.div [ classes [ Tw.pt Th.s2, Tw.pb Th.s4 ] ] config.body
        ]
