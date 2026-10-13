#!/usr/bin/env bash
# cursor-agent status line: model, context usage, directory, git branch, worktree.
# Spec: ~/.cursor/skills-cursor/statusline/SKILL.md (payload arrives as JSON on stdin).
input=$(cat)

# \x1f instead of tabs: read collapses consecutive whitespace delimiters, which shifts empty fields.
IFS=$'\x1f' read -r model params pct dir wt < <(jq -r '[
  .model.display_name // .model.id // "?",
  .model.param_summary // "",
  ((.context_window.used_percentage // 0) | floor | tostring),
  .workspace.current_dir // .cwd // "",
  .worktree.name // ""
] | join("\u001f")' <<<"$input")

width=10
filled=$((pct * width / 100))
bar=""
for ((i = 0; i < width; i++)); do
  if ((i < filled)); then bar+="▓"; else bar+="░"; fi
done

if ((pct >= 80)); then color='\033[31m'; elif ((pct >= 50)); then color='\033[33m'; else color='\033[32m'; fi

branch=""
if [[ -n $dir ]] && b=$(git -C "$dir" branch --show-current 2>/dev/null); then
  [[ -z $b ]] && b=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  [[ -n $(git -C "$dir" status --porcelain --untracked-files=no 2>/dev/null | head -1) ]] && b+="*"
  branch="  \033[35m⎇ ${b}\033[0m"
fi

printf "\033[36m%s%s\033[0m  ${color}%s %s%%\033[0m  \033[34m%s\033[0m%b%s\n" \
  "$model" "${params:+ $params}" "$bar" "$pct" "${dir/#$HOME/\~}" "$branch" "${wt:+  wt:$wt}"
