module Component.Pagination exposing (view)

{-| Pagination controls component.
-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindTokens as TC


view :
    { currentPage : Int
    , totalPages : Int
    , onPageClick : Int -> msg
    }
    -> Html msg
view config =
    Html.nav
        [ Attr.attribute "aria-label" "Sivutus" ]
        [ Html.ul
            [ classes [ Tw.inline_flex, Tw.items_center, Tw.gap Th.s1, Tw.text_sm ] ]
            (prevButton config
                :: List.map (pageButton config) (List.range 1 config.totalPages)
                ++ [ nextButton config ]
            )
        ]


prevButton : { currentPage : Int, totalPages : Int, onPageClick : Int -> msg } -> Html msg
prevButton config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , classes (navBtnTw (config.currentPage <= 1))
            , Attr.disabled (config.currentPage <= 1)
            , Events.onClick (config.onPageClick (config.currentPage - 1))
            , Attr.attribute "aria-label" "Edellinen"
            ]
            [ Html.text "‹" ]
        ]


nextButton : { currentPage : Int, totalPages : Int, onPageClick : Int -> msg } -> Html msg
nextButton config =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , classes (navBtnTw (config.currentPage >= config.totalPages))
            , Attr.disabled (config.currentPage >= config.totalPages)
            , Events.onClick (config.onPageClick (config.currentPage + 1))
            , Attr.attribute "aria-label" "Seuraava"
            ]
            [ Html.text "›" ]
        ]


pageButton : { currentPage : Int, totalPages : Int, onPageClick : Int -> msg } -> Int -> Html msg
pageButton config page =
    Html.li []
        [ Html.button
            [ Attr.type_ "button"
            , classes (pageBtnTw (page == config.currentPage))
            , Events.onClick (config.onPageClick page)
            , Attr.attribute "aria-current"
                (if page == config.currentPage then
                    "page"

                 else
                    "false"
                )
            ]
            [ Html.text (String.fromInt page) ]
        ]


pageBtnTw : Bool -> List Tw.Tailwind
pageBtnTw active =
    [ Tw.w Th.s9
    , Tw.h Th.s9
    , Tw.flex
    , Tw.items_center
    , Tw.justify_center
    , Tw.rounded_md
    , Tw.type_body_small
    , Tw.transition_colors
    , Tw.cursor_pointer
    ]
        ++ (if active then
                [ Tw.bg_simple TC.brand, Tw.text_simple Th.white ]

            else
                [ Tw.text_color (Th.gray Th.s700), Bp.hover [ Tw.bg_color (Th.gray Th.s100) ] ]
           )


navBtnTw : Bool -> List Tw.Tailwind
navBtnTw isDisabled =
    [ Tw.w Th.s9
    , Tw.h Th.s9
    , Tw.flex
    , Tw.items_center
    , Tw.justify_center
    , Tw.rounded_md
    , Tw.text_sm
    , Tw.transition_colors
    ]
        ++ (if isDisabled then
                [ Tw.text_color (Th.gray Th.s300), Tw.cursor_not_allowed ]

            else
                [ Tw.text_color (Th.gray Th.s700), Bp.hover [ Tw.bg_color (Th.gray Th.s100) ], Tw.cursor_pointer ]
           )
