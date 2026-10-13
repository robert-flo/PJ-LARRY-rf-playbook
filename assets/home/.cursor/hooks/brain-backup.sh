#!/usr/bin/env bash
# Commits and pushes the private brain repos: ~/.claude (sura-brain) and the nixfredOS USER tree
# (sura-brain-user, behind the NIXFREDOS/USER symlink). Adapted from how.nixfred.com's
# seed/hooks/session-end-backup.sh (playbook Chapter 7). sura-conversations is memory-backup's job.
#
#   brain-backup.sh               Cursor sessionEnd hook: answers {} and backs up in the background
#   brain-backup.sh --foreground  run in place (systemd timer, manual)
set -uo pipefail

if [[ ${1:-} != --foreground ]]; then
  cat >/dev/null
  setsid "$0" --foreground </dev/null >/dev/null 2>&1 &
  echo '{}'
  exit 0
fi

root="${NIXFREDOS_CONFIG_ROOT:-$HOME/.claude}"
log="$HOME/.local/state/brain-backup.log"
mkdir -p "${log%/*}"
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/brain-backup.lock"
flock -n 9 || exit 0

# A stalled push must not hang the heartbeat forever.
export GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=20
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh} -o ConnectTimeout=15 -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -o BatchMode=yes"

ts=$(date '+%Y-%m-%d %H:%M:%S')
say() { printf '%s %s\n' "$(date -Is)" "$*" >>"$log"; }

backup_repo() {
  local dir=$1 name
  git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  name=$(basename "$(git -C "$dir" remote get-url origin 2>/dev/null || echo "$dir")" .git)
  if [[ -n $(git -C "$dir" status --porcelain) ]]; then
    git -C "$dir" add -A >/dev/null 2>&1
    git -C "$dir" commit -q --no-gpg-sign -m "SessionEnd backup ${ts}" >/dev/null 2>&1 || { say "$name: commit failed"; return 0; }
    say "$name: committed"
  fi
  if git -C "$dir" remote get-url origin >/dev/null 2>&1; then
    if [[ -n $(git -C "$dir" log --oneline '@{u}..' 2>/dev/null) ]] || ! git -C "$dir" rev-parse '@{u}' >/dev/null 2>&1; then
      if git -C "$dir" push -q origin HEAD >/dev/null 2>&1; then say "$name: pushed"; else say "$name: push failed"; fi
    fi
  fi
}

backup_repo "$root"
if [[ -L $root/NIXFREDOS/USER ]]; then
  user_dir=$(cd "$root/NIXFREDOS/USER" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)
  [[ -n $user_dir && $user_dir != "$root" ]] && backup_repo "$user_dir"
fi
exit 0
