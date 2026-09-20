---
paths:
  - ".github/**"
  - "scripts/**"
---

<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# CI/CD and supply-chain discipline

No specification governs this: our own design, grounded in the OWASP GitHub
Actions Security Cheat Sheet and GitHub's own hardening guide. The repository
is public, so every workflow here is readable by anyone and a mistake in one
is exploitable by anyone. The rules below are the same ones the sibling
repository runs under, with the Rust half removed and the Pages half added.

## What runs

Two workflows and nothing else:

- `.github/workflows/ci.yml`: one `guards` job on `ubuntu-latest`. zizmor over `.github/`,
  actionlint over the workflows, shellcheck over every tracked shell program,
  then the committed guards as successive named steps: `prose-style`,
  `versions`, `brand-contrast`, `company-name`, and `zola check` over the
  site. Every step carries a `name:` and `if: ${{ !cancelled() }}`, so one run
  reports every failing check.
- `.github/workflows/pages.yml`: build and publish. On a push to `main` it
  installs Zola from its GitHub release tarball, pinned by version and by
  sha256, runs `zola build`, uploads the output as a Pages artifact and
  deploys it. The deploy job is the only place `pages: write` and
  `id-token: write` are granted.

There is no `pull_request` trigger on either. Every pull request arms
auto-merge the moment it opens and merges within seconds, so a pull-request
run would duplicate the push run over the same commit. The evidence for a
change is the whole guard set run locally with the exact flags before the
push, plus the `main` run watched afterwards.

## Where a job runs

**Every job of every workflow runs on `ubuntu-latest`, GitHub's own runners**
(owner ruling 2026-09-20). This repository is public, so those runners are
free for it and carry no minute budget to spend.

**The private sibling repository runs on the organisation's own machines, and
that difference is deliberate.** There the repository is private, every
minute is billed, and two days of merges spent most of a 2,000-minute
allowance, which is what bought three Hetzner boxes. None of that reasoning
reaches a public repository: the bill is zero either way, and the
organisation's runners are a queue this site would sit in behind a codebase
that merges dozens of times a day. Hosted runners also start cold and clean,
which is what a lane that publishes to the open internet should want.

So when you read the sibling's CI rules, the `self-hosted` labels are the one
line not to copy. Everything else in them applies here unchanged.

Two consequences follow from the runner being a fresh image each time:

- **A tool the image carries is still pinned and installed.** The image ships
  its own shellcheck, and which one moves when the image is rebuilt, so
  `ci.yml` installs the pinned version over it through the SHA-pinned
  installer and then asserts that the version on `PATH` is that one. A
  finding in CI has to be reproducible by the same version locally.
- **Zola is unpacked into `$RUNNER_TEMP` and called by its path.** It is
  never installed into a system directory, even though a hosted runner would
  allow it, and it never arrives through a third-party action.

## Workflow security (every workflow, no exceptions)

- **Every `uses:` is pinned to a full commit SHA** with a trailing `# vX.Y.Z`
  comment. Dependabot (`github-actions`) bumps them. A tag or branch ref is a
  finding.
- **`permissions: {}` at workflow level**, with the minimum granted per job.
  `pages: write` and `id-token: write` live on the deploy job alone.
- **`persist-credentials: false`** on every `actions/checkout`.
- **No `${{ }}` context interpolation inside `run:`**: pass context through
  `env:`. This prevents template injection.
- **No lane logic in a `run:` block.** A `run:` block holds one command, or a
  fetch and one command. Anything with a branch belongs in a program under
  `scripts/`.
- **A downloaded tool is verified before it runs.** The Zola tarball is
  fetched by its release URL and checked against the sha256 in
  `docs/VERSIONS.md` before it is unpacked, with `sha256sum -c` deciding, so
  a replaced asset stops the run instead of building the site.

**Enforcement:** the `guards` job runs `zizmor --min-severity=low .github/`,
`actionlint`, and `shellcheck --severity=style` on every push to `main`. Run
the same three by hand before pushing a workflow or script change: with no
pull-request run, the local run is the only check the change gets before it
lands. The zizmor path is the whole of `.github`, so `dependabot.yml` is
audited alongside the workflows. Never narrow it to make a finding disappear:
fix the cause, or record a `# zizmor: ignore[audit]` suppression with its
reason on the line the finding names.

`.github/actionlint.yaml` declares no custom runner label, and it should stay
that way: actionlint then knows every label this repository uses, so a typo
in a `runs-on:` is a finding instead of a label somebody once declared.

## Shell scripts are analysed like code

Every committed shell script stays clean at `shellcheck --severity=style`, its
lowest floor, so every finding gates. A finding is fixed, or it carries a
per-line `# shellcheck disable=SCnnnn` directive with its reason on the same
line. A blanket exclusion is refused, and no `.shellcheckrc` exists, because a
file that can turn a code off tree-wide eventually does.

## Publishing

GitHub Pages is configured with the source "GitHub Actions", so the site is
whatever `pages.yml` deployed and no branch serves content by itself. The
custom domain is set on the repository and `static/CNAME` carries the same
name, because GitHub reads the file out of the artifact and a mismatch
unsets the setting on the next deploy
(<https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site>).
HTTPS enforcement is on once the certificate is issued.

A deploy is not a release. There are no tags, no binaries and no registry in
this repository; the published site is the head of `main`, and the way back
from a bad page is the next commit.

## Never

- Never unpin a `uses:` to a tag or branch, widen a job's permissions without
  cause, interpolate context into `run:`, or run a downloaded binary before
  its checksum is verified.
- Never weaken a gate to go green; fix the cause.
- **Never add AI or Claude attribution** to any commit, pull request, issue or
  comment.

## Official documentation (durable citations)

- OWASP GitHub Actions Security Cheat Sheet:
  <https://cheatsheetseries.owasp.org/cheatsheets/GitHub_Actions_Security_Cheat_Sheet.html>
- GitHub Actions security hardening:
  <https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions>
- Publishing with a custom GitHub Actions workflow:
  <https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site>
- zizmor: <https://docs.zizmor.sh/>
- actionlint: <https://github.com/rhysd/actionlint>
