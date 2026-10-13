#!/usr/bin/env bun
// sura-cloud: launch and supervise Cursor cloud agents from Sura (one agent per PR).
// Credentials: CURSOR_API_KEY, else the key stored by `sura-cloud login` (~/.cursor/sdk/auth.json).
import { Agent, Cursor, CursorAgentError } from "@cursor/sdk";
import { appendFileSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const STATE = join(process.env.XDG_STATE_HOME ?? join(homedir(), ".local/state"), "sura-cloud");
const LEDGER = join(STATE, "agents.jsonl");
const WEB = "https://cursor.com/agents";

const RULES = `Repository rules (non-negotiable):
- Work on a new auxiliary branch; never commit to the default branch.
- Before finishing, rebase the branch onto the latest default branch so history stays linear.
- Open one pull request into the default branch. Body: "## Summary" (what changed, with a diff or tree when useful) and "## Evidence" (commands run and their real output, before/after).
- Never add Co-authored-by or any other attribution trailer to commits.
- Do not merge. The human merges.
- If the same pull request needs more work later (rebase, CI, review findings), it will come back to you in this same conversation.

Task:
`;

function usage(): never {
  console.error(`usage:
  sura-cloud login                       sign in through the browser (mints a 90-day key)
  sura-cloud whoami                      show the key in use
  sura-cloud launch --repo <owner/name|url> [--ref <branch>] [--pr <url>] [--model <id>] [--raw] <task>
  sura-cloud send <bc-id> <message>      follow-up to the same agent (same PR)
  sura-cloud show <bc-id>                status, branch, PR and cost
  sura-cloud wait <bc-id> [--every <s>]  block until the latest run ends, then show
  sura-cloud list [--limit <n>]`);
  process.exit(64);
}

function repoUrl(r: string): string {
  return /^https?:\/\//.test(r) ? r : `https://github.com/${r.replace(/\.git$/, "")}`;
}

function cents(c?: { rawCostCents: number; chargedCents: number }): string {
  if (!c) return "cost not reported yet";
  const extra = c.chargedCents > 0 ? `  ⚠ charged outside the plan: $${(c.chargedCents / 100).toFixed(2)}` : "  (charged: $0, inside the plan)";
  return `raw $${(c.rawCostCents / 100).toFixed(2)}${extra}`;
}

async function show(id: string) {
  const info = await Agent.get(id);
  const runs = await Agent.listRuns(id, { runtime: "cloud", limit: 1 });
  const run = runs.items[0];
  console.log(`${info.agentId}  ${info.status ?? "?"}  ${info.name}`);
  console.log(`  ${WEB}/${info.agentId}`);
  for (const b of run?.git?.branches ?? []) console.log(`  branch ${b.branch ?? "-"}  pr ${b.prUrl ?? "-"}`);
  if (run?.result) console.log(`  result: ${run.result.split("\n").slice(0, 6).join("\n          ")}`);
  if (run?.error) console.log(`  error: ${run.error.message}`);
  const u = await Agent.getUsage(id).catch(() => undefined);
  console.log(`  ${cents(u?.cost)}`);
}

async function main() {
  const [cmd, ...rest] = process.argv.slice(2);
  const flag = (name: string) => {
    const i = rest.indexOf(`--${name}`);
    if (i < 0) return undefined;
    const v = rest[i + 1];
    rest.splice(i, 2);
    return v;
  };
  const bool = (name: string) => {
    const i = rest.indexOf(`--${name}`);
    if (i < 0) return false;
    rest.splice(i, 1);
    return true;
  };

  switch (cmd) {
    case "login": {
      const r = await Cursor.auth.login({ apiKeyName: "sura-cloud", onLoginUrl: (u) => console.log(`Open: ${u}`) });
      console.log(`logged in${r && "email" in r && r.email ? ` as ${r.email}` : ""}`);
      return;
    }
    case "whoami": {
      const me = await Cursor.me();
      console.log(`${me.userEmail ?? "?"}  key "${me.apiKeyName}" (created ${me.createdAt})`);
      return;
    }
    case "launch": {
      const repo = flag("repo");
      const ref = flag("ref");
      const pr = flag("pr");
      const model = flag("model") ?? "auto";
      const raw = bool("raw");
      const task = rest.join(" ").trim();
      if (!repo || !task) usage();
      const agent = await Agent.create({
        model: { id: model },
        cloud: {
          repos: [{ url: repoUrl(repo), ...(ref ? { startingRef: ref } : {}), ...(pr ? { prUrl: pr } : {}) }],
          autoCreatePR: !pr,
          skipReviewerRequest: true,
          metadata: { by: "sura" },
        },
      });
      const run = await agent.send(raw ? task : RULES + task);
      mkdirSync(STATE, { recursive: true });
      appendFileSync(LEDGER, JSON.stringify({ ts: new Date().toISOString(), id: agent.agentId, run: run.id, repo, ref, pr, model, task: task.slice(0, 200) }) + "\n");
      console.log(`${agent.agentId}  run ${run.id}\n  ${WEB}/${agent.agentId}`);
      agent.close();
      return;
    }
    case "send": {
      const [id, ...msg] = rest;
      if (!id?.startsWith("bc-") || msg.length === 0) usage();
      const agent = await Agent.resume(id);
      const run = await agent.send(msg.join(" "));
      mkdirSync(STATE, { recursive: true });
      appendFileSync(LEDGER, JSON.stringify({ ts: new Date().toISOString(), id, run: run.id, followUp: msg.join(" ").slice(0, 200) }) + "\n");
      console.log(`${id}  run ${run.id}\n  ${WEB}/${id}`);
      agent.close();
      return;
    }
    case "show": {
      if (!rest[0]?.startsWith("bc-")) usage();
      await show(rest[0]);
      return;
    }
    case "wait": {
      const every = Number(flag("every") ?? 30) * 1000;
      const id = rest[0];
      if (!id?.startsWith("bc-")) usage();
      while ((await Agent.get(id)).status === "running") await Bun.sleep(every);
      await show(id);
      return;
    }
    case "list": {
      const limit = Number(flag("limit") ?? 15);
      const r = await Agent.list({ runtime: "cloud", limit });
      for (const a of r.items) {
        const when = a.lastModified ? new Date(a.lastModified).toISOString().slice(0, 16).replace("T", " ") : "";
        console.log(`${a.agentId}  ${(a.status ?? "?").padEnd(8)}  ${when}  ${a.name}`);
      }
      return;
    }
    default:
      usage();
  }
}

main().catch((err) => {
  if (err instanceof CursorAgentError) {
    console.error(`sura-cloud: ${err.message}${err.isRetryable ? " (retryable)" : ""}`);
    if (/auth|401|api key|unauthor/i.test(err.message)) console.error("sign in first: sura-cloud login");
    process.exit(1);
  }
  console.error(`sura-cloud: ${err?.message ?? err}`);
  process.exit(2);
});
