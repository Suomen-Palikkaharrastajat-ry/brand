module View exposing (View, map, placeholder)

import Html exposing (Html)


type alias View msg =
    { title : String
    , body : List (Html msg)
    }


map : (a -> b) -> View a -> View b
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }


placeholder : String -> View msg
placeholder moduleName =
    { title = "Placeholder - " ++ moduleName
    , body = [ Html.text moduleName ]
    }
