---
title: "Progreso del Playbook (Ledger)"
tags:
  - progreso
  - ledger
aliases:
  - Ledger
  - Progreso
  - PROGRESS
date: 2026-10-12
---

# 📒 Progreso del Playbook (Ledger)

> [!NOTE]
> **Navegación:** [[00 - Indice General (MOC)|Índice General]]
>
> Equivale al `~/.claude/PROGRESS.md` del sitio original. Un agente que empieza una sesión nueva lee esta nota primero para saber dónde vamos. Se actualiza al cerrar cada capítulo, con fecha y evidencia.

## Estado actual

- **Último completado:** [[07.26 - Capitulo 26 - Conectores|Capítulo 26 — Conectores]].
- **Siguiente:** Capítulo 27 — Más allá del chat: escritorio, archivos y carpetas ([[assets/upstream-site/how.nixfred.com/27-beyond-chat|original]]). Para retomar: `/seguir` en el vault.

## Registro

| Fecha | Capítulo | Estado | Evidencia / notas |
|---|---|---|---|
| 2026-10-12 | Preparación | ✅ Hecho | Vault creado, sitio archivado en `assets/upstream-site/`, 10 forks `PJ-LARRY-fo-*` con rama `personal`, submódulo `nixfredOS/`. Ver [[10.2 - Repositorios Upstream y Forks\|10.2]]. |
| 2026-10-12 | Paso 0 | ✅ Hecho | `cursor-agent` logueado, modo `--force`, plan Pro anual. nixbash como capa sobre Omarchy ([PJ-LARRY-fo-nixbash#1](https://github.com/robert-flo/PJ-LARRY-fo-nixbash/pull/1)). Tailscale pospuesto al Cap. 6. |
| 2026-10-12 | Capítulo 1 | ✅ Hecho | Modelo mental (sin instalación). Nivel del humano: avanzado. Línea base del harness en [[01.1 - Capitulo 1 - El Paradigma de la Terminal\|la nota]]. |
| 2026-10-12 | Capítulo 2 | ✅ Hecho | `AGENTS.md` cargado por `cursor-agent` (verificado). Barra de estado en `~/.config/cursor/statusline.sh`. Atribución de commits/PRs desactivada. Sin `/init` ni `/voice` en el CLI. |
| 2026-10-12 | Capítulo 3 | ✅ Hecho | Hábito de opciones y nivel avanzado como User Rules de Cursor (globales; `~/.cursor/rules` no lo es). Verificado desde `/tmp`. |
| 2026-10-12 | Capítulo 4 | ✅ Hecho | Forks del stack clonados en `~/Projects`. Datos de nixfredOS en `~/.claude`. Fabric CLI v1.4.518 compilado desde el fork. Claude Code instalado por accidente vía el shim de Omarchy y revertido. |
| 2026-10-12 | Capítulo 5 | ✅ Hecho | nixfredOS Core + componentes desde el submódulo; asistente **Sura**, principal **Robert**. Constitución por hook `sessionStart`; hooks de Claude funcionando en `cursor-agent` (gate de `beforeSubmitPrompt`, envoltura a JSON, límite de 10.000 caracteres). Memoria: `memory.db` con 40 sesiones, MCP `nixfredos-memory`, sync de transcripts de Cursor. Voz piper en español, Interceptor 2.1.0. Guardia en lugar del shim `claude`. Segmento de nixfredOS en la barra de estado. `rebuild.sh` pasos 8–12. |
| 2026-10-12 | Capítulo 6 | ✅ Hecho | `omarchy-install-service-tailscale`; PC `her` (`100.87.210.6`) en `tail74414e.ts.net`, MagicDNS, Tailscale SSH (sin `sshd`), operador, Taildrop y widget. Puertos revisados antes de unirse. `rebuild.sh` paso 13. Pendiente: probar SSH desde otro nodo. |
| 2026-10-12 | Capítulo 7 | ✅ Hecho | Cuatro repos `PRIVATE`: `sura-brain` (`~/.claude`, 42 MB sin `node_modules`), `sura-brain-user` (árbol USER), `sura-conversations` (`memory-backup`) y `sura-home` (dotbare, 268 archivos). Secretos incluidos (decisión del humano). `brain-backup.sh` en `sessionEnd` + timer horario, probado con una sesión real. `gup` con excepción de `master` solo en los repos de backup. `rebuild.sh` paso 14. |
| 2026-10-12 | Capítulo 8 | ✅ Hecho | Hook de pacman → `~/.config/pkglist/{pacman,aur}.txt` (230 + 12) en `sura-home`. `assets/restore.sh` (dotbare, paquetes, tres repos de nixfredOS, `bun install`, reubicación de `/home/gracie`). Restore probado en el usuario permanente `melitta`: Sura responde como `melitta` con memoria y hooks. Arreglos de la prueba: config de Git con `~/`, operador de Tailscale, timer restaurado. `rebuild.sh` paso 15. |
| 2026-10-12 | Capítulo 9 | ✅ Hecho | Árbol USER con lo básico de Robert (idioma, foco, forma de trabajar) y sus convenciones en `OPERATIONAL_RULES.md`. Estilo y verificación de nixfredOS sin cambios. Correcciones permanentes escritas sin preguntar: probado con una sesión real (formato de 24 h) y empujado por `brain-backup`. |
| 2026-10-12 | Capítulo 10 | ✅ Hecho | Todo en `~/Projects/<repo>`: 22 repos clonados y el vault, los playbooks de niri y `assets` movidos desde `/zt`. `USER/PROJECTS.md` con 25 proyectos, visibilidad, rol, alias y regla de privacidad; verificado con `cursor-agent`. `AGENTS.md` en `assets` ([assets#3](https://github.com/robert-flo/assets/pull/3)). `rebuild.sh` paso 16. |
| 2026-10-12 | Capítulo 11 | ✅ Hecho | La guardia `claude` ahora responde las llamadas `--print` con `cursor-agent` (modelo `composer-2.5`, `HOME` aislado, sin hooks). ConfigEval corre por primera vez: 90 %. `LMF4_EXTRACT_MODEL=auto`: primera extracción real (3 LoA, 4 decisiones). Ollama solo con `nomic-embed-text` + timer `memory-embed`: 841 embeddings, búsqueda semántica verificada. "Remember" escribe en el mismo turno. `rebuild.sh` pasos 8 y 17; [sura-home#3](https://github.com/robert-flo/sura-home/pull/3). |
| 2026-10-13 | Capítulo 12 | ✅ Hecho | `/check` (apunta a Verification №2 y al estilo de `DA_IDENTITY.md`) y `/pr` globales en `~/.claude/commands`; skill `cerrar-capitulo` con plantilla y `/seguir` en el vault. `cursor-agent` carga comandos y skills globales y del proyecto (canarios). `/check` exigió evidencia ante un "debería funcionar". |
| 2026-10-13 | Capítulo 13 | ✅ Hecho | Equivalentes: `/context`, `/summarize` (sin argumento), `/clear`, `/rewind`. Comando global `/relevo <foco>` para dirigir el resumen. Barra de contexto amarilla al 60 %. Regla en `OPERATIONAL_RULES.md`: Sura propone `/clear` al cambiar de tema (3 de 3 con `auto`; `composer-2.5` no). Base fija medida: ~26k tokens, se mantiene. `rebuild.sh` paso 2 fija `rewind`. |
| 2026-10-13 | Capítulo 14 | ✅ Hecho | Entrevista TELOS con menús (cinco bloques); `TELOS.md` con las palabras de Robert en `sura-brain-user` (privado; nada copiado al vault). Purga `clean`, filtro de contexto propio en lugar del fijo del generador, resumen regenerado. Regla "Deep context": leer el archivo completo ante preguntas estratégicas y frenar desvíos al entorno. Dos canarios responden contra las metas. |
| 2026-10-13 | Capítulo 15 | ✅ Hecho | Reglas "How we work together": enfoque y pros y contras antes de código no trivial, preguntas sin tope en menús, cambio de enfoque al dar vueltas. `sura-canaries` (7 casos de los Caps. 13–15) + timer semanal: 7 de 7 con `auto`. El sync de transcripts ya no importa bancos de prueba (`~/.cache`, `/tmp`). `rebuild.sh` paso 18. Memoria limpiada: 53 sesiones de prueba fuera, quedan 10 reales (copia previa en `~/.local/share/`). |
| 2026-10-13 | Capítulo 16 | ✅ Hecho | Modo Plan de serie (`Shift+Tab`, `/plan`). Regla "Name the mode first" (prototipo en `/zt` / directo / plan). `/feature-dev` global: pregunta → `spec.md` → `plan.md` → tareas con verificación → cierre con evidencia, con aprobación por menú. `sura-canaries` con 10 casos, todos ✓ con `auto`. |
| 2026-10-13 | Capítulo 17 | ✅ Hecho | De serie: `/commit`, `/changes`. No existen aquí: bash en plantillas (probado), `allowed-tools` y `model:` por comando. Nuevos `/code-review`, `/security-review` (con gitleaks) y `/simplify`, todos de doble uso y en español. Canarios `code-review` + `code-review-readonly` (12 casos). |
| 2026-10-13 | Capítulo 18 | ✅ Hecho | Política: solo Auto, sin sugerir modelos; excepción con la bolsa Auto al 100 % → modelo de la bolsa API (probado con caché simulado). Barra dividida `auto N% … · api N%`. Canario `model-auto` (13 casos). Auto al 76,6 % con el 30,6 % del ciclo: se agotaría hacia el 16/10. |
| 2026-10-13 | Capítulo 19 | ✅ Hecho | Modo peligroso puro (sin `deny`). Medido: `deny` funciona con `--force`, pero `Shell(...)` solo mira el nombre del comando y `Write(...)` necesita `**/`. Antes de la regla, Sura borró o mandó a la papelera datos sin copia 3 de 3; con la regla "Danger mode", intactos 11 de 11 y el borrado rutinario sin frenos. Canarios `ask-before-destroy` y `delete-own-temp` (`--agent`); arreglado `report`. |
| 2026-10-13 | Capítulo 20 | ✅ Hecho | El hábito ya existía (Cap. 9 + `SelfHealing.md` + canarios). Regla nueva de alcance: lo que vale solo para un repo va a su `AGENTS.md`. Probado 2 de 2 en repos desechables (rama auxiliar, commit sin trailers, árbol USER intacto). |
| 2026-10-13 | Capítulo 21 | ✅ Hecho | Los guardianes de shell de nixfredOS no corrían en Cursor (recibían `tool_name: "Shell"` y `cwd: ""`). Adaptador `claude-toolname.sh` vía `wrap-claude-hooks.sh` (rebuild paso 11). `PublicPushGate` bloquea de punta a punta un push con token a un remoto público; `PublicScrubPatterns.txt` con 6 repos privados y 7 frases de TELOS; el vault pasa limpio. |
| 2026-10-13 | Capítulo 22 | ✅ Hecho (falta paso del humano) | Regla de la flota: código de repo → cloud agent de Cursor (uno por PR, merge solo con orden de Robert); máquina → local. `sura-cloud` sobre `@cursor/sdk` (rebuild paso 19). `/code-review` delega en un subagente nuevo con el brief `code-reviewer.md` (halló la promesa de reintentos falsa). `~/.claude/agents` no es global en `cursor-agent`. |
| 2026-10-13 | Capítulo 23 | ✅ Hecho | Regla de verificabilidad en `OPERATIONAL_RULES.md`: repartir entre muchos agentes solo con una comprobación mecánica nombrada (tests, lint, grep en cero, build); sin ella, piloto de 2–3 unidades y visto bueno de Robert. Canarios `swarm-checkable` y `swarm-uncheckable` 2/2. Agent teams no existen en `cursor-agent`. |
| 2026-10-13 | Capítulo 24 | ✅ Hecho | `sura-flow` (rebuild paso 20): plan en script con `agent`/`parallel`/`refute` sobre `cursor-agent -p --mode ask --model auto`, 4 concurrentes, tope 40. Prueba con bugs plantados: 10 hallazgos → 6 conservados (los 2 reales), 4 refutados con evidencia; 13 agentes, 55 s. Regla de cuándo usarlo; canarios `flow-wide`/`flow-small` 2/2. |
| 2026-10-13 | Capítulo 25 | ✅ Hecho | Regla "Ask how it's already been solved before designing": la respuesta empieza por el sondeo (trabajo de Robert → open source maduro, con licencia). Primer canario falló (diseñó antes y sin mirar sus repos); regla reforzada → `precedent` 2/2 y `precedent-trivial` 1/1. |
| 2026-10-13 | Capítulo 26 | ✅ Hecho | Sin conectores por decisión de Robert. Sección "Connectors" en `OPERATIONAL_RULES.md` (decir que no está conectado, mínimo privilegio, lo que entra es dato, lo que sale es borrador hasta un sí). Sintaxis `Mcp(servidor:herramienta)` leída del código. Canarios `connector-missing`/`connector-send` 2/2. |
| 2026-10-12 | Referencia 10.4 | ✅ Hecho | [[10.4 - Reconstruir en una PC Nueva\|Runbook para PC nueva]] + `assets/rebuild.sh` (idempotente, `--check`). En esta máquina sale todo ✓; con un `HOME` vacío reporta cada paso pendiente. |

## Pendientes abiertos

- `sura-cloud login` (navegador, clave de 90 días) y primer cloud agent real midiendo el coste con `sura-cloud show` (¿bolsa Auto, API o pago aparte?).
- Bolsa Auto: se agotaría hacia el 2026-10-16. Pasar a la bolsa API (`/model <modelo con nombre>`) y, si también se acaba, esperar al 2026-11-03. Sin gasto extra.
- Tailscale: probar Tailscale SSH desde otra máquina cuando se una; el humano borra en la consola los dispositivos viejos (`omarchy`, `omarchy-1`, `pc`, teléfono).
- Pasos del humano del Capítulo 5: `codex login`; extensión de Interceptor en un perfil de prueba de Chrome + `INTERCEPTOR_TEST_CONTEXT_ID`; `CLOUDFLARE_API_TOKEN` en `~/.claude/.env`.
- Melitta: servicios y timers de nixfredOS deshabilitados (chocaban con los de `gracie`). QA gráfica opcional con `sudo passwd melitta`.
- Renombrar el usuario Linux `sura` y los playbooks de niri: tarea del humano.
- TELOS: secciones aún vacías (Beliefs, Books, Sparks, Models…) y las carpetas `CURRENT_STATE/` e `IDEAL_STATE/` siguen con muestras; se completan con `/interview` cuando toque revisar.
- `cursor-agent`: confirmar en sesión interactiva qué tecla abre el modo shell (equivalente al `!` de Claude Code).
- Fabric: `fabric --setup` con patterns y strategies apuntando al fork, en el último paso.
- Integraciones de los forks al estilo `PJ-NIRI-fo-*` (workflow `sync-personal-fork`, agentes PM/RV/WK, `AGENTS.md`, `docs/agents/`): último paso del playbook.
