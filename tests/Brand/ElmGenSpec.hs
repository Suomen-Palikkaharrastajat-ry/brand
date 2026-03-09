{-# LANGUAGE OverloadedStrings #-}
module Brand.ElmGenSpec (tests) where

import Brand.Colors (rainbowColors, skinTones)
import Brand.ElmGen (generateBrandModule)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Exit (ExitCode (..))
import System.IO (hClose)
import System.IO.Temp (withTempFile)
import System.Process (readProcessWithExitCode)
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests =
    testGroup
        "Brand.ElmGen"
        [ testCase "module header is correct" $
            assertBool "starts with module Brand.Generated exposing (..)" $
                "module Brand.Generated exposing (..)" `T.isPrefixOf` generateBrandModule
        , testCase "contains associationName" $
            assertBool "has association name" $
                "Suomen Palikkaharrastajat ry" `T.isInfixOf` generateBrandModule
        , testCase "escapeElmString handles quotes" $
            renderString "say \"hi\"" @?= "\"say \\\"hi\\\"\""
        , testCase "escapeElmString handles backslash" $
            renderString "a\\b" @?= "\"a\\\\b\""
        , testCase "skinTones list has 4 items" $
            length skinTones @?= 4
        , testCase "rainbowColors list has 7 items" $
            length rainbowColors @?= 7
        , testCase "generated module contains skinTones" $
            assertBool "skinTones appears in output" $
                "skinTones : List SkinTone" `T.isInfixOf` generateBrandModule
        , testCase "generated module contains rainbowColors" $
            assertBool "rainbowColors appears in output" $
                "rainbowColors : List RainbowColor" `T.isInfixOf` generateBrandModule
        , testCase "generated Elm passes elm-format --validate" $ do
            (rc, _, _) <- readProcessWithExitCode "which" ["elm-format"] ""
            case rc of
                ExitFailure _ -> pure ()  -- elm-format not in PATH; skip
                ExitSuccess   -> withTempFile "." "Generated.elm" $ \path handle -> do
                    TIO.hPutStr handle generateBrandModule
                    hClose handle
                    (code, _, _) <- readProcessWithExitCode "elm-format" ["--validate", path] ""
                    code @?= ExitSuccess
        ]

-- | Mirror of Brand.ElmGen internals for testing the escape logic.
escapeElmString :: Text -> Text
escapeElmString = T.concatMap escapeChar
  where
    escapeChar '\\' = "\\\\"
    escapeChar '"' = "\\\""
    escapeChar '\n' = "\\n"
    escapeChar '\r' = "\\r"
    escapeChar '\t' = "\\t"
    escapeChar c = T.singleton c

renderString :: Text -> Text
renderString t = "\"" <> escapeElmString t <> "\""
