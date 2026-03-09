module Brand.Logos exposing (LogoVariant, horizontalVariants, squareVariants)


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
    [ { id = "square"
      , description = "Yellow, classic minifig"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square.svg"
      , pngUrl = Just "/logo/square/png/square.png"
      , webpUrl = Just "/logo/square/png/square.webp"
      , gifUrl = Nothing
      }
    , { id = "square-light-nougat"
      , description = "Light Nougat skin tone"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-light-nougat.svg"
      , pngUrl = Just "/logo/square/png/square-light-nougat.png"
      , webpUrl = Just "/logo/square/png/square-light-nougat.webp"
      , gifUrl = Nothing
      }
    , { id = "square-nougat"
      , description = "Nougat skin tone"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-nougat.svg"
      , pngUrl = Just "/logo/square/png/square-nougat.png"
      , webpUrl = Just "/logo/square/png/square-nougat.webp"
      , gifUrl = Nothing
      }
    , { id = "square-dark-nougat"
      , description = "Dark Nougat skin tone"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/square-dark-nougat.svg"
      , pngUrl = Just "/logo/square/png/square-dark-nougat.png"
      , webpUrl = Just "/logo/square/png/square-dark-nougat.webp"
      , gifUrl = Nothing
      }
    , { id = "square-animated"
      , description = "Animated logo cycling through all four skin tones"
      , theme = "light"
      , animated = True
      , withText = False
      , svgUrl = Nothing
      , pngUrl = Nothing
      , webpUrl = Just "/logo/square/png/square-animated.webp"
      , gifUrl = Just "/logo/square/png/square-animated.gif"
      }
    , { id = "minifig-colorful"
      , description = "Minifig head with face divided into horizontal skin-tone bands"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/minifig-colorful.svg"
      , pngUrl = Just "/logo/square/png/minifig-colorful.png"
      , webpUrl = Just "/logo/square/png/minifig-colorful.webp"
      , gifUrl = Nothing
      }
    , { id = "minifig-rainbow"
      , description = "Minifig head with face divided into horizontal rainbow bands"
      , theme = "light"
      , animated = False
      , withText = False
      , svgUrl = Just "/logo/square/svg/minifig-rainbow.svg"
      , pngUrl = Just "/logo/square/png/minifig-rainbow.png"
      , webpUrl = Just "/logo/square/png/minifig-rainbow.webp"
      , gifUrl = Nothing
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
    ]
