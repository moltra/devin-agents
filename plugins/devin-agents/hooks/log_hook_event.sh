#!/usr/bin/env bash
# devin-agents plugin hook logger.
#
# Invoked by the plugin's hooks.json for PreToolUse (delegation tools) and
# PostCompaction events. Reads the hook payload from stdin and appends one
# tab-separated audit line to .devin/logs/devin-agents.log under the project
# root (DEVIN_PROJECT_DIR, falling back to CLAUDE_PROJECT_DIR, then PWD).
#
# Fields logged: timestamp, event, session, tool, profile, title, provenance.
# tool_provenance is only present on CLI >= v3000.10.21; older versions log
# "n/a". Payload text (task bodies, compaction summaries) is never written
# to the log.
#
# Always exits 0 — logging must never block the agent.
set -u

event="${1:-unknown}"

root="${DEVIN_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-$PWD}}"
log_dir="$root/.devin/logs"
log_file="$log_dir/devin-agents.log"
mkdir -p "$log_dir" 2>/dev/null || exit 0

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
payload="$(cat 2>/dev/null || true)"

fields="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
ti = d.get("tool_input") or {}
prov = d.get("tool_provenance") or ""
prov_s = json.dumps(prov, separators=(",", ":")) if prov else ""
sid = d.get("session_id") or d.get("trajectory_id") or ""
cols = [d.get("tool_name", ""), ti.get("profile", ""), ti.get("title", ""), prov_s, sid]
print("\t".join(str(c)[:200] for c in cols))
' 2>/dev/null || true)"

IFS=$'\t' read -r tool profile title prov sid <<<"$fields"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$ts" "$event" "${sid:-?}" "${tool:-?}" "${profile:-?}" "${title:-?}" "${prov:-n/a}" \
  >>"$log_file" 2>/dev/null || true

exit 0
