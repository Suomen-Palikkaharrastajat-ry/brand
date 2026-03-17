module Route.Saavutettavuus exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Component.Alert as Alert
import Component.SectionHeader as SectionHeader
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


route : RouteBuilder.StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = SiteMeta.organizationName
        , image =
            { url = Pages.Url.external "https://logo.palikkaharrastajat.fi/logo/horizontal/png/horizontal-full.png"
            , alt = SiteMeta.organizationName
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Suomen Palikkaharrastajat ry:n saavutettavuusohjeet — kontrasti, värinäkö ja animaatiot."
        , locale = Nothing
        , title = "Saavutettavuus — " ++ SiteMeta.organizationName
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { title = "Saavutettavuus — " ++ SiteMeta.organizationName
    , body =
        [ Html.div [ Attr.class "max-w-5xl mx-auto px-4 py-8 sm:py-12 space-y-12 sm:space-y-16" ]
            [ Html.div [ Attr.class "space-y-2" ]
                [ Html.h1 [ Attr.class "text-2xl sm:text-3xl font-bold text-brand" ]
                    [ Html.text "Saavutettavuus" ]
                , Html.p [ Attr.class "text-sm sm:text-base text-gray-500" ]
                    [ Html.text "WCAG 2.1 AA -ohjeistus kontrasteista, värisokeustuesta, animaatioista ja saavutettavasta nimeämisestä. Koneluettava: "
                    , Html.a
                        [ Attr.href "/design-guide/logos.jsonld"
                        , Attr.class "underline hover:text-brand transition-colors font-mono text-sm"
                        ]
                        [ Html.text "design-guide/logos.jsonld" ]
                    , Html.text "."
                    ]
                ]
            , Alert.view
                { alertType = Alert.Info
                , title = Just "WCAG 2.1 AA — tavoitetaso"
                , body =
                    [ Html.text "Kaikki brändimateriaalit ja käyttöliittymäkomponentit noudattavat vähintään WCAG 2.1 AA -tasoa. Kontrastitiedot löytyvät myös koneluettavasta "
                    , Html.a [ Attr.href "/brand.json", Attr.class "underline" ] [ Html.text "brand.json" ]
                    , Html.text " -tiedostosta (kenttä "
                    , Html.code [ Attr.class "font-mono text-xs" ] [ Html.text "colors.brand[*].wcag" ]
                    , Html.text ")."
                    ]
                , onDismiss = Nothing
                }
            , viewContrastSection
            , viewColorBlindSection
            , viewMotionSection
            , viewLogoAltSection
            , viewFocusSection
            , viewAccessibleNamingSection
            ]
        ]
    }



-- ---------------------------------------------------------------------------
-- Contrast
-- ---------------------------------------------------------------------------


viewContrastSection : Html msg
viewContrastSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Kontrastisuhteet"
            , description = Just "WCAG 2.1 vaatii vähintään 4.5:1 normaalille tekstille (AA) ja 3:1 suurelle tekstille (AA). Tähdellä (*) merkityt ylittävät AAA-tason (7:1)."
            }
        , Html.div [ Attr.class "overflow-x-auto" ]
            [ Html.table [ Attr.class "w-full text-sm border-collapse" ]
                [ Html.thead []
                    [ Html.tr [ Attr.class "bg-gray-50 border-b border-gray-200" ]
                        [ th "Väri"
                        , th "Hex"
                        , th "Valkoisella"
                        , th "Mustalla"
                        , th "Käyttötarkoitus"
                        ]
                    ]
                , Html.tbody [ Attr.class "divide-y divide-gray-100" ]
                    (List.map viewContrastRow contrastData)
                ]
            ]
        ]


contrastData : List { name : String, hex : String, onWhite : String, onBlack : String, usage : String }
contrastData =
    [ { name = "Black", hex = "#05131D", onWhite = "17.3:1 (AAA*)", onBlack = "—", usage = "Teksti, otsikot, logo" }
    , { name = "White", hex = "#FFFFFF", onWhite = "—", onBlack = "17.3:1 (AAA*)", usage = "Teksti tummalla taustalla" }
    , { name = "Red", hex = "#C91A09", onWhite = "5.0:1 (AA)", onBlack = "4.2:1 (AA)", usage = "Aksentti, varoitus, korostus" }
    , { name = "Yellow", hex = "#FAC80A", onWhite = "1.5:1 (ei)", onBlack = "11.5:1 (AAA*)", usage = "Aksenttiväri — ei tekstinä vaalealla" }
    , { name = "Light Nougat", hex = "#F6D7B3", onWhite = "1.4:1 (ei)", onBlack = "12.4:1 (AAA*)", usage = "Vain koristelullinen käyttö" }
    , { name = "Nougat", hex = "#CC8E69", onWhite = "2.6:1 (ei)", onBlack = "6.7:1 (AA)", usage = "Suuri teksti mustalla taustalla" }
    , { name = "Dark Nougat", hex = "#AD6140", onWhite = "4.4:1 (AA)", onBlack = "4.0:1 (AA)", usage = "Suuri teksti, koristeet" }
    ]


viewContrastRow : { name : String, hex : String, onWhite : String, onBlack : String, usage : String } -> Html msg
viewContrastRow row =
    Html.tr [ Attr.class "hover:bg-gray-50" ]
        [ Html.td [ Attr.class "px-4 py-3 font-medium text-brand flex items-center gap-2" ]
            [ Html.span
                [ Attr.class "inline-block w-4 h-4 rounded border border-black/10 flex-shrink-0"
                , Attr.style "background-color" row.hex
                ]
                []
            , Html.text row.name
            ]
        , Html.td [ Attr.class "px-4 py-3 font-mono text-gray-500" ] [ Html.text row.hex ]
        , Html.td [ Attr.class "px-4 py-3" ] [ Html.text row.onWhite ]
        , Html.td [ Attr.class "px-4 py-3" ] [ Html.text row.onBlack ]
        , Html.td [ Attr.class "px-4 py-3 text-gray-500" ] [ Html.text row.usage ]
        ]



-- ---------------------------------------------------------------------------
-- Color blindness
-- ---------------------------------------------------------------------------


viewColorBlindSection : Html msg
viewColorBlindSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Värisokeustuki"
            , description = Just "Brändivärit ja niiden käyttö värinäön erityisryhmissä."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ viewRuleCard "Älä käytä väriä ainoana erottavana tekijänä"
                "Tieto on ilmaistava myös tekstillä, kuviolla tai ikonilla. Esimerkiksi Alert-komponentti käyttää sekä väriä että ikonia (ℹ / ✓ / ⚠ / ✕)."
            , viewRuleCard "Sateenkaaripaletti ja värisokeus"
                "Sateenkaarivariantti on suunniteltu visuaaliseen monimuotoisuuteen, ei tiedon välittämiseen. Kaikki sateenkaarivärit ovat koristelullisia. Deuteranopiaa (puna-vihersokeutta) sairastavat eivät erota Salmon- ja Medium Green -värejä helposti — älä käytä niitä rinnakkain tärkeysjärjestyksen merkitsemiseen."
            , viewRuleCard "Black / Yellow -pari on turvallinen"
                "Mustakeltainen yhdistelmä on tunnistettava kaikilla yleisimmillä värisokeustyypeillä (deuteranopia, protanopia, tritanopia)."
            ]
        ]



-- ---------------------------------------------------------------------------
-- Motion
-- ---------------------------------------------------------------------------


viewMotionSection : Html msg
viewMotionSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Liike ja animaatiot"
            , description = Nothing
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ viewRuleCard "prefers-reduced-motion on pakollinen"
                "Kaikki animaatiot, siirtymät ja automaattisesti toistuvat kuvat on pysäytettävä tai vaihdettava staattiseen versioon, kun käyttäjä on asettanut prefers-reduced-motion: reduce. CSS-esimerkki: @media (prefers-reduced-motion: reduce) { *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; } }"
            , viewRuleCard "Animoitu logo"
                "Käytä <img src=\"square-animated.gif\"> vain silloin, kun prefers-reduced-motion EI ole aktiivinen. Staattinen vaihtoehto: square.png tai square.webp."
            , viewRuleCard "Siirtymäajat brand.json:ssa"
                "Viralliset siirtymäajat: fast 150ms (hover), base 300ms (avautumiset), slow 500ms (sivutason muutokset). Katso kenttä motion.duration brand.json:ssa."
            ]
        ]



-- ---------------------------------------------------------------------------
-- Logo alt text
-- ---------------------------------------------------------------------------


viewLogoAltSection : Html msg
viewLogoAltSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Logon vaihtoehtoteksti"
            , description = Just "Ohjeet alt-attribuutin käyttöön eri konteksteissa."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ viewRuleCard "Päälogo navigaatiossa"
                "alt=\"Suomen Palikkaharrastajat ry\" — kerro yhdistyksen nimi."
            , viewRuleCard "Logo kuvitustarkoituksessa"
                "alt=\"Suomen Palikkaharrastajat ry — logo\" tai varianttispesifinen kuvaus, esim. alt=\"Sateenkaarilogovariantti\"."
            , viewRuleCard "Koristelullinen logo"
                "Jos logo on pelkästään visuaalinen koriste (esim. taustakuvio), käytä alt=\"\"."
            ]
        ]



-- ---------------------------------------------------------------------------
-- Focus
-- ---------------------------------------------------------------------------


viewFocusSection : Html msg
viewFocusSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Kohdistusindikaattorit"
            , description = Just "Näppäimistönavigointi edellyttää selkeää kohdistusindikaattoria."
            }
        , Html.div [ Attr.class "space-y-4" ]
            [ viewRuleCard "Älä poista outline-attribuuttia"
                "focus:outline-none on sallittu vain, jos tarjoat vastaavan näkyvän vaihtoehdon (focus:ring-2). Button-komponentti käyttää valmiiksi focus:ring-2 focus:ring-offset-2 -luokkia."
            , viewRuleCard "Kohdistusrengas kirkkuusvaatimus"
                "Kohdistusindikaattorin kontrast taustan kanssa on oltava vähintään 3:1 (WCAG 2.1 AA, kriteeri 1.4.11). Merkkivärinen (brand-yellow #FAC80A) rengas tummalla taustalla täyttää vaatimuksen."
            ]
        ]



-- ---------------------------------------------------------------------------
-- Accessible naming
-- ---------------------------------------------------------------------------


viewAccessibleNamingSection : Html msg
viewAccessibleNamingSection =
    Html.section [ Attr.class "space-y-6" ]
        [ SectionHeader.view
            { title = "Saavutettava nimeäminen"
            , description = Just "Ohjeet aria-label-, aria-haspopup-, aria-expanded-, aria-controls- ja aria-labelledby-attribuuttien käyttöön komponenttikirjaston kanssa."
            }
        , Html.div [ Attr.class "space-y-6" ]
            [ -- CloseButton / aria-label
              Html.div [ Attr.class "space-y-3" ]
                [ Html.p [ Attr.class "font-semibold text-sm text-brand" ] [ Html.text "aria-label — CloseButton ja Spinner" ]
                , Html.p [ Attr.class "text-sm text-gray-600" ]
                    [ Html.text "Komponentit, jotka eivät sisällä näkyvää tekstiä (kuten × tai pyörivä kehä), tarvitsevat aina "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "aria-label" ]
                    , Html.text "-attribuutin. Komponenttikirjastossa tämä välitetään "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "label : String" ]
                    , Html.text " -kentällä — ei "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "Html msg" ]
                    , Html.text " -tyyppisenä, koska ruudunlukijat jättävät muotoillun HTML-sisällön huomiotta tai lukevat sen väärin."
                    ]
                , viewCodeComparison
                    "Vältä — ei aria-labelia"
                    """-- Ruudunlukija lukee vain \"×\", ei tiedä mitä suljetaan
Html.button [] [ Html.text \"×\" ]"""
                    "Oikein — selkeä label"
                    """-- Ruudunlukija lukee \"Sulje ilmoitus\"
CloseButton.view
    { onClick = DismissAlert
    , label   = \"Sulje ilmoitus\"  -- aria-label
    }

-- Spinner: label on sr-only -elementissä
Spinner.view
    { size  = Spinner.Medium
    , label = \"Ladataan...\"  -- aria-label
    }"""
                ]

            -- Dropdown / aria-haspopup + aria-expanded
            , Html.div [ Attr.class "space-y-3" ]
                [ Html.p [ Attr.class "font-semibold text-sm text-brand" ] [ Html.text "aria-haspopup ja aria-expanded — Dropdown" ]
                , Html.p [ Attr.class "text-sm text-gray-600" ]
                    [ Html.text "Ruudunlukija tarvitsee tiedon siitä, että painike avaa valikon ("
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "aria-haspopup=\"menu\"" ]
                    , Html.text ") ja siitä, onko valikko auki ("
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "aria-expanded" ]
                    , Html.text "). Dropdown-komponentti asettaa nämä automaattisesti "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "isOpen" ]
                    , Html.text "-tilan perusteella."
                    ]
                , viewCodeBlock
                    """Dropdown.view
    { trigger  = Html.text \"Toiminnot\"
    , items    = [ Dropdown.viewItem { label = \"Muokkaa\", href = \"/muokkaa\" } ]
    , isOpen   = model.dropdownOpen   -- aria-expanded päivittyy automaattisesti
    , onToggle = ToggleDropdown
    , onClose  = CloseDropdown        -- laukaisee myös Escape-näppäin
    }
-- Renderöityy:
--   <button aria-haspopup=\"menu\" aria-expanded=\"true\">Toiminnot ▾</button>
--   <div role=\"menu\">
--     <a role=\"menuitem\" href=\"/muokkaa\">Muokkaa</a>
--   </div>"""
                ]

            -- Tabs / aria-controls + aria-labelledby
            , Html.div [ Attr.class "space-y-3" ]
                [ Html.p [ Attr.class "font-semibold text-sm text-brand" ] [ Html.text "aria-controls ja aria-labelledby — Tabs" ]
                , Html.p [ Attr.class "text-sm text-gray-600" ]
                    [ Html.text "Välilehtipanelit linkitetään välilehtipainikkeisiin "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "aria-controls" ]
                    , Html.text " (painike → paneeli) ja "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "aria-labelledby" ]
                    , Html.text " (paneeli → painike) -attribuuteilla. Tabs-komponentti generoi "
                    , Html.code [ Attr.class "font-mono text-xs bg-gray-100 px-1 rounded" ] [ Html.text "id" ]
                    , Html.text "-arvot indeksin perusteella."
                    ]
                , viewCodeBlock
                    """-- Tabs.view tuottaa automaattisesti:
--   <div role=\"tablist\">
--     <button role=\"tab\" id=\"tab-0\" aria-controls=\"panel-0\" aria-selected=\"true\">
--       Esikatselu
--     </button>
--   </div>
--   <div role=\"tabpanel\" id=\"panel-0\" aria-labelledby=\"tab-0\">
--     ...sisältö...
--   </div>
--
-- Nuolinäppäimet (← →) vaihtavat aktiivista välilehteä.
Tabs.view
    { tabs        = [ \"Esikatselu\", \"Koodi\" ]
    , activeIndex = model.activeTab
    , onTabClick  = SetTab
    , panels      = [ previewPanel, codePanel ]
    }"""
                ]

            -- Why String not Html msg
            , viewRuleCard "Miksi label on String eikä Html msg?"
                "Avustava teknologia (ruudunlukijat) lukee aria-label-attribuutin, joka on pelkkä merkkijono. Jos välittäisit Html msg -sisällön, HTML-rakenne renderöityisi näkymään mutta aria-label pysyisi tyhjänä tai puuttuisi kokonaan — ruudunlukija ei voisi lukea sitä. Rajoittamalla label-kenttä String-tyypiksi komponenttikirjasto varmistaa, että saavutettava nimi on aina läsnä."
            ]
        ]


viewCodeBlock : String -> Html msg
viewCodeBlock src =
    Html.div [ Attr.class "overflow-x-auto" ]
        [ Html.pre
            [ Attr.class "bg-gray-900 text-gray-100 rounded-lg p-4 text-xs leading-relaxed overflow-x-auto" ]
            [ Html.code [] [ Html.text src ] ]
        ]


viewCodeComparison : String -> String -> String -> String -> Html msg
viewCodeComparison badLabel badSrc goodLabel goodSrc =
    Html.div [ Attr.class "grid grid-cols-1 sm:grid-cols-2 gap-3" ]
        [ Html.div [ Attr.class "space-y-1" ]
            [ Html.p [ Attr.class "text-xs font-semibold text-red-600" ] [ Html.text ("✗ " ++ badLabel) ]
            , viewCodeBlock badSrc
            ]
        , Html.div [ Attr.class "space-y-1" ]
            [ Html.p [ Attr.class "text-xs font-semibold text-green-600" ] [ Html.text ("✓ " ++ goodLabel) ]
            , viewCodeBlock goodSrc
            ]
        ]


-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------


th : String -> Html msg
th label =
    Html.th [ Attr.class "px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider" ]
        [ Html.text label ]


viewRuleCard : String -> String -> Html msg
viewRuleCard title body =
    Html.div [ Attr.class "border-l-4 border-brand-yellow pl-4 py-1 space-y-1" ]
        [ Html.p [ Attr.class "font-semibold text-sm text-brand" ] [ Html.text title ]
        , Html.p [ Attr.class "text-sm text-gray-600" ] [ Html.text body ]
        ]
