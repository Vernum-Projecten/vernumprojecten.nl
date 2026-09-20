#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
# scripts/gh/fields.sh: the issue type, the Priority and the Effort field, by
# issue number.
#
# WHY THIS EXISTS: since 2026-09-19 the type of an issue (Bug, Feature, Task)
# is GitHub's native issue type, its priority (Urgent, High, Medium, Low) is
# the organisation's Priority issue field and its effort (High, Medium, Low)
# the organisation's Effort issue field. None of the three has a `gh issue`
# subcommand: both are set through GraphQL mutations that take node ids for
# the issue, the type, the field and the option. This wrapper resolves every
# id from a name, so a call reads as the intent and fails loud on a typo.
#
# Official docs (durable references):
#   Issue types ......... https://docs.github.com/en/issues/tracking-your-work-with-issues/configuring-issues/managing-issue-types-in-an-organization
#   Issue fields ........ https://docs.github.com/en/issues/tracking-your-work-with-issues/configuring-issues/managing-issue-fields-in-an-organization
#   GraphQL mutations ... https://docs.github.com/en/graphql/reference/mutations
#                         (updateIssueIssueType, setIssueFieldValue)
#
# Policy: .claude/rules/issue-workflow.md §Type, priority and labels.
#
# Usage:
#   scripts/gh/fields.sh type     <n> <bug|feature|task>
#   scripts/gh/fields.sh priority <n> <urgent|high|medium|low>
#   scripts/gh/fields.sh effort   <n> <high|medium|low>
#   scripts/gh/fields.sh show     <n>
#   scripts/gh/fields.sh new <bug|feature|task> <urgent|high|medium|low> <high|medium|low> <gh issue create args...>
#       Creates the issue with `gh issue create` (pass --title, --body,
#       --milestone, --label as usual) and sets type, priority and effort on
#       it; prints the URL.

# shellcheck disable=SC2016 # every $o/$n/$i/$t/$f in a query is a GraphQL variable, and $w/$f/$fl in a jq filter is a jq binding
set -euo pipefail

die() {
  echo "gh-fields: $*" >&2
  exit 1
}

command -v gh >/dev/null 2>&1 || die "the GitHub CLI (gh) is not installed"
command -v jq >/dev/null 2>&1 || die "jq is not installed"

REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" ||
  die "could not resolve the current repository (run inside a gh-authenticated clone)"
OWNER="${REPO%%/*}"
NAME="${REPO##*/}"

usage() {
  sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

# Title-case the lower-case word the command line takes: bug -> Bug.
titled() {
  printf '%s%s' "$(printf '%s' "${1:0:1}" | tr '[:lower:]' '[:upper:]')" "${1:1}"
}

issue_id() {
  local id
  id="$(gh api graphql -f query='query($o:String!,$n:String!,$i:Int!){ repository(owner:$o,name:$n){ issue(number:$i){ id } } }' \
    -f o="$OWNER" -f n="$NAME" -F i="$1" --jq '.data.repository.issue.id' 2>/dev/null)" ||
    die "could not resolve issue #$1"
  [[ -n "$id" && "$id" != "null" ]] || die "no issue #$1 in $REPO"
  printf '%s' "$id"
}

type_id() {
  local want id
  want="$(titled "$1")"
  id="$(gh api graphql -f query='query($o:String!){ organization(login:$o){ issueTypes(first:20){ nodes{ id name isEnabled } } } }' \
    -f o="$OWNER" 2>/dev/null | jq -r --arg w "$want" '.data.organization.issueTypes.nodes[] | select(.name==$w and .isEnabled) | .id')" ||
    die "could not read the issue types of $OWNER"
  [[ -n "$id" ]] || die "$OWNER has no enabled issue type named '$want' (the set is Bug, Feature, Task)"
  printf '%s' "$id"
}

# Prints "<field id> <option id>" for the option named on the single-select
# field named: field_option Priority high -> "IFSS_... IFSSO_...".
field_option() {
  local field="$1" want out
  want="$(titled "$2")"
  out="$(gh api graphql -f query='query($o:String!){ organization(login:$o){ issueFields(first:20){ nodes{ ... on IssueFieldSingleSelect{ id name options{ id name } } } } } }' \
    -f o="$OWNER" 2>/dev/null | jq -r --arg fl "$field" --arg w "$want" '.data.organization.issueFields.nodes[] | select(.name==$fl) | .id as $f | .options[] | select(.name==$w) | "\($f) \(.id)"')" ||
    die "could not read the issue fields of $OWNER"
  [[ -n "$out" ]] || die "$OWNER has no $field option named '$want' (Priority: Urgent, High, Medium, Low; Effort: High, Medium, Low)"
  printf '%s' "$out"
}

set_type() {
  local n="$1" kind="$2" iid tid got
  iid="$(issue_id "$n")"
  tid="$(type_id "$kind")"
  got="$(gh api graphql -f query='mutation($i:ID!,$t:ID!){ updateIssueIssueType(input:{issueId:$i,issueTypeId:$t}){ issue{ issueType{ name } } } }' \
    -f i="$iid" -f t="$tid" --jq '.data.updateIssueIssueType.issue.issueType.name')" ||
    die "setting the type of #$n failed"
  echo "ok: #$n is a $got"
}

# set_field <n> <Priority|Effort> <option word>
set_field() {
  local n="$1" field="$2" level="$3" iid fid oid got
  iid="$(issue_id "$n")"
  read -r fid oid <<<"$(field_option "$field" "$level")"
  got="$(gh api graphql -f query='mutation($i:ID!,$f:ID!,$o:ID!){ setIssueFieldValue(input:{issueId:$i,issueFields:[{fieldId:$f,singleSelectOptionId:$o}]}){ issue{ issueFieldValues(first:10){ nodes{ ... on IssueFieldSingleSelectValue{ field{ ... on IssueFieldSingleSelect{ name } } value } } } } } }' \
    -f i="$iid" -f f="$fid" -f o="$oid" 2>/dev/null | jq -r --arg fl "$field" '[.data.setIssueFieldValue.issue.issueFieldValues.nodes[] | select(.field.name==$fl) | .value] | first')" ||
    die "setting the $field of #$n failed"
  [[ -n "$got" && "$got" != "null" ]] || die "setting the $field of #$n failed"
  echo "ok: #$n has $(printf '%s' "$field" | tr '[:upper:]' '[:lower:]') $got"
}

show() {
  local n="$1"
  gh api graphql -f query='query($o:String!,$n:String!,$i:Int!){ repository(owner:$o,name:$n){ issue(number:$i){ number title issueType{ name } issueFieldValues(first:10){ nodes{ ... on IssueFieldSingleSelectValue{ field{ ... on IssueFieldSingleSelect{ name } } value } } } labels(first:20){ nodes{ name } } milestone{ title } } } }' \
    -f o="$OWNER" -f n="$NAME" -F i="$n" \
    --jq '.data.repository.issue | "#\(.number)  \(.title)\n  type:      \(.issueType.name // "none")\n  priority:  \([.issueFieldValues.nodes[] | select(.field.name=="Priority") | .value] | first // "none")\n  effort:    \([.issueFieldValues.nodes[] | select(.field.name=="Effort") | .value] | first // "none")\n  labels:    \([.labels.nodes[].name] | join(", "))\n  milestone: \(.milestone.title // "none")"' ||
    die "could not read #$n"
}

new() {
  local kind="$1" level="$2" effort="$3" url n
  shift 3
  type_id "$kind" >/dev/null
  field_option Priority "$level" >/dev/null
  field_option Effort "$effort" >/dev/null
  url="$(gh issue create "$@")" || die "gh issue create failed"
  n="${url##*/}"
  set_type "$n" "$kind"
  set_field "$n" Priority "$level"
  set_field "$n" Effort "$effort"
  echo "$url"
}

cmd="${1:-}"
case "$cmd" in
  type)     [[ $# -eq 3 ]] || usage; set_type "$2" "$3" ;;
  priority) [[ $# -eq 3 ]] || usage; set_field "$2" Priority "$3" ;;
  effort)   [[ $# -eq 3 ]] || usage; set_field "$2" Effort "$3" ;;
  show)     [[ $# -eq 2 ]] || usage; show "$2" ;;
  new)      [[ $# -ge 5 ]] || usage; shift; new "$@" ;;
  *)        usage ;;
esac
