#!/usr/bin/env bash
# 模板校验：用 metadata 块（DOC-CONTRACT / AGENTS-META）驱动章节存在性检查。
# 改章节名时只需同步 metadata 的 required_sections 字段，本脚本不需要改。
set -euo pipefail

required_files=(
  AGENTS.md
  PRD.md
  DESIGN.md
  TASKS.md
  TEST_REPORT.md
)

# 从文件的 metadata 注释块中提取 required_sections 字段值（逗号分隔的章节名列表）。
extract_required_sections() {
  local file="$1"
  sed -n '/<!--[[:space:]]*\(DOC-CONTRACT\|AGENTS-META\)/,/-->/p' "$file" \
    | grep -E '^required_sections:' \
    | head -n 1 \
    | sed -E 's/^required_sections:[[:space:]]*//'
}

# 从 AGENTS-META 注释块中提取 version 字段值（harness 版本号）。
extract_harness_version() {
  local file="$1"
  sed -n '/<!--[[:space:]]*AGENTS-META/,/-->/p' "$file" \
    | grep -E '^version:' \
    | head -n 1 \
    | sed -E 's/^version:[[:space:]]*//'
}

# 校验文件中含指定的元数据块标签。
check_metadata_block() {
  local file="$1"
  local tag="$2"

  if ! grep -q "$tag" "$file"; then
    echo "$file: missing metadata block '$tag'" >&2
    exit 1
  fi
}

# 校验文件中存在指定章节标题。
# 支持二/三级标题与 N. / N.M 编号，例：
#   ## 0. 文件契约
#   ## 1. 项目概述
#   ### 5.1 会话心智摘要
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

# 链式调用跨文档 ID 一致性校验（Brainstorm 阶段会自动跳过）。
bash "$(dirname "$(readlink -f "$0")")/verify_ids.sh"
