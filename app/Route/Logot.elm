module Route.Logot exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Brand.Logos as Logos
import Component.LogoCard as LogoCard
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
        , description = "Suomen Palikkaharrastajat ry:n logot — neliö-, vaaka- ja sateenkaarivariantit."
        , locale = Nothing
        , title = "Logot — " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Logot — " ++ SiteMeta.organizationName
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-12 space-y-16" ]
            [ Html.h1 [ Attr.class "text-3xl font-bold text-brand" ] [ Html.text "Logot" ]
            , viewSquareSection
            , viewHorizontalSection
            ]
        ]
    }


viewSquareSection : Html msg
viewSquareSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Neliö (square)"
            , description = Just "Tunnuskuva on LEGO-minihahmon pää rakennuspalikoista koottuna. Neliömuoto sopii sosiaalisen median profiileihin ja sovelluskuvakkeisiin."
            }
        , Html.div
            [ Attr.class "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4" ]
            (List.map LogoCard.view Logos.squareVariants)
        ]


viewHorizontalSection : Html msg
viewHorizontalSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Vaakasuuntainen (horizontal)"
            , description = Just "Neljä minihahmon päätä vierekkäin rakennuspalikoista koottuna. Vaakaversio tekstillä sopii esitteisiin, nettisivuille ja muihin konteksteihin."
            }
        , Html.div
            [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-4" ]
            (List.map LogoCard.view Logos.horizontalVariants)
        ]
