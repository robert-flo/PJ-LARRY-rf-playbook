#!/usr/bin/env bash
# Restore the AI and the home directory from the private repos (playbook Chapter 8), then run rebuild.sh.
# Idempotent: every step checks first and skips what is already restored.
#
#   assets/restore.sh --check          report only, change nothing
#   assets/restore.sh                  restore
#   assets/restore.sh --no-push        test bench: every restored repo gets its push URL disabled
#   assets/restore.sh --skip-packages  do not install the packages listed in ~/.config/pkglist
#
# Needs a logged-in gh (human step: gh auth login). The first clones go over HTTPS with gh as the
# credential helper, because the SSH key only arrives with sura-home; remotes are switched to SSH after.
set -uo pipefail

CHECK=0 NOPUSH=0 PKGS=1
for a in "$@"; do
  case $a in
    --check) CHECK=1 ;;
    --no-push) NOPUSH=1 ;;
    --skip-packages) PKGS=0 ;;
    *) echo "uso: $0 [--check] [--no-push] [--skip-packages]" >&2; exit 2 ;;
  esac
done

VAULT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GH_USER=robert-flo
CFG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
USER_TREE="$CFG_HOME/NIXFREDOS/USER"
TS=$(date +%Y%m%d-%H%M%S)
# Home the backups were taken from; restoring into another user rewrites it to $HOME (like niri's postinstall).
SRC_HOME="${RESTORE_FROM_HOME:-/home/gracie}"
FAIL=0

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
todo() { printf '  \033[33m•\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; FAIL=1; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }
run()  { if ((CHECK)); then todo "pendiente: $*"; else "$@"; fi; }

https() { echo "https://github.com/$GH_USER/$1.git"; }
ssh_url() { echo "git@github.com:$GH_USER/$1.git"; }
origin_is() { [[ $(git --git-dir="$1" remote get-url origin 2>/dev/null) == *"/$2.git" ]]; }
private() {
  local v; v=$(gh repo view "$GH_USER/$1" --json visibility -q .visibility 2>/dev/null)
  [[ $v == PRIVATE ]] && return 0
  bad "$1: visibilidad '${v:-desconocida}'; solo se restaura desde repos PRIVATE"; return 1
}
relocate() { # git-dir work-tree label: rewrite $SRC_HOME to $HOME in tracked text files (local change only)
  [[ $HOME == "$SRC_HOME" ]] && return 0
  local files n
  files=$(git --git-dir="$1" --work-tree="$2" grep -I -l -F "$SRC_HOME" -- . 2>/dev/null)
  [[ -z $files ]] && { ok "$3: nada que reubicar"; return 0; }
  n=$(wc -l <<<"$files")
  if ((CHECK)); then todo "pendiente: reubicar $SRC_HOME → $HOME en $n archivo(s) de $3"; return 0; fi
  (cd "$2" && xargs -d '\n' sed -i "s|$SRC_HOME|$HOME|g" <<<"$files") && ok "$3: $n archivo(s) reubicados a $HOME"
}
finish_remote() { # git-dir repo: SSH remote, and push disabled on a test bench
  git --git-dir="$1" remote set-url origin "$(ssh_url "$2")"
  ((NOPUSH)) && git --git-dir="$1" remote set-url --push origin no_push
  return 0
}

export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

# The restored ~/.config/git/config must not steer the restore itself.
export GIT_CONFIG_GLOBAL=/dev/null
# gh as the credential helper for every git call in this script (dotbare included), without touching ~/.gitconfig
export GIT_CONFIG_COUNT=2 GIT_CONFIG_KEY_0=credential.helper GIT_CONFIG_VALUE_0= \
  GIT_CONFIG_KEY_1=credential.helper GIT_CONFIG_VALUE_1='!gh auth git-credential'

step "0. Requisitos"
[[ -r /usr/share/omarchy/default/bash/rc ]] && ok "Omarchy" || bad "no es Omarchy"
for c in git gh jq rsync; do command -v "$c" >/dev/null && ok "$c" || bad "falta $c"; done
gh auth status >/dev/null 2>&1 && ok "gh autenticado ($(gh api user -q .login 2>/dev/null))" \
  || { bad "ejecuta: gh auth login   (GitHub.com, navegador)"; exit 1; }
command -v dotbare >/dev/null && ok "dotbare" || run yay -S --needed --noconfirm dotbare
command -v bun >/dev/null && ok "bun" || run mise use -g bun
((NOPUSH)) && todo "modo banco de pruebas: los repos restaurados no pueden hacer push"

step "1. HOME desde sura-home (dotbare)"
G=(git --git-dir="$HOME/.cfg" --work-tree="$HOME")
if origin_is "$HOME/.cfg" sura-home; then ok "~/.cfg → sura-home"
elif [[ -e $HOME/.cfg ]]; then bad "~/.cfg existe y no apunta a sura-home: revísalo a mano"
elif ((CHECK)); then todo "pendiente: dotbare finit -u sura-home"
elif private sura-home; then
  # finit -u moves files that would be overwritten to ~/.local/share/dotbare/
  (cd ~ && DOTBARE_DIR="$HOME/.cfg" DOTBARE_TREE="$HOME" dotbare finit -y -u "$(https sura-home)" </dev/null >/dev/null 2>&1)
  if origin_is "$HOME/.cfg" sura-home; then
    "${G[@]}" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    "${G[@]}" config status.showUntrackedFiles no
    "${G[@]}" fetch -q origin && "${G[@]}" branch -q -u origin/master master
    finish_remote "$HOME/.cfg" sura-home
    ok "sura-home restaurado ($("${G[@]}" ls-files | wc -l) archivos)"
  else bad "falló dotbare finit -u sura-home"; fi
fi
if [[ -d $HOME/.ssh ]]; then
  chmod 700 ~/.ssh && find ~/.ssh -maxdepth 1 -type f ! -name '*.pub' ! -name 'known_hosts*' ! -name config -exec chmod 600 {} +
  ok "permisos de ~/.ssh"
fi
[[ -d $HOME/.gnupg ]] && chmod 700 ~/.gnupg && ok "permisos de ~/.gnupg"
[[ -d $HOME/.cfg ]] && relocate "$HOME/.cfg" "$HOME" "~"

step "2. Paquetes desde ~/.config/pkglist"
if ((!PKGS)); then todo "omitido (--skip-packages)"
elif [[ ! -s $CFG_HOME/pkglist/pacman.txt ]]; then todo "no hay ~/.config/pkglist (llega con sura-home)"
else
  mapfile -t miss < <(comm -23 <(sort -u "$CFG_HOME/pkglist/pacman.txt") <(pacman -Qq | sort -u))
  if ((${#miss[@]} == 0)); then ok "paquetes de los repos"
  else run sudo pacman -S --needed --noconfirm "${miss[@]}" || bad "pacman falló con: ${miss[*]}"; fi
  mapfile -t miss < <(comm -23 <(sort -u "$CFG_HOME/pkglist/aur.txt" 2>/dev/null) <(pacman -Qq | sort -u))
  if ((${#miss[@]} == 0)); then ok "paquetes de AUR"
  else run yay -S --needed --noconfirm "${miss[@]}" || bad "yay falló con: ${miss[*]}"; fi
fi

step "3. ~/.claude desde sura-brain"
if origin_is "$HOME/.claude/.git" sura-brain; then ok "~/.claude → sura-brain"
elif [[ -d $HOME/.claude/.git ]]; then bad "~/.claude es otro repo: revísalo a mano"
elif ((CHECK)); then todo "pendiente: checkout de sura-brain en ~/.claude (con copia previa)"
elif private sura-brain; then
  if [[ -d $HOME/.claude ]]; then
    tar --exclude=node_modules -czf "$HOME/.claude.pre-restore-$TS.tgz" -C ~ .claude && ok "copia previa: ~/.claude.pre-restore-$TS.tgz"
  fi
  mkdir -p ~/.claude && git -C ~/.claude init -q -b master && git -C ~/.claude remote add origin "$(https sura-brain)" \
    && git -C ~/.claude fetch -q origin && git -C ~/.claude checkout -q -f -B master origin/master \
    && finish_remote "$HOME/.claude/.git" sura-brain && ok "sura-brain restaurado ($(git -C ~/.claude ls-files | wc -l) archivos)" \
    || bad "falló el checkout de sura-brain"
fi
[[ -d $HOME/.claude/.git ]] && relocate "$HOME/.claude/.git" "$HOME/.claude" "~/.claude"

step "4. Árbol USER desde sura-brain-user"
if origin_is "$USER_TREE/.git" sura-brain-user; then ok "${USER_TREE/#$HOME/\~} → sura-brain-user"
elif ((CHECK)); then todo "pendiente: clonar sura-brain-user en ${USER_TREE/#$HOME/\~}"
elif private sura-brain-user; then
  [[ -e $USER_TREE ]] && mv "$USER_TREE" "$USER_TREE.pre-restore-$TS" && ok "árbol USER previo movido a USER.pre-restore-$TS"
  mkdir -p "${USER_TREE%/*}" && git clone -q "$(https sura-brain-user)" "$USER_TREE" \
    && finish_remote "$USER_TREE/.git" sura-brain-user && ok "sura-brain-user restaurado" || bad "falló el clon de sura-brain-user"
fi
[[ -d $USER_TREE/.git ]] && relocate "$USER_TREE/.git" "$USER_TREE" "árbol USER"
# LinkUser writes an absolute symlink; on another user or path it points at someone else's tree.
link="$HOME/.claude/NIXFREDOS/USER"
if [[ -d $HOME/.claude/NIXFREDOS ]]; then
  if [[ $(readlink "$link") == "$USER_TREE" ]]; then ok "NIXFREDOS/USER → ${USER_TREE/#$HOME/\~}"
  else run ln -sfn "$USER_TREE" "$link" && ((!CHECK)) && ok "NIXFREDOS/USER reapuntado a ${USER_TREE/#$HOME/\~}"; fi
fi

step "5. Conversaciones y memory.db desde sura-conversations"
CB="$HOME/.claude/conversations-backup"
if origin_is "$CB/.git" sura-conversations; then ok "conversations-backup → sura-conversations"
elif ((CHECK)); then todo "pendiente: clonar sura-conversations"
elif private sura-conversations; then
  [[ -e $CB ]] && mv "$CB" "$CB.pre-restore-$TS"
  git clone -q "$(https sura-conversations)" "$CB" && finish_remote "$CB/.git" sura-conversations \
    && ok "sura-conversations restaurado" || bad "falló el clon de sura-conversations"
fi
if [[ -f $CB/memory.db ]]; then
  if [[ -f $HOME/.claude/memory.db ]]; then ok "memory.db presente"
  else run cp "$CB/memory.db" ~/.claude/memory.db && ((!CHECK)) && ok "memory.db restaurada"; fi
  if [[ -n $(ls -A ~/.claude/projects 2>/dev/null) ]]; then ok "transcripts en ~/.claude/projects"
  elif [[ -d $CB/projects ]]; then run rsync -a "$CB/projects/" ~/.claude/projects/ && ((!CHECK)) && ok "transcripts restaurados en ~/.claude/projects"; fi
fi

step "6. Dependencias de nixfredOS (node_modules)"
# skills/nixfredOS/install/ is the installer's source copy: it never had node_modules.
if git -C ~/.claude rev-parse >/dev/null 2>&1; then
  n=0
  while IFS= read -r lock; do
    d="$HOME/.claude/${lock%/*}"; [[ $lock == */* ]] || d="$HOME/.claude"
    [[ -d $d/node_modules ]] && continue
    n=$((n + 1))
    if ((CHECK)); then todo "pendiente: bun install en ${d/#$HOME/\~}"
    else (cd "$d" && bun install --frozen-lockfile >/dev/null 2>&1) && ok "bun install ${d/#$HOME/\~}" || bad "bun install falló en ${d/#$HOME/\~}"; fi
  done < <(git -C ~/.claude ls-files '*bun.lock' 'bun.lock' | grep -v '^skills/nixfredOS/install/')
  ((n == 0)) && ok "todos los node_modules presentes"
fi

step "7. Portabilidad (rutas de otro usuario)"
for pair in "$HOME/.cfg|$HOME" "$HOME/.claude/.git|$HOME/.claude" "$USER_TREE/.git|$USER_TREE"; do
  gd=${pair%%|*} wt=${pair#*|}
  [[ -d $gd ]] || continue
  hits=$(git --git-dir="$gd" --work-tree="$wt" grep -I -l -E "/home/[a-z_][a-z0-9_-]*/" -- . 2>/dev/null \
    | while IFS= read -r f; do grep -Eo "/home/[a-z_][a-z0-9_-]*/" "$wt/$f" | grep -vq "^/home/$USER/$" && echo "$f"; done | sort -u)
  if [[ -z $hits ]]; then ok "${wt/#$HOME/\~}: sin rutas de otros usuarios"
  else todo "${wt/#$HOME/\~}: $(wc -l <<<"$hits") archivo(s) con /home/<otro>: $(head -5 <<<"$hits" | paste -sd' ')"; fi
done

step "Resumen"
if ((FAIL)); then echo "Hay pasos en rojo: resuélvelos y vuelve a ejecutar."; exit 1; fi
if ((CHECK)); then echo "Revisión terminada (sin cambios)."
else echo "Restauración terminada. Siguiente: $VAULT/assets/rebuild.sh --check y después sin --check."; fi
