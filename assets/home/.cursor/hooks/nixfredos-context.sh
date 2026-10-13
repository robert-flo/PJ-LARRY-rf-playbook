#!/bin/bash
# PJ-LARRY: cursor-agent has no --append-system-prompt-file and does not read ~/.claude/CLAUDE.md,
# so this sessionStart hook injects both, in the order nixfredOS's own launcher uses.
# Fails open: on any missing file it injects nothing and the session starts without nixfredOS.
cat >/dev/null
root="${NIXFREDOS_CONFIG_ROOT:-$HOME/.claude}"
sys="$root/NIXFREDOS/NIXFREDOS_SYSTEM_PROMPT.md"
md="$root/CLAUDE.md"
for f in "$sys" "$md"; do
  [[ -r $f ]] || { echo "nixfredos-context: missing $f" >&2; echo '{}'; exit 0; }
done

expand_imports() {
  local line p
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line =~ ^@([^[:space:]]+)$ ]]; then
      p="${BASH_REMATCH[1]}"
      p="${p/#\~/$HOME}"
      [[ $p = /* ]] || p="$root/$p"
      if [[ -r $p ]]; then
        printf '\n<!-- @%s -->\n' "${BASH_REMATCH[1]}"
        cat "$p"
        printf '\n'
      else
        printf '%s (missing)\n' "$line"
      fi
    else
      printf '%s\n' "$line"
    fi
  done <"$1"
}

ctx=$(
  printf '# nixfredOS constitution (loaded by sessionStart hook; harness: cursor-agent; config root: %s)\n\n' "$root"
  cat "$sys"
  printf '\n\n---\n\n'
  expand_imports "$md"
)
jq -n --arg c "$ctx" '{additional_context: $c}'
