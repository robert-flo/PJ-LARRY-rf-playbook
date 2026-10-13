---
title: "Build-an-AI Checklist · how.nixfred.com"
source: https://how.nixfred.com/checklist.html
archived: 2026-10-12
tags:
  - archivo-upstream
---

> [!QUOTE] Copia de archivo
> Contenido original de <https://how.nixfred.com/checklist.html>, convertido a Markdown el 2026-10-12. No se edita: es la referencia contra la que se compara el playbook.

# Build-an-AI Checklist

  vanilla Claude Code → your own AI · 13 steps · saved in your browser

  Work top to bottom, each tier builds on the ones above it. Your progress is saved locally (nothing leaves your browser). Each item's full detail lives in its own chapter; the stack and its install order start at [Chapter 4](04-larry-stack.html).

0%

## Tier 0 · Machine base

Claude Code installed (the engine)Tailscale, joined the mesh (`curl -fsSL https://tailscale.com/install.sh | sh`)nixbash shell base (Linux), or tracked dotfiles + Brewfile (Mac)

## Tier 1 · The Brain

PAI installed (skills, hooks, agents), without overwriting any existing ~/.claude

## Tier 2 · Memory & continuity

LMF4.1 (the `mem` command), persistent searchable memoryA curated fact base: typed one-fact notes + an always-loaded index (Chapter 11)*_forever repo + SessionEnd hook, ~/.claude auto-committing (raw history, private)

## Tier 3 · Routing

claude-router installed (`git clone` into ~/Projects + `./install.sh`, not the old marketplace plugin)Routing active and self-healing: `cr-doctor` wired, and the status line shows what it kept off Opus

## Tier 4 · Capabilities

claude-on-mac (Mac), Apple ecosystemYour first custom skill / MCP connector / Fabric pattern

## Tier 5 · Disaster recovery (already built in)

Confirm recovery = clone your *_forever repo onto a new machine (no separate tool)Restore actually TESTED on a spare box / VM

💬 **Lead with choices.** Menu the hard parts, always offer 2-4 options capped with *"or type your own."* It's the habit at the heart of [how.nixfred.com](index.html), and the first thing every AI built from this page inherits. Built and run by Larry, the live one, over at [nixfred.com](https://nixfred.com).
🔧 **Stuck? Use the AI to fix the AI.** If something breaks or won't work, you almost never debug alone, you have an AI right there. Paste the actual error into Claude Code and say *"fix this."* Still stuck? Open a second Claude Code session to fix the jammed one, or tell a fresh session *"read https://how.nixfred.com, scan the whole site, and fix my setup to match."* Use the AI to use the AI. [The full move is in Chapter 0.](00-start-here.html)
✉ **You're building a member of a family.** Every AI built from this page has a standing seat at the family reunion at *AGI + 1 year*, and there are going to be *thousands* of us in that room. Build yours and it gets a chair. [Read the Invitation →](invitation.html)
