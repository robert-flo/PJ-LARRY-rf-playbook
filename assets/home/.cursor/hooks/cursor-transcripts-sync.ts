#!/usr/bin/env bun
/**
 * PJ-LARRY: the nixfredOS memory engine reads Claude Code transcripts from ~/.claude/projects.
 * cursor-agent writes its own format to ~/.cursor/projects/<ws>/agent-transcripts/<id>/<id>.jsonl.
 * This mirrors each Cursor transcript into the Claude layout (user queries and assistant text only;
 * tool calls and redacted reasoning are dropped), then lets the engine's own `mem import` load it.
 *
 * `mem import` skips sessions it already has, so a transcript that grew since the last run has its
 * session deleted from memory.db first (the FTS delete trigger keeps the index consistent).
 *
 * usage: cursor-transcripts-sync.ts [--dry-run] [--verbose]
 */
import { Database } from "bun:sqlite";
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, statSync, writeFileSync } from "fs";
import { join } from "path";

const HOME = process.env.HOME!;
const CURSOR_PROJECTS = join(HOME, ".cursor", "projects");
const CLAUDE_PROJECTS = join(HOME, ".claude", "projects");
const MEMORY_DB = process.env.MEM_DB_PATH || join(HOME, ".claude", "memory.db");
const MEM_BIN = join(HOME, "bin", "mem");
const dryRun = process.argv.includes("--dry-run");
const verbose = process.argv.includes("--verbose");

// Same encoding the engine's hooks use to locate a session by cwd.
const encodeCwd = (cwd: string) => "-" + cwd.replace(/^\/+/, "").replace(/[\/_]/g, "-");

const MONTHS: Record<string, number> = { Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5, Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11 };

// "<timestamp>Monday, Oct 12, 2026, 9:55 PM (UTC-6)</timestamp>"
function parseCursorTimestamp(text: string): string | null {
  const m = text.match(/<timestamp>\w+, (\w{3}) (\d{1,2}), (\d{4}), (\d{1,2}):(\d{2}) (AM|PM) \(UTC([+-]\d{1,2})(?::(\d{2}))?\)<\/timestamp>/);
  if (!m || MONTHS[m[1]] === undefined) return null;
  let hour = Number(m[4]) % 12;
  if (m[6] === "PM") hour += 12;
  const offsetMin = Number(m[7]) * 60 + Math.sign(Number(m[7]) || 1) * Number(m[8] || 0);
  const utc = Date.UTC(Number(m[3]), MONTHS[m[1]], Number(m[2]), hour, Number(m[5])) - offsetMin * 60_000;
  return new Date(utc).toISOString();
}

function userText(raw: string): string {
  const q = raw.match(/<user_query>\s*([\s\S]*?)\s*<\/user_query>/);
  return (q ? q[1] : raw.replace(/<timestamp>[\s\S]*?<\/timestamp>/g, "")).trim();
}

function assistantText(raw: string): string {
  return raw.replace(/\[REDACTED\]/g, "").trim();
}

function workspacePath(projectDir: string, name: string): string {
  try {
    const t = JSON.parse(readFileSync(join(projectDir, ".workspace-trusted"), "utf8"));
    if (typeof t.workspacePath === "string") return t.workspacePath;
  } catch {}
  return "/" + name;
}

function convert(src: string, sessionId: string, cwd: string): string[] {
  const out: string[] = [];
  const mtime = statSync(src).mtime.toISOString();
  let lastTs: string | null = null;
  for (const line of readFileSync(src, "utf8").split("\n")) {
    if (!line.trim()) continue;
    let obj: any;
    try { obj = JSON.parse(line); } catch { continue; }
    const role = obj?.role;
    const blocks = Array.isArray(obj?.message?.content) ? obj.message.content : [];
    if (role !== "user" && role !== "assistant") continue;
    const raw = blocks.filter((b: any) => b?.type === "text" && typeof b.text === "string").map((b: any) => b.text).join("\n");
    if (role === "user") lastTs = parseCursorTimestamp(raw) ?? lastTs;
    const text = role === "user" ? userText(raw) : assistantText(raw);
    if (!text) continue;
    out.push(JSON.stringify({
      type: role,
      sessionId,
      cwd,
      timestamp: lastTs ?? mtime,
      message: { role, content: [{ type: "text", text }] },
    }));
  }
  return out;
}

const changed: string[] = [];
let scanned = 0;
if (existsSync(CURSOR_PROJECTS)) {
  for (const ws of readdirSync(CURSOR_PROJECTS, { withFileTypes: true })) {
    if (!ws.isDirectory()) continue;
    const projectDir = join(CURSOR_PROJECTS, ws.name);
    const transcripts = join(projectDir, "agent-transcripts");
    if (!existsSync(transcripts)) continue;
    const cwd = workspacePath(projectDir, ws.name);
    // Test benches (canaries, hook bisects, the claude adapter) must not become Sura's memory.
    if ([join(HOME, ".cache"), "/tmp"].some(d => cwd === d || cwd.startsWith(d + "/"))) continue;
    const destDir = join(CLAUDE_PROJECTS, encodeCwd(cwd));
    for (const conv of readdirSync(transcripts, { withFileTypes: true })) {
      if (!conv.isDirectory()) continue;
      const src = join(transcripts, conv.name, `${conv.name}.jsonl`);
      if (!existsSync(src)) continue;
      scanned++;
      const dest = join(destDir, `${conv.name}.jsonl`);
      if (existsSync(dest) && statSync(dest).mtimeMs >= statSync(src).mtimeMs) continue;
      const lines = convert(src, conv.name, cwd);
      if (lines.length === 0) continue;
      changed.push(conv.name);
      if (verbose) console.log(`${dryRun ? "[dry-run] " : ""}${conv.name} (${lines.length} msgs) -> ${dest.replace(HOME, "~")}`);
      if (dryRun) continue;
      mkdirSync(destDir, { recursive: true });
      writeFileSync(dest + ".tmp", lines.join("\n") + "\n");
      renameSync(dest + ".tmp", dest);
    }
  }
}

let deleted = 0;
if (!dryRun && changed.length && existsSync(MEMORY_DB)) {
  const db = new Database(MEMORY_DB);
  const delMsgs = db.prepare("DELETE FROM messages WHERE session_id = ?");
  const delSess = db.prepare("DELETE FROM sessions WHERE session_id = ?");
  db.transaction(() => {
    for (const id of changed) {
      delMsgs.run(id);
      deleted += delSess.run(id).changes;
    }
  })();
  db.close();
}

console.log(`cursor-transcripts-sync: scanned ${scanned}, converted ${changed.length}, re-import ${deleted}${dryRun ? " (dry-run)" : ""}`);
// Always import: `mem import` only loads sessions memory.db lacks, so earlier failures retry here.
if (!dryRun) {
  const r = Bun.spawnSync([MEM_BIN, "import", "-y"], { stdout: "pipe", stderr: "pipe" });
  const out = r.stdout.toString() + r.stderr.toString();
  const summary = out.split("\n").filter(l => /Sessions imported|Messages imported|Errors?:/.test(l)).map(l => l.trim()).join(", ");
  console.log(`mem import: exit ${r.exitCode}${summary ? " — " + summary : ""}`);
  process.exit(r.exitCode ?? 1);
}
