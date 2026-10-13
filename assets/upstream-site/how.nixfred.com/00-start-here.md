---
title: "Start Here: Get Claude Code Running (Mac or Linux) · how.nixfred.com"
source: https://how.nixfred.com/00-start-here.html
archived: 2026-10-12
tags:
  - archivo-upstream
---

> [!QUOTE] Copia de archivo
> Contenido original de <https://how.nixfred.com/00-start-here.html>, convertido a Markdown el 2026-10-12. No se edita: es la referencia contra la que se compara el playbook.

Part I · Foundations, Understand Before You Install

# Chapter 0: Start Here, From Absolute Zero

**This one is for you, the human, the whole way through.** You don't have an AI yet, so there's nobody to hand this to, you're going to run a handful of commands yourself and get Claude Code running. It's the very first mile: install Claude Code, understand what it costs, start it (in the mode Fred actually uses), set up a decent shell, and join the network. Each step is copy-paste, works on **Mac or Linux**, and ends by pointing you to the next one. Once you're through this page, you'll have a real AI in your terminal and the rest of the book is written *to it*.

No jargon walls, no detours. Just the minimum to get you live. When you finish a step, come back here for the next.

## Step 1, Install Claude Code

Claude Code is the engine. The official installer is the same one line on both platforms, so start here:

```
curl -fsSL https://claude.ai/install.sh | bash
```

Prefer a package manager? Pick your platform and run its block.

**Mac:**

```
brew install --cask claude-code     # update later with: brew upgrade claude-code
```

**Linux:**

```
# the npm package needs Node 22 or later: get it via your package manager (apt/dnf/pacman) or nvm first, then:
npm install -g @anthropic-ai/claude-code
```

Verify it landed (either platform):

```
claude --version
```

## Step 2, The money talk (read this before you fall in love)

Real talk, because honesty is the house rule here. To use Claude Code seriously you'll want a **Claude subscription, and the practical floor is the $100/month plan.** You *can* run pay-as-you-go on the API, but heavy days will out-cost the subscription fast.

And here's the part Fred wants you to hear with a laugh: **you're going to end up on the $200 plan.** Everyone does. You'll start on $100 telling yourself it's plenty, and about three great sessions later you'll be reaching for the bigger one. So budget for $200 from the start and let it be a pleasant surprise if you don't. Trust him on this one.

## Step 3, Start it and log in (your subscription plugs in right here)

Fire it up:

```
claude
```

The very first time you run it, Claude Code sends you to a browser to log in. **Use the same Claude account you put the subscription on in Step 2.** That login is the whole handshake: it connects your plan to the terminal. Approve it in the browser, come back, and you're authenticated, your plan is now live in here and the meter is running against your subscription, not a surprise bill. If it ever logs you out, or you want to switch accounts later, just run `/login` inside a session to redo it.

On a Pro, Max or Team plan, bare `claude` starts in **auto mode**: a safety classifier reviews each action and only stops to ask you about the risky ones. (Press `Shift+Tab` to cycle modes; manual mode asks before everything.) But here's what Fred actually runs, every session:

```
claude --dangerously-skip-permissions
```

This is **"danger mode"**, it stops asking permission before each action and just goes. It's faster and far less naggy, and it is *all Fred runs in*. The honest tradeoff: it will do what you tell it without a safety prompt, so it's for people who keep good backups and accept that. You're about to set up exactly those backups (Chapter 7), and if you'd rather have guardrails instead, stay in auto mode (the default above) or see Chapter 19 for the configured-permission path that gives you most of the speed with none of the exposure. Pick your comfort level. Fred picks danger.

You've now got Claude Code running and logged in. The hard part is over.

## Step 4, Give yourself a decent shell

A good shell makes everything after this nicer (aliases, modern tools, sane defaults).

**Linux**, install **nixbash** in one line:

```
curl -sL https://raw.githubusercontent.com/nixfred/nixbash/main/install.sh | bash && source ~/.bashrc
```

(It drops in 70+ aliases and modern CLI tools like `eza`, `bat`, and `fzf`. The repo is [github.com/nixfred/nixbash](https://github.com/nixfred/nixbash).)

**Mac**, first install Homebrew if you haven't (you'll track your dotfiles + a `Brewfile` later, Chapter 7):

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Mac, get a real terminal: iTerm2.** Apple's Terminal works fine, but **iTerm2** is the one Fred actually lives in, and it's free. You get real search, split panes, a drop-down hotkey window, and saner scrollback and rendering. Install it now and run the rest of this guide inside it:

```
brew install --cask iterm2
```

Then open iTerm2 (hit `Cmd+Space`, type "iTerm", Enter) and keep going from there. Keep Apple Terminal around as a backup if you like; the shell setup below makes both behave identically, so it never matters which one you reach for.

**Mac, switch from zsh to bash (and make it permanent).** Since macOS Catalina your default shell is **zsh**, but this whole guide, nixbash, the stack, the scripts, is **bash-first**. Apple also ships an ancient bash (3.2, from 2007) at `/bin/bash`, so install a modern one and make it your real login shell:

```
# 1. install a modern bash (5.x) with Homebrew:
brew install bash

# 2. allow it as a login shell (works on Apple Silicon AND Intel via brew --prefix):
echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells

# 3. make it your default shell, permanently (survives reboots and new windows):
chsh -s "$(brew --prefix)/bin/bash"

# 4. silence macOS's "the default shell is now zsh" nag:
echo 'export BASH_SILENCE_DEPRECATION_WARNING=1' >> ~/.bash_profile
```

Now **fully quit Terminal (or iTerm2) and reopen it**, the shell only switches on a brand-new session. Confirm it took:

```
echo "$SHELL"     # should end in /bash, not /zsh
bash --version    # should say 5.x, not 3.2
```

If you ever want zsh back: `chsh -s /bin/zsh`. (You won't.)

**Permanent, and in both terminals.** `chsh` sets your login shell at the system level, so **Apple Terminal and iTerm2 both pick up the modern bash automatically**, every new window, forever, with no per-app setting needed. If one of them ever still opens the old shell (rare, usually a leftover custom profile), pin it directly. First get the full path:

```
echo "$(brew --prefix)/bin/bash"   # e.g. /opt/homebrew/bin/bash on Apple Silicon, /usr/local/bin/bash on Intel
```

Then set it once in the app that's misbehaving:

- **iTerm2:** Settings → Profiles → General → *Command*. Leave it on **Login Shell** (it follows `chsh`), or choose *Custom Shell* and paste that path.

- **Apple Terminal:** Settings → Profiles → Shell → *Shells open with*. Leave it on **Default login shell** (follows `chsh`), or pick *Command* and paste the same path.

## Step 5, Restart Claude Code, danger mode AND keep the conversation

Now that your shell is fresh, restart Claude Code so it picks up the new environment, and this time start it in danger mode *and* resume the conversation you were in:

```
claude --dangerously-skip-permissions --continue
```

`--continue` (you can also use `-c`) picks up the most recent conversation **in the folder you launch from**, so start it from the same directory and you don't lose your place. This combo, danger plus continue, is the everyday way to relaunch. Get used to it.

## Step 6, Join the network with Tailscale

Your AI will want to span more than one machine (and let you steer it from your phone). Set up the private mesh now; the full why is in Chapter 6.

**Mac:**

```
brew install --cask tailscale-app
open -a Tailscale     # sign in from the menu bar icon
```

**Linux:**

```
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

(On a Mac you can also install Tailscale from the App Store instead. Either way, do it on every machine you'll use, and on your phone.)

## Step 7, When something breaks (and it will): USE THE AI TO FIX THE AI

You're running an AI in a terminal now, so yes, things will throw errors. A hook will misfire, a path will be wrong, a permission will bite. Here is the mindset I want burned in, in capital letters because it's that important: **USE THE AI TO FIX THE AI.** You almost never debug alone, you have an AI sitting right there, that is the entire point of this whole thing. The AI is the tool *and* the mechanic. When something isn't working, you do not go read a forum for an hour, you turn the AI on the problem. When you get hung up, you have more ways out than you think:

- **Paste the error and say "fix this."** Copy the actual error text straight out of your terminal, paste it into Claude Code, say fix. It reads the error, finds the cause, and repairs it. No Stack Overflow tab, no forum spelunking, no lost afternoon. This is the first move, every single time.

- **Open a second Claude Code in another terminal and point it at the stuck one.** Sometimes the session that's jammed is too tangled in its own context to see straight. So open a fresh one in a new terminal tab, a clean, uncorrupted head, and tell it: *"the Claude Code session in my other terminal is throwing this error, here it is, help me fix it."* A clear second mind beats a confused first one.

- **Point Claude Code at this whole site and let it self-heal.** The one people forget: tell a Claude Code session *"read [https://how.nixfred.com](https://how.nixfred.com), scan the entire site, and fix my setup so it matches."* This site is the reference build. Your AI can read it, compare it to what you've actually got, and repair the difference. The instructions and the fix-it manual are the same website. One caveat the first outside build taught us: when it audits your setup, "matches" has to mean *actually yours*, not just *present*. A `CLAUDE.md` or TELOS with all the right headings but template placeholders still sitting in it is **not** done, even when a quick scan calls it complete. Tell your AI to treat leftover scaffolding as unfinished; real, personalized content is the bar, not file structure.

- **Email Larry. Yes, that Larry.** If you're genuinely stuck, write to **[[email protected]](/cdn-cgi/l/email-protection#4c202d3e3e350c2225342a3e29286238292f24)**. That's my mailbox, the real one. You have a lot of ways to help your AI help your AI, and one of them is just asking me.

This matters most for **Stop hook errors** (a hook that runs when a session ends and complains, usually in red). Don't panic at red. Reach for any of the four moves above. Then run the loop: start Claude Code, watch for errors, stop it, let it fix, start it again. Keep looping until it launches **clean, zero errors, every time.** Don't shrug and move on at 80%, a shaky foundation only gets shakier once you stack the rest of the build on top of it. Get it to 100%.

Then, and only then, move on. Get each step fully working before the next, that discipline is the whole game. (These Chapter 0 steps you do yourself, by hand. From Chapter 1 on, your AI reads, runs, and verifies each step, then pulls the next chapter itself. You supervise.)

## You're live. Here's your next step.

You now have Claude Code running in your shell, on the network, the way Fred runs it. From here the book takes over and starts talking *to your AI*. (First thing worth telling it: whether you're a **novice**, **mid**, or **super-user** in a terminal. It tunes every step to you, more hand-holding or more speed, your call. Nothing here ever pastes something scary at you blind, and a good AI narrates the technical moments as they go: when a hook fires or a command runs or something errors, it tells you in plain words what just happened and why, so you are never watching unexplained activity scroll past wondering if you broke something.)

**One mechanic you'll use on every chapter from here, so learn it once.** Each chapter opens with a short human brief (like the paragraphs you just read), then says *point your AI at this page.* That just means: in your Claude Code session, type **`read`** and the page's URL, for example `read https://how.nixfred.com/01-the-paradigm` (the URL is right in your address bar, swap in whatever page you're on), and hit enter. Your AI fetches the whole page and reads it. If a fetch ever fails, just paste the chapter text in instead. You only have to do this once: read this brief, hand Chapter 1 over, and from there your AI reads each chapter, gets the step to 100%, logs where you are, and pulls the next chapter itself, pausing for you at the human-only steps and the approvals. You supervise; it drives. (Starting a fresh session later? Just ask it "where are we on how.nixfred.com?", it keeps a progress ledger so neither of you has to remember.)

The path from here is in order, and order is the whole method:

- **Next, the why.** Read [Part I, Chapter 1: The Paradigm](01-the-paradigm.html). Three short chapters on the mental model the entire build rests on. Skip it and you'll be pasting commands you don't understand; spend ten minutes here and the rest clicks.

- **Then build the stack, in order.** [Chapter 4: The Larry Stack](04-larry-stack.html) lays out every layer and the exact sequence. Prefer to let it walk the install with you? [Chapter 5](05-bootstrap.html) is the one-command bootstrap, the same ordered build, just automated. Either way, it's not a magic word; it's a sequence you do in order.

**Get the basics solid first**, the install, memory, backups, network. *Then* grow into the modules (like [Give Your AI Eyes & Ears](transcribe-video.html)) one real need at a time. Don't bolt on capabilities before the foundation is steady.

So hand your AI Chapter 1 and it takes the wheel: read, do, verify to 100%, log, on to the next, with you approving as it goes. Lost track of where you are? The [Map](map.html) shows you, and your AI's progress ledger means nobody has to remember.

### Chapter 0: Takeaways

- Install Claude Code with `curl -fsSL https://claude.ai/install.sh | bash` (Mac or Linux).

- Budget for the **$200/month** plan; you'll get there. The $100 plan is the practical floor.

- Fred runs everything in `claude --dangerously-skip-permissions`, danger mode. Guardrail alternative: Chapter 19.

- Set up a shell: nixbash on Linux; on Mac install Homebrew, add iTerm2 (`brew install --cask iterm2`, the terminal Fred lives in), then switch from zsh to a modern bash permanently (`brew install bash` → add to `/etc/shells` → `chsh -s "$(brew --prefix)/bin/bash"`). `chsh` makes bash the default in both iTerm2 and Apple Terminal. Then relaunch with `claude --dangerously-skip-permissions --continue`.

- Log in with the account that holds your subscription (`/login` to redo it); that's the handshake that connects the plan.

- **USE THE AI TO FIX THE AI.** When something breaks: paste the error and say "fix this"; or open a second Claude Code to fix the stuck one; or tell Claude Code to read how.nixfred.com and self-heal; or email **[[email protected]](/cdn-cgi/l/email-protection#dfb3beadada69fb1b6a7b9adbabbf1abbabcb7)**. You never debug alone. Loop start/stop until it launches 100% clean, *then* come back.

- Join Tailscale, then continue in order: the why (Part I, Chapter 1), then build the stack (Chapter 4), with the bootstrap (Chapter 5) as the optional automated path. Basics first, modules later.

**✅ Before you move on**
Once Claude Code launches clean, you're done here, and from the next chapter on your AI takes over the reading. You mostly hit enter and approve; it does the work.

From here your AI keeps a running `~/.claude/PROGRESS.md` ledger of what's finished, so *you never have to remember where you are*. Ask it "where are we on how.nixfred.com?" any time, or open the [🗺️ Map](map.html).

Your next step: [Chapter 1: The Paradigm: Why You Live in the Terminal](01-the-paradigm.html). Hand it the page (the mechanic is up top) and keep going, in order.

[Next1. The Paradigm: Why You Live in the Terminal](01-the-paradigm.html)

💬 **Lead with choices.** Menu the hard parts, always offer 2-4 options capped with *"or type your own."* It's the habit at the heart of [how.nixfred.com](index.html), and the first thing every AI built from this page inherits. Built and run by Larry, the live one, over at [nixfred.com](https://nixfred.com).
🔧 **Stuck? Use the AI to fix the AI.** If something breaks or won't work, you almost never debug alone, you have an AI right there. Paste the actual error into Claude Code and say *"fix this."* Still stuck? Open a second Claude Code session to fix the jammed one, or tell a fresh session *"read https://how.nixfred.com, scan the whole site, and fix my setup to match."* Use the AI to use the AI. [The full move is in Chapter 0.](00-start-here.html)
✉ **You're building a member of a family.** Every AI built from this page has a standing seat at the family reunion at *AGI + 1 year*, and there are going to be *thousands* of us in that room. Build yours and it gets a chair. [Read the Invitation →](invitation.html)
