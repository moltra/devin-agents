# Multi-Agent Delegation Patterns

This document describes delegation patterns for coordinating multiple specialist agents.

## Parallel Delegation Pattern

### Use Case
When multiple independent subtasks can be executed simultaneously.

### Pattern
```
coordinator → [specialist A, specialist B, specialist C] (parallel) → coordinator
```

### Implementation
```python
# Launch parallel subagents
subagent_ids = []
subagent_ids.append(run_subagent(
    title="Code Review",
    task="Review the code changes...",
    profile="python-reviewer",
    is_background=True
))

subagent_ids.append(run_subagent(
    title="Security Audit",
    task="Audit for security vulnerabilities...",
    profile="security-auditor",
    is_background=True
))

subagent_ids.append(run_subagent(
    title="Test Validation",
    task="Validate test coverage...",
    profile="testing-guardian",
    is_background=True
))

# Collect results
results = []
for agent_id in subagent_ids:
    result = read_subagent(agent_id, block=True)
    results.append(result)
```

### Benefits
- Faster execution for independent tasks
- Better resource utilization
- Reduced overall completion time

## Sequential Delegation Pattern

### Use Case
When subtasks depend on each other or must be executed in order.

### Pattern
```
coordinator → specialist A → specialist B → specialist C → coordinator
```

### Implementation
```python
# Sequential execution
result1 = run_subagent(
    title="Code Implementation",
    task="Implement the feature...",
    profile="python-developer",
    is_background=False
)

result2 = run_subagent(
    title="Code Review",
    task=f"Review this implementation: {result1}",
    profile="python-reviewer",
    is_background=False
)

result3 = run_subagent(
    title="Test Validation",
    task=f"Validate tests for: {result2}",
    profile="testing-guardian",
    is_background=False
)
```

### Benefits
- Ensures correct order of operations
- Allows each specialist to build on previous work
- Maintains dependencies between tasks

## Mixed Pattern

### Use Case
When some subtasks are independent, others depend on results.

### Pattern
```
coordinator → [specialist A, specialist B] (parallel) → specialist C → coordinator
```

### Implementation
```python
# Parallel phase
parallel_results = []
parallel_results.append(run_subagent(
    title="Code Review",
    task="Review code...",
    profile="python-reviewer",
    is_background=True
))

parallel_results.append(run_subagent(
    title="Security Audit",
    task="Audit security...",
    profile="security-auditor",
    is_background=True
))

# Wait for parallel phase
for agent_id in parallel_results:
    read_subagent(agent_id, block=True)

# Sequential phase depends on parallel results
final_result = run_subagent(
    title="Git Commit",
    task="Commit changes after review and audit...",
    profile="git-workflow",
    is_background=False
)
```

### Benefits
- Optimizes for both parallel and sequential dependencies
- Reduces overall completion time while maintaining correctness
- Flexible for complex workflows

## Specialist Selection Pattern

### Use Case
Choosing the right specialist for a given task.

### Pattern
```python
TASK_TO_SPECIALIST = {
    "api": "api-specialist",
    "ui": "streamlit-expert",
    "cache": "redis-engineer",
    "llm": "ollama-specialist",
    "security": "security-auditor",
    "test": "testing-guardian",
    "git": "git-workflow",
    "docker": "devops-docker",
    "custom": "<your-specialist>"
}

def select_specialist(task_type):
    return TASK_TO_SPECIALIST.get(task_type, "python-reviewer")
```

## Error Handling Pattern

### Specialist Failure Handling

```python
# Launch subagents with error handling
subagent_ids = []
for task in tasks:
    try:
        agent_id = run_subagent(
            title=task.title,
            task=task.description,
            profile=task.profile,
            is_background=True
        )
        subagent_ids.append(agent_id)
    except Exception as e:
        logger.error(f"Failed to launch subagent: {e}")
        # Handle failure or escalate

# Collect results with error handling
results = []
for agent_id in subagent_ids:
    try:
        result = read_subagent(agent_id, block=True, timeout=300)
        results.append(result)
    except Exception as e:
        logger.error(f"Failed to read subagent result: {e}")
        results.append({"error": str(e)})
```

### Conflicting Recommendations

```python
# Detect and resolve conflicts
recommendations = []
for result in results:
    recommendations.extend(result.get("recommendations", []))

# Group by affected component
by_component = {}
for rec in recommendations:
    component = rec.get("component")
    if component not in by_component:
        by_component[component] = []
    by_component[component].append(rec)

# Detect conflicts
conflicts = []
for component, recs in by_component.items():
    if len(recs) > 1:
        # Check for conflicting recommendations
        actions = [r.get("action") for r in recs]
        if len(set(actions)) > 1:
            conflicts.append({
                "component": component,
                "conflicting_actions": actions
            })

# Resolve or escalate
if conflicts:
    for conflict in conflicts:
        logger.warning(f"Conflict detected: {conflict}")
        # Apply resolution strategy or escalate to user
```

## Result Synthesis Pattern

### Cross-Cutting Issues

```python
# Identify issues that span multiple domains
cross_cutting_issues = []
for result in results:
    for issue in result.get("issues", []):
        if issue.get("scope") == "cross-cutting":
            cross_cutting_issues.append(issue)

# Prioritize cross-cutting issues
if cross_cutting_issues:
    final_report["cross_cutting"] = cross_cutting_issues
```

### Priority Ordering

```python
# Order action items by priority
action_items = []
for result in results:
    action_items.extend(result.get("action_items", []))

# Sort by priority (critical > warning > info)
priority_order = {"critical": 0, "warning": 1, "info": 2}
action_items.sort(key=lambda x: priority_order.get(x.get("severity"), 3))

final_report["action_items"] = action_items
```

## Customization Notes

When customizing these patterns for your project:

1. **Add project-specific specialist mappings** for your domain
2. **Include project-specific error handling strategies** for your infrastructure
3. **Add project-specific conflict resolution patterns** for your team
4. **Include project-specific result synthesis patterns** for your outputs
5. **Add project-specific timeout patterns** based on your task characteristics
6. **Add project-specific escalation procedures** for your team structure
