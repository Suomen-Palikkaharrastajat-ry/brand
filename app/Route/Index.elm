module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Brand.Colors as Colors
import Component.ColorSwatch as ColorSwatch
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : RouteBuilder.StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = SiteMeta.organizationName
        , image =
            { url = Pages.Url.external "https://logo.palikkaharrastajat.fi/logo/horizontal/png/horizontal-full.png"
            , alt = SiteMeta.organizationName
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = SiteMeta.description
        , locale = Nothing
        , title = SiteMeta.siteTitle
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = SiteMeta.siteTitle
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-12 space-y-16" ]
            [ viewHero
            , viewQuickColors
            , viewSectionLinks
            ]
        ]
    }


viewHero : Html msg
viewHero =
    Html.section [ Attr.class "text-center space-y-6" ]
        [ Html.div [ Attr.class "flex justify-center" ]
            [ Html.img
                [ Attr.src "/logo/square/png/square-animated.gif"
                , Attr.alt "Suomen Palikkaharrastajat ry — animoitu logo"
                , Attr.class "w-40 h-40 object-contain"
                ]
                []
            ]
        , Html.h1 [ Attr.class "text-3xl font-bold text-brand" ]
            [ Html.text "Suomen Palikkaharrastajat ry" ]
        , Html.p [ Attr.class "text-xl text-gray-500 font-light" ]
            [ Html.text "Logo ja värit" ]
        , Html.p [ Attr.class "max-w-xl mx-auto text-gray-600" ]
            [ Html.text "Brändiohjeistus sisältää logot, värit ja typografian. Kaikki materiaalit ovat vapaasti ladattavissa." ]
        ]


viewQuickColors : Html msg
viewQuickColors =
    Html.section [ Attr.class "space-y-4" ]
        [ Html.h2 [ Attr.class "text-lg font-semibold text-brand/60 uppercase tracking-wider text-center" ]
            [ Html.text "Merkkivärit" ]
        , Html.div [ Attr.class "flex flex-wrap justify-center gap-6" ]
            (List.map
                (\c ->
                    ColorSwatch.view
                        { hex = c.hex
                        , name = c.name
                        , description = ""
                        , usageTags = []
                        }
                )
                Colors.brandColors
            )
        ]


viewSectionLinks : Html msg
viewSectionLinks =
    Html.section [ Attr.class "grid grid-cols-1 sm:grid-cols-3 gap-6" ]
        [ viewLinkCard
            { href = "/logot"
            , title = "Logot"
            , description = "Neliö-, vaaka- ja sateenkaarivariantit kaikissa muodoissa"
            , icon = "🧱"
            }
        , viewLinkCard
            { href = "/varit"
            , title = "Värit"
            , description = "Merkkivärit, ihonsävyt ja sateenkaarivärit"
            , icon = "🎨"
            }
        , viewLinkCard
            { href = "/typografia"
            , title = "Typografia"
            , description = "Outfit-fontti — paino 100–900"
            , icon = "✏️"
            }
        ]


viewLinkCard : { href : String, title : String, description : String, icon : String } -> Html msg
viewLinkCard { href, title, description, icon } =
    Html.a
        [ Attr.href href
        , Attr.class "block border border-gray-200 rounded-xl p-6 hover:border-brand-yellow hover:shadow-md transition-all group"
        ]
        [ Html.div [ Attr.class "text-3xl mb-3" ] [ Html.text icon ]
        , Html.h3 [ Attr.class "text-lg font-bold text-brand group-hover:text-brand-yellow transition-colors" ]
            [ Html.text title ]
        , Html.p [ Attr.class "mt-1 text-sm text-gray-500" ]
            [ Html.text description ]
        ]
