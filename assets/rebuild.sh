#!/usr/bin/env bash
# Rebuild this playbook's machine state on a fresh Omarchy PC, up to the last completed chapter.
# Idempotent: every step checks first and skips what is already in place.
#
#   assets/rebuild.sh --check   report only, change nothing
#   assets/rebuild.sh           apply (asks for sudo only to create /zt)
#
# Human-only steps (gh auth login, cursor-agent login, Cursor User Rules, identity edits) are checked, never done.
# Never invokes `claude`: on Omarchy that shim installs Claude Code through mise; step 8 replaces it with a guard.
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

NFOS=~/.claude/skills/nixfredOS
nfos() { (cd "$NFOS" && bun "Tools/$1.ts" --config-root ~/.claude "${@:2}" >/dev/null) && ok "nixfredOS $1" || bad "nixfredOS $1 falló"; }
same() { cmp -s "$1" "$2"; }
put() { # src dst mode
  if same "$1" "$2"; then ok "${2/#$HOME/\~}"
  elif ((CHECK)); then todo "pendiente: instalar ${2/#$HOME/\~}"
  else install -D -m "$3" "$1" "$2" && ok "${2/#$HOME/\~} instalado"; fi
}

step "8. Guardia de claude (Capítulo 5)"
put "$HOME_ASSETS/.local/bin/claude" ~/.local/bin/claude 755

step "9. nixfredOS Core en ~/.claude (Capítulo 5)"
if [[ -f $NFOS/INSTALL.md ]]; then ok "skill nixfredOS"
elif ((CHECK)); then todo "pendiente: copiar el submódulo a $NFOS"
else
  [[ -d ~/.claude ]] && tar -C ~ -czf ~/.claude.backup.$(date +%Y%m%d-%H%M%S).tgz .claude
  mkdir -p ~/.claude/skills && cp -R "$VAULT/nixfredOS/nixfredOS" "$NFOS" && ok "skill nixfredOS copiada (snapshot previo en ~/.claude.backup.*.tgz)"
fi
if [[ -f ~/.claude/NIXFREDOS/NIXFREDOS_SYSTEM_PROMPT.md ]]; then ok "DeployCore"
elif ((CHECK)); then todo "pendiente: DeployCore"
else nfos DeployCore --apply; fi
if [[ -f ~/.claude/CLAUDE.md ]]; then ok "CLAUDE.md"
else run cp "$NFOS/install/CLAUDE.template.md" ~/.claude/CLAUDE.md; fi
if jq -e '.env.NIXFREDOS_DIR' ~/.claude/settings.json >/dev/null 2>&1; then ok "InstallSettings"
elif ((CHECK)); then todo "pendiente: InstallSettings"
else nfos InstallSettings --apply; fi
if [[ -L ~/.claude/NIXFREDOS/USER ]]; then ok "árbol USER enlazado (${XDG_CONFIG_HOME:-~/.config}/NIXFREDOS/USER)"
elif ((CHECK)); then todo "pendiente: ScaffoldUser + LinkUser (o restaurar USER desde el repo privado, Cap. 8)"
else nfos ScaffoldUser --apply && nfos LinkUser --apply
  todo "identidad: editar NIXFREDOS_CONFIG.toml, DA_IDENTITY.md y PRINCIPAL_IDENTITY.md (nota 02.5) y volver a ejecutar"; fi
if grep -q '^@NIXFREDOS/USER/DIGITAL_ASSISTANT/DA_IDENTITY.md' ~/.claude/CLAUDE.md 2>/dev/null; then ok "ActivateImports"
elif ((CHECK)); then todo "pendiente: ActivateImports"
else nfos ActivateImports --apply; fi
if [[ -f ~/.claude/hooks/LoadContext.hook.ts ]]; then ok "InstallHooks"
elif ((CHECK)); then todo "pendiente: InstallHooks"
else nfos InstallHooks --apply; fi
if [[ -d ~/.claude/agents ]] && systemctl --user is-enabled -q com.nixfredos.pulse.service 2>/dev/null; then ok "DeployComponents (agents, commands, pulse, worksweep, derivedsync, usage-aggregator)"
elif ((CHECK)); then todo "pendiente: DeployComponents"
else nfos DeployComponents --components agents,commands,pulse,worksweep,derivedsync,usage-aggregator --apply; fi
if systemctl --user is-enabled -q com.nixfredos.interviewdue.timer 2>/dev/null; then ok "servicio interviewdue"
else run bun ~/.claude/NIXFREDOS/TOOLS/Services.ts install --only interviewdue --yes; fi

step "10. Memory engine (Capítulo 5)"
if [[ -x ~/bin/mem ]]; then ok "memory-engine instalado"
elif ((CHECK)); then todo "pendiente: memory-engine (install/memory-engine/install)"
else (cd "$NFOS/install/memory-engine" && ./install >/dev/null) && ok "memory-engine instalado (su paso 'claude mcp add' falla a propósito)"; fi
if [[ -f ~/.claude/memory.db ]] && DB=~/.claude/memory.db bun -e 'const {Database}=require("bun:sqlite");process.exit(new Database(process.env.DB,{readonly:true}).query("select 1 from pragma_table_info(\"sessions\") where name=\"git_branch\"").get()?0:1)'; then
  ok "memory.db con el esquema de mem"
elif ((CHECK)); then todo "pendiente: recrear memory.db con mem init (el instalador crea un esquema viejo)"
else
  [[ -f ~/.claude/memory.db ]] && mv ~/.claude/memory.db ~/.claude/memory.db.installer-schema.$(date +%Y%m%d-%H%M%S).bak
  ~/bin/mem init >/dev/null && ok "memory.db recreada con mem init"
fi
if [[ $(readlink ~/.local/bin/mem) == "$HOME/bin/mem" ]]; then ok "mem en el PATH"
else run ln -sfn ~/bin/mem ~/.local/bin/mem; fi
if ((CHECK)); then
  bun "$VAULT/assets/nixfredos-substitute.ts" --check >/dev/null 2>&1 && ok "placeholders de identidad" || todo "pendiente: bun assets/nixfredos-substitute.ts"
else
  bun "$VAULT/assets/nixfredos-substitute.ts" && ok "placeholders de identidad" || bad "quedan placeholders (¿falta la identidad en NIXFREDOS_CONFIG.toml?)"
fi

step "11. Adaptadores de Cursor (Capítulo 5)"
for f in nixfredos-context.sh claude-hooks-gate.sh claude-plain2json.sh wrap-claude-hooks.sh cursor-transcripts-sync.sh cursor-transcripts-sync.ts; do
  put "$HOME_ASSETS/.cursor/hooks/$f" ~/.cursor/hooks/"$f" 755
done
put "$HOME_ASSETS/.cursor/hooks.json" ~/.cursor/hooks.json 644
put "$HOME_ASSETS/.cursor/mcp.json" ~/.cursor/mcp.json 644
if ~/.cursor/hooks/wrap-claude-hooks.sh --check >/dev/null 2>&1; then ok "hooks de Claude envueltos (claude-plain2json)"
else run ~/.cursor/hooks/wrap-claude-hooks.sh; fi
for u in cursor-transcripts-sync.service cursor-transcripts-sync.timer; do
  put "$HOME_ASSETS/.config/systemd/user/$u" ~/.config/systemd/user/"$u" 644
done
if systemctl --user is-enabled -q cursor-transcripts-sync.timer 2>/dev/null; then ok "timer cursor-transcripts-sync"
elif ((CHECK)); then todo "pendiente: activar cursor-transcripts-sync.timer"
else systemctl --user daemon-reload && systemctl --user enable --now cursor-transcripts-sync.timer && ok "timer cursor-transcripts-sync activo"; fi

step "12. Extras opcionales (Capítulo 5)"
VOICE=~/.local/share/piper/voices/es_MX-claude-high.onnx
command -v espeak-ng >/dev/null && ok "espeak-ng" || run sudo pacman -S --needed --noconfirm espeak-ng
command -v piper-tts >/dev/null && ok "piper-tts" || run yay -S --needed --noconfirm piper-tts-bin
[[ -L /usr/local/bin/piper ]] && ok "/usr/local/bin/piper" || run sudo ln -sfn /usr/bin/piper-tts /usr/local/bin/piper
if [[ -s $VOICE && -s $VOICE.json ]]; then ok "voz piper es_MX-claude-high"
elif ((CHECK)); then todo "pendiente: descargar la voz es_MX-claude-high"
else mkdir -p "${VOICE%/*}" && for x in "" .json; do
  curl -fsSL -o "$VOICE$x" "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_MX/claude/high/es_MX-claude-high.onnx$x"; done && ok "voz descargada"; fi
if [[ -f ~/.claude/voice.json ]]; then ok "voice.json"
elif ((CHECK)); then todo "pendiente: voice.json (piper) y nixfredos-voice on"
else jq -n --arg m "$VOICE" '{enabled:true, engine:"auto", elevenlabs_voice_id:"", elevenlabs_model:"eleven_turbo_v2_5", say_voice:"", piper_model:$m, volume:1.0, speaker:"", listen:false, wake_word:"", mic:""}' >~/.claude/voice.json \
  && systemctl --user restart com.nixfredos.pulse.service && ok "voz activada (nixfredos-voice off para silenciar)"; fi
IV=2.1.0; ID=~/.local/share/interceptor/$IV
if [[ -x $ID/dist/interceptor && $(readlink ~/.local/bin/interceptor) == "$ID/dist/interceptor" ]]; then ok "interceptor $IV (CLI + native host)"
elif ((CHECK)); then todo "pendiente: Interceptor $IV (tarball Browser linux-x64)"
else
  t=$(mktemp -d) && gh release download "v$IV" -R Hacker-Valley-Media/Interceptor -D "$t" -p "Interceptor-Browser-$IV-linux-x64.tar.gz" -p SHA256SUMS \
    && (cd "$t" && grep "Browser-$IV-linux-x64" SHA256SUMS | sha256sum -c --quiet -) \
    && mkdir -p "$ID" && tar -xzf "$t/Interceptor-Browser-$IV-linux-x64.tar.gz" -C "$ID" --strip-components=1 \
    && bash "$ID/scripts/install.sh" --browser-only --chrome --skip-extension </dev/null >/dev/null \
    && ln -sfn "$ID/dist/interceptor" ~/.local/bin/interceptor && ok "interceptor $IV instalado" || bad "falló Interceptor"
fi
todo "humano: codex login · extensión Interceptor en un perfil de prueba de Chrome · CLOUDFLARE_API_TOKEN en ~/.claude/.env"

step "Resumen"
if ((FAIL)); then echo "Hay pasos en rojo: resuélvelos y vuelve a ejecutar."; exit 1; fi
((CHECK)) && echo "Revisión terminada (sin cambios)." || echo "Máquina al día hasta el último capítulo cubierto por este script."
