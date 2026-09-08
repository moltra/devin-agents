# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this plugin, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, email the maintainer directly or use GitHub's private vulnerability reporting:

1. Go to https://github.com/moltra/devin-agents/security/advisories/new
2. Describe the vulnerability with steps to reproduce
3. Include the affected file(s) and line numbers if possible

You will receive a response within 48 hours.

## Scope

This policy covers:
- The plugin manifest (`plugin.json`)
- Agent profiles (`agents/*/AGENT.md`)
- Skills (`skills/*/SKILL.md`)
- Rules (`rules/*.md`)
- Install scripts (`scripts/`)
- Templates (`templates/`)

## Agent Permission Security

This plugin ships agent profiles with `exec` and `write` tool permissions.
These are necessary for the agents to perform their work (run tests, edit
files, execute build tools). Before installing any agent profile, review
its `allowed-tools` and `permissions` blocks to ensure they match your
security requirements.

To restrict an agent:
- Remove tools from its `allowed-tools` list
- Add `deny` patterns to its `permissions` block
- Disable the agent entirely (see CUSTOMIZATION.md)

## Install Script Safety

The install scripts (`install-agents.sh`, `install-agents.ps1`) clone the
repo and copy agent/skill profiles into your Devin config. Always review
the content of agent profiles before installing them. The scripts accept
`REPO_URL` and `REPO_BRANCH` environment overrides — only use trusted
sources.

## Secrets

Never commit API keys, tokens, passwords, or other secrets to this
repository. The plugin profiles are designed to be generic and should
not contain any credentials.
