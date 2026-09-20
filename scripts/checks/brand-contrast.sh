#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/checks/brand-contrast.sh: measure every token in
# sass/_huisstijl-tokens.scss against the two grounds and check the `safe:`
# claim its comment carries (docs/huisstijl.md).
#
#   scripts/checks/brand-contrast.sh          # check the claims, exit 1 on a miss
#   scripts/checks/brand-contrast.sh --table  # print the measured table (markdown)
#
# WCAG 2.2 asks 4.5:1 for body text and 3:1 for a graphical object or large
# text (https://www.w3.org/TR/WCAG22/#contrast-minimum and #non-text-contrast).
# A token safe as a graphic is not therefore safe as a label, so each claim
# names the use and the ground: text-on-light, text-on-dark, graphic-on-light,
# graphic-on-dark, ground-light, ground-dark, rule. The ratio is the WCAG
# formula over relative luminance, computed in awk because bash is the one
# tooling language here.
#
# The house style is the owner's and the palette is not this site's to change,
# so a failure here means a token was edited that should not have been. No
# specification governs the palette itself; it is the company's own design.

set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

readonly TOKENS=sass/_huisstijl-tokens.scss

light="$(awk -F'[:;]' '/--huisstijl-mist:/ { gsub(/ /, "", $2); print $2; exit }' "$TOKENS")"
dark="$(awk -F'[:;]' '/--huisstijl-inkt:/ { gsub(/ /, "", $2); print $2; exit }' "$TOKENS")"
[ -n "$light" ] && [ -n "$dark" ] || { echo "brand-contrast: $TOKENS names no --huisstijl-mist or --huisstijl-inkt" >&2; exit 1; }

# One "name<TAB>value<TAB>claims" line per token.
rows="$(awk '
  /--huisstijl-[a-z-]+:[[:space:]]*#/ {
    line = $0
    split(line, parts, ":")
    name = parts[1]; gsub(/[[:space:]]*--huisstijl-/, "", name); gsub(/[[:space:]]/, "", name)
    value = parts[2]; sub(/;.*/, "", value); gsub(/[[:space:]]/, "", value)
    claim = ""
    if (match(line, /safe:[^*]*/)) {
      claim = substr(line, RSTART + 5, RLENGTH - 5)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", claim)
    }
    print name "\t" value "\t" claim
  }
' "$TOKENS")"

ratio() {
  awk -v a="$1" -v b="$2" '
    function hexval(pair,   digits, i, c, v) {
      digits = "0123456789abcdef"; v = 0
      for (i = 1; i <= length(pair); i++) { c = tolower(substr(pair, i, 1)); v = v * 16 + index(digits, c) - 1 }
      return v
    }
    function chan(v,   s) { s = v / 255; return (s <= 0.03928) ? s / 12.92 : ((s + 0.055) / 1.055) ^ 2.4 }
    function lum(hex) {
      return 0.2126 * chan(hexval(substr(hex, 2, 2))) + 0.7152 * chan(hexval(substr(hex, 4, 2))) + 0.0722 * chan(hexval(substr(hex, 6, 2)))
    }
    BEGIN {
      la = lum(a); lb = lum(b)
      hi = (la > lb) ? la : lb; lo = (la > lb) ? lb : la
      printf "%.2f", (hi + 0.05) / (lo + 0.05)
    }'
}

table=0
[ "${1:-}" = "--table" ] && table=1
fail=0
[ "$table" -eq 1 ] && printf '| Token | Hex | Op mist | Op inkt | Veilig voor |\n| --- | --- | --- | --- | --- |\n'
while IFS=$'\t' read -r name value claim; do
  [ -n "$name" ] || continue
  on_light="$(ratio "$value" "$light")"
  on_dark="$(ratio "$value" "$dark")"
  if [ "$table" -eq 1 ]; then
    # shellcheck disable=SC2016 # the backticks are markdown, not command substitution
    printf '| `%s` | `%s` | %s | %s | %s |\n' "$name" "$value" "$on_light" "$on_dark" "$claim"
    continue
  fi
  [ -n "$claim" ] || { echo "brand-contrast: --huisstijl-$name carries no safe: claim" >&2; fail=1; continue; }
  for use in $claim; do
    case "$use" in
      text-on-light)    need=4.5; got="$on_light" ;;
      text-on-dark)     need=4.5; got="$on_dark" ;;
      graphic-on-light) need=3;   got="$on_light" ;;
      graphic-on-dark)  need=3;   got="$on_dark" ;;
      ground-light|ground-dark|rule) continue ;;
      *) echo "brand-contrast: --huisstijl-$name claims unknown use '$use'" >&2; fail=1; continue ;;
    esac
    if awk -v g="$got" -v n="$need" 'BEGIN { exit !(g + 0 < n + 0) }'; then
      echo "brand-contrast: --huisstijl-$name ($value) claims $use but measures $got:1 (needs $need:1)" >&2
      fail=1
    fi
  done
done <<< "$rows"

if [ "$table" -eq 0 ]; then
  [ "$fail" -eq 0 ] && echo "brand-contrast: OK, every safe: claim in $TOKENS holds against $light and $dark"
fi
exit "$fail"
