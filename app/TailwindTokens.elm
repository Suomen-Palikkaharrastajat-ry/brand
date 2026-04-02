module TailwindTokens exposing
    ( bgAccent
    , bgDark
      -- Brand colors (for bg/text/border)
    , bgPage
    , bgSubtle
    , borderBrand
    , borderDefault
    , brand
    , brandNougat
    , brandNougatDark
      -- Border colors
    , brandNougatLight
    , brandRed
    , brandYellow
    , textMuted
    , textOnDark
    , -- Text colors
      textPrimary
    , textSubtle
      -- Background colors
    )

{-| Semantic color tokens for elm-tailwind-classes.

Because our custom `@theme` colors (`--color-brand-yellow`, `--color-text-primary`,
etc.) use non-numeric shade names, the generated `Tailwind.Theme.Color` API cannot
express them with the standard `Shade -> Color` helpers. We use the exposed
`SimpleColor(..)` constructor instead, which lets `Tw.bg_simple`, `Tw.text_simple`,
and `Tw.border_simple` emit the right Tailwind class names.

Usage:
import Tailwind as Tw exposing (classes)
import TailwindTokens as TC

    classes [ Tw.bg_simple TC.brand, Tw.text_simple TC.textPrimary ]

-}

import Tailwind.Theme exposing (SimpleColor(..))


textPrimary : SimpleColor
textPrimary =
    SimpleColor "text-primary"


textOnDark : SimpleColor
textOnDark =
    SimpleColor "text-on-dark"


textMuted : SimpleColor
textMuted =
    SimpleColor "text-muted"


textSubtle : SimpleColor
textSubtle =
    SimpleColor "text-subtle"


bgPage : SimpleColor
bgPage =
    SimpleColor "bg-page"


bgSubtle : SimpleColor
bgSubtle =
    SimpleColor "bg-subtle"


bgAccent : SimpleColor
bgAccent =
    SimpleColor "bg-accent"


bgDark : SimpleColor
bgDark =
    SimpleColor "bg-dark"


brand : SimpleColor
brand =
    SimpleColor "brand"


brandYellow : SimpleColor
brandYellow =
    SimpleColor "brand-yellow"


brandRed : SimpleColor
brandRed =
    SimpleColor "brand-red"


brandNougat : SimpleColor
brandNougat =
    SimpleColor "brand-nougat"


brandNougatLight : SimpleColor
brandNougatLight =
    SimpleColor "brand-nougat-light"


brandNougatDark : SimpleColor
brandNougatDark =
    SimpleColor "brand-nougat-dark"


borderDefault : SimpleColor
borderDefault =
    SimpleColor "border-default"


borderBrand : SimpleColor
borderBrand =
    SimpleColor "border-brand"
