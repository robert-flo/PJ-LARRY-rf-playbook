#!/bin/bash
# sura-brief: facts for the morning briefing (/buenosdias). Read-only: no fetch, push, send or delete.
# Sections: quota, playbook, open PRs, local repos with unpushed work, cloud agents, health.
set -uo pipefail

vault="${SURA_VAULT:-$HOME/Projects/PJ-LARRY-rf-playbook}"
usage="${XDG_CACHE_HOME:-$HOME/.cache}/cursor-statusline/usage.json"
state="${XDG_STATE_HOME:-$HOME/.local/state}"

h() { printf '\n## %s\n' "$1"; }

printf '# sura-brief · %s\n' "$(date '+%A %F %H:%M')"

h "Cuota de Cursor"
if [[ -f $usage ]]; then
  jq -r '"auto \(.auto_pct|floor)% · api \(.api_pct|floor)% · ciclo termina \((.cycle_end/1000)|strftime("%F")) (\(((.cycle_end/1000 - now)/86400)|floor) días)"' "$usage"
else echo "sin datos ($usage)"; fi

h "Playbook"
if [[ -f $vault/PROGRESO\ \(Ledger\).md ]]; then
  ledger="$vault/PROGRESO (Ledger).md"
  rg -N '^\- \*\*(Último completado|Siguiente):\*\*' "$ledger" | sed -E 's/\[\[[^|]*\|([^]]*)\]\]/\1/g; s/\*\*//g'
  echo "Pendientes abiertos:"
  sed -n '/^## Pendientes abiertos/,/^## /{/^- /p}' "$ledger" | sed -E 's/\[\[[^|]*\|([^]]*)\]\]/\1/g' | cut -c1-200
else echo "vault no encontrado ($vault)"; fi

h "PRs abiertos (míos y donde me piden revisión)"
if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  { gh search prs --author=@me --state=open --limit 20 --json repository,number,title,updatedAt \
      --jq '.[] | "mío      \(.repository.nameWithOwner)#\(.number) \(.title) (\(.updatedAt[:10]))"'
    gh search prs --review-requested=@me --state=open --limit 20 --json repository,number,title,updatedAt \
      --jq '.[] | "revisar  \(.repository.nameWithOwner)#\(.number) \(.title) (\(.updatedAt[:10]))"'
  } 2>/dev/null | sed 's/^/  /' | rg . || echo "  ninguno"
else echo "  gh sin sesión"; fi

h "Repos en ~/Projects con trabajo sin subir"
n=0
for d in "$HOME"/Projects/*/; do
  [[ -d $d.git || -f $d.git ]] || continue
  s=$(git -C "$d" status --porcelain=2 --branch 2>/dev/null) || continue
  dirty=$(grep -c '^[12u?] ' <<<"$s")
  ahead=$(sed -n 's/^# branch.ab +\([0-9]*\) .*/\1/p' <<<"$s")
  branch=$(sed -n 's/^# branch.head //p' <<<"$s")
  if ((dirty > 0 || ${ahead:-0} > 0)); then
    printf '  %-32s %-20s %s cambios · %s commits sin subir\n' "$(basename "$d")" "$branch" "$dirty" "${ahead:-?}"
    n=$((n + 1))
  fi
done
((n)) || echo "  todo limpio y subido"

h "Cloud agents recientes"
if [[ -f $state/sura-cloud/agents.jsonl ]]; then
  tail -n 5 "$state/sura-cloud/agents.jsonl" | jq -r '"  \(.ts[:16]) \(.id) \(.repo // "seguimiento") \((.task // .followUp)[:70])"'
else echo "  ninguno lanzado"; fi

h "Salud"
for r in "$HOME/.claude" "${XDG_CONFIG_HOME:-$HOME/.config}/NIXFREDOS/USER"; do
  [[ -d $r/.git ]] || continue
  ab=$(git -C "$r" status --porcelain=2 --branch | sed -n 's/^# branch.ab +\([0-9]*\) .*/\1/p')
  printf '  backup %-28s último commit %s · %s sin subir\n' "${r/#$HOME/\~}" "$(git -C "$r" log -1 --format=%cr)" "${ab:-?}"
done
if [[ -d $HOME/.cfg ]]; then
  printf '  sura-home (dotbare): %s archivos versionados con cambios\n' \
    "$(git --git-dir="$HOME/.cfg" --work-tree="$HOME" status --porcelain -uno | grep -c .)"
fi
[[ -f $state/sura-canaries/last.json ]] &&
  jq -r '"  canarios \(.date[:16]): \(.pass) ✓ · \(.fail) ✗ \(if .fail > 0 then "(" + (.failed|join(" ")) + ")" else "" end)"' "$state/sura-canaries/last.json"
failed=$(systemctl --user --failed --no-legend --plain 2>/dev/null | awk '{print $1}' | paste -sd' ')
echo "  servicios de usuario fallidos: ${failed:-ninguno}"

h "Correo y calendario"
echo "  no conectados (Capítulo 26)"
