module Component.DownloadButton exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : { label : String, href : String } -> Html msg
view { label, href } =
    Html.a
        [ Attr.href href
        , Attr.download ""
        , Attr.title href
        , Attr.class "inline-block bg-brand-yellow text-brand px-3 py-1.5 rounded text-sm font-semibold hover:opacity-90 transition-opacity"
        ]
        [ Html.text label ]
