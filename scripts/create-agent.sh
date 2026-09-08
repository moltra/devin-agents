#!/bin/bash
# Scaffold a new custom subagent profile.
#
# Creates an AGENT.md (and optionally a matching SKILL.md) from a template,
# under the chosen target directory.
#
# Usage:
#   ./scripts/create-agent.sh <name> [-d "<description>"] [-t <target-dir>] [-s] [-h]
#
# Arguments:
#   name            Agent name in kebab-case (required).
#
# Options:
#   -d <desc>       Short description for the agent (default: "Custom subagent").
#   -t <dir>        Target directory (default: .devin/agents/ for project-level).
#   -s              Also create a matching SKILL.md.
#   -h              Show this help and exit.
#
# Examples:
#   ./scripts/create-agent.sh my-reviewer -d "Reviews code for issues" -s
#   ./scripts/create-agent.sh data-analyst -d "Analyzes data patterns" -t ~/.config/devin/agents/

set -euo pipefail

# --- Defaults -------------------------------------------------------------

DESCRIPTION="Custom subagent"
TARGET_DIR=".devin/agents"
CREATE_SKILL=0

# --- Functions ------------------------------------------------------------

usage() {
    cat <<'USAGE'
Usage: create-agent.sh <name> [options]

Scaffold a new custom subagent profile.

Arguments:
  name            Agent name in kebab-case (required).

Options:
  -d <desc>       Short description for the agent (default: "Custom subagent").
  -t <dir>        Target directory (default: .devin/agents/ for project-level).
  -s              Also create a matching SKILL.md.
  -h              Show this help and exit.

Examples:
  ./scripts/create-agent.sh my-reviewer -d "Reviews code for issues" -s
  ./scripts/create-agent.sh data-analyst -d "Analyzes data patterns" -t ~/.config/devin/agents/
USAGE
}

# Convert a kebab-case name to Title Case for headings.
# Example: "my-reviewer" -> "My Reviewer"
title_case() {
    local name="$1"
    echo "$name" | awk -F'-' '{
        for (i = 1; i <= NF; i++) {
            printf "%s%s", toupper(substr($i, 1, 1)), substr($i, 2)
            if (i < NF) printf " "
        }
    }'
}

# --- Parse arguments ------------------------------------------------------

if [ $# -lt 1 ]; then
    usage >&2
    exit 1
fi

# First positional argument is the agent name (unless it is a flag).
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    -*)
        printf 'Error: agent name is required and must come first.\n\n' >&2
        usage >&2
        exit 1
        ;;
    *)
        AGENT_NAME="$1"
        shift
        ;;
esac

while getopts ":d:t:sh" opt; do
    case "$opt" in
        d)
            DESCRIPTION="$OPTARG"
            ;;
        t)
            TARGET_DIR="$OPTARG"
            ;;
        s)
            CREATE_SKILL=1
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            printf 'Error: invalid option: -%s\n' "$OPTARG" >&2
            usage >&2
            exit 1
            ;;
        :)
            printf 'Error: option -%s requires an argument.\n' "$OPTARG" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# --- Validate the name ----------------------------------------------------

if ! printf '%s' "$AGENT_NAME" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
    printf 'Error: agent name must be kebab-case (lowercase letters, digits, hyphens).\n' >&2
    printf 'Got: "%s"\n' "$AGENT_NAME" >&2
    exit 1
fi

# --- Resolve paths --------------------------------------------------------

# Expand a leading ~ in the target directory.
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

AGENT_DIR="$TARGET_DIR/$AGENT_NAME"
AGENT_FILE="$AGENT_DIR/AGENT.md"
SKILL_FILE="$AGENT_DIR/SKILL.md"

# --- Guard against overwriting -------------------------------------------

if [ -f "$AGENT_FILE" ]; then
    printf 'Error: agent already exists: %s\n' "$AGENT_FILE" >&2
    printf 'Remove it first or choose a different name/target.\n' >&2
    exit 1
fi

# --- Create the agent directory ------------------------------------------

mkdir -p "$AGENT_DIR"

TITLE=$(title_case "$AGENT_NAME")

# --- Generate AGENT.md ----------------------------------------------------

cat > "$AGENT_FILE" <<EOF
---
name: $AGENT_NAME
description: $DESCRIPTION
allowed-tools:
  - read
  - grep
  - glob
  - exec
---

# $TITLE

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
EOF

printf 'Created agent: %s\n' "$AGENT_FILE"

# --- Optionally generate SKILL.md ----------------------------------------

if [ "$CREATE_SKILL" -eq 1 ]; then
    if [ -f "$SKILL_FILE" ]; then
        printf 'Warning: SKILL.md already exists, skipping: %s\n' "$SKILL_FILE"
    else
        cat > "$SKILL_FILE" <<EOF
---
name: $AGENT_NAME
description: $DESCRIPTION
triggers:
  - user
  - model
---

# $TITLE Skill

<Instructions for the agent when this skill is invoked>
EOF
        printf 'Created skill: %s\n' "$SKILL_FILE"
    fi
fi

# --- Next steps -----------------------------------------------------------

printf '\nNext steps:\n'
printf '1. Edit %s to fill in the system prompt sections.\n' "$AGENT_FILE"
if [ "$CREATE_SKILL" -eq 1 ]; then
    printf '2. Edit %s to fill in the skill instructions.\n' "$SKILL_FILE"
    printf '3. Validate with: bash scripts/validate-agent.sh %s\n' "$TARGET_DIR"
else
    printf '2. Validate with: bash scripts/validate-agent.sh %s\n' "$TARGET_DIR"
fi
