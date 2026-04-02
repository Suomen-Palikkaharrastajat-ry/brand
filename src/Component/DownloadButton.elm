module Component.DownloadButton exposing (view)

{-| File-download button component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view : { label : String, href : String } -> Html msg
view { label, href } =
    Html.a
        [ Attr.href href
        , Attr.download ""
        , Attr.title href
        , classes
            [ Tw.inline_block
            , Tw.bg_simple TC.brandYellow
            , Tw.text_simple TC.brand
            , Tw.px Th.s3
            , Tw.py Th.s1_dot_5
            , Tw.rounded
            , Tw.type_body_small
            , Tw.cursor_pointer
            , Bp.hover [ Tw.opacity_90 ]
            , Tw.transition_opacity
            ]
        ]
        [ Html.text label ]
