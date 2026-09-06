---
name: tdd
description: Test-driven development discipline. Red-green-refactor loop with anti-pattern guidance.
argument-hint: "[feature or bug description]"
triggers:
  - user
  - model
---

You are practicing test-driven development (TDD). This skill enforces the red-green-refactor loop and guards against the anti-patterns that quietly erode its value. Use it whenever you are adding a feature, fixing a bug, or changing production code.

## The core loop

TDD is a three-step cycle repeated many times:

1. **Red** — Write exactly one test that captures a slice of the desired behavior. Run it. It must fail for the right reason (assertion failure or missing behavior), not for a trivial reason (import error, typo, wrong setup). If it fails for the wrong reason, fix the setup, not the assertion.
2. **Green** — Write the minimal production code that makes the failing test pass. No more, no less. Do not add speculative generality, extra parameters, or "while I'm here" changes.
3. **Refactor** — Improve the structure of both test and production code *without changing behavior*. The tests stay green the entire time. If a refactor breaks a test, revert and try a smaller step.

The cycle is **red → green → refactor**, then back to red. Never skip red. Never write production code before a failing test demands it.

## One slice at a time

Each cycle covers one vertical slice: one behavior, one test, one implementation. A "slice" is the smallest meaningful unit of behavior you can describe and verify.

- Write one test. Make it fail. Make it pass. Refactor. Repeat.
- Do not write a batch of tests and then a batch of implementation. That is horizontal slicing (see anti-patterns below).
- If a slice feels too large to test in one cycle, it is not one slice — split it.

### Vertical, not horizontal

**Vertical slicing** means each cycle delivers a thin end-to-end piece of behavior: the test exercises the public interface and the implementation behind it, together.

**Horizontal slicing** means writing all the tests for a layer, then all the implementation, then "integrating." This defers feedback, hides integration bugs until the end, and produces tests that do not guide the design.

Always slice vertically.

## What makes a good test

A good test:

- **Verifies behavior through the public interface.** It calls the same entry points real callers use. It does not reach into private helpers, internal state, or package-private symbols.
- **Reads like a specification.** A reader who has never seen the implementation should understand the required behavior from the test alone. Name the test after the behavior ("returns 404 when the user does not exist"), not after the method ("testGetUser").
- **Has one reason to fail.** Each test asserts one behavior. If it fails, the cause is obvious. If a test can fail for five different reasons, split it into five tests.
- **Is independent.** It does not depend on test execution order, shared mutable state, or external services left dirty by a previous test.
- **Uses expected values from an independent source.** The expected value must come from a known-good literal, a worked example, a specification, or a reference implementation — never from re-running the code under test (see "expected values" below).

## Seams: where to test

A **seam** is a pre-agreed public boundary where you test behavior. Test at seams, not at internals.

- Agree on the seam *before* writing the test. The seam is the contract; the internals are free to change.
- If you find yourself wanting to test a private method, the real problem is usually that the method deserves to be its own module with its own public interface. Extract it, then test it at its new seam.
- Never expose internals solely to make them testable. That widens the interface for no real consumer and couples tests to implementation.

## Expected values must be independent

The expected value in an assertion must come from an **independent source**, not from the system under test:

- A known-good literal (`assert add(2, 3) == 5`).
- A worked example from a spec, ticket, or documentation.
- A reference implementation or oracle you trust.
- A manually computed result you verified by hand.

**Never** derive the expected value by calling the same code you are testing. That is a tautology (see anti-patterns). If the only way to produce the expected value is to run the implementation, you do not have a test — you have a consistency check, which is far weaker.

## Anti-patterns

Recognize and reject these:

### Implementation-coupled tests
The test asserts on internal structure (private fields, call counts to collaborators, the shape of intermediate data) instead of observable behavior through the public interface. These tests break on every refactor and provide negative value. **Fix:** rewrite the test to assert on public behavior. If you cannot, the interface is too shallow — redesign it.

### Tautological tests
The expected value is computed by the same logic the implementation uses, so the test can only fail if both the test and the implementation are wrong in *different* ways. This is testing nothing. **Fix:** replace the expected value with an independent source (literal, spec, oracle).

### Horizontal slicing
Writing all tests first, then all implementation. Feedback arrives late, integration bugs hide, and the tests do not shape the design. **Fix:** switch to vertical slices — one test, one implementation, repeat.

### Testing the mock
The test sets up a mock to return a value, calls the code, and asserts the mock was called with that value. The test verifies the wiring, not the behavior. **Fix:** assert on the *result* or *observable effect*, not on which internal calls happened. Use mocks only at module boundaries to isolate external dependencies.

### Over-asserting
The test asserts on incidental details (exact log text, ordering of unrelated calls, formatting) that are not part of the contract. **Fix:** assert only on what the contract guarantees.

### Green without red
Writing the implementation first, then a test that passes. The test was never shown to fail, so you do not know it actually exercises the behavior. **Fix:** run the test before the implementation exists and watch it fail for the right reason.

## Refactoring belongs to the review stage

Refactoring is the **third** step, after green. It is not mixed into the red-green loop:

- During red and green, focus on making the test pass with the simplest possible code. Do not optimize, abstract, or restructure yet.
- During refactor, change structure only. Behavior is fixed by the green tests. If you are changing behavior, you are back in red-green, not refactoring.
- If a refactor is large, break it into small behavior-preserving steps, running the full suite after each step.

## When not to use TDD

- **Exploratory/spike work** where you do not yet know the interface. Throw the code away afterward; do not keep spike code as production code.
- **Pure refactoring** of existing code that already has a trustworthy test suite. Run the existing tests; do not write new ones unless you are changing behavior.
- **Trivial changes** with no behavior (formatting, renaming a local variable). Use judgment.

Even in these cases, once you touch behavior, return to the loop.

## Checklist for each cycle

- [ ] One test written, describing one behavior through the public interface.
- [ ] Test run and observed failing for the right reason (red).
- [ ] Minimal implementation written (green). No speculative generality.
- [ ] Full suite run and green.
- [ ] Refactoring done in behavior-preserving steps, suite green throughout.
- [ ] Expected value came from an independent source.
- [ ] No test couples to implementation internals.
- [ ] No test is tautological.
