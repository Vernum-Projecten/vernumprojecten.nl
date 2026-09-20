<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Huisstijl van Vernum Projecten B.V.

De visuele identiteit is van het bedrijf en is op 2026-09-17 door de eigenaar
vastgesteld. Deze site is er een afnemer van, naast alles wat het bedrijf
verder onder zijn naam naar buiten brengt. Dit bestand beschrijft wat deze
site ervan gebruikt en welke regels daarbij gelden. Verander hier geen kleur
en geen maat: de huisstijl staat vast en een wijziging is een besluit van de
eigenaar, niet van een pagina.

Geen specificatie schrijft een huisstijl voor; dit is eigen ontwerp, met de
contrasteisen van WCAG 2.2 als enige externe meetlat.

## 1. Het idee

Het eerste woord van de naam is Latijn voor "van de lente". Het merkteken is
een **V** van twee armen die elkaar niet raken, met daaronder één gouden punt
waar de twee kanten sluiten. Het is getekend voor een boekhoudprogramma, waar
een debet- en een creditkolom op de cent gelijk moeten uitkomen. De kleur is
een diep loofgroen, de ondergrond een warm gebroken wit, het accent een
ingetogen goud dat alleen op een lijn of een zegel verschijnt.

## 2. Het merkteken

De tegel is een vierkant met hoekradius 12 op 64 eenheden, gevuld met `loof`.
De twee armen zijn lijnen van 6,5 eenheden dik met ronde uiteinden, van
(18,16) naar (28,6,39) en van (46,16) naar (35,4,39), in `mist`. Het
balanspunt is een cirkel met straal 5,2 op (32,47,5), in `goud-licht`. Die
getallen zijn het merkteken; alles anders is afgeleid.

Wat deze site ervan gebruikt:

- `static/favicon.svg` en de rasters `favicon-16.png`, `favicon-32.png` en
  `favicon.ico`: het teken op de loofgroene tegel, als pictogram in het
  tabblad.
- `static/apple-touch-icon.png`: hetzelfde teken op 180 px, met de tegelkleur
  tot aan de rand, want iOS maakt de hoeken zelf rond.
- `static/brand/huisstijl-icon-auto.svg`: dezelfde twee vormen met een
  `prefers-color-scheme`-mediaquery in het bestand.

Nooit: de armen spiegelen of laten raken, het punt weglaten of verkleuren, de
tegel een andere kleur of een schaduw geven, het teken roteren.

## 3. Het woordmerk en de lockup

Het woordmerk zet het eerste woord van de naam in Inter SemiBold en het tweede
in Inter Regular. Het staat als omtrekpaden in de SVG, gezet uit de gevendorde
Inter 4.1, zodat geen bestand van een geïnstalleerd lettertype afhangt.

**De vennootschap heet altijd voluit**: Vernum Projecten B.V., nooit het
eerste woord alleen. Er bestaat geen vennootschap die zo heet. Dat geldt ook
voor de `alt`-tekst die een schermlezer voorleest, en
`scripts/checks/company-name.sh` weigert het losse woord in elk bestand van de
boom.

De lockup als afbeelding staat in
`static/brand/vernum-projecten-lockup-auto.svg`, met de mediaquery voor het
donkere thema in het bestand zelf. De maat: tegel 45 op een hoogte van 56,
woordmerk op 30 px, 12 eenheden tussen tegel en woord. De site gebruikt hem
voor de banner van een deelbare link.

In de paginakop staat hij sinds 20-09-2026 niet meer. Daar staan het
merkteken op 32 px en de naam als tekst ernaast: een lockup van 28 px hoog is
op een telefoon een vlek van een paar millimeter, en als tekst blijft de naam
scherp en voorleesbaar.

Nooit: het woordmerk opnieuw zetten uit een lettertype, de afstand tot de
tegel veranderen, of het eerste woord zonder het tweede op een pagina zetten.

De banner voor een deelbare link is `static/brand/vernum-projecten-social.png`,
1280 × 640, en staat als `og:image` in elke pagina.

## 4. Kleuren

Negen tokens, in `sass/_huisstijl-tokens.scss`, met per token een
`safe:`-claim die zegt waarvoor het op welke ondergrond mag. WCAG 2.2 vraagt
4,5:1 voor lopende tekst en 3:1 voor een grafisch element of grote tekst;
`scripts/checks/brand-contrast.sh` meet elke claim tegen de twee ondergronden
en faalt zodra een herkleurd token zijn claim niet meer haalt. De tabel
hieronder is de uitvoer van `--table` op 2026-09-20.

| Token | Hex | Op mist | Op inkt | Veilig voor |
| --- | --- | --- | --- | --- |
| `mist` | `#F5F4EF` | 1,00 | 15,20 | lichte ondergrond |
| `inkt` | `#15201B` | 15,20 | 1,00 | tekst op licht, donkere ondergrond |
| `loof` | `#1E5A44` | 7,33 | 2,07 | tekst en grafiek op licht |
| `blad` | `#7FBF9E` | 1,94 | 7,85 | tekst en grafiek op donker |
| `goud` | `#A67C1F` | 3,45 | 4,40 | grafiek op licht en op donker, nooit lopende tekst |
| `goud-licht` | `#D9B44A` | 1,80 | 8,43 | tekst en grafiek op donker en op de tegel |
| `leisteen` | `#586560` | 5,53 | 2,75 | gedempte tekst op licht |
| `nevel` | `#A7B1AB` | 2,00 | 7,59 | gedempte tekst op donker |
| `zilver` | `#D8DAD4` | 1,28 | 11,88 | lijnen en randen op licht |

Rollen:

- `loof` is de merkkleur: koppen, links, de focusring. Op donker neemt `blad`
  die rol over.
- `goud` is het ene accent. Op deze site draagt het één ding: de lijn onder de
  hoofdlink van een pagina. Het is nooit tekstkleur op licht.
- `inkt` en `mist` zijn de twee ondergronden en elkaars tekstkleur.
- `leisteen` en `nevel` zijn de gedempte tekst: labels, de navigatie, de voet.
- `zilver` is de enige lijnkleur op licht; op donker is een lijn `nevel` op
  30% dekking in CSS.

De stylesheet vertaalt deze tokens één keer naar rollen (`--grond`, `--tekst`,
`--merk`, `--gedempt`, `--lijn`, `--accent`). Het donkere thema wisselt alleen
die rollen om, dus geen enkele regel noemt een tweede kleur.

## 5. Typografie

Eén lettertype: **Inter** (versie 4.1, SIL Open Font License 1.1). De site
laadt de twee variabele webfonts uit `static/fonts/inter/web/`, van zijn eigen
oorsprong; het woordmerk is er als paden uit gezet.

De schaal, in pixels: 12 voor een label in kapitalen met 0,04 em
letterafstand, 14 voor de voet en gedempte tekst, 16 voor lopende tekst, 18
voor de inleiding onder een paginatitel, 20 en 24 voor koppen, 32 voor een
paginatitel. Gewichten: Regular voor tekst, Medium voor labels, SemiBold voor
koppen en de hoofdlink. Lopende tekst blijft onder 72 tekens per regel, wat de
tekstkolom van 36 rem afdwingt.

Datums in lopende tekst als `20-09-2026`.

## 6. Raster en ruimte

De basiseenheid is 4 px; afstanden komen uit 8, 12, 16, 24, 32 en 48. Waar een
pagina meer lucht vraagt dan 48 px, gebruikt zij 64 of 96: veelvouden van
dezelfde eenheid. Hoekradius 6 op iets waar je op klikt, 12 alleen op de
tegel. Geen schaduwen: scheiding komt van ruimte en van één `zilver`-lijn.

De schil is 60 rem breed met een goot van 16 px links en rechts. De
paginakop draagt de lockup op 28 px hoog, links, met de navigatie rechts; op
een smal scherm vouwt de navigatie eronder.

## 7. Onderdelen op deze site

- **Paginakop:** het merkteken op 32 px met de naam als tekst ernaast,
  navigatie rechts in `leisteen`, de huidige pagina in de tekstkleur met
  `aria-current="page"`. Onder 40 rem staat de navigatie in een `details` die
  als paneel onder de kop opengaat; er komt geen JavaScript aan te pas.
- **Paginatitel:** een label in kapitalen erboven waar dat iets toevoegt, dan
  de titel in `loof`, dan de inleiding. De maten schalen met `clamp()` mee met
  het venster, tussen de telefoon en de maat uit sectie 5.
- **Blok:** twee blokken onder elkaar worden gescheiden door ruimte en één
  `zilver`-lijn. Dat is de enige scheiding die de site kent.
- **Band:** de startpagina zet een blok op een rustige tint, een menging van
  `loof` met `mist` (5%) op licht en van `blad` met `inkt` (7%) op donker.
  Gemeten op 20-09-2026: lopende tekst haalt er 14,06:1 en 13,43:1, gedempte
  tekst 5,12:1 en 6,70:1, en `goud` als lijn 3,19:1. De pagina's achter het
  menu dragen geen band: daar is rust de opdracht (eigenaar, 20-09-2026).
- **Actie:** de ene knop die op een pagina telt, gevuld met `loof` en tekst in
  `mist` (7,33:1); op donker `blad` met `inkt` (7,85:1). Minstens 44 px hoog.
- **Pictogram:** Lucide, gevendord onder `static/icons/lucide/`, 20 px naast
  een woord en 32 px op een dienstblok, in de kleur van de tekst ernaast en
  nooit alleen. De pin staat in `docs/VERSIONS.md`.
- **Hoofdlink:** de ene link die op een pagina telt, in `loof` SemiBold met
  een 2 px lijn in `goud` eronder. Eén per pagina, nooit twee.
- **Gegevenslijst:** de contactpagina zet label en waarde naast elkaar met een
  `zilver`-lijn tussen de rijen; op een smal scherm onder elkaar. Nummers
  krijgen tabelcijfers.
- **Voet:** een `zilver`-lijn erboven, dan de naam, de plaats, het KVK-nummer
  en het btw-identificatienummer in `leisteen` op 14 px.
- **Donker thema:** dezelfde onderdelen met `inkt` als ondergrond, `mist` als
  tekst, `blad` voor de merkrol, `nevel` voor gedempte tekst en `goud-licht`
  voor het accent. Er is geen schakelaar: de site volgt de instelling van het
  apparaat.

## 8. Bestanden en controles

- `sass/_huisstijl-tokens.scss` is het palet, `sass/_huisstijl-fonts.scss` de
  twee `@font-face`-regels. Beide zijn de huisstijl zoals die is vastgesteld
  en worden hier niet gewijzigd.
- `scripts/checks/brand-contrast.sh` meet de claims in het palet, per
  bewerking en in de CI-stap `brand-contrast`.
- `scripts/checks/company-name.sh` weigert het eerste woord van de naam
  alleen, in de inhoud en in het pad van elk bestand.
- `static/fonts/inter/SHA256SUMS` legt de gevendorde bestanden vast;
  `shasum -a 256 -c SHA256SUMS` in die map controleert ze zonder netwerk.
- `scripts/vendor/icons.sh` haalt de pictogrammen op en weigert een download
  die niet de gepinde is; `scripts/vendor/icons.sh --verify` controleert de
  boom zonder netwerk, en `scripts/checks/versions.sh` meet de pin.

## Bronnen

- WCAG 2.2, contrast (minimum): <https://www.w3.org/TR/WCAG22/#contrast-minimum>;
  contrast van niet-tekst: <https://www.w3.org/TR/WCAG22/#non-text-contrast>
- Inter, Rasmus Andersson: <https://github.com/rsms/inter>, release v4.1
  (2024-11-16); SIL Open Font License 1.1: <https://openfontlicense.org/>
