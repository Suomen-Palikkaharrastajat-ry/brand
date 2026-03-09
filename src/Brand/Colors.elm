module Brand.Colors exposing (ColorEntry, RainbowColor, SkinToneEntry, brandColors, rainbowColors, skinTones)


type alias ColorEntry =
    { hex : String
    , id : String
    , name : String
    , usage : List String
    }


type alias SkinToneEntry =
    { hex : String
    , id : String
    , name : String
    , description : String
    }


type alias RainbowColor =
    { hex : String
    , name : String
    , description : String
    }


brandColors : List ColorEntry
brandColors =
    [ { hex = "#F2CD37"
      , id = "lego-yellow"
      , name = "LEGO Yellow"
      , usage = [ "primary brand", "accent" ]
      }
    , { hex = "#05131D"
      , id = "lego-black"
      , name = "LEGO Black"
      , usage = [ "features", "text", "dark background" ]
      }
    , { hex = "#FFFFFF"
      , id = "lego-white"
      , name = "LEGO White"
      , usage = [ "eye highlights", "text on dark background" ]
      }
    ]


skinTones : List SkinToneEntry
skinTones =
    [ { hex = "#F2CD37", id = "yellow", name = "Yellow", description = "Classic minifig" }
    , { hex = "#F6D7B3", id = "light-nougat", name = "Light Nougat", description = "Light skin" }
    , { hex = "#CC8E69", id = "nougat", name = "Nougat", description = "Medium skin" }
    , { hex = "#AD6140", id = "dark-nougat", name = "Dark Nougat", description = "Dark skin" }
    ]


rainbowColors : List RainbowColor
rainbowColors =
    [ { hex = "#F2705E", name = "Salmon", description = "Red" }
    , { hex = "#F9BA61", name = "Light Orange", description = "Orange" }
    , { hex = "#F2CD37", name = "Yellow", description = "Yellow" }
    , { hex = "#73DCA1", name = "Medium Green", description = "Green" }
    , { hex = "#9FC3E9", name = "Bright Light Blue", description = "Blue" }
    , { hex = "#9195CA", name = "Light Lilac", description = "Indigo" }
    , { hex = "#AC78BA", name = "Medium Lavender", description = "Violet" }
    ]
