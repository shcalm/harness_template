# DESIGN Template: Technical Design and Recovery Manual

<!-- DOC-CONTRACT: DESIGN.md
role: source of truth for technical design and recovery
status: permanent
read_policy: read before editing this file
required_sections: Environment Baseline, Recovery Steps, Architecture Overview, Interface and Data Contracts, Invariants, Technical Decision Records, Observability, Failure Modes and Handling, Rollback and Compatibility, Known Technical Debt
ids: DEC-*, INV-*, OBS-*, BUG-*, DEBT-*, CONTRACT-*
rules:
  - design conclusions trace back to REQ, AC, or DEC
  - environment, build, and run commands are copy-runnable
  - key interfaces link to REQ/AC
-->

This file records how to implement, why this way, how to recover the environment, and how to localize problems. Business goals and acceptance criteria belong in `PRD.md`.

## 1. Environment Baseline

| Item | Requirement | Verification Command |
| :--- | :--- | :--- |
| OS | `[Distro / version]` | `uname -a` |
| Language / Runtime | `[Version]` | `[Command]` |
| Package Manager | `[Version]` | `[Command]` |
| Database / External Services | `[Version or note]` | `[Command]` |
| Key Environment Variables | `[Variable name and purpose]` | `[How to check presence]` |

## 2. Recovery Steps

From a clean working tree, recover to a verifiable state:

1. Install dependencies: `[Command]`
2. Environment check: `./init.sh`
3. Build: `[Command]`
4. Start: `[Command]`
5. Minimal health check: `[Command]`

Success criteria:
* All commands exit with code `0`.
* The health check produces `[Concrete success signature]`.
* On failure, logs land in `[Log path]`.

## 3. Architecture Overview

```text
[External caller]
    -> [Module A: responsibility]
    -> [Module B: responsibility]
    -> [Storage / external service: responsibility]
```

| Module | Responsibility | Input | Output | Dependencies | Linked REQ/AC |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[Module name]` | `[Single responsibility]` | `[Input]` | `[Output]` | `[Dependencies]` | REQ-001 / AC-001 |

## 4. Interface and Data Contracts

| CONTRACT-ID | Linked REQ/AC | Caller | Interface / Function / Message | Request | Response | Error Semantics |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CONTRACT-001 | REQ-001 / AC-001 | `[Caller]` | `[Interface]` | `[Fields and constraints]` | `[Fields and constraints]` | `[Error codes / exceptions / retry rules]` |

## 5. Invariants

These conditions always hold. Violations point to design or state-management issues first.

| INV-ID | Invariant | Protected At | Verification |
| :--- | :--- | :--- | :--- |
| INV-001 | `[Condition that must always hold]` | `[Module / test / assertion]` | `[Command or log signature]` |

## 6. Technical Decision Records

| DEC-ID | Linked REQ/AC | Decision | Alternatives | Reason | Cost / Risk | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| DEC-001 | REQ-001 | `[Chosen option]` | `[At least one alternative]` | `[Why this option fits better]` | `[Side effects or maintenance cost]` | `[Adopted / Deprecated / Pending]` |

## 7. Observability

| OBS-ID | Type | Location | Description | Normal Signature | Abnormal Signature |
| :--- | :--- | :--- | :--- | :--- | :--- |
| OBS-001 | `[Log / Metric / Tracing / Artifact]` | `[File / module / command]` | `[What to observe]` | `[Normal output]` | `[Abnormal output]` |

## 8. Failure Modes and Handling

| BUG-ID | Symptom | Trigger Condition | Key Logs | Root Cause | Handling | Regression Verification |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| BUG-001 | `[Error symptom]` | `[How to trigger]` | `[Log path or excerpt]` | `[Confirmed root cause]` | `[Fix or workaround]` | TEST-001 |

## 9. Rollback and Compatibility

| Scenario | Rollback Method | Data Impact | Compatibility Risk | Verification |
| :--- | :--- | :--- | :--- | :--- |
| `[Change scenario]` | `[How to roll back]` | `[Whether data is affected]` | `[Caller / version risk]` | `[Command or AC-ID]` |

## 10. Known Technical Debt

| DEBT-ID | Description | Impact | Trigger Condition | Follow-up Task |
| :--- | :--- | :--- | :--- | :--- |
| DEBT-001 | `[Technical debt]` | `[Impact scope]` | `[When it becomes a problem]` | TASK-001 |

## 11. Minimal Example

| DEC-ID | Linked REQ/AC | Decision | Alternatives | Reason | Cost / Risk | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| DEC-001 | REQ-001 / AC-001 | Save files to the local `uploads/` directory first. | Use object storage directly. | Local storage validates the full upload path more easily at the MVP stage. | The storage layer must be swapped before multi-instance deployment. | Adopted |

| INV-ID | Invariant | Protected At | Verification |
| :--- | :--- | :--- | :--- |
| INV-001 | A download link only points to a file that fully landed on disk. | Before the upload service returns a response | `pytest tests/test_upload.py::test_link_points_to_existing_file -q` |
