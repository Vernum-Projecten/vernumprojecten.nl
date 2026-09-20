#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/vendor/icons.sh: vendor the Lucide icons the pages draw.
#
# The site draws six icons and no more: three on the service blocks, one on
# the contact action, one on the link that carries a page forward, and one on
# the menu button of a narrow screen. The upstream release carries thousands,
# so the whole set is not vendored; the TAKE list below is, and every name in
# it is referenced by a template.
#
# The version comes from the row `Lucide` in docs/VERSIONS.md, which
# scripts/checks/versions.sh measures against the PROVENANCE.md this script
# writes. The sha256 of the release zip and of the licence are pinned here: a
# download that differs is refused unopened.
#
# Usage:
#   scripts/vendor/icons.sh            # fetch, replace the tree, stamp it
#   scripts/vendor/icons.sh --verify   # no network: every file matches SHA256SUMS
#
# Re-running with an unchanged pin reproduces the tree byte for byte; only the
# fetch date in PROVENANCE.md moves. Requires curl, shasum, unzip.
#
# No specification governs this file; it is our own design, following the same
# shape as scripts/vendor/inter.sh.
#
# Exit 0 = the tree is in place, 1 = a refusal, 2 = usage.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

readonly VERSION="1.47.0"
readonly ZIP_URL="https://github.com/lucide-icons/lucide/releases/download/${VERSION}/lucide-icons-${VERSION}.zip"
readonly LICENCE_URL="https://raw.githubusercontent.com/lucide-icons/lucide/${VERSION}/LICENSE"
readonly ZIP_SHA256="84aa2931525f129cc3ed2530dd079feb8470b575d56d1fb4fa7404b185af058e"
readonly LICENCE_SHA256="b495047bd93a9b06913511076f504daba17d5bbeb3e0650f3bb53a4220329c57"
readonly DEST="static/icons/lucide"
readonly UA="vernumprojecten-vendor (scripts/vendor/icons.sh)"

# The icons taken from the zip, at their path inside it. Keep this list and
# the templates in step: an icon here that no template draws is dead weight.
readonly TAKE=(
  "icons/arrow-right.svg"
  "icons/code.svg"
  "icons/compass.svg"
  "icons/mail.svg"
  "icons/menu.svg"
  "icons/pencil-ruler.svg"
)

say() { echo "icons: $*"; }
die() {
  echo "icons: $*" >&2
  exit 1
}

sha256_of() { shasum -a 256 "$1" | cut -d' ' -f1; }

verify_sha256() {
  local file="$1" want="$2" got
  got="$(sha256_of "$file")"
  if [ "$got" != "$want" ]; then
    echo "icons: REFUSED $file" >&2
    echo "  expected $want" >&2
    echo "  measured $got" >&2
    return 1
  fi
  return 0
}

write_sums() {
  (
    cd "$DEST" || exit 1
    find . -type f ! -name PROVENANCE.md ! -name SHA256SUMS | LC_ALL=C sort |
      while IFS= read -r f; do shasum -a 256 "$f"; done
  ) >"$DEST/SHA256SUMS"
}

verify_tree() {
  [ -f "$DEST/SHA256SUMS" ] || die "$DEST/SHA256SUMS is missing; run the script without --verify first"
  (cd "$DEST" && shasum -a 256 -c SHA256SUMS) >/dev/null ||
    die "the vendored Lucide tree differs from SHA256SUMS"
  say "OK: every file in $DEST matches SHA256SUMS"
}

if [ "${1:-}" = "--verify" ]; then
  verify_tree
  exit 0
fi

if [ $# -gt 0 ]; then
  echo "usage: $0 [--verify]" >&2
  exit 2
fi

for tool in curl shasum unzip; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is not installed"
done

work="$(mktemp -d)"
# shellcheck disable=SC2064 # the path is expanded now on purpose, so the trap cannot lose it
trap "rm -rf '$work'" EXIT

say "fetching $ZIP_URL"
curl --proto '=https' --tlsv1.2 -fsSL -A "$UA" -o "$work/lucide.zip" "$ZIP_URL" ||
  die "could not fetch the release zip"
verify_sha256 "$work/lucide.zip" "$ZIP_SHA256" ||
  die "the release zip is not the pinned one; nothing was unpacked"

say "fetching $LICENCE_URL"
curl --proto '=https' --tlsv1.2 -fsSL -A "$UA" -o "$work/LICENSE" "$LICENCE_URL" ||
  die "could not fetch the licence"
verify_sha256 "$work/LICENSE" "$LICENCE_SHA256" ||
  die "the licence is not the pinned one"

unzip -q "$work/lucide.zip" -d "$work/zip" || die "could not unpack the release zip"

rm -rf "${DEST:?}"
mkdir -p "$DEST"
cp "$work/LICENSE" "$DEST/LICENSE"
for icon in "${TAKE[@]}"; do
  [ -f "$work/zip/$icon" ] || die "the release does not carry $icon"
  cp "$work/zip/$icon" "$DEST/$(basename "$icon")"
done

cat >"$DEST/PROVENANCE.md" <<PROV
<!-- SPDX-FileCopyrightText: Vernum Projecten B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Herkomst: de pictogrammen van Lucide

Deze pictogrammen zijn niet van ons. Ze komen byte voor byte uit de releasezip
die het Lucide-project op GitHub publiceert. Alleen wat de sjablonen tekenen
staat hier; de rest van de set is niet overgenomen.

Dit bestand is geschreven door \`scripts/vendor/icons.sh\`. Wijzig het niet met
de hand: pas het script aan en draai het opnieuw.

## Pin

| Onderdeel | Waarde |
| --- | --- |
| Versie | Lucide $VERSION (de rij \`Lucide\` in \`docs/VERSIONS.md\`) |
| Release | <https://github.com/lucide-icons/lucide/releases/tag/$VERSION> |
| Zip | \`$ZIP_URL\` |
| Sha256 van de zip | \`$ZIP_SHA256\` |
| Sha256 van de licentie | \`$LICENCE_SHA256\` |
| Opgehaald op | $(date -u +%Y-%m-%d) |
| Bestanden | $(( ${#TAKE[@]} + 1 )) |

## Overgenomen bestanden

De sha256 van elk bestand staat in \`SHA256SUMS\` ernaast. Controleer de boom
zonder netwerk met:

\`\`\`sh
scripts/vendor/icons.sh --verify
\`\`\`

- \`LICENSE\`
$(for icon in "${TAKE[@]}"; do echo "- \`$(basename "$icon")\`"; done)

## Voorwaarden van de uitgever

Lucide staat onder de ISC-licentie; de tekst staat in \`LICENSE\` in deze map en
gaat met de bestanden mee, zoals die licentie vraagt. De sjablonen zetten de
pictogrammen ongewijzigd in de pagina, met \`currentColor\` als kleur.
PROV

write_sums
say "vendored ${#TAKE[@]} icons and the licence into $DEST"
verify_tree
