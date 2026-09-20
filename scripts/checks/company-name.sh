#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# Company-name guard: this site is Vernum Projecten B.V. and nothing else.
#
# Two rules, both owner rulings, in one pass over the content and the path of
# every tracked file:
#
#   1. A company is named in full (2026-09-18). "Vernum Projecten" or
#      "Vernum Projecten B.V."; the first word alone names no company, so the
#      shared house style lives under the "huisstijl" namespace instead.
#   2. No second company (2026-09-20). The site is this one company, so the
#      word that names a company form the sibling company carries appears
#      nowhere, on a page or in a file.
#
# How it works on BSD as well as GNU: grep -P is absent on macOS, so there is
# no Perl negative lookahead here. strip() deletes every legitimate spelling
# from the text and the search runs on what is left. sed deletes text without
# deleting lines, so the line numbers grep reports are the file's own. Neither
# banned word is written as a literal; each is derived, which is why this file
# passes its own check.
#
# Two files are exempt, because they are the ones that state the rule:
# CLAUDE.md and this script. Everything else is read, including the vendored
# font tree's own paths.
#
# Usage:
#   scripts/checks/company-name.sh --all            # every tracked file
#   scripts/checks/company-name.sh --files <f>...   # named files (hook)
#   scripts/checks/company-name.sh --self-test      # prove the guard catches
#
# Exit 0 = clean, 1 = hits (listed as file:line: text), 2 = usage.

set -euo pipefail

cd "$(dirname "$0")/../.."

COMPANY="Vernum Projecten"
WORD="${COMPANY%% *}"
# The second banned word, spelled out of its parts so the literal is absent.
OTHER="$(printf 'hold%s' 'ing')"

EXEMPT_RE='^(CLAUDE\.md|scripts/checks/company-name\.sh)$'

# Every legitimate spelling, longest first, so a short form never eats the
# head of a long one.
strip() {
  sed \
    -e 's/VERNUM_PROJECTEN//g' \
    -e 's/VERNUM-PROJECTEN//g' \
    -e 's/Vernum Projecten//g' \
    -e 's/Vernum-Projecten//g' \
    -e 's/vernum-projecten//g' \
    -e 's/vernum_projecten//g' \
    -e 's/VERNUMPROJECTEN//g' \
    -e 's/Vernumprojecten//g' \
    -e 's/vernumprojecten//g'
}

in_scope() {
  [[ "$1" =~ $EXEMPT_RE ]] && return 1
  return 0
}

hits_in() {
  # Reads a stream on stdin, prints "line:text" for every banned hit.
  strip | grep -nIi -e "$WORD" -e "$OTHER" || true
}

if [[ "${1:-}" == "--self-test" ]]; then
  clean="$COMPANY B.V. publishes vernumprojecten.nl."
  if [[ -n "$(printf '%s\n' "$clean" | hits_in)" ]]; then
    echo "company-name: self-test failed: a line naming the company in full was reported." >&2
    exit 1
  fi
  for dirty in "the token is --${WORD}-ink" "a second company, a ${OTHER}"; do
    if [[ -z "$(printf '%s\n' "$dirty" | hits_in)" ]]; then
      echo "company-name: self-test failed: '$dirty' slipped through." >&2
      exit 1
    fi
  done
  echo "company-name: self-test OK."
  exit 0
fi

files=()
case "${1:---all}" in
--all)
  while IFS= read -r f; do
    [[ -e "$f" ]] && in_scope "$f" && files+=("$f")
  done < <(git ls-files)
  ;;
--files)
  shift
  for f in "$@"; do
    rel="${f#"$PWD"/}"
    [[ -e "$rel" ]] && in_scope "$rel" && files+=("$rel")
  done
  ;;
*)
  echo "usage: $0 [--all | --files <f>... | --self-test]" >&2
  exit 2
  ;;
esac

if [[ ${#files[@]} -eq 0 ]]; then
  echo "company-name: no files to check"
  exit 0
fi

fail=0
for f in "${files[@]}"; do
  if [[ -n "$(printf '%s\n' "$f" | hits_in)" ]]; then
    echo "$f:0: the path carries a banned company word"
    fail=1
  fi
  # grep -I reports nothing for a binary file, so this also skips the PNGs
  # and the favicon before sed ever reads them.
  grep -qIi -e "$WORD" -e "$OTHER" -- "$f" || continue
  while IFS= read -r hit; do
    echo "$f:$hit"
    fail=1
  done < <(hits_in <"$f")
done

if [[ "$fail" -ne 0 ]]; then
  echo "company-name: name the company in full ($COMPANY), use the huisstijl namespace, and name no second company." >&2
  exit 1
fi
echo "company-name: OK (${#files[@]} files)."
