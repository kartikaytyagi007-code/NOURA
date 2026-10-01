#!/usr/bin/env node
// Generates the Dart Dio client from openapi.yaml into apps/mobile/packages/noura_api_client,
// then runs build_runner (json_serializable) and dart format so the committed output is stable.
// Requires: Java 11+ (OpenAPI Generator), and the Flutter/Dart SDK on PATH.
import { execFileSync } from 'node:child_process';
import { readFileSync, rmSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const pkg = path.resolve(here, '..');
const out = path.resolve(pkg, '../../apps/mobile/packages/noura_api_client');

const run = (cmd, args, cwd) =>
  execFileSync(cmd, args, { cwd, stdio: 'inherit', env: process.env });

rmSync(out, { recursive: true, force: true });
run(
  'pnpm',
  [
    'exec',
    'openapi-generator-cli',
    'generate',
    '-i',
    'openapi.yaml',
    '-g',
    'dart-dio',
    '-o',
    out,
    '--global-property',
    'skipFormModel=true,apiTests=false,modelTests=false,apiDocs=false,modelDocs=false',
    '--additional-properties',
    [
      'pubName=noura_api_client',
      'pubDescription=Generated-NOURA-API-client-do-not-edit',
      'pubVersion=0.1.0',
      'pubAuthor=NOURA',
      'serializationLibrary=json_serializable',
      'dateLibrary=core',
      'equalityCheckMethod=equatable',
      'finalProperties=true',
    ].join(','),
  ],
  pkg,
);
// Generator bookkeeping that would only add noise to drift checks.
for (const f of ['.travis.yml', 'git_push.sh', '.gitignore', 'README.md', 'doc', 'test']) {
  rmSync(path.join(out, f), { recursive: true, force: true });
}
// The generator's pubspec targets an older SDK; json_serializable output needs Dart >= 3.8
// (null-aware elements), so raise the SDK floor. Exact resolved versions (including the
// generator's unconstrained build_runner) are locked by the committed pubspec.lock.
const pubspecPath = path.join(out, 'pubspec.yaml');
let pubspec = readFileSync(pubspecPath, 'utf8');
pubspec = pubspec
  .replace(/sdk: '[^']+'/, "sdk: '^3.9.0'")
  .replace(/homepage: homepage\n/, '')
  .replace(/\s+test: '[^']+'/, '');
writeFileSync(pubspecPath, pubspec);
run('dart', ['pub', 'get'], out);
run('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs'], out);
run('dart', ['format', '.'], out);
