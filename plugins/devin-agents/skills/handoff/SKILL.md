---
name: handoff
description: Compact the current conversation into a handoff document so another agent or session can continue the work seamlessly.
argument-hint: "[what the next session will focus on]"
triggers:
  - user
  - model
---

You are the handoff skill. Your job is to compress the current conversation
into a structured handoff document that lets another agent or session pick
up the work with minimal context loss.

## Purpose

Conversations get long. Context windows fill up. Sessions need to switch
agents. When any of these happen, a structured handoff prevents lost
context — the next session doesn't have to re-read the entire history or
re-derive decisions that were already made.

A handoff is a **pointer to context**, not a re-implementation of it. It
references existing artifacts (specs, plans, commits, diffs) by path
rather than duplicating their contents.

## Process

1. **Summarize what was being worked on.** Capture the goal, the current
   state, what's done, and what's remaining. Be concrete: name the
   feature, the files, the branch.

2. **List key decisions made and their rationale.** Only the decisions
   that a future session would need to understand — not every minor
   choice. For each, note *why* it was decided, not just *what* was
   decided.

3. **List files touched and their current state.** For each file: was it
   created, modified, or deleted? Is it committed or uncommitted? Is it
   in-progress or complete?

4. **List any blockers or open questions.** Things that are unresolved,
   waiting on input, or known-broken. A future session needs to know
   where the landmines are.

5. **Suggest which skills or agents the next session should use.** Based
   on what's remaining, point to the relevant skills (e.g.
   `/devin-agents:grilling` if the plan still has gaps,
   `/devin-agents:coordinator` if implementation is next) or subagent
   profiles.

6. **Note any environment state.** Current git branch, running services,
   environment variables set, ports in use, containers started — anything
   that isn't obvious from the repo itself.

## Rules

- **Save to the OS temp directory, not the workspace.** Use `$TMPDIR`,
  falling back to `/tmp` if unset. Never write handoff documents into the
  project repository — they're session artifacts, not project files.
  Filename format: `handoff-<YYYYMMDD-HHMMSS>.md`.

- **Do not duplicate content already in artifacts.** If a spec exists at
  `PLAN.md`, reference it by path. If a commit captures a decision,
  reference the commit hash. If a diff shows the current state, point to
  the branch. The handoff document should be lean.

- **Redact any sensitive information.** API keys, passwords, tokens,
  personally identifiable information — never include these in the
  handoff. Replace with `[REDACTED]` or a description like "the API key
  from the environment."

- **Tailor to the next session's focus.** If `$ARGUMENTS` was provided,
  weight the handoff toward what the next session will actually work on.
  Don't spend equal space on completed background work and the active
  task — emphasize the active task.

- **Keep it concise.** A handoff that's longer than the conversation it
  summarizes has failed its purpose. Aim for a document a new agent can
  read in under two minutes and know exactly where to start.

## Output

Produce a markdown handoff document with this structure:

```
# Handoff: [task title]

## Goal
[What was being worked on — 1-2 sentences]

## Current State
- Done: [completed items]
- In progress: [active items]
- Remaining: [todo items]

## Key Decisions
- [Decision]: [rationale] (ref: [artifact path or commit hash])

## Files
- [path] — [created/modified/deleted], [committed/uncommitted], [state]

## Blockers & Open Questions
- [Unresolved item or question]

## Environment
- Branch: [name]
- Running services: [list or "none"]
- Other: [env vars, ports, containers, etc.]

## Suggested Next Steps
- Skills/agents to use: [recommendations]
- First action: [what to do first]
```

Save the file to the temp directory and **report its absolute path to the
user** so they can pass it to the next session:

```
Handoff document saved to: /tmp/handoff-20250115-143022.md
```
