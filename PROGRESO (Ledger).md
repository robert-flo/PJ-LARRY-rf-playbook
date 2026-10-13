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

- **Último completado:** [[02.4 - Capitulo 4 - El Stack de Larry|Capítulo 4 — El Stack de Larry]] (inicio de la Part II).
- **Siguiente:** Capítulo 5 — Bootstrap → nixfredOS ([[assets/upstream-site/how.nixfred.com/05-bootstrap|original]]): instalar el Core desde el submódulo con `--config-root ~/.claude`.

## Registro

| Fecha | Capítulo | Estado | Evidencia / notas |
|---|---|---|---|
| 2026-10-12 | Preparación | ✅ Hecho | Vault creado, sitio archivado en `assets/upstream-site/`, 10 forks `PJ-LARRY-fo-*` con rama `personal`, submódulo `nixfredOS/`. Ver [[10.2 - Repositorios Upstream y Forks\|10.2]]. |
| 2026-10-12 | Paso 0 | ✅ Hecho | `cursor-agent` logueado, modo `--force`, plan Pro anual. nixbash como capa sobre Omarchy ([PJ-LARRY-fo-nixbash#1](https://github.com/robert-flo/PJ-LARRY-fo-nixbash/pull/1)). Tailscale pospuesto al Cap. 6. |
| 2026-10-12 | Capítulo 1 | ✅ Hecho | Modelo mental (sin instalación). Nivel del humano: avanzado. Línea base del harness en [[01.1 - Capitulo 1 - El Paradigma de la Terminal\|la nota]]. |
| 2026-10-12 | Capítulo 2 | ✅ Hecho | `AGENTS.md` cargado por `cursor-agent` (verificado). Barra de estado en `~/.config/cursor/statusline.sh`. Atribución de commits/PRs desactivada. Sin `/init` ni `/voice` en el CLI. |
| 2026-10-12 | Capítulo 3 | ✅ Hecho | Hábito de opciones y nivel avanzado como User Rules de Cursor (globales; `~/.cursor/rules` no lo es). Verificado desde `/tmp`. |
| 2026-10-12 | Capítulo 4 | ✅ Hecho | Forks del stack clonados en `~/Projects`. Datos de nixfredOS en `~/.claude`. Fabric CLI v1.4.518 compilado desde el fork. Claude Code instalado por accidente vía el shim de Omarchy y revertido. |
| 2026-10-12 | Referencia 10.4 | ✅ Hecho | [[10.4 - Reconstruir en una PC Nueva\|Runbook para PC nueva]] + `assets/rebuild.sh` (idempotente, `--check`). En esta máquina sale todo ✓; con un `HOME` vacío reporta cada paso pendiente. |

## Pendientes abiertos

- Tailscale: instalar en el Capítulo 6.
- Ollama (`nomic-embed-text`, extractor de memoria): decidir en el Capítulo 11.
- Fabric: `fabric --setup` con patterns y strategies apuntando al fork, en el último paso.
- Integraciones de los forks al estilo `PJ-NIRI-fo-*` (workflow `sync-personal-fork`, agentes PM/RV/WK, `AGENTS.md`, `docs/agents/`): último paso del playbook.
