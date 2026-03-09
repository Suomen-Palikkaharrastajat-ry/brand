{-# LANGUAGE OverloadedStrings #-}
module Brand.JsonSpec (tests) where

import Brand.Colors (associationName)
import Data.Aeson (decode, Value(..))
import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests = testGroup "Brand.Json"
    [ testCase "associationName matches expected value" $
        associationName @?= "Suomen Palikkaharrastajat ry"
    ]
