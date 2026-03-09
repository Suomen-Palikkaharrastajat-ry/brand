module Route.Typografia exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
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
        , description = "Suomen Palikkaharrastajat ry:n typografia — Outfit-fontti."
        , locale = Nothing
        , title = "Typografia — " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Typografia — " ++ SiteMeta.organizationName
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-12 space-y-12" ]
            [ Html.h1 [ Attr.class "text-3xl font-bold text-brand" ] [ Html.text "Typografia" ]
            , viewFontInfo
            , viewWeightSpecimens
            ]
        ]
    }


viewFontInfo : Html msg
viewFontInfo =
    Html.section [ Attr.class "bg-white border border-gray-200 rounded-xl p-6 space-y-4" ]
        [ Html.div [ Attr.class "flex items-start justify-between flex-wrap gap-4" ]
            [ Html.div []
                [ Html.h2 [ Attr.class "text-2xl font-bold text-brand" ] [ Html.text "Outfit" ]
                , Html.p [ Attr.class "text-gray-500 mt-1" ]
                    [ Html.text "Variable font · paino 100–900 · SIL Open Font License 1.1" ]
                ]
            , Html.a
                [ Attr.href "/fonts/Outfit-VariableFont_wght.ttf"
                , Attr.download ""
                , Attr.class "inline-flex items-center gap-2 bg-brand-yellow text-brand px-4 py-2 rounded font-semibold hover:opacity-90 transition-opacity"
                ]
                [ Html.text "Lataa TTF" ]
            ]
        , Html.p [ Attr.class "text-gray-600" ]
            [ Html.text "Outfit on moderni geometrinen groteski, joka toimii hyvin sekä otsikoissa että leipätekstissä. Fontti on saatavilla Google Fontseista (SIL OFL)." ]
        ]


viewWeightSpecimens : Html msg
viewWeightSpecimens =
    Html.section [ Attr.class "space-y-4" ]
        [ SectionHeader.view
            { title = "Painovariannit"
            , description = Nothing
            }
        , Html.div [ Attr.class "space-y-3" ]
            (List.map viewWeightSample fontWeights)
        ]


type alias FontWeight =
    { weight : Int
    , label : String
    }


fontWeights : List FontWeight
fontWeights =
    [ { weight = 100, label = "Thin" }
    , { weight = 200, label = "ExtraLight" }
    , { weight = 300, label = "Light" }
    , { weight = 400, label = "Regular" }
    , { weight = 500, label = "Medium" }
    , { weight = 600, label = "SemiBold" }
    , { weight = 700, label = "Bold" }
    , { weight = 800, label = "ExtraBold" }
    , { weight = 900, label = "Black" }
    ]


viewWeightSample : FontWeight -> Html msg
viewWeightSample { weight, label } =
    Html.div
        [ Attr.class "flex items-baseline gap-4 border-l-4 border-brand-yellow pl-4 py-2 bg-white rounded-r" ]
        [ Html.span
            [ Attr.class "text-xs text-gray-400 w-24 flex-shrink-0 font-mono" ]
            [ Html.text (String.fromInt weight ++ " · " ++ label) ]
        , Html.span
            [ Attr.style "font-weight" (String.fromInt weight)
            , Attr.class "text-lg text-brand"
            ]
            [ Html.text "Nopea ruskea kettu hyppää laiskan koiran yli" ]
        ]
