<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# vernumprojecten.nl

De website van Vernum Projecten B.V., een IT-bedrijf in Groningen:
IT-advies, softwareontwerp en softwareontwikkeling. De site staat op
<https://vernumprojecten.nl> en telt zes pagina's plus een 404.

De site is statisch. Er draait geen server van ons, er staat geen JavaScript
in, er wordt geen cookie gezet en er is geen statistiekendienst. Wat je
browser ophaalt is HTML, één stylesheet, twee lettertypebestanden en een paar
SVG's, allemaal van dit domein zelf.

## Hoe de site gebouwd wordt

De generator is [Zola](https://www.getzola.org/), één statische binary
geschreven in Rust. Die leest de Tera-sjablonen in `templates/`, de
Nederlandse markdown in `content/` en de Sass in `sass/`, en schrijft de hele
site naar `public/`. De versie staat gepind in
[`docs/VERSIONS.md`](docs/VERSIONS.md), samen met de sha256 van de tarball die
de publicatielane ophaalt.

Lokaal bouwen en bekijken:

```sh
zola serve      # bouwt en serveert op http://127.0.0.1:1111
zola build      # schrijft de site naar public/
zola check      # controleert elke interne en externe link
```

Voor het pushen draaien de controles die ook in CI staan:

```sh
scripts/checks/prose-style.sh --all      # geen verboden woorden, geen em dash
scripts/checks/versions.sh               # elke pin tegen docs/VERSIONS.md
scripts/checks/brand-contrast.sh         # elk kleurtoken haalt zijn WCAG-claim
scripts/checks/company-name.sh --all     # het bedrijf voluit, en geen tweede
```

`zola check` volgt ook elke externe link. In CI draait hij met
`--skip-external-links`, zodat een site die even traag antwoordt geen bouw
laat omvallen; lokaal draai je hem zonder die vlag als je een link hebt
toegevoegd of gewijzigd.

## Hoe de site gepubliceerd wordt

Een push naar `main` start `.github/workflows/pages.yml`. Die haalt Zola op,
meet de tarball tegen de gepinde sha256, bouwt de site en zet het resultaat
via GitHub Pages online. De bron van Pages staat op "GitHub Actions", dus er
is geen tak die uit zichzelf iets uitlevert, en er staat geen gebouwde site in
de repository. Terug van een verkeerde pagina is de volgende commit.

Het domein, het certificaat en de Pages-instellingen staan vast; wat er
precies staat en hoe je het naleest, staat in
[`docs/publiceren.md`](docs/publiceren.md).

## Wat de wet op deze site vraagt

Twee artikelen bepalen wat de contactpagina toont, en ze staan daar met naam
genoemd:

- **Burgerlijk Wetboek Boek 3, artikel 15d**: een dienstverlener maakt zijn
  identiteit, zijn adres, zijn e-mailadres en zijn nummer in het
  Handelsregister gemakkelijk, rechtstreeks en permanent toegankelijk, en
  noemt zijn btw-identificatienummer.
  <https://wetten.overheid.nl/BWBR0005291>
- **Handelsregisterwet 2007, artikel 27**: een ingeschreven onderneming
  vermeldt haar Handelsregisternummer op de stukken en de elektronische
  berichten die zij verzendt. <https://wetten.overheid.nl/BWBR0021777>

Verder staat er geen bedrijfsgegeven in deze repository: geen klantnaam, geen
bedrag uit een overeenkomst, geen bankgegeven, geen factuur.

## De privacyverklaring en de voorwaarden

`/privacy/` is de verklaring onder de AVG en noemt per verwerking het artikel
waar zij op rust. `/voorwaarden/` draagt de algemene voorwaarden en staat
gemarkeerd als concept: de tekst is nog niet vastgesteld. Twee dingen die bij
het schrijven zijn nagekeken, met de datum erbij:

- **De NLdigital Voorwaarden 2025 zijn niet vrij te gebruiken** (gelezen
  20-09-2026 op
  <https://www.nldigital.nl/kennis-producten/nldigital-voorwaarden-2025/>).
  De pagina zegt "Gratis voor leden en vanaf €395,- (ex. btw) voor
  niet-leden", en over wijzigen: "Nee, ze mogen niet inhoudelijk worden
  aangepast. Op de NLdigital Voorwaarden 2025 rust namelijk het auteursrecht
  van NLdigital." Een niet-lid koopt ze dus, of schrijft een eigen set. Het
  concept op `/voorwaarden/` is die eigen set.
- **Deponeren bij KVK kan nog steeds en is niet verplicht** (gelezen
  20-09-2026 op
  <https://www.kvk.nl/deponeren/algemene-voorwaarden-deponeren/>): "Je kunt de
  algemene voorwaarden van je organisatie bij KVK of de rechtbank deponeren.
  Dit is niet verplicht, maar kan in verschillende situaties handig zijn." KVK
  rekent een tarief per document per kalenderjaar. Deponeren vervangt het
  ter hand stellen niet: artikel 6:234 van het Burgerlijk Wetboek vraagt dat
  de voorwaarden voor of bij het sluiten van de overeenkomst aan de wederpartij
  worden gegeven.

## Indeling van de repository

| Pad | Wat er staat |
| --- | --- |
| `config.toml` | de configuratie van Zola, in het Nederlands |
| `content/` | de pagina's als markdown |
| `templates/` | de Tera-sjablonen: de schil, de twee paginavormen, de onderdelen |
| `sass/` | de ene stylesheet, plus het palet en de lettertypen van de huisstijl |
| `static/` | wat ongewijzigd meegaat: merkbestanden, favicons, de webfonts, `CNAME` |
| `docs/` | de versiematrix, de huisstijl en hoe er gepubliceerd wordt |
| `scripts/checks/` | de controles die per bewerking en in CI draaien |
| `.github/workflows/` | `ci.yml` (de controles) en `pages.yml` (bouwen en publiceren) |

## Licentie

De code en de configuratie staan onder de
[Apache License 2.0](LICENSE); zie [`NOTICE`](NOTICE). De teksten en de
afbeeldingen van de site zijn © Vernum Projecten B.V. en vallen niet onder die
licentie. Het lettertype Inter houdt zijn eigen voorwaarden, de SIL Open Font
License 1.1, in `assets/fonts/inter/LICENSE.txt`.
