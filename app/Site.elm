module Site exposing (canonicalUrl, config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import SiteConfig exposing (SiteConfig)


canonicalUrl : String
canonicalUrl =
    "https://logo.palikkaharrastajat.fi"


config : SiteConfig
config =
    { canonicalUrl = canonicalUrl
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "description"
        (Head.raw "Suomen Palikkaharrastajat ry:n brändiohjeistus: logot, värit ja typografia.")
    , Head.metaProperty "og:image"
        (Head.raw (canonicalUrl ++ "/logo/horizontal/png/horizontal-full.png"))
    , Head.metaProperty "og:type"
        (Head.raw "website")
    , Head.metaName "theme-color"
        (Head.raw "#05131D")
    ]
        |> BackendTask.succeed
