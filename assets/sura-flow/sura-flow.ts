#!/usr/bin/env bun
// sura-flow: run a workflow whose plan is a script, not context. The plan fans out
// read-only cursor-agent subagents (model Auto), then a refute wave keeps only what survives.
//
//   sura-flow run <plan.ts> [args...]     SURA_FLOW_MAX=4 concurrent agents, SURA_FLOW_CAP=40 per run
//
// A plan exports `default async function (flow: Flow, args: string[])` and returns what to print.
// Every prompt and answer is logged to $XDG_STATE_HOME/sura-flow/<run>/.
import { mkdirSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

const MAX = Number(process.env.SURA_FLOW_MAX ?? 4);
const CAP = Number(process.env.SURA_FLOW_CAP ?? 40);
const RUN = new Date().toISOString().replace(/[:.]/g, "-");
const DIR = join(process.env.XDG_STATE_HOME ?? join(homedir(), ".local/state"), "sura-flow", RUN);

export type Verdict = { finding: string; keep: boolean; why: string };
export type Flow = {
  agent: (prompt: string, opts?: { cwd?: string; label?: string }) => Promise<string>;
  parallel: <T, R>(items: T[], fn: (item: T, i: number) => Promise<R>) => Promise<R[]>;
  refute: (findings: string[], opts?: { cwd?: string; context?: string }) => Promise<Verdict[]>;
  log: (msg: string) => void;
  spent: () => number;
};

let active = 0;
let spent = 0;
const queue: (() => void)[] = [];
const slot = () => (active < MAX ? (active++, Promise.resolve()) : new Promise<void>((r) => queue.push(r)));
const release = () => {
  const next = queue.shift();
  next ? next() : active--;
};

const log = (msg: string) => console.error(`[sura-flow] ${msg}`);

async function agent(prompt: string, opts: { cwd?: string; label?: string } = {}): Promise<string> {
  if (spent >= CAP) throw new Error(`agent cap reached (${CAP}); raise SURA_FLOW_CAP if this run really needs more`);
  const n = ++spent;
  const label = `${String(n).padStart(3, "0")}-${(opts.label ?? "agent").replace(/[^\w-]/g, "_")}`;
  await slot();
  try {
    log(`→ ${label}`);
    const p = Bun.spawn(["cursor-agent", "-p", "--trust", "--mode", "ask", "--model", "auto", "--output-format", "json"], {
      cwd: opts.cwd ?? process.cwd(),
      stdin: new Blob([prompt]),
      stdout: "pipe",
      stderr: "pipe",
    });
    const timer = setTimeout(() => p.kill(), 300_000);
    const out = await new Response(p.stdout).text();
    clearTimeout(timer);
    await p.exited;
    let answer: string;
    try {
      answer = JSON.parse(out).result ?? "";
    } catch {
      answer = "";
    }
    if (!answer) answer = `(no answer, exit ${p.exitCode}) ${out.slice(0, 300)}`;
    writeFileSync(join(DIR, `${label}.md`), `# prompt\n\n${prompt}\n\n# answer\n\n${answer}\n`);
    log(`✓ ${label}`);
    return answer;
  } finally {
    release();
  }
}

const parallel = <T, R>(items: T[], fn: (item: T, i: number) => Promise<R>) => Promise.all(items.map(fn));

async function refute(findings: string[], opts: { cwd?: string; context?: string } = {}): Promise<Verdict[]> {
  return parallel(findings, async (finding, i) => {
    const answer = await agent(
      `You are a skeptical verifier with no stake in this finding. Try hard to prove it WRONG by reading the actual code; ` +
        `do not trust the finding's wording. ${opts.context ?? ""}\n\nFinding:\n${finding}\n\n` +
        `Reply with exactly one first line, "VERDICT: KEEP" if it is real or "VERDICT: DROP" if it is wrong or not worth reporting, ` +
        `then one sentence with the evidence (file:line).`,
      { cwd: opts.cwd, label: `refute-${i + 1}` },
    );
    const m = answer.match(/VERDICT:\s*(KEEP|DROP)/i);
    return { finding, keep: m ? m[1].toUpperCase() === "KEEP" : true, why: answer.replace(/^.*VERDICT:\s*\w+\s*/is, "").trim().split("\n")[0] };
  });
}

async function main() {
  const [cmd, plan, ...args] = process.argv.slice(2);
  if (cmd !== "run" || !plan) {
    console.error("usage: sura-flow run <plan.ts> [args...]");
    process.exit(64);
  }
  mkdirSync(DIR, { recursive: true });
  const mod = await import(resolve(plan));
  const flow: Flow = { agent, parallel, refute, log, spent: () => spent };
  const out = await mod.default(flow, args);
  if (out !== undefined) console.log(typeof out === "string" ? out : JSON.stringify(out, null, 2));
  log(`${spent} agents (model auto) · log ${DIR}`);
}

main().catch((err) => {
  console.error(`sura-flow: ${err?.message ?? err}`);
  process.exit(2);
});
