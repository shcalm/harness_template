# TASKS Template: Execution State and Session Recovery

<!-- DOC-CONTRACT: TASKS.md
role: source of truth for current execution state and session recovery
status: permanent
read_policy: read before editing this file
required_sections: Current Focus, Top-Level Backlog, Current Task Breakdown, Blockers and Assumptions, Handoff, Session Mental Snapshot, Collapse Rules
ids: TASK-*, REQ-*, AC-*, TEST-*, BUG-*, Q-*
rules:
  - only one current-focus task at a time
  - the current task must link to a REQ-ID or AC-ID
  - after the generation action, the top-level backlog must cover every AC-ID in the current scope
  - every main task must include completion criteria and a verification plan before implementation starts
  - the next action must be an executable command or specific operation
  - long logs go to .log files; this document keeps only summaries and paths
  - §5.1 Session Mental Snapshot is the code agent's entry point after compaction or resumption — keep it within 10 lines and overwrite, not append
-->

This file records execution state and verification plans. Long-term business intent goes in `PRD.md`, long-term technical knowledge in `DESIGN.md`, and executed verification results in `TEST_REPORT.md`.

During design, planned verification, reserved `TEST-ID`s, and key observation points live here first. Only executed verification results move into `TEST_REPORT.md`.

Status symbols:
* `[ ]` pending
* `[/]` in-progress
* `[x]` done
* `[!]` blocked

## 1. Current Focus

| Field | Content |
| :--- | :--- |
| Current Task | TASK-001 |
| Linked REQ | REQ-001 |
| Linked AC | AC-001 |
| Phase | `[Requirements alignment / Design / Implementation / Verification / Delivery]` |
| Next Action | `[One executable command or specific operation]` |
| Current Blocker | `[None / BUG-001 / Q-001]` |

## 2. Top-Level Backlog: Global Goals

| Status | TASK-ID | Main Task | Linked REQ/AC | Completion Criteria | Verification Plan | Verification Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [/] | TASK-001 | `[Current main task]` | REQ-001 / AC-001 | `[What counts as done]` | `[How to verify it and which signals to watch]` | TEST-001 |
| [ ] | TASK-002 | `[Next main task]` | REQ-002 / AC-002 | `[Completion criteria]` | `[Reserved TEST-ID, verification type, success criteria]` | `[Pending execution]` |

## 3. Current Task Breakdown: TASK-001

| Status | Subtask | Action | Evidence / Output |
| :--- | :--- | :--- | :--- |
| [ ] | TASK-001.1 | `[Reproduce / add logs / design tests]` | `[Reserved TEST-ID / log path / test name]` |
| [ ] | TASK-001.2 | `[Implement minimal change]` | `[File / function / config]` |
| [ ] | TASK-001.3 | `[Run local verification]` | TEST-001 |
| [ ] | TASK-001.4 | `[Run end-to-end verification]` | TEST-002 |

> During design, use this section to define the verification plan first: reserve `TEST-ID`s, state verification type, key logs/observation points, and pass criteria. Move results into `TEST_REPORT.md` only after execution.
> The `Evidence / Output` column records unit-test results: on pass, write the test command or log path; on fail, mark `[!]` and write the log path, and register a `BUG-ID` in §4.

## 4. Blockers and Assumptions

| BUG/Q-ID | Status | Summary | Evidence Path | Current Assumption | Next Verification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| BUG-001 | [!] | `[One-sentence blocker]` | `[logs/xxx.log]` | `[Current judgment — mark explicitly as a pending assumption]` | `[Command or operation]` |

> When a cross-module, hard-to-reproduce, or root-cause-unclear issue appears, upgrade it into a new `TASK` or subtask first, then record the `BUG/Q-ID` and the next verification here.

## 5. Handoff

### 5.1 Session Mental Snapshot

> Audience: code agent (read first after compaction or on resumption).
> Form: free text, ≤10 lines, overwrite-on-update, never accumulated.
> Content: current mental model, recent reasoning, rejected paths, background on assumptions still being verified. Structured fields (focus / next action / blockers) live in tables and are not repeated here.

```text
[Working memory for this session:
 - Core problem I am solving ...
 - My judgment before the last interruption ...
 - Paths rejected and why ...
 - Largest remaining uncertainty ...]
```

### 5.2 Handoff Fields

| Field | Content |
| :--- | :--- |
| Recently Completed | `[Concrete items finished this round]` |
| Recent Evidence | `[TEST-ID / log path / command]` |
| Recovery Entry | `[First command or first file to open next time]` |
| Risks | `[Unresolved risks with associated BUG/TASK-ID]` |

## 6. Collapse Rules

When a main task is done, collapse "Current Task Breakdown" into one row:

| Status | TASK-ID | Main Task | Linked REQ/AC | Completion Summary | Verification Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [x] | TASK-001 | `[Main task]` | REQ-001 / AC-001 | `[One-sentence result]` | TEST-001 / TEST-002 |

## 7. Minimal Example

| Field | Content |
| :--- | :--- |
| Current Task | TASK-001 |
| Linked REQ | REQ-001 |
| Linked AC | AC-001 |
| Phase | Design |
| Next Action | `pytest tests/test_upload.py::test_upload_success -q` |
| Current Blocker | None |

| Status | Subtask | Action | Evidence / Output |
| :--- | :--- | :--- | :--- |
| [x] | TASK-001.1 | Design upload-success verification | `Reserve TEST-001; watch response code and upload_complete log` |
| [/] | TASK-001.2 | Run end-to-end upload verification | `logs/upload_full_path.log` |
