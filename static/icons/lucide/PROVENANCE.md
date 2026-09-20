<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Herkomst: de pictogrammen van Lucide

Deze pictogrammen zijn niet van ons. Ze komen byte voor byte uit de releasezip
die het Lucide-project op GitHub publiceert. Alleen wat de sjablonen tekenen
staat hier; de rest van de set is niet overgenomen.

Dit bestand is geschreven door `scripts/vendor/icons.sh`. Wijzig het niet met
de hand: pas het script aan en draai het opnieuw.

## Pin

| Onderdeel | Waarde |
| --- | --- |
| Versie | Lucide 1.47.0 (de rij `Lucide` in `docs/VERSIONS.md`) |
| Release | <https://github.com/lucide-icons/lucide/releases/tag/1.47.0> |
| Zip | `https://github.com/lucide-icons/lucide/releases/download/1.47.0/lucide-icons-1.47.0.zip` |
| Sha256 van de zip | `84aa2931525f129cc3ed2530dd079feb8470b575d56d1fb4fa7404b185af058e` |
| Sha256 van de licentie | `b495047bd93a9b06913511076f504daba17d5bbeb3e0650f3bb53a4220329c57` |
| Opgehaald op | 2026-09-20 |
| Bestanden | 7 |

## Overgenomen bestanden

De sha256 van elk bestand staat in `SHA256SUMS` ernaast. Controleer de boom
zonder netwerk met:

```sh
scripts/vendor/icons.sh --verify
```

- `LICENSE`
- `arrow-right.svg`
- `code.svg`
- `compass.svg`
- `mail.svg`
- `menu.svg`
- `pencil-ruler.svg`

## Voorwaarden van de uitgever

Lucide staat onder de ISC-licentie; de tekst staat in `LICENSE` in deze map en
gaat met de bestanden mee, zoals die licentie vraagt. De sjablonen zetten de
pictogrammen ongewijzigd in de pagina, met `currentColor` als kleur.
