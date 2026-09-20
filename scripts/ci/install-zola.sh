#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/ci/install-zola.sh: fetch the pinned Zola release, refuse it if the
# checksum differs, and unpack it.
#
# This is a program rather than three lines in a `run:` block, because the
# checksum comparison is a branch and a lane that branches is measured here
# on every push instead of for the first time against a live deploy
# (.claude/rules/ci-cd.md, "Workflow security").
#
# Nothing is installed into a system directory, even where the runner would
# allow it. The binary lands in the directory you name and the caller runs it
# by its path, so a run leaves the machine as it found it.
#
# The version and the checksum come from the environment, so the workflow
# holds the pin and scripts/checks/versions.sh measures it against
# docs/VERSIONS.md. Neither is defaulted here: a missing pin is a refusal, not
# a silent fallback to whatever is newest.
#
# Usage:
#   ZOLA_VERSION=0.23.6 ZOLA_SHA256=<sha256> scripts/ci/install-zola.sh <dir>
#   scripts/ci/install-zola.sh --self-test    # prove the refusal, no network
#
# Prints the absolute path of the unpacked binary on success.
#
# Exit 0 = the binary is in place, 1 = a refusal, 2 = usage.

set -euo pipefail

die() {
  echo "install-zola: $*" >&2
  exit 1
}

# Measures FILE against WANT and refuses on a difference. Split out because it
# is the one branch that decides whether a downloaded binary may run, and the
# self-test below exercises it without touching the network.
verify_sha256() {
  local file="$1" want="$2" got
  [ -f "$file" ] || die "no file at $file to verify"
  if command -v sha256sum >/dev/null 2>&1; then
    got="$(sha256sum "$file" | cut -d' ' -f1)"
  elif command -v shasum >/dev/null 2>&1; then
    got="$(shasum -a 256 "$file" | cut -d' ' -f1)"
  else
    die "neither sha256sum nor shasum is available, so nothing can be verified"
  fi
  if [ "$got" != "$want" ]; then
    echo "install-zola: REFUSED $file" >&2
    echo "  expected $want" >&2
    echo "  measured $got" >&2
    return 1
  fi
  return 0
}

if [ "${1:-}" = "--self-test" ]; then
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064 # the path is expanded now on purpose, so the trap cannot lose it
  trap "rm -rf '$tmp'" EXIT
  # The empty file, whose sha256 is a published constant. Comparing against a
  # constant rather than against a sum this script measured itself is what
  # makes the passing half of the self-test mean something.
  : >"$tmp/probe"
  good="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  if ! verify_sha256 "$tmp/probe" "$good" >/dev/null 2>&1; then
    echo "install-zola: self-test failed: a matching checksum was refused." >&2
    exit 1
  fi
  if verify_sha256 "$tmp/probe" "0000000000000000000000000000000000000000000000000000000000000000" >/dev/null 2>&1; then
    echo "install-zola: self-test failed: a wrong checksum was accepted." >&2
    exit 1
  fi
  echo "install-zola: self-test OK."
  exit 0
fi

dest="${1:-}"
[ -n "$dest" ] || {
  echo "usage: ZOLA_VERSION=<x.y.z> ZOLA_SHA256=<sha256> $0 <dir>" >&2
  echo "       $0 --self-test" >&2
  exit 2
}

version="${ZOLA_VERSION:-}"
sha="${ZOLA_SHA256:-}"
[ -n "$version" ] || die "ZOLA_VERSION is empty; the pin is docs/VERSIONS.md"
[ -n "$sha" ] || die "ZOLA_SHA256 is empty; the pin is docs/VERSIONS.md"
command -v curl >/dev/null 2>&1 || die "curl is not installed on this runner"

mkdir -p "$dest"
dest="$(cd "$dest" && pwd)"

# The musl build is statically linked, so it does not depend on the glibc of
# whatever image the runner happens to carry.
asset="zola-v${version}-x86_64-unknown-linux-musl.tar.gz"
url="https://github.com/getzola/zola/releases/download/v${version}/${asset}"

echo "install-zola: fetching ${url}"
curl -fsSL --retry 3 --retry-delay 2 -o "$dest/$asset" "$url" ||
  die "could not fetch $url"

if ! verify_sha256 "$dest/$asset" "$sha"; then
  # Nothing unverified is left on disk for a later step to stumble into.
  rm -f "$dest/$asset"
  die "the downloaded tarball is not the pinned release; it was deleted unopened"
fi

tar xzf "$dest/$asset" -C "$dest" || die "could not unpack $asset"
rm -f "$dest/$asset"
[ -x "$dest/zola" ] || die "the tarball carried no zola binary"

"$dest/zola" --version
printf '%s\n' "$dest/zola"
