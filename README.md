# Devin Desktop Automations - Agent Templates

A comprehensive collection of **generic agent templates and patterns** for Devin AI multi-agent systems. These templates provide a foundation for building specialized sub-agents while keeping project-specific knowledge private.

## Overview

This repository contains **generic agent templates, patterns, and documentation** that can be customized for any project. The templates are designed to be copied to your local Devin configuration and then adapted to your specific needs.

## Architecture

The system uses a hierarchical delegation pattern where a coordinator agent orchestrates specialized sub-agents for specific tasks. The ecosystem is self-improving via a sensor/actuator loop.

```mermaid
graph TD
    USER[User Request] --> GC{global_coordinator}
    GC -->|Python| PC[python_coordinator]
    GC -->|Other| COORD[coordinator<br/>generic fallback]
    GC -->|Planning| PL[planner]

    PC --> IMPL[Implementation Specialists]
    COORD --> IMPL
    IMPL --> QUAL[Quality & Safety]
    QUAL --> GW[git-workflow]
    GW --> REVIEW[Human Review]

    USER -.->|gap detected| SR[subagent-recommender<br/>sensor]
    SR -.->|proposes| SC[subagent-curator<br/>actuator]
    SC -.->|creates/edits| ECOSYSTEM[Agent Ecosystem]

    style GC fill:#ff6b6b,stroke:#c92a2a,stroke-width:2px,color:#fff
    style SR fill:#e599f7,stroke:#862e9c,stroke-width:2px,color:#fff
    style SC fill:#e599f7,stroke:#862e9c,stroke-width:2px,color:#fff
    style REVIEW fill:#fcc419,stroke:#e67700,stroke-width:2px,color:#000
```

See [agent-architecture.md](agent-architecture.md) for detailed diagrams (delegation flow, verification pipeline, improvement loop) and full agent/skill inventory.

### Available Templates

#### Coordinator
- **coordinator-template**: Main orchestrator for task delegation and synthesis

#### Code & Development
- **python-reviewer-template**: Code quality and review specialist
- **api-specialist-template**: API design and implementation
- **testing-guardian-template**: Test quality and validation

#### Infrastructure
- **streamlit-expert-template**: UI architecture and Streamlit applications
- **redis-engineer-template**: Caching strategies and Redis integration
- **ollama-specialist-template**: LLM integration and Ollama management
- **devops-docker-template**: Container orchestration and deployment

#### Security & Quality
- **security-auditor-template**: Security scanning and vulnerability assessment

#### Git Operations
- **git-workflow-template**: Branch management and commit workflows

## Repository Structure

```
.
├── templates/                 # Generic agent templates
│   ├── coordinator-template.md
│   ├── python-reviewer-template.md
│   ├── streamlit-expert-template.md
│   ├── redis-engineer-template.md
│   ├── ollama-specialist-template.md
│   ├── security-auditor-template.md
│   ├── git-workflow-template.md
│   └── etc.
├── patterns/                  # Generic patterns and workflows
│   ├── coordinator-optimization-patterns.md
│   ├── coordinator-quick-reference.md
│   ├── task-template-patterns.md
│   ├── task-templates-quick-reference.md
│   ├── skills-integration-patterns.md
│   ├── skills-quick-reference.md
│   ├── delegation-patterns.md
│   ├── streamlit-performance.md
│   └── redis-patterns.md
├── plugins/                   # Devin plugin (installable unit)
│   └── devin-agents/
│       ├── agents/            # 22 subagent profiles
│       ├── skills/            # 29 skills
│       ├── rules/             # 2 triggered rules
│       └── AGENTS.md          # always-on rule
├── scripts/                   # Utility scripts
│   ├── install-agents.sh
│   └── validate-agent.sh
├── agent-architecture.md      # Architecture documentation
├── CUSTOMIZATION.md           # How to customize templates
├── PLAN.md                    # Planning template
└── README.md                  # This file
```

## Devin Plugin (`plugins/devin-agents/`)

This repo also ships a **Devin plugin** at `plugins/devin-agents/` that bundles
the full multi-agent team into a single installable unit. The plugin merges every
unique agent and skill from the global Devin config (`~/.config/devin/`) and
project repos into one deduplicated, generic package.

### What the plugin includes

- **22 custom subagent profiles** (`agents/<name>/AGENT.md`) — coordinators,
  implementation specialists, reviewers, workflow agents, and a meta-agent
  (`subagent-curator`) that maintains the agent ecosystem itself.
- **29 skills** (`skills/<name>/SKILL.md`) — invokable skills including the
  `subagent-recommender` (detects coverage gaps and proposes new sub-agents),
  `subagent-curator` (reviews, edits, creates, and audits profiles), and 6
  process skills (`grilling`, `tdd`, `diagnosing-bugs`, `code-review`,
  `codebase-design`, `handoff`) adapted from engineering best practices.
- **Always-on rule** (`AGENTS.md`) — installs the coordinator-first workflow,
  the auto-recommend guidance, and the continuous improvement loop in every
  session.
- **Triggered rules** (`rules/`) — `subagent-recommender.md` prompts the agent
  to invoke the recommender skill when it sees repeated, unscoped, or
  cross-cutting work; `continuous-improvement.md` ties the recommender and
  curator together into a self-improving ecosystem.

### Plugin layout

```
plugins/devin-agents/
├── .devin-plugin/
│   └── plugin.json          # manifest
├── AGENTS.md                # always-on rule (coordinator workflow + improvement loop)
├── rules/
│   ├── subagent-recommender.md   # triggered rule: detect coverage gaps
│   └── continuous-improvement.md # triggered rule: ecosystem self-improvement
├── agents/                  # 22 subagent profiles
│   ├── global_coordinator/AGENT.md
│   ├── coordinator/AGENT.md
│   ├── subagent-curator/AGENT.md  # meta-agent: reviews/edits/creates profiles
│   └── … (19 more)
└── skills/                  # 29 skills
    ├── subagent-recommender/SKILL.md  # detect gaps, propose new sub-agents
    ├── subagent-curator/SKILL.md      # review/edit/create/audit profiles
    ├── grilling/SKILL.md              # pre-implementation interview
    ├── tdd/SKILL.md                   # red-green-refactor discipline
    ├── diagnosing-bugs/SKILL.md       # 6-phase debugging
    ├── code-review/SKILL.md           # two-axis review (standards + spec)
    ├── codebase-design/SKILL.md       # deep module design vocabulary
    ├── handoff/SKILL.md               # session continuity
    ├── coordinator/SKILL.md
    └── … (20 more)
```

### Install the plugin

```bash
# From the repo root
devin plugins install ./plugins/devin-agents

# Or from any location
devin plugins install /path/to/devin-agents/plugins/devin-agents
```

Local installs are linked, so edits to the plugin files apply on the next session
— no `update` needed. Verify with:

```bash
devin plugins list
devin plugins info devin-agents
```

### Using skills

Skills become available as `/devin-agents:<skill>` slash commands. Subagent
profiles are available to `run_subagent` by name.

**Process skills** run inline in the current conversation — the skill's
instructions are injected and the agent follows them directly:

```
/devin-agents:grilling I want to add a caching layer to the API
/devin-agents:tdd implement a cache wrapper with TTL support
/devin-agents:diagnosing-bugs the API returns 500 on large payloads
/devin-agents:code-review main
/devin-agents:codebase-design
/devin-agents:handoff next session should focus on integration tests
```

**Subagent-tied skills** spawn a specialist subagent with its own context
window, tools, and model. The parent agent waits for the result and
summarizes it:

```
/devin-agents:python-reviewer src/services/
/devin-agents:security-auditor
/devin-agents:architecture-reviewer
/devin-agents:testing-guardian tests/
```

You can also ask the agent to use a skill in natural language:
"I want to review this code" → the agent reaches for `/devin-agents:code-review`
"Debug this issue" → the agent reaches for `/devin-agents:diagnosing-bugs`

### Quick reference

**22 subagent profiles** (invoke by name via `run_subagent`):

| Category | Profile | Focus |
|----------|---------|-------|
| Coordinators | `global_coordinator` | Detects language/stack, delegates |
| | `coordinator` | Generic orchestrator |
| | `python_coordinator` | Python-specific orchestrator |
| | `planner` | Spec/PLAN.md production |
| Implementation | `python-developer` | FastAPI/Flask/Django backend |
| | `api-specialist` | REST endpoints, OpenAPI |
| | `streamlit-expert` | Streamlit UI, caching, reruns |
| | `redis-engineer` | Redis caching, resilience |
| | `ollama-specialist` | Ollama LLM, streaming |
| | `devops-docker` | Docker Compose, deployment |
| Quality | `python-reviewer` | Python code review |
| | `swe-check` | Non-Python bug detection |
| | `security-auditor` | Vulnerabilities, secrets |
| | `testing-guardian` | Test coverage, quality |
| | `qa-ci-agent` | CI/CD gates, lint, typecheck |
| | `architecture-reviewer` | Module boundaries, structure |
| | `best-practices-reviewer` | Cross-language code quality |
| | `feature-verifier` | Verify features match spec |
| Workflow | `git-workflow` | Branches, commits, merges |
| | `documentation-agent` | Docs, README, migration guides |
| | `playwright-testing` | E2E test creation |
| Meta | `subagent-curator` | Reviews/edits/creates profiles |

**29 skills** (invoke as `/devin-agents:<skill>`):

| Category | Skill | Description |
|----------|-------|-------------|
| Coordinator | `/devin-agents:coordinator` | Pure orchestration |
| Implementation | `/devin-agents:python-developer` | Python backend |
| | `/devin-agents:api-specialist` | API design |
| | `/devin-agents:streamlit-expert` | Streamlit UI |
| | `/devin-agents:redis-engineer` | Redis caching |
| | `/devin-agents:ollama-specialist` | Ollama integration |
| | `/devin-agents:devops-docker` | Docker/DevOps |
| Quality | `/devin-agents:python-reviewer` | Python review |
| | `/devin-agents:architecture-reviewer` | Architecture review |
| | `/devin-agents:security-auditor` | Security audit |
| | `/devin-agents:testing-guardian` | Test quality |
| | `/devin-agents:qa-ci-agent` | CI/CD gates |
| | `/devin-agents:swe-check` | Non-Python bugs |
| | `/devin-agents:best-practices-reviewer` | Cross-language quality |
| | `/devin-agents:feature-verifier` | Verify features match spec |
| Workflow | `/devin-agents:git-workflow` | Git operations |
| | `/devin-agents:documentation-agent` | Documentation |
| | `/devin-agents:playwright-testing` | Playwright tests |
| Audits | `/devin-agents:ollama-testing` | Ollama safety audit |
| | `/devin-agents:redis-resilience` | Redis resilience audit |
| | `/devin-agents:quick-review` | Quick pre-commit review |
| Meta | `/devin-agents:subagent-recommender` | Detect gaps, propose agents |
| | `/devin-agents:subagent-curator` | Review/edit/create/audit profiles |
| Process | `/devin-agents:grilling` | Pre-implementation interview |
| | `/devin-agents:tdd` | Red-green-refactor discipline |
| | `/devin-agents:diagnosing-bugs` | 6-phase debugging |
| | `/devin-agents:code-review` | Two-axis review (standards + spec) |
| | `/devin-agents:codebase-design` | Deep module design vocabulary |
| | `/devin-agents:handoff` | Session continuity |

### Automatic sub-agent recommendation

The plugin's `subagent-recommender` skill + rule makes Devin proactively suggest
new sub-agent profiles when it detects:

- The same task type handled inline 3+ times with no matching specialist
- Cross-cutting work that would benefit from an isolated context
- A coverage gap no existing profile fills
- An explicit user request for a new specialist

The skill drafts a complete `AGENT.md` (name, model, tools, system prompt) and
presents it for approval. On approval, the `subagent-curator` agent creates and
validates the profile.

### Continuous agent improvement

The plugin includes a self-improving ecosystem via two complementary components:

- **`subagent-recommender`** (sensor) — detects coverage gaps and proposes new
  profiles
- **`subagent-curator`** (actuator) — reviews, edits, creates, and audits
  profiles for consistency, genericity, quality, and coverage

The `continuous-improvement.md` rule ties them together with automatic triggers:

- 5+ subagent calls in a session → suggest a lightweight audit
- 3+ corrections to the same agent → its profile needs refinement
- Stale references or genericity drift → curator fixes them
- User request → run a full audit or improvement cycle

Usage:

```bash
/devin-agents:subagent-curator audit     # full ecosystem audit
/devin-agents:subagent-curator improve   # top improvements cycle
/devin-agents:subagent-curator edit <name>  # edit a specific profile
/devin-agents:subagent-curator create <name> # create a new profile
```

## Installation

### Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/moltra/devin-agents.git
   cd devin-agents
   ```

2. **Install templates to your local Devin config:**
   ```bash
   bash scripts/install-agents.sh
   ```

3. **Customize for your project:**
   - Edit agent configurations in `~/.config/devin/agents/`
   - Add project-specific patterns and knowledge
   - Adjust permissions and tool access
   - Update model assignments if needed

4. **Restart Devin** to load the new configurations

### Manual Installation

If you prefer manual installation:

```bash
# Copy agent templates
cp -r templates/* ~/.config/devin/agents/

# Install the plugin (recommended — includes all agents + skills)
devin plugins install ./plugins/devin-agents

# Make scripts executable
chmod +x scripts/*.sh
```

## Customization

### Project-Specific Customization

After installing the templates, you should customize them for your project:

1. **Add Project Knowledge:**
   - Add project-specific file paths
   - Include business logic patterns
   - Document internal architecture
   - Add configuration details

2. **Adjust Permissions:**
   - Add project-specific tool permissions
   - Configure file access patterns
   - Set up Docker/container permissions
   - Configure API access

3. **Update Models:**
   - Choose appropriate models for your use case
   - Adjust model parameters
   - Configure model-specific behaviors

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for detailed customization guidelines.

## Workflow Patterns

### Standard Development Workflow
```
coordinator → domain-specialist → python-reviewer → testing-guardian → security-auditor → coordinator
```

### API Development
```
coordinator → api-specialist → python-reviewer → testing-guardian → security-auditor → git-workflow
```

### Infrastructure Setup
```
coordinator → devops-docker → security-auditor → coordinator
```

### Performance Investigation
```
coordinator → subagent_explore → domain-specialist → python-reviewer → coordinator
```

## Key Design Principles

1. **Single Responsibility**: Each agent has a clear, focused domain
2. **Hierarchical Delegation**: Coordinator breaks down tasks, specialists execute
3. **Parallel Execution**: Independent subtasks run concurrently when possible
4. **Cross-Validation**: Code reviewed by multiple specialists
5. **Safe Operations**: Git and destructive operations have limited permissions
6. **Privacy First**: Project-specific knowledge stays in your local configuration

## Documentation

- [CUSTOMIZATION.md](CUSTOMIZATION.md): How to customize templates for your project
- [agent-architecture.md](agent-architecture.md): Multi-agent architecture documentation
- [patterns/coordinator-optimization-patterns.md](patterns/coordinator-optimization-patterns.md): Coordinator behavioral patterns for efficiency
- [patterns/coordinator-quick-reference.md](patterns/coordinator-quick-reference.md): Quick reference for coordinator behavior
- [patterns/task-template-patterns.md](patterns/task-template-patterns.md): Task construction templates
- [patterns/task-templates-quick-reference.md](patterns/task-templates-quick-reference.md): Quick reference for task templates
- [patterns/skills-integration-patterns.md](patterns/skills-integration-patterns.md): Skills integration guide
- [patterns/skills-quick-reference.md](patterns/skills-quick-reference.md): Quick reference for available skills
- [patterns/delegation-patterns.md](patterns/delegation-patterns.md): Structural delegation patterns
- [patterns/streamlit-performance.md](patterns/streamlit-performance.md): Streamlit optimization patterns
- [patterns/redis-patterns.md](patterns/redis-patterns.md): Redis integration patterns

## Contributing

When contributing new templates or patterns:

1. Keep them **generic and reusable** across projects
2. Remove any **project-specific information** (paths, configs, business logic)
3. Add **clear documentation** for customization
4. Update relevant documentation files
5. Test the template before submitting

## Privacy & Security

This repository contains **only generic templates and patterns**.

**What IS shared:**
- Generic agent configurations
- Reusable patterns and workflows
- Best practices and guidelines
- Documentation and examples

**What is NOT shared:**
- Project-specific file paths
- Business logic details
- Proprietary algorithms
- Internal architecture diagrams
- Configuration values (API keys, secrets)
- Custom agent implementations

Keep your project-specific customizations in your local `~/.config/devin/agents/` directory - these should never be committed to this repository.

## Feedback

Found a bug, have a feature request, or want to suggest a new agent profile?

[Open an issue on GitHub](https://github.com/moltra/devin-agents/issues/new/choose)

- **Bug reports** — describe what happened, what you expected, and how to reproduce
- **Feature requests** — describe the use case and what agent/skill would help
- **Agent proposals** — use the subagent-recommender skill, then share your proposal in an issue for inclusion in the plugin
- **General feedback** — all feedback welcome

Please include:
- Your Devin CLI version (`devin --version`)
- The plugin version (`devin plugins info devin-agents`)
- Steps to reproduce (for bugs)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues or questions:
1. Review [CUSTOMIZATION.md](CUSTOMIZATION.md) for guidance
2. Check the [agent-architecture.md](agent-architecture.md) for architecture details
3. Open an issue on GitHub for template-specific problems
test
