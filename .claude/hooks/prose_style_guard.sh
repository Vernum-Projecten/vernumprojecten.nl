#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# .claude/hooks/prose_style_guard.sh
#
# Claude Code PostToolUse hook (matcher: Write|Edit).
#
# Runs the prose-style guard (.claude/rules/writing-style.md, "Banned tells")
# over the edited file: markdown, the Tera templates, config.toml and the
# comment lines of the shell scripts and the stylesheet. Exit 2 blocks the
# edit and feeds the findings back as a correction, so a banned word or an em
# dash never reaches a commit. A file outside the guard's scope is a quiet
# exit 0.

set -uo pipefail

payload="$(cat)" || true

if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true
else
  file_path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

[ -n "${file_path:-}" ] && [ -f "$file_path" ] || exit 0

repo_root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
[ -x "$repo_root/scripts/checks/prose-style.sh" ] || exit 0

findings="$("$repo_root/scripts/checks/prose-style.sh" --files "$file_path" 2>&1)" || {
  printf '%s\n' "$findings" >&2
  exit 2
}
exit 0
