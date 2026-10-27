#!/usr/bin/env node
// Writes the DocC article that lists every rule, from the scanner's own catalog:
//
//   swift run migration-scan --list-rules --format json | node scripts/rule-catalog.mjs
//
// Output: Sources/MigrationScanner/MigrationScanner.docc/RuleReference.md. A test fails when the
// article and the catalog disagree, so run this after adding or changing a rule.
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const rules = JSON.parse(readFileSync(0, 'utf8'));
const categories = [
  ['scene-life-cycle', 'Scene life cycle'],
  ['uikit', 'UIKit'],
  ['liquid-glass', 'Liquid Glass'],
  ['swiftui', 'SwiftUI'],
  ['swift-language', 'Swift language'],
];
const cell = (text) => text.replace(/([|_*\\])/g, '\\$1');

const lines = [
  '# Rule reference',
  '',
  `All ${rules.length} rules, by category, with what to write instead.`,
  '',
  '## Overview',
  '',
  'Errors stop the app from compiling or launching with the current toolchain or SDK. Warnings are',
  'deprecated API that still works, or a setting the latest SDK ignores. Info findings are',
  'soft deprecations (`deprecated: 100000.0` in the SDK, no compiler warning yet) and design review',
  'points. `migration-scan --explain <rule>` prints a rule\'s full explanation and the SDK declaration',
  'it is based on.',
  '',
];
for (const [id, title] of categories) {
  const inCategory = rules.filter((rule) => rule.category === id);
  if (!inCategory.length) continue;
  lines.push(`### ${title}`, '', '| Rule | Severity | Fix |', '| --- | --- | --- |');
  for (const rule of inCategory) {
    lines.push(`| \`${rule.id}\`: ${cell(rule.title)} | ${rule.severity} | ${cell(rule.replacement)} |`);
  }
  lines.push('');
}
writeFileSync(join(root, 'Sources/MigrationScanner/MigrationScanner.docc/RuleReference.md'), lines.join('\n'));
