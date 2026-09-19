# devin-agents Plugin — Always-On Rule

This plugin bundles a multi-agent team (22 subagent profiles + 29 skills) for use
across Devin CLI and Devin Desktop sessions. It is installed at the user level and
available in every project.

## Coordinator-first workflow

For any non-trivial task (code changes, multi-file work, testing, architecture, or
delegation), the root agent MUST spawn the `global_coordinator` subagent at the
start of the session and route the work through it. `global_coordinator` detects
the project language/stack and delegates to the appropriate language-specific
coordinator (`python_coordinator`, or the generic `coordinator` for unsupported
languages).

Trivial tasks (single-file edits, quick lookups, answering questions) may be
handled directly unless the user asks otherwise.

If subagent tools are unavailable (`subagents_enabled` or `disabled_tools` in
config, or org policy), skip the coordinator routing and handle the task
directly.

Do not duplicate planning or implementation work that `global_coordinator` and its
delegates will perform.

## Available subagent profiles

The plugin ships these custom subagent profiles (invoke by name via `run_subagent`):

**Coordinators:** `global_coordinator`, `coordinator`, `python_coordinator`,
`planner`

**Implementation:** `python-developer`, `api-specialist`, `streamlit-expert`,
`redis-engineer`, `ollama-specialist`, `devops-docker`

**Quality & safety:** `python-reviewer`, `swe-check`,
`security-auditor`, `testing-guardian`, `qa-ci-agent`, `architecture-reviewer`,
`best-practices-reviewer`, `feature-verifier`

**Workflow & docs:** `git-workflow`, `documentation-agent`, `playwright-testing`

**Meta:** `subagent-curator` — reviews, edits, creates, and audits sub-agent
profiles; enforces consistency, genericity, and minimum-access principles

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
presents the proposal to the user for approval. On approval, the
`subagent-curator` agent creates and validates the profile. Proposed profiles are
written to the project's `.devin/agents/<name>/AGENT.md` (or the global
`~/.config/devin/agents/<name>/AGENT.md` if the user prefers a global profile).

Never silently create a sub-agent. Always propose, get approval, then create via
the curator.

## Continuous agent improvement

The agent ecosystem is self-improving. The `subagent-recommender` skill is the
**sensor** that detects gaps; the `subagent-curator` agent is the **actuator**
that reviews, edits, and creates profiles. The
`rules/continuous-improvement.md` rule ties them together.

Improvement triggers:

- A session used 5+ subagent calls → suggest a lightweight audit
- The same subagent needed 3+ corrections → its profile needs refinement
- A coverage gap was detected → the recommender proposes, the curator creates
- A stale reference or genericity drift was found → the curator fixes it
- The user requests an audit or improvement cycle

To run an improvement cycle: `/devin-agents:subagent-curator improve`
To run a full audit: `/devin-agents:subagent-curator audit`
To edit a specific profile: `/devin-agents:subagent-curator edit <name>`

## Verification pipeline

After implementation, the coordinator runs this verification pipeline before
human review:

1. `swe-check` — non-Python bug detection
2. tests — run the project's test suite
3. `security-auditor` — secret detection and vulnerability scan
4. `qa-ci-agent` — lint, typecheck, CI gates
5. `python-reviewer` (Python) — language-specific review
6. `architecture-reviewer` — structural consistency (when scope warrants it)
7. Human review — required before merging into `main`

## Coordinator logging

Two complementary mechanisms write to `.devin/logs/` in the project:

- **Automatic** — the plugin's `hooks.json` logs `run_subagent` /
  `read_subagent` calls and `PostCompaction` events to
  `.devin/logs/devin-agents.log`. Requires no agent action; fail-open where
  plugin hooks are unsupported.
- **Manual** — `scripts/log_coordinator.sh <action> <details>` appends to
  `.devin/logs/coordinator.log` (actions: plan, delegate, integrate, verify,
  commit, decision, recovery, cleanup, escalation). To enable it in a
  project, copy the script to `.devin/hooks/log_coordinator.sh` — the path
  coordinator profiles call. They skip logging silently when it is absent.

## Recommended settings

For delegation-heavy sessions, prefer **Smart** permission mode where your
build offers it (`/mode smart` or Shift+Tab; `/smart` on CLI >= v3000.10.21):
routine commands auto-approve while destructive ones still prompt, and
background subagents — which cannot prompt for permissions — stall less.

## Runtime compatibility

- **Minimum CLI v3000.3.22** — plugin-contributed subagents (`agents/`),
  rules, and root `hooks.json` require it.
- **>= v3000.5.20** — `devin doctor` frontmatter validation (run by
  `qa-ci-agent` when the CLI is on PATH) and `DEVIN_PLUGIN_ROOT` for plugin
  hook commands. On older versions hooks still load but resolve no plugin
  root, so logging quietly no-ops.
- **>= v3000.10.21** — `tool_provenance` in `PreToolUse` payloads (logged
  when present, `n/a` before) and specific `allow` rules carving out of a
  broad `ask`. Profiles keep explicit `Exec(...)` allow entries because
  older versions still require them — revisit pruning only if the minimum
  supported version moves to >= v3000.10.21.
