---
title: "Install · nixfredOS"
source: https://nixfredos.com/install.html
archived: 2026-10-12
tags:
  - archivo-upstream
---

> [!QUOTE] Copia de archivo
> Contenido original de <https://nixfredos.com/install.html>, convertido a Markdown el 2026-10-12. No se edita: es la referencia contra la que se compara el playbook.

install

# Five minutes to an AI that remembers.

The one-liner does the first four steps and tells you what it changed. The guided setup does the rest and asks before each change. Here is exactly what you need and exactly what happens.

step 0 · requirements

### Required

- macOS 13+ or a modern Linux (Arch, Ubuntu, Debian, Fedora…)

- git and curl

- [bun](https://bun.sh) 1.2+. The installer can install it for you

- [gh](https://cli.github.com) (GitHub CLI) and a free GitHub account

- An AI coding harness. [Claude Code](https://code.claude.com/docs/en/overview) is the most tested. Cursor, Cline, Codex and Gemini CLI can follow the guide

### Optional

- [Ollama](https://ollama.com) for semantic, meaning-based recall. A native app, no containers

- An ElevenLabs key if you want spoken responses

No Docker. No telemetry. No cloud memory service.

step 1 · preflight (installs nothing)

### Check your machine first

Runs the installer's checks and prints what is present and what is missing, then exits.

```
$ curl -fsSL https://raw.githubusercontent.com/nixfred/nixfredOS/main/nixfredOS/install/install.sh | bash -s -- --check
```

step 2 · install

### Option A: let your AI do it

Paste this into your AI coding assistant. It reads the guide and walks you through everything.

```
you › Read https://github.com/nixfred/nixfredOS/blob/main/nixfredOS/INSTALL.md and install nixfredOS for me.
```

### Option B: one line in a terminal

```
$ curl -fsSL https://raw.githubusercontent.com/nixfred/nixfredOS/main/nixfredOS/install/install.sh | bash
```

what happens

## Six steps. The last two ask before every change.

- 1

### Preflight

Run it with --check first: it reports on curl, git, bash, tar, bun and gh, detects macOS or Linux, and installs nothing. On the real run it installs bun for you if it is missing.

- 2

### Find your harness

Locates your AI harness's skills folder. An existing install is detected and upgraded, including an old LifeOS setup.

- 3

### Fetch, pinned

Resolves the latest release, pins it to an exact commit and prints the sha256 of the download before extracting anything.

- 4

### Install additively

Drops the nixfredOS skill into place. Nothing else on your machine is touched until you say yes.

- 5

### Memory engine

Part of the guided setup, not the one-liner. A separate installer brings up the SQLite FTS5 memory engine with empty memory. If Ollama is present, it offers local semantic recall.

- 6

### Your private brain

Also part of the guided setup. Walks you through gh login and creates a PRIVATE GitHub repo for your AI's config and memory, and verifies the repo is private before the first push.

your private brain repo

### Why GitHub, and why private

Your AI's memory is just files: settings, hooks, notes, decisions. Committing them to git gives you history, backup and a searchable record of everything your AI has learned. Recall becomes `git log --grep`.
The installer and your AI will:

- install `gh` if needed (Homebrew on macOS, your package manager on Linux)

- run `gh auth login` with you at the keyboard

- create `/-brain` as a private repo

- check it really is private before the first push, and refuse to push anywhere public

after install

### Give it a name, then give it time

Onboarding is a conversation. Your AI asks about your goals (current state and ideal state), detects conflicts with your existing setup, and wires hooks only with your permission.
Then just work. Say `remember that` when something matters. In a week, ask it what you decided. In a month, notice you stopped re-explaining yourself.
Upgrading? Re-run the installer. It detects your existing install and upgrades it in place.

Want a guide for the first setup? [nixfred](https://nixfred.com) helps people 1:1 as a paid consultant. The software stays free.
