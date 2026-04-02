module Component.SectionHeader exposing (view, viewSub)

{-| Section heading components — top-level `h2` with optional description, plus a sub-section `h3` variant.
-}

import Html exposing (Html)
import Tailwind as Tw exposing (classes)
import Tailwind.Theme as Th
import TailwindTokens as TC


{-| Top-level section heading (h2). Use directly under the page h1.
-}
view : { title : String, description : Maybe String } -> Html msg
view { title, description } =
    Html.div [ classes [ Tw.mb Th.s6 ] ]
        (Html.h2 [ classes [ Tw.type_h2, Tw.text_simple TC.brand ] ] [ Html.text title ]
            :: (case description of
                    Just desc ->
                        [ Html.p [ classes [ Tw.mt Th.s2, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text desc ] ]

                    Nothing ->
                        []
               )
        )


{-| Sub-section heading (h3). Use inside a section that already has an h2.
-}
viewSub : { title : String, description : Maybe String } -> Html msg
viewSub { title, description } =
    Html.div [ classes [ Tw.mb Th.s4 ] ]
        (Html.h3 [ classes [ Tw.type_h4, Tw.text_simple TC.brand ] ] [ Html.text title ]
            :: (case description of
                    Just desc ->
                        [ Html.p [ classes [ Tw.mt Th.s1, Tw.text_color (Th.gray Th.s600), Tw.text_sm ] ] [ Html.text desc ] ]

                    Nothing ->
                        []
               )
        )
