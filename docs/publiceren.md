<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Publiceren

De site is wat `.github/workflows/pages.yml` bij de laatste push naar `main`
heeft gebouwd. Er is geen tak die uit zichzelf iets uitlevert en er staat geen
gebouwde site in de repository. Terug van een verkeerde pagina is de volgende
commit; die staat binnen enkele minuten online.

## Hoe de lane werkt

1. Een push naar `main` start de workflow.
2. De bouwjob haalt de Zola-tarball van de GitHub-release, meet de sha256
   tegen de rij `Zola sha256` in [`VERSIONS.md`](VERSIONS.md) en pakt hem pas
   daarna uit. Klopt de som niet, dan stopt de run en is er geen site
   veranderd.
3. `zola build` schrijft de site naar `public/`.
4. De uitvoer gaat als Pages-artefact naar de deploy-job, en alleen die job
   heeft `pages: write` en `id-token: write`.

De versies en de commit-SHA's van de actions staan in
[`VERSIONS.md`](VERSIONS.md); de regels waaronder de workflows staan in
`.claude/rules/ci-cd.md`.

## Hoe de repository is ingesteld

Gelezen op 2026-09-20 met
`gh api repos/Vernum-Projecten/vernumprojecten.nl/pages`:

| Instelling | Waarde |
| --- | --- |
| Bron | GitHub Actions (`build_type: workflow`) |
| Domein | `vernumprojecten.nl` |
| Status van het domein | geverifieerd |
| Certificaat | uitgegeven, geldig tot 2026-12-19 |
| HTTPS afgedwongen | ja |

`static/CNAME` draagt dezelfde naam als de Pages-instelling. Dat moet zo
blijven: GitHub leest dat bestand uit het artefact, en een verschil zet de
instelling bij de volgende publicatie uit
([GitHub Docs, Managing a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)).
`scripts/checks/versions.sh` vergelijkt het bestand, `base_url` in
`config.toml` en de rij `Domein` in de versiematrix met elkaar.

## Naleeslijst

Wil je weten of het nog staat zoals hierboven:

```sh
gh api repos/Vernum-Projecten/vernumprojecten.nl/pages
curl -sSI https://vernumprojecten.nl/ | head -n 1
gh run list --workflow=pages.yml --limit 5
```

Het certificaat van GitHub vernieuwt zichzelf. Loopt de datum hierboven af
zonder dat er een nieuwe in de plaats komt, dan is er iets met de DNS-records
gebeurd en zegt het antwoord van de eerste opdracht wat.

## De meldroute vernieuwen

`static/.well-known/security.txt` staat op het pad dat RFC 9116 vastlegt en
draagt een `Expires`. Dat veld loopt af op **2027-09-20**. Een bestand met een
verlopen `Expires` zegt een melder dat de route verlaten is, dus dat is erger
dan geen bestand.

Zet de datum uiterlijk een maand voor die dag een jaar vooruit, in dezelfde
pull request als niets anders, en lees daarna
`curl -s https://vernumprojecten.nl/.well-known/security.txt` terug. Het
programma op `boekhouding.vernumprojecten.nl` draagt hetzelfde bestand met
dezelfde datum; daar faalt een test zodra de dag voorbij is
(`app/vernumboek-web/tests/it/disclosure.rs` in de VernumBOEK-repository), dus
die kant meldt zich vanzelf. Deze kant niet: dit stuk tekst is de herinnering.
