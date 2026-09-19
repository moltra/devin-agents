#!/usr/bin/env bash
# Canonical coordinator action logger for the devin-agents plugin.
#
# Usage: log_coordinator.sh <action> [details...]
# Standard actions: plan delegate integrate verify commit decision
#                   recovery cleanup escalation
#
# Appends "timestamp | action | details" to .devin/logs/coordinator.log
# under the project root (DEVIN_PROJECT_DIR, falling back to PWD).
#
# To enable in a project, copy or symlink this script to
# .devin/hooks/log_coordinator.sh — the path coordinator profiles call.
# When the script is absent, coordinators skip manual logging silently;
# delegation calls are still captured automatically by the plugin's
# hooks.json into .devin/logs/devin-agents.log.
#
# Always exits 0 — logging must never block the agent.
set -u

action="${1:-note}"
shift 2>/dev/null || true
details="${*:-}"

root="${DEVIN_PROJECT_DIR:-$PWD}"
log_dir="$root/.devin/logs"
mkdir -p "$log_dir" 2>/dev/null || exit 0

printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$action" "$details" \
  >>"$log_dir/coordinator.log" 2>/dev/null || true

exit 0
