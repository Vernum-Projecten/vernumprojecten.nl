#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# Version-drift guard (docs/VERSIONS.md is the single source of truth).
#
# Every file that repeats a pin must agree with the matrix. A check whose
# subject file is absent skips loudly with a printed reason, so the guard is
# useful before a file lands and gains teeth the moment it appears.
#
#   1. site generator    the Zola version and the sha256 of its release
#                        tarball, as .github/workflows/pages.yml and
#                        .github/workflows/ci.yml pin them.
#   2. CI tool pins      the zizmor, actionlint and shellcheck versions
#                        .github/workflows/ci.yml uses.
#   3. the domain        config.toml base_url, static/CNAME and the matrix row
#                        all name the same host.
#   4. the typeface      assets/fonts/inter/PROVENANCE.md names the pin the
#                        matrix records.
#   5. licence           LICENSE is the Apache License 2.0 and no first-party
#                        file claims another licence.
#
# Usage:
#   scripts/checks/versions.sh
#
# Exit 0 = every present check agrees (skips are fine). Exit 1 = a real drift.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

fail=0
note() { printf '  %s\n' "$*"; }
bad() {
  printf '  DRIFT: %s\n' "$*" >&2
  fail=1
}

# The first whitespace-separated token of the second cell of the markdown
# table row whose first cell is ITEM, with spaces and backticks removed.
pin_of() {
  awk -F'|' -v item="$1" '
    NF >= 3 {
      k = $2; v = $3
      gsub(/`/, "", k); gsub(/`/, "", v)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      if (k == item) { split(v, w, /[[:space:]]/); print w[1]; exit }
    }
  ' "$2"
}

# The value of a `NAME: "value"` workflow environment entry.
wf_env() {
  sed -nE "s|^[[:space:]]*$1:[[:space:]]*\"?([^\"[:space:]]+)\"?.*|\1|p" "$2" | head -n1
}

if [ ! -f docs/VERSIONS.md ]; then
  echo "versions: no docs/VERSIONS.md yet, nothing to compare against" >&2
  exit 1
fi

echo "== site generator (.github/workflows/*.yml <-> docs/VERSIONS.md)"
want_zola="$(pin_of "Zola" docs/VERSIONS.md)"
want_sha="$(pin_of "Zola sha256" docs/VERSIONS.md)"
[ -n "$want_zola" ] || bad "docs/VERSIONS.md has no 'Zola' row"
[ -n "$want_sha" ] || bad "docs/VERSIONS.md has no 'Zola sha256' row"
for wf in .github/workflows/pages.yml .github/workflows/ci.yml; do
  if [ ! -f "$wf" ]; then
    note "no $wf yet, skipped"
    continue
  fi
  found_ver="$(wf_env ZOLA_VERSION "$wf")"
  found_sha="$(wf_env ZOLA_SHA256 "$wf")"
  if [ -z "$found_ver" ]; then
    bad "$wf pins no ZOLA_VERSION"
  elif [ -n "$want_zola" ] && [ "$found_ver" != "$want_zola" ]; then
    bad "Zola: $wf pins $found_ver, docs/VERSIONS.md pins $want_zola"
  else
    note "OK: $wf builds with Zola $found_ver"
  fi
  if [ -z "$found_sha" ]; then
    bad "$wf pins no ZOLA_SHA256"
  elif [ -n "$want_sha" ] && [ "$found_sha" != "$want_sha" ]; then
    bad "Zola sha256: $wf pins $found_sha, docs/VERSIONS.md pins $want_sha"
  else
    note "OK: $wf verifies the tarball against ${found_sha:0:16}…"
  fi
done

echo "== CI tool pins (.github/workflows/ci.yml <-> docs/VERSIONS.md)"
if [ -f .github/workflows/ci.yml ]; then
  ci_tool_pin() {
    case "$1" in
    zizmor)
      sed -nE "s|^[[:space:]]*tool:[[:space:]]*$1@([^[:space:]]+).*|\1|p" \
        .github/workflows/ci.yml | head -n1
      ;;
    # The shell linter is the runner's own package, asserted rather than
    # installed, so its pin is a workflow environment variable
    # (.claude/rules/ci-cd.md, "Where a job runs").
    shellcheck)
      wf_env SHELLCHECK_VERSION .github/workflows/ci.yml
      ;;
    actionlint)
      sed -nE 's|^[[:space:]]*rhysd/actionlint:([^@[:space:]]+)@sha256:.*|\1|p' \
        .github/workflows/ci.yml | head -n1
      ;;
    esac
  }
  for tool in zizmor actionlint shellcheck; do
    want="$(pin_of "$tool" docs/VERSIONS.md)"
    found="$(ci_tool_pin "$tool")"
    if [ -z "$want" ]; then
      bad "docs/VERSIONS.md has no '$tool' row"
    elif [ -z "$found" ]; then
      bad ".github/workflows/ci.yml pins no $tool version"
    elif [ "$found" != "$want" ]; then
      bad "$tool: ci.yml pins $found, docs/VERSIONS.md pins $want"
    else
      note "OK: $tool $found"
    fi
  done
else
  note "no .github/workflows/ci.yml yet, skipped"
fi

echo "== the domain (config.toml, static/CNAME <-> docs/VERSIONS.md)"
want_host="$(pin_of "Domein" docs/VERSIONS.md)"
if [ -z "$want_host" ]; then
  bad "docs/VERSIONS.md has no 'Domein' row"
fi
if [ -f config.toml ]; then
  base="$(sed -nE 's|^[[:space:]]*base_url[[:space:]]*=[[:space:]]*"([^"]+)".*|\1|p' config.toml | head -n1)"
  host="${base#https://}"
  host="${host#http://}"
  host="${host%%/*}"
  if [ -z "$base" ]; then
    bad "config.toml has no base_url"
  elif [ -n "$want_host" ] && [ "$host" != "$want_host" ]; then
    bad "domain: config.toml serves $host, docs/VERSIONS.md pins $want_host"
  elif [ "${base#https://}" = "$base" ]; then
    bad "domain: base_url is not https ($base)"
  else
    note "OK: base_url is $base"
  fi
else
  note "no config.toml yet, skipped"
fi
if [ -f static/CNAME ]; then
  cname="$(tr -d '[:space:]' <static/CNAME)"
  if [ -n "$want_host" ] && [ "$cname" != "$want_host" ]; then
    bad "domain: static/CNAME says $cname, docs/VERSIONS.md pins $want_host"
  else
    note "OK: static/CNAME is $cname"
  fi
else
  note "no static/CNAME yet, skipped"
fi

echo "== the typeface (assets/fonts/inter/PROVENANCE.md <-> docs/VERSIONS.md)"
want_inter="$(pin_of "Inter" docs/VERSIONS.md)"
if [ -z "$want_inter" ]; then
  bad "docs/VERSIONS.md has no 'Inter' row"
elif [ ! -f assets/fonts/inter/PROVENANCE.md ]; then
  note "no assets/fonts/inter/PROVENANCE.md yet, skipped"
elif ! /usr/bin/grep -qF "$want_inter" assets/fonts/inter/PROVENANCE.md; then
  bad "assets/fonts/inter/PROVENANCE.md does not name the pin $want_inter"
else
  note "OK: Inter $want_inter"
fi

echo "== licence (LICENSE <-> SPDX headers)"
if [ -f LICENSE ]; then
  stale=0
  if ! grep -q "Apache License" LICENSE || ! grep -q "Version 2.0" LICENSE; then
    bad "LICENSE is not the Apache License 2.0"
    stale=1
  fi
  # Every first-party header names Apache-2.0. The SPDX tag is anchored to the
  # start of its line, after an optional comment marker, so a header claim is
  # caught while the same identifier quoted in prose is not. The vendored
  # typeface keeps its upstream terms and is excluded.
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    bad "licence claim other than Apache-2.0 at $hit"
    stale=1
  done < <(git grep -n -E '^[[:space:]]*([/#*]+|<!--)?[[:space:]]*SPDX-License-Identifier:' \
    -- ':!LICENSE' ':!scripts/checks/versions.sh' ':(glob,exclude)assets/fonts/**' \
    ':(glob,exclude)static/fonts/**' | grep -v 'SPDX-License-Identifier: Apache-2\.0' || true)
  [ "$stale" -eq 0 ] && note "OK: LICENSE is the Apache License 2.0 and every first-party file names Apache-2.0"
else
  note "no LICENSE yet, skipped"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "versions: DRIFT detected" >&2
  exit 1
fi
echo "versions: OK (every present check agrees)"
