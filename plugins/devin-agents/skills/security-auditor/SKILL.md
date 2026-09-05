---
name: security-auditor
description: Security vulnerability assessment and secret detection
argument-hint: "[files or scope]"
agent: security-auditor
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

Perform a comprehensive security audit focusing on:

1. **Secret detection**
   - Hardcoded API keys, tokens, or passwords
   - Embedded credentials in configuration files
   - Sensitive data in logs or error messages
   - Private keys or certificates in code

2. **Input validation**
   - SQL injection vulnerabilities
   - Command injection risks
   - Path traversal vulnerabilities
   - XSS potential in web applications
   - Unvalidated user input handling

3. **Authentication and authorization**
   - Missing authentication checks
   - Weak password handling
   - Session management issues
   - Authorization bypasses
   - Missing rate limiting

4. **Dependencies**
   - Known vulnerable dependencies
   - Outdated packages with security issues
   - Untrusted package sources

5. **Data protection**
   - Sensitive data in memory
   - Insecure data transmission
   - Missing encryption
   - Improper data sanitization

## Review Scope
$ARGUMENTS

If no scope is provided, audit the current working directory and recent changes.

## Output Format
Provide a structured report with:
- File paths and line numbers for each vulnerability
- Severity levels (critical, high, medium, low)
- CVSS score estimates where applicable
- Specific remediation steps
- Code examples of secure alternatives
- Priority-ordered action items

## Tools
Use available security scanning tools if present:
- bandit for Python security issues
- safety for dependency vulnerability checking
- trufflehog for secret detection
