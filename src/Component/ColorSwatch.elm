module Component.ColorSwatch exposing (ColorSwatchConfig, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


type alias ColorSwatchConfig =
    { hex : String
    , name : String
    , description : String
    , usageTags : List String
    }


view : ColorSwatchConfig -> Html msg
view config =
    Html.div
        [ Attr.class "flex flex-col gap-2 min-w-36" ]
        [ Html.div
            [ Attr.class "h-20 rounded-lg border border-black/10 shadow-sm"
            , Attr.style "background-color" config.hex
            ]
            []
        , Html.div [ Attr.class "space-y-1" ]
            [ Html.div [ Attr.class "font-semibold text-sm text-brand" ]
                [ Html.text config.name ]
            , Html.div [ Attr.class "font-mono text-xs text-gray-500" ]
                [ Html.text config.hex ]
            , if String.isEmpty config.description then
                Html.text ""

              else
                Html.div [ Attr.class "text-xs text-gray-400" ]
                    [ Html.text config.description ]
            , if List.isEmpty config.usageTags then
                Html.text ""

              else
                Html.div [ Attr.class "flex flex-wrap gap-1 mt-1" ]
                    (List.map viewTag config.usageTags)
            ]
        ]


viewTag : String -> Html msg
viewTag tag =
    Html.span
        [ Attr.class "text-xs bg-brand/10 text-brand px-2 py-0.5 rounded-full" ]
        [ Html.text tag ]
