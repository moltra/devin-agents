---
name: Bug Report
about: Report a bug in the devin-agents plugin
title: "[BUG] "
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to report a bug!
  - type: textarea
    id: description
    attributes:
      label: Description
      description: What happened? What did you expect?
    validations:
      required: true
  - type: textarea
    id: reproduce
    attributes:
      label: Steps to reproduce
      description: How can we reproduce the issue?
    validations:
      required: true
  - type: input
    id: devin-version
    attributes:
      label: Devin CLI version
      description: Run `devin --version`
    validations:
      required: true
  - type: input
    id: plugin-version
    attributes:
      label: Plugin version
      description: Run `devin plugins info devin-agents`
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Relevant logs
      description: Paste any relevant log output
---

## Description
<!-- What happened? What did you expect? -->

## Steps to reproduce
<!-- How can we reproduce the issue? -->

## Environment
- Devin CLI version: 
- Plugin version: 

## Logs
<!-- Paste any relevant log output -->
