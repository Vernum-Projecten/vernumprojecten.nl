#!/bin/bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/intune/set-company-wallpaper.sh: install the Vernum Projecten
# wallpaper on a managed Mac.
#
# Intune runs this as a macOS shell script. It downloads the dark lock-screen
# background from the site, verifies it against the SHA256SUMS published next
# to it, and puts it where the Settings catalog profile points:
#
#   Desktop > Override Picture Path =
#     /Library/Desktop Pictures/Vernum Projecten/wallpaper.png
#
# macOS shows the desktop picture on the lock screen as well, so this one
# image serves both. When the installed file already matches, nothing changes
# and the Dock is left alone, so any Intune frequency is safe.
# scripts/checks/versions.sh fails when the image named below is missing from
# static/achtergronden/SHA256SUMS.
#
# Usage (Intune > Devices > macOS > Shell scripts):
#   Run script as signed-in user: No (the script runs as root)
#   Script frequency: any; a run without a new image changes nothing
#   Log: /Library/Logs/Microsoft/IntuneScripts/company-wallpaper.log

set -uo pipefail

BASE_URL="https://vernumprojecten.nl/achtergronden"
IMAGE_NAME="vernum-projecten-lockscreen-donker.png"
TARGET_DIR="/Library/Desktop Pictures/Vernum Projecten"
TARGET_FILE="$TARGET_DIR/wallpaper.png"
LOG="/Library/Logs/Microsoft/IntuneScripts/company-wallpaper.log"

mkdir -p "$TARGET_DIR" "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo "$(date) - starting wallpaper check ($IMAGE_NAME)"

fail() {
  echo "$(date) - ERROR: $1"
  exit 1
}

TMP_FILE="$(mktemp "$TARGET_DIR/.wallpaper.XXXXXX")" || fail "cannot create a temporary file"
trap 'rm -f "$TMP_FILE"' EXIT

sha256_of() {
  shasum -a 256 "$1" | awk '{print $1}'
}

# The expected hash comes from the site's own SHA256SUMS, so a new image
# needs no change to this script.
expected="$(curl -fsSL --retry 5 --retry-delay 10 "$BASE_URL/SHA256SUMS" |
  awk -v f="$IMAGE_NAME" '$2 == f { print $1 }')"
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || fail "no checksum for $IMAGE_NAME in SHA256SUMS"

if [[ -f "$TARGET_FILE" && "$(sha256_of "$TARGET_FILE")" == "$expected" ]]; then
  echo "$(date) - wallpaper is current, nothing to do"
  exit 0
fi

curl -fsSL --retry 5 --retry-delay 10 -o "$TMP_FILE" "$BASE_URL/$IMAGE_NAME" || fail "download failed"
actual="$(sha256_of "$TMP_FILE")"
[[ "$actual" == "$expected" ]] || fail "checksum mismatch (got $actual, want $expected)"

chmod 644 "$TMP_FILE"
chown root:wheel "$TMP_FILE"
mv -f "$TMP_FILE" "$TARGET_FILE" || fail "cannot move the wallpaper into place"
echo "$(date) - wallpaper installed at $TARGET_FILE"

# Restart the Dock for the signed-in user, so the new picture shows at once.
CURRENT_USER="$(stat -f%Su /dev/console)"
if [[ -n "$CURRENT_USER" && "$CURRENT_USER" != "root" && "$CURRENT_USER" != "_mbsetupuser" ]]; then
  killall Dock 2>/dev/null || true
fi
exit 0
