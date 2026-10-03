import type { Queryable } from '../db/user-transaction.js';

export interface EntitlementEventInput {
  entitlementKey: string;
  provider: 'revenuecat';
  providerStatus: string;
  isActive: boolean;
  /** ISO timestamp, or null for no expiry. */
  expiresAt: string | null;
  /** The event's own effective time (ISO) — never "now()" — used to order reconciliation. */
  eventAt: string;
}

/**
 * Upserts `app.entitlements`, applying an event only when it is at least as new as whatever is
 * already stored (`last_verified_at`). This is the blueprint's "reconcile, don't trust arrival
 * order" requirement (§13): a duplicate or out-of-order webhook delivery, or a stale restore/sync
 * response, can never roll a user's entitlement backward past a state a newer event already
 * established. The `where` clause on the conflict branch is what makes this safe under concurrent
 * processing — Postgres evaluates it per-row inside the single upsert statement.
 */
export async function reconcileEntitlement(
  client: Queryable,
  userId: string,
  event: EntitlementEventInput,
): Promise<void> {
  await client.query(
    `insert into app.entitlements
       (user_id, entitlement_key, provider, provider_status, is_active, expires_at, last_verified_at)
     values ($1, $2, $3, $4, $5, $6, $7)
     on conflict (user_id, entitlement_key) do update set
       provider = excluded.provider,
       provider_status = excluded.provider_status,
       is_active = excluded.is_active,
       expires_at = excluded.expires_at,
       last_verified_at = excluded.last_verified_at
     where app.entitlements.last_verified_at <= excluded.last_verified_at`,
    [
      userId,
      event.entitlementKey,
      event.provider,
      event.providerStatus,
      event.isActive,
      event.expiresAt,
      event.eventAt,
    ],
  );
}
