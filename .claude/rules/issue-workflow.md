<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Issue workflow (the tracker loop)

**The tracker is GitHub Issues: the open issue list is the worklist.** Issue
state is edited only through `gh`; never track work in chat alone. Issue and
pull-request text is English (`writing-style.md` §Which language); the site
content the issue describes is Dutch.

## The loop

1. **Orient.** `gh issue list --state open`. Read the contract with the
   `--json` form below, never with the plain `gh issue view`: on gh 2.101.0
   that prints the header fields and stops before the body, and
   `--comments` prints nothing and exits 0, so the contract comes back empty
   and nothing says so.

   ```sh
   gh issue view <n> --json title,body,comments \
     --jq '.title, .body, (.comments[] | "--- comment ---", .body)'
   ```
2. **Read the contract.** The body opens with a plain summary, then an
   `## Acceptance criteria` checklist. New work found en route gets its own
   issue, never a prose "see also".
3. **Do the work.** A page's wording is the owner's to settle. Where a fact on
   the site is the owner's (an address, an e-mail address, a number from the
   Handelsregister), the issue carries the owner's answer before the page
   carries the fact. The site never states a company fact nobody confirmed.
4. **Record progress on the issue.** Tick verified acceptance criteria with
   `gh issue edit <n>`, and post decisions as comments. The issue thread is
   the durable record.
5. **Commit on a conventional-type branch** with a descriptive subject; the
   pull-request body declares `Closes #<n>` so the merge auto-closes the
   issue. One `Closes` keyword closes one issue, so repeat the keyword per
   issue.

## Pull requests merge themselves

```sh
gh pr create … && gh pr merge <n> --auto --squash --delete-branch
```

The repository has auto-merge and delete-branch-on-merge on, and `ci.yml` has
no `pull_request` trigger, so `--auto` merges at once. It can lose a race with
GitHub working out whether the branch is mergeable, and then answers
"Protected branch rules not configured for this branch" without queueing
anything; run it again, or merge with
`gh pr merge <n> --squash --delete-branch`. Every guard runs locally with the
exact CI flags before the push, and the `main` run is watched afterwards and
fixed forward if red. Cut every branch from the remote head
(`git fetch origin && git checkout -b <type>/<slug> origin/HEAD`), never from
a local `main` that may be behind.

## Type, priority and labels

The `Vernum-Projecten` organisation carries native issue types (Bug, Feature,
Task) and a native Priority field (Urgent, High, Medium, Low). Neither has a
`gh issue` subcommand, so both go through `scripts/gh/fields.sh`, which
resolves every node id from a name:

```sh
scripts/gh/fields.sh type     <n> <bug|feature|task>
scripts/gh/fields.sh priority <n> <urgent|high|medium|low>
scripts/gh/fields.sh show     <n>
scripts/gh/fields.sh new <type> <priority> [effort] <gh issue create args…>
```

Labels carry the rest, and the set is small on purpose: `documentation`,
`chore`, `ci`, `content` (the words on a page), `design` (the look of one),
`dependencies`, `no-changelog`.

## Milestones are releases

**Every issue carries a milestone, with no exception.** A milestone is
described by what it carries, never by a phase and never by a season:

| Milestone | What it carries |
| --- | --- |
| `v0.1.0` | the site live on the custom domain, with the five pages and the 404 |
| `v0.2.0` | what the owner confirms after reading the live site |

A milestone is cut when it reaches zero open issues, or when the owner calls
the cut. Work that waits on somebody else (an address to confirm, DNS at the
registrar) never holds a release: it carries the milestone it is most likely
to be answerable in and moves forward with every cut.

## The fix-first cadence

**An issue filed while working a unit is fixed before the next unit starts.**
Filing the issue is the record, never permission to move on. Tractable
findings are fixed in the same branch; separable work becomes a linked issue
that is closed before the current program advances. The exception is a fact
only the owner can give: that waits on the owner and says on the issue what it
waits for.

## Branches use conventional types

`<type>/<kebab-case-slug>` with `type` in `feat`, `fix`, `chore`, `docs`,
`refactor`, `perf`, `test`, `ci`, `build`, `release`. Pick the type by the
dominant change. Never force-push `main`.

## Never add AI or Claude attribution

Commit messages, pull-request text, issue and comment bodies describe only the
change itself: no `Co-Authored-By`, no "Generated with", no bot trailer, no
emoji marker. The `no_attribution_guard.sh` hook blocks a command that carries
one.
