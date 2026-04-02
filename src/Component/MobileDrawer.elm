module Component.MobileDrawer exposing (Breakpoint(..), NavLink, view, viewNavLink, viewOverlay)

{-| Slide-in navigation drawer for mobile viewports.

Provides three primitives that callers compose:

  - `viewOverlay` — the clickable backdrop behind the drawer
  - `view` — the slide-in panel container (accepts arbitrary content)
  - `viewNavLink` — a single navigation link with active indicator dot and keyboard focus ring

-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC


{-| The responsive breakpoint above which the drawer (and overlay) are hidden.
-}
type Breakpoint
    = Sm
    | Md
    | Lg


breakpointTw : Breakpoint -> Tw.Tailwind
breakpointTw bp =
    case bp of
        Sm ->
            Bp.sm [ Tw.hidden ]

        Md ->
            Bp.md [ Tw.hidden ]

        Lg ->
            Bp.lg [ Tw.hidden ]


{-| Configuration for a single navigation link inside the drawer.
-}
type alias NavLink msg =
    { href : String
    , label : String
    , isActive : Bool
    , onClose : msg
    }


{-| Clickable semi-transparent backdrop. Place it in the DOM before `view`
so the drawer renders on top.
-}
viewOverlay : { isOpen : Bool, onClose : msg, breakpoint : Breakpoint } -> Html msg
viewOverlay config =
    if config.isOpen then
        Html.div
            [ classes [ breakpointTw config.breakpoint, Tw.fixed, TwEx.inset_0, Tw.z_40, TwEx.bg_black_50 ]
            , Html.Events.onClick config.onClose
            ]
            []

    else
        Html.text ""


{-| Slide-in drawer panel. Supply navigation markup (and any extra content such
as auth controls) via `content`.
-}
view :
    { isOpen : Bool
    , id : String
    , onClose : msg
    , breakpoint : Breakpoint
    , content : List (Html msg)
    }
    -> Html msg
view config =
    Html.div
        [ classes
            [ breakpointTw config.breakpoint
            , Tw.fixed
            , TwEx.inset_y_0
            , TwEx.left_0
            , Tw.w Th.s64
            , Tw.bg_simple Th.white
            , Tw.shadow_lg
            , Tw.z_50
            , Tw.transform
            , Tw.overflow_y_auto
            , Tw.transition_transform
            , Tw.duration_300
            , Tw.ease_in_out
            , Bp.withVariant "motion-reduce" [ Tw.transition_none ]
            , if config.isOpen then
                TwEx.translate_x_0

              else
                Tw.neg_translate_x_full
            ]
        , Attr.id config.id
        ]
        (Html.button
            [ Html.Events.onClick config.onClose
            , classes [ Tw.sr_only ]
            , Attr.attribute "aria-label" "Sulje valikko"
            ]
            [ Html.text "Sulje valikko" ]
            :: config.content
        )


{-| A `<li>` containing a navigation anchor.

  - Active link: yellow indicator dot on the left + `id="mobile-nav-active"`
    (the `focusMobileNav` port scrolls this into view when the drawer opens)
  - Keyboard focus: `focus-visible:ring` only — no ring on mouse/touch

-}
viewNavLink : NavLink msg -> Html msg
viewNavLink config =
    Html.li []
        [ Html.a
            ([ Attr.href config.href
             , classes
                [ Tw.flex
                , Tw.items_center
                , Tw.gap Th.s2
                , Tw.text_simple TC.brand
                , Tw.font_medium
                , Tw.px Th.s3
                , Tw.py Th.s2
                , Tw.rounded
                , Bp.hover [ Tw.bg_color (Th.gray Th.s100) ]
                , Tw.transition_colors
                , Tw.text_sm
                , Bp.focus_visible [ Tw.outline_none, Tw.ring_2, TwEx.ring_brand_yellow ]
                ]
             , Html.Events.onClick config.onClose
             ]
                ++ (if config.isActive then
                        [ Attr.id "mobile-nav-active" ]

                    else
                        []
                   )
            )
            [ Html.span
                [ classes
                    ([ Tw.w Th.s2, Tw.h Th.s2, Tw.rounded_full, Tw.shrink_0 ]
                        ++ (if config.isActive then
                                [ Tw.bg_simple TC.brandYellow ]

                            else
                                [ Tw.invisible ]
                           )
                    )
                ]
                []
            , Html.text config.label
            ]
        ]
