import type { Queryable } from '../db/user-transaction.js';

/** Matches `app.usage_reservations.feature`'s check constraint (migration 20261001000700). */
export type UsageFeature =
  'meal_scan' | 'coach_reply' | 'diet_plan' | 'workout_plan' | 'plan_regeneration';

export interface FeatureQuota {
  free: number;
  premium: number;
}

/**
 * Server-controlled, entitlement-aware free/premium limits (blueprint §13). Values are supplied by
 * the caller (apps/api/src/config.ts), not hardcoded here, so they stay env-overridable "server-
 * controlled configuration" rather than a client-visible constant — but the defaults are exactly the
 * blueprint's own proposed engineering numbers, same provisional-number caveat as the M4/M9 constants
 * these replace.
 */
export const DEFAULT_FEATURE_QUOTAS: Record<UsageFeature, FeatureQuota> = {
  meal_scan: { free: 3, premium: 20 },
  coach_reply: { free: 5, premium: 20 },
  diet_plan: { free: 1, premium: 7 },
  workout_plan: { free: 1, premium: 7 },
  plan_regeneration: { free: 1, premium: 7 },
};

/**
 * True only when the user has a currently-active `premium` entitlement row — read from
 * `app.entitlements`, the server-side table a webhook or restore/sync populates. This is the only
 * place "is this user premium" is decided; nothing here ever reads a client-submitted field.
 */
export async function isPremiumUser(client: Queryable, userId: string): Promise<boolean> {
  const { rowCount } = await client.query(
    `select 1 from app.entitlements
       where user_id = $1 and entitlement_key = 'premium' and is_active
         and (expires_at is null or expires_at > now())
       limit 1`,
    [userId],
  );
  return (rowCount ?? 0) > 0;
}

/** The caller's configured free or premium limit for `feature`, based on their current entitlement. */
export async function dailyQuotaFor(
  client: Queryable,
  userId: string,
  quota: FeatureQuota,
): Promise<number> {
  return (await isPremiumUser(client, userId)) ? quota.premium : quota.free;
}
