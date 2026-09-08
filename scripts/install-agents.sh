#!/bin/bash
# Install or update Devin agent templates and skills.
#
# Usage:
#   Run from inside the repository:
#     bash scripts/install-agents.sh
#
#   Run standalone (downloads the repository automatically):
#     bash <(curl -fsSL https://raw.githubusercontent.com/moltra/devin-agents/main/scripts/install-agents.sh)
#
#   Force a specific scope without prompting:
#     INSTALL_MODE=local  bash scripts/install-agents.sh
#     INSTALL_MODE=global bash scripts/install-agents.sh
#
# The script asks whether to install locally (current project: ./.devin) or globally
# (user Devin config). On non-interactive terminals it defaults to global.
#
# Override behavior by setting these environment variables:
#   - DEVIN_CONFIG: target directory (skips the local/global prompt)
#   - INSTALL_MODE: local or global (skips the prompt)
#   - REPO_URL:     Git repository URL to clone when running standalone
#   - REPO_BRANCH:  Git branch to clone when running standalone (default: main)

set -euo pipefail

shopt -s nullglob

REPO_URL="${REPO_URL:-https://github.com/moltra/devin-agents.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
TMP_REPO_DIR=""

# Detect global Devin configuration directory.
detect_global_config() {
    local os
    os=$(uname -s)

    case "$os" in
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            # Git Bash, MSYS2, or Cygwin on Windows. Devin Desktop stores config
            # in %APPDATA%\devin (AppData/Roaming/devin).
            if [ -d "$HOME/AppData/Roaming" ]; then
                printf '%s/AppData/Roaming/devin' "$HOME"
            else
                printf '%s/.config/devin' "$HOME"
            fi
            ;;
        *)
            printf '%s/.config/devin' "$HOME"
            ;;
    esac
}

# Select installation scope: local (current project) or global (user config).
select_install_scope() {
    if [ -n "${DEVIN_CONFIG:-}" ]; then
        printf 'global
'
        return
    fi

    if [ -n "${INSTALL_MODE:-}" ]; then
        local mode
        mode=$(printf '%s' "$INSTALL_MODE" | tr '[:upper:]' '[:lower:]')
        if [ "$mode" != "local" ] && [ "$mode" != "global" ]; then
            printf 'Invalid INSTALL_MODE: %s. Must be local or global.\n' "$INSTALL_MODE" >&2
            exit 1
        fi
        printf '%s
' "$mode"
        return
    fi

    if [ -t 0 ] && [ -t 1 ]; then
        local mode
        read -rp "Install locally (current project: $PWD/.devin) or globally (user config)? [local/global]: " mode
        mode=$(printf '%s' "$mode" | tr '[:upper:]' '[:lower:]')
        if [ "$mode" != "local" ] && [ "$mode" != "global" ]; then
            printf 'Invalid choice: %s. Defaulting to global.\n' "$mode" >&2
            mode="global"
        fi
        printf '%s
' "$mode"
    else
        printf 'global
'
    fi
}

# Locate the repository. If the script is not inside the repository, clone it to
# a temporary directory.
locate_repo() {
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd 2>/dev/null) || script_dir=""

    if [ -n "$script_dir" ] && [ -d "$script_dir" ]; then
        local candidate
        candidate=$(dirname "$script_dir")
        if [ -d "$candidate/templates" ] && [ -d "$candidate/plugins/devin-agents/skills" ]; then
            printf '%s' "$candidate"
            return
        fi
    fi

    if ! command -v git >/dev/null 2>&1; then
        printf 'Error: git is not installed and the repository is not available locally.\n' >&2
        exit 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    TMP_REPO_DIR="$tmp_dir"
    printf 'Repository not found locally. Cloning to %s...\n' "$tmp_dir" >&2
    git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$tmp_dir" >&2
    printf '%s' "$tmp_dir"
}

cleanup() {
    if [ -n "${TMP_REPO_DIR:-}" ] && [ -d "$TMP_REPO_DIR" ]; then
        rm -rf "$TMP_REPO_DIR"
    fi
}
trap cleanup EXIT

SCOPE=$(select_install_scope)
if [ -n "${DEVIN_CONFIG:-}" ]; then
    # A specific target was provided; keep it and skip scope-based path selection.
    :
elif [ "$SCOPE" = "local" ]; then
    DEVIN_CONFIG="$PWD/.devin"
else
    DEVIN_CONFIG=$(detect_global_config)
fi

REPO_DIR=$(locate_repo)

BACKUP_DIR="$DEVIN_CONFIG/backup-$(date +%Y%m%d-%H%M%S)"
AGENTS_DIR="$DEVIN_CONFIG/agents"
SKILLS_DIR="$DEVIN_CONFIG/skills"

printf 'Installing Devin agents and skills...\n'
printf 'Scope:      %s\n' "$SCOPE"
printf 'Repository: %s\n' "$REPO_DIR"
printf 'Target:     %s\n' "$DEVIN_CONFIG"

mkdir -p "$AGENTS_DIR" "$SKILLS_DIR"
mkdir -p "$BACKUP_DIR"

# Backup the entire agents and skills directories if they already contain data.
if [ -d "$AGENTS_DIR" ] && [ "$(ls -A "$AGENTS_DIR" 2>/dev/null)" ]; then
    cp -r "$AGENTS_DIR" "$BACKUP_DIR/"
fi
if [ -d "$SKILLS_DIR" ] && [ "$(ls -A "$SKILLS_DIR" 2>/dev/null)" ]; then
    cp -r "$SKILLS_DIR" "$BACKUP_DIR/"
fi

printf '\nInstalling/updating agents...\n'
for template in "$REPO_DIR/templates/"*.md; do
    [ -f "$template" ] || continue

    name=$(basename "$template" .md | sed 's/-template$//')
    target_dir="$AGENTS_DIR/$name"
    target_file="$target_dir/AGENT.md"

    if [ -f "$target_file" ]; then
        printf '  Updating agent: %s\n' "$name"
    else
        printf '  Installing agent: %s\n' "$name"
    fi

    mkdir -p "$target_dir"
    cp "$template" "$target_file"
done

printf '\nInstalling/updating skills...\n'
install_skills_from() {
    local source_dir="$1"
    if [ ! -d "$source_dir" ]; then
        return
    fi

    for skill_dir in "$source_dir"/*/; do
        [ -d "$skill_dir" ] || continue

        local name
        name=$(basename "$skill_dir")
        local target_dir="$SKILLS_DIR/$name"

        if [ -d "$target_dir" ]; then
            printf '  Updating skill: %s\n' "$name"
            rm -rf "$target_dir"
        else
            printf '  Installing skill: %s\n' "$name"
        fi

        cp -r "$skill_dir" "$target_dir"
    done
}

install_skills_from "$REPO_DIR/plugins/devin-agents/skills"

printf '\nInstallation complete.\n'
printf 'Backup: %s\n' "$BACKUP_DIR"
printf '\nNext steps:\n'
printf '1. Review backed-up files if you had customizations.\n'
printf '2. Restart Devin to load the updated configurations.\n'
