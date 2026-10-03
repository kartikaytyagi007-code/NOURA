import type { BillingProvider, NormalizedWebhookEvent } from '@noura/billing';
import {
  AppError,
  isUuid,
  isPremiumUser,
  reconcileEntitlement,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';
import type { Database } from '../../plugins/db.js';

type Schemas = components['schemas'];

export interface FeatureQuotaConfig {
  free: number;
  premium: number;
}

/** Built from `ApiConfig.quotas` by routes.ts, so this module stays free of a config import. */
export function usageFeatureList(quotas: {
  mealScan: FeatureQuotaConfig;
  coachReply: FeatureQuotaConfig;
}): { feature: Schemas['FeatureUsage']['feature']; quota: FeatureQuotaConfig }[] {
  return [
    { feature: 'meal_scan', quota: quotas.mealScan },
    { feature: 'coach_reply', quota: quotas.coachReply },
  ];
}

interface EntitlementRow {
  entitlement_key: string;
  provider_status: string;
  is_active: boolean;
  expires_at: Date | null;
  last_verified_at: Date;
}

export async function getEntitlements(
  client: Queryable,
  userId: string,
): Promise<Schemas['Entitlements']> {
  const { rows } = await client.query<EntitlementRow>(
    `select entitlement_key, provider_status, is_active, expires_at, last_verified_at
       from app.entitlements where user_id = $1 order by entitlement_key`,
    [userId],
  );
  return {
    entitlements: rows.map((r) => ({
      key: r.entitlement_key,
      is_active: r.is_active,
      provider_status: r.provider_status,
      expires_at: r.expires_at ? r.expires_at.toISOString() : null,
      last_verified_at: r.last_verified_at.toISOString(),
    })),
  };
}

export async function getUsage(
  client: Queryable,
  userId: string,
  features: { feature: Schemas['FeatureUsage']['feature']; quota: FeatureQuotaConfig }[],
): Promise<Schemas['Usage']> {
  const timezoneRow = (
    await client.query<{ timezone: string | null }>(
      'select timezone from app.profiles where user_id = $1',
      [userId],
    )
  ).rows[0];
  const timezone = timezoneRow?.timezone ?? 'UTC';
  const premium = await isPremiumUser(client, userId);
  const today = new Date().toISOString().slice(0, 10);

  const out: Schemas['FeatureUsage'][] = [];
  for (const { feature, quota } of features) {
    const counts = (
      await client.query<{ reserved: string; consumed: string }>(
        `select
           count(*) filter (where state = 'reserved') as reserved,
           count(*) filter (where state in ('reserved', 'consumed')) as consumed
         from app.usage_reservations
         where user_id = $1 and feature = $2 and quota_period = $3`,
        [userId, feature, today],
      )
    ).rows[0]!;
    out.push({
      feature,
      period: today,
      limit: premium ? quota.premium : quota.free,
      used: Number(counts.consumed),
      reserved: Number(counts.reserved),
    });
  }
  return { timezone, features: out };
}

/**
 * Restore-purchases / manual sync (blueprint §13: "restore → server sync → confirmed entitlement").
 * Asks the provider directly, never the device, and reconciles each returned entitlement the same
 * way a webhook event does.
 */
export async function syncBilling(
  client: Queryable,
  userId: string,
  provider: BillingProvider,
): Promise<Schemas['Entitlements']> {
  const fetched = await provider.fetchSubscriberEntitlements(userId);
  for (const entitlement of fetched) {
    await reconcileEntitlement(client, userId, {
      entitlementKey: entitlement.entitlementKey,
      provider: 'revenuecat',
      providerStatus: entitlement.providerStatus,
      isActive: entitlement.isActive,
      expiresAt: entitlement.expiresAt,
      eventAt: new Date().toISOString(),
    });
  }
  return getEntitlements(client, userId);
}

/**
 * Persists then processes a RevenueCat webhook event (blueprint §13). Dedupes on
 * (provider, provider_event_id) — a replayed event is a no-op after the first delivery, never
 * reprocessed. Never trusts arrival order: `reconcileEntitlement` only applies an event at least as
 * new as whatever is already stored.
 */
export async function receiveWebhook(
  db: Database,
  provider: BillingProvider,
  body: unknown,
): Promise<{ received: boolean }> {
  let event: NormalizedWebhookEvent;
  try {
    event = provider.parseWebhookEvent(body);
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError('VALIDATION_ERROR', 'Unrecognized webhook payload.');
  }

  await db.system(async (client) => {
    const inserted = await client.query<{ id: string }>(
      `insert into app.billing_events
         (provider, provider_event_id, event_type, environment, app_user_id, minimal_payload, status)
       values ('revenuecat', $1, $2, $3, $4, $5::jsonb, 'received')
       on conflict (provider, provider_event_id) do nothing
       returning id`,
      [
        event.providerEventId,
        event.rawType,
        event.environment,
        isUuid(event.appUserId) ? event.appUserId : null,
        // Minimal, non-identifying payload: the event's own shape, not the full provider body
        // (never the raw request, which may carry more than this adapter has normalized).
        JSON.stringify({
          entitlement_key: event.entitlement.entitlementKey,
          is_active: event.entitlement.isActive,
          provider_status: event.entitlement.providerStatus,
        }),
      ],
    );
    const billingEventId = inserted.rows[0]?.id;
    if (!billingEventId) {
      // Already seen this provider_event_id: dedupe, do not reprocess.
      return;
    }

    if (!isUuid(event.appUserId)) {
      await client.query(
        `update app.billing_events set status = 'ignored', processed_at = now() where id = $1`,
        [billingEventId],
      );
      return;
    }

    await withUserReconcile(db, event.appUserId, event);
    await client.query(
      `update app.billing_events set status = 'processed', processed_at = now() where id = $1`,
      [billingEventId],
    );
  });

  return { received: true };
}

async function withUserReconcile(
  db: Database,
  userId: string,
  event: NormalizedWebhookEvent,
): Promise<void> {
  await db.forUser(userId, (client) =>
    reconcileEntitlement(client, userId, {
      entitlementKey: event.entitlement.entitlementKey,
      provider: 'revenuecat',
      providerStatus: event.entitlement.providerStatus,
      isActive: event.entitlement.isActive,
      expiresAt: event.entitlement.expiresAt,
      eventAt: event.eventAt,
    }),
  );
}
