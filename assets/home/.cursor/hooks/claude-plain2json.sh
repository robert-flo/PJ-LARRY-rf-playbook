#!/bin/bash
# PJ-LARRY: usage: claude-plain2json.sh <ClaudeEvent> <hook command...>
# Claude Code injects a hook's plain stdout as context; cursor-agent drops it and only reads
# JSON (hookSpecificOutput.additionalContext). This runs the hook once, passes JSON through
# untouched, wraps plain text, and keeps the hook's exit code.
# cursor-agent drops the whole beforeSubmitPrompt context if the merged total exceeds 10000 chars.
ev=$1
shift
out=$("$@")
rc=$?
if [[ -n ${out//[[:space:]]/} ]]; then
  if jq -e 'type == "object"' >/dev/null 2>&1 <<<"$out"; then
    printf '%s\n' "$out"
  else
    jq -n --arg e "$ev" --arg c "$out" '{hookSpecificOutput: {hookEventName: $e, additionalContext: $c}}'
  fi
fi
exit "$rc"
