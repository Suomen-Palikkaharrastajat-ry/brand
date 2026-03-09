module Route.Varit exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Brand.Colors as Colors
import Component.ColorSwatch as ColorSwatch
import Component.SectionHeader as SectionHeader
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
        , description = "Suomen Palikkaharrastajat ry:n merkkivärit, ihonsävyt ja sateenkaarivärit."
        , locale = Nothing
        , title = "Värit — " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Värit — " ++ SiteMeta.organizationName
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-12 space-y-16" ]
            [ Html.h1 [ Attr.class "text-3xl font-bold text-brand" ] [ Html.text "Värit" ]
            , viewBrandColors
            , viewSkinTones
            , viewRainbowColors
            ]
        ]
    }


viewBrandColors : Html msg
viewBrandColors =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Merkkivärit"
            , description = Just "Yhdistyksen viralliset päävärit."
            }
        , Html.div [ Attr.class "flex flex-wrap gap-6" ]
            (List.map
                (\c ->
                    ColorSwatch.view
                        { hex = c.hex
                        , name = c.name
                        , description = ""
                        , usageTags = c.usage
                        }
                )
                Colors.brandColors
            )
        ]


viewSkinTones : Html msg
viewSkinTones =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Ihoteemat"
            , description = Just "Neljä virallista LEGO®-ihonsävyä edustavat erilaisia ihonsävyjä."
            }
        , Html.div [ Attr.class "flex flex-wrap gap-6" ]
            (List.map
                (\c ->
                    ColorSwatch.view
                        { hex = c.hex
                        , name = c.name
                        , description = c.description
                        , usageTags = []
                        }
                )
                Colors.skinTones
            )
        ]


viewRainbowColors : Html msg
viewRainbowColors =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Sateenkaari"
            , description = Just "Sateenkaarilogoissa käytetyt seitsemän väriä."
            }
        , Html.div [ Attr.class "flex flex-wrap gap-6" ]
            (List.map
                (\c ->
                    ColorSwatch.view
                        { hex = c.hex
                        , name = c.name
                        , description = c.description
                        , usageTags = []
                        }
                )
                Colors.rainbowColors
            )
        ]
