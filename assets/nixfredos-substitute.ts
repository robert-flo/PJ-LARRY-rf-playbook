#!/usr/bin/env bun
/**
 * Render nixfredOS identity placeholders ({{DA_NAME}}, {{PRINCIPAL_NAME}}, ...) across the installed
 * tree, with values read from NIXFREDOS_CONFIG.toml. Run it after InstallHooks and DeployComponents:
 * both copy fresh templates, so substituting earlier leaves them unrendered.
 *
 * Skips skills/nixfredOS: substituting the redistribution payload would also rewrite the
 * IDENTITY_PLACEHOLDERS list inside InstallEngine.ts.
 *
 * usage: bun assets/nixfredos-substitute.ts [--check]   (--check exits 1 if placeholders survive)
 */
import { existsSync, readdirSync } from "fs";
import { join } from "path";

const root = process.env.NIXFREDOS_CONFIG_ROOT || join(process.env.HOME!, ".claude");
const { substituteTree, checkSurvivingPlaceholders } = await import(join(root, "skills/nixfredOS/Tools/InstallEngine.ts"));
const { loadnixfredOSConfig } = await import(join(root, "NIXFREDOS/TOOLS/nixfredOSConfig.ts"));

const c = loadnixfredOSConfig();
const da = c.da?.name;
const principal = c.principal?.name;
if (!da || !principal) {
  console.error("nixfredos-substitute: principal.name / da.name missing in NIXFREDOS_CONFIG.toml");
  process.exit(2);
}
const raw: Record<string, string> = {
  DA_NAME: da,
  DA_FULL_NAME: c.da?.full_name || da,
  PRINCIPAL_NAME: principal,
  PRINCIPAL_FULL_NAME: c.principal?.full_name || principal,
  PRIMARY_VOICE_ID: c.voice?.primary_voice_id || "21m00Tcm4TlvDq8ikWAM",
  SECONDARY_VOICE_ID: c.voice?.secondary_voice_id || "",
  NIXFREDOS_VERSION: c.version || "1.5.0",
};
// substituteTree only accepts fully delimited keys and silently ignores bare ones.
const vars = Object.fromEntries(Object.entries(raw).map(([k, v]) => [`{{${k}}}`, v]));

// NIXFREDOS/USER is a symlink, which the tree walk does not follow, so it is listed on its own.
const roots = [
  "NIXFREDOS", "NIXFREDOS/USER", "hooks", "agents", "commands",
  ...readdirSync(join(root, "skills")).filter(s => s !== "nixfredOS").map(s => `skills/${s}`),
].map(r => join(root, r)).filter(existsSync);

const check = process.argv.includes("--check");
let applied = 0, survivors = 0;
for (const r of roots) {
  if (!check) applied += substituteTree(r, vars).applied;
  survivors += checkSurvivingPlaceholders(r).total;
}
console.log(`nixfredos-substitute: ${check ? "checked" : `applied ${applied}`}, surviving ${survivors} (${da} / ${principal})`);
process.exit(survivors ? 1 : 0);
