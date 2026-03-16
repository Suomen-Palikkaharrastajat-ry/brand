module Guide.Logos exposing (LogoVariant, bwVariants, horizontalVariants, squareVariants)


type alias LogoVariant =
    { id : String
    , description : String
    , theme : String
    , animated : Bool
    , withText : Bool
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
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-full-dark-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-full-dark-animated.gif"
      }
    , { id = "horizontal-rainbow"
      , description = "Rainbow logo mark, sliding window of 4 colors"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-rainbow.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-rainbow.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-rainbow.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-rainbow-animated"
      , description = "Animated rainbow logo mark cycling all 7 colors one step at a time"
      , theme = "light"
      , animated = True
      , withText = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-rainbow-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-rainbow-animated.gif"
      }
    , { id = "horizontal-rainbow-full"
      , description = "Rainbow logo mark with subtitle, light theme"
      , theme = "light"
      , animated = False
      , withText = True
      , svgUrl = Just "/logo/horizontal/svg/horizontal-rainbow-full.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-rainbow-full.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-rainbow-full.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-rainbow-full-animated"
      , description = "Animated rainbow logo with subtitle, light theme, 7 colors cycling"
      , theme = "light"
      , animated = True
      , withText = True
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-rainbow-full-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-rainbow-full-animated.gif"
      }
    , { id = "horizontal-rainbow-full-dark"
      , description = "Rainbow logo mark with subtitle, dark theme"
      , theme = "dark"
      , animated = False
      , withText = True
      , svgUrl = Just "/logo/horizontal/svg/horizontal-rainbow-full-dark.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-rainbow-full-dark.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-rainbow-full-dark.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-rainbow-full-dark-animated"
      , description = "Animated rainbow logo with subtitle, dark theme, 7 colors cycling"
      , theme = "dark"
      , animated = True
      , withText = True
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-rainbow-full-dark-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-rainbow-full-dark-animated.gif"
      }
    , { id = "horizontal-skintone"
      , description = "Skin-tone logo mark, sliding window of 4 tones"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-skintone.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-skintone.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-skintone.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-skintone-animated"
      , description = "Animated skin-tone logo mark cycling all 4 tones one step at a time"
      , theme = "light"
      , animated = True
      , withText = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-skintone-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-skintone-animated.gif"
      }
    , { id = "horizontal-skintone-full"
      , description = "Skin-tone logo mark with subtitle, light theme"
      , theme = "light"
      , animated = False
      , withText = True
      , svgUrl = Just "/logo/horizontal/svg/horizontal-skintone-full.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-skintone-full.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-skintone-full.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-skintone-full-animated"
      , description = "Animated skin-tone logo with subtitle, light theme, 4 tones cycling"
      , theme = "light"
      , animated = True
      , withText = True
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-skintone-full-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-skintone-full-animated.gif"
      }
    , { id = "horizontal-skintone-full-dark"
      , description = "Skin-tone logo mark with subtitle, dark theme"
      , theme = "dark"
      , animated = False
      , withText = True
      , svgUrl = Just "/logo/horizontal/svg/horizontal-skintone-full-dark.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-skintone-full-dark.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-skintone-full-dark.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-skintone-full-dark-animated"
      , description = "Animated skin-tone logo with subtitle, dark theme, 4 tones cycling"
      , theme = "dark"
      , animated = True
      , withText = True
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/horizontal/png/horizontal-skintone-full-dark-animated.webp"
      , gifUrl = Just "/logo/horizontal/png/horizontal-skintone-full-dark-animated.gif"
      }
    ]


bwVariants : List LogoVariant
bwVariants =
    [ { id = "square-bw-basic"
      , description = "B&W square — neutral expression"
      , theme = "yellow"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-bw-basic.svg"
      , pngUrl = Just "/logo/square/png/square-bw-basic.png"
      , webpUrl = Just "/logo/square/png/square-bw-basic.webp"
      , gifUrl = Nothing
      }
    , { id = "square-bw-smile"
      , description = "B&W square — smiling expression"
      , theme = "yellow"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-bw-smile.svg"
      , pngUrl = Just "/logo/square/png/square-bw-smile.png"
      , webpUrl = Just "/logo/square/png/square-bw-smile.webp"
      , gifUrl = Nothing
      }
    , { id = "square-bw-blink"
      , description = "B&W square — blinking expression"
      , theme = "yellow"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-bw-blink.svg"
      , pngUrl = Just "/logo/square/png/square-bw-blink.png"
      , webpUrl = Just "/logo/square/png/square-bw-blink.webp"
      , gifUrl = Nothing
      }
    , { id = "square-bw-laugh"
      , description = "B&W square — laughing expression"
      , theme = "yellow"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-bw-laugh.svg"
      , pngUrl = Just "/logo/square/png/square-bw-laugh.png"
      , webpUrl = Just "/logo/square/png/square-bw-laugh.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-bw"
      , description = "B&W horizontal logo mark only"
      , theme = "yellow"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/horizontal/svg/horizontal-bw.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-bw.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-bw.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-bw-full"
      , description = "B&W horizontal logo mark with subtitle, light theme"
      , theme = "yellow"
      , animated = False
      , withText = True
      , svgUrl = Just "/logo/horizontal/svg/horizontal-bw-full.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-bw-full.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-bw-full.webp"
      , gifUrl = Nothing
      }
    , { id = "horizontal-bw-full-dark"
      , description = "B&W horizontal logo mark with subtitle, dark theme"
      , theme = "dark"
      , animated = False
      , withText = True
      , svgUrl = Just "/logo/horizontal/svg/horizontal-bw-full-dark.svg"
      , pngUrl = Just "/logo/horizontal/png/horizontal-bw-full-dark.png"
      , webpUrl = Just "/logo/horizontal/png/horizontal-bw-full-dark.webp"
      , gifUrl = Nothing
      }
    ]
