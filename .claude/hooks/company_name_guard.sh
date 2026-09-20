#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# .claude/hooks/company_name_guard.sh
#
# Claude Code PostToolUse hook (matcher: Write|Edit).
#
# Runs the company-name guard (CLAUDE.md, "The site is Vernum Projecten B.V.
# alone") over the edited file. Exit 2 blocks the edit and feeds the findings
# back, so neither banned word the guard derives ever reaches a commit: the
# first word of the company name standing alone, and the word that would name
# a second company.

set -uo pipefail

payload="$(cat)" || true

if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true
else
  file_path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

[ -n "${file_path:-}" ] && [ -f "$file_path" ] || exit 0

repo_root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
[ -x "$repo_root/scripts/checks/company-name.sh" ] || exit 0

findings="$("$repo_root/scripts/checks/company-name.sh" --files "$file_path" 2>&1)" || {
  printf '%s\n' "$findings" >&2
  exit 2
}
exit 0
