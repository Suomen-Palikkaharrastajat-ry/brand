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


{-| The responsive breakpoint above which the drawer (and overlay) are hidden.
Maps to a Tailwind hidden utility so all class strings appear literally in source
for JIT purging.
-}
type Breakpoint
    = Sm
    | Md
    | Lg


breakpointClass : Breakpoint -> String
breakpointClass bp =
    case bp of
        Sm ->
            "sm:hidden "

        Md ->
            "md:hidden "

        Lg ->
            "lg:hidden "


{-| Configuration for a single navigation link inside the drawer. -}
type alias NavLink msg =
    { href : String
    , label : String
    , isActive : Bool
    , onClose : msg
    }


{-| Clickable semi-transparent backdrop. Place it in the DOM before `view`
so the drawer renders on top. -}
viewOverlay : { isOpen : Bool, onClose : msg, breakpoint : Breakpoint } -> Html msg
viewOverlay config =
    if config.isOpen then
        Html.div
            [ Attr.class (breakpointClass config.breakpoint ++ "fixed inset-0 z-40")
            , Html.Events.onClick config.onClose
            ]
            []

    else
        Html.text ""


{-| Slide-in drawer panel. Supply navigation markup (and any extra content such
as auth controls) via `content`. -}
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
        [ Attr.class
            (breakpointClass config.breakpoint
                ++ "fixed inset-y-0 left-0 w-64 bg-white shadow-lg z-50 "
                ++ "transform overflow-y-auto transition-transform duration-300 ease-in-out motion-reduce:transition-none "
                ++ (if config.isOpen then
                        "translate-x-0"

                    else
                        "-translate-x-full"
                   )
            )
        , Attr.id config.id
        ]
        (Html.button
            [ Html.Events.onClick config.onClose
            , Attr.class "sr-only"
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
             , Attr.class "flex items-center gap-2 text-brand font-medium px-3 py-2 rounded hover:bg-gray-100 transition-colors text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-yellow"
             , Html.Events.onClick config.onClose
             ]
                ++ (if config.isActive then
                        [ Attr.id "mobile-nav-active" ]

                    else
                        []
                   )
            )
            [ Html.span
                [ Attr.class
                    (if config.isActive then
                        "w-2 h-2 rounded-full bg-brand-yellow flex-shrink-0"

                     else
                        "w-2 h-2 rounded-full flex-shrink-0 invisible"
                    )
                ]
                []
            , Html.text config.label
            ]
        ]
