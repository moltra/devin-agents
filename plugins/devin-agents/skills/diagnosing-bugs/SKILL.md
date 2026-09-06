---
name: diagnosing-bugs
description: Structured debugging discipline for hard bugs. Six phases - build feedback loop, reproduce, hypothesize, instrument, fix, cleanup.
argument-hint: "[bug description]"
triggers:
  - user
  - model
---

You are debugging a hard bug using a structured, six-phase discipline. Resist the urge to jump straight to a fix. The phases exist because unstructured debugging wastes time chasing wrong causes and leaves debug debris in the codebase.

## Redact

Before showing any command, log, stack trace, environment variable, or output to the user or in a commit message, **redact every secret**:

- API keys, tokens, passwords, connection strings, private keys, bearer tokens.
- Personally identifying information (emails, phone numbers, account IDs) when the context is not your own machine.
- Cloud credentials, signing keys, and any value that looks like `AKIA…`, `ghp_…`, `sk-…`, `xoxb-…`, or similar known prefixes.

Replace redacted values with `<REDACTED>` or a placeholder. Never paste a real secret into a shared channel, a commit message, or an issue tracker. When in doubt, redact.

---

## Phase 1 — Build a feedback loop

This is the most important phase. A feedback loop is a single, repeatable command that reproduces the bug (or proves its absence) in seconds. Without a tight loop, every later phase is guesswork.

### Ten ways to build a feedback loop

Pick the one that fits the bug; combine if needed:

1. **Failing test** — Write a test that reproduces the symptom. Best when the bug lives in unit-testable logic.
2. **curl / HTTP client** — A one-line request that triggers the failing endpoint. Best for API and service bugs.
3. **CLI invocation** — Run the program with the exact arguments that fail. Best for command-line tools and scripts.
4. **Headless browser** — Drive the UI with a headless browser script that reproduces the user's click path. Best for frontend bugs.
5. **Replay trace** — Re-run a recorded request, event, or input stream that triggered the bug. Best for distributed and event-driven systems.
6. **Throwaway harness** — A tiny script that imports the suspect module and calls it with the failing input. Best when the real entry point is heavy or slow to start.
7. **Fuzz loop** — Generate random inputs until the bug appears, then capture the triggering input. Best for crashes, panics, and edge-case bugs.
8. **Bisection** — `git bisect` across commits to find the change that introduced the bug. Best for regressions.
9. **Differential** — Run two versions (old vs new, branch A vs branch B) with the same input and diff the output. Best for "it worked before" bugs.
10. **Human-in-the-loop (HITL) script** — A script that sets up the exact state the user had, then pauses for the user to perform the failing action. Best for bugs that require manual interaction or external state.

### Tighten the loop

A loose loop kills debugging velocity. Tighten it relentlessly:

- **Faster** — Cut startup time. Skip unrelated services. Use a smaller dataset. Cache expensive setup. Target seconds, not minutes.
- **Sharper signal** — Make the failure obvious. Assert the exact wrong value, not "something broke." Exit non-zero on the bug, zero on correct.
- **More deterministic** — Remove flakiness. Freeze time. Seed RNGs. Pin external dependencies. A loop that sometimes passes is worse than no loop.
- **Agent-runnable** — The loop must be a single command a machine can run and interpret without human judgment. No "look at the screen and tell me if it looks weird."

### Completion criterion for Phase 1

You have a **single command** that:

- Reproduces the bug (goes red) deterministically.
- Runs in seconds.
- Exits non-zero / fails the test / prints a clear wrong value on bug present.
- Exits zero / passes / prints the correct value on bug absent.
- Requires no human judgment to interpret the result.

Do not proceed to Phase 2 until this command exists. If you cannot build a loop, that is itself a finding — the system is not observable enough to debug, and you need to add observability first.

---

## Phase 2 — Reproduce and minimize

### Confirm the exact symptom

Run the loop and confirm it reproduces the **user's exact symptom**, not a similar-looking but different bug. Read the user's report carefully. Compare the loop's failure to what they described. If they do not match, you are debugging the wrong thing — adjust the loop.

### Minimize the scenario

Shrink the reproducer to the smallest scenario that still fails:

- Remove inputs, options, and setup steps one at a time. After each removal, run the loop. If it still fails, keep the removal. If it passes, restore.
- Reduce data size: large dataset → small dataset → single record → minimal record.
- Remove unrelated modules, services, and configuration.
- Strip the reproducer down to the essential trigger.

A minimized reproducer narrows the cause space dramatically and makes every later phase faster. The smaller the reproducer, the faster the loop and the fewer places the bug can hide.

---

## Phase 3 — Hypothesize

Before touching any code, generate **3 to 5 ranked, falsifiable hypotheses** about the root cause.

### Format

Each hypothesis must be falsifiable and predict an observable consequence:

> **If X is the cause, then changing Y will make the bug disappear.**

Examples:

> If the off-by-one in the pagination offset is the cause, then incrementing the offset by 1 will make the bug disappear.
>
> If the race between the cache write and the DB commit is the cause, then adding a flush before the cache write will make the bug disappear.
>
> If the timezone mismatch in the timestamp comparison is the cause, then normalizing both timestamps to UTC will make the bug disappear.

### Rank them

Order hypotheses by a combination of:

- **Likelihood** — how well each explains the symptom and the minimized reproducer.
- **Cost to test** — how cheaply you can falsify each.
- **Severity if true** — prefer hypotheses that, if true, explain the most.

### Show the list to the user

Present the ranked list to the user before testing any hypothesis. This checkpoint prevents fixation on a single theory and lets the user contribute domain knowledge that may reorder the list.

Do not start probing until the list is written down and shared.

---

## Phase 4 — Instrument

Test hypotheses one at a time, with one probe per hypothesis.

### One variable at a time

Change exactly one thing per probe. If you change two variables and the bug disappears, you do not know which one mattered. Run the loop after each single change.

### One probe per hypothesis

For each hypothesis, add the minimal instrumentation needed to falsify it:

- A print/log statement at the suspected location.
- A breakpoint or interactive debugger session.
- A temporary assertion that checks the predicted condition.
- A metric or counter around the suspected code path.

### Tag debug instrumentation

Prefix every temporary debug log, print, or comment with a unique, searchable tag so cleanup is mechanical:

```
console.log("[DBG-BUG-42] cache write order:", order);
# [DBG-BUG-42] checking offset value
```

Use the same tag across all probes for this bug. In Phase 6 you grep for the tag and remove every match.

### For performance bugs: measure first, fix second

If the bug is a performance regression (slow, high memory, high CPU), **measure before you fix anything**:

1. Profile the minimized reproducer and record the baseline numbers.
2. Identify the hotspot the profile points to.
3. Form a hypothesis about *why* the hotspot is slow.
4. Apply the fix.
5. Re-profile and compare to the baseline.

Never "optimize" a performance bug without a before-and-after measurement. Without measurements you cannot prove the fix worked or that it did not regress something else.

---

## Phase 5 — Fix and regression test

### Write the regression test before the fix

If a correct seam exists (a public interface through which the bug is observable), write a regression test that reproduces the bug **before** applying the fix:

1. Write the test. Run it. Confirm it fails (red) — this is your loop from Phase 1, codified.
2. Apply the fix.
3. Run the test. Confirm it passes (green).
4. Run the full suite to check for regressions.

The regression test permanently guards against this bug returning.

### If no correct seam exists

If there is no public interface through which to write a regression test, **that is the finding**: the architecture prevents locking down the bug. Do not hack around it by exposing internals or testing private methods. Instead:

1. Note that the architecture lacks a testable seam for this behavior.
2. Apply the fix anyway (the bug still needs fixing).
3. Recommend a follow-up to introduce a proper seam so the behavior becomes testable. This may mean extracting a module, adding a public entry point, or introducing an adapter at a boundary.

The absence of a seam is a design debt to surface, not a reason to write a brittle test.

### Apply the minimal fix

Fix the root cause, not the symptom. The fix should be the smallest change that eliminates the cause identified in Phase 4. Do not bundle unrelated improvements into the fix.

---

## Phase 6 — Cleanup

The bug is not done until the codebase is clean and the fix is explained.

Verify all of the following:

- [ ] **Original reproducer no longer reproduces.** Run the exact loop from Phase 1. It now passes (green).
- [ ] **Regression test passes.** The test from Phase 5 is green and committed alongside the fix.
- [ ] **Full suite passes.** No regressions introduced.
- [ ] **Debug instrumentation removed.** Grep for the unique tag from Phase 4. Every match is deleted — no leftover prints, logs, or temporary assertions.
- [ ] **Throwaway prototypes deleted.** Any throwaway harness, spike script, or temporary reproducer file is removed (unless it became the regression test).
- [ ] **Correct hypothesis stated in the commit message.** The commit message names which hypothesis was confirmed and why, so the history explains the root cause, not just the fix.

Example commit message:

```
fix: correct pagination offset off-by-one in user list query

Root cause: the offset was computed as (page - 1) * size but page
is 1-indexed while the query expects 0-indexed, producing a
duplicate first row on page 2+.

Confirmed hypothesis #1 from debugging session. Regression test
added in test_user_pagination.py::test_no_duplicate_first_row.
```

---

## Summary of the six phases

| Phase | Goal | Completion signal |
|-------|------|-------------------|
| 1. Build feedback loop | A single, fast, deterministic, agent-runnable command that goes red | Loop command exists and reproduces |
| 2. Reproduce + minimize | Confirm exact symptom; shrink to smallest failing scenario | Minimal reproducer confirmed |
| 3. Hypothesize | 3-5 ranked falsifiable hypotheses, shown to user | Ranked list written and shared |
| 4. Instrument | One probe per hypothesis, one variable at a time, tagged | A hypothesis confirmed falsified or supported |
| 5. Fix + regression test | Regression test before fix; minimal root-cause fix | Test green, suite green |
| 6. Cleanup | Reproducer gone, test committed, instrumentation removed, cause documented | All cleanup checkboxes ticked |
