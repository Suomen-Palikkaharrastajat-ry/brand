module Route.Saavutettavuus exposing (ActionData, Data, Model, Msg, route)

{-| Accessibility guide page.

Covers WCAG conformance levels, colour contrast, focus management,
screen-reader usage, and form labelling requirements.

-}

import BackendTask exposing (BackendTask)
import Component.Alert as Alert
import Component.SectionHeader as SectionHeader
import FatalError exposing (FatalError)
import FeatherIcons
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StaticPayload)
import Shared
import SiteMeta
import Tailwind as Tw exposing (classes)
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Th
import TailwindExtra as TwEx
import TailwindTokens as TC
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
        [ Html.div
            [ classes
                [ TwEx.max_w_5xl
                , Tw.mx_auto
                , Tw.px Th.s4
                , Tw.py Th.s8
                , Bp.sm [ Tw.py Th.s12 ]
                , TwEx.space_y Th.s12
                , Bp.sm [ TwEx.space_y Th.s16 ]
                ]
            ]
            [ Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.h1 [ classes [ Tw.text_2xl, Bp.sm [ Tw.text_3xl ], Tw.font_bold, Tw.text_simple TC.brand ] ]
                    [ Html.text "Saavutettavuus" ]
                , Html.p [ classes [ Tw.text_sm, Bp.sm [ Tw.text_base ], Tw.text_color (Th.gray Th.s500) ] ]
                    [ Html.text "WCAG 2.1 AA -ohjeistus kontrasteista, värisokeustuesta, animaatioista ja saavutettavasta nimeämisestä. Koneluettava: "
                    , Html.a
                        [ Attr.href "/design-guide/index.jsonld"
                        , classes [ Tw.underline, Bp.hover [ Tw.text_simple TC.brand ], Tw.transition_colors, Tw.font_mono, Tw.text_sm ]
                        ]
                        [ Html.text "design-guide/" ]
                    , Html.text "."
                    ]
                ]
            , viewSkipToContentSection
            , Alert.view
                { alertType = Alert.Info
                , title = Just "WCAG 2.1 AA — tavoitetaso"
                , body =
                    [ Html.text "Kaikki brändimateriaalit ja käyttöliittymäkomponentit noudattavat vähintään WCAG 2.1 AA -tasoa. Kontrastitiedot löytyvät myös koneluettavasta "
                    , Html.a [ Attr.href "/brand.json", classes [ Tw.underline ] ] [ Html.text "brand.json" ]
                    , Html.text " -tiedostosta (kenttä "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs ] ] [ Html.text "colors.brand[*].wcag" ]
                    , Html.text ")."
                    ]
                , onDismiss = Nothing
                }
            , viewContrastSection
            , viewSemanticPairingsSection
            , viewDarkSurfaceSection
            , viewColorBlindSection
            , viewMotionSection
            , viewLogoAltSection
            , viewFocusSection
            , viewAccessibleNamingSection
            ]
        ]
    }



-- ---------------------------------------------------------------------------
-- Skip to content
-- ---------------------------------------------------------------------------


viewSkipToContentSection : Html msg
viewSkipToContentSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Ohita-navigaatio-linkki"
            , description = Just "Skip-to-content-linkki on pakollinen näppäimistökäyttäjille — ilman sitä koko navigaatio täytyy läpikäydä joka sivulatauksella."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ viewRuleCard "Lisää ensimmäiseksi elementiksi <body>:n sisälle"
                "Linkki on piilotettu oletuksena (sr-only) mutta tulee näkyviin, kun se saa kohdistuksen. Näin se ei häiritse visuaalista layoutia mutta on saavutettava näppäimistöllä."
            , Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "HTML-esimerkki" ]
                , Html.pre [ classes [ Tw.bg_color (Th.gray Th.s900), Tw.text_color (Th.gray Th.s100), Tw.rounded_lg, Tw.p Th.s4, Tw.text_xs, Tw.leading_relaxed, Tw.overflow_x_auto ] ]
                    [ Html.code []
                        [ Html.text """<a href="#main-content"
   class="sr-only focus:not-sr-only focus:absolute
          focus:top-4 focus:left-4 focus:z-50
          bg-white text-brand font-semibold
          py-2 px-4 rounded shadow-lg">
  Siirry pääsisältöön
</a>

<!-- ... navigaatio ... -->

<main id="main-content" tabindex="-1">
  <!-- sivun sisältö -->
</main>""" ]
                    ]
                ]
            , viewRuleCard "Elm-pages: lisää Shared.elm-tiedostoon"
                "Elm-pages-sovelluksessa skip-linkki kuuluu Shared.view-funktioon ennen navigaatiopalkkia, jotta se renderöityy joka sivulla ensimmäisenä elementtinä."
            ]
        ]



-- ---------------------------------------------------------------------------
-- Contrast
-- ---------------------------------------------------------------------------


viewContrastSection : Html msg
viewContrastSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Kontrastisuhteet"
            , description = Just "WCAG 2.1 vaatii vähintään 4.5:1 normaalille tekstille (AA) ja 3:1 suurelle tekstille (AA). Tähdellä (*) merkityt ylittävät AAA-tason (7:1)."
            }
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_sm, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ th "Väri"
                        , th "Hex"
                        , th "Valkoisella"
                        , th "Mustalla"
                        , th "Käyttötarkoitus"
                        ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
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
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ] ]
        [ Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_medium, Tw.text_simple TC.brand, Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
            [ Html.span
                [ classes [ Tw.inline_block, Tw.w Th.s4, Tw.h Th.s4, Tw.rounded, Tw.border, TwEx.border_black_10, Tw.shrink_0 ]
                , Attr.style "background-color" row.hex
                ]
                []
            , Html.text row.name
            ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.hex ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3 ] ] [ Html.text row.onWhite ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3 ] ] [ Html.text row.onBlack ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.usage ]
        ]



-- ---------------------------------------------------------------------------
-- Semantic token pairings
-- ---------------------------------------------------------------------------


viewSemanticPairingsSection : Html msg
viewSemanticPairingsSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Semanttiset kontrastiparit"
            , description = Just "Lasketut kontrastisuhteet semanttisten väritokenien yhdistelmille. Käytä tätä taulukkoa, kun valitset teksti–tausta-pareja."
            }
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_sm, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ th "Teksti-token"
                        , th "Tausta-token"
                        , th "Suhde"
                        , th "Taso"
                        , th "Soveltuvuus"
                        ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
                    (List.map viewPairingRow semanticPairingData)
                ]
            ]
        ]


semanticPairingData : List { textToken : String, bgToken : String, ratio : String, level : String, note : String }
semanticPairingData =
    [ { textToken = "text.primary", bgToken = "background.page", ratio = "17.3:1", level = "AAA", note = "Otsikot ja leipäteksti" }
    , { textToken = "text.primary", bgToken = "background.subtle", ratio = "16.8:1", level = "AAA", note = "Kortit ja korostusalueet" }
    , { textToken = "text.muted", bgToken = "background.page", ratio = "4.6:1", level = "AA", note = "Sekundääriteksti ja kuvatekstit" }
    , { textToken = "text.muted", bgToken = "background.subtle", ratio = "4.5:1", level = "AA", note = "Aputekstit korttialueilla" }
    , { textToken = "text.subtle", bgToken = "background.page", ratio = "2.5:1", level = "—", note = "Vain suuri teksti (≥18 pt / 14 pt bold)" }
    , { textToken = "text.onDark", bgToken = "background.dark", ratio = "17.3:1", level = "AAA", note = "Kaikki teksti tummalla taustalla" }
    , { textToken = "text.primary", bgToken = "background.accent", ratio = "11.5:1", level = "AAA", note = "Teksti keltaisella aksenttipainikkeella" }
    ]


viewPairingRow : { textToken : String, bgToken : String, ratio : String, level : String, note : String } -> Html msg
viewPairingRow row =
    let
        levelClasses =
            if row.level == "AAA" then
                [ Tw.text_color (Th.green Th.s700), Tw.font_semibold ]

            else if row.level == "AA" then
                [ Tw.text_color (Th.blue Th.s700), Tw.font_semibold ]

            else
                [ Tw.text_color (Th.red Th.s600), Tw.font_semibold ]
    in
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ] ]
        [ Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_simple TC.brand ] ] [ Html.text row.textToken ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.bgToken ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_xs ] ] [ Html.text row.ratio ]
        , Html.td [ classes ([ Tw.px Th.s4, Tw.py Th.s3, Tw.text_xs ] ++ levelClasses) ] [ Html.text row.level ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.note ]
        ]



-- ---------------------------------------------------------------------------
-- Dark surface pairings
-- ---------------------------------------------------------------------------


viewDarkSurfaceSection : Html msg
viewDarkSurfaceSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Tumman pinnan parit"
            , description = Just "background.dark (#05131D) -taustan kanssa sallitut värit. Käytä vain tässä hyväksyttyjä värejä tummilla osuuksilla."
            }
        , Html.div [ classes [ Tw.overflow_x_auto ] ]
            [ Html.table [ classes [ Tw.w_full, Tw.text_sm, Tw.border_collapse ] ]
                [ Html.thead []
                    [ Html.tr [ classes [ Tw.bg_color (Th.gray Th.s50), Tw.border_b, Tw.border_color (Th.gray Th.s200) ] ]
                        [ th "Väri / token"
                        , th "Hex"
                        , th "Kontrasti"
                        , th "Taso"
                        , th "Käyttö"
                        ]
                    ]
                , Html.tbody [ classes [ Tw.divide_y, TwEx.divide_color (Th.gray Th.s100) ] ]
                    (List.map viewDarkPairingRow darkSurfaceData)
                ]
            ]
        , viewRuleCard "Vältä tummalla: text.muted ja text.subtle"
            "text.muted (#6B7280) saavuttaa vain 2.8:1 tummalla taustalla — alle AA-tason. text.subtle (#9CA3AF) saavuttaa 3.9:1, mikä riittää vain suurelle tekstille (≥18 pt). Käytä näitä värejä ainoastaan vaaleilla taustoilla."
        ]


darkSurfaceData : List { token : String, hex : String, ratio : String, level : String, usage : String }
darkSurfaceData =
    [ { token = "text.onDark / White", hex = "#FFFFFF", ratio = "17.3:1", level = "AAA", usage = "Kaikki teksti ja otsikot" }
    , { token = "brand Yellow", hex = "#FAC80A", ratio = "11.5:1", level = "AAA", usage = "Korostukset, linkit, CTA-painikkeet" }
    , { token = "brand Red", hex = "#C91A09", ratio = "4.2:1", level = "AA", usage = "Varoitukset, virheet (ei pienelle tekstille)" }
    , { token = "text.subtle / gray-400", hex = "#9CA3AF", ratio = "3.9:1", level = "—", usage = "Vain suuri teksti (≥18 pt / 14 pt bold)" }
    , { token = "text.muted / gray-500", hex = "#6B7280", ratio = "2.8:1", level = "—", usage = "Ei sallittu tummalla taustalla" }
    ]


viewDarkPairingRow : { token : String, hex : String, ratio : String, level : String, usage : String } -> Html msg
viewDarkPairingRow row =
    let
        levelClasses =
            if row.level == "AAA" then
                [ Tw.text_color (Th.green Th.s700), Tw.font_semibold ]

            else if row.level == "AA" then
                [ Tw.text_color (Th.blue Th.s700), Tw.font_semibold ]

            else
                [ Tw.text_color (Th.red Th.s600), Tw.font_semibold ]
    in
    Html.tr [ classes [ Bp.hover [ Tw.bg_color (Th.gray Th.s50) ] ] ]
        [ Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_simple TC.brand ] ]
            [ Html.div [ classes [ Tw.flex, Tw.items_center, Tw.gap Th.s2 ] ]
                [ Html.span
                    [ classes [ Tw.inline_block, Tw.w Th.s4, Tw.h Th.s4, Tw.rounded, Tw.border, TwEx.border_black_10, Tw.shrink_0 ]
                    , Attr.style "background-color" row.hex
                    ]
                    []
                , Html.text row.token
                ]
            ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.hex ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.font_mono, Tw.text_xs ] ] [ Html.text row.ratio ]
        , Html.td [ classes ([ Tw.px Th.s4, Tw.py Th.s3, Tw.text_xs ] ++ levelClasses) ] [ Html.text row.level ]
        , Html.td [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.text_xs, Tw.text_color (Th.gray Th.s500) ] ] [ Html.text row.usage ]
        ]



-- ---------------------------------------------------------------------------
-- Color blindness
-- ---------------------------------------------------------------------------


viewColorBlindSection : Html msg
viewColorBlindSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Värisokeustuki"
            , description = Just "Brändivärit ja niiden käyttö värinäön erityisryhmissä."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
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
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Liike ja animaatiot"
            , description = Nothing
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
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
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Logon vaihtoehtoteksti"
            , description = Just "Ohjeet alt-attribuutin käyttöön eri konteksteissa."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
            [ viewRuleCard "Päälogo navigaatiossa"
                "alt=\"Suomen Palikkaharrastajat ry\" — kerro yhdistyksen nimi."
            , viewRuleCard "Logo kuvitustarkoituksessa"
                "alt=\"Suomen Palikkaharrastajat ry — logo\" tai varianttispesifinen kuvaus, esim. alt=\"Sateenkaarilogovariantti\"."
            , viewRuleCard "Koristelullinen logo"
                "Jos logo on pelkästään visuaalinen koriste (esim. taustakuvio), käytä alt=\"\". Lisää myös aria-hidden=\"true\", jotta ruudunlukija ohittaa elementin kokonaan."
            , Html.div [ classes [ TwEx.space_y Th.s2 ] ]
                [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ] [ Html.text "Esimerkki — koristelullinen logo" ]
                , viewCodeBlock """<!-- Koristelullinen: sekä alt="" että aria-hidden="true" -->
<img src="/logo/square/svg/square-smile.svg"
     alt=""
     aria-hidden="true"
     width="40" height="40">

<!-- Merkityksellinen: kuvaava alt, ei aria-hidden -->
<img src="/logo/square/svg/square-smile.svg"
     alt="Suomen Palikkaharrastajat ry"
     width="40" height="40">"""
                ]
            ]
        ]



-- ---------------------------------------------------------------------------
-- Focus
-- ---------------------------------------------------------------------------


viewFocusSection : Html msg
viewFocusSection =
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Kohdistusindikaattorit"
            , description = Just "Näppäimistönavigointi edellyttää selkeää kohdistusindikaattoria."
            }
        , Html.div [ classes [ TwEx.space_y Th.s4 ] ]
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
    Html.section [ classes [ TwEx.space_y Th.s6 ] ]
        [ SectionHeader.view
            { title = "Saavutettava nimeäminen"
            , description = Just "Ohjeet aria-label-, aria-haspopup-, aria-expanded-, aria-controls- ja aria-labelledby-attribuuttien käyttöön komponenttikirjaston kanssa."
            }
        , Html.div [ classes [ TwEx.space_y Th.s6 ] ]
            [ -- CloseButton / aria-label
              Html.div [ classes [ TwEx.space_y Th.s3 ] ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text "aria-label — CloseButton ja Spinner" ]
                , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
                    [ Html.text "Komponentit, jotka eivät sisällä näkyvää tekstiä (kuten × tai pyörivä kehä), tarvitsevat aina "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "aria-label" ]
                    , Html.text "-attribuutin. Komponenttikirjastossa tämä välitetään "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "label : String" ]
                    , Html.text " -kentällä — ei "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "Html msg" ]
                    , Html.text " -tyyppisenä, koska ruudunlukijat jättävät muotoillun HTML-sisällön huomiotta tai lukevat sen väärin."
                    ]
                , viewCodeComparison
                    "Vältä — ei aria-labelia"
                    """-- Ruudunlukija lukee vain "×", ei tiedä mitä suljetaan
Html.button [] [ Html.text "×" ]"""
                    "Oikein — selkeä label"
                    """-- Ruudunlukija lukee "Sulje ilmoitus"
CloseButton.view
    { onClick = DismissAlert
    , label   = "Sulje ilmoitus"  -- aria-label
    }

-- Spinner: label on sr-only -elementissä
Spinner.view
    { size  = Spinner.Medium
    , label = "Ladataan..."  -- aria-label
    }"""
                ]

            -- Dropdown / aria-haspopup + aria-expanded
            , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text "aria-haspopup ja aria-expanded — Dropdown" ]
                , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
                    [ Html.text "Ruudunlukija tarvitsee tiedon siitä, että painike avaa valikon ("
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "aria-haspopup=\"menu\"" ]
                    , Html.text ") ja siitä, onko valikko auki ("
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "aria-expanded" ]
                    , Html.text "). Dropdown-komponentti asettaa nämä automaattisesti "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "isOpen" ]
                    , Html.text "-tilan perusteella."
                    ]
                , viewCodeBlock
                    """Dropdown.view
    { trigger  = Html.text "Toiminnot"
    , items    = [ Dropdown.viewItem { label = "Muokkaa", href = "/muokkaa" } ]
    , isOpen   = model.dropdownOpen   -- aria-expanded päivittyy automaattisesti
    , onToggle = ToggleDropdown
    , onClose  = CloseDropdown        -- laukaisee myös Escape-näppäin
    }
-- Renderöityy:
--   <button aria-haspopup="menu" aria-expanded="true">Toiminnot ▾</button>
--   <div role="menu">
--     <a role="menuitem" href="/muokkaa">Muokkaa</a>
--   </div>"""
                ]

            -- Tabs / aria-controls + aria-labelledby
            , Html.div [ classes [ TwEx.space_y Th.s3 ] ]
                [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text "aria-controls ja aria-labelledby — Tabs" ]
                , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ]
                    [ Html.text "Välilehtipanelit linkitetään välilehtipainikkeisiin "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "aria-controls" ]
                    , Html.text " (painike → paneeli) ja "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "aria-labelledby" ]
                    , Html.text " (paneeli → painike) -attribuuteilla. Tabs-komponentti generoi "
                    , Html.code [ classes [ Tw.font_mono, Tw.text_xs, Tw.bg_color (Th.gray Th.s100), Tw.px Th.s1, Tw.rounded ] ] [ Html.text "id" ]
                    , Html.text "-arvot indeksin perusteella."
                    ]
                , viewCodeBlock
                    """-- Tabs.view tuottaa automaattisesti:
--   <div role="tablist">
--     <button role="tab" id="tab-0" aria-controls="panel-0" aria-selected="true">
--       Esikatselu
--     </button>
--   </div>
--   <div role="tabpanel" id="panel-0" aria-labelledby="tab-0">
--     ...sisältö...
--   </div>
--
-- Nuolinäppäimet (← →) vaihtavat aktiivista välilehteä.
Tabs.view
    { tabs        = [ "Esikatselu", "Koodi" ]
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
    Html.div [ classes [ Tw.overflow_x_auto ] ]
        [ Html.pre
            [ classes [ Tw.bg_color (Th.gray Th.s900), Tw.text_color (Th.gray Th.s100), Tw.rounded_lg, Tw.p Th.s4, Tw.text_xs, Tw.leading_relaxed, Tw.overflow_x_auto ] ]
            [ Html.code [] [ Html.text src ] ]
        ]


viewCodeComparison : String -> String -> String -> String -> Html msg
viewCodeComparison badLabel badSrc goodLabel goodSrc =
    Html.div [ classes [ Tw.grid, Tw.grid_cols_1, Bp.sm [ Tw.grid_cols_2 ], Tw.gap Th.s3 ] ]
        [ Html.div [ classes [ TwEx.space_y Th.s1 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.red Th.s600), Tw.flex, Tw.items_center, Tw.gap Th.s1 ] ]
                [ FeatherIcons.x
                    |> FeatherIcons.withSize 12
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text badLabel
                ]
            , viewCodeBlock badSrc
            ]
        , Html.div [ classes [ TwEx.space_y Th.s1 ] ]
            [ Html.p [ classes [ Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.green Th.s600), Tw.flex, Tw.items_center, Tw.gap Th.s1 ] ]
                [ FeatherIcons.check
                    |> FeatherIcons.withSize 12
                    |> FeatherIcons.toHtml [ Attr.attribute "aria-hidden" "true" ]
                , Html.text goodLabel
                ]
            , viewCodeBlock goodSrc
            ]
        ]



-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------


th : String -> Html msg
th label =
    Html.th [ classes [ Tw.px Th.s4, Tw.py Th.s3, Tw.text_left, Tw.text_xs, Tw.font_semibold, Tw.text_color (Th.gray Th.s500), Tw.uppercase, Tw.tracking_wider ] ]
        [ Html.text label ]


viewRuleCard : String -> String -> Html msg
viewRuleCard title body =
    Html.div [ classes [ Tw.border_l_4, Tw.border_simple TC.brandYellow, Tw.pl Th.s4, Tw.py Th.s1, TwEx.space_y Th.s1 ] ]
        [ Html.p [ classes [ Tw.font_semibold, Tw.text_sm, Tw.text_simple TC.brand ] ] [ Html.text title ]
        , Html.p [ classes [ Tw.text_sm, Tw.text_color (Th.gray Th.s600) ] ] [ Html.text body ]
        ]
