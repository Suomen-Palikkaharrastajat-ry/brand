module Component.Dialog exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode


view :
    { title : String
    , body : List (Html msg)
    , footer : Maybe (Html msg)
    , isOpen : Bool
    , onClose : msg
    }
    -> Html msg
view config =
    if config.isOpen then
        Html.div
            [ Attr.class "fixed inset-0 z-50 flex items-center justify-center" ]
            [ Html.div
                [ Attr.class "absolute inset-0 bg-black/50"
                , Events.onClick config.onClose
                ]
                []
            , Html.node "dialog"
                [ Attr.attribute "open" ""
                , Attr.class "relative rounded-xl shadow-xl p-0 max-w-lg w-full mx-4 flex flex-col z-10"
                , Events.on "cancel" (Json.Decode.succeed config.onClose)
                ]
                [ Html.div
                    [ Attr.class "flex items-center justify-between px-6 py-4" ]
                    [ Html.h2 [ Attr.class "text-lg font-semibold text-brand" ] [ Html.text config.title ]
                    , Html.button
                        [ Attr.type_ "button"
                        , Attr.class "inline-flex items-center justify-center w-11 h-11 rounded text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors cursor-pointer focus:outline-none focus:ring-2 focus:ring-brand"
                        , Attr.attribute "aria-label" "Sulje"
                        , Attr.attribute "autofocus" ""
                        , Events.onClick config.onClose
                        ]
                        [ Html.span [ Attr.attribute "aria-hidden" "true", Attr.class "text-lg leading-none" ]
                            [ Html.text "×" ]
                        ]
                    ]
                , Html.div [ Attr.class "px-6 py-4 flex-1" ] config.body
                , case config.footer of
                    Nothing ->
                        Html.text ""

                    Just f ->
                        Html.div [ Attr.class "px-6 py-4" ] [ f ]
                ]
            ]

    else
        Html.text ""
