#!/bin/bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/intune/set-teams-background.sh: offer the Vernum Projecten
# background in Microsoft Teams on a managed Mac.
#
# Teams has no organisation background without a Teams Premium licence, so
# this script puts the dark background in the user's own uploads folder of
# the current Teams app (com.microsoft.teams2). That client wants a UUID as
# the file name and a "<uuid>_thumb.png" beside it; the UUID below is fixed,
# so a second run overwrites the same pair and never adds a copy. The user
# still picks the background once in Teams, which lists it after a restart.
# scripts/checks/versions.sh fails when the image named below is missing from
# static/achtergronden/SHA256SUMS.
#
# Usage (Intune > Devices > macOS > Shell scripts):
#   Run script as signed-in user: Yes (the folder is in the user's home)
#   Script frequency: daily; a run before Teams has started once exits 1 and
#   the next run installs
#   Log: ~/Library/Logs/company-teams-background.log

set -uo pipefail

BASE_URL="https://vernumprojecten.nl/achtergronden"
IMAGE_NAME="vernum-projecten-teams-donker.png"
BACKGROUND_ID="1b279507-1343-4c9b-8145-26c252580285"
CONTAINER="$HOME/Library/Containers/com.microsoft.teams2/Data/Library"
UPLOADS="$CONTAINER/Application Support/Microsoft/MSTeams/Backgrounds/Uploads"
TARGET_FILE="$UPLOADS/$BACKGROUND_ID.png"
THUMB_FILE="$UPLOADS/${BACKGROUND_ID}_thumb.png"
LOG="$HOME/Library/Logs/company-teams-background.log"

mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo "$(date) - starting Teams background check ($IMAGE_NAME)"

fail() {
  echo "$(date) - ERROR: $1"
  exit 1
}

[[ "$(id -u)" -ne 0 ]] || fail "running as root; set 'Run script as signed-in user' to Yes"
[[ -d "/Applications/Microsoft Teams.app" ]] || fail "Microsoft Teams is not installed"
# macOS creates the container on the first start of Teams; creating it by
# hand could leave Teams with a container it did not make.
[[ -d "$CONTAINER" ]] || fail "Teams has not been started yet for $(id -un)"

sha256_of() {
  shasum -a 256 "$1" | awk '{print $1}'
}

expected="$(curl -fsSL --retry 5 --retry-delay 10 "$BASE_URL/SHA256SUMS" |
  awk -v f="$IMAGE_NAME" '$2 == f { print $1 }')"
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || fail "no checksum for $IMAGE_NAME in SHA256SUMS"

if [[ -f "$TARGET_FILE" && -f "$THUMB_FILE" && "$(sha256_of "$TARGET_FILE")" == "$expected" ]]; then
  echo "$(date) - Teams background is current, nothing to do"
  exit 0
fi

mkdir -p "$UPLOADS" || fail "cannot create $UPLOADS"
TMP_FILE="$(mktemp "$UPLOADS/.background.XXXXXX")" || fail "cannot create a temporary file"
TMP_THUMB="$TMP_FILE.thumb.png"
trap 'rm -f "$TMP_FILE" "$TMP_THUMB"' EXIT

curl -fsSL --retry 5 --retry-delay 10 -o "$TMP_FILE" "$BASE_URL/$IMAGE_NAME" || fail "download failed"
actual="$(sha256_of "$TMP_FILE")"
[[ "$actual" == "$expected" ]] || fail "checksum mismatch (got $actual, want $expected)"

# The thumbnail keeps the 16:9 shape of the background.
sips -z 225 400 "$TMP_FILE" --out "$TMP_THUMB" >/dev/null || fail "cannot make the thumbnail"

chmod 644 "$TMP_FILE" "$TMP_THUMB"
mv -f "$TMP_THUMB" "$THUMB_FILE" || fail "cannot move the thumbnail into place"
mv -f "$TMP_FILE" "$TARGET_FILE" || fail "cannot move the background into place"
echo "$(date) - Teams background installed at $TARGET_FILE; Teams lists it after a restart"
exit 0
