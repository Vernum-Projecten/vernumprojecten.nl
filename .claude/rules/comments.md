<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Comments

Adapted from RFC 505 and RFC 1574, the Rust API comment conventions, which are
the sibling repository's authority
(<https://rust-lang.github.io/rfcs/0505-api-comment-conventions.html>,
<https://rust-lang.github.io/rfcs/1574-more-api-documentation-conventions.html>).
There is no Rust here; the files that carry comments are the shell scripts,
the stylesheet, the Tera templates, the workflows and `config.toml`. The
discipline is the same, because comments rot faster than anything else in a
repository.

Comments are English (`writing-style.md` §Which language), including the ones
inside a Dutch template. The string a visitor reads is Dutch; the note to the
next developer is English.

## The prime rule: a comment earns its lines

Code says what; a comment exists for what the code cannot show: a citation (a
law article, a WCAG success criterion, a GitHub docs page), the non-obvious
why, the constraint. Everything else has a durable home and goes there:

| Content | Home |
|---|---|
| Decisions and history | the pull-request description or the tracker issue |
| How the site is built and published | `README.md` and `CLAUDE.md` |
| What a pin is and where it is repeated | `docs/VERSIONS.md` |
| What changed and why it is correct | the pull request, never the file |

**No change-narration**: "previously…", "now correctly…", "before this
change…" is pull-request text. A comment describes the file as it is.

## Budgets

- `# NOTE:` or `{# NOTE: #}` is a citation plus **one** sentence, at most 3
  physical lines. The full reasoning lives on the issue.
- A plain comment run is at most 8 physical lines. Longer prose belongs in
  `README.md`, `CLAUDE.md` or `docs/`.
- A file header is the exception: a script or a workflow opens with the two
  SPDX lines and a short block saying what it does and how it is called. That
  block is the file's documentation, not a comment run.

## Annotation vocabulary (the only sanctioned markers)

- `# TODO(#NNNN): <what is missing>`, pending work, always with its tracker
  issue number. Deferred work is a TODO, never prose ("later", "for now",
  "in a next step").
- `# NOTE: <citation plus one sentence>`, a settled decision: the source
  citation, or the explicit flag "no specification governs this: our own
  design".
- No other marker form exists. `FIXME`, `HACK`, `XXX` and `WIP` do not appear.

## Per file type

- **Shell** (`scripts/**/*.sh`): `#` comments. Every script opens with the two
  SPDX lines, one line naming the file, a short block saying what it checks,
  and a `Usage:` block. `shellcheck` disables carry their reason on the same
  line.
- **Templates** (`templates/**/*.html`): `{# … #}`. A template comment is
  rare; a template is read as HTML and the structure should carry the meaning.
  Use one where a class name or an attribute needs a citation, for example a
  WCAG criterion or the reason an image is `aria-hidden`. A `{# … #}` comment
  is removed by Tera and never reaches the visitor, unlike `<!-- … -->`, which
  ships. Use the HTML form only when a reader of the page source is the
  intended audience, which is close to never.
- **Sass and CSS** (`sass/**`): `//` line comments, which Sass strips, over
  `/* … */`, which it keeps. The stylesheet's own header is the exception and
  is written as `/* … */` so the compiled file carries its SPDX lines.
- **Workflows and `config.toml`**: `#` comments, same budgets. A workflow step
  that does something surprising says why in one line above it.

## Enforcement

Review-enforced. `scripts/checks/prose-style.sh` reads the comment lines of
the shell scripts and the stylesheet for the banned word list and the em dash,
so the writing rules reach comments even though the budgets above are not
machine-checked.
