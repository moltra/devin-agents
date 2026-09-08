---
name: Feature Request
about: Suggest a new agent, skill, or improvement
title: "[FEATURE] "
labels: ["enhancement"]
body:
  - type: textarea
    id: use-case
    attributes:
      label: Use case
      description: What problem does this solve?
    validations:
      required: true
  - type: textarea
    id: proposal
    attributes:
      label: Proposed solution
      description: What agent, skill, or change do you propose?
    validations:
      required: true
  - type: dropdown
    id: type
    attributes:
      label: Type
      options:
        - New agent profile
        - New skill
        - Improvement to existing agent/skill
        - Documentation
        - Other
    validations:
      required: true
---

## Use case
<!-- What problem does this solve? -->

## Proposed solution
<!-- What agent, skill, or change do you propose? -->

## Type
<!-- New agent, new skill, improvement, documentation, or other -->
