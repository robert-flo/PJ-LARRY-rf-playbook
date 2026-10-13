#!/bin/bash
# PJ-LARRY: route every Claude-format UserPromptSubmit/SessionStart hook in ~/.claude/settings.json
# through claude-plain2json.sh so cursor-agent receives its context. Idempotent; re-run after any
# nixfredOS/memory-engine (re)install, which rewrites these entries.
# usage: wrap-claude-hooks.sh [--check]   (--check exits 1 if any entry is unwrapped)
set -euo pipefail
settings="${NIXFREDOS_CONFIG_ROOT:-$HOME/.claude}/settings.json"
wrapper="$HOME/.cursor/hooks/claude-plain2json.sh"
filter='
  reduce ("UserPromptSubmit", "SessionStart") as $ev (.;
    if .hooks[$ev] then
      .hooks[$ev] |= map(.hooks |= map(
        if (.command | startswith($w)) then . else .command = "\($w) \($ev) \(.command)" end))
    else . end)'
new=$(jq --arg w "$wrapper" "$filter" "$settings")
if [[ ${1:-} == --check ]]; then
  [[ $new == "$(jq . "$settings")" ]] && { echo "wrapped"; exit 0; } || { echo "unwrapped entries in $settings"; exit 1; }
fi
if [[ $new != "$(jq . "$settings")" ]]; then
  cp "$settings" "$settings.pre-wrap-$(date +%Y%m%d-%H%M%S)"
  printf '%s\n' "$new" >"$settings"
  echo "wrapped: $settings"
else
  echo "already wrapped: $settings"
fi
