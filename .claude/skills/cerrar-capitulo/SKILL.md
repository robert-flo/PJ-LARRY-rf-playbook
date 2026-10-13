---
name: cerrar-capitulo
description: Cierra un capítulo del playbook Larry en este vault - nota del capítulo desde la plantilla, 10.4 y rebuild.sh, ledger, MOC, README, navegación y PR. USE WHEN cerrar capítulo, documenta el capítulo, close chapter, terminar capítulo N.
argument-hint: <número de capítulo>
---

# cerrar-capitulo

Capítulo: `$ARGUMENTS`. Solo se cierra un capítulo **ejecutado y verificado** (paso 4 de `AGENTS.md`); si falta evidencia, se consigue primero o se dice qué bloquea.

## Estado final

- **Nota** `NN - <Parte>/NN.M - Capitulo M - <Título>.md` creada desde `plantilla-capitulo.md` (en esta carpeta): decisiones del humano tal como las dio, lo que se hizo, trampas reales y verificación con salida de comandos copiada, no resumida. Parte I → `01 - Fundamentos`, II → `02 - Instalacion del Stack`, III → `03 - Configuracion`, IV → `04 - Uso Diario`, V → `05 - Memoria y Reglas`; las partes siguientes siguen el MOC.
- **Navegación**: la nota anterior apunta a esta en "Siguiente" y en "Continuar"; esta apunta a la anterior.
- **Si cambió la máquina**: `10 - Referencias/10.4 - Reconstruir en una PC Nueva.md` (línea "Cubre hasta el Capítulo N", tabla de pasos, decisiones, trampas) y `assets/rebuild.sh` (paso nuevo idempotente con `--check`); archivos de usuario copiados a `assets/home/`, de sistema a `assets/system/`; `assets/rebuild.sh --check` sin ✗. Los mismos archivos de `$HOME` en `sura-home` por PR (comando `/pr`).
- **Datos privados** (nombres de repos privados, identidad, memoria) fuera del vault, que es **público**: van al árbol USER (`sura-brain-user`).
- **`PROGRESO (Ledger).md`**: "Último completado" y "Siguiente" al día; fila nueva en el registro con fecha y evidencia; pendientes resueltos borrados y nuevos añadidos.
- **`00 - Indice General (MOC).md`**: la línea del capítulo enlaza a la nota con ✅ y un resumen corto.
- **`README.md`**: la nota en el árbol de carpetas.
- **Equivalencias** nuevas Claude Code → cursor-agent en `10 - Referencias/10.1`.
- **Git**: `gitleaks git --pre-commit --staged --redact .` limpio y luego el flujo de `/pr` (rama `chN-<tema>`, PR a `master`, rebase, merge, borrar rama).

Al terminar: resumen al humano (resultado primero) y pregunta con opciones antes de pasar al siguiente capítulo.
