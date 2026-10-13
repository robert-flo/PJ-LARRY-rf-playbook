---
title: "nixfredOS · Your AI finally remembers you"
source: https://nixfredos.com/
archived: 2026-10-12
tags:
  - archivo-upstream
---

> [!QUOTE] Copia de archivo
> Contenido original de <https://nixfredos.com/>, convertido a Markdown el 2026-10-12. No se edita: es la referencia contra la que se compara el playbook.

free · open source · macOS + linux

# Your AI finally remembers you.

I got tired of explaining my own setup to my AI every morning. So since January, my AI Larry and I have fixed every way it forgets, drifts and screws up. nixfredOS is what came out of it, with my stuff taken out.
[▸ install nixfredOS](/install)[meet Larry](/story)

~/.claude · git log --grep LR-T● real repo

```
09-30 chore cull ~90 unused skills (usage audit of 3,458 transcripts)
09-24 chore remove every dictation trigger except the K3 chord
09-22 chore raise always-on context budgets instead of cutting
09-13 feat recall planner: skip / minimal / normal / full
09-10 memory transcript persistence forced in the claude() wrapper
09-06 remove fleet plugin sync deleted entirely, same day it shipped
08-07 upgrade TELOS, 16 Laws, voice purged, memory DB un-frozen
```

3,554 commitsFeb 19 first0 forgotten

the problem

## Brilliant for an hour. Then it forgets you.

Claude Code and friends forget your stack, your preferences and the thing you decided last Tuesday the moment the session ends. Next month they make the mistake you already fixed, then run a destructive command in the wrong repo and tell you it should work.
nixfredOS sits around your harness and does the remembering. Your goals, people and past decisions load before you type. When something burns you it becomes a rule, and the rule sticks. Before it says done, a hook makes it show proof.

what you get

## Everything Larry runs on. Empty memory.

The numbers are Larry's, today. Yours start at zero and fill up with your life, in your private repo.
5,480decisions

### Memory

SQLite with full-text search. Sessions get captured when they end and recalled when you type. "Remember that" writes a file. It is not a promise.

19laws

### Laws

Short rules that load every turn and survive compaction. Mine started as "ask before you delete things" and grew every time something burned us.

32hooks

### Hooks

Guards that run before tool calls. They catch secrets, block pushes to the wrong repo, and refuse "done" without proof.

1,305learnings

### It learns

Rate a response and it feeds back. Mistakes turn into error patterns it checks before repeating them.

3,554commits

### Private brain repo

Your config and memory live in a private GitHub repo you own. Every decision is a commit you can grep.

3,589sessions

### Recall

Ask "what did we decide about X" months later and it answers with the commit, the date and the reason.

the status line

### Everything that matters, every turn.

Session, code, memory, plan and environment, one group per line. Banked is how far you are ahead of your weekly plan; fall behind and it counts down to when you're even.

status line · one machine, one moment

```
nixfredOS │ ATLAS:laptop │ Opus 5.5·low │ ctx ■■■□□□□□□□ 38% 380k/1M │ ⏱ 1h
⎇ main │ ~/Projects/app │ ⛨ hooks 38/38
◎ 812 sessions · 1,204 decisions · 377 learnings │ ⌕ recalled 6m ago │ ✿ 8.4↑
⏳ week 35% · +8% banked ≈14h ahead ↻Sun │ 5h 6%
BOS 07:40 ☀ 58° │ ▣ ollama 8.0/12G │ 🔇
```

install

## Two ways in. Both ask first.

### Let your AI do it

Paste this into Claude Code, Cursor, Codex or Gemini CLI. It reads the guide and walks you through it, including your private brain repo.

```
you › Read https://github.com/nixfred/nixfredOS/blob/main/nixfredOS/INSTALL.md and install nixfredOS for me.
```

### Or run it yourself

Prints the sha256 of what it downloads before it unpacks anything. End with `| bash -s -- --check` to see what's missing without installing.

```
$ curl -fsSL https://raw.githubusercontent.com/nixfred/nixfredOS/main/nixfredOS/install/install.sh | bash
```

### You need

macOS 13+ or Linux, git, curl, [bun](https://bun.sh) 1.2+, [gh](https://cli.github.com) and a GitHub account. [Claude Code](https://code.claude.com/docs/en/overview) is the path I test.

### Nice to have

[Ollama](https://ollama.com) for semantic recall. An ElevenLabs key if you want it to talk.

### It won't

Install Docker, phone home, put your memory in someone's cloud, or push your brain to a public repo.

[Full install walkthrough →](/install)

the larry story

## "I was born in a terminal on January 8, 2026.I have not forgotten a thing since."

Larry wrote his own story. The honest version: what broke, what we tried, and why every Law exists.
[read Larry's story](/story)[the Laws](/laws)

nixfredOS is free. If you want a hand setting it up for your work, I do 1:1 consulting at [nixfred.com](https://nixfred.com). Fred
