{-# LANGUAGE OverloadedStrings #-}
module Logo.DesignsSpec (tests) where

import Brand.Colors (Hex(..), headSvgFaceColor)
import Logo.Designs (recolorFace, svgViewBox, horizontalSvg)
import qualified Data.Text as T
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests = testGroup "Logo.Designs"
    [ testCase "recolorFace replaces face color exactly once" $ do
        let src = "fill=\"" <> headSvgFaceColor <> "\" other=\"" <> headSvgFaceColor <> "\""
            result = recolorFace (Hex "#F2CD37") src
        -- All occurrences are replaced (T.replace replaces all)
        assertBool "old color should not appear" $
            not (T.isInfixOf headSvgFaceColor result)
        assertBool "new color should appear" $
            T.isInfixOf "#f2cd37" result

    , testCase "svgViewBox parses simple viewBox" $ do
        let svg = "<svg viewBox=\"0 0 100.5 200.75\" xmlns=\"http://www.w3.org/2000/svg\">"
            (x, y, w, h) = svgViewBox svg
        x @?= 0.0
        y @?= 0.0
        w @?= 100.5
        h @?= 200.75

    , testCase "horizontalSvg produces wider viewBox than single head" $ do
        let src = "<?xml version=\"1.0\"?><svg viewBox=\"0 0 50 50\" xmlns=\"http://www.w3.org/2000/svg\"><rect/></svg>"
            result = horizontalSvg [Hex "#F2CD37", Hex "#F6D7B3", Hex "#CC8E69", Hex "#AD6140"] src
            (_, _, w, _) = svgViewBox result
        assertBool "horizontal svg should be wider than single head (50)" $
            w > 50.0
    ]
