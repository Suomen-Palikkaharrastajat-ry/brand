module Component.LogoCard exposing (LogoVariant, view)

{-| Logo-display card component.
-}

import Component.DownloadButton as DownloadButton
import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


type alias LogoVariant =
    { id : String
    , description : String
    , theme : String
    , animated : Bool
    , withText : Bool
    , bold : Bool
    , highlight : Bool
    , svgUrl : Maybe String
    , pngUrl : Maybe String
    , webpUrl : Maybe String
    , gifUrl : Maybe String
    }


view : LogoVariant -> Html msg
view variant =
    Html.div
        [ classes
            (if variant.highlight then
                [ Tw.border_2, Tw.border_simple TC.brandYellow, Tw.rounded_lg, Tw.overflow_hidden, Tw.ring_2, TwEx.ring_brand_yellow, Tw.ring_offset_2 ]

             else
                [ Tw.border, Tw.border_color (Th.gray Th.s200), Tw.rounded_lg, Tw.overflow_hidden ]
            )
        ]
        [ viewPreview variant
        , viewInfo variant
        ]


viewPreview : LogoVariant -> Html msg
viewPreview variant =
    let
        bgTw =
            if variant.theme == "dark" then
                [ Tw.bg_simple TC.brand ]

            else if variant.theme == "yellow" then
                [ Tw.bg_simple TC.brandYellow ]

            else
                [ Tw.bg_color (Th.gray Th.s50) ]

        previewSrc =
            case ( variant.gifUrl, variant.pngUrl, variant.svgUrl ) of
                ( Just gif, _, _ ) ->
                    gif

                ( _, Just png, _ ) ->
                    png

                ( _, _, Just svg ) ->
                    svg

                _ ->
                    ""
    in
    Html.div
        [ classes
            ([ Tw.flex
             , Tw.items_center
             , Tw.justify_center
             , Tw.p Th.s6
             , Tw.min_h Th.s44
             ]
                ++ bgTw
            )
        ]
        [ if String.isEmpty previewSrc then
            Html.text ""

          else
            Html.img
                [ Attr.src previewSrc
                , Attr.alt variant.description
                , classes [ Tw.max_w_full, Tw.max_h Th.s40, Tw.object_contain ]
                ]
                []
        ]


viewInfo : LogoVariant -> Html msg
viewInfo variant =
    Html.div
        [ classes [ Tw.p Th.s4, Tw.bg_color (Th.gray Th.s50), Tw.border_t, Tw.border_color (Th.gray Th.s100) ] ]
        [ Html.div [ classes [ Tw.mb Th.s3 ] ]
            [ Html.span [ classes [ Tw.type_body_small, Tw.text_simple TC.brand ] ]
                [ Html.text variant.description ]
            , if variant.highlight then
                Html.span
                    [ classes [ Tw.ml Th.s2, Tw.inline_block, Tw.bg_simple TC.brandYellow, Tw.text_simple TC.brand, Tw.text_xs, Tw.font_bold, Tw.px Th.s1_dot_5, Tw.py Th.s0_dot_5, Tw.rounded ] ]
                    [ Html.text "Suositeltu" ]

              else
                Html.text ""
            , if variant.animated then
                Html.span
                    [ classes [ Tw.ml Th.s2, Tw.inline_block, Tw.bg_simple TC.brand, Tw.text_simple TC.brandYellow, Tw.text_xs, Tw.font_bold, Tw.px Th.s1_dot_5, Tw.py Th.s0_dot_5, Tw.rounded ] ]
                    [ Html.text "ANI" ]

              else
                Html.text ""
            , if variant.bold then
                Html.span
                    [ classes [ Tw.ml Th.s2, Tw.inline_block, Tw.bg_color (Th.gray Th.s200), Tw.text_color (Th.gray Th.s700), Tw.text_xs, Tw.font_bold, Tw.px Th.s1_dot_5, Tw.py Th.s0_dot_5, Tw.rounded ] ]
                    [ Html.text "BOLD" ]

              else
                Html.text ""
            ]
        , Html.div [ classes [ Tw.flex, Tw.flex_wrap, Tw.gap Th.s2 ] ]
            (List.filterMap identity
                [ Maybe.map (\u -> DownloadButton.view { label = "SVG", href = u }) variant.svgUrl
                , Maybe.map (\u -> DownloadButton.view { label = "PNG", href = u }) variant.pngUrl
                , Maybe.map (\u -> DownloadButton.view { label = "WebP", href = u }) variant.webpUrl
                , Maybe.map (\u -> DownloadButton.view { label = "GIF", href = u }) variant.gifUrl
                ]
            )
        ]
