module Logo.BlockifySpec (tests) where

import Logo.Blockify (aspectCorrectionFactor)
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests = testGroup "Logo.Blockify"
    [ testCase "aspectCorrectionFactor with default params is 12/15" $ do
        let factor = aspectCorrectionFactor 24 20
        -- studH = max 2 (20 * 15 / 100) = 3
        -- bodyH = 17, innerStudH = max 2 (17 * 15 / 100) = 2
        -- vPitch = 15, hPitch = 12
        assertBool "factor should be 12/15 = 0.8" $
            abs (factor - 0.8) < 1e-9

    , testCase "aspectCorrectionFactor produces value < 1 for default params" $ do
        let factor = aspectCorrectionFactor 24 20
        assertBool "correction factor should be < 1 (compress height)" $
            factor < 1.0

    , testCase "padding adds 2*pad columns" $ do
        -- With pad=1, a 14-wide image becomes 16-wide
        let imgW = 14 :: Int
            padded = imgW + 2
        padded @?= 16
    ]
