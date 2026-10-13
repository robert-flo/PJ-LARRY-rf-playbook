#!/bin/bash
# PJ-LARRY: native sessionEnd hook and timer entry point for cursor-transcripts-sync.ts.
# Runs detached so ending a session never waits on the import; flock keeps runs from overlapping.
[[ -t 0 ]] || cat >/dev/null
export PATH="$HOME/.local/share/mise/installs/bun/latest/bin:$HOME/bin:$PATH"
log="${XDG_STATE_HOME:-$HOME/.local/state}/cursor-transcripts-sync.log"
mkdir -p "${log%/*}"
run() {
  flock -n "${XDG_RUNTIME_DIR:-/tmp}/cursor-transcripts-sync.lock" \
    bun "$HOME/.cursor/hooks/cursor-transcripts-sync.ts" 2>&1 |
    while IFS= read -r l; do printf '%s %s\n' "$(date -Is)" "$l"; done >>"$log"
}
if [[ ${1:-} == --foreground ]]; then
  run
else
  setsid "$0" --foreground </dev/null >/dev/null 2>&1 &
  echo '{}'
fi
