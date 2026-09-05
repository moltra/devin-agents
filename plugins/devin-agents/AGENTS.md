# devin-agents Plugin — Always-On Rule

This plugin bundles a multi-agent team (25 subagent profiles + 26 skills) for use
across Devin CLI and Devin Desktop sessions. It is installed at the user level and
available in every project.

## Coordinator-first workflow

For any non-trivial task (code changes, multi-file work, testing, architecture, or
delegation), the root agent MUST spawn the `global_coordinator` subagent at the
start of the session and route the work through it. `global_coordinator` detects
the project language/stack and delegates to the appropriate language-specific
coordinator (`rust_coordinator`, `python_coordinator`, or the generic
`coordinator`).

Trivial tasks (single-file edits, quick lookups, answering questions) may be
handled directly unless the user asks otherwise.

Do not duplicate planning or implementation work that `global_coordinator` and its
delegates will perform.

## Available subagent profiles

The plugin ships these custom subagent profiles (invoke by name via `run_subagent`):

**Coordinators:** `global_coordinator`, `coordinator`, `python_coordinator`,
`rust_coordinator`, `planner`

**Implementation:** `python-developer`, `api-specialist`, `streamlit-expert`,
`redis-engineer`, `ollama-specialist`, `devops-docker`, `rust-developer`,
`herdr-board-specialist`, `devin-cli-integration`

**Quality & safety:** `python-reviewer`, `rust-reviewer`, `swe-check`,
`security-auditor`, `testing-guardian`, `qa-ci-agent`, `architecture-reviewer`,
`video-pipeline-reviewer`

**Workflow & docs:** `git-workflow`, `documentation-agent`, `playwright-testing`

## Automatic sub-agent recommendation

When the agent detects **repeated, unscoped, or cross-cutting work** that no
existing subagent profile cleanly covers, it MUST invoke the
`/devin-agents:subagent-recommender` skill before attempting the work inline.

Signals that trigger a recommendation:

- The same kind of task has been delegated 3+ times in a session with no matching
  specialist profile.
- A task spans multiple unrelated files/domains that would benefit from a focused,
  isolated context.
- The agent is about to do broad exploratory or implementation work that doesn't
  fit any existing profile's stated scope.
- A user explicitly asks for a new specialist ("we need a ___ agent").

The skill produces a proposed `AGENT.md` definition (name, description, model,
allowed-tools, system prompt) and a matching `SKILL.md` if appropriate. The agent
presents the proposal to the user for approval before writing any files. Proposed
profiles are written to the project's `.devin/agents/<name>/AGENT.md` (or the
global `~/.config/devin/agents/<name>/AGENT.md` if the user prefers a global
profile).

Never silently create a sub-agent. Always propose, get approval, then create.

## Verification pipeline

After implementation, the coordinator runs this verification pipeline before
human review:

1. `swe-check` — non-Python bug detection
2. tests — run the project's test suite
3. `security-auditor` — secret detection and vulnerability scan
4. `qa-ci-agent` — lint, typecheck, CI gates
5. `python-reviewer` (Python) or `rust-reviewer` (Rust) — language-specific review
6. `architecture-reviewer` — structural consistency (when scope warrants it)
7. Human review — required before merging into `main`
