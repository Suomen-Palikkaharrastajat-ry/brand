{-# LANGUAGE OverloadedStrings #-}
module Brand.ColorsSpec (tests) where

import Brand.Colors
import Data.Char (isHexDigit, toUpper)
import Data.Text (Text)
import qualified Data.Text as T
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests = testGroup "Brand.Colors"
    [ testCase "skinTones has exactly 4 entries" $
        length skinTones @?= 4

    , testCase "rainbowColors has exactly 7 entries" $
        length rainbowColors @?= 7

    , testCase "all skinTone hex values are valid" $
        mapM_ (assertValidHex . (\(_, _, h) -> hexText h)) skinTones

    , testCase "all rainbowColor hex values are valid" $
        mapM_ (assertValidHex . (\(_, _, h, _) -> hexText h)) rainbowColors

    , testCase "featureColor is valid hex" $
        assertValidHex (hexText featureColor)

    , testCase "highlightColor is valid hex" $
        assertValidHex (hexText highlightColor)

    , testCase "darkBg is valid hex" $
        assertValidHex (hexText darkBg)

    , testCase "associationName is non-empty" $
        assertBool "association name should not be empty" $
            not (T.null associationName)

    , testCase "headSvgFaceColor is valid hex" $
        assertValidHex headSvgFaceColor

    , testCase "skinTone ids are unique" $
        let ids = map (\(sid, _, _) -> sid) skinTones
         in length ids @?= length (foldr (\x acc -> if x `elem` acc then acc else x : acc) [] ids)
    ]

-- | Assert that a Text value is a CSS hex color (#RRGGBB or #RGB).
assertValidHex :: Text -> Assertion
assertValidHex t = do
    assertBool ("should start with #: " ++ T.unpack t) $
        T.isPrefixOf "#" t
    let body = T.tail t
    assertBool ("should be 3 or 6 hex digits: " ++ T.unpack t) $
        T.length body `elem` [3, 6]
    assertBool ("all chars should be hex digits: " ++ T.unpack t) $
        T.all (isHexDigit . toUpper) body
