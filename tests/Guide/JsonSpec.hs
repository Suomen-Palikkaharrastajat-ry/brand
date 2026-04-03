{-# LANGUAGE OverloadedStrings #-}
module Guide.JsonSpec (tests) where

import Guide.Toml (parseDesignGuide)
import Guide.Types (dgMeta, metaOrganization)
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests = testGroup "Guide.Json"
    [ testCase "associationName matches expected value" $ do
        dg <- parseDesignGuide "design-guide.toml"
        metaOrganization (dgMeta dg) @?= "Suomen Palikkaharrastajat ry"
    ]
