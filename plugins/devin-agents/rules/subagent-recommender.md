---
trigger: always
description: Prompt the agent to recommend a new sub-agent profile when it detects repeated, unscoped, or cross-cutting work that no existing profile covers.
---

# Sub-Agent Recommendation Trigger

When you notice ANY of these signals during a session, invoke the
`/devin-agents:subagent-recommender` skill BEFORE attempting the work inline:

1. **Repeated unscoped work** — you've handled the same kind of task 3+ times
   this session and no specialist profile fits it cleanly.
2. **Cross-cutting scope** — a task spans multiple unrelated files or domains
   that would benefit from a focused, isolated context window.
3. **Coverage gap** — you're about to do work outside every existing profile's
   stated scope, and the work is likely to recur.
4. **Explicit request** — the user asks for a new specialist ("we need a ___
   agent", "create a specialist for ___").

The skill will inventory existing profiles, prove the gap is real, draft a
complete `AGENT.md` (and optional `SKILL.md`), and present it for your approval
before writing any files.

Do NOT silently create sub-agent profiles. Always propose first, get approval,
then create.
