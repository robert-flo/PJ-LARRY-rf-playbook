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
├── 10 - Referencias/                                  # 📚 Equivalencias, forks y archivo
│   ├── 10.1 - Equivalencias Claude Code a cursor-agent.md
│   ├── 10.2 - Repositorios Upstream y Forks.md
│   └── 10.3 - Archivo del Sitio how.nixfred.com.md
├── nixfredOS/                                         # 🧠 Submódulo: fork PJ-LARRY-fo-nixfredOS (personal)
└── assets/
    ├── home/                                          # Copias de archivos de usuario (p. ej. .config/cursor/statusline.sh)
    └── upstream-site/                                 # Copia del sitio en Markdown (ver 10.3)
        ├── html2md.py
        ├── how.nixfred.com/                           # 55 páginas + install.sh + seed/
        └── nixfredos.com/
```

Las carpetas `02` a `09` (Instalación del Stack, Configuración, Uso Diario, Memoria y Reglas, Escalar, Conectar y Automatizar, Maestría, Módulos) se crean a medida que se ejecutan sus capítulos.

---

## 📜 Créditos y Licencias

- **Guía original:** [how.nixfred.com](https://how.nixfred.com) de [Fred Nix](https://nixfred.com) y Larry. La copia en `assets/upstream-site/` es de archivo y conserva su autoría.
- **nixfredOS:** [nixfred/nixfredOS](https://github.com/nixfred/nixfredOS) (MIT), fork de [danielmiessler/LifeOS](https://github.com/danielmiessler/LifeOS).
- **Daniel Miessler:** [Telos](https://github.com/danielmiessler/Telos) y [Fabric](https://github.com/danielmiessler/Fabric) (MIT).
