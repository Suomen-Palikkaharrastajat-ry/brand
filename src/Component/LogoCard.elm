module Component.LogoCard exposing (LogoVariant, view)

import Component.DownloadButton as DownloadButton
import Html exposing (Html)
import Html.Attributes as Attr


type alias LogoVariant =
    { id : String
    , description : String
    , theme : String
    , animated : Bool
    , withText : Bool
    , svgUrl : Maybe String
    , pngUrl : Maybe String
    , webpUrl : Maybe String
    , gifUrl : Maybe String
    }


view : LogoVariant -> Html msg
view variant =
    Html.div
        [ Attr.class "border border-gray-200 rounded-lg overflow-hidden hover:-translate-y-1 hover:shadow-lg transition-all" ]
        [ viewPreview variant
        , viewInfo variant
        ]


viewPreview : LogoVariant -> Html msg
viewPreview variant =
    let
        bgClass =
            if variant.theme == "dark" then
                "bg-brand"

            else
                "bg-gray-50"

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
        [ Attr.class ("flex items-center justify-center p-6 min-h-44 " ++ bgClass) ]
        [ if String.isEmpty previewSrc then
            Html.text ""

          else
            Html.img
                [ Attr.src previewSrc
                , Attr.alt variant.description
                , Attr.class "max-w-full max-h-40 object-contain"
                ]
                []
        ]


viewInfo : LogoVariant -> Html msg
viewInfo variant =
    Html.div
        [ Attr.class "p-4 bg-gray-50 border-t border-gray-100" ]
        [ Html.div [ Attr.class "mb-3" ]
            [ Html.span [ Attr.class "font-semibold text-sm text-brand" ]
                [ Html.text variant.description ]
            , if variant.animated then
                Html.span
                    [ Attr.class "ml-2 inline-block bg-brand text-brand-yellow text-xs font-bold px-1.5 py-0.5 rounded" ]
                    [ Html.text "ANI" ]

              else
                Html.text ""
            ]
        , Html.div [ Attr.class "flex flex-wrap gap-2" ]
            (List.filterMap identity
                [ Maybe.map (\u -> DownloadButton.view { label = "SVG", href = u }) variant.svgUrl
                , Maybe.map (\u -> DownloadButton.view { label = "PNG", href = u }) variant.pngUrl
                , Maybe.map (\u -> DownloadButton.view { label = "WebP", href = u }) variant.webpUrl
                , Maybe.map (\u -> DownloadButton.view { label = "GIF", href = u }) variant.gifUrl
                ]
            )
        ]
