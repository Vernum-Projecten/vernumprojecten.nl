# CLAUDE.md

**vernumprojecten.nl** is the public website of Vernum Projecten B.V., an IT
company in Groningen. Three services, set by the owner on 2026-09-20:
IT consulting, software design, and software development. Management and
maintenance are not offered; a project ends with a handover, and what runs the
software after that is the client's choice. The site is five pages and a 404,
built by Zola from Tera templates and Dutch markdown, published on GitHub
Pages at
<https://vernumprojecten.nl>. It carries no JavaScript, no cookies, no
analytics and no tracker, and the build output is the whole of what a visitor
receives.

The repository is public. Everything in it is readable by anyone, so it holds
nothing that is not meant to be read.

## The site is Vernum Projecten B.V. alone

The owner ruled on 2026-09-20: the word "holding" and the name of any other
company appear nowhere on this site and nowhere in this repository.
Vernum Projecten B.V. is the only company named.
`scripts/checks/company-name.sh` refuses both, plus the first word of the name
standing on its own, in the content and the path of every tracked file.

A company is named in full: **Vernum Projecten B.V.**, never the first word
alone, because no company is registered under that word (owner ruling
2026-09-18, inherited from the house style).

## Language: Dutch for the visitor, English for the developer

The split is by reader, as in the sibling repository:

- **Dutch:** every word a visitor reads. `content/**`, every string in
  `templates/**`, `config.toml`, `README.md`, `CHANGELOG.md`, `docs/**`, the
  page titles, the alt texts and the footer.
- **English:** identifiers, template variable names, shell scripts, the
  comment lines of every file, commit messages, pull-request and issue text,
  this file and everything under `.claude/`.
- **English, and read while operating rather than visiting:** what a CI run
  prints, and what the check scripts say. A line becomes Dutch the moment the
  built page renders it.

Specification and product proper names stay as they are (`Zola`, `Tera`,
`Sass`, `KVK`, `btw-id`).

## The house style is the oracle

The visual identity is the owner's, set on 2026-09-17, and it is not this
website's to change. `docs/huisstijl.md` records what this site uses of it.
The mark, the lockup, the nine colour tokens with their measured contrast
claims, the type scale and the 4 px grid come from there, and a page that
needs something the house style does not carry is a question for the owner
before it is a line of CSS.

- `sass/_huisstijl-tokens.scss` is the one colour source. A rule never writes
  a hex value; it uses a `--huisstijl-*` token, through the role variables the
  stylesheet defines once.
- `scripts/checks/brand-contrast.sh` measures every token against the two
  grounds and fails when a `safe:` claim no longer holds. WCAG 2.2 asks 4.5:1
  for body text and 3:1 for a graphic (<https://www.w3.org/TR/WCAG22/#contrast-minimum>).
- Inter is the one typeface, vendored under `static/fonts/inter/` with its SIL
  Open Font License 1.1 and a `SHA256SUMS` beside it, served as the two
  variable woff2 files from this site's own origin. No font, and no other
  file, is fetched from a third party.
- Only the Vernum Projecten and the shared `huisstijl-*` files are in this
  tree. No file named after another company is copied in.

## What the law asks the site to show

Two obligations decide the Contact page, and both are cited there:

- **Burgerlijk Wetboek Boek 3 artikel 15d**: a service provider makes its
  identity, its geographic address, its electronic address and its
  registration number in the Handelsregister easily, directly and permanently
  accessible, and names its VAT identification number where it is registered
  for VAT.
- **Handelsregisterwet 2007 artikel 27**: a registered company states its
  Handelsregister number on the documents and electronic communications it
  sends out.

No other company data belongs in this repository. No customer name, no
contract figure, no bank detail, no private address of a person, no invoice.
What the two articles ask for is published because the law asks for it; the
rest stays out.

## Repo map

- `config.toml`: the Zola configuration (Dutch), `base_url` and the site
  metadata. No search index, no feed, no taxonomies.
- `content/`: the pages in Dutch markdown, one file per page.
- `templates/`: the Tera templates. `base.html` is the shell, `index.html`
  and `page.html` the two page shapes, `partials/` the header, the footer and
  the lockup.
- `sass/`: the one stylesheet, compiled by Zola to `/site.css`, plus the house
  style palette and font faces as two partials. There is one copy of each
  file, so nothing can drift against a second one.
- `static/`: what is copied verbatim: the brand files, the favicons, the
  vendored Inter woff2 files with their licence and checksums, `CNAME`.
- `docs/`: `VERSIONS.md` (the pin matrix every other file follows),
  `huisstijl.md` (the house style) and `publiceren.md` (how the site reaches
  the domain, and how the repository is configured).
- `scripts/checks/`: the committed guards. `prose-style.sh`, `versions.sh`,
  `brand-contrast.sh`, `company-name.sh`.
- `scripts/gh/`: `fields.sh`, which sets the organisation's native issue type,
  Priority and Effort fields.
- `.github/workflows/`: `ci.yml` (the guards) and `pages.yml` (build and
  publish).
- `.claude/`: the working discipline. `rules/`, `hooks/`, `settings.json`.

## Issue workflow

The tracker is GitHub Issues and the open issue list is the worklist
(`.claude/rules/issue-workflow.md`). One milestone on every issue, the
organisation's native issue type and Priority field set with
`scripts/gh/fields.sh`, and labels for the rest. A pull request declares
`Closes #N` and arms auto-merge the moment it opens:

```sh
gh pr create … && gh pr merge <n> --auto --squash --delete-branch
```

Branch from `origin/HEAD` with a conventional type (`feat/`, `fix/`,
`chore/`, `docs/`, `ci/`, `content/`), never from a stale local `main`.

## IMPORTANT hard rules

- **Verify online, never from memory.** Every version pin, every action SHA,
  every tool checksum, every address the site publishes and every law article
  it cites is checked against the live source on the day it is written, and
  `docs/VERSIONS.md` records the date of that check.
- **Every `uses:` is pinned to a full commit SHA** with a trailing `# vX.Y.Z`
  comment, `permissions: {}` sits at workflow level, no `${{ }}` context is
  interpolated into a `run:` block, and `persist-credentials: false` is on
  every checkout (`.claude/rules/ci-cd.md`).
- **Jobs run on `ubuntu-latest`, and the private sibling's `self-hosted`
  labels are the one line not to copy from it** (owner ruling 2026-09-20).
  This repository is public, so GitHub's runners are free for it and are the
  standard for Pages. The sibling bought its own machines because it is
  private and was spending a billed minute allowance; that reasoning does not
  reach a public repository, and the organisation's three machines are a
  queue this site would sit in behind a codebase that merges dozens of times
  a day. Every other rule in the sibling's CI discipline applies here
  unchanged.
- **Prose follows `.claude/rules/writing-style.md`:** no em dashes, no
  "not X but Y", no decorative triads, and none of the banned words in either
  language. `scripts/checks/prose-style.sh` fails on any hit, per edit through
  the hook and in CI. A sentence a reader cannot verify does not belong on the
  site. A page addresses the reader as "u" and speaks about the client's
  problem and the work; the size of the company, the number of people or
  directors, the year of incorporation and the legal structure are never a
  selling point (owner ruling 2026-09-20).
- **No JavaScript.** The site ships none, authored or third party, and no
  page loads a resource from another origin. That is what makes the privacy
  page true.
- **Never add AI or Claude attribution** to a commit, pull request, issue,
  comment or file: no `Co-Authored-By`, no "Generated with", no bot trailer,
  no emoji marker. A `PreToolUse` hook blocks a command carrying one.
- **Never edit a file with a `sed -i` or `perl -0pi` regex.** Use an editor
  that matches an exact string and fails when the match is not unique.
- **Keep the changelog.** `CHANGELOG.md` is Dutch and follows Keep a
  Changelog 1.1.0; a change with a visible effect adds an entry under
  `[Unreleased]` in the same pull request.
- **Every first-party file carries the two SPDX lines**,
  `SPDX-FileCopyrightText: Vernum Projecten B.V.` and
  `SPDX-License-Identifier: Apache-2.0`. `scripts/checks/versions.sh` fails on
  any other claim. Vendored material keeps its upstream terms.
- **Run the guards before pushing.** `ci.yml` has no `pull_request` trigger
  and auto-merge lands a pull request within seconds, so the local run is the
  check the change gets before it is on `main`:

  ```sh
  scripts/checks/prose-style.sh --all
  scripts/checks/versions.sh
  scripts/checks/brand-contrast.sh
  scripts/checks/company-name.sh --all
  zola check
  actionlint && zizmor --min-severity=low .github/ && shellcheck --severity=style scripts/checks/*.sh
  ```

  CI runs `zola check --skip-external-links`, so an outside site that answers
  slowly cannot fail a build. Run it without that flag locally whenever you
  add or change a link.

## Licence

The code and the configuration are under the **Apache License 2.0**
(`LICENSE`, `NOTICE`). The copyright holder and licensor is
**Vernum Projecten B.V.** The texts and images of the site are the company's own,
"© Vernum Projecten B.V.", stated in the footer and in `README.md`. Inter
keeps the SIL Open Font License 1.1 recorded beside it.

## References

- Zola: <https://www.getzola.org/documentation/getting-started/overview/>
- Tera templates: <https://keats.github.io/tera/docs/>
- GitHub Pages with Actions:
  <https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site>
- WCAG 2.2: <https://www.w3.org/TR/WCAG22/>
- The law: <https://wetten.overheid.nl/BWBR0005291> (Burgerlijk Wetboek Boek 3),
  <https://wetten.overheid.nl/BWBR0021777> (Handelsregisterwet 2007)
- The tracker: `gh issue list --state open`
