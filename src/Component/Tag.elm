module Component.Tag exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


view : { label : String, onRemove : Maybe msg } -> Html msg
view config =
    Html.span
        [ Attr.class "inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-medium bg-brand/10 text-brand" ]
        (Html.text config.label
            :: (case config.onRemove of
                    Nothing ->
                        []

                    Just msg ->
                        [ Html.button
                            [ Attr.type_ "button"
                            , Attr.attribute "aria-label" ("Poista " ++ config.label)
                            , Attr.class "ml-0.5 inline-flex items-center justify-center w-3.5 h-3.5 rounded-full hover:bg-brand/20 transition-colors cursor-pointer"
                            , Events.onClick msg
                            ]
                            [ Html.span [ Attr.attribute "aria-hidden" "true" ] [ Html.text "×" ] ]
                        ]
               )
        )
