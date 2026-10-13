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

- **Último completado:** [[03.11 - Capitulo 11 - Memoria Viva|Capítulo 11 — Memoria viva]].
- **Siguiente:** Capítulo 12 — Bibliotecas de prompts, plantillas y listas de calidad ([[assets/upstream-site/how.nixfred.com/12-prompt-library|original]]).

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
| 2026-10-12 | Capítulo 11 | ✅ Hecho | La guardia `claude` ahora responde las llamadas `--print` con `cursor-agent` (modelo `auto`, `HOME` aislado, sin hooks). `LMF4_EXTRACT_MODEL=auto`: primera extracción real (3 LoA, 4 decisiones). Ollama solo con `nomic-embed-text` + timer `memory-embed`: 841 embeddings, búsqueda semántica verificada. "Remember" escribe en el mismo turno. `rebuild.sh` pasos 8 y 17; [sura-home#3](https://github.com/robert-flo/sura-home/pull/3). |
| 2026-10-12 | Referencia 10.4 | ✅ Hecho | [[10.4 - Reconstruir en una PC Nueva\|Runbook para PC nueva]] + `assets/rebuild.sh` (idempotente, `--check`). En esta máquina sale todo ✓; con un `HOME` vacío reporta cada paso pendiente. |

## Pendientes abiertos

- Tailscale: probar Tailscale SSH desde otra máquina cuando se una; el humano borra en la consola los dispositivos viejos (`omarchy`, `omarchy-1`, `pc`, teléfono).
- Pasos del humano del Capítulo 5: `codex login`; extensión de Interceptor en un perfil de prueba de Chrome + `INTERCEPTOR_TEST_CONTEXT_ID`; `CLOUDFLARE_API_TOKEN` en `~/.claude/.env`.
- Melitta: servicios y timers de nixfredOS deshabilitados (chocaban con los de `gracie`). QA gráfica opcional con `sudo passwd melitta`.
- Renombrar el usuario Linux `sura` y los playbooks de niri: tarea del humano.
- Fabric: `fabric --setup` con patterns y strategies apuntando al fork, en el último paso.
- Integraciones de los forks al estilo `PJ-NIRI-fo-*` (workflow `sync-personal-fork`, agentes PM/RV/WK, `AGENTS.md`, `docs/agents/`): último paso del playbook.
