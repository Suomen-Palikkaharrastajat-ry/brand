module Main where

import Test.Tasty
import qualified Guide.ColorsSpec as Colors
import qualified Guide.ElmGenSpec as ElmGen
import qualified Guide.JsonSpec as Json

main :: IO ()
main = defaultMain $ testGroup "logo-gen"
    [ Colors.tests
    , ElmGen.tests
    , Json.tests
    ]
