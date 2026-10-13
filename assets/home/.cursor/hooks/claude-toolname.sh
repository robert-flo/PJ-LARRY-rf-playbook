#!/bin/bash
# PJ-LARRY: usage: claude-toolname.sh <hook command...>
# cursor-agent picks Claude-format PreToolUse/PostToolUse hooks by translating matchers (Bash→Shell,
# Edit→Write) but hands the hook its own names: tool_name "Shell", hook_event_name "preToolUse".
# Hooks that branch on "Bash" (PreToolGuard, AtlasEventCapture) then skip silently. It also sends
# "cwd": "" (the workspace is in workspace_roots), so repo-aware guards like PublicPushGate scan
# the wrong directory and fail open. This restores the Claude names and a real cwd on stdin and
# keeps the hook's stdout, stderr and exit code (2 still blocks).
in=$(cat)
fixed=$(jq -c '
  (.workspace_roots[0] // "") as $root
  | (if (.cwd // "") == "" and $root != "" then .cwd = $root else . end)
  | (if (.tool_input | type) == "object" and (.tool_input.cwd // "") == "" and $root != ""
     then .tool_input.cwd = $root else . end)
  | (if .tool_name == "Shell" then .tool_name = "Bash" else . end)
  | (if .hook_event_name == "preToolUse" then .hook_event_name = "PreToolUse"
     elif .hook_event_name == "postToolUse" then .hook_event_name = "PostToolUse" else . end)
' <<<"$in" 2>/dev/null) || fixed=$in
exec "$@" <<<"$fixed"
