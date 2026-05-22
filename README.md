# Agent Engineering Harness

A documentation governance template set for code agents (Claude Code, Codex CLI, and other AGENTS.md-aware tools). Keeps the agent able to recover context, execute tasks, and leave reproducible evidence across long sessions and multiple resumptions.

Harness version: **v1.0**

## Layout

| Path | Language | Purpose |
| :--- | :--- | :--- |
| Repository root | Chinese | Primary template set |
| `EN/` | English | Full mirror for English-only projects |

Both versions contain the same files:

```
AGENTS.md            # Governance context (read first)
CLAUDE.md            # Claude Code auto-load entry; points to AGENTS.md
PROBLEM_SOLVING.md   # Debugging method (engagement conditions, 8-step flow)
PRD.md               # Requirements and acceptance criteria
DESIGN.md            # Technical design and recovery manual
TASKS.md             # Current execution state and session recovery
TEST_REPORT.md       # Quality evidence and delivery audit
scripts/
  verify_docs.sh     # Metadata-driven section check + version + ID chain
  verify_ids.sh      # Cross-document ID consistency
```

## Installation

The harness ships several files. Copying treatment differs by category:

| File / Path | Copy treatment | Reason |
| :--- | :--- | :--- |
| `AGENTS.md`, `CLAUDE.md` | Overwrite | Governance entry points; single source of truth |
| `PRD.md`, `DESIGN.md`, `TASKS.md`, `TEST_REPORT.md` | Overwrite | Project document templates; Brainstorm phase expects them blank |
| `PROBLEM_SOLVING.md` | Overwrite | Debugging method reference |
| `scripts/verify_docs.sh`, `scripts/verify_ids.sh` | Overwrite | Verification chain |
| `.gitignore` | **Manual merge** | Target project may already have language-specific rules |
| `README.md` | **Skip** | Target project keeps its own README |

For `.gitignore`, append the snippet below to the target project's existing `.gitignore`, or copy directly if the target has none:

````text
# Logs and runtime artifacts
*.log
logs/

# Local-only agent settings (per-user overrides)
.claude/settings.local.json
````

Choose the language version (repository root for Chinese, `EN/` for English) and copy the listed files into your project root.

## Usage

1. Copy either the repository-root files (Chinese) or the contents of `EN/` (English) into your new project root.
2. Open the project in Claude Code (or any AGENTS.md-aware agent). `CLAUDE.md` loads automatically and directs the agent to `AGENTS.md`.
3. **Brainstorm** with the agent. When the five essentials are gathered (business goal, core flow, REQ+AC, tech stack, minimal verification command), the agent asks "Generate project documents now?"
4. Confirm → the **Generation Action** overwrites the four project documents with real content and creates `init.sh` when applicable. The project enters the **Development Phase**.
5. From here on: follow `AGENTS.md` DoR / DoD, ID consistency, status vocabulary, and document update triggers.

## Verification

Run before delivery:

```bash
bash scripts/verify_docs.sh
```

It chains three checks:

1. **Section existence** — driven by `DOC-CONTRACT` / `AGENTS-META` `required_sections` (metadata-driven; rename a section, sync the metadata, and the script picks it up).
2. **Harness version** — `AGENTS-META.version` is present and printed.
3. **Cross-document ID consistency** — `scripts/verify_ids.sh` enforces every used ID is defined in its owning document. Auto-skipped in the Brainstorm phase.

## Why this exists

Long agent sessions lose context. Multiple agents (Claude Code, Codex CLI, Cursor) need a shared protocol. Two recurring failure modes drove the design:

* The agent rewrites the same conclusion in different files, then loses track of which version is authoritative.
* After context compaction, the agent forgets why it was on a particular path.

This harness fixes both by making one source of truth per concern (requirements / design / state / evidence / debugging) and a single mental-snapshot section the agent reads first on resumption.

## 中文摘要

本仓库是面向 code agent 的工程治理模板。中文版位于仓库根，英文版位于 `EN/`。拷贝任一版到新项目根目录时，治理文件（AGENTS / CLAUDE / 4 份项目文档 / PROBLEM_SOLVING / scripts）直接覆盖；`.gitignore` 需手动合并（见 Installation 节片段），`README.md` 跳过不覆盖。从 Brainstorm 阶段起步，agent 收齐 5 项必收信息后一次性生成 4 份项目文档，进入开发阶段。完整规范、ID 体系、质量 Gate 见 `AGENTS.md`；调试方法见 `PROBLEM_SOLVING.md`。交付前运行 `scripts/verify_docs.sh` 完成三项校验。
