#!/usr/bin/env node
// Guards the repository against committed secrets and server-only configuration leaking into the
// Flutter app (blueprint §2/§13). Scans files tracked by git (or, outside git, the working tree).
// Exits non-zero with file:line references; never prints the matched value itself.
import { execFileSync } from 'node:child_process';
import { readFileSync, statSync } from 'node:fs';

const SKIP = [
  /^node_modules\//,
  /\/node_modules\//,
  /pnpm-lock\.yaml$/,
  /pubspec\.lock$/,
  /\.(png|jpg|jpeg|gif|webp|ico|otf|ttf|woff2?|jar|zip)$/i,
  /^scripts\/check-no-secrets\.mjs$/,
];

const SECRET_PATTERNS = [
  ['Supabase secret key', /sb_secret_[A-Za-z0-9_-]{10,}/],
  ['private key block', /-----BEGIN (?:RSA |EC |OPENSSH |)PRIVATE KEY-----/],
  ['Google API key', /AIza[0-9A-Za-z_-]{35}/],
  ['RevenueCat secret key', /\bsk_[A-Za-z0-9]{20,}/],
  ['OpenAI-style key', /\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}/],
  ['GitHub token', /\bgh[pousr]_[A-Za-z0-9]{30,}/],
  ['JWT', /\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/],
];

// Server-only names that must never appear in the mobile app sources.
const MOBILE_FORBIDDEN = [
  /SERVICE_ROLE/,
  /SUPABASE_SECRET/,
  /AI_API_KEY/,
  /GEMINI_API_KEY/,
  /REVENUECAT_SECRET/,
  /REVENUECAT_WEBHOOK/,
  /DATABASE_URL/,
];

function listFiles() {
  try {
    return execFileSync('git', ['ls-files', '--cached', '--others', '--exclude-standard'], {
      encoding: 'utf8',
    })
      .split('\n')
      .filter(Boolean);
  } catch {
    throw new Error('check-no-secrets must run inside the git repository');
  }
}

const problems = [];
const files = listFiles().filter((f) => !SKIP.some((re) => re.test(f)));
for (const file of files) {
  if (/(^|\/)\.env(\.|$)/.test(file) && !file.endsWith('.example')) {
    problems.push(`${file}: environment file must not be committed (only *.example templates)`);
    continue;
  }
  if (/(^|\/)(google-services\.json|GoogleService-Info\.plist|signing_keys\.json)$/.test(file)) {
    problems.push(`${file}: credential file must not be committed`);
    continue;
  }
  let text;
  try {
    if (statSync(file).size > 2_000_000) continue;
    text = readFileSync(file, 'utf8');
  } catch {
    continue;
  }
  const lines = text.split('\n');
  const mobile = file.startsWith('apps/mobile/') && !file.startsWith('apps/mobile/build/');
  lines.forEach((line, i) => {
    for (const [label, re] of SECRET_PATTERNS) {
      if (re.test(line)) problems.push(`${file}:${i + 1}: looks like a ${label}`);
    }
    if (mobile && /\.(dart|json|yaml|plist|xml|gradle|kts)$/.test(file)) {
      for (const re of MOBILE_FORBIDDEN) {
        if (re.test(line))
          problems.push(
            `${file}:${i + 1}: server-only setting ${re.source} referenced in the mobile app`,
          );
      }
    }
  });
}

if (problems.length > 0) {
  console.error(`Secret check failed (${problems.length}):\n  ${problems.join('\n  ')}`);
  process.exit(1);
}
console.log(`Secret check passed (${files.length} files scanned).`);
