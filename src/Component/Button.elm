module Component.Button exposing (Size(..), Variant(..), view, viewLink)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events


type Variant
    = Primary
    | Secondary
    | Ghost
    | Danger


type Size
    = Small
    | Medium
    | Large


view : { label : String, variant : Variant, size : Size, onClick : msg, disabled : Bool, loading : Bool } -> Html msg
view config =
    let
        isInactive =
            config.disabled || config.loading

        baseAttrs =
            [ Attr.class
                (buttonClasses config.variant config.size
                    ++ (if isInactive then
                            " cursor-not-allowed opacity-50"

                        else
                            ""
                       )
                )
            , Attr.type_ "button"
            , Attr.disabled isInactive
            ]

        loadingAttrs =
            if config.loading then
                [ Attr.attribute "aria-busy" "true"
                , Attr.attribute "aria-label" config.label
                ]

            else
                []

        clickAttrs =
            if isInactive then
                []

            else
                [ Events.onClick config.onClick ]

        content =
            if config.loading then
                Html.div [ Attr.class "flex items-center gap-1" ]
                    [ Html.span
                        [ Attr.class "w-1.5 h-1.5 rounded-full bg-current animate-bounce"
                        , Attr.style "animation-delay" "0ms"
                        ]
                        []
                    , Html.span
                        [ Attr.class "w-1.5 h-1.5 rounded-full bg-current animate-bounce"
                        , Attr.style "animation-delay" "150ms"
                        ]
                        []
                    , Html.span
                        [ Attr.class "w-1.5 h-1.5 rounded-full bg-current animate-bounce"
                        , Attr.style "animation-delay" "300ms"
                        ]
                        []
                    ]

            else
                Html.text config.label
    in
    Html.button
        (baseAttrs ++ loadingAttrs ++ clickAttrs)
        [ content ]


viewLink : { label : String, variant : Variant, size : Size, href : String } -> Html msg
viewLink config =
    Html.a
        [ Attr.href config.href
        , Attr.class (buttonClasses config.variant config.size)
        ]
        [ Html.text config.label ]


buttonClasses : Variant -> Size -> String
buttonClasses variant size =
    "inline-flex items-center justify-center font-semibold rounded transition-all cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-2 "
        ++ variantClasses variant
        ++ " "
        ++ sizeClasses size


variantClasses : Variant -> String
variantClasses variant =
    case variant of
        Primary ->
            "bg-brand-yellow text-brand hover:opacity-90 focus:ring-brand-yellow"

        Secondary ->
            "bg-white text-brand border border-brand hover:bg-gray-50 focus:ring-brand"

        Ghost ->
            "bg-transparent text-brand hover:bg-brand/5 focus:ring-brand"

        Danger ->
            "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"


sizeClasses : Size -> String
sizeClasses size =
    case size of
        Small ->
            "px-3 py-1.5 text-sm"

        Medium ->
            "px-4 py-2 text-sm"

        Large ->
            "px-6 py-3 text-base"
