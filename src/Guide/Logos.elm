module Guide.Logos exposing (LogoVariant, horizontalVariants, squareVariants)


type alias LogoVariant =
    { id : String
    , description : String
    , theme : String
    , animated : Bool
    , withText : Bool
    , highlight : Bool
    , svgUrl : Maybe String
    , pngUrl : Maybe String
    , webpUrl : Maybe String
    , gifUrl : Maybe String
    }


squareVariants : List LogoVariant
squareVariants =
    [ { id = "square-basic"
      , description = "Basic / neutral expression"
      , theme = "light"
      , animated = False
      , withText = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-basic.svg"
      , pngUrl = Just "/logo/square/png/square-basic.png"
      , webpUrl = Just "/logo/square/png/square-basic.webp"
      , gifUrl = Nothing
      }
    , { id = "square-smile"
      , description = "Smiling expression"
      , theme = "light"
      , animated = False
      , withText = False
      , highlight = True
      , svgUrl = Just "/logo/square/svg/square-smile.svg"
      , pngUrl = Just "/logo/square/png/square-smile.png"
      , webpUrl = Just "/logo/square/png/square-smile.webp"
      , gifUrl = Nothing
      }
    , { id = "square-blink"
      , description = "Blinking expression"
      , theme = "light"
      , animated = False
      , withText = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-blink.svg"
      , pngUrl = Just "/logo/square/png/square-blink.png"
      , webpUrl = Just "/logo/square/png/square-blink.webp"
      , gifUrl = Nothing
      }
    , { id = "square-laugh"
      , description = "Laughing expression"
      , theme = "light"
      , animated = False
      , withText = False
      , highlight = False
      , svgUrl = Just "/logo/square/svg/square-laugh.svg"
      , pngUrl = Just "/logo/square/png/square-laugh.png"
      , webpUrl = Just "/logo/square/png/square-laugh.webp"
      , gifUrl = Nothing
      }
    , { id = "square-animated"
      , description = "Animated logo cycling through all four expressions"
      , theme = "light"
      , animated = True
      , withText = False
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/square/png/square-animated.webp"
      , gifUrl = Just "/logo/square/png/square-animated.gif"
      }
    ]


horizontalVariants : List LogoVariant
horizontalVariants =
    [ { id = "horizontal"
      , description = "Logo mark only, light theme"
      , theme = "light"
      , animated = False
      , withText = False
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-full"
      , description = "Logo mark with association name subtitle, light theme"
      , theme = "light"
      , animated = False
      , withText = True
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-full.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-full.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-full.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-full-dark"
      , description = "Logo mark with subtitle, dark theme"
      , theme = "dark"
      , animated = False
      , withText = True
      , highlight = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-full-dark.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-full-dark.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-animated"
      , description = "Animated logo mark cycling skin-tone order"
      , theme = "light"
      , animated = True
      , withText = False
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-animated.gif"
      }
    , { id = "horizontal-full-animated"
      , description = "Animated logo with subtitle cycling skin-tone order, light theme"
      , theme = "light"
      , animated = True
      , withText = True
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-animated.gif"
      }
    , { id = "horizontal-full-dark-animated"
      , description = "Animated logo with subtitle cycling skin-tone order, dark theme"
      , theme = "dark"
      , animated = True
      , withText = True
      , highlight = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-dark-animated.gif"
      }
    ]
