# TEST_REPORT Template: Quality Evidence and Delivery Audit

<!-- DOC-CONTRACT: TEST_REPORT.md
role: source of truth for quality evidence and delivery audit
status: permanent
read_policy: read before editing this file
required_sections: Delivery Verdict, Verification Environment, Test Matrix, Unit and Local Verification, End-to-End Business Verification, Defects and Remaining Risks, Reproduction Steps, Audit Checklist
ids: TEST-*, AC-*, TASK-*, BUG-*
rules:
  - every test record carries a TEST-ID
  - every TEST-ID links to an AC-ID and a TASK-ID
  - end-to-end verification has at least one full-path entry
  - design-stage verification planning stays in TASKS.md; this file records only executed verification or delivery-audit entries explicitly marked not-run
-->

This file records reproducible quality evidence. Conclusions trace back to commands, logs, artifacts, or manual observation records.

When a `TEST-ID` is first reserved during design in `TASKS.md`, it becomes a formal record here only after the verification is actually executed.

## 1. Delivery Verdict

| Field | Content |
| :--- | :--- |
| Verdict | `[pass / partial / fail / not-verified]` |
| Date | `YYYY-MM-DD` |
| Branch | `[branch]` |
| Commit | `[commit hash; if uncommitted, describe working-tree state]` |
| Dirty State | `[clean / dirty, list relevant files]` |
| Coverage | `[REQ/AC list covered]` |
| Main Risk | `[None / BUG-ID / risk summary]` |

## 2. Verification Environment

| Item | Value | Capture Command |
| :--- | :--- | :--- |
| OS | `[Version]` | `uname -a` |
| Runtime | `[Version]` | `[Command]` |
| Dependency Versions | `[Key dependencies]` | `[Command]` |
| Configuration | `[Key config name and purpose]` | `[Command]` |

## 3. Test Matrix

> This matrix records only verifications that actually ran, or verifications that a delivery audit explicitly needs to mark as not-run. Pure planning items do not belong here.

| TEST-ID | Type | Linked TASK | Covered AC | Command / Operation | Exit Code | Evidence Path | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| TEST-001 | `[unit / integration / full-path / manual]` | TASK-001 | AC-001 | `[Command or manual step]` | `[0 / non-zero / manual]` | `[logs/xxx.log / screenshot / artifact]` | `[pass / fail / not-run]` |
| TEST-002 | full-path | TASK-001 | AC-001 | `[End-to-end command or manual step]` | `[0 / non-zero / manual]` | `[logs/full_path.log / screenshot / artifact]` | `[pass / fail / not-run]` |

## 4. Unit and Local Verification

> This section is a delivery-time summary aggregated from the `Evidence / Output` column of each subtask in `TASKS.md`; it is not used for live tracking. During development, unit-test failure state and verification planning live in the `TASKS.md` subtask row.

Format:

```text
1.[Step]->Verify:[Test/Log]
```

Record:

```text
1.[step]->Verify:[[command], [log path]]
```

Key output excerpt:

```text
[Keep ≤50 lines of key output; full log lives at the listed path]
```

## 5. End-to-End Business Verification

| AC-ID | Scenario | Preconditions | Steps | Observed | Evidence | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AC-001 | `[Scenario from PRD]` | `[Environment / data / service state]` | `1. ... 2. ...` | `[Actual observation]` | TEST-002 | `[pass / fail]` |

Pass criteria:
* The actual observation must match the expected result of the corresponding `AC-ID` in `PRD.md`.
* If only local tests pass, mark the verdict as `partial`.
* When verification relies on manual observation, record the observation time, observed object, and decision basis.

## 6. Defects and Remaining Risks

| BUG-ID | Linked AC/TASK | Severity | Symptom | Impact | Evidence | Follow-up |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| BUG-001 | AC-001 / TASK-001 | `[P0 / P1 / P2]` | `[Defect symptom]` | `[Impact scope]` | `[Log / test]` | TASK-002 |

## 7. Reproduction Steps

Reproduce the verdicts in this report from a clean environment:

1. Switch revision: `[git checkout ...]`
2. Initialize environment: `./init.sh`
3. Start services: `[Command]`
4. Run verification: `[Command]`
5. Compare evidence: `[Log path / artifact path]`

## 8. Audit Checklist

| Gate | Status | Evidence |
| :--- | :--- | :--- |
| `PRD` has corresponding `REQ/AC` | `[pass / fail]` | `[File line or ID]` |
| `DESIGN` records key decisions | `[pass / fail]` | DEC-001 |
| `TASKS` reflects current state | `[pass / fail]` | TASK-001 |
| Unit / local verification executed | `[pass / fail]` | TEST-001 |
| End-to-end verification executed | `[pass / fail]` | TEST-002 |
| Known risks documented | `[pass / fail]` | BUG-001 / None |

## 9. Minimal Example

| TEST-ID | Type | Linked TASK | Covered AC | Command / Operation | Exit Code | Evidence Path | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| TEST-001 | unit | TASK-001 | AC-001 | `pytest tests/test_upload.py::test_upload_success -q` | 0 | `logs/test_upload_success.log` | pass |
| TEST-002 | full-path | TASK-001 | AC-001 | `scripts/e2e_upload.sh sample.pdf` | 0 | `logs/e2e_upload.log` | pass |

```text
1.Upload 2 MB PDF->Verify:[pytest tests/test_upload.py::test_upload_success -q, logs/test_upload_success.log]
2.Complete upload end-to-end->Verify:[scripts/e2e_upload.sh sample.pdf, logs/e2e_upload.log]
```
