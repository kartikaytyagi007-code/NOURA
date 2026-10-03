import { createHmac, randomUUID, timingSafeEqual } from 'node:crypto';
import { mkdir, readFile, rm, stat, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import type { AppEnv } from '../env.js';

/**
 * Private media storage (blueprint §8/§14): the API/worker are the only callers, images are never
 * served from a public URL, and access is always through a short-lived signed link minted after an
 * ownership check. Two implementations exist, selected exactly like `createAiProvider` (D-010):
 *
 * - `local` (development/test only): bytes live on local disk; "signed" URLs point back at the API's
 *   own `/dev-storage/*` route (registered only outside deployed environments) and are authorized by
 *   an HMAC token with an expiry, not by Supabase. This is what lets the whole upload → verify →
 *   recognize → review pipeline be exercised in this container, which has no reachable Supabase
 *   project.
 * - `supabase` (required in staging/production): talks to the real Supabase Storage REST API with
 *   the service-role key over HTTPS. This adapter has not been exercised against a live project in
 *   this environment (no project is configured here); its request/response shapes are unit-tested
 *   against a mocked fetch only, the same documented limitation as D-011's OAuth providers.
 */
export interface SignedUrl {
  url: string;
  expiresAt: string;
}

export interface MediaStorage {
  readonly driver: 'local' | 'supabase';
  createUploadUrl(bucket: string, objectPath: string, mime: string): Promise<SignedUrl>;
  createDownloadUrl(bucket: string, objectPath: string): Promise<SignedUrl>;
  /** Fetches the object's current bytes for server-side verification/recognition. Null if missing. */
  readObject(bucket: string, objectPath: string): Promise<Uint8Array | null>;
  deleteObject(bucket: string, objectPath: string): Promise<void>;
  /**
   * Writes bytes directly, server-side — used only for server-generated objects the client never
   * uploads itself (M10: the account-data export manifest). Never used for user-submitted media,
   * which always goes through the signed-upload-url flow above so the server can verify bytes/type
   * before trusting them.
   */
  writeObject(
    bucket: string,
    objectPath: string,
    bytes: Uint8Array,
    contentType: string,
  ): Promise<void>;
}

// ---------------------------------------------------------------------------------------------
// local (development/test)
// ---------------------------------------------------------------------------------------------

export interface LocalMediaStorageOptions {
  baseDir: string;
  /** Base URL of the API process serving `/dev-storage/*` (e.g. http://127.0.0.1:8080). */
  publicBaseUrl: string;
  signingSecret: string;
  urlTtlSeconds?: number;
}

function signToken(
  secret: string,
  bucket: string,
  objectPath: string,
  expiresAtMs: number,
): string {
  const payload = `${bucket}:${objectPath}:${expiresAtMs}`;
  return createHmac('sha256', secret).update(payload).digest('hex');
}

/** Verifies a dev-storage token. Used by the API's `/dev-storage/*` route handlers. */
export function verifyDevStorageToken(
  secret: string,
  bucket: string,
  objectPath: string,
  expiresAtMs: number,
  token: string,
): boolean {
  if (!Number.isFinite(expiresAtMs) || expiresAtMs < Date.now()) return false;
  const expected = signToken(secret, bucket, objectPath, expiresAtMs);
  const a = Buffer.from(expected, 'hex');
  const b = Buffer.from(token, 'hex');
  return a.length === b.length && timingSafeEqual(a, b);
}

function safeObjectPath(bucket: string, objectPath: string, baseDir: string): string {
  if (objectPath.includes('..') || objectPath.startsWith('/')) {
    throw new Error('invalid object path');
  }
  return resolve(baseDir, bucket, objectPath);
}

export class LocalMediaStorage implements MediaStorage {
  readonly driver = 'local' as const;
  constructor(private readonly options: LocalMediaStorageOptions) {}

  async createUploadUrl(bucket: string, objectPath: string, _mime: string): Promise<SignedUrl> {
    const ttl = (this.options.urlTtlSeconds ?? 600) * 1000;
    const expiresAtMs = Date.now() + ttl;
    const token = signToken(this.options.signingSecret, bucket, objectPath, expiresAtMs);
    const url = `${this.options.publicBaseUrl}/dev-storage/${bucket}/${objectPath}?exp=${expiresAtMs}&token=${token}&mode=upload`;
    return { url, expiresAt: new Date(expiresAtMs).toISOString() };
  }

  async createDownloadUrl(bucket: string, objectPath: string): Promise<SignedUrl> {
    const ttl = (this.options.urlTtlSeconds ?? 600) * 1000;
    const expiresAtMs = Date.now() + ttl;
    const token = signToken(this.options.signingSecret, bucket, objectPath, expiresAtMs);
    const url = `${this.options.publicBaseUrl}/dev-storage/${bucket}/${objectPath}?exp=${expiresAtMs}&token=${token}&mode=download`;
    return { url, expiresAt: new Date(expiresAtMs).toISOString() };
  }

  /** Verifies a token minted by `createUploadUrl`/`createDownloadUrl`. Used by the dev-storage route. */
  verifyToken(bucket: string, objectPath: string, expiresAtMs: number, token: string): boolean {
    return verifyDevStorageToken(
      this.options.signingSecret,
      bucket,
      objectPath,
      expiresAtMs,
      token,
    );
  }

  /** Test/dev-only direct write, used by the dev-storage HTTP route and by tests that simulate an upload. */
  async writeObject(
    bucket: string,
    objectPath: string,
    bytes: Uint8Array,
    _contentType?: string,
  ): Promise<void> {
    const path = safeObjectPath(bucket, objectPath, this.options.baseDir);
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, bytes);
  }

  async readObject(bucket: string, objectPath: string): Promise<Uint8Array | null> {
    const path = safeObjectPath(bucket, objectPath, this.options.baseDir);
    try {
      const buf = await readFile(path);
      return new Uint8Array(buf);
    } catch {
      return null;
    }
  }

  async objectExists(bucket: string, objectPath: string): Promise<boolean> {
    try {
      await stat(safeObjectPath(bucket, objectPath, this.options.baseDir));
      return true;
    } catch {
      return false;
    }
  }

  async deleteObject(bucket: string, objectPath: string): Promise<void> {
    const path = safeObjectPath(bucket, objectPath, this.options.baseDir);
    await rm(path, { force: true });
  }
}

// ---------------------------------------------------------------------------------------------
// supabase (staging/production)
// ---------------------------------------------------------------------------------------------

export interface SupabaseMediaStorageOptions {
  supabaseUrl: string;
  serviceRoleKey: string;
  urlTtlSeconds?: number;
  fetchImpl?: typeof fetch;
}

/** Real Supabase Storage REST adapter. See the module doc comment for its verification status. */
export class SupabaseMediaStorage implements MediaStorage {
  readonly driver = 'supabase' as const;
  private readonly base: string;
  private readonly fetchImpl: typeof fetch;

  constructor(private readonly options: SupabaseMediaStorageOptions) {
    this.base = options.supabaseUrl.replace(/\/+$/, '');
    this.fetchImpl = options.fetchImpl ?? fetch;
  }

  private headers(): Record<string, string> {
    return {
      authorization: `Bearer ${this.options.serviceRoleKey}`,
      apikey: this.options.serviceRoleKey,
      'content-type': 'application/json',
    };
  }

  async createUploadUrl(bucket: string, objectPath: string): Promise<SignedUrl> {
    const ttl = this.options.urlTtlSeconds ?? 600;
    const res = await this.fetchImpl(
      `${this.base}/storage/v1/object/upload/sign/${bucket}/${objectPath}`,
      { method: 'POST', headers: this.headers(), body: JSON.stringify({ expiresIn: ttl }) },
    );
    if (!res.ok) throw new Error(`storage upload-sign failed: ${res.status}`);
    const body = (await res.json()) as { url?: string; signedUrl?: string; token?: string };
    const path = body.url ?? body.signedUrl;
    if (!path) throw new Error('storage upload-sign returned no url');
    return {
      url: path.startsWith('http') ? path : `${this.base}/storage/v1${path}`,
      expiresAt: new Date(Date.now() + ttl * 1000).toISOString(),
    };
  }

  async createDownloadUrl(bucket: string, objectPath: string): Promise<SignedUrl> {
    const ttl = this.options.urlTtlSeconds ?? 600;
    const res = await this.fetchImpl(
      `${this.base}/storage/v1/object/sign/${bucket}/${objectPath}`,
      {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify({ expiresIn: ttl }),
      },
    );
    if (!res.ok) throw new Error(`storage sign failed: ${res.status}`);
    const body = (await res.json()) as { signedURL?: string; signedUrl?: string };
    const path = body.signedURL ?? body.signedUrl;
    if (!path) throw new Error('storage sign returned no url');
    return {
      url: path.startsWith('http') ? path : `${this.base}/storage/v1${path}`,
      expiresAt: new Date(Date.now() + ttl * 1000).toISOString(),
    };
  }

  async readObject(bucket: string, objectPath: string): Promise<Uint8Array | null> {
    const res = await this.fetchImpl(`${this.base}/storage/v1/object/${bucket}/${objectPath}`, {
      headers: {
        authorization: `Bearer ${this.options.serviceRoleKey}`,
        apikey: this.options.serviceRoleKey,
      },
    });
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`storage read failed: ${res.status}`);
    return new Uint8Array(await res.arrayBuffer());
  }

  async deleteObject(bucket: string, objectPath: string): Promise<void> {
    const res = await this.fetchImpl(`${this.base}/storage/v1/object/${bucket}/${objectPath}`, {
      method: 'DELETE',
      headers: {
        authorization: `Bearer ${this.options.serviceRoleKey}`,
        apikey: this.options.serviceRoleKey,
      },
    });
    if (!res.ok && res.status !== 404) throw new Error(`storage delete failed: ${res.status}`);
  }

  async writeObject(
    bucket: string,
    objectPath: string,
    bytes: Uint8Array,
    contentType: string,
  ): Promise<void> {
    const res = await this.fetchImpl(`${this.base}/storage/v1/object/${bucket}/${objectPath}`, {
      method: 'POST',
      headers: {
        authorization: `Bearer ${this.options.serviceRoleKey}`,
        apikey: this.options.serviceRoleKey,
        'content-type': contentType,
        'x-upsert': 'true',
      },
      body: bytes,
    });
    if (!res.ok) throw new Error(`storage write failed: ${res.status}`);
  }
}

// ---------------------------------------------------------------------------------------------
// factory (fails closed, mirrors createAiProvider)
// ---------------------------------------------------------------------------------------------

export interface MediaStorageConfig {
  appEnv: AppEnv;
  driver?: 'local' | 'supabase' | undefined;
  supabaseUrl: string;
  serviceRoleKey?: string | undefined;
  local?: { baseDir: string; publicBaseUrl: string; signingSecret: string };
}

export function createMediaStorage(config: MediaStorageConfig): MediaStorage {
  const deployed = config.appEnv === 'staging' || config.appEnv === 'production';
  const driver = config.driver ?? (deployed ? 'supabase' : 'local');
  if (driver === 'local') {
    if (deployed)
      throw new Error(`MEDIA_STORAGE_DRIVER=local is not allowed when APP_ENV=${config.appEnv}`);
    if (!config.local)
      throw new Error('local media storage requires baseDir/publicBaseUrl/signingSecret');
    return new LocalMediaStorage(config.local);
  }
  if (!config.serviceRoleKey) {
    throw new Error('MEDIA_STORAGE_DRIVER=supabase requires SUPABASE_SERVICE_ROLE_KEY');
  }
  return new SupabaseMediaStorage({
    supabaseUrl: config.supabaseUrl,
    serviceRoleKey: config.serviceRoleKey,
  });
}

export function newMediaId(): string {
  return randomUUID();
}
