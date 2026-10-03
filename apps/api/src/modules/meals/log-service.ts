import { randomUUID } from 'node:crypto';
import {
  AppError,
  computeMealBalance,
  isUuid,
  loadCatalogFoods,
  resolveConfirmedItems,
  sumAnalyzedNutrition,
  type AnalyzedItemOut,
  type Queryable,
} from '@noura/domain';
import type { components } from '@noura/contracts';
import { MEAL_BALANCE_POLICY_VERSION } from '@noura/domain';

type Schemas = components['schemas'];

const conflict = (what: string) =>
  new AppError(
    'REVISION_CONFLICT',
    `Your ${what} changed since you loaded it. Reload and try again.`,
  );

/** Meal-local date: captured once from consumed_at + the device's timezone, never recomputed later. */
function localDateOf(consumedAt: string, timezone: string): string {
  try {
    return new Intl.DateTimeFormat('en-CA', { timeZone: timezone }).format(new Date(consumedAt));
  } catch {
    throw new AppError('VALIDATION_ERROR', 'Unknown timezone.', {
      fieldErrors: [
        { field: 'body.timezone', code: 'invalid', message: 'not a recognized IANA timezone' },
      ],
    });
  }
}

interface LogItemRow {
  id: string;
  food_id: string | null;
  recipe_id: string | null;
  label: string;
  grams: string | null;
  grams_min: string | null;
  grams_max: string | null;
  nutrients: Schemas['Nutrients'] | null;
  uncertainty: Schemas['Uncertainty'] | null;
}

interface LogRow {
  id: string;
  client_id: string;
  consumed_at: Date;
  local_date: Date;
  timezone: string;
  slot: Schemas['MealSlot'];
  scan_id: string | null;
  plan_meal_id: string | null;
  totals_snapshot: Schemas['NutrientTotals'];
  meal_balance_score: number | null;
  score_policy_version: string | null;
  revision: number;
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

async function loadItems(
  client: Queryable,
  userId: string,
  logId: string,
): Promise<Schemas['AnalyzedItem'][]> {
  const { rows } = await client.query<LogItemRow>(
    `select id, food_id, recipe_id, label, grams::text as grams, grams_min::text as grams_min,
            grams_max::text as grams_max, nutrients, uncertainty
       from app.meal_log_items where meal_log_id = $1 and user_id = $2 order by id`,
    [logId, userId],
  );
  return rows.map((r) => ({
    item_id: r.id,
    label: r.label,
    food_id: r.food_id,
    recipe_id: r.recipe_id,
    source: null,
    grams: r.grams === null ? null : Number(r.grams),
    grams_range:
      r.grams_min !== null && r.grams_max !== null
        ? { min: Number(r.grams_min), max: Number(r.grams_max) }
        : null,
    nutrients: r.nutrients,
    uncertainty: r.uncertainty,
  }));
}

function toMealBalance(
  score: number | null,
  policyVersion: string | null,
): Schemas['MealLog']['meal_balance'] {
  if (policyVersion === null) return null;
  return {
    score,
    policy_version: policyVersion,
    components: [],
    missing_data_message:
      score === null ? "Some items don't have nutrition information yet." : null,
  };
}

async function toMealLog(
  client: Queryable,
  userId: string,
  row: LogRow,
): Promise<Schemas['MealLog']> {
  const items = await loadItems(client, userId, row.id);
  return {
    id: row.id,
    client_id: row.client_id,
    consumed_at: row.consumed_at.toISOString(),
    local_date: isoDate(row.local_date),
    slot: row.slot,
    scan_id: row.scan_id,
    plan_meal_id: row.plan_meal_id,
    items,
    totals: row.totals_snapshot,
    meal_balance: toMealBalance(row.meal_balance_score, row.score_policy_version),
    revision: row.revision,
  };
}

async function resolveItemsForWrite(
  client: Queryable,
  items: Schemas['ConfirmedItemInput'][],
): Promise<AnalyzedItemOut[]> {
  const catalogFoods = await loadCatalogFoods(client);
  return resolveConfirmedItems(
    items.map((i) => ({
      temporary_id: i.temporary_id,
      food_id: i.food_id,
      recipe_id: i.recipe_id,
      label: i.label,
      grams: i.grams,
      serving: i.serving,
    })),
    catalogFoods,
    () => randomUUID(),
  );
}

export async function createMealLog(
  client: Queryable,
  userId: string,
  body: Schemas['CreateMealLogRequest'],
): Promise<Schemas['MealLog']> {
  const localDate = localDateOf(body.consumed_at, body.timezone);
  const resolved = await resolveItemsForWrite(client, body.items);
  const totals = sumAnalyzedNutrition(resolved);
  const balance = computeMealBalance(resolved, totals);

  const existing = (
    await client.query<{ id: string }>(
      'select id from app.meal_logs where user_id = $1 and client_id = $2',
      [userId, body.client_id],
    )
  ).rows[0];
  if (existing) {
    const row = (
      await client.query<LogRow>(
        `select id, client_id, consumed_at, local_date, timezone, slot, scan_id, plan_meal_id, totals_snapshot,
                meal_balance_score, score_policy_version, revision
           from app.meal_logs where id = $1 and user_id = $2`,
        [existing.id, userId],
      )
    ).rows[0]!;
    return toMealLog(client, userId, row);
  }

  const inserted = (
    await client.query<LogRow>(
      `insert into app.meal_logs
         (user_id, client_id, consumed_at, local_date, timezone, slot, scan_id, plan_meal_id,
          totals_snapshot, meal_balance_score, score_policy_version)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9::jsonb, $10, $11)
       returning id, client_id, consumed_at, local_date, timezone, slot, scan_id, plan_meal_id, totals_snapshot,
                 meal_balance_score, score_policy_version, revision`,
      [
        userId,
        body.client_id,
        body.consumed_at,
        localDate,
        body.timezone,
        body.slot,
        body.scan_id ?? null,
        body.plan_meal_id ?? null,
        JSON.stringify(totals),
        balance.score,
        MEAL_BALANCE_POLICY_VERSION,
      ],
    )
  ).rows[0]!;

  for (const item of resolved) {
    await client.query(
      `insert into app.meal_log_items
         (user_id, meal_log_id, food_id, recipe_id, label, grams, nutrients, provenance, uncertainty)
       values ($1, $2, $3, $4, $5, $6, $7::jsonb, $8::jsonb, $9)`,
      [
        userId,
        inserted.id,
        item.food_id,
        item.recipe_id,
        item.label,
        item.grams,
        item.nutrients ? JSON.stringify(item.nutrients) : null,
        JSON.stringify({ matched: !!item.food_id }),
        item.uncertainty,
      ],
    );
  }

  return toMealLog(client, userId, inserted);
}

export async function listMealLogs(
  client: Queryable,
  userId: string,
  date: string,
): Promise<Schemas['MealDiary']> {
  const { rows } = await client.query<LogRow>(
    `select id, client_id, consumed_at, local_date, timezone, slot, scan_id, plan_meal_id, totals_snapshot,
            meal_balance_score, score_policy_version, revision
       from app.meal_logs where user_id = $1 and local_date = $2 order by consumed_at`,
    [userId, date],
  );
  const logs = await Promise.all(rows.map((row) => toMealLog(client, userId, row)));
  const totalsSnapshot =
    logs.length === 0
      ? sumAnalyzedNutrition([])
      : sumAnalyzedNutrition(
          logs.flatMap((l) =>
            l.items.map((i) => ({
              item_id: i.item_id,
              label: i.label,
              food_id: i.food_id,
              recipe_id: i.recipe_id,
              grams: i.grams,
              grams_range: i.grams_range,
              nutrients: i.nutrients,
              uncertainty: i.uncertainty,
            })),
          ),
        );
  return { date, logs, totals: totalsSnapshot };
}

async function loadOwnedLog(client: Queryable, userId: string, id: string): Promise<LogRow> {
  if (!isUuid(id)) throw new AppError('NOT_FOUND', 'Resource not found.');
  const row = (
    await client.query<LogRow>(
      `select id, client_id, consumed_at, local_date, timezone, slot, scan_id, plan_meal_id, totals_snapshot,
              meal_balance_score, score_policy_version, revision
         from app.meal_logs where id = $1 and user_id = $2`,
      [id, userId],
    )
  ).rows[0];
  if (!row) throw new AppError('NOT_FOUND', 'Resource not found.');
  return row;
}

export async function patchMealLog(
  client: Queryable,
  userId: string,
  id: string,
  body: Schemas['PatchMealLogRequest'],
): Promise<Schemas['MealLog']> {
  const log = await loadOwnedLog(client, userId, id);
  if (log.revision !== body.expected_revision) throw conflict('meal log');

  const consumedAt = body.consumed_at ?? log.consumed_at.toISOString();
  const slot = body.slot ?? log.slot;

  if (body.items) {
    const resolved = await resolveItemsForWrite(client, body.items);
    const totals = sumAnalyzedNutrition(resolved);
    const balance = computeMealBalance(resolved, totals);
    await client.query('delete from app.meal_log_items where meal_log_id = $1 and user_id = $2', [
      log.id,
      userId,
    ]);
    for (const item of resolved) {
      await client.query(
        `insert into app.meal_log_items
           (user_id, meal_log_id, food_id, recipe_id, label, grams, nutrients, provenance, uncertainty)
         values ($1, $2, $3, $4, $5, $6, $7::jsonb, $8::jsonb, $9)`,
        [
          userId,
          log.id,
          item.food_id,
          item.recipe_id,
          item.label,
          item.grams,
          item.nutrients ? JSON.stringify(item.nutrients) : null,
          JSON.stringify({ matched: !!item.food_id }),
          item.uncertainty,
        ],
      );
    }
    const updated = (
      await client.query<{ revision: number }>(
        `update app.meal_logs
           set consumed_at = $3, local_date = $4, slot = $5, totals_snapshot = $6::jsonb,
               meal_balance_score = $7, score_policy_version = $8, revision = revision + 1
           where id = $1 and user_id = $2 and revision = $9
           returning revision`,
        [
          log.id,
          userId,
          consumedAt,
          localDateOf(consumedAt, log.timezone),
          slot,
          JSON.stringify(totals),
          balance.score,
          MEAL_BALANCE_POLICY_VERSION,
          body.expected_revision,
        ],
      )
    ).rows[0];
    if (!updated) throw conflict('meal log');
    const row = await loadOwnedLog(client, userId, log.id);
    return toMealLog(client, userId, row);
  }

  const updated = (
    await client.query<{ revision: number }>(
      `update app.meal_logs set consumed_at = $3, slot = $4, revision = revision + 1
         where id = $1 and user_id = $2 and revision = $5
         returning revision`,
      [log.id, userId, consumedAt, slot, body.expected_revision],
    )
  ).rows[0];
  if (!updated) throw conflict('meal log');
  const row = await loadOwnedLog(client, userId, log.id);
  return toMealLog(client, userId, row);
}

export async function deleteMealLog(
  client: Queryable,
  userId: string,
  id: string,
  expectedRevision: number,
): Promise<Schemas['Deleted']> {
  const log = await loadOwnedLog(client, userId, id);
  if (log.revision !== expectedRevision) throw conflict('meal log');
  // meal_log_items cascade on delete (FK `on delete cascade`).
  const deleted = await client.query(
    'delete from app.meal_logs where id = $1 and user_id = $2 and revision = $3',
    [id, userId, expectedRevision],
  );
  if (deleted.rowCount === 0) throw conflict('meal log');
  return { id, deleted: true };
}
