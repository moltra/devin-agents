# Customizing Agent Templates

This guide explains how to customize the generic agent templates for your specific project while keeping your project knowledge private.

## Overview

The templates in this repository are designed to be **generic starting points**. After installation, you should customize them for your specific project needs in your local `~/.config/devin/agents/` directory.

## Customization Workflow

### Step 1: Install Templates

```bash
# Clone repository
git clone https://github.com/moltra/devin-agents.git
cd devin-agents

# Install to your local config
bash scripts/install-agents.sh
```

### Step 2: Customize for Your Project

Edit the agent files in `~/.config/devin/agents/` to add your project-specific knowledge.

### Step 3: Test and Validate

```bash
# Validate your customized agents
bash scripts/validate-agent.sh ~/.config/devin/agents/
```

## Disabling Individual Agents

Not every project needs every agent profile that the plugin ships. You can
disable individual agents without uninstalling the entire plugin using any of
the methods below.

### Method 1: Project-level override

Create a `.devin/agents/<name>/AGENT.md` file in your project that overrides
the plugin's agent. To disable an agent, create a minimal profile that does
nothing:

```markdown
---
name: <agent-name>
description: Disabled
---
This profile is disabled.
```

### Method 2: Remove from plugin (if installed locally)

If you installed the plugin from a local folder, you can delete or rename the
agent's directory:

```bash
# Disable the ollama-specialist agent
mv ~/.config/devin/plugins/devin-agents/agents/ollama-specialist ~/.config/devin/plugins/devin-agents/agents/ollama-specialist.disabled
```

Changes apply on the next session.

### Method 3: Fork the plugin

For permanent changes, fork the plugin repo and remove the agent directories
you don't need. This is the cleanest approach for teams.

### Method 4: Disable all subagents

To disable ALL subagents (not just plugin ones), set in
`~/.config/devin/config.json`:

```json
{
  "subagents_enabled": false
}
```

This removes the `run_subagent` and `read_subagent` tools entirely.

### Note on skills

Disabling agents does NOT affect skills. Skills are invoked explicitly via
`/<plugin>:<skill>` commands and will still work even if their matching agent
is disabled. However, skills that use `agent: <name>` to run as a subagent
will fall back to the default subagent profile if the named agent is not
available.

## Customization Areas

### 1. Project Knowledge

Add project-specific information to agent templates:

#### Example: Python Developer Agent

**Generic Template:**
```markdown
## Tech Stack
- Python 3.12+
- FastAPI
- Streamlit
- Redis
```

**Customized for Your Project:**
```markdown
## Tech Stack
- Python 3.12+
- FastAPI (your project uses version X.Y)
- Streamlit (your project uses version A.B)
- Redis (your project uses db 5, not db 0)
- Custom internal libraries
```

#### Example: Adding Project File Structure

```markdown
## Project-Specific File Structure
- `app/controllers/` - Your API endpoints
- `app/services/` - Your business logic
- `frontend/` - Your Streamlit application
- `internal/` - Your internal utilities
```

### 2. Permissions Configuration

Add project-specific tool and file permissions:

#### Example: Docker Permissions

**Generic Template:**
```yaml
permissions:
  allow:
    - Exec(git diff*)
    - Exec(git log*)
```

**Customized for Your Project:**
```yaml
permissions:
  allow:
    - Exec(git diff*)
    - Exec(git log*)
    - Exec(docker logs myapp-*)
    - Exec(docker restart myapp-*)
    - Write(/path/to/your/project/**)
```

#### Example: File Access Patterns

```yaml
permissions:
  allow:
    - Read(/path/to/your/project/**)
    - Write(/path/to/your/project/app/**)
    - Edit(/path/to/your/project/frontend/**)
```

### 3. Model Selection

Agent profiles do **not** pin a `model:` field by default. Instead, they
inherit the **default subagent model**, which admins can configure centrally
via org/enterprise settings. This keeps model choices consistent across all
agents and lets you upgrade models in one place.

To override the default for a specific agent, add a `model:` line to that
agent's `AGENT.md` frontmatter. Valid values include: `swe`, `opus`, `sonnet`,
`haiku`, `codex`, `gemini`, `gpt`.

#### Example: Model Configuration

**Generic Template (inherits default):**
```yaml
---
# model: <omit to inherit the default subagent model; set to override>
```

**Customized for Your Project (override for one agent):**
```yaml
---
model: swe  # Override the default for this agent only
# or
model: sonnet  # Use a higher-reasoning model for this agent only
```

### 4. Project-Specific Patterns

Add patterns specific to your project:

#### Example: Configuration Access

**Generic Template:**
```markdown
## Configuration
- Read config via environment variables
- Support multiple configuration sources
```

**Customized for Your Project:**
```markdown
## Configuration
- Read config via `from myproject.config import config`
- Access with `config.app.get("key", default_value)`
- Your project uses specific config file format
- Custom configuration validation patterns
```

#### Example: Error Handling

**Generic Template:**
```markdown
## Error Handling
- Use specific exceptions
- Log errors before raising
```

**Customized for Your Project:**
```markdown
## Error Handling
- Use custom `MyProjectException` from `myproject.exceptions`
- Always include `request_id` in error responses
- Use your project's logging format
- Follow your project's error reporting patterns
```

### 5. Integration Patterns

Add project-specific integration patterns:

#### Example: Database Integration

**Generic Template:**
```markdown
## Database Integration
- Support multiple databases
- Use connection pooling
```

**Customized for Your Project:**
```markdown
## Database Integration
- Your project uses PostgreSQL with specific ORM
- Connection string format: `postgresql://user:pass@host/db`
- Your project has specific migration patterns
- Custom query optimization patterns
```

## Common Customization Examples

### Example 1: Web Application Project

**Customizations needed:**
- Add web framework specifics (Django, Flask, FastAPI)
- Add database patterns (SQLAlchemy, Django ORM)
- Add authentication/authorization patterns
- Add API endpoint patterns
- Add frontend integration patterns

### Example 2: Data Science Project

**Customizations needed:**
- Add data processing patterns (pandas, numpy)
- Add ML model integration patterns
- Add data visualization patterns
- Add experiment tracking patterns
- Add deployment patterns (MLflow, etc.)

### Example 3: DevOps Project

**Customizations needed:**
- Add infrastructure-as-code patterns (Terraform, Ansible)
- Add CI/CD pipeline patterns
- Add monitoring and alerting patterns
- Add container orchestration patterns
- Add cloud provider specifics

## Privacy Guidelines

### What to Keep Private

**Never commit to the shared repository:**
- Project-specific file paths
- Business logic details
- Proprietary algorithms
- Internal architecture diagrams
- API keys, secrets, or credentials
- Configuration values
- Custom implementation details
- Company-specific patterns

### What Can Be Shared

**Safe to contribute back:**
- Generic patterns that work across projects
- Best practices and guidelines
- Documentation improvements
- Bug fixes in templates
- New generic templates
- Performance optimization patterns

## Validation

After customization, validate your agents:

```bash
# Validate agent syntax
bash scripts/validate-agent.sh ~/.config/devin/agents/

# Test agent functionality
# (specific to your project)
```

## Version Control

### Your Local Configuration

Your customized agents in `~/.config/devin/agents/` should be version controlled separately:

```bash
# Initialize git in your local config (optional)
cd ~/.config/devin/agents
git init
git add .
git commit -m "Initial project-specific agent configuration"
```

### Keeping Templates Updated

When the shared repository is updated:

```bash
# Pull latest templates
cd devin-agents
git pull

# Review changes
git diff HEAD~1

# Manually merge relevant changes to your local config
# (be careful not to overwrite your customizations)
```

## Examples

### Example: Customizing Streamlit Expert

**Original Template:**
```markdown
## Core Expertise
1. Session state management
2. Caching strategy
3. Rerun performance
4. UI patterns
```

**Customized Version:**
```markdown
## Core Expertise
1. Session state management
   - Your project uses specific session state keys
   - Custom state initialization patterns
2. Caching strategy
   - Your project uses specific TTL values
   - Custom cache invalidation patterns
3. Rerun performance
   - Your project has specific performance requirements
   - Custom optimization patterns
4. UI patterns
   - Your project uses specific component library
   - Custom styling patterns
```

### Example: Customizing Security Auditor

**Original Template:**
```markdown
## Security Focus
- Secret detection
- Input validation
- Dependency scanning
```

**Customized Version:**
```markdown
## Security Focus
- Secret detection
  - Your project's specific secret patterns
  - Custom secret locations
- Input validation
  - Your project's validation framework
  - Custom validation rules
- Dependency scanning
  - Your project's dependency sources
  - Custom scanning patterns
```

## Troubleshooting

### Common Issues

**Issue:** Agent not working after customization
- **Solution:** Validate agent syntax with validation script
- **Solution:** Check that permissions are correctly configured
- **Solution:** Verify model assignments are valid

**Issue:** Customizations lost after template update
- **Solution:** Always backup your customizations before updating
- **Solution:** Use git to track your local changes
- **Solution:** Manually merge template updates

**Issue:** Agent has too much/little access
- **Solution:** Review and adjust permissions in agent configuration
- **Solution:** Test with minimal permissions first
- **Solution:** Add permissions incrementally

## Best Practices

1. **Start with templates, then customize** - Don't modify templates directly
2. **Keep customizations minimal** - Only add what's necessary for your project
3. **Document your changes** - Add comments explaining project-specific customizations
4. **Test thoroughly** - Validate customized agents before use
5. **Version control locally** - Track your customizations separately
6. **Share improvements** - Contribute generic improvements back to the shared repository

## Manually Creating Sub-Agents

This section explains how to add your own custom subagent profiles, either with
the bundled scaffold script or by hand.

### 1. Using the scaffold script

The repository ships with `scripts/create-agent.sh`, which scaffolds a new
subagent profile from a template. The script:

- Takes the agent name as a required argument (kebab-case).
- Accepts an optional description with `-d`.
- Accepts an optional target directory with `-t` (default: `.devin/agents/` for
  project-level agents).
- Optionally creates a matching `SKILL.md` with `-s`.
- Shows help with `-h`.

```bash
# Project-level agent with a description and a matching skill
./scripts/create-agent.sh my-reviewer -d "Reviews code for issues" -s

# Global agent installed to the user Devin config
./scripts/create-agent.sh data-analyst -d "Analyzes data patterns" -t ~/.config/devin/agents/
```

The generated `AGENT.md` contains YAML frontmatter (`name`, `description`,
`allowed-tools`) and a system prompt with the sections described below. It does
**not** include a `model:` field, so the agent inherits the default subagent
model. Edit the placeholder text in each section to tailor the agent to your
needs.

### 2. Manual creation

If you prefer to create the profile by hand, follow these steps.

#### Choose a location

Decide where the agent should live:

- **Project-level:** `.devin/agents/<name>/AGENT.md` — scoped to the current
  repository and version-controlled alongside the project.
- **Global:** `~/.config/devin/agents/<name>/AGENT.md` — available across all
  projects for the current user.

#### Create the directory and AGENT.md file

```bash
# Project-level
mkdir -p .devin/agents/my-reviewer
touch .devin/agents/my-reviewer/AGENT.md

# Global
mkdir -p ~/.config/devin/agents/my-reviewer
touch ~/.config/devin/agents/my-reviewer/AGENT.md
```

#### Required frontmatter fields

Every `AGENT.md` starts with YAML frontmatter. The required fields are:

- `name` — the agent identifier in kebab-case.
- `description` — a short summary of what the agent does.
- `allowed-tools` — the list of tools the agent may use. Common values:
  `read`, `grep`, `glob`, `exec`, `edit`, `write`.

```yaml
---
name: my-reviewer
description: Reviews code for issues
allowed-tools:
  - read
  - grep
  - glob
  - exec
---
```

#### Optional fields

- `model` — omit to inherit the default subagent model (recommended). Set to
  `swe`, `opus`, `sonnet`, `haiku`, `codex`, `gemini`, or `gpt` to override for
  this agent only. See the [Model Selection](#3-model-selection) section above
  for details.
- `max-nesting` — include only if this agent needs to spawn its own subagents.
  Omit it for leaf agents that do not delegate further.

#### System prompt structure

The body of `AGENT.md` is the system prompt. Use these sections to keep prompts
focused and consistent across agents:

```markdown
# My Reviewer

## Role
<Describe the specialist's role>

## Scope
<What files/domains this agent works on>

## What it does
<Specific tasks this agent handles>

## What it must NOT do
<Boundaries to prevent scope creep>

## Reporting format
<How this agent reports results back to the parent>
```

#### Optionally create a matching SKILL.md

If the agent should be invokable as a skill, create a `SKILL.md` alongside it
(or in the plugin's `skills/` directory, or the project's `.devin/skills/`
directory):

```markdown
---
name: my-reviewer
description: Reviews code for issues
triggers:
  - user
  - model
---

# My Reviewer Skill

<Instructions for the agent when this skill is invoked>
```

### 3. Validating the profile

After creating the agent, confirm it loads correctly:

```bash
# Verify the plugin picks up the new agent
devin plugins info devin-agents
```

Alternatively, start a new Devin session and check whether the agent appears in
the available profiles. You can also run the validation script against the
target directory:

```bash
bash scripts/validate-agent.sh .devin/agents/
```

### 4. Best practices

- **Minimum-access principle:** Grant only the tools and file access the agent
  needs. Start with `read`, `grep`, `glob`, and `exec`, then add more only when
  required.
- **Use kebab-case names:** Agent names must be lowercase with hyphens
  (for example, `my-reviewer`, not `MyReviewer`).
- **Avoid conflicts with built-in profiles:** Do not reuse the built-in profile
  names `subagent_explore` or `subagent_general`.
- **Keep system prompts focused:** Each agent should have one clear
  responsibility. Use the Role and Scope sections to bound what the agent does,
  and the "What it must NOT do" section to prevent scope creep.
- **Inherit the default model:** Omit `model:` unless the agent has a specific
  reason to use a different model. This keeps model choices consistent and
  easy to upgrade centrally.

## Support

For customization help:
1. Review this documentation
2. Check examples in the `patterns/` directory
3. Open an issue for template-specific problems
4. Share generic improvements via pull requests
