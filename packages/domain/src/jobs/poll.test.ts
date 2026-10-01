import { describe, expect, it } from 'vitest';
import { pollDelayMs } from './poll.js';

describe('pollDelayMs', () => {
  const created = new Date('2026-10-01T00:00:00Z');
  const at = (s: number) => new Date(created.getTime() + s * 1000);

  it('starts at 2 s and backs off to a 10 s ceiling', () => {
    expect(pollDelayMs('queued', created, at(0))).toBe(2000);
    expect(pollDelayMs('running', created, at(15))).toBe(4000);
    expect(pollDelayMs('running', created, at(45))).toBe(8000);
    expect(pollDelayMs('running', created, at(3600))).toBe(10000);
  });

  it('stops polling for terminal states', () => {
    for (const s of ['completed', 'failed', 'cancelled'])
      expect(pollDelayMs(s, created, at(1))).toBeNull();
  });
});
