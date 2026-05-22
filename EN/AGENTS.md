# Agent Engineering Governance

<!-- AGENTS-META
role: code agent governance context
version: 1.0
required_sections: File Contracts, Document Lifecycle, Core Principles, Unified ID Scheme, Working Modes, Quality Gates, Tasks and Logs, Document Update Triggers, Problem Analysis and Resolution, Template Verification
-->

Goal: keep the code agent able to recover context, execute tasks, and leave reproducible evidence across long sessions and multiple resumptions.

## 0. File Contracts

| File | Role | DOC-CONTRACT |
| :--- | :--- | :--- |
| `AGENTS.md` / `CLAUDE.md` | Governance context | None |
| `PROBLEM_SOLVING.md` | Debugging playbook | None |
| `PRD.md` / `DESIGN.md` / `TASKS.md` / `TEST_REPORT.md` | Project source of truth | Required, read before editing |

After the Development Phase begins, template examples and placeholder rows are overwritten or removed in the body, while `DOC-CONTRACT` remains.

## 1. Document Lifecycle

A project begins in the **Brainstorm Phase**, transitions through a single **Generation Action**, and enters the **Development Phase**. No further phase switching occurs.

Phase detection (O(1), read `PRD.md` §1 first cell):

| `PRD.md` §1 "Project Name" | Phase |
| :--- | :--- |
| `[Project Name]` (placeholder) | Brainstorm |
| Real project name | Development |

## 2. Core Principles

* `PRD` = requirements/acceptance, `DESIGN` = design/recovery, `TASKS` = current state, `TEST_REPORT` = quality evidence.
* Evidence precedes conclusion: commands, logs, tests, code references, or manual observation.
* End-to-end validation outranks local correctness: closing a task requires covering the associated `AC-ID`.
* Minimal change, reversible, auditable; key decisions record alternatives / reason / cost.
* Every handoff leaves the current focus, next action, blockers, and evidence paths.

## 3. Unified ID Scheme

| Owner | ID Prefix | Meaning |
| :--- | :--- | :--- |
| `PRD.md` | `REQ-NNN` | Requirement |
| `PRD.md` | `AC-NNN` | End-to-end acceptance |
| `PRD.md` | `FLOW-NNN` | Business flow |
| `PRD.md` | `CON-NNN` | Constraint / assumption |
| `PRD.md` | `NOGOAL-NNN` | Non-goal |
| `PRD.md` | `Q-NNN` | Open question |
| `DESIGN.md` | `DEC-NNN` | Technical decision |
| `DESIGN.md` | `INV-NNN` | Invariant |
| `DESIGN.md` | `CONTRACT-NNN` | Interface contract |
| `DESIGN.md` | `OBS-NNN` | Observability signal |
| `DESIGN.md` | `BUG-NNN` | Failure mode |
| `DESIGN.md` | `DEBT-NNN` | Technical debt |
| `TASKS.md` | `TASK-NNN[.M]` | Task (supports subtasks) |
| `TEST_REPORT.md` | `TEST-NNN` | Test |

Naming Rules:

* R1 Uppercase prefix + three-digit number: `PREFIX-NNN`.
* R2 Table headers always `<PREFIX>-ID`; no camel-case variants.
* R3 One concept, one prefix (interface = `CONTRACT-*`, observability = `OBS-*`).
* R4 Sub-IDs only on `TASK-001.M`.
* R5 New ID type enters this table before being used.

Cross-document References:

* `AC` → `REQ`; `TASK` → `REQ` + `AC`; `TEST` → `TASK` + `AC`.
* `Q-NNN` defined in `PRD.md` §7; referenced in `TASKS.md` blockers.
* `BUG-NNN` registered in `DESIGN.md` §8; referenced by `TASKS.md` blockers and `TEST_REPORT.md` defects under the same number.
* Before closing a `TASK`, `TASKS.md` and `TEST_REPORT.md` trace back to the same set of `AC-ID`s.

## 4. Working Modes

### Brainstorm Phase

The agent leaves project documents untouched and collects five essentials in conversation:

1. Business goal and target users.
2. Core business flow (≥1 `FLOW`).
3. ≥1 `REQ` + matching `AC`.
4. Tech stack and runtime environment.
5. Minimal run / verification command.

Once complete, the agent proactively confirms "Generate project documents now?"; gaps become `Q-NNN` (conversation only, not in files).

### Generation Action (one-shot, not repeatable)

On user confirmation, overwrite the four project documents. Each document uses its `DOC-CONTRACT` `required_sections` as the skeleton and fills it section by section.

| Keep | Overwrite | Remove |
| :--- | :--- | :--- |
| `DOC-CONTRACT` comment block | Placeholder rows → real content | "Minimal Example" section in each document |
| Section titles and numbering | Headers stay, table rows take real values | Rows containing only `[xxx]` |
| Table header column names | PRD §1 Project Name → real name | Unused example ID rows |

`init.sh` is created when the tech stack is clear; otherwise log a `Q-NNN` in `TASKS.md`.

### Development Phase

At the start of every session:

1. Read `TASKS.md` (including §5 Session Mental Snapshot): recover focus, next action, mental model.
2. Read `PRD` / `DESIGN` / `TEST_REPORT`: align on goals, design, evidence.
3. Execute the current `TASK-NNN`; new requirements → `PRD`, new decisions → `DESIGN`, new state → `TASKS`, new evidence → `TEST_REPORT`.

## 5. Quality Gates

Definition of Ready (DoR):

* Explicit `REQ-ID / AC-ID`.
* Executable next action.
* Expected verification approach.
* Environment recovery steps work, or the blocker is recorded.

Definition of Done (DoD):

* Minimal change.
* `AC-ID` validated end-to-end, or failure reason recorded.
* `TEST_REPORT.md` carries command, exit code, evidence path, environment, versions.
* `TASKS.md` state updated with a usable next-action entry.
* Remaining risks have a `BUG-ID` or follow-up `TASK-ID`.

Verification record format: `1.[Step]->Verify:[Test/Log]`

## 6. Tasks and Logs

### 6.1 Status Vocabulary

| Category | Used in | Status Set |
| :--- | :--- | :--- |
| Task progress | `TASKS.md` | `[ ]` pending / `[/]` in-progress / `[x]` done / `[!]` blocked |
| Test verdict | `TEST_REPORT.md` | pass / fail / not-run / partial |

Cross-table consistency:

* Verdict = `fail` → associated task status must be `[!]`.
* Verdict = `not-run` → associated task status must not be `[x]`.
* Marking a task `[x]` requires every `AC-ID` it covers has all tests in `TEST_REPORT.md` with verdict = `pass`.

### 6.2 Logs and Collapsing

* Only one current-focus task expanded at a time.
* Long logs go to `.log` files; documents keep only the summary and path.
* After a top-level task finishes, collapse its subtasks into a one-line summary.
* When categorization is uncertain, write into `TASKS.md` blockers and request confirmation.

## 7. Document Update Triggers

| Change Trigger | Update Location |
| :--- | :--- |
| Generation Action completes | 4 documents enter incremental mode |
| Requirements / acceptance change | `PRD.md` |
| Decisions / architecture / failure modes | `DESIGN.md` |
| Task / blockers / next action | `TASKS.md` |
| Test results | `TEST_REPORT.md` |
| Session end / handoff | `TASKS.md` §5 |

Test Tiers and Document Ownership:

| Tier | Timing | Status Location | Evidence Archive |
| :--- | :--- | :--- | :--- |
| Unit tests | Throughout development | `TASKS.md` subtask `Evidence/Output` column | `TEST_REPORT.md` §4 (delivery-time summary) |
| Integration / end-to-end | Once per completed task | `TEST_REPORT.md` §3 and §5 | `TEST_REPORT.md` |

## 8. Problem Analysis and Resolution

For BUGs or system anomalies, reference `PROBLEM_SOLVING.md` (full engagement conditions, debugging method, and exit criteria). Single-module problems with obvious cause are handled directly.

## 9. Template Verification

Run `scripts/verify_docs.sh` before delivery. It covers three checks:

1. Section existence (driven by `DOC-CONTRACT` / `AGENTS-META` `required_sections`).
2. Harness version (`AGENTS-META.version`).
3. Cross-document ID consistency (chains into `scripts/verify_ids.sh`; auto-skipped in Brainstorm phase).

Proceed to testing, end-to-end verification, and handoff only after all three pass.
