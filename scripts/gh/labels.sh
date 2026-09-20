#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/gh/labels.sh: the label set of this tracker, as a file.
#
# The type of an issue is GitHub's native issue type and its priority the
# organisation's Priority field, both set with scripts/gh/fields.sh. Labels
# carry what is left, and the set stays small on purpose: a label nobody
# filters on is a label nobody maintains
# (.claude/rules/issue-workflow.md §Type, priority and labels).
#
# The descriptions are Dutch, because they are read in the tracker beside
# Dutch issue titles about Dutch pages.
#
# Usage:
#   scripts/gh/labels.sh            # create or update every label below
#   scripts/gh/labels.sh --list     # print the set without touching GitHub
#
# Running it twice is safe: --force updates a label that already exists.

set -euo pipefail

# name|colour|description
LABELS="documentation|0075ca|Verbeteringen of aanvullingen in de documentatie
chore|fef2c0|Onderhoud aan de repository, zonder zichtbaar effect op de site
ci|1d76db|De workflows, de controles en de publicatielane
content|0e8a16|De woorden op een pagina
design|5319e7|Hoe een pagina eruitziet, binnen de huisstijl
accessibility|f143ab|Een drempel voor iemand met een beperking
dependencies|0366d6|Bumps van Dependabot
no-changelog|ededed|Geen regel in CHANGELOG.md nodig"

if [ "${1:-}" = "--list" ]; then
  printf '%s\n' "$LABELS" | awk -F'|' '{ printf "%-16s #%s  %s\n", $1, $2, $3 }'
  exit 0
fi

[ $# -eq 0 ] || {
  echo "usage: $0 [--list]" >&2
  exit 2
}

command -v gh >/dev/null 2>&1 || {
  echo "labels: the GitHub CLI (gh) is not installed" >&2
  exit 1
}

fail=0
while IFS='|' read -r name colour description; do
  [ -n "$name" ] || continue
  if gh label create "$name" --color "$colour" --description "$description" --force >/dev/null 2>&1; then
    echo "ok: $name"
  else
    echo "labels: could not create or update '$name'" >&2
    fail=1
  fi
done <<EOF
$LABELS
EOF

exit "$fail"
