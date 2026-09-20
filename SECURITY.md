<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Beveiliging

Deze repository bouwt en publiceert <https://vernumprojecten.nl>, de website
van Vernum Projecten B.V. Vind je een beveiligingsprobleem, meld het dan
zoals hieronder staat. Je mag je melding in het Engels schrijven; *you are
welcome to report in English.*

## Wat er te melden valt

De site is statisch. Er draait geen server van ons, er zijn geen accounts,
er wordt niets ingevuld en er wordt geen gegeven van een bezoeker opgeslagen.
Wat overblijft is toch de moeite waard om te melden:

- een fout in `.github/workflows/`, bijvoorbeeld een stap die met te veel
  rechten draait of die invoer van buiten in een shell laat komen;
- een afhankelijkheid of een gepinde versie in `docs/VERSIONS.md` waarvoor een
  advisory bestaat;
- een pagina die iets uitlevert wat er niet hoort te staan, of die een bestand
  bij een derde partij ophaalt (dat zou de privacyverklaring onwaar maken);
- een geheim dat per ongeluk in de geschiedenis van de repository staat.

Buiten bereik: bevindingen over GitHub zelf (meld die bij GitHub), een
ontbrekende HTTP-header die GitHub Pages bepaalt en wij niet kunnen zetten, de
uitslag van een scanner zonder dat je laat zien wat een aanvaller ermee kan,
en meldingen over e-mail of telefoon die niet over deze site gaan.

## Hoe je meldt

Gebruik bij voorkeur de private meldknop van GitHub. Die staat aan voor deze
repository: ga naar het tabblad **Security** en kies **Report a
vulnerability**. Het gesprek blijft dan tussen jou en ons tot het opgelost is,
en het staat op de juiste plek.

Lukt dat niet, schrijf dan naar het e-mailadres op de
[contactpagina](https://vernumprojecten.nl/contact/). Zet er in het onderwerp
"beveiliging" bij.

Wat helpt in een melding: welke pagina of welk bestand het betreft, wat je
deed, wat er gebeurde en wat je verwachtte, en zo mogelijk een commit of een
regelnummer. Een stukje voorbeeldcode of een screenshot is welkom.

## Wat je terugkrijgt

Het bedrijf heeft één bestuurder, dus er is geen dienst die dag en nacht
meekijkt. De afspraak die we wel waarmaken:

- binnen vijf werkdagen een ontvangstbevestiging, van een mens;
- daarna laten we weten of we het probleem herkennen en wat we ermee doen;
- als we het oplossen, hoor je wanneer het live staat.

Er is geen beloningsprogramma en we betalen niet voor meldingen. Wil je
genoemd worden als vinder, zeg dat er dan bij; dan zetten we je naam in
`CHANGELOG.md` bij de regel die het oplost.

Meld het probleem niet openbaar (geen issue, geen pull request, geen bericht
op sociale media) voordat het opgelost is. Publiceer je het na afloop zelf,
dan horen we graag waar.

## Welke versie wordt ondersteund

Eén: wat er nu op <https://vernumprojecten.nl> staat. De site is de laatste
commit op `main`; er zijn geen tags, geen oudere versies en geen
parallelle takken die iets uitleveren. Een oplossing is de volgende commit,
en die staat binnen enkele minuten online.
