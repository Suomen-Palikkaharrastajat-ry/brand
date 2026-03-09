module AddRoute exposing (main)

{-| Generates a new elm-pages route module scaffold.
Run with: elm-codegen run codegen/src/AddRoute.elm --output app/Route/
-}

import Elm
import Gen.CodeGen.Generate as Generate


main : Program {} () ()
main =
    Generate.run
        [ -- TODO: implement route scaffolding
        ]
