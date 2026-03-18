module Guide.Logos exposing (LogoVariant, horizontalVariants, squareFullVariants, squareVariants)


type alias LogoVariant =
    { id : String
    , description : String
    , theme : String
    , animated : Bool
    , withText : Bool
    , bold : Bool
    , highlight : Bool
    , svgUrl : Maybe String
    , pngUrl : Maybe String
    , webpUrl : Maybe String
    , gifUrl : Maybe String
    }


squareVariants : List LogoVariant
squareVariants =
    [ { id = "square-basic"
      , description = "Neutraali ilme"
      , theme = "light"
      , animated = False
      , withText = False
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-basic.svg"
      , pngUrl = Just "/logo/square/png/square-basic.png"
      , webpUrl = Just "/logo/square/png/square-basic.webp"
      , gifUrl = Nothing
      }
    , { id = "square-smile"
      , description = "Hymyilevä ilme"
      , theme = "light"
      , animated = False
      , withText = False
      , bold = False
      , highlight = True
      , svgUrl = Just "/logo/square/svg/square-smile.svg"
      , pngUrl = Just "/logo/square/png/square-smile.png"
      , webpUrl = Just "/logo/square/png/square-smile.webp"
      , gifUrl = Nothing
      }
    , { id = "square-blink"
      , description = "Silmää iskevä ilme"
      , theme = "light"
      , animated = False
      , withText = False
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-blink.svg"
      , pngUrl = Just "/logo/square/png/square-blink.png"
      , webpUrl = Just "/logo/square/png/square-blink.webp"
      , gifUrl = Nothing
      }
    , { id = "square-laugh"
      , description = "Naurava ilme"
      , theme = "light"
      , animated = False
      , withText = False
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-laugh.svg"
      , pngUrl = Just "/logo/square/png/square-laugh.png"
      , webpUrl = Just "/logo/square/png/square-laugh.webp"
      , gifUrl = Nothing
      }
    , { id = "square-animated"
      , description = "Animoitu logo, käy läpi kaikki neljä ilmettä"
      , theme = "light"
      , animated = True
      , withText = False
      , bold = False
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/square/png/square-animated.webp"
      , gifUrl = Just "/logo/square/png/square-animated.gif"
      }
    ]


squareFullVariants : List LogoVariant
squareFullVariants =
    [ { id = "square-smile-full"
      , description = "Hymyilevä logo kahdella tekstirivillä, vaalea teema"
      , theme = "light"
      , animated = False
      , withText = True
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-smile-full.svg"
      , pngUrl = Just "/logo/square/png/square-smile-full.png"
      , webpUrl = Just "/logo/square/png/square-smile-full.webp"
      , gifUrl = Nothing
      }
    , { id = "square-smile-full-bold"
      , description = "Hymyilevä logo kahdella tekstirivillä, lihavoitu, vaalea teema"
      , theme = "light"
      , animated = False
      , withText = True
      , bold = True
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-smile-full-bold.svg"
      , pngUrl = Just "/logo/square/png/square-smile-full-bold.png"
      , webpUrl = Just "/logo/square/png/square-smile-full-bold.webp"
      , gifUrl = Nothing
      }
    , { id = "square-smile-full-dark"
      , description = "Hymyilevä logo kahdella tekstirivillä, tumma teema"
      , theme = "dark"
      , animated = False
      , withText = True
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-smile-full-dark.svg"
      , pngUrl = Just "/logo/square/png/square-smile-full-dark.png"
      , webpUrl = Just "/logo/square/png/square-smile-full-dark.webp"
      , gifUrl = Nothing
      }
    , { id = "square-smile-full-dark-bold"
      , description = "Hymyilevä logo kahdella tekstirivillä, lihavoitu, tumma teema"
      , theme = "dark"
      , animated = False
      , withText = True
      , bold = True
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-smile-full-dark-bold.svg"
      , pngUrl = Just "/logo/square/png/square-smile-full-dark-bold.png"
      , webpUrl = Just "/logo/square/png/square-smile-full-dark-bold.webp"
      , gifUrl = Nothing
      }
    ]


horizontalVariants : List LogoVariant
horizontalVariants =
    [ { id = "horizontal"
      , description = "Pelkkä logo, vaalea teema"
      , theme = "light"
      , animated = False
      , withText = False
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-full"
      , description = "Logo yhdistyksen nimellä, vaalea teema"
      , theme = "light"
      , animated = False
      , withText = True
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-full.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-full.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-full.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-full-bold"
      , description = "Logo nimitekstillä, lihavoitu, vaalea teema"
      , theme = "light"
      , animated = False
      , withText = True
      , bold = True
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-full-bold.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-full-bold.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-bold.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-full-dark"
      , description = "Logo nimitekstillä, tumma teema"
      , theme = "dark"
      , animated = False
      , withText = True
      , bold = False
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-full-dark.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-full-dark.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-full-dark-bold"
      , description = "Logo nimitekstillä, lihavoitu, tumma teema"
      , theme = "dark"
      , animated = False
      , withText = True
      , bold = True
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-full-dark-bold.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-full-dark-bold.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark-bold.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-animated"
      , description = "Animoitu logo"
      , theme = "light"
      , animated = True
      , withText = False
      , bold = False
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-animated.gif"
      }
    , { id = "horizontal-full-animated"
      , description = "Animoitu logo nimitekstillä, vaalea teema"
      , theme = "light"
      , animated = True
      , withText = True
      , bold = False
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-animated.gif"
      }
    , { id = "horizontal-full-bold-animated"
      , description = "Animoitu logo nimitekstillä, lihavoitu, vaalea teema"
      , theme = "light"
      , animated = True
      , withText = True
      , bold = True
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-bold-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-bold-animated.gif"
      }
    , { id = "horizontal-full-dark-animated"
      , description = "Animoitu logo nimitekstillä, tumma teema"
      , theme = "dark"
      , animated = True
      , withText = True
      , bold = False
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-dark-animated.gif"
      }
    , { id = "horizontal-full-dark-bold-animated"
      , description = "Animoitu logo nimitekstillä, lihavoitu, tumma teema"
      , theme = "dark"
      , animated = True
      , withText = True
      , bold = True
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark-bold-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-dark-bold-animated.gif"
      }
    ]
