# Devin Multi-Agent Architecture

## Ecosystem Overview

```mermaid
graph TD
    %% Entry point
    ROOT[Root Agent / User]
    
    %% Global Coordinator
    GC[global_coordinator<br/>detects language/stack]
    
    %% Language coordinators
    subgraph COORDINATORS [Coordinator Layer]
        PC[python_coordinator<br/>Python projects]
        COORD[coordinator<br/>generic fallback]
        PL[planner<br/>spec & PLAN.md]
    end
    
    %% Implementation specialists
    subgraph IMPLEMENTATION [Implementation Specialists]
        PD[python-developer<br/>backend logic]
        API[api-specialist<br/>REST & OpenAPI]
        ST[streamlit-expert<br/>UI architecture]
        RE[redis-engineer<br/>caching & resilience]
        OL[ollama-specialist<br/>LLM integration]
        DD[devops-docker<br/>containers & deploy]
    end
    
    %% Quality & safety
    subgraph QUALITY [Quality & Safety]
        PR[python-reviewer<br/>code review]
        SW[swe-check<br/>non-Python bugs]
        SA[security-auditor<br/>vuln & secrets]
        TG[testing-guardian<br/>test quality]
        QA[qa-ci-agent<br/>CI/CD gates]
        AR[architecture-reviewer<br/>structure]
    end
    
    %% Workflow & docs
    subgraph WORKFLOW [Workflow & Docs]
        GW[git-workflow<br/>branches & commits]
        DA[documentation-agent<br/>docs & guides]
        PW[playwright-testing<br/>E2E tests]
    end
    
    %% Meta
    subgraph META [Meta — Self-Improving]
        SR[subagent-recommender<br/>sensor: detects gaps]
        SC[subagent-curator<br/>actuator: reviews/edits/creates]
    end
    
    %% Delegation flow
    ROOT -->|non-trivial task| GC
    GC -->|Python| PC
    GC -->|other languages| COORD
    GC -->|planning needed| PL
    
    PC -->|delegates| IMPLEMENTATION
    COORD -->|delegates| IMPLEMENTATION
    PL -->|produces specs| COORDINATORS
    
    %% Verification pipeline
    IMPLEMENTATION -.->|verify| QUALITY
    QUALITY -.->|commit| GW
    GW -.->|document| DA
    
    %% Improvement loop
    ROOT -.->|coverage gap| SR
    SR -.->|proposes profile| SC
    SC -.->|audits ecosystem| META
    
    %% Styling
    classDef root fill:#845ef7,stroke:#5f3dc4,stroke-width:3px,color:#fff
    classDef coord fill:#ff6b6b,stroke:#c92a2a,stroke-width:2px,color:#fff
    classDef impl fill:#4dabf7,stroke:#1864ab,stroke-width:2px,color:#fff
    classDef qual fill:#51cf66,stroke:#2b8a3e,stroke-width:2px,color:#fff
    classDef work fill:#fcc419,stroke:#e67700,stroke-width:2px,color:#000
    classDef meta fill:#e599f7,stroke:#862e9c,stroke-width:2px,color:#fff
    
    class ROOT root
    class GC,PC,COORD,PL coord
    class PD,API,ST,RE,OL,DD impl
    class PR,SW,SA,TG,QA,AR qual
    class GW,DA,PW work
    class SR,SC meta
```

## Delegation Flow

```mermaid
flowchart LR
    USER[User Request] --> GC{global_coordinator}
    
    GC -->|pyproject.toml / .py| PC[python_coordinator]
    GC -->|Cargo.toml / .rs| COORD[coordinator<br/>generic fallback]
    GC -->|package.json / .ts| COORD
    GC -->|other| COORD
    
    PC --> DECIDE{What kind<br/>of work?}
    COORD --> DECIDE
    
    DECIDE -->|API endpoints| API[api-specialist]
    DECIDE -->|backend logic| PD[python-developer]
    DECIDE -->|UI / Streamlit| ST[streamlit-expert]
    DECIDE -->|caching / Redis| RE[redis-engineer]
    DECIDE -->|LLM / Ollama| OL[ollama-specialist]
    DECIDE -->|Docker / deploy| DD[devops-docker]
    DECIDE -->|E2E tests| PW[playwright-testing]
    DECIDE -->|git ops| GW[git-workflow]
    DECIDE -->|docs| DA[documentation-agent]
```

## Verification Pipeline

```mermaid
flowchart LR
    IMPL[Implementation<br/>Complete] --> SW[swe-check<br/>non-Python bugs]
    SW --> TESTS[Project<br/>test suite]
    TESTS --> SA[security-auditor<br/>secrets & vulns]
    SA --> QA[qa-ci-agent<br/>lint & typecheck]
    QA --> PR[python-reviewer<br/>code review]
    PR --> AR[architecture-reviewer<br/>structure check]
    AR --> REVIEW[Human Review<br/>required before merge]
    
    style REVIEW fill:#ff6b6b,stroke:#c92a2a,stroke-width:3px,color:#fff
```

## Continuous Improvement Loop

```mermaid
flowchart TD
    subgraph TRIGGERS [Improvement Triggers]
        T1[5+ subagent calls<br/>in a session]
        T2[3+ corrections to<br/>same agent]
        T3[Coverage gap<br/>detected]
        T4[Stale reference<br/>or genericity drift]
        T5[User requests<br/>audit/improvement]
    end
    
    T1 --> SENSOR
    T2 --> SENSOR
    T3 --> SENSOR
    T4 --> SENSOR
    T5 --> SENSOR
    
    SENSOR[subagent-recommender<br/>SENSOR — detects & proposes] --> APPROVE{User<br/>approves?}
    APPROVE -->|yes| ACTUATOR[subagent-curator<br/>ACTUATOR — creates/edits/validates]
    APPROVE -->|no| END1[Discard proposal]
    
    T4 --> ACTUATOR
    T5 --> ACTUATOR
    
    ACTUATOR --> AUDIT[Audit ecosystem<br/>consistency, genericity,<br/>quality, coverage]
    AUDIT --> BACKLOG[Improvement<br/>backlog]
    BACKLOG --> APPLY{Apply<br/>changes?}
    APPLY -->|yes| WRITE[Write profiles<br/>validate & commit]
    APPLY -->|no| DEFER[Defer to<br/>next cycle]
    
    style SENSOR fill:#e599f7,stroke:#862e9c,stroke-width:2px,color:#fff
    style ACTUATOR fill:#e599f7,stroke:#862e9c,stroke-width:2px,color:#fff
    style APPROVE fill:#fcc419,stroke:#e67700,stroke-width:2px,color:#000
    style APPLY fill:#fcc419,stroke:#e67700,stroke-width:2px,color:#000
```

## Agent Inventory

| Category | Agent | Model | Focus |
|----------|-------|-------|-------|
| **Coordinators** | `global_coordinator` | swe-1-7-high | Detects language/stack, delegates |
| | `coordinator` | swe-1-7-high | Generic orchestrator |
| | `python_coordinator` | swe-1-7-high | Python-specific orchestrator |
| | `planner` | swe-1-7-high | Spec/PLAN.md production (no implementation) |
| **Implementation** | `python-developer` | swe-1-7-high | FastAPI/Flask/Django backend |
| | `api-specialist` | swe-1-7-medium | REST endpoints, validation, OpenAPI |
| | `streamlit-expert` | swe-1-7-medium | Streamlit UI, caching, reruns |
| | `redis-engineer` | swe-1-7-medium | Redis caching, serialization, fallback |
| | `ollama-specialist` | swe-1-7-medium | Ollama LLM, streaming, structured output |
| | `devops-docker` | swe-1-7-medium | Docker Compose, deployment, health |
| **Quality** | `python-reviewer` | swe-1-7-medium | Python code review (bugs, style, types) |
| | `swe-check` | swe-1-7-medium | Non-Python bug detection |
| | `security-auditor` | swe-1-7-medium | Vulnerabilities, secret detection |
| | `testing-guardian` | swe-1-7-medium | Test coverage, quality, mocking |
| | `qa-ci-agent` | swe-1-7-medium | CI/CD gates, lint, typecheck |
| | `architecture-reviewer` | swe-1-7-medium | Module boundaries, dependency graph |
| | `best-practices-reviewer` | swe-1-7-medium | Cross-language code quality |
| | `feature-verifier` | swe-1-7-medium | Verify features match spec |
| **Workflow** | `git-workflow` | swe-1-7-medium | Branch management, commits, merges |
| | `documentation-agent` | swe-1-7-medium | README, API docs, migration guides |
| | `playwright-testing` | swe-1-7-medium | E2E test creation and maintenance |
| **Meta** | `subagent-curator` | swe-1-7-high | Reviews/edits/creates agent profiles |

## Skill Inventory

| Category | Skill | Slash Command | Description |
|----------|-------|---------------|-------------|
| **Coordinator** | `coordinator` | `/devin-agents:coordinator` | Pure orchestration |
| **Implementation** | `python-developer` | `/devin-agents:python-developer` | Python backend |
| | `api-specialist` | `/devin-agents:api-specialist` | API design |
| | `streamlit-expert` | `/devin-agents:streamlit-expert` | Streamlit UI |
| | `redis-engineer` | `/devin-agents:redis-engineer` | Redis caching |
| | `ollama-specialist` | `/devin-agents:ollama-specialist` | Ollama integration |
| | `devops-docker` | `/devin-agents:devops-docker` | Docker/DevOps |
| **Quality** | `python-reviewer` | `/devin-agents:python-reviewer` | Python review |
| | `architecture-reviewer` | `/devin-agents:architecture-reviewer` | Architecture review |
| | `security-auditor` | `/devin-agents:security-auditor` | Security audit |
| | `testing-guardian` | `/devin-agents:testing-guardian` | Test quality |
| | `qa-ci-agent` | `/devin-agents:qa-ci-agent` | CI/CD gates |
| | `swe-check` | `/devin-agents:swe-check` | Non-Python bugs |
| | `best-practices-reviewer` | `/devin-agents:best-practices-reviewer` | Cross-language quality |
| | `feature-verifier` | `/devin-agents:feature-verifier` | Verify features match spec |
| **Workflow** | `git-workflow` | `/devin-agents:git-workflow` | Git operations |
| | `documentation-agent` | `/devin-agents:documentation-agent` | Documentation |
| | `playwright-testing` | `/devin-agents:playwright-testing` | Playwright tests |
| **Audits** | `ollama-testing` | `/devin-agents:ollama-testing` | Ollama safety audit |
| | `redis-resilience` | `/devin-agents:redis-resilience` | Redis resilience audit |
| | `quick-review` | `/devin-agents:quick-review` | Quick pre-commit review |
| **Meta** | `subagent-recommender` | `/devin-agents:subagent-recommender` | Detect gaps, propose agents |
| | `subagent-curator` | `/devin-agents:subagent-curator` | Review/edit/create/audit profiles |
| **Process** | `grilling` | `/devin-agents:grilling` | Pre-implementation interview |
| | `tdd` | `/devin-agents:tdd` | Red-green-refactor discipline |
| | `diagnosing-bugs` | `/devin-agents:diagnosing-bugs` | 6-phase debugging |
| | `code-review` | `/devin-agents:code-review` | Two-axis review (standards + spec) |
| | `codebase-design` | `/devin-agents:codebase-design` | Deep module design vocabulary |
| | `handoff` | `/devin-agents:handoff` | Session continuity |

## Workflow Patterns

### API Development
```
global_coordinator → python_coordinator → api-specialist (design)
  → python-reviewer (review) → testing-guardian (validate)
  → security-auditor (scan) → qa-ci-agent (gates) → git-workflow (commit)
```

### UI Development
```
global_coordinator → python_coordinator → streamlit-expert (UI)
  → python-reviewer (review) → testing-guardian (validate)
  → security-auditor (scan) → coordinator (synthesize)
```

### Infrastructure Setup
```
global_coordinator → coordinator → devops-docker (containers)
  → security-auditor (scan) → coordinator (synthesize)
```

### Git Workflow
```
coordinator → git-workflow (branch/commit)
  → python-reviewer (code review) → security-auditor (secrets check)
  → git-workflow (merge) → coordinator (synthesize)
```

### New Agent Creation (Improvement Loop)
```
repeated unscoped work → subagent-recommender (propose)
  → user approves → subagent-curator (create & validate)
  → profile available next session
```

## Key Design Principles

1. **Single Responsibility** — Each agent has a clear, focused domain
2. **Hierarchical Delegation** — Coordinators break down tasks, specialists execute
3. **Parallel Execution** — Independent subtasks run concurrently
4. **Cross-Validation** — Code reviewed by multiple specialists (security, testing, review)
5. **Safe Operations** — Git and destructive operations have limited permissions
6. **Minimum Access** — Each agent gets only the tools it needs
7. **Generic by Default** — Plugin profiles are project-agnostic; customization is local
8. **Self-Improving** — The recommender/curator loop keeps the ecosystem evolving
