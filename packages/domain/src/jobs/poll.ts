/**
 * Suggested client polling delay for a job (blueprint §13): starts at 2 s and backs off to 10 s.
 * Returns null for terminal jobs so clients stop polling.
 */
export function pollDelayMs(
  status: string,
  createdAt: Date,
  now: Date = new Date(),
): number | null {
  if (status === 'completed' || status === 'failed' || status === 'cancelled') return null;
  const ageSeconds = Math.max(0, (now.getTime() - createdAt.getTime()) / 1000);
  if (ageSeconds < 10) return 2000;
  if (ageSeconds < 30) return 4000;
  if (ageSeconds < 60) return 8000;
  return 10000;
}
