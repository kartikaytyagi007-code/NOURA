#!/usr/bin/env node
// Regenerates the TypeScript types and the Dart client from packages/contracts/openapi.yaml and
// fails if the committed output differs. Run `pnpm contracts:generate` and commit to fix drift.
import { execFileSync } from 'node:child_process';

const GENERATED = ['packages/contracts/generated', 'apps/mobile/packages/noura_api_client'];

const run = (cmd, args) => execFileSync(cmd, args, { stdio: 'inherit' });
run('pnpm', ['--filter', '@noura/contracts', 'run', 'generate']);

const status = execFileSync('git', ['status', '--porcelain', '--', ...GENERATED], {
  encoding: 'utf8',
}).trim();
if (status) {
  console.error(
    `Generated API clients are out of date with openapi.yaml:\n${status}\nRun: pnpm contracts:generate`,
  );
  execFileSync('git', ['--no-pager', 'diff', '--stat', '--', ...GENERATED], { stdio: 'inherit' });
  process.exit(1);
}
console.log('Generated clients match openapi.yaml.');
