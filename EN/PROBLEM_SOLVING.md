# PROBLEM_SOLVING.md: Problem Analysis and Resolution Flow

> This file constrains **debugging method** (thinking flow, decision criteria). Whether documents are updated, when they are updated, and whether they must be tied to a commit all follow `AGENTS.md` §7.
> Document writes follow AGENTS.md §7; verification record format follows AGENTS.md §5; engagement conditions are defined by this file.

## When to Engage This Flow

**Simple problems are handled directly without this flow.** These traits mean a problem is simple enough for a direct answer:

* The error message points to a single cause.
* The impact stays within one function or module.
* Cause and fix are obvious at a glance.

**Complex problems must engage this flow.** Skipping the flow tends to go off-track when any of these appear:

| Trait | Meaning |
| :--- | :--- |
| Crosses modules / boundaries | The problem spans multiple modules; the root cause lives somewhere other than a single location |
| Symptom and cause diverge | The error surface is far from the actual root cause |
| Intermittent / hard to reproduce | Cannot be triggered reliably; depends on timing, concurrency, or external state |
| Recurs after a fix | A previous "fix" did not actually address the root cause |
| Unclear impact scope | Uncertain which modules will be affected by the change |
| Assumptions outnumber evidence | The reasoning chain runs more than two steps with every step being a guess |

Once the problem matches these complex-problem traits, first create or split a tracked `TASK` in `TASKS.md`, register a `BUG-ID` when needed, and complete the verification plan before repairing the code.

---

## Core Principle

Evidence precedes conclusion. Grasp the problem from the overall architecture, confirm the boundary, then narrow inward to the root cause. Local correctness does not imply system correctness.

---

## Standard Flow

### Step 1: Define the Problem

Write each field in one sentence:

| Field | Content |
| :--- | :--- |
| Symptom | What was observed (error / abnormal behavior / performance regression) |
| Trigger Condition | What operation or input produced the symptom |
| Impact Scope | Which features, users, or environments are affected |
| Expected Behavior | What the correct result should be |

> If any of these four fields is incomplete, gather more information before proceeding.

---

### Step 2: Locate the Architectural Boundary

**See the whole before the parts.** Before reading code, answer:

```
1. Which modules make up the system? What are their responsibility boundaries?
2. Which modules sit on the problem's path? What is the call chain?
3. At which boundary does the problem occur?
   - Inside a module?
   - Between modules (caller/callee contract)?
   - At an external dependency boundary (DB, third-party service, OS)?
4. Which side is "trustworthy"? Which side is "suspect"?
```

Draw or write the problem path:

```
[Caller] -> [Module A] -> [Module B] -> [External service]
                              ↑
                       does the problem live here?
```

> Reading code without this step lands you in the blind spot of locally correct but systemically wrong. When the boundary is unclear, return to the `DESIGN.md` Architecture Overview and Interface Contracts.

---

### Step 3: Collect Evidence

Collect in priority order:

1. **Reproduction** — stable reproduction is the strongest evidence; write the minimal repro steps.
2. **Logs** — capture full logs around the error timestamp, covering both sides of the boundary.
3. **Environment** — OS, runtime version, key configuration, recent change history.
4. **Comparison** — find a "working" case and diff the difference.

> When collecting logs, cover **both sides of the boundary**: what the caller sent, what the callee received, and whether the two match.

---

### Step 4: Narrow the Scope

Use elimination, one dimension at a time:

```
Environment issue?     → Reproduce in a different environment → yes/no
Input issue?           → Reproduce with the smallest input    → yes/no
Recent-change issue?   → git bisect or revert and verify      → yes/no
Dependency version?    → Pin a version and verify             → yes/no
Contract mismatch?     → Compare interface spec to actual args → match/mismatch
```

Write down each result; do not rely on memory.

---

### Step 5: Confirm the Root Cause

Root-cause criteria: explains every known symptom and points to a concrete location in code or config.

| Check | Meaning |
| :--- | :--- |
| Explains all symptoms | Including intermittent ones and edge cases |
| Located in code or config | Down to file, line, or config key |
| Boundary attribution clear | Caller-side, callee-side, or contract itself |
| Predicts the fix | The symptom disappears after the change |

> When only some symptoms are explained, either a second root cause exists or an assumption is wrong; keep collecting evidence.

---

### Step 6: Plan the Fix

Write at least two options before choosing:

| Option | Description | Pros | Cost / Risk |
| :--- | :--- | :--- | :--- |
| Option A | `[Minimal change]` | Low risk, fast to verify | `[Limitation]` |
| Option B | `[Full fix]` | Addresses the root cause | Larger blast radius, more verification |

Selection rule: prefer the minimal change that can validate the root cause; open a separate task for the full fix.

Each option must also state the verification method, key logs/observation points, and the success criteria.

---

### Step 7: Implement and Verify

```
1. Apply the minimal change.
2. Re-run the repro steps → symptom gone?
3. Existing tests all pass?
4. Boundary-two-sides check (caller/callee input/output match the contract)
5. Edge cases (empty input, concurrency, exception paths)
```

Verification record format follows AGENTS.md §5.

Before this step begins, confirm that the corresponding `TASK/BUG` entry and verification plan have already been recorded.

When the issue is a build error, syntax error, small localized fix, or other obvious narrow-scope error, successful verification at this step normally means commit directly without updating source-of-truth project documents.

---

### Step 8: Archive

After the root cause is confirmed, close out with these rules:

1. If the current environment supports real verification, finish verification first, then commit, and only then update documents per AGENTS.md §7.
2. If the current environment cannot support real verification, documents may be updated after the code change is prepared, but the record must clearly state the "unverified / awaiting user verification" boundary and explicitly ask the user to verify. After verification passes and the code is committed, convert that record into final fact.
3. Simple issues normally do not update source-of-truth project documents; the commit is the primary record.
4. Complex issues update `TASKS.md` after verification passes, and archive every actually executed verification in `TEST_REPORT.md`.

This flow ends here.

---

## When You Get Stuck

| Stuck Reason | Handling |
| :--- | :--- |
| Boundary unclear | Return to `DESIGN.md` Architecture Overview, add the module relationship diagram, then continue |
| Cannot reproduce | Add logs on both sides of the boundary; wait for the next occurrence and mark "pending observation" |
| Logs insufficient | Add logging in the code, re-trigger, then re-analyze |
| Root cause in external dependency | Reproduce minimally, then file an issue or document a workaround; record a `DEBT-ID` |
| Fix introduces a new problem | Roll back, restart from Step 2 to re-check boundary attribution |
