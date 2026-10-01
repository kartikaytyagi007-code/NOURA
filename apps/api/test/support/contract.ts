import { buildRouteSchemas, getOperation } from '@noura/contracts';
import { Ajv, type ValidateFunction } from 'ajv';
import addFormatsModule from 'ajv-formats';

const addFormats = ((addFormatsModule as unknown as { default?: unknown }).default ??
  addFormatsModule) as (ajv: Ajv) => Ajv;
const ajv = new Ajv({ strict: true, allErrors: true });
addFormats(ajv);
const cache = new Map<string, ValidateFunction>();

/**
 * Asserts a live response matches the documented OpenAPI response for (operationId, status).
 * Fails if the status is undocumented for that operation.
 */
export function expectMatchesContract(operationId: string, status: number, body: unknown): void {
  const key = `${operationId}:${status}`;
  let validate = cache.get(key);
  if (!validate) {
    const schema = buildRouteSchemas(getOperation(operationId)).response[String(status)];
    if (!schema) throw new Error(`Status ${status} is not documented for ${operationId}`);
    validate = ajv.compile(schema as object);
    cache.set(key, validate);
  }
  if (!validate(body)) {
    throw new Error(
      `${key} response violates contract: ${ajv.errorsText(validate.errors)}\n${JSON.stringify(body)}`,
    );
  }
}
