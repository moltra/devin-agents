# Skills Integration Patterns

This document describes how to use Devin skills to enhance subagent orchestration and coordinator workflows.

## Overview

Skills are reusable prompts and workflows that extend the agent's capabilities. They can be invoked via slash commands (`/skill-name`) or autonomously by the agent. Skills can run as subagents with their own context window, making them ideal for specialist tasks.

## Available Skills

### Coordinator Skill
**Invocation:** `/coordinator [task description]`

The coordinator skill orchestrates complex tasks by delegating to specialist subagents. It uses the custom `coordinator` subagent profile defined in `templates/coordinator-template.md`.

**Use when:**
- Task involves multiple technical domains
- You need explicit specialist selection
- Task is ambiguous and needs analysis
- You want to monitor each step

**Example:**
```
/coordinator Review the recent changes to the Redis pagination code and ensure it follows best practices
```

### Specialist Skills

#### Python Reviewer
**Invocation:** `/python-reviewer [files or scope]`

Performs rigorous Python code review focusing on logic errors, style patterns, error handling, type safety, and performance.

**Example:**
```
/python-reviewer app/services/state.py
```

#### Security Auditor
**Invocation:** `/security-auditor [files or scope]`

Performs comprehensive security audit including secret detection, input validation, authentication/authorization, dependency vulnerabilities, and data protection.

**Example:**
```
/security-auditor app/services/llm.py
```

#### Redis Engineer
**Invocation:** `/redis-engineer [files or scope]`

Reviews and optimizes Redis integration including connection resilience, serialization patterns, fallback strategies, performance patterns, and TTL management.

**Example:**
```
/redis-engineer app/services/state.py
```

#### Testing Guardian
**Invocation:** `/testing-guardian [files or scope]`

Reviews test coverage and quality including coverage gaps, test quality, mocking strategy, test patterns, and test performance.

**Example:**
```
/testing-guardian tests/
```

#### Streamlit Expert
**Invocation:** `/streamlit-expert [files or scope]`

Reviews Streamlit applications including session state management, caching strategy, performance optimization, UI/UX patterns, and architecture.

**Example:**
```
/streamlit-expert app/streamlit/
```

#### Git Workflow
**Invocation:** `/git-workflow [operation or scope]`

Handles git operations and workflow tasks including commit management, branch management, code review preparation, workflow validation, and history maintenance.

**Example:**
```
/git-workflow prepare for commit
```

#### Ollama Testing
**Invocation:** `/ollama-testing [file or directory]`

Audits Ollama integration for streaming safety, timeout configuration, and test isolation.

#### Quick Review
**Invocation:** `/quick-review`

Quick pre-commit code review using the SWE model (runs as subagent).

#### Redis Resilience
**Invocation:** `/redis-resilience [file or directory]`

Audits Redis usage for connection resilience, fallback strategies, and serialization safety.

## Skill Architecture

### Coordinator Skill
The coordinator skill uses the `agent: coordinator` field to run as a custom subagent profile. This gives it:
- Access to `run_subagent` and `read_subagent` tools
- The coordinator system prompt from `templates/coordinator-template.md`
- Ability to orchestrate other specialist skills
- Optimization principles from `patterns/coordinator-optimization-patterns.md`

### Specialist Skills
Specialist skills run inline by default but can be invoked by the coordinator. They provide:
- Domain-specific expertise
- Structured review patterns
- Consistent output formats
- Best practice enforcement

## Usage Patterns

### Pattern 1: Direct Specialist Invocation
Use when you need a specific domain review without coordination.

```
/python-reviewer app/services/api.py
```

### Pattern 2: Coordinator Orchestration
Use when task requires multiple domains or complex analysis.

```
/coordinator Review the new API endpoint implementation for security, performance, and code quality
```

The coordinator will:
1. Analyze the task
2. Identify relevant specialists (security-auditor, python-reviewer, api-specialist)
3. Delegate to each specialist in parallel
4. Synthesize results into a unified report

### Pattern 3: Progressive Enhancement
Start with direct skill invocation, escalate to coordinator if needed.

```
# First attempt
/python-reviewer app/services/complex.py

# If issues span multiple domains, escalate
/coordinator The review revealed issues that also affect Redis caching and security. Please coordinate a comprehensive review.
```

### Pattern 4: Batch Processing
Use coordinator to review multiple components systematically.

```
/coordinator Review all services in app/services/ for code quality, security, and performance issues
```

## Skill Configuration

### Frontmatter Fields

Each skill uses the following frontmatter:

```yaml
---
name: skill-name              # Skill identifier for /skill-name invocation
description: Brief description # Shown in completions
argument-hint: "[scope]"       # Usage hint
triggers:                      # How skill can be invoked
  - user                       # User can invoke with /skill-name
  - model                      # Agent can invoke autonomously
---
```

### Coordinator Skill Special Fields

The coordinator skill uses additional fields:

```yaml
---
agent: coordinator            # Use custom subagent profile
---
```

This references the `agents/coordinator/AGENT.md` profile which includes:
- Coordinator system prompt
- Tool permissions (run_subagent, read_subagent)
- Specialist mappings
- Optimization principles

### Skill Location

Skills are stored in `plugins/devin-agents/skills/<name>/SKILL.md` for broad compatibility with the `.agents` skills standard. This location:
- Follows the `.agents` skills standards
- Is supported by third-party skill installation tools
- Is tool-agnostic (not specific to Devin or Windsurf)
- Is committed to git for sharing

## Integration with Existing Patterns

### Task Templates
Skills work seamlessly with task templates from `patterns/task-template-patterns.md`. When invoking skills, provide structured task descriptions:

```
/coordinator Please review the Redis pagination implementation.

**Context:**
The pagination bug causes empty task lists when all keys arrive in a single SCAN batch.

**Requirements:**
- Identify the root cause
- Propose a fix following Redis best practices
- Ensure the fix handles both single-batch and multi-batch scenarios

**Files:**
- app/services/state.py

**Success:**
- Pagination works for all batch sizes
- No performance regression
- Follows Redis patterns from patterns/redis-patterns.md

**Priority:** High
```

### Optimization Patterns
The coordinator skill automatically applies optimization principles from `patterns/coordinator-optimization-patterns.md`:
- Parallel delegation for independent tasks
- Comprehensive task instructions
- Autonomous decision-making
- Progressive enhancement
- Timeout management

### Delegation Patterns
Skills implement the structural patterns from `patterns/delegation-patterns.md`:
- Parallel delegation for independent reviews
- Sequential delegation for dependent tasks
- Mixed patterns for complex workflows
- Specialist selection based on domain

## Customization

### Adding New Specialist Skills

To add a new specialist skill:

1. Create `plugins/devin-agents/skills/<specialist-name>/SKILL.md`
2. Add the skill to the coordinator's specialist list in `templates/coordinator-template.md`
3. Add skill-specific patterns to the appropriate patterns document
4. Update this documentation

Example:

```markdown
---
name: database-expert
description: Database schema, query optimization, and migration review
argument-hint: "[files or scope]"
triggers:
  - user
  - model
---

Review database-related code focusing on:
- Schema design
- Query optimization
- Index usage
- Migration safety
- Connection pooling

## Review Scope
$ARGUMENTS

## Output Format
[Structured report format]
```

### Modifying Coordinator Behavior

To modify coordinator behavior:
1. Edit `templates/coordinator-template.md` for system prompt changes
2. Edit `patterns/coordinator-optimization-patterns.md` for behavioral changes
3. Edit `plugins/devin-agents/skills/coordinator/SKILL.md` for skill-level changes

## Skill vs. Direct Subagent

### Use Skills When
- You want reusable, domain-specific workflows
- You need consistent output formats
- You want slash command access
- You're building a library of specialist knowledge

### Use Direct Subagents When
- Task is one-off and doesn't need reusability
- You need complete control over the system prompt
- Task doesn't fit a domain pattern
- You're experimenting with new approaches

## Best Practices

1. **Start with skills** for common domain tasks
2. **Use coordinator** for multi-domain tasks
3. **Provide context** when invoking skills (use task templates)
4. **Review skill output** and provide feedback for improvement
5. **Customize skills** for project-specific needs

## Troubleshooting

### Skill Not Found
Ensure skill files are in `plugins/devin-agents/skills/<name>/SKILL.md` and the directory name matches the skill name.

### Coordinator Not Working
Verify that `agents/coordinator/AGENT.md` exists and is properly configured with the coordinator template.

### Specialist Not Available
Add the specialist to the coordinator's specialist list in `templates/coordinator-template.md`.

## Related Documentation

- `patterns/coordinator-optimization-patterns.md` — Coordinator behavioral patterns
- `patterns/coordinator-quick-reference.md` — Quick reference for coordinator behavior
- `patterns/task-template-patterns.md` — Task construction templates
- `patterns/delegation-patterns.md` — Structural delegation patterns
- `templates/coordinator-template.md` — Coordinator agent template
