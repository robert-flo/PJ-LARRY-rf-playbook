#!/bin/bash
# PJ-LARRY: cursor-agent only runs the beforeSubmitPrompt step (which includes the Claude-format
# UserPromptSubmit hooks in ~/.claude/settings.json) when ~/.cursor/hooks.json declares at least
# one native beforeSubmitPrompt hook. This no-op is that declaration; removing it silences them all.
cat >/dev/null
echo '{}'
