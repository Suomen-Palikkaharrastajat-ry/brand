module AddStaticRoute exposing (main)

{-| Generates a new static elm-pages route module scaffold.
Run with: elm-codegen run codegen/src/AddStaticRoute.elm --output app/Route/
-}

import Elm
import Gen.CodeGen.Generate as Generate


main : Program {} () ()
main =
    Generate.run
        [ -- TODO: implement static route scaffolding
        ]
