---
name: git-workflow
description: Git operations, branch management, and commit validation
argument-hint: "[operation or scope]"
agent: git-workflow
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

Handle git operations and workflow tasks:

1. **Commit management**
   - Commit message quality and format
   - Commit scope and granularity
   - Staging appropriate files
   - Commit history cleanliness

2. **Branch management**
   - Branch naming conventions
   - Branch strategy adherence
   - Merge conflict resolution
   - Branch cleanup

3. **Code review preparation**
   - PR description quality
   - Diff clarity
   - Contextual information
   - Reviewer assignment

4. **Workflow validation**
   - Pre-commit hook compliance
   - CI/CD pipeline readiness
   - Integration branch suitability
   - Release preparation

5. **History maintenance**
   - Squash commits when appropriate
   - Fixup commit usage
   - Rebase safety
   - History rewriting risks

## Operation
$ARGUMENTS

If no operation is specified, assess the current git state and provide recommendations.

## Output Format
Provide:
- Current git status summary
- Specific action recommendations
- Command examples where applicable
- Risk assessments for destructive operations
- Workflow improvement suggestions
