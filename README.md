# 🤖 Larry Playbook con cursor-agent (Obsidian Vault & Guía Ejecutable)

[![Obsidian](https://img.shields.io/badge/Obsidian-Ready-483699?logo=obsidian&logoColor=white)](https://obsidian.md)
[![Linux](https://img.shields.io/badge/Linux-Arch%20%7C%20Omarchy-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Harness](https://img.shields.io/badge/Harness-cursor--agent-000000)](https://cursor.com/cli)
[![Base](https://img.shields.io/badge/Base-nixfredOS-6E40C9)](https://nixfredos.com)

Guía modular y ejecutable para construir un asistente de IA personal en la terminal, siguiendo [how.nixfred.com](https://how.nixfred.com) capítulo por capítulo, adaptada a:
- **`cursor-agent`** (Cursor CLI) como harness, en lugar de Claude Code.
- **[nixfredOS](https://github.com/nixfred/nixfredOS)** como base (el "Brain"), en lugar de LifeOS/PAI.
- **Forks propios** (`PJ-LARRY-fo-*`) de cada repo del stack, para no perder ningún engranaje si un upstream se vuelve privado.

Está pensada para que un agente la ejecute en orden y, a la vez, le explique al humano cómo está armado cada paso.

---

## 📖 Cómo Consumir este Playbook

**En Obsidian:**
1. Clona con submódulos: `git clone --recurse-submodules https://github.com/robert-flo/PJ-LARRY-rf-playbook.git`
2. En Obsidian, **Open folder as vault** y elige la carpeta.
3. Abre **`00 - Indice General (MOC).md`**.

**Con un agente:**
```text
Lee AGENTS.md y PROGRESO (Ledger).md de este vault y continúa el playbook donde lo dejamos.
```

**En una PC nueva:** sigue [`10 - Referencias/10.4 - Reconstruir en una PC Nueva.md`](10%20-%20Referencias/10.4%20-%20Reconstruir%20en%20una%20PC%20Nueva.md). Tras los pasos del humano (`gh auth login`, `cursor-agent login`, User Rules), `assets/restore.sh` trae a Sura desde los repos privados, `assets/rebuild.sh --check` muestra qué falta y `assets/rebuild.sh` lo aplica.

---

## 🗺️ Estructura del Repositorio

```text
PJ-LARRY-rf-playbook/
├── 00 - Indice General (MOC).md                       # 🗺️ Mapa de contenidos con Mermaid y estado
├── PROGRESO (Ledger).md                               # 📒 Dónde vamos (el PROGRESS.md del sitio)
├── README.md                                          # 📖 Esta guía
├── AGENTS.md                                          # 🤖 Reglas para agentes (git, forks, harness)
├── 01 - Fundamentos/                                  # 🧭 Part I
│   ├── 01.0 - Paso 0 - Desde Cero con cursor-agent.md
│   ├── 01.1 - Capitulo 1 - El Paradigma de la Terminal.md
│   ├── 01.2 - Capitulo 2 - Primera Sesion.md
│   └── 01.3 - Capitulo 3 - Hablar en Opciones.md
├── 02 - Instalacion del Stack/                        # 🧱 Part II
│   ├── 02.4 - Capitulo 4 - El Stack de Larry.md
│   ├── 02.5 - Capitulo 5 - nixfredOS en cursor-agent.md
│   ├── 02.6 - Capitulo 6 - Tailscale.md
│   ├── 02.7 - Capitulo 7 - Repos Privados para Siempre.md
│   └── 02.8 - Capitulo 8 - Recuperacion ante Desastres.md
├── 03 - Configuracion/                                # ⚙️ Part III
│   ├── 03.9 - Capitulo 9 - Configurar, no Chatear.md
│   ├── 03.10 - Capitulo 10 - Proyectos, Roles y Referencias.md
│   ├── 03.11 - Capitulo 11 - Memoria Viva.md
│   ├── 03.12 - Capitulo 12 - Prompts, Plantillas y Calidad.md
│   ├── 03.13 - Capitulo 13 - Disciplina de Contexto.md
│   └── 03.14 - Capitulo 14 - TELOS.md
├── 04 - Uso Diario/                                   # 🚗 Part IV
│   ├── 04.15 - Capitulo 15 - El Prompting es una Habilidad.md
│   ├── 04.16 - Capitulo 16 - Planear, Prototipar, Construir.md
│   ├── 04.17 - Capitulo 17 - Comandos Slash y Doble Uso.md
│   ├── 04.18 - Capitulo 18 - Modelos, Razonamiento y Coste.md
│   └── 04.19 - Capitulo 19 - Permisos y Autonomia Segura.md
├── 05 - Memoria y Reglas/                             # 🧠 Part V
│   ├── 05.20 - Capitulo 20 - Ingenieria que se Acumula.md
│   └── 05.21 - Capitulo 21 - Hooks.md
├── 06 - Escalar/                                      # 📈 Part VI
│   ├── 06.22 - Capitulo 22 - Subagentes y Contexto Bifurcado.md
│   ├── 06.23 - Capitulo 23 - Enjambres, Migraciones y Equipos de Agentes.md
│   ├── 06.24 - Capitulo 24 - Flujos Dinamicos y Ultracode.md
│   └── 06.25 - Capitulo 25 - Conocimiento Tacito y Reutilizacion.md
├── 07 - Conectar y Automatizar/                       # 🔌 Part VII
│   ├── 07.26 - Capitulo 26 - Conectores.md
│   ├── 07.27 - Capitulo 27 - Mas Alla del Chat.md
│   ├── 07.28 - Capitulo 28 - Rutinas.md
│   ├── 07.29 - Capitulo 29 - Disenar y Desplegar Rutinas.md
│   ├── 07.30 - Capitulo 30 - Sistemas Repetibles.md
│   └── 07.31 - Capitulo 31 - Claude en Todas Partes.md
├── 08 - Maestria/                                     # 🎓 Part VIII
│   ├── 08.32 - Capitulo 32 - Patrones Multiagente.md
│   ├── 08.33 - Capitulo 33 - Ingenieria que se Acumula Bien Hecha.md
│   ├── 08.34 - Capitulo 34 - Agentes Proactivos.md
│   ├── 08.35 - Capitulo 35 - Principios.md
│   └── 08.36 - Capitulo 36 - Manual de Operacion.md
├── 10 - Referencias/                                  # 📚 Equivalencias, forks y archivo
│   ├── 10.1 - Equivalencias Claude Code a cursor-agent.md
│   ├── 10.2 - Repositorios Upstream y Forks.md
│   ├── 10.3 - Archivo del Sitio how.nixfred.com.md
│   ├── 10.4 - Reconstruir en una PC Nueva.md
│   └── 10.5 - Manual de Operacion.md
├── nixfredOS/                                         # 🧠 Submódulo: fork PJ-LARRY-fo-nixfredOS (personal)
└── assets/
    ├── restore.sh                                     # 🛟 Restaura HOME, ~/.claude, USER y memoria desde los repos privados (Cap. 8)
    ├── rebuild.sh                                     # 💻 Reconstruye la máquina en una PC nueva (ver 10.4)
    ├── nixfredos-substitute.ts                        # Rellena los placeholders de identidad de nixfredOS
    ├── home/                                          # Copias de archivos de usuario (statusline, cli-config, hooks de Cursor, guardia claude, systemd)
    ├── system/                                        # Archivos de sistema (hook de pacman pkglist)
    └── upstream-site/                                 # Copia del sitio en Markdown (ver 10.3)
        ├── html2md.py
        ├── how.nixfred.com/                           # 55 páginas + install.sh + seed/
        └── nixfredos.com/
```

Las carpetas `03` a `09` (Configuración, Uso Diario, Memoria y Reglas, Escalar, Conectar y Automatizar, Maestría, Módulos) se crean a medida que se ejecutan sus capítulos.

---

## 📜 Créditos y Licencias

- **Guía original:** [how.nixfred.com](https://how.nixfred.com) de [Fred Nix](https://nixfred.com) y Larry. La copia en `assets/upstream-site/` es de archivo y conserva su autoría.
- **nixfredOS:** [nixfred/nixfredOS](https://github.com/nixfred/nixfredOS) (MIT), fork de [danielmiessler/LifeOS](https://github.com/danielmiessler/LifeOS).
- **Daniel Miessler:** [Telos](https://github.com/danielmiessler/Telos) y [Fabric](https://github.com/danielmiessler/Fabric) (MIT).
