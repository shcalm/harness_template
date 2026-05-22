#!/usr/bin/env bash
# Cross-document ID consistency check.
#   Every ID that appears in any project document must also appear in its
#   owner document; otherwise it is a dangling reference.
#   The Brainstorm Phase (PRD.md §1 project name is still a placeholder)
#   skips this check.
#   The "Minimal Example" sections (§9 / §11) are stripped from both the
#   definition and reference scans.
#
# When adding a new ID prefix, sync two places:
#   1. AGENTS.md §3 "Unified ID Scheme" table
#   2. ID_PATTERN and owner_of below
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")/.."

# Governed ID prefixes + three-digit number + optional sub-level (TASK only).
ID_PATTERN='(REQ|AC|FLOW|CON|NOGOAL|Q|DEC|INV|CONTRACT|OBS|BUG|DEBT|TASK|TEST)-[0-9]{3}(\.[0-9]+)?'

# Ownership: prefix -> owner file
owner_of() {
  case "$1" in
    REQ|AC|FLOW|CON|NOGOAL|Q) echo PRD.md ;;
    DEC|INV|CONTRACT|OBS|BUG|DEBT) echo DESIGN.md ;;
    TASK) echo TASKS.md ;;
    TEST) echo TEST_REPORT.md ;;
    *) echo "" ;;
  esac
}

files=(PRD.md DESIGN.md TASKS.md TEST_REPORT.md)
for f in "${files[@]}"; do
  [[ -f "$f" ]] || { echo "missing required file: $f" >&2; exit 1; }
done

# Phase detection: project name still placeholder -> Brainstorm, skip.
if grep -qE '\[项目名称\]|\[Project Name\]' PRD.md; then
  echo "ID consistency: skipped (Brainstorm phase)"
  exit 0
fi

# Strip "Minimal Example" / "最小填写示例" sections, up to the next H2 or EOF.
strip_examples() {
  awk '
    BEGIN { skip = 0 }
    /^## +[0-9]+\. +.*(最小填写示例|Minimal Example)/ { skip = 1; next }
    /^## / { skip = 0 }
    !skip { print }
  ' "$1"
}

# Build per-file definition sets.
declare -A defined_in_PRD defined_in_DESIGN defined_in_TASKS defined_in_TEST
collect_defs() {
  local file="$1"
  declare -n map="$2"
  local id
  while IFS= read -r id; do
    map["$id"]=1
  done < <(strip_examples "$file" | grep -oE "$ID_PATTERN" | sort -u)
}
collect_defs PRD.md         defined_in_PRD
collect_defs DESIGN.md      defined_in_DESIGN
collect_defs TASKS.md       defined_in_TASKS
collect_defs TEST_REPORT.md defined_in_TEST

is_defined() {
  local id="$1" owner="$2"
  case "$owner" in
    PRD.md)         [[ -n "${defined_in_PRD[$id]:-}"   ]] ;;
    DESIGN.md)      [[ -n "${defined_in_DESIGN[$id]:-}" ]] ;;
    TASKS.md)       [[ -n "${defined_in_TASKS[$id]:-}"  ]] ;;
    TEST_REPORT.md) [[ -n "${defined_in_TEST[$id]:-}"   ]] ;;
    *) return 1 ;;
  esac
}

# Collect the union of all IDs that appear anywhere.
mapfile -t all_ids < <(
  for f in "${files[@]}"; do strip_examples "$f"; done \
    | grep -oE "$ID_PATTERN" | sort -u
)

errors=0
for id in "${all_ids[@]}"; do
  prefix="${id%%-*}"
  owner="$(owner_of "$prefix")"
  if [[ -z "$owner" ]]; then
    echo "$id: unknown prefix (not in AGENTS.md §3 ID table)" >&2
    errors=$((errors+1))
    continue
  fi
  if ! is_defined "$id" "$owner"; then
    echo "$id: undefined - not found in owner $owner" >&2
    errors=$((errors+1))
  fi
done

if (( errors > 0 )); then
  echo "ID consistency: FAILED ($errors error(s))" >&2
  exit 1
fi
echo "ID consistency: OK (${#all_ids[@]} IDs across ${#files[@]} files)"
