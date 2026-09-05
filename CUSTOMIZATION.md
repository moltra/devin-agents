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
- `webui/` - Your Streamlit application
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
    - Edit(/path/to/your/project/webui/**)
```

### 3. Model Selection

Choose appropriate models for your use case:

#### Example: Model Configuration

**Generic Template:**
```yaml
---
model: glm-5-2-high
```

**Customized for Your Project:**
```yaml
---
model: glm-5-2-high  # For complex tasks
# or
model: kimi-k2-7    # For focused tasks
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

## Support

For customization help:
1. Review this documentation
2. Check examples in the `patterns/` directory
3. Open an issue for template-specific problems
4. Share generic improvements via pull requests
