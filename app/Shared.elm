module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

{-| elm-pages shared layout — top-level shell wrapping every page (navbar + footer).
-}

import BackendTask exposing (BackendTask)
import Browser.Events
import Component.MobileDrawer as MobileDrawer
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Ports
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type alias Data =
    ()


type SharedMsg
    = NoOp
    | ToggleMenu
    | CloseMenu


type Msg
    = SharedMsg SharedMsg


type alias Model =
    { menuOpen : Bool }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : Maybe Route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init _ _ =
    ( { menuOpen = False }, Effect.none )


update : Msg -> Model -> ( Model, Effect msg )
update msg model =
    case msg of
        SharedMsg ToggleMenu ->
            if model.menuOpen then
                ( { model | menuOpen = False }, Effect.none )

            else
                ( { model | menuOpen = True }, Effect.fromCmd (Ports.focusMobileNav ()) )

        SharedMsg CloseMenu ->
            ( { model | menuOpen = False }, Effect.none )

        SharedMsg _ ->
            ( model, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ model =
    if model.menuOpen then
        Browser.Events.onKeyDown
            (Json.Decode.field "key" Json.Decode.string
                |> Json.Decode.andThen
                    (\key ->
                        if key == "Escape" then
                            Json.Decode.succeed (SharedMsg CloseMenu)

                        else
                            Json.Decode.fail "not escape"
                    )
            )

    else
        Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    -> { path : UrlPath, route : Maybe Route }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view _ page model toMsg pageView =
    { title = pageView.title
    , body =
        [ Html.div [ classes [ Tw.min_h_screen, Tw.flex, Tw.flex_col, Tw.font_sans ] ]
            [ viewNavbar model (toMsg << SharedMsg)
            , Html.main_ [ classes [ Tw.flex_1 ] ] pageView.body
            , viewFooter
            , MobileDrawer.viewOverlay { isOpen = model.menuOpen, onClose = toMsg (SharedMsg CloseMenu), breakpoint = MobileDrawer.Sm }
            , viewMobileDrawer page.path model (toMsg << SharedMsg)
            ]
        ]
    }


viewNavbar : Model -> (SharedMsg -> msg) -> Html msg
viewNavbar model toMsg =
    Html.nav
        [ classes
            [ Tw.bg_simple TC.brand
            , Tw.sticky
            , TwEx.top_0
            , Tw.z_50
            , Tw.shadow_md
            , Bp.sm [ Tw.static, Tw.top_auto, Tw.z_auto, Tw.shadow_none ]
            ]
        ]
        [ Html.div
            [ classes [ TwEx.max_w_5xl, Tw.mx_auto, Tw.px Th.s4 ] ]
            [ Html.div
                [ classes [ Tw.flex, Tw.items_center, Tw.py Th.s2, Bp.sm [ Tw.py Th.s3 ] ] ]
                [ Html.a
                    [ Attr.href "/"
                    , classes [ Tw.shrink_0, Tw.mr_auto, Bp.focus [ Tw.outline_none, Tw.ring_2, TwEx.ring_brand_yellow ], Tw.rounded ]
                    , Html.Events.onClick (toMsg CloseMenu)
                    ]
                    [ Html.node "picture"
                        []
                        [ Html.node "source"
                            [ Attr.attribute "media" "(min-width: 640px)"
                            , Attr.attribute "srcset" "/logo/horizontal/svg/horizontal-full-dark-bold.svg"
                            ]
                            []
                        , Html.img
                            [ Attr.src "/logo/horizontal/svg/horizontal.svg"
                            , Attr.alt "Suomen Palikkaharrastajat ry"
                            , classes [ Tw.h Th.s10, Bp.sm [ Tw.h Th.s14 ] ]
                            ]
                            []
                        ]
                    ]
                , Html.button
                    [ classes
                        [ Bp.sm [ Tw.hidden ]
                        , Tw.text_simple Th.white
                        , Tw.p Th.s2
                        , Tw.ml Th.s2
                        , Tw.rounded
                        , Bp.focus [ Tw.outline_none, Tw.ring_2, TwEx.ring_brand_yellow ]
                        , Tw.cursor_pointer
                        ]
                    , Html.Events.onClick (toMsg ToggleMenu)
                    , Attr.attribute "aria-label"
                        (if model.menuOpen then
                            "Sulje valikko"

                         else
                            "Avaa valikko"
                        )
                    , Attr.attribute "aria-expanded"
                        (if model.menuOpen then
                            "true"

                         else
                            "false"
                        )
                    , Attr.attribute "aria-controls" "mobile-nav"
                    ]
                    [ if model.menuOpen then
                        FeatherIcons.x |> FeatherIcons.withSize 24 |> FeatherIcons.toHtml []

                      else
                        FeatherIcons.menu |> FeatherIcons.withSize 24 |> FeatherIcons.toHtml []
                    ]
                , Html.ul
                    [ classes [ Tw.hidden, Bp.sm [ Tw.flex ], Tw.flex_wrap, Tw.gap Th.s0_dot_5, Tw.list_none, Tw.m Th.s0, Tw.p Th.s0 ] ]
                    [ desktopNavLink "/typografia" "Typografia"
                    , desktopNavLink "/komponentit" "Komponentit"
                    , desktopNavLink "/responsiivisuus" "Responsiivisuus"
                    , desktopNavLink "/saavutettavuus" "Saavutettavuus"
                    ]
                ]
            ]
        ]


desktopNavLink : String -> String -> Html msg
desktopNavLink href label =
    Html.li []
        [ Html.a
            [ Attr.href href
            , classes
                [ TwEx.text_white_80
                , Bp.hover [ Tw.text_simple TC.brandYellow ]
                , Tw.font_medium
                , Tw.px Th.s2
                , Bp.sm [ Tw.px Th.s3 ]
                , Tw.py Th.s1
                , Tw.rounded
                , Tw.transition_colors
                , Tw.text_sm
                , Tw.cursor_pointer
                , Bp.focus [ Tw.outline_none, Tw.ring_2, TwEx.ring_brand_yellow ]
                ]
            ]
            [ Html.text label ]
        ]


viewMobileDrawer : UrlPath -> Model -> (SharedMsg -> msg) -> Html msg
viewMobileDrawer currentPath model toMsg =
    let
        isActive href =
            "/" ++ UrlPath.toRelative currentPath == href

        close =
            toMsg CloseMenu
    in
    MobileDrawer.view
        { isOpen = model.menuOpen
        , id = "mobile-nav"
        , onClose = close
        , breakpoint = MobileDrawer.Sm
        , content =
            [ Html.nav [ classes [ Tw.p Th.s4 ] ]
                [ Html.ul [ classes [ Tw.flex, Tw.flex_col, Tw.gap Th.s1, Tw.list_none, Tw.m Th.s0, Tw.p Th.s0 ] ]
                    [ MobileDrawer.viewNavLink { href = "/", label = "Logot ja värit", isActive = isActive "/", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/typografia", label = "Typografia", isActive = isActive "/typografia", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/komponentit", label = "Komponentit", isActive = isActive "/komponentit", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/responsiivisuus", label = "Responsiivisuus", isActive = isActive "/responsiivisuus", onClose = close }
                    , MobileDrawer.viewNavLink { href = "/saavutettavuus", label = "Saavutettavuus", isActive = isActive "/saavutettavuus", onClose = close }
                    ]
                ]
            ]
        }


viewFooter : Html msg
viewFooter =
    Html.footer
        [ classes [ Tw.bg_simple TC.brand, Tw.text_simple Th.white, Tw.mt Th.s16, Tw.py Th.s12, Tw.px Th.s4 ] ]
        [ Html.div
            [ classes [ TwEx.max_w_5xl, Tw.mx_auto ] ]
            [ Html.div
                [ classes [ Tw.grid, Tw.grid_cols_1, Bp.sm [ Tw.grid_cols_2, Tw.items_end ], Tw.gap Th.s8 ] ]
                [ -- Col 1: service links + logo
                  Html.div [ classes [ Tw.flex, Tw.items_start, Tw.gap Th.s4 ] ]
                    [ Html.img
                        [ Attr.src "/logo/square/svg/square-smile-full-dark-bold.svg"
                        , Attr.alt ""
                        , Attr.attribute "aria-hidden" "true"
                        , classes [ TwEx.h_35, TwEx.w_35, Tw.shrink_0 ]
                        ]
                        []
                    , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
                        [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, TwEx.text_white_50, Tw.uppercase, Tw.tracking_wider ] ]
                            [ Html.text "Palikkaharrastajat" ]
                        , Html.ul [ classes [ TwEx.space_y Th.s2, Tw.list_none, Tw.m Th.s0, Tw.p Th.s0 ] ]
                            [ Html.li []
                                [ Html.a
                                    [ Attr.href "https://palikkaharrastajat.fi"
                                    , classes [ Tw.text_sm, TwEx.text_white_80, Bp.hover [ Tw.text_simple Th.white ], Tw.underline, Tw.transition_colors ]
                                    ]
                                    [ Html.text "Kotisivut" ]
                                ]
                            , Html.li []
                                [ Html.a
                                    [ Attr.href "https://kalenteri.palikkaharrastajat.fi"
                                    , classes [ Tw.text_sm, TwEx.text_white_80, Bp.hover [ Tw.text_simple Th.white ], Tw.underline, Tw.transition_colors ]
                                    ]
                                    [ Html.text "Palikkakalenteri" ]
                                ]
                            , Html.li []
                                [ Html.a
                                    [ Attr.href "https://linkit.palikkaharrastajat.fi"
                                    , classes [ Tw.text_sm, TwEx.text_white_80, Bp.hover [ Tw.text_simple Th.white ], Tw.underline, Tw.transition_colors ]
                                    ]
                                    [ Html.text "Palikkalinkit" ]
                                ]
                            ]
                        ]
                    ]
                , -- Col 2: org name & legal
                  Html.div [ classes [ TwEx.space_y Th.s1, Bp.sm [ Tw.text_right ] ] ]
                    [ Html.div [ classes [ TwEx.space_y Th.s1, Tw.text_xs, TwEx.text_white_50 ] ]
                        [ Html.p [] [ Html.text "© 2026 Suomen Palikkaharrastajat ry" ]
                        , Html.p [] [ Html.text "Fontit: Outfit (SIL Open Font License)" ]
                        , Html.p [] [ Html.text "LEGO® on LEGO Groupin rekisteröity tavaramerkki" ]
                        , Html.p []
                            [ Html.a
                                [ Attr.href "/design-guide/index.jsonld"
                                , Attr.title "Machine readable Design Guide in JSON-LD"
                                , classes [ Tw.underline, Bp.hover [ TwEx.text_white_80 ], Tw.transition_colors ]
                                ]
                                [ Html.text "JSON-LD" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
