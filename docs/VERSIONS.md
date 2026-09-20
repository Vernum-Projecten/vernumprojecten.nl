<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Versiematrix

Elke pin op één plek. Dit bestand is de enige bron voor elke versie die ergens
in de repository herhaald wordt. Wijkt een bestand hiervan af, dan is dat
drift; los het op en laat nooit één van beide kanten stilzwijgend winnen.
`scripts/checks/versions.sh` controleert elke overeenkomst die het kan
bereiken en slaat luid over wat nog niet bestaat.

De kolom `Item` is het label dat de scripts opzoeken; verander het niet zonder
`scripts/checks/versions.sh` mee te veranderen. Elke pin is gecontroleerd bij
de uitgever op de datum die erbij staat, nooit uit het geheugen.

Geen specificatie schrijft dit bestand voor; het is eigen ontwerp.

## Sitegenerator

De site wordt gebouwd door Zola, één statische binary die Tera-sjablonen en
markdown leest. De publicatielane haalt de release-tarball van GitHub, meet de
sha256 tegen de rij hieronder en pakt hem pas daarna uit. Er is geen
installatie-actie van derden in de keten en geen pakket van de distributie.

| Item | Pin | Herhaald in |
| --- | --- | --- |
| `Zola` | 0.23.6 (release van 2026-09-12 op github.com/getzola/zola; gecontroleerd 2026-09-20) | `ZOLA_VERSION` in `.github/workflows/pages.yml` en `.github/workflows/ci.yml` |
| `Zola sha256` | `7d77a4220a4f699cba2fc0e0c7859f780e887e269159ad4fab90e11ea16c906f` (`zola-v0.23.6-x86_64-unknown-linux-musl.tar.gz`; zelf gemeten 2026-09-20) | `ZOLA_SHA256` in dezelfde twee workflows |

De release publiceert zelf geen checksumbestand, dus de sha256 hierboven is
gemeten over de asset die de release-API noemt. Bij een nieuwe Zola-versie
meet je hem opnieuw en verandert deze rij mee:

```sh
curl -fsSL -o zola.tar.gz \
  https://github.com/getzola/zola/releases/download/vX.Y.Z/zola-vX.Y.Z-x86_64-unknown-linux-musl.tar.gz
sha256sum zola.tar.gz
```

## Hosting

| Item | Pin | Herhaald in |
| --- | --- | --- |
| `Domein` | vernumprojecten.nl | `base_url` in `config.toml`, `static/CNAME`, de Pages-instelling van de repository |
| `Pages-bron` | GitHub Actions (`build_type=workflow`) | `.github/workflows/pages.yml` |

De A- en AAAA-records van GitHub Pages staan in `README.md` bij de stappen die
de eigenaar bij de registrar zet, met de leesdatum erbij.

## CI-tools

De `guards`-job van `.github/workflows/ci.yml` draait drie analyzers, elk op
een exacte versie zodat een CI-resultaat gelijk is aan het lokale. `zizmor`
komt via `taiki-e/install-action`, dat de upstream checksum verifieert;
`actionlint` draait uit zijn officiële image, gepind op tag en digest.
`shellcheck` staat al op de runner: die installer haalt eerst het pakket van
de distributie weg met `apt-get remove`, en het runneraccount heeft geen sudo.
De job controleert daarom de versie in plaats van hem te installeren.

| Item | Pin | Herhaald in |
| --- | --- | --- |
| `zizmor` | 1.30.1 (gecontroleerd 2026-09-20) | `.github/workflows/ci.yml` |
| `actionlint` | 1.7.12 (gecontroleerd 2026-09-20) | `.github/workflows/ci.yml` |
| `shellcheck` | 0.11.0 (Ubuntu 26.04 levert 0.11.0-2 in universe) | `SHELLCHECK_VERSION` in `.github/workflows/ci.yml`, en de runners |

Houd de lokaal geïnstalleerde versies op deze nummers, zodat een bevinding één
lokale run kost in plaats van een CI-rondje (`.claude/rules/ci-cd.md`).

## GitHub Actions

Elke `uses:` in `.github/workflows/**` is gepind op een volledige commit-SHA
met een `# vX.Y.Z`-commentaar erachter (`.claude/rules/ci-cd.md`). Dependabot
bumpt ze; zizmor controleert de vorm. De set is klein:

| Item | Pin | Gelezen op |
| --- | --- | --- |
| `actions/checkout` | v7.0.1, `3d3c42e5aac5ba805825da76410c181273ba90b1` | 2026-09-20 |
| `actions/configure-pages` | v6.0.0, `45bfe0192ca1faeb007ade9deae92b16b8254a0d` | 2026-09-20 |
| `actions/upload-pages-artifact` | v5.0.0, `fc324d3547104276b827a68afc52ff2a11cc49c9` | 2026-09-20 |
| `actions/deploy-pages` | v5.0.1, `368f82528645a54fb793d4d04e342629a3f51346` | 2026-09-20 |
| `taiki-e/install-action` | v2.87.13, `26e9283f268b880168bdbd2c545dfcd60ec2c6ab` | 2026-09-20 |

## Runners

Elke job draait op de runners van de organisatie, met de labels
`self-hosted, linux, x64, hetzner`. Ze zijn geregistreerd bij
`Vernum-Projecten` vanuit `Vernum-Projecten/hetzner-runners` en bedienen de
hele organisatie. Drie machines op Ubuntu 26.04, één job tegelijk per machine,
en het runneraccount heeft geen sudo.

## Lettertypen

Eén lettertype, gevendord met zijn licentie en zijn `SHA256SUMS` onder
`assets/fonts/inter/`. De site laadt de twee variabele webfonts van zijn eigen
oorsprong; er wordt geen lettertype bij een derde partij opgehaald.

| Item | Pin | Herhaald in |
| --- | --- | --- |
| `Inter` | 4.1 (release v4.1 van 2024-11-16 op github.com/rsms/inter) | `assets/fonts/inter/PROVENANCE.md`, `assets/brand/fonts.css`, `docs/huisstijl.md` |

## Huisstijl

De huisstijl is van het bedrijf en staat vast in `docs/huisstijl.md`. De
bestanden onder `assets/brand/` zijn de bron; `static/` draagt de kopieën die
de site uitlevert. `scripts/checks/brand-contrast.sh` meet elk token in
`assets/brand/tokens.css` tegen de twee ondergronden.

## Licentie

| Item | Pin | Herhaald in |
| --- | --- | --- |
| `Project licence` | Apache-2.0 | `LICENSE`, `NOTICE`, de SPDX-kop van elk eigen bestand |

`scripts/checks/versions.sh` faalt op elk eigen bestand dat een andere
licentie claimt. Het gevendorde lettertype houdt zijn eigen voorwaarden, de
SIL Open Font License 1.1, vastgelegd in `assets/fonts/inter/LICENSE.txt`.
