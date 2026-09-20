<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# vernumprojecten.nl

De website van Vernum Projecten B.V., een IT-bedrijf in Groningen:
softwareontwikkeling, IT-projecten en integratie, en advies. De site staat op
<https://vernumprojecten.nl> en telt vijf pagina's plus een 404.

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

## Hoe de site gepubliceerd wordt

Een push naar `main` start `.github/workflows/pages.yml`. Die haalt Zola op,
meet de tarball tegen de gepinde sha256, bouwt de site en zet het resultaat
via GitHub Pages online. De bron van Pages staat op "GitHub Actions", dus er
is geen tak die uit zichzelf iets uitlevert, en er staat geen gebouwde site in
de repository. Terug van een verkeerde pagina is de volgende commit.

## Wat de eigenaar zelf instelt

**DNS bij de registrar.** GitHub Pages bedient het domein pas als de records
ernaar wijzen. Voor `vernumprojecten.nl`:

| Type | Naam | Waarde |
| --- | --- | --- |
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |
| AAAA | `@` | `2606:50c0:8000::153` |
| AAAA | `@` | `2606:50c0:8001::153` |
| AAAA | `@` | `2606:50c0:8002::153` |
| AAAA | `@` | `2606:50c0:8003::153` |
| CNAME | `www` | `vernum-projecten.github.io` |

Deze adressen zijn op 2026-09-20 gelezen op
[docs.github.com](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site).
Lees ze opnieuw op de dag dat je ze invoert; GitHub kan ze veranderen.

**HTTPS afdwingen.** Zodra de records zijn doorgegeven en GitHub een
certificaat heeft uitgegeven, zet je in Settings, Pages het vinkje "Enforce
HTTPS" aan. Tot dat certificaat er is, is het vinkje grijs.

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

## Indeling van de repository

| Pad | Wat er staat |
| --- | --- |
| `config.toml` | de configuratie van Zola, in het Nederlands |
| `content/` | de pagina's als markdown |
| `templates/` | de Tera-sjablonen: de schil, de twee paginavormen, de onderdelen |
| `sass/` | de ene stylesheet, die de kleurtokens en de lettertypen inleest |
| `static/` | wat ongewijzigd meegaat: merkbestanden, favicons, de webfonts, `CNAME` |
| `assets/` | de huisstijl zoals de eigenaar die vaststelde, de bron van `static/` |
| `docs/` | de versiematrix en de huisstijl |
| `scripts/checks/` | de controles die per bewerking en in CI draaien |
| `.github/workflows/` | `ci.yml` (de controles) en `pages.yml` (bouwen en publiceren) |

## Licentie

De code en de configuratie staan onder de
[Apache License 2.0](LICENSE); zie [`NOTICE`](NOTICE). De teksten en de
afbeeldingen van de site zijn © Vernum Projecten B.V. en vallen niet onder die
licentie. Het lettertype Inter houdt zijn eigen voorwaarden, de SIL Open Font
License 1.1, in `assets/fonts/inter/LICENSE.txt`.
