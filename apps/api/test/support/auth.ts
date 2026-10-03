import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { exportJWK, generateKeyPair, SignJWT, type JWK, type CryptoKey } from 'jose';

export const ISSUER = 'http://127.0.0.1:54321/auth/v1';
export const AUDIENCE = 'authenticated';

export interface TestKeys {
  privateKey: CryptoKey;
  jwk: JWK;
  kid: string;
}

export async function createTestKeys(kid = 'test-key-1'): Promise<TestKeys> {
  const { privateKey, publicKey } = await generateKeyPair('ES256', { extractable: true });
  const jwk = { ...(await exportJWK(publicKey)), kid, alg: 'ES256', use: 'sig' };
  return { privateKey, jwk, kid };
}

/** Serves a JWKS document over HTTP so tests exercise the real remote JWKS fetch path. */
export async function startJwksServer(
  keys: JWK[],
): Promise<{ url: string; close: () => Promise<void>; server: Server }> {
  const server = createServer((req, res) => {
    if (req.url === '/auth/v1/.well-known/jwks.json') {
      res.writeHead(200, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ keys }));
      return;
    }
    res.writeHead(404).end();
  });
  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address() as AddressInfo;
  return {
    url: `http://127.0.0.1:${port}/auth/v1/.well-known/jwks.json`,
    server,
    close: () => new Promise((resolve) => server.close(() => resolve())),
  };
}

export interface TokenOptions {
  sub?: string;
  role?: string;
  issuer?: string;
  audience?: string;
  expiresIn?: string | number;
  isAnonymous?: boolean;
  key?: TestKeys;
}

export async function signToken(keys: TestKeys, options: TokenOptions = {}): Promise<string> {
  const key = options.key ?? keys;
  const jwt = new SignJWT({
    role: options.role ?? 'authenticated',
    is_anonymous: options.isAnonymous ?? false,
    session_id: 'test-session',
  })
    .setProtectedHeader({ alg: 'ES256', kid: key.kid, typ: 'JWT' })
    .setIssuer(options.issuer ?? ISSUER)
    .setAudience(options.audience ?? AUDIENCE)
    .setIssuedAt();
  if (options.sub !== undefined) jwt.setSubject(options.sub);
  jwt.setExpirationTime(options.expiresIn ?? '5m');
  return jwt.sign(key.privateKey);
}
