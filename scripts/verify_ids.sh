#!/usr/bin/env bash
# 跨文档 ID 一致性校验
#   每个 ID 出现在任意一份项目文档中时，必须在其归属文档（owner）中同样出现，
#   否则视为悬挂引用。
#   Brainstorm 阶段（PRD.md §1 项目名仍为占位）跳过本检查。
#   §9 / §11 「最小填写示例」段从检查中剔除（不视为定义也不视为引用）。
#
# 新增 ID 前缀时需同步两处：
#   1. AGENTS.md §3「统一 ID」表
#   2. 本脚本 ID_PATTERN 与 owner_of 映射
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")/.."

# 受治理的 ID 前缀 + 三位数字编号 + 可选子级（仅 TASK 用得到）
ID_PATTERN='(REQ|AC|FLOW|CON|NOGOAL|Q|DEC|INV|CONTRACT|OBS|BUG|DEBT|TASK|TEST)-[0-9]{3}(\.[0-9]+)?'

# 归属：prefix -> owner file
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

# 阶段检测：项目名仍为占位 -> Brainstorm，跳过本检查
if grep -qE '\[项目名称\]|\[Project Name\]' PRD.md; then
  echo "ID consistency: skipped (Brainstorm phase)"
  exit 0
fi

# 从文件中剔除「最小填写示例」/「Minimal Example」段，
# 直到下一个二级标题或文件结束。
strip_examples() {
  awk '
    BEGIN { skip = 0 }
    /^## +[0-9]+\. +.*(最小填写示例|Minimal Example)/ { skip = 1; next }
    /^## / { skip = 0 }
    !skip { print }
  ' "$1"
}

# 收集每份文件已声明的 ID 集合
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

# 收集四份文件中出现过的全部 ID
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
