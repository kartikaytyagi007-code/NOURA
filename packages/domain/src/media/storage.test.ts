import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { createMediaStorage, LocalMediaStorage } from './storage.js';

let dir: string;
beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), 'noura-storage-test-'));
});
afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

describe('createMediaStorage (fails closed like createAiProvider)', () => {
  it('refuses local storage outside development/test', () => {
    for (const appEnv of ['staging', 'production'] as const) {
      expect(() =>
        createMediaStorage({ appEnv, driver: 'local', supabaseUrl: 'https://x.supabase.co' }),
      ).toThrow(/not allowed/);
    }
  });

  it('requires a service-role key for the supabase driver', () => {
    expect(() =>
      createMediaStorage({
        appEnv: 'production',
        driver: 'supabase',
        supabaseUrl: 'https://x.supabase.co',
      }),
    ).toThrow(/SERVICE_ROLE_KEY/);
  });

  it('defaults to local in development/test and supabase when deployed', () => {
    const local = createMediaStorage({
      appEnv: 'test',
      supabaseUrl: 'https://x.supabase.co',
      local: { baseDir: dir, publicBaseUrl: 'http://127.0.0.1', signingSecret: 's' },
    });
    expect(local.driver).toBe('local');
    expect(() =>
      createMediaStorage({ appEnv: 'staging', supabaseUrl: 'https://x.supabase.co' }),
    ).toThrow(/SERVICE_ROLE_KEY/);
  });
});

describe('LocalMediaStorage', () => {
  it('round-trips bytes written through writeObject/readObject', async () => {
    const storage = new LocalMediaStorage({
      baseDir: dir,
      publicBaseUrl: 'http://127.0.0.1',
      signingSecret: 's',
    });
    await storage.writeObject('meal-images', 'user-1/abc.png', new Uint8Array([1, 2, 3]));
    const read = await storage.readObject('meal-images', 'user-1/abc.png');
    expect(Array.from(read ?? [])).toEqual([1, 2, 3]);
  });

  it('returns null for a missing object instead of throwing', async () => {
    const storage = new LocalMediaStorage({
      baseDir: dir,
      publicBaseUrl: 'http://127.0.0.1',
      signingSecret: 's',
    });
    expect(await storage.readObject('meal-images', 'nope')).toBeNull();
  });

  it('mints a signed URL whose token verifies for that exact bucket/path/expiry only', async () => {
    const storage = new LocalMediaStorage({
      baseDir: dir,
      publicBaseUrl: 'http://127.0.0.1',
      signingSecret: 's',
    });
    const slot = await storage.createUploadUrl('meal-images', 'user-1/abc.png', 'image/png');
    const url = new URL(slot.url);
    const token = url.searchParams.get('token')!;
    const exp = Number(url.searchParams.get('exp'));
    expect(storage.verifyToken('meal-images', 'user-1/abc.png', exp, token)).toBe(true);
    expect(storage.verifyToken('meal-images', 'user-1/other.png', exp, token)).toBe(false);
    expect(storage.verifyToken('meal-images', 'user-1/abc.png', exp, 'wrong-token')).toBe(false);
  });

  it('rejects an expired token', async () => {
    const storage = new LocalMediaStorage({
      baseDir: dir,
      publicBaseUrl: 'http://127.0.0.1',
      signingSecret: 's',
    });
    const slot = await storage.createUploadUrl('meal-images', 'user-1/abc.png', 'image/png');
    const url = new URL(slot.url);
    const token = url.searchParams.get('token')!;
    expect(storage.verifyToken('meal-images', 'user-1/abc.png', Date.now() - 1000, token)).toBe(
      false,
    );
  });

  it('rejects a path that tries to escape the bucket directory', async () => {
    const storage = new LocalMediaStorage({
      baseDir: dir,
      publicBaseUrl: 'http://127.0.0.1',
      signingSecret: 's',
    });
    await expect(
      storage.writeObject('meal-images', '../../etc/passwd', new Uint8Array([1])),
    ).rejects.toThrow();
  });
});
