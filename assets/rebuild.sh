#!/usr/bin/env bash
# Rebuild this playbook's machine state on a fresh Omarchy PC, up to the last completed chapter.
# Idempotent: every step checks first and skips what is already in place.
#
#   assets/rebuild.sh --check   report only, change nothing
#   assets/rebuild.sh           apply (asks for sudo only to create /zt)
#
# Human-only steps (gh auth login, cursor-agent login, Cursor User Rules) are checked, never done.
# Never invokes `claude`: on Omarchy that shim installs Claude Code through mise.
set -uo pipefail

CHECK=0
[[ ${1:-} == --check ]] && CHECK=1

VAULT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOME_ASSETS="$VAULT/assets/home"
CURSOR_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/cursor"
GH_USER=robert-flo
FAIL=0

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
todo() { printf '  \033[33m•\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; FAIL=1; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }
run()  { if ((CHECK)); then todo "pendiente: $*"; else "$@"; fi; }

step "0. Base"
[[ -r /usr/share/omarchy/default/bash/rc ]] && ok "Omarchy" || bad "no es Omarchy: este script asume su ~/.bashrc y mise"
for c in git gh jq mise curl; do command -v "$c" >/dev/null && ok "$c" || bad "falta $c"; done
command -v bun >/dev/null && ok "bun $(bun --version)" || run mise use -g bun
command -v cursor-agent >/dev/null && ok "cursor-agent $(cursor-agent --version 2>/dev/null)" \
  || { bad "falta cursor-agent"; run mise use -g cursor-agent; }

step "1. Pasos del humano (no se automatizan)"
gh auth status >/dev/null 2>&1 && ok "gh autenticado ($(gh api user -q .login 2>/dev/null))" \
  || bad "ejecuta: gh auth login   (GitHub.com, SSH, navegador)"
cursor-agent status 2>/dev/null | grep -q 'Logged in' && ok "cursor-agent logueado" \
  || bad "ejecuta: cursor-agent login"
todo "User Rules de Cursor (Settings → Rules → User Rules): copia los textos de la nota 10.4 si es otra cuenta"

step "2. Configuración de cursor-agent (Capítulo 2)"
mkdir -p "$CURSOR_CFG"
if cmp -s "$HOME_ASSETS/.config/cursor/statusline.sh" "$CURSOR_CFG/statusline.sh"; then ok "statusline.sh"
else run install -m 755 "$HOME_ASSETS/.config/cursor/statusline.sh" "$CURSOR_CFG/statusline.sh"; fi
cfg="$CURSOR_CFG/cli-config.json"
frag="$HOME_ASSETS/.config/cursor/cli-config.fragment.json"
if [[ -f $cfg ]] && jq -e --slurpfile f "$frag" '(.statusLine == $f[0].statusLine) and (.attribution == $f[0].attribution)' "$cfg" >/dev/null; then
  ok "cli-config.json (statusLine, attribution)"
elif ((CHECK)); then todo "pendiente: fusionar $frag en $cfg"
else
  if [[ -f $cfg ]]; then cp -a "$cfg" "$cfg.bak-$(date +%Y%m%d-%H%M%S)" || { bad "backup de $cfg falló"; exit 1; }
  else echo '{}' >"$cfg"; fi
  tmp=$(mktemp) && jq --slurpfile f "$frag" '. * $f[0]' "$cfg" >"$tmp" && mv "$tmp" "$cfg" && ok "cli-config.json fusionado (backup .bak-*)"
fi

step "3. Directorio compartido /zt y try (Preparación)"
if [[ -d /zt && $(stat -c %G /zt) == wheel ]]; then ok "/zt (grupo wheel)"
else run sudo bash -c 'install -d -m 2770 -o root -g wheel /zt && setfacl -m g:wheel:rwx,d:g:wheel:rwx /zt'; fi
if grep -q 'export TRY_PATH=/zt' ~/.bashrc; then ok "bloque try en ~/.bashrc"
elif ((CHECK)); then todo "pendiente: añadir assets/home/bashrc.zt-try.snippet a ~/.bashrc"
else cp -a ~/.bashrc ~/.bashrc.pre-zt.$(date +%Y%m%d-%H%M%S) && cat "$HOME_ASSETS/bashrc.zt-try.snippet" >>~/.bashrc && ok "bloque try añadido"; fi

step "4. Vault: submódulo nixfredOS"
if [[ -f $VAULT/nixfredOS/nixfredOS/INSTALL.md ]]; then ok "submódulo inicializado"
else run git -C "$VAULT" submodule update --init --depth 1; fi
if git -C "$VAULT/nixfredOS" remote get-url upstream >/dev/null 2>&1; then ok "nixfredOS: remoto upstream"
else run git -C "$VAULT/nixfredOS" remote add upstream https://github.com/nixfred/nixfredOS.git
  run git -C "$VAULT/nixfredOS" remote set-url --push upstream DISABLE; fi

step "5. Forks del stack en ~/Projects (Capítulo 4)"
mkdir -p ~/Projects
while read -r dir fork up extra; do
  if [[ -d ~/Projects/$dir/.git ]]; then ok "$dir"; continue; fi
  if ((CHECK)); then todo "pendiente: clonar $fork en ~/Projects/$dir"; continue; fi
  git clone -q $extra -b personal "git@github.com:$GH_USER/$fork.git" ~/Projects/"$dir" \
    && git -C ~/Projects/"$dir" remote add upstream "https://github.com/$up.git" \
    && git -C ~/Projects/"$dir" remote set-url --push upstream DISABLE \
    && ok "$dir clonado" || bad "no se pudo clonar $fork"
done <<'EOF'
nixbash       PJ-LARRY-fo-nixbash       nixfred/nixbash
lmf4.1        PJ-LARRY-fo-lmf4.1        nixfred/lmf4.1
nixnet        PJ-LARRY-fo-nixnet        nixfred/nixnet
claude-router PJ-LARRY-fo-claude-router nixfred/claude-router
claude-on-mac PJ-LARRY-fo-claude-on-mac nixfred/claude-on-mac
x.api         PJ-LARRY-fo-x.api         nixfred/x.api
infomarchy    PJ-LARRY-fo-infomarchy    nixfred/infomarchy
Telos         PJ-LARRY-fo-Telos         danielmiessler/Telos
Fabric        PJ-LARRY-fo-Fabric        danielmiessler/Fabric --depth=1
EOF

step "6. nixbash como capa sobre Omarchy (Paso 0)"
if grep -q 'nixbash/bashrc' ~/.bashrc && [[ -r ${XDG_DATA_HOME:-$HOME/.local/share}/nixbash/bashrc ]]; then ok "nixbash (modo capa)"
elif ((CHECK)); then todo "pendiente: instalar nixbash desde el fork"
else curl -sL "https://raw.githubusercontent.com/$GH_USER/PJ-LARRY-fo-nixbash/personal/install.sh" | bash; fi

step "7. Fabric CLI desde el fork (Capítulo 4)"
if command -v fabric >/dev/null; then ok "fabric $(fabric --version 2>/dev/null)"
elif ((CHECK)); then todo "pendiente: compilar ~/Projects/Fabric"
elif [[ -d ~/Projects/Fabric ]]; then
  (cd ~/Projects/Fabric && mise x go@1.27.2 -- go build -trimpath -o ~/.local/bin/fabric ./cmd/fabric) \
    && ok "fabric $(~/.local/bin/fabric --version)" || bad "falló la compilación de Fabric"
else bad "falta ~/Projects/Fabric (paso 5)"; fi
todo "fabric --setup se hace en el último paso (patterns/strategies apuntando al fork)"

step "Resumen"
if ((FAIL)); then echo "Hay pasos en rojo: resuélvelos y vuelve a ejecutar."; exit 1; fi
((CHECK)) && echo "Revisión terminada (sin cambios)." || echo "Máquina al día hasta el último capítulo cubierto por este script."
