---
trigger: always
description: Continuous improvement loop for the agent ecosystem — detects when profiles need refinement and routes to the subagent-curator for review, editing, and creation.
---

# Continuous Agent Improvement

The agent ecosystem is not static. Profiles accumulate drift, references
go stale, and recurring work patterns emerge that need new specialists.
This rule keeps the ecosystem self-improving.

## When to trigger improvement

Invoke the `/devin-agents:subagent-curator` skill (which routes to the
`subagent-curator` agent) when ANY of these signals appear during a
session:

### Automatic triggers

1. **High subagent usage**: A session used 5+ `run_subagent` calls.
   Suggest a lightweight audit to check if profiles need refinement.

2. **Repeated corrections**: The same subagent needed 3+ corrections in
   one session (wrong scope, wrong approach, missing context). Its
   profile likely needs clearer instructions or tighter boundaries.

3. **Coverage gap detected**: The `subagent-recommender` skill fired and
   proposed a new profile. Route the proposal to the curator for proper
   creation and validation.

4. **Stale reference found**: Any profile references an agent that does
   not exist in the current ecosystem. The curator should fix or remove
   the reference.

5. **Genericity drift**: A profile contains project-specific content
   (paths, names, env vars, file layouts) that should be generic. The
   curator should generalize it.

6. **Scope overlap**: Two profiles have scopes that cause routing
   confusion. The curator should clarify boundaries or merge profiles.

### Manual triggers

7. **User request**: The user asks for an audit, improvement, or new
   profile creation.

8. **Post-session review**: The user wants to review and improve the
   agent ecosystem after a work session.

## Improvement workflow

When a trigger fires:

1. **Detect**: The root agent or coordinator notices a trigger signal.
2. **Recommend**: If the trigger is a coverage gap, the
   `subagent-recommender` skill drafts a proposal.
3. **Curate**: Route to the `subagent-curator` agent to:
   - Audit the affected profiles
   - Propose specific improvements
   - Present changes for approval
4. **Apply**: On user approval, the curator applies the changes.
5. **Validate**: The curator re-checks counts, references, and JSON.
6. **Commit**: If working in a repo, the coordinator commits the changes.

## Improvement cadence

- **Lightweight audit**: After any session with 5+ subagent calls, the
  coordinator should suggest running `/devin-agents:subagent-curator
  improve` to catch drift early.
- **Full audit**: When the user requests it, or when major changes have
  been made to the agent ecosystem (profiles added, removed, or
  renamed).
- **Targeted review**: When a specific profile is causing issues, run
  `/devin-agents:subagent-curator edit <name>`.

## What the curator checks

- **Consistency**: frontmatter, naming, model, tools, output format
- **Genericity**: no project-specific content in plugin profiles
- **Quality**: clear scope, explicit boundaries, structured reporting
- **Coverage**: no gaps, no overlaps, no stale references

## Relationship to the recommender

| Role | Skill | Agent | Action |
|------|-------|-------|--------|
| Detect gaps | `subagent-recommender` | (parent) | Proposes new profiles |
| Review/edit/create | `subagent-curator` | `subagent-curator` | Audits, edits, creates |
| Route work | (coordinator) | `global_coordinator` | Decides when to trigger each |

The recommender is the **sensor**; the curator is the **actuator**.
Together they form a closed-loop improvement system for the agent
ecosystem.
