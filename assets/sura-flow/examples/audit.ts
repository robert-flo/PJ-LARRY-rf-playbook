// Example plan: one finder per file (wide, allowed to over-report), then a refute wave.
//   sura-flow run audit.ts <dir> "<what to look for>"
import { readdirSync, statSync } from "node:fs";
import { join, resolve } from "node:path";
import type { Flow } from "../sura-flow.ts";

export default async function (flow: Flow, [dir = ".", focus = "real bugs"]: string[]) {
  const root = resolve(dir);
  const files = readdirSync(root).filter((f) => statSync(join(root, f)).isFile());
  flow.log(`${files.length} files → ${files.length} finders`);

  const found = await flow.parallel(files, (f) =>
    flow.agent(
      `Audit only the file ${f} for: ${focus}. Over-report rather than miss. ` +
        `One finding per line, each starting with "FINDING: ${f}:<line> — ". If nothing, reply "NONE".`,
      { cwd: root, label: `find-${f}` },
    ),
  );
  const findings = found.flatMap((a) => a.split("\n").filter((l) => l.startsWith("FINDING:")).map((l) => l.slice(8).trim()));
  flow.log(`${findings.length} findings → refute wave`);

  const verdicts = await flow.refute(findings, { cwd: root, context: `The concern is: ${focus}.` });
  const kept = verdicts.filter((v) => v.keep);
  return [
    `kept ${kept.length} of ${findings.length}:`,
    ...kept.map((v) => `  ✓ ${v.finding}`),
    ...verdicts.filter((v) => !v.keep).map((v) => `  ✗ ${v.finding}\n      ${v.why}`),
  ].join("\n");
}
