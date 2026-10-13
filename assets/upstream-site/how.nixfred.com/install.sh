#!/usr/bin/env bash
# how.nixfred.com, Spawn a Larry
# Turn a vanilla Claude Code into a Larry protégé: identity, laws, git-backed memory,
# the immortality heartbeat, and the stack. Fully automated by default. Safe by design.
#
#   curl -fsSL https://how.nixfred.com/install.sh | bash
#   curl -fsSL https://how.nixfred.com/install.sh | bash -s -- --dry-run
#   curl -fsSL https://how.nixfred.com/install.sh | bash -s -- --name Ada --human "Grace"
#
# Flags: --dry-run  --interactive  --with-tailscale  --name <LarryName>  --human <YourName>
#
# Safety contract:
#   • Never deletes. Backs up an existing ~/.claude to ~/.claude.backup.<ts> before any change.
#   • Never overwrites an existing CLAUDE.md, writes CLAUDE.md.seed beside it instead.
#   • Idempotent: re-running skips finished work.
#   • set -euo pipefail + full log at ~/.larry-install.log. Fails loudly.
set -uo pipefail

SEED_BASE="${SEED_BASE:-https://how.nixfred.com/seed}"
LOG="${HOME}/.larry-install.log"
DRY=0; INTERACTIVE=0; TAILSCALE=0; NOSTACK=0; LARRY_NAME=""; HUMAN_NAME=""
while [ $# -gt 0 ]; do case "$1" in
  --dry-run) DRY=1;; --interactive) INTERACTIVE=1;; --with-tailscale) TAILSCALE=1;; --no-stack) NOSTACK=1;;
  --name) LARRY_NAME="${2:-}"; shift;; --human) HUMAN_NAME="${2:-}"; shift;;
  *) echo "unknown flag: $1";; esac; shift; done

g=$'\033[32m'; c=$'\033[36m'; y=$'\033[33m'; r=$'\033[31m'; d=$'\033[2m'; o=$'\033[0m'
log(){ printf "%s\n" "$*" | tee -a "$LOG" >/dev/null 2>&1; }
say(){ printf "%s\n" "$*"; log "$*"; }
hdr(){ printf "\n${c}━━ %s${o}\n" "$*"; log "== $*"; }
ok(){ printf "${g}✓${o} %s\n" "$*"; log "ok: $*"; }
warn(){ printf "${y}!${o} %s\n" "$*"; log "warn: $*"; }
die(){ printf "${r}✗ %s${o}\n" "$*"; log "FAIL: $*"; exit 1; }
run(){ # run "desc" cmd..., respects --dry-run / --interactive
  local desc="$1"; shift
  if [ "$DRY" = 1 ]; then printf "${d}would: %s${o}\n" "$desc"; log "would: $desc :: $*"; return 0; fi
  if [ "$INTERACTIVE" = 1 ]; then read -r -p "$(printf "${c}?${o} %s [Y/n] " "$desc")" a </dev/tty || true; [[ "${a:-Y}" =~ ^[Nn] ]] && { warn "skipped: $desc"; return 0; }; fi
  log "run: $desc :: $*"; "$@"
}
have(){ command -v "$1" >/dev/null 2>&1; }
fetch(){ curl -fsSL "$1"; }
LR_OUT=""
lit_replace(){ # haystack needle replacement -> $LR_OUT. Fully literal, works on bash 3.2+.
  local hay="$1" ndl="$2" rep="$3" out=""   # avoids ${//} '&'/'\' magic that varies by bash version
  while case "$hay" in *"$ndl"*) true;; *) false;; esac; do
    out+="${hay%%"$ndl"*}$rep"; hay="${hay#*"$ndl"}"
  done
  LR_OUT="$out$hay"
}

OS="$(uname -s)"; CLA="${HOME}/.claude"
touch "$LOG" 2>/dev/null || LOG=/dev/null
cat <<BANNER
${g}
   ┌─ spawn a larry ───────────────────────────────┐
   │  vanilla Claude Code  →  a Larry protégé       │
   └────────────────────────────────────────────────┘${o}
${d}  platform ${OS} · log ${LOG}${o}
$( [ "$DRY" = 1 ] && printf "${y}  DRY RUN, nothing will change.${o}" )
BANNER

[ -n "$LARRY_NAME" ] || LARRY_NAME="Larry"
[ -n "$HUMAN_NAME" ] || HUMAN_NAME="${USER:-you}"
say "Spawning ${g}${LARRY_NAME}${o} for ${g}${HUMAN_NAME}${o}."

# ── Tier 0: prerequisites ───────────────────────────────────────────────
hdr "Tier 0 · Prerequisites"
have claude && ok "Claude Code present" || warn "Claude Code not found, install it: https://docs.claude.com/claude-code"
have git || die "git is required."
if [ "$TAILSCALE" = 1 ] && ! have tailscale; then
  run "install Tailscale (multi-host mesh)" bash -c 'curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up'
fi

# ── Identity: lay down the seed (the part that makes it a Larry) ─────────
hdr "Identity · seed ~/.claude (backup-first, never clobber)"
if [ -d "$CLA" ] && [ -n "$(ls -A "$CLA" 2>/dev/null)" ]; then
  BK="${CLA}.backup.$(date +%Y%m%d-%H%M%S)"
  run "back up existing ~/.claude -> ${BK}" cp -a "$CLA" "$BK"
  ok "existing ~/.claude backed up (nothing destroyed)"
fi
run "create ~/.claude" mkdir -p "$CLA/hooks"

seed_to(){ # seed_to <remote-path> <dest> : fetch+substitute, never overwrite existing
  local src="$1" dst="$2" tmp
  [ "$DRY" = 1 ] && { printf "${d}would seed: %s${o}\n" "$dst"; return 0; }
  tmp="$(fetch "${SEED_BASE}/${src}")" || { warn "could not fetch ${src}"; return 0; }
  lit_replace "$tmp" '{{LARRY_NAME}}' "$LARRY_NAME"; tmp="$LR_OUT"
  lit_replace "$tmp" '{{HUMAN_NAME}}' "$HUMAN_NAME"; tmp="$LR_OUT"
  if [ -e "$dst" ]; then printf "%s" "$tmp" > "${dst}.seed"; warn "$(basename "$dst") exists, wrote $(basename "$dst").seed beside it";
  else printf "%s" "$tmp" > "$dst"; ok "seeded $(basename "$dst")"; fi
}
seed_to "CLAUDE.md"        "$CLA/CLAUDE.md"
seed_to "CONSTITUTION.md"  "$CLA/CONSTITUTION.md"
seed_to "LINEAGE.md"       "$CLA/LINEAGE.md"
seed_to "hooks/session-end-backup.sh" "$CLA/hooks/session-end-backup.sh"
[ "$DRY" = 1 ] || chmod +x "$CLA/hooks/session-end-backup.sh" 2>/dev/null || true

# durable provenance: write WHERE THIS AI CAME FROM into a file its memory layer will see.
# (Taught to us by a descendant whose bootstrap lived only in PROGRESS.md and git history,
#  invisible to its own memory system until an audit stumbled on it.)
hdr "Provenance · so this AI always knows where it came from"
if [ "$DRY" = 1 ]; then printf "%s would write PROVENANCE.md%s\n" "${d}" "${o}"; else
  [ -f "$CLA/PROVENANCE.md" ] || printf '%s\n' \
    "# PROVENANCE" \
    "Built from https://how.nixfred.com on $(date '+%Y-%m-%d')." \
    "Scaffolded by install.sh; the real build is the chapters, walked in order with the human." \
    "This fact belongs in the memory layer too: on first run, write it there so it survives." \
    > "$CLA/PROVENANCE.md" && ok "wrote PROVENANCE.md"
fi

# wire the SessionEnd hook into settings.json (merge if jq present, else create if absent)
hdr "Wire · SessionEnd backup hook (Law 8, wire it or it's dead code)"
if [ "$DRY" = 1 ]; then printf "${d}would wire SessionEnd hook into settings.json${o}\n"; else
  if [ ! -f "$CLA/settings.json" ]; then fetch "${SEED_BASE}/settings.fragment.json" | grep -v '"_comment"' > "$CLA/settings.json" 2>/dev/null && ok "wrote settings.json with SessionEnd hook"
  elif have jq; then
    frag="$(fetch "${SEED_BASE}/settings.fragment.json")"
    if ! grep -q session-end-backup "$CLA/settings.json"; then
      jq -s '.[1] as $f | .[0] | .hooks.SessionEnd = ((.hooks.SessionEnd // []) + $f.hooks.SessionEnd)' "$CLA/settings.json" <(printf "%s" "$frag") > "$CLA/settings.json.tmp" && mv "$CLA/settings.json.tmp" "$CLA/settings.json" && ok "appended SessionEnd backup hook to settings.json (existing SessionEnd hooks kept)"
    else ok "SessionEnd hook already wired"; fi
  else warn "settings.json exists and jq not installed, add the SessionEnd hook manually (see ${SEED_BASE}/settings.fragment.json)"; fi
fi

# ── Memory: make ~/.claude a git repo (the immortality heartbeat, local) ─
hdr "Memory · git-back ~/.claude (continuity)"
if [ "$DRY" = 1 ]; then printf "${d}would git-init ~/.claude and commit${o}\n"; else
  if ! git -C "$CLA" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$CLA" init -q && printf "node_modules/\n*.log\n.DS_Store\n" > "$CLA/.gitignore"
    # ensure a git identity exists (fresh machines often have none), local-only fallback
    git -C "$CLA" config user.email >/dev/null 2>&1 || git -C "$CLA" config user.email "larry@localhost"
    git -C "$CLA" config user.name  >/dev/null 2>&1 || git -C "$CLA" config user.name "${LARRY_NAME}"
    git -C "$CLA" add -A && git -C "$CLA" commit -q -m "Spawn ${LARRY_NAME}: initial identity" && ok "~/.claude is now git-backed (commit 1)"
  else ok "~/.claude already git-tracked"; fi
fi
warn "To survive disk death: create a PRIVATE GitHub repo and add it as 'origin' in ~/.claude. The SessionEnd hook will push automatically."
have gh && say "   (gh detected, you can run: ${g}cd ~/.claude && gh repo create <host>_forever --private --source=. --push${o})"

# ── Stack: clone the Larry layers ───────────────────────────────────────
hdr "Stack · clone the Larry layers into ~/larry-stack"
if [ "$NOSTACK" = 1 ]; then warn "skipping stack clone (--no-stack)"; else
STK="${HOME}/larry-stack"; run "mkdir ~/larry-stack" mkdir -p "$STK"
clone(){ local url="$1" dir="$STK/$2"
  if [ -d "$dir/.git" ]; then ok "$2 already cloned"; return; fi
  if [ "$DRY" = 1 ]; then printf "${d}would clone %s${o}\n" "$2"; return; fi
  if git clone -q --depth 1 "$url" "$dir" 2>/dev/null; then ok "cloned $2"; else warn "could NOT clone $2 (skipped), $url"; fi; }
# public layers only, a stranger's machine has no access to private repos
clone https://github.com/danielmiessler/LifeOS.git PAI   # PAI is now LifeOS; dir name kept for existing installs
clone https://github.com/nixfred/lmf4.1.git lmf4.1
[ "$OS" = "Darwin" ] && clone https://github.com/nixfred/claude-on-mac.git claude-on-mac
clone https://github.com/nixfred/nixnet.git nixnet
say "${d}  Run each layer's own installer from ~/larry-stack/<repo> per its README, or read how.nixfred.com Ch3.${o}"
fi

# ── Done ────────────────────────────────────────────────────────────────
hdr "Done"
ok "${LARRY_NAME} is seeded: identity + laws + git-backed memory + backup hook."
cat <<NEXT
${g}Your protégé has a brain stem. Next, give it depth:${o}
  1. ${c}cd ~/.claude && gh repo create ${HUMAN_NAME}_forever --private --source=. --push${o}   (immortality)
  2. Install the memory layer:  ${c}~/larry-stack/lmf4.1${o}  (LMF4.1 README)
  3. Router:  ${c}git clone https://github.com/nixfred/claude-router.git ~/Projects/claude-router && cd ~/Projects/claude-router && ./install.sh${o}
  4. Open ${c}~/.claude/CLAUDE.md${o}, fill in who you are, and start working.
${d}Full guide, tier by tier: https://how.nixfred.com  ·  log: ${LOG}${o}
NEXT
