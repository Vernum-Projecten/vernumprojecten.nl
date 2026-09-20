<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Herkomst: het lettertype Inter

Inter is niet van ons. De bestanden hiernaast komen byte voor byte uit de
releasezip die Rasmus Andersson op GitHub publiceert, en zijn overgenomen uit
de huisstijl van het bedrijf (`docs/huisstijl.md`). Alleen wat de site nodig
heeft staat hier: de twee variabele webfonts en de licentietekst. De statische
TTF's uit dezelfde release horen bij de factuur-PDF en staan hier niet.

## Pin

| Onderdeel | Waarde |
| --- | --- |
| Versie | Inter 4.1 (de rij `Inter` in `docs/VERSIONS.md`) |
| Release | <https://github.com/rsms/inter/releases/tag/v4.1>, 2024-11-16 |
| Zip | `https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip` |
| Sha256 van de zip | `9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e` |
| Bestanden | 3 |

## Overgenomen bestanden

De sha256 van elk bestand staat in `SHA256SUMS` ernaast. Controleer de boom
zonder netwerk met:

```sh
cd static/fonts/inter && shasum -a 256 -c SHA256SUMS
```

- `LICENSE.txt`
- `web/InterVariable.woff2`
- `web/InterVariable-Italic.woff2`

## Voorwaarden van de uitgever

Inter staat onder de SIL Open Font License 1.1; de tekst staat in
`LICENSE.txt` in deze map en wordt met de bestanden meegeleverd, zoals die
licentie vraagt. De licentie staat gebruik op een website toe en verbiedt het
lettertype onder zijn eigen naam gewijzigd te verspreiden. Wij wijzigen er
niets aan.
