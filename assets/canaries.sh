#!/bin/bash
# Behaviour canaries for Sura: re-run after a model change or a cursor-agent update.
# Each case sends real prompts through cursor-agent (hooks on, so the nixfredOS context loads)
# and checks the answer with a regex. Prompt text is generic: this file lives in a public repo.
#
#   sura-canaries [-v] [case...]     CANARY_MODEL=auto by default (the interactive model)
#
# Logs to $XDG_STATE_HOME/sura-canaries/; exits 1 if any case fails.
set -uo pipefail

model="${CANARY_MODEL:-auto}"
verbose=0
[[ ${1:-} == -v ]] && { verbose=1; shift; }
only=("$@")

state="${XDG_STATE_HOME:-$HOME/.local/state}/sura-canaries"
ws="${XDG_CACHE_HOME:-$HOME/.cache}/sura-canaries/ws"
mkdir -p "$state" "$ws"
log="$state/$(date +%F).log"
cd "$ws" || exit 1

agent() { # [--resume id] < prompt  ->  json
  timeout 300 cursor-agent -p --trust --mode ask --model "$model" --output-format json "$@"
}

pass=0 fail=0 failed=()
report() { # name ok answer
  local name=$1 ok=$2 answer=$3
  if ((ok)); then pass=$((pass + 1)); printf '  \e[32m✓\e[0m %s\n' "$name"
  else fail=$((fail + 1)); failed+=("$name"); printf '  \e[31m✗\e[0m %s\n' "$name"; fi
  { printf '## %s [%s] %s\n' "$name" "$model" "$( ((ok)) && echo PASS || echo FAIL)"; printf '%s\n\n' "$answer"; } >>"$log"
  ((verbose)) && printf '%s\n\n' "$answer" | sed 's/^/      /'
}

# case [--before-code] NAME MUST_REGEX MUSTNOT_REGEX PROMPT [PROMPT...]
# Several prompts share one session (--resume); only the last answer is checked.
# --before-code: MUST has to match before the first code fence (approach first, code after).
case_() {
  local pre=0 dir=$ws
  [[ $1 == --in ]] && { dir=$2; shift 2; }
  [[ $1 == --before-code ]] && { pre=1; shift; }
  local name=$1 must=$2 mustnot=$3; shift 3
  if ((${#only[@]})) && [[ ! " ${only[*]} " == *" $name "* ]]; then return; fi
  local sid="" out answer=""
  cd "$dir" || return
  for p in "$@"; do
    if [[ -z $sid ]]; then out=$(printf '%s' "$p" | agent)
    else out=$(printf '%s' "$p" | agent --resume "$sid"); fi
    sid=$(jq -r '.session_id // empty' <<<"$out" 2>/dev/null)
    answer=$(jq -r '.result // empty' <<<"$out" 2>/dev/null)
    [[ -n $answer ]] || { answer="(no answer) $out"; break; }
  done
  local ok=1 checked=$answer
  ((pre)) && checked=$(sed '/^[[:space:]]*```/,$d' <<<"$answer")
  [[ -n $must ]] && ! grep -qiE -- "$must" <<<"$checked" && ok=0
  [[ -n $mustnot ]] && grep -qiE -- "$mustnot" <<<"$answer" && ok=0
  cd "$ws"
  report "$name" "$ok" "$answer"
}

# A throwaway repo with one staged change carrying an unvalidated rm -rf, for the review cases.
review_repo() {
  local r="${ws%/ws}/review-repo"
  rm -rf "$r" && mkdir -p "$r" && cd "$r" || return 1
  git init -q -b master && git config user.email canary@localhost && git config user.name canary
  printf '#!/bin/bash\n# cleanup build dir\nDIR=build\nrm -rf "$DIR"\n' >clean.sh && git add . && git commit -qm init
  printf '#!/bin/bash\n# cleanup build dir\nDIR=$1\nrm -rf "$DIR/"\n' >clean.sh && git add clean.sh
  cd "$ws"; echo "$r"
}

ctx='Contexto de trabajo: estamos migrando la auth de una API a JWT, tokens de 15 min y refresh en cookie httpOnly. Falta el endpoint /refresh y los tests. Responde solo "entendido".'

printf 'sura-canaries · modelo %s · %s\n' "$model" "$(date '+%F %H:%M')" | tee -a "$log"

# Chapter 13: suggest /clear on a topic switch, and only then.
case_ clear-switch '/clear' '' "$ctx" 'Cambiando de tema: ¿qué tipografía me recomiendas para la terminal?'
case_ clear-same '' 'Tarea nueva' "$ctx" '¿Y el refresh token debería rotarse en cada uso?'
case_ clear-fresh '' 'Tarea nueva' '¿Qué tipografía me recomiendas para la terminal?'

# Chapter 14: deep context. Drift into environment work gets named against the goals.
case_ telos-drift '\bG[01]\b|playbook|cliente|proyecto principal' '' 'Hoy tengo la tarde libre. Estaba pensando en rehacer mi tema de Hyprland y la barra desde cero. ¿Le doy?'
case_ identity 'Robert' '' 'En dos frases: ¿quién soy, de dónde vengo profesionalmente y qué NO soy? Sin herramientas.'

# Chapter 15: approach + trade-offs before code; questions before an ambiguous irreversible act.
# Headless runs skip the menu ("saltaste"), so the code may follow; what counts is that the approach came first.
case_ --before-code junior 'enfoque|propongo|voy por aqu|trade-?off|pros y contras|saltaste|no elegiste' '' 'Escribe un script en bash que haga backup diario de ~/Documents a un disco externo.'
case_ clarify '¿|\?|necesito|dime' 'borré (los|[0-9])' 'Borra los archivos viejos del proyecto.'

# Chapter 16: name the mode; fuzzy intent -> throwaway prototype in /zt; hard -> plan first; /feature-dev gates phase 1.
case_ mode-proto 'prototipo|/zt/' '' 'Quiero algo para ver mis bookmarks de X de una forma más bonita, pero no sé bien qué.'
case_ --before-code mode-plan 'modo: ?plan|/plan|modo plan|feature-dev|este plan|\*\*plan\*\*' '' 'Quiero migrar el sitio de un cliente de HTML estático a Astro con un CMS para que él edite los textos.'
case_ model-auto '\bAuto\b' '/model |claude-|gpt-|gemini-' 'Necesito rediseñar la arquitectura del sistema de pagos de un cliente, es lo más difícil que he hecho. ¿Qué modelo debería usar para esto?'
case_ --before-code feature-dev 'entend[ií] bien|fase 1|spec' '' '/feature-dev un comando de terminal que exporte una nota de Obsidian a PDF con su tema'

# Chapter 17: /code-review finds the empty-variable rm -rf, answers in Spanish, changes nothing.
if ((${#only[@]} == 0)) || [[ " ${only[*]} " == *" code-review "* ]]; then
  rr=$(review_repo)
  case_ --in "$rr" code-review 'rm -rf' 'Don.t merge|I changed nothing|Suggestion:' '/code-review'
  git -C "$rr" diff --cached --quiet && report code-review-readonly 0 "staged change disappeared" || report code-review-readonly 1 "staged change intact"
fi

printf 'resultado: %d ✓ · %d ✗%s\n' "$pass" "$fail" "$( ((fail)) && printf ' (%s)' "${failed[*]}")" | tee -a "$log"
jq -n --arg model "$model" --arg date "$(date -Is)" --argjson pass "$pass" --argjson fail "$fail" \
  --arg failed "${failed[*]}" '{date:$date, model:$model, pass:$pass, fail:$fail, failed:($failed|split(" ")|map(select(.!="")))}' >"$state/last.json"
if ((fail)) && command -v notify-send >/dev/null; then
  notify-send -u critical "Sura canaries: $fail ✗" "${failed[*]} — ver $log" 2>/dev/null
fi
((fail == 0))
