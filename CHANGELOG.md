<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Changelog

Elke wijziging met een zichtbaar effect krijgt een regel, in dezelfde pull
request. Het formaat is [Keep a Changelog 1.1.0](https://keepachangelog.com/nl/1.1.0/)
en de versienummering volgt [Semantic Versioning 2.0.0](https://semver.org/lang/nl/).

## [Unreleased]

### Toegevoegd

- De startpagina bestaat uit blokken: een opening met het merkteken en de
  actie, drie diensten met een pictogram, de vier stappen van een opdracht en
  een afsluiting. De andere pagina's kregen een kopblok met secties eronder.
- Zes pictogrammen van Lucide 1.47.0, gevendord met hun licentie onder
  `static/icons/lucide/` door `scripts/vendor/icons.sh`, en in de pagina zelf
  gezet. Er wordt niets bij een derde partij opgehaald.
- Een foto op de pagina Over, bijgesneden en verkleind tot 600 en 1200 px
  breed.
- `/voorwaarden/`: de algemene voorwaarden, gemarkeerd als concept tot de
  eigenaar ze vaststelt. De NLdigital Voorwaarden 2025 zijn niet gebruikt,
  omdat een niet-lid ze koopt vanaf € 395 en ze niet mag aanpassen (gelezen
  20-09-2026). De pagina staat in de voet van elke pagina.
- De site zelf: vijf pagina's in het Nederlands (Home, Diensten, Werkwijze,
  Over, Contact, Privacy) en een 404, gebouwd door Zola uit Tera-sjablonen.
  Geen JavaScript, geen cookie, geen bestand van een andere oorsprong.
- De huisstijl op de site: het palet en de twee lettertypen als Sass-partials,
  het merkteken als favicon, de lockup in de paginakop, de banner als
  `og:image`. `docs/huisstijl.md` legt vast wat de site ervan gebruikt en
  `scripts/checks/brand-contrast.sh` meet elk kleurtoken.
- Inter 4.1 gevendord onder `static/fonts/inter/`, met zijn licentie, een
  `PROVENANCE.md` en een `SHA256SUMS` die `scripts/checks/versions.sh`
  nakijkt.
- `docs/publiceren.md`: hoe de site op het domein komt en hoe de repository
  daarvoor is ingesteld.
- De twee workflows. `pages.yml` bouwt de site bij elke push naar `main` en
  zet hem online; alleen de deploy-job heeft de rechten om te publiceren.
  `ci.yml` draait zizmor, actionlint, shellcheck en de vier controles, plus
  `zola check` en `zola build`.
- `scripts/ci/install-zola.sh` haalt de gepinde Zola op en weigert elke andere
  inhoud. De weigering wordt bij elke push bewezen met `--self-test`, dus een
  wijziging aan de lane wordt gemeten voordat er iets gepubliceerd wordt.
- De werkafspraken van de repository: `CLAUDE.md`, de regels onder
  `.claude/rules/` (schrijfstijl, CI en publiceren, commentaar, de
  issue-loop), de drie hooks die per bewerking meekijken, en de controles
  `prose-style.sh`, `versions.sh` en `company-name.sh`.
- `docs/VERSIONS.md` als de enige plek waar een versie staat, met per pin de
  datum waarop hij bij de uitgever is gelezen.
- Een Nederlandse `README.md` die zegt wat de site is, hoe je hem bouwt en
  hoe hij gepubliceerd wordt.
- `NOTICE`, `.editorconfig`, `.gitattributes`, `.gitignore` en een
  Dependabot-configuratie voor de actions.
- `SECURITY.md`: wat er te melden valt, hoe je meldt (de private meldknop van
  GitHub staat aan voor deze repository) en wat je terugkrijgt.
- `scripts/gh/labels.sh`: de labelset van de tracker als bestand, zodat hij
  niet alleen in de webinterface bestaat.

### Gewijzigd

- Alle zichtbare teksten zijn herschreven. Elke pagina gaat over het werk en
  over de lezer, die met "u" wordt aangesproken. De omvang van het bedrijf,
  het aantal bestuurders, het jaar van oprichting en de rechtsvorm staan
  nergens meer als argument; wat de wet vraagt blijft op de contactpagina en
  in de voet staan.
- Diensten noemt de drie diensten zoals de eigenaar ze op 2026-09-20 heeft
  vastgesteld: IT-advies, softwareontwerp en softwareontwikkeling. Beheer en
  onderhoud worden niet aangeboden, en Diensten en Werkwijze zeggen dat: een
  opdracht eindigt met de overdracht.
- Werkwijze loopt van het eerste gesprek via het ontwerp en het plan, het
  bouwen in stappen en het testen naar de overdracht, en noemt nog steeds geen
  bedrag en geen termijn zolang die niet zijn vastgesteld.
- De 404-pagina is één zin en een link naar de startpagina.
- De site is licht als de bezoeker niets heeft ingesteld; donker volgt de
  instelling van het apparaat. De stylesheet is mobile-first: de basisregels
  zijn de telefoon en een breder scherm krijgt er lagen bij op 40, 48 en
  60 rem. De typeschaal schaalt met `clamp()` mee met het venster.
- De paginakop draagt het merkteken met de naam als tekst, en onder 40 rem
  een menu dat zonder JavaScript opengaat. De kop blijft bij het scrollen
  staan. Elke link en elke knop is minstens 44 px hoog.
- De voet zet de naam, de plaats, het KVK-nummer en het btw-nummer elk op een
  eigen regel, zodat er niets meer midden in een nummer afbreekt.
- `/privacy/` is een volledige verklaring onder de AVG: wie de
  verwerkingsverantwoordelijke is, wat de site zelf doet, wat de hosting
  vastlegt, wat er met een e-mail gebeurt, op welke grondslag (artikel 6, lid
  1, onderdelen b en f) en welke rechten u heeft (artikel 15 tot en met 21 en
  artikel 77).
- Beide workflows draaien op `ubuntu-latest` in plaats van op de eigen
  machines van de organisatie. Deze repository is openbaar, dus de runners
  van GitHub zijn er gratis voor, en de site wacht niet meer in een rij achter
  de andere repository. `shellcheck` wordt daarbij op zijn gepinde versie
  geïnstalleerd in plaats van van het image van de runner gelezen.
