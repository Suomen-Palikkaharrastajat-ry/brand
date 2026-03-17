{-# LANGUAGE OverloadedStrings #-}
module Guide.Colors where

import Data.Text (Text)

newtype Hex = Hex Text deriving (Show, Eq)

-- Logo mark
featureColor :: Hex
featureColor = Hex "#05131D" -- LEGO Black

highlightColor :: Hex
highlightColor = Hex "#FFFFFF" -- LEGO White

darkBg :: Hex
darkBg = Hex "#05131D"

-- Subtitle text
subtitleOnLight :: Hex
subtitleOnLight = Hex "#05131D"

subtitleOnDark :: Hex
subtitleOnDark = Hex "#FFFFFF"

associationName :: Text
associationName = "Suomen Palikkaharrastajat ry"

-- source.svg face color to replace
headSvgFaceColor :: Text
headSvgFaceColor = "#f8c70b"

-- (id, name, hex)
skinTones :: [(Text, Text, Hex)]
skinTones =
    [ ("yellow", "Yellow", Hex "#FAC80A")
    , ("light-nougat", "Light Nougat", Hex "#F6D7B3")
    , ("nougat", "Nougat", Hex "#D09168")
    , ("dark-nougat", "Dark Nougat", Hex "#AD6140")
    ]

-- (id, name, hex, description)
rainbowColors :: [(Text, Text, Hex, Text)]
rainbowColors =
    [ ("salmon", "Salmon", Hex "#F2705E", "Red")
    , ("light-orange", "Light Orange", Hex "#F9BA61", "Orange")
    , ("yellow", "Yellow", Hex "#FAC80A", "Yellow")
    , ("medium-green", "Medium Green", Hex "#73DCA1", "Green")
    , ("bright-light-blue", "Bright Light Blue", Hex "#9FC3E9", "Blue")
    , ("light-lilac", "Light Lilac", Hex "#9195CA", "Indigo")
    , ("medium-lavender", "Medium Lavender", Hex "#AC78BA", "Violet")
    ]

hexText :: Hex -> Text
hexText (Hex t) = t
