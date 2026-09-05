---
name: python-reviewer
description: Rigorous Python code review for bugs, style, and patterns
argument-hint: "[files or scope]"
agent: python-reviewer
triggers:
  - user
  - model
allowed-tools:
  - read
  - grep
  - glob
  - exec
permissions:
  allow:
    - Exec(true)
    - Exec(/bin/true)
    - Exec(/usr/bin/true)
    - Exec(cp *)
---

Perform a rigorous Python code review focusing on:

1. **Logic errors and bugs**
   - Incorrect conditionals or loop logic
   - Off-by-one errors
   - Missing edge case handling
   - Race conditions or concurrency issues

2. **Code style and patterns**
   - PEP 8 compliance
   - Pythonic idioms vs. non-Pythonic code
   - Appropriate use of data structures
   - Function and class design patterns

3. **Error handling**
   - Missing exception handling
   - Overly broad exception catches
   - Proper error propagation
   - Resource cleanup (finally blocks, context managers)

4. **Type safety**
   - Type hints where appropriate
   - Potential type errors
   - Missing type annotations for complex functions

5. **Performance considerations**
   - Inefficient algorithms or data structures
   - Unnecessary computations
   - Memory leaks or excessive memory usage
   - I/O optimization opportunities

## Review Scope
$ARGUMENTS

If no scope is provided, review the current working directory and recent changes.

## Output Format
Provide a structured report with:
- File paths and line numbers for each issue
- Severity levels (critical, warning, info)
- Specific recommendations for fixes
- Code examples where helpful
- Priority-ordered action items
