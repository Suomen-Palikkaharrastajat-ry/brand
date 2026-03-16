module Component.ColorSwatch exposing (ColorSwatchConfig, view)

import Html exposing (Html)
import Html.Attributes as Attr


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
            , viewContrastInfo config.hex
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


viewContrastInfo : String -> Html msg
viewContrastInfo hex =
    case parseHex hex of
        Nothing ->
            Html.text ""

        Just ( r, g, b ) ->
            let
                lColor =
                    luminance r g b

                lWhite =
                    1.0

                lDark =
                    case parseHex "#1A1A2E" of
                        Just ( dr, dg, db ) ->
                            luminance dr dg db

                        Nothing ->
                            0.0

                ratioVsWhite =
                    contrastRatio lColor lWhite

                ratioVsDark =
                    contrastRatio lColor lDark

                fmt ratio =
                    String.fromFloat (toFloat (round (ratio * 100)) / 100)

                grade ratio =
                    if ratio >= 7.0 then
                        "AAA ✓"

                    else if ratio >= 4.5 then
                        "AA ✓"

                    else if ratio >= 3.0 then
                        "AA-large ✓"

                    else
                        "✗"
            in
            Html.div [ Attr.class "space-y-0.5 mt-1" ]
                [ Html.div [ Attr.class "text-xs font-mono text-gray-400" ]
                    [ Html.text ("vs #FFF: " ++ fmt ratioVsWhite ++ " " ++ grade ratioVsWhite) ]
                , Html.div [ Attr.class "text-xs font-mono text-gray-400" ]
                    [ Html.text ("vs #1A1A2E: " ++ fmt ratioVsDark ++ " " ++ grade ratioVsDark) ]
                ]


parseHex : String -> Maybe ( Float, Float, Float )
parseHex hex =
    let
        h =
            String.dropLeft 1 hex

        rStr =
            String.slice 0 2 h

        gStr =
            String.slice 2 4 h

        bStr =
            String.slice 4 6 h
    in
    case ( hexToInt rStr, hexToInt gStr, hexToInt bStr ) of
        ( Just r, Just g, Just b ) ->
            Just ( toFloat r / 255, toFloat g / 255, toFloat b / 255 )

        _ ->
            Nothing


hexToInt : String -> Maybe Int
hexToInt s =
    String.foldl
        (\c acc ->
            Maybe.andThen
                (\a -> Maybe.map (\d -> a * 16 + d) (hexDigit c))
                acc
        )
        (Just 0)
        s


hexDigit : Char -> Maybe Int
hexDigit c =
    let
        code =
            Char.toCode c
    in
    if code >= 48 && code <= 57 then
        Just (code - 48)

    else if code >= 97 && code <= 102 then
        Just (code - 87)

    else if code >= 65 && code <= 70 then
        Just (code - 55)

    else
        Nothing


luminance : Float -> Float -> Float -> Float
luminance r g b =
    let
        lin c =
            if c <= 0.04045 then
                c / 12.92

            else
                ((c + 0.055) / 1.055) ^ 2.4
    in
    0.2126 * lin r + 0.7152 * lin g + 0.0722 * lin b


contrastRatio : Float -> Float -> Float
contrastRatio l1 l2 =
    let
        lighter =
            max l1 l2

        darker =
            min l1 l2
    in
    (lighter + 0.05) / (darker + 0.05)
