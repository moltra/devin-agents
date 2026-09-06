# Skills Quick Reference

Quick reference for available Devin skills and their usage.

## Available Skills

### Coordinator
**Command:** `/coordinator [task description]`

Orchestrates complex tasks by delegating to specialist subagents.

**Use when:**
- Multi-domain tasks
- Complex analysis needed
- Want to monitor each step

**Example:**
```
/coordinator Review the new API endpoint for security, performance, and code quality
```

### Python Reviewer
**Command:** `/python-reviewer [files or scope]`

Rigorous Python code review: bugs, style, patterns, error handling, type safety, performance.

**Example:**
```
/python-reviewer app/services/state.py
```

### Security Auditor
**Command:** `/security-auditor [files or scope]`

Security audit: secrets, input validation, auth, dependencies, data protection.

**Example:**
```
/security-auditor app/services/llm.py
```

### Redis Engineer
**Command:** `/redis-engineer [files or scope]`

Redis optimization: connection resilience, serialization, fallback strategies, performance, TTL.

**Example:**
```
/redis-engineer app/services/state.py
```

### Testing Guardian
**Command:** `/testing-guardian [files or scope]`

Test review: coverage, quality, mocking strategy, test patterns, performance.

**Example:**
```
/testing-guardian tests/
```

### Streamlit Expert
**Command:** `/streamlit-expert [files or scope]`

Streamlit review: session state, caching, performance, UI/UX, architecture.

**Example:**
```
/streamlit-expert app/streamlit/
```

### Git Workflow
**Command:** `/git-workflow [operation or scope]`

Git operations: commits, branches, PR preparation, workflow validation, history.

**Example:**
```
/git-workflow prepare for commit
```

### Ollama Testing
**Command:** `/ollama-testing [file or directory]`

Audit Ollama integration: streaming safety, timeout config, test isolation.

### Quick Review
**Command:** `/quick-review`

Quick pre-commit code review using SWE model (runs as subagent).

### Redis Resilience
**Command:** `/redis-resilience [file or directory]`

Audit Redis usage: connection resilience, fallback strategies, serialization safety.

## Usage Patterns

### Direct Specialist
```
/python-reviewer app/services/api.py
```

### Coordinator Orchestration
```
/coordinator Review the new API endpoint for security, performance, and code quality
```

### Progressive Enhancement
```
# Start with specialist
/python-reviewer app/services/complex.py

# Escalate if needed
/coordinator The review revealed issues spanning multiple domains. Please coordinate comprehensive review.
```

### Batch Processing
```
/coordinator Review all services in app/services/ for code quality, security, and performance
```

## Skill vs. Coordinator

| Situation | Use |
|-----------|-----|
| Single domain review | Direct specialist skill |
| Multi-domain task | Coordinator |
| Complex analysis | Coordinator |
| Quick domain check | Direct specialist skill |
| Systematic review | Coordinator |

## Task Structure

Provide structured context when invoking skills:

```
/coordinator Please review the Redis pagination implementation.

**Context:**
The pagination bug causes empty task lists when all keys arrive in a single SCAN batch.

**Requirements:**
- Identify root cause
- Propose fix following Redis best practices
- Handle single-batch and multi-batch scenarios

**Files:**
- app/services/state.py

**Success:**
- Pagination works for all batch sizes
- No performance regression

**Priority:** High
```

## Skill Locations

Skills are defined in `plugins/devin-agents/skills/<name>/SKILL.md`:
- `plugins/devin-agents/skills/coordinator/SKILL.md`
- `plugins/devin-agents/skills/python-reviewer/SKILL.md`
- `plugins/devin-agents/skills/security-auditor/SKILL.md`
- `plugins/devin-agents/skills/redis-engineer/SKILL.md`
- `plugins/devin-agents/skills/testing-guardian/SKILL.md`
- `plugins/devin-agents/skills/streamlit-expert/SKILL.md`
- `plugins/devin-agents/skills/git-workflow/SKILL.md`
- `plugins/devin-agents/skills/ollama-testing/SKILL.md`
- `plugins/devin-agents/skills/quick-review/SKILL.md`
- `plugins/devin-agents/skills/redis-resilience/SKILL.md`

## Related Documentation

- `patterns/skills-integration-patterns.md` — Detailed skills integration guide
- `patterns/coordinator-optimization-patterns.md` — Coordinator behavioral patterns
- `patterns/task-template-patterns.md` — Task construction templates
