#!/usr/bin/env bash
# Template verification: drives section-existence checks from metadata blocks
# (DOC-CONTRACT / AGENTS-META). When section titles change, sync the
# `required_sections` field in metadata; this script needs no change.
set -euo pipefail

required_files=(
  AGENTS.md
  PRD.md
  DESIGN.md
  TASKS.md
  TEST_REPORT.md
)

# Extract the `required_sections` value (comma-separated section names) from the
# metadata block of a file.
extract_required_sections() {
  local file="$1"
  sed -n '/<!--[[:space:]]*\(DOC-CONTRACT\|AGENTS-META\)/,/-->/p' "$file" \
    | grep -E '^required_sections:' \
    | head -n 1 \
    | sed -E 's/^required_sections:[[:space:]]*//'
}

# Extract the `version` value (harness version) from the AGENTS-META metadata block.
extract_harness_version() {
  local file="$1"
  sed -n '/<!--[[:space:]]*AGENTS-META/,/-->/p' "$file" \
    | grep -E '^version:' \
    | head -n 1 \
    | sed -E 's/^version:[[:space:]]*//'
}

# Check that a file contains the given metadata block tag.
check_metadata_block() {
  local file="$1"
  local tag="$2"

  if ! grep -q "$tag" "$file"; then
    echo "$file: missing metadata block '$tag'" >&2
    exit 1
  fi
}

# Check that a section title exists in the file.
# Accepts level-2 / level-3 headings with N. or N.M numbering, for example:
#   ## 0. File Contracts
#   ## 1. Project Overview
#   ### 5.1 Session Mental Snapshot
check_section() {
  local file="$1"
  local section="$2"

  if ! grep -Eq "^#{2,3}[[:space:]]+[0-9.]+[[:space:]]+.*${section}" "$file"; then
    echo "$file: missing section '$section'" >&2
    exit 1
  fi
}

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing required file: $file" >&2
    exit 1
  fi

  if [[ "$file" == "AGENTS.md" ]]; then
    check_metadata_block "$file" "AGENTS-META"
  else
    check_metadata_block "$file" "DOC-CONTRACT: $file"
  fi

  sections=$(extract_required_sections "$file")
  if [[ -z "$sections" ]]; then
    echo "$file: required_sections not declared in metadata block" >&2
    exit 1
  fi

  IFS=',' read -ra section_list <<< "$sections"
  for sec in "${section_list[@]}"; do
    sec="$(echo "$sec" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [[ -n "$sec" ]] || continue
    check_section "$file" "$sec"
  done
done

echo "docs template verification passed"

harness_version="$(extract_harness_version AGENTS.md)"
if [[ -z "$harness_version" ]]; then
  echo "AGENTS.md: missing version field in AGENTS-META block" >&2
  exit 1
fi
echo "harness version: v${harness_version}"

# Chain into cross-document ID consistency check (auto-skipped in Brainstorm phase).
bash "$(dirname "$(readlink -f "$0")")/verify_ids.sh"
