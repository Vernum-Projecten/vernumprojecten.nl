#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# Prose-style guard (.claude/rules/writing-style.md, "Banned tells").
#
# Prose in this repository never reads like machine-generated text. This
# script makes the word-level half of that rule a failing check. It scans the
# first-party prose of the tree:
#
#   - every tracked *.md outside the rule file that lists the words. The
#     vendored font licence has no .md extension, so it is never read;
#   - every Tera template under templates/, where the Dutch a visitor reads
#     lives;
#   - config.toml, whose title and description reach the page;
#   - the comment lines (`#`) of the tracked shell programs and the comment
#     lines (`//` and `/* */`) of the Sass sources.
#
# Inside those files it skips fenced code blocks and quoted lines (`> …`),
# then fails on:
#
#   1. the em dash (U+2014) and the en dash used as clause glue (U+2013 with
#      spaces around it);
#   2. any word or phrase in the banned list below, English and Dutch,
#      matched case-insensitively on word boundaries.
#
# The list is the one in writing-style.md. Add to both places at once.
#
# Usage:
#   scripts/checks/prose-style.sh --all                 # whole tree
#   scripts/checks/prose-style.sh --diff <base> [head]  # changed files only
#   scripts/checks/prose-style.sh --files <f>...        # named files (hook)
#   scripts/checks/prose-style.sh --self-test           # prove it catches
#
# Exit 0 = clean, 1 = violations (file:line: message), 2 = usage.

set -euo pipefail

cd "$(dirname "$0")/../.."

# Files the guard never reads: the rule that lists the words, this script.
EXEMPT_RE='^(\.claude/rules/writing-style\.md|scripts/checks/prose-style\.sh)$'

in_scope() {
  local f="$1"
  [[ "$f" =~ $EXEMPT_RE ]] && return 1
  case "$f" in
  config.toml) return 0 ;;
  *.md | *.html | *.scss | *.sh) return 0 ;;
  esac
  return 1
}

mode="${1:---all}"

if [[ "$mode" == "--self-test" ]]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  printf 'Een zin met een cruciaal woord erin.\n' >"$tmp/dirty.md"
  printf 'Een zin met een em dash \xe2\x80\x94 erin.\n' >"$tmp/dash.md"
  printf 'Een gewone zin zonder verboden woorden.\n' >"$tmp/clean.md"
  fails=0
  for bad in dirty dash; do
    if "$0" --files "$tmp/$bad.md" >/dev/null 2>&1; then
      echo "prose-style: self-test failed: $bad.md was not reported" >&2
      fails=1
    fi
  done
  if ! "$0" --files "$tmp/clean.md" >/dev/null 2>&1; then
    echo "prose-style: self-test failed: clean.md was reported" >&2
    fails=1
  fi
  [[ $fails -eq 0 ]] || exit 1
  echo "prose-style: self-test OK."
  exit 0
fi

files=()
case "$mode" in
--all)
  while IFS= read -r f; do
    [[ -f "$f" ]] && in_scope "$f" && files+=("$f")
  done < <(git ls-files)
  ;;
--diff)
  base="${2:?usage: --diff <base> [head]}"
  head="${3:-HEAD}"
  while IFS= read -r f; do
    [[ -f "$f" ]] && in_scope "$f" && files+=("$f")
  done < <(git diff --name-only --diff-filter=ACMR "$base" "$head")
  ;;
--files)
  shift
  for f in "$@"; do
    rel="${f#"$PWD"/}"
    [[ -f "$rel" ]] && in_scope "$rel" && files+=("$rel")
  done
  ;;
*)
  echo "usage: $0 [--all | --diff <base> [head] | --files <f>... | --self-test]" >&2
  exit 2
  ;;
esac

if [[ ${#files[@]} -eq 0 ]]; then
  echo "prose-style: no files to check"
  exit 0
fi

# One alternation per language. Word boundaries are added by the matcher;
# a phrase may carry its own inflection group.
export BANNED_EN='delv(e|es|ed|ing)|underscor(es|ed|ing) (the|that|its|how|why|a|an)|pivotal|realms?|harness(es|ed|ing)?|illuminat(e|es|ed|ing)|that being said|at its core|to put it simply|simply put|(a )?key takeaways?|from a broader perspective|generally speaking|broadly speaking|typically|tends? to|arguably|to some extent|sheds? light on|shedding light on|facilitat(e|es|ed|ing)|refin(e|es|ed|ing)|bolster(s|ed|ing)?|differentiat(e|es|ed|ing)|streamlin(e|es|ed|ing)|revolutioni[sz](e|es|ed|ing)|innovative|cutting-edge|game-changing|transformative|seamless(ly)?|scalable solutions?|leverag(e|es|ed|ing)|robust(ly|ness)?|elevat(e|es|ed|ing)|testament to|landscape|tapestry|foster(s|ed|ing)?|empower(s|ed|ing|ment)?|unlock(s|ed|ing)?|holistic(ally)?|synerg(y|ies|istic)|state-of-the-art|journey|it is worth noting|it'\''s worth noting|in today'\''s|at the end of the day|imagine a world|in conclusion'
export BANNED_NL='duik(en|t)? in|dook in|gedoken in|onderstre(ept|pen)|cruciaal|cruciale|sleutelrol|naadlo(os|ze)|robuust(e)?|krachtig(e)?|faciliteer(t|de)?|faciliteren|in kaart (brengen|gebracht|brengt)|stroomlijn(en|t|de)?|gestroomlijnd(e)?|innovatie(f|ve)|baanbrekend(e)?|revolutionair(e)?|transformatie(f|ve)|dat gezegd hebbende|in de kern|simpel gezegd|kort gezegd|eenvoudig gezegd|over het algemeen|doorgaans|in zekere mate|tot op zekere hoogte|vanuit een breder perspectief|een belangrijke les|werpt licht op|licht werpen op|belicht(en)?|landschap|holistisch(e)?|synergie|schaalbare oplossing(en)?'

status=0
for f in "${files[@]}"; do
  out="$(perl -CSD -Mutf8 -ne '
    BEGIN { $en = $ENV{BANNED_EN}; $nl = $ENV{BANNED_NL}; die "empty word list" unless length $en && length $nl; }
    if ($. == 1) { $sh = ($ARGV =~ /\.sh$/); $css = ($ARGV =~ /\.scss$/); }
    if ($sh) {
      # Comment lines only: a command and a Dutch string are not prose.
      next unless /^\s*#\s?(.*)$/;
      $_ = $1;
      next if /^!/;
    } elsif ($css) {
      # Both Sass comment forms, the line form and one line of a block.
      next unless m{^\s*(?://+|/?\*+)\s?(.*?)\s*\*?/?\s*$};
      $_ = $1;
    } else {
      if (/^\s*(```|~~~)/) { $fence = !$fence; next; }
      next if $fence;
      next if /^\s*>/;
    }
    my @hits;
    push @hits, "em dash (U+2014): use a comma, colon, period or parentheses" if /\x{2014}/;
    push @hits, "en dash as clause glue (U+2013): use a comma or colon" if / \x{2013} /;
    while (/\b($en)\b/gi) { push @hits, "banned word or phrase: \"$1\""; }
    while (/\b($nl)\b/gi) { push @hits, "verboden woord of frase: \"$1\""; }
    print "$ARGV:$.: $_\n" for @hits;
  ' "$f" 2>&1)" || true
  if [[ -n "$out" ]]; then
    printf '%s\n' "$out"
    status=1
  fi
done

if [[ $status -eq 0 ]]; then
  echo "prose-style: OK (${#files[@]} files, no banned words, no em dashes)"
fi
exit $status
