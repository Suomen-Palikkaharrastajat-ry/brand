module Component.SectionHeader exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : { title : String, description : Maybe String } -> Html msg
view { title, description } =
    Html.div [ Attr.class "mb-6" ]
        (Html.h2 [ Attr.class "text-2xl font-bold text-brand" ] [ Html.text title ]
            :: (case description of
                    Just desc ->
                        [ Html.p [ Attr.class "mt-2 text-gray-600" ] [ Html.text desc ] ]

                    Nothing ->
                        []
               )
        )
