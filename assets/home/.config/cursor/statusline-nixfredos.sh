#!/usr/bin/env bash
# Refreshes the nixfredOS cache read by statusline.sh: DA name, memory, Cursor adapter health, voice.
# Health means the Cursor adapters are wired (playbook Chapter 5), not that nixfredOS itself is perfect.
set -uo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cursor-statusline"
cache="$cache_dir/nixfredos.json"
mkdir -p "$cache_dir"

exec 9>"$cache_dir/nixfredos.lock"
flock -n 9 || exit 0

root="${NIXFREDOS_CONFIG_ROOT:-$HOME/.claude}"
toml="${XDG_CONFIG_HOME:-$HOME/.config}/NIXFREDOS/USER/CONFIG/NIXFREDOS_CONFIG.toml"
sync_log="$HOME/.local/state/cursor-transcripts-sync.log"
now=$(date +%s)

da=$(awk -F'"' '/^\[da\]/ { s = 1; next } /^\[/ { s = 0 } s && /^name *=/ { print $2; exit }' "$toml" 2>/dev/null)

mem=-1
[[ -f $root/memory.db ]] && mem=$(sqlite3 -readonly "$root/memory.db" 'select count(*) from sessions' 2>/dev/null || echo -1)

# Sync is healthy if the last import exited 0 and the hourly timer ran recently.
sync_ok=0 sync_age=-1
if [[ -f $sync_log ]]; then
  sync_age=$((now - $(stat -c %Y "$sync_log")))
  last=$(grep -E 'mem import: exit [0-9]+' "$sync_log" | tail -1)
  [[ $last == *"exit 0"* ]] && ((sync_age < 2 * 3600 + 600)) && sync_ok=1
fi

hooks_ok=0
if jq -e '.hooks | (.sessionStart | length > 0) and (.beforeSubmitPrompt | length > 0) and (.sessionEnd | length > 0)' \
  "$HOME/.cursor/hooks.json" >/dev/null 2>&1 &&
  "$HOME/.cursor/hooks/wrap-claude-hooks.sh" --check >/dev/null 2>&1 &&
  [[ -f $root/NIXFREDOS/NIXFREDOS_SYSTEM_PROMPT.md ]]; then
  hooks_ok=1
fi

voice=off
if jq -e '.enabled == true' "$root/voice.json" >/dev/null 2>&1; then
  if systemctl --user is-active --quiet com.nixfredos.pulse.service; then voice=on; else voice=down; fi
fi

jq -n --arg da "$da" --argjson mem "${mem:--1}" --argjson sync_ok "$sync_ok" --argjson sync_age "$sync_age" \
  --argjson hooks_ok "$hooks_ok" --arg voice "$voice" --argjson now "$now" \
  '{updated: $now, da: $da, mem: $mem, sync_ok: $sync_ok, sync_age: $sync_age, hooks_ok: $hooks_ok, voice: $voice}' \
  >"$cache.tmp" && mv "$cache.tmp" "$cache"
