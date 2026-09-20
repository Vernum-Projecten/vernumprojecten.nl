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

- `.github/workflows/ci.yml`: one `guards` job. zizmor over `.github/`,
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

**Every job of every workflow runs on the organisation's own runners.** The
labels are `self-hosted, linux, x64, hetzner`; the runners are registered at
the `Vernum-Projecten` organisation from `Vernum-Projecten/hetzner-runners`
and serve the whole organisation. Three machines on Ubuntu 26.04, one job at
a time each.

**The runner account has no sudo, so a workflow installs nothing that needs
it.** Two consequences here:

- `shellcheck` is asserted, never installed: the runner carries it, the pin
  lives in the `SHELLCHECK_VERSION` variable of `ci.yml`, and the job checks
  `shellcheck --version` against it.
- Zola is unpacked into `$RUNNER_TEMP` and called by its path. It is never
  installed into a system directory, and it never arrives through a
  third-party action.

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

zizmor's `self-hosted-runner` audit names every `runs-on:` of this
repository. It is a pedantic-tier audit, so `--min-severity=low` does not
report it, and the reasoning that accepts it is the section above.

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
