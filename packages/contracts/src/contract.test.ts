import { Ajv } from 'ajv';
import addFormatsModule from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import {
  buildRouteSchemas,
  listOperations,
  loadOpenApiDocument,
  toJsonSchema,
  type JsonObject,
} from './index.js';

// ajv-formats ships CJS; normalize the default export across module systems.
const addFormats = ((addFormatsModule as unknown as { default?: unknown }).default ??
  addFormatsModule) as (ajv: Ajv) => Ajv;

const ops = listOperations();
const MUTATIONS = new Set(['post', 'put', 'patch', 'delete']);

describe('OpenAPI contract structure', () => {
  it('has unique operationIds with milestone and status annotations', () => {
    const ids = ops.map((o) => o.operationId);
    expect(new Set(ids).size).toBe(ids.length);
    for (const op of ops) {
      expect(op.milestone, op.operationId).toMatch(/^M(10|[1-9])$/);
      expect(['implemented', 'planned'], op.operationId).toContain(op.status);
    }
  });

  it('implements exactly the M1-M8 operations, each tagged with its milestone', () => {
    const implemented = Object.fromEntries(
      ops.filter((o) => o.status === 'implemented').map((o) => [o.operationId, o.milestone]),
    );
    expect(implemented).toEqual({
      getLiveness: 'M1',
      getReadiness: 'M1',
      getMe: 'M1',
      getJob: 'M1',
      patchMe: 'M2',
      putPreferences: 'M2',
      putTrainingPreferences: 'M2',
      completeOnboarding: 'M2',
      getTargets: 'M2',
      generateDietPlan: 'M3',
      getCurrentDietPlan: 'M3',
      getSwapOptions: 'M3',
      replacePlanMeal: 'M3',
      createUploadSlot: 'M4',
      completeUpload: 'M4',
      getMediaDownload: 'M4',
      deleteMedia: 'M4',
      createMealScan: 'M4',
      getMealScan: 'M4',
      confirmMealScanItems: 'M4',
      createMealLog: 'M4',
      listMealLogs: 'M4',
      patchMealLog: 'M4',
      deleteMealLog: 'M4',
      createPlateFixes: 'M5',
      getHome: 'M6',
      getNextMeal: 'M6',
      nextMealAction: 'M6',
      getInsights: 'M6',
      generateWorkoutPlan: 'M7',
      getCurrentWorkoutPlan: 'M7',
      getExerciseSubstitutions: 'M7',
      createWorkoutLog: 'M7',
      putWorkoutSets: 'M7',
      patchWorkoutLog: 'M7',
      listWeightLogs: 'M8',
      createWeightLog: 'M8',
      deleteWeightLog: 'M8',
      listProgressPhotos: 'M8',
      createProgressPhoto: 'M8',
      deleteProgressPhoto: 'M8',
      getProgress: 'M8',
    });
  });

  it('covers exactly the blueprint §11 route inventory', () => {
    const inventory = [
      'GET /me',
      'PATCH /me',
      'PUT /me/preferences',
      'PUT /me/training-preferences',
      'POST /onboarding/complete',
      'GET /targets',
      'GET /home',
      'POST /media/upload-slots',
      'POST /media/{id}/complete',
      'GET /media/{id}/download',
      'DELETE /media/{id}',
      'POST /meal-scans',
      'GET /meal-scans/{id}',
      'PUT /meal-scans/{id}/confirmed-items',
      'POST /meal-scans/{id}/plate-fixes',
      'GET /foods',
      'GET /recipes/{id}',
      'POST /meal-logs',
      'GET /meal-logs',
      'PATCH /meal-logs/{id}',
      'DELETE /meal-logs/{id}',
      'POST /diet-plans/generate',
      'GET /diet-plans/current',
      'POST /diet-plan-meals/{id}/swap-options',
      'PUT /diet-plan-meals/{id}',
      'GET /recommendations/next-meal',
      'POST /recommendations/next-meal/actions',
      'GET /insights',
      'POST /workout-plans/generate',
      'GET /workout-plans/current',
      'GET /exercises/{id}/substitutions',
      'POST /workout-logs',
      'PUT /workout-logs/{id}/sets',
      'PATCH /workout-logs/{id}',
      'GET /weight-logs',
      'POST /weight-logs',
      'DELETE /weight-logs/{id}',
      'GET /progress-photos',
      'POST /progress-photos',
      'DELETE /progress-photos/{id}',
      'GET /progress',
      'POST /coach/threads',
      'GET /coach/threads/{id}/messages',
      'POST /coach/threads/{id}/messages',
      'POST /action-proposals/{id}/apply',
      'POST /action-proposals/{id}/cancel',
      'GET /jobs/{id}',
      'GET /entitlements',
      'GET /usage',
      'POST /billing/sync',
      'POST /webhooks/revenuecat',
      'POST /account/export',
      'GET /account/export/{id}',
      'DELETE /account',
    ];
    const actual = ops
      .filter((o) => o.path.startsWith('/v1/'))
      .map((o) => `${o.method.toUpperCase()} ${o.path.slice(3)}`)
      .sort();
    expect(actual).toEqual([...inventory].sort());
  });

  it('requires bearer auth everywhere except health probes and the provider webhook', () => {
    const open = ops
      .filter((o) => !o.requiresAuth)
      .map((o) => o.operationId)
      .sort();
    expect(open).toEqual(['getLiveness', 'getReadiness', 'receiveRevenueCatWebhook']);
    for (const op of ops.filter((o) => o.requiresAuth)) {
      expect(Object.keys(op.operation.responses as JsonObject), op.operationId).toContain('401');
    }
  });

  it('requires an Idempotency-Key on every user mutation', () => {
    for (const op of ops.filter((o) => MUTATIONS.has(o.method) && o.requiresAuth)) {
      const refs = JSON.stringify(op.operation.parameters ?? []);
      // swap-options is a read-only preview modelled as POST because it carries a revision body.
      if (op.operationId === 'getSwapOptions') continue;
      expect(refs, op.operationId).toContain('#/components/parameters/IdempotencyKey');
    }
  });

  it('forbids unrecognized fields in every NOURA-owned request body', () => {
    for (const op of ops.filter(
      (o) => o.operation.requestBody && o.operationId !== 'receiveRevenueCatWebhook',
    )) {
      const body = buildRouteSchemas(op).body as JsonObject;
      expect(body.additionalProperties, op.operationId).toBe(false);
    }
  });

  it('returns 404 for every owner resource lookup by id', () => {
    for (const op of ops.filter((o) => o.path.includes('{id}'))) {
      expect(Object.keys(op.operation.responses as JsonObject), op.operationId).toContain('404');
    }
  });

  it('caps pagination at 100', () => {
    const doc = loadOpenApiDocument() as {
      components: { parameters: { Limit: { schema: { maximum: number } } } };
    };
    expect(doc.components.parameters.Limit.schema.maximum).toBe(100);
  });

  it('uses the standard success envelope for every 2xx JSON response of /v1 operations', () => {
    for (const op of ops.filter((o) => o.path.startsWith('/v1/'))) {
      const schemas = buildRouteSchemas(op).response;
      for (const [status, schema] of Object.entries(schemas)) {
        if (!status.startsWith('2')) continue;
        const s = schema as JsonObject;
        expect(s.required, `${op.operationId} ${status}`).toEqual(['data', 'meta']);
      }
    }
  });

  it('uses the standard error envelope for every 4xx/5xx response', () => {
    for (const op of ops.filter((o) => o.path.startsWith('/v1/'))) {
      for (const [status, schema] of Object.entries(buildRouteSchemas(op).response)) {
        if (Number(status) < 400) continue;
        expect((schema as JsonObject).required, `${op.operationId} ${status}`).toEqual([
          'error',
          'meta',
        ]);
      }
    }
  });
});

describe('runtime schema conversion', () => {
  it('compiles every request and response schema with Ajv in strict mode', () => {
    const ajv = new Ajv({ strict: true, allErrors: true });
    addFormats(ajv);
    for (const op of ops) {
      const s = buildRouteSchemas(op);
      for (const [part, schema] of Object.entries({
        params: s.params,
        querystring: s.querystring,
        headers: s.headers,
        body: s.body,
      })) {
        if (schema)
          expect(() => ajv.compile(schema as object), `${op.operationId} ${part}`).not.toThrow();
      }
      for (const [status, schema] of Object.entries(s.response)) {
        expect(() => ajv.compile(schema as object), `${op.operationId} ${status}`).not.toThrow();
      }
    }
  });

  it('treats nullable refs as an explicit union with null', () => {
    const ajv = new Ajv({ strict: true });
    addFormats(ajv);
    const doc = loadOpenApiDocument();
    const validate = ajv.compile(
      toJsonSchema({ $ref: '#/components/schemas/Onboarding' }, doc) as object,
    );
    expect(validate({ status: 'not_started', step: null })).toBe(true);
    expect(validate({ status: 'in_progress', step: 'basics' })).toBe(true);
    expect(validate({ status: 'in_progress', step: 'bogus' })).toBe(false);
  });

  it('keeps unknown nutrient values nullable rather than defaulting to zero', () => {
    const ajv = new Ajv({ strict: true });
    const validate = ajv.compile(
      toJsonSchema({ $ref: '#/components/schemas/Nutrients' }) as object,
    );
    expect(
      validate({
        energy_kcal: null,
        protein_g: null,
        carbohydrate_g: null,
        fat_g: null,
        fibre_g: null,
      }),
    ).toBe(true);
    expect(validate({ energy_kcal: 100 })).toBe(false);
  });
});
