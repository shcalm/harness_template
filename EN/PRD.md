# PRD Template: Requirements and Acceptance Contract

<!-- DOC-CONTRACT: PRD.md
role: source of truth for requirements and acceptance
status: permanent
read_policy: read before editing this file
required_sections: Project Overview, Non-Goals, Core Business Flows, Requirements, End-to-End Acceptance Criteria, Constraints and Assumptions, Open Questions, Change Log
ids: REQ-*, AC-*, FLOW-*, NOGOAL-*, CON-*, Q-*
rules:
  - every AC must link to at least one REQ
  - every acceptance criterion must be executable, observable, and reproducible
  - unresolved questions go to Open Questions and, once resolved, become a REQ, AC, CON, or Non-Goal
-->

This file focuses on the problem to solve and the verifiable outcome. Implementation details belong in `DESIGN.md`.

## 1. Project Overview

| Field | Content |
| :--- | :--- |
| Project Name | `[Project Name]` |
| Business Goal | `[One-sentence description of the business value to create]` |
| Target Users | `[Users / systems / callers]` |
| Success Metrics | `[Quantifiable indicators or observable outcomes]` |
| Current Stage | `[Exploration / MVP / Increment / Maintenance]` |

## 2. Non-Goals

The following items are explicitly out of scope for this round:

| ID | Non-Goal | Reason |
| :--- | :--- | :--- |
| NOGOAL-001 | `[What is not being done]` | `[Why it is not in scope this round]` |

## 3. Core Business Flows

| FLOW-ID | Actor | Preconditions | Steps | Outcome |
| :--- | :--- | :--- | :--- | :--- |
| FLOW-001 | `[Role]` | `[Preconditions]` | `1. ... 2. ... 3. ...` | `[Observable outcome]` |

## 4. Requirements

| REQ-ID | Priority | Status | Description | Linked Flow |
| :--- | :--- | :--- | :--- | :--- |
| REQ-001 | P0 | `[Draft / Confirmed / Changing / Done]` | `[Capability the user or system must have]` | FLOW-001 |

Priority definition:
* P0: necessary for delivering the core flow.
* P1: affects main experience or stability without blocking the minimal loop.
* P2: enhancement or follow-up optimization.

## 5. End-to-End Acceptance Criteria

| AC-ID | Linked REQ | Scenario | Input | Steps | Expected Result | Evidence Type |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AC-001 | REQ-001 | `[Business scenario]` | `[Specific input data]` | `1. ... 2. ...` | `[API response / UI state / DB change / artifact / log signature]` | `[Test command / log / screenshot / artifact path]` |

Acceptance requirements:
* Each `AC-ID` verifies exactly one business conclusion.
* The expected result must be recordable as evidence in `TEST_REPORT.md`.
* When manual observation is required, state the observation window, observed object, and pass condition.

## 6. Constraints and Assumptions

| ID | Type | Content | Verification |
| :--- | :--- | :--- | :--- |
| CON-001 | `[Business / Technical / Legal / Performance / Security]` | `[Constraint or assumption]` | `[How to confirm it still holds]` |

## 7. Open Questions

| ID | Question | Impact | Owner | Status |
| :--- | :--- | :--- | :--- | :--- |
| Q-001 | `[Question awaiting confirmation]` | `[Risk if left unresolved]` | `[Person / role]` | `[Pending / Resolved]` |

Once resolved, each question must convert into a REQ/AC/CON change or be recorded as a non-goal.

## 8. Change Log

| Date | Change | Affected REQ/AC | Reason |
| :--- | :--- | :--- | :--- |
| YYYY-MM-DD | `[Change summary]` | REQ-001 / AC-001 | `[Why the change happened]` |

## 9. Minimal Example

| REQ-ID | Priority | Status | Description | Linked Flow |
| :--- | :--- | :--- | :--- | :--- |
| REQ-001 | P0 | Confirmed | A user can upload a file up to 10 MB and receive a download link. | FLOW-001 |

| AC-ID | Linked REQ | Scenario | Input | Steps | Expected Result | Evidence Type |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AC-001 | REQ-001 | Successful file upload | `sample.pdf`, 2 MB | `1. Start service 2. Call upload endpoint 3. Read response` | Returns `200`, response contains an accessible download link, service log shows `upload_complete`. | Test command, response log, service log |
