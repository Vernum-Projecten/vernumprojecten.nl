<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Changelog

Elke wijziging met een zichtbaar effect krijgt een regel, in dezelfde pull
request. Het formaat is [Keep a Changelog 1.1.0](https://keepachangelog.com/nl/1.1.0/)
en de versienummering volgt [Semantic Versioning 2.0.0](https://semver.org/lang/nl/).

## [Unreleased]

### Toegevoegd

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
  issue-loop), de twee hooks die per bewerking meekijken, en de controles
  `prose-style.sh`, `versions.sh` en `company-name.sh`.
- `docs/VERSIONS.md` als de enige plek waar een versie staat, met per pin de
  datum waarop hij bij de uitgever is gelezen.
- Een Nederlandse `README.md` die zegt wat de site is, hoe je hem bouwt, hoe
  hij gepubliceerd wordt, en welke DNS-records de eigenaar bij de registrar
  zet.
- `NOTICE`, `.editorconfig`, `.gitattributes`, `.gitignore` en een
  Dependabot-configuratie voor de actions.
- `SECURITY.md`: wat er te melden valt, hoe je meldt (de private meldknop van
  GitHub staat aan voor deze repository) en wat je terugkrijgt.
