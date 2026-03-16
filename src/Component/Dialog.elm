module Component.Dialog exposing (view)

import Component.CloseButton as CloseButton
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
    Html.node "dialog"
        ([ Attr.class "rounded-xl shadow-xl p-0 max-w-lg w-full backdrop:bg-black/50 open:flex open:flex-col"
         , Events.on "cancel" (Json.Decode.succeed config.onClose)
         ]
            ++ (if config.isOpen then
                    [ Attr.attribute "open" "" ]

                else
                    []
               )
        )
        [ Html.div
            [ Attr.class "flex items-center justify-between px-6 py-4 border-b border-gray-200" ]
            [ Html.h2 [ Attr.class "text-lg font-semibold text-brand" ] [ Html.text config.title ]
            , CloseButton.view { onClick = config.onClose, label = "Sulje" }
            ]
        , Html.div [ Attr.class "px-6 py-4 flex-1" ] config.body
        , case config.footer of
            Nothing ->
                Html.text ""

            Just f ->
                Html.div [ Attr.class "px-6 py-4 border-t border-gray-200" ] [ f ]
        ]
