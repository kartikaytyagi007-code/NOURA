import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { parse } from 'yaml';

export type { components, operations, paths } from '../generated/ts/openapi.js';

export const openApiPath = fileURLToPath(new URL('../openapi.yaml', import.meta.url));

type Json = null | boolean | number | string | Json[] | { [key: string]: Json };
export type JsonObject = { [key: string]: Json };

export const HTTP_METHODS = ['get', 'put', 'post', 'patch', 'delete'] as const;
export type HttpMethod = (typeof HTTP_METHODS)[number];

export interface OperationInfo {
  operationId: string;
  method: HttpMethod;
  /** OpenAPI path, e.g. /v1/jobs/{id} */
  path: string;
  milestone: string;
  status: 'implemented' | 'planned';
  /** true when the operation requires bearer authentication */
  requiresAuth: boolean;
  operation: JsonObject;
  pathItem: JsonObject;
}

let cached: JsonObject | undefined;

export function loadOpenApiDocument(): JsonObject {
  cached ??= parse(readFileSync(openApiPath, 'utf8')) as JsonObject;
  return cached;
}

export function listOperations(doc: JsonObject = loadOpenApiDocument()): OperationInfo[] {
  const result: OperationInfo[] = [];
  const globalSecurity = (doc.security as Json[] | undefined) ?? [];
  for (const [path, pathItemRaw] of Object.entries(doc.paths as JsonObject)) {
    const pathItem = pathItemRaw as JsonObject;
    for (const method of HTTP_METHODS) {
      const operation = pathItem[method] as JsonObject | undefined;
      if (!operation) continue;
      const security = (operation.security as Json[] | undefined) ?? globalSecurity;
      result.push({
        operationId: operation.operationId as string,
        method,
        path,
        milestone: operation['x-noura-milestone'] as string,
        status: operation['x-noura-status'] as 'implemented' | 'planned',
        requiresAuth: security.some((s) => Object.keys(s as JsonObject).includes('bearerAuth')),
        operation,
        pathItem,
      });
    }
  }
  return result;
}

export function getOperation(
  operationId: string,
  doc: JsonObject = loadOpenApiDocument(),
): OperationInfo {
  const op = listOperations(doc).find((o) => o.operationId === operationId);
  if (!op) throw new Error(`Unknown operationId: ${operationId}`);
  return op;
}

/** Converts an OpenAPI path template to Fastify syntax: /v1/jobs/{id} -> /v1/jobs/:id */
export function toFastifyPath(path: string): string {
  return path.replace(/\{([^}]+)\}/g, ':$1');
}

const STRIPPED_KEYWORDS = new Set([
  'example',
  'examples',
  'discriminator',
  'xml',
  'externalDocs',
  'deprecated',
]);

/**
 * Resolves local $refs and converts an OpenAPI 3.0 schema fragment into plain JSON Schema accepted
 * by Ajv (strict mode) and fast-json-stringify:
 * - drops documentation-only keywords and x-* extensions;
 * - rewrites `allOf: [X] + nullable: true` into `anyOf: [X, {type: null}]`;
 * - rewrites boolean exclusiveMinimum/exclusiveMaximum into numeric form.
 */
export function toJsonSchema(
  node: Json,
  doc: JsonObject = loadOpenApiDocument(),
  seen: string[] = [],
): Json {
  if (Array.isArray(node)) return node.map((n) => toJsonSchema(n, doc, seen));
  if (node === null || typeof node !== 'object') return node;

  if (typeof node.$ref === 'string') {
    const ref = node.$ref;
    if (seen.includes(ref)) throw new Error(`Circular $ref not supported: ${ref}`);
    return toJsonSchema(resolveRef(ref, doc), doc, [...seen, ref]);
  }

  const out: JsonObject = {};
  for (const [key, value] of Object.entries(node)) {
    if (STRIPPED_KEYWORDS.has(key) || key.startsWith('x-')) continue;
    // `properties` is a map of names, not a schema: keep keys, convert values.
    if (key === 'properties' && value && typeof value === 'object' && !Array.isArray(value)) {
      out.properties = Object.fromEntries(
        Object.entries(value).map(([name, schema]) => [name, toJsonSchema(schema, doc, seen)]),
      );
      continue;
    }
    out[key] = toJsonSchema(value, doc, seen);
  }

  if (out.exclusiveMinimum === true && typeof out.minimum === 'number') {
    out.exclusiveMinimum = out.minimum;
    delete out.minimum;
  } else if (out.exclusiveMinimum === false) {
    delete out.exclusiveMinimum;
  }
  if (out.exclusiveMaximum === true && typeof out.maximum === 'number') {
    out.exclusiveMaximum = out.maximum;
    delete out.maximum;
  } else if (out.exclusiveMaximum === false) {
    delete out.exclusiveMaximum;
  }

  // OpenAPI 3.0 `nullable` does not extend into allOf branches, so `{type, allOf: [$ref],
  // nullable: true}` is rewritten to an explicit union that validators interpret unambiguously.
  if (out.nullable === true && Array.isArray(out.allOf)) {
    const { allOf, nullable: _nullable, type: _type, ...rest } = out;
    const branches = allOf as Json[];
    const inner: Json =
      branches.length === 1 && Object.keys(rest).length === 0
        ? (branches[0] as Json)
        : { ...rest, allOf: branches };
    return { anyOf: [inner, { type: 'null' }] };
  }
  if (out.nullable === false) delete out.nullable;
  return out;
}

function resolveRef(ref: string, doc: JsonObject): Json {
  if (!ref.startsWith('#/')) throw new Error(`Only local $refs are supported: ${ref}`);
  let current: Json = doc;
  for (const segment of ref.slice(2).split('/')) {
    const key = segment.replace(/~1/g, '/').replace(/~0/g, '~');
    if (
      current === null ||
      typeof current !== 'object' ||
      Array.isArray(current) ||
      !(key in current)
    ) {
      throw new Error(`Unresolvable $ref: ${ref}`);
    }
    current = current[key] as Json;
  }
  return current;
}

export interface RouteSchemas {
  params?: JsonObject;
  querystring?: JsonObject;
  headers?: JsonObject;
  body?: Json;
  response: Record<string, Json>;
}

/** Builds Fastify route schemas (request validation + response serialization) for an operation. */
export function buildRouteSchemas(
  op: OperationInfo,
  doc: JsonObject = loadOpenApiDocument(),
): RouteSchemas {
  const params = [
    ...(((op.pathItem.parameters as Json[] | undefined) ?? []) as Json[]),
    ...(((op.operation.parameters as Json[] | undefined) ?? []) as Json[]),
  ].map((p) => toJsonSchema(p, doc) as JsonObject);

  const group = (location: string): JsonObject | undefined => {
    const selected = params.filter((p) => p.in === location);
    if (selected.length === 0) return undefined;
    const properties: JsonObject = {};
    const required: string[] = [];
    for (const p of selected) {
      // HTTP header names are case-insensitive; Fastify exposes them lower-cased.
      const name = location === 'header' ? (p.name as string).toLowerCase() : (p.name as string);
      properties[name] = p.schema as Json;
      if (p.required) required.push(name);
    }
    return {
      type: 'object',
      properties,
      required,
      // Unknown query parameters are rejected; headers naturally carry extra fields.
      additionalProperties: location === 'header',
    };
  };

  const schemas: RouteSchemas = { response: {} };
  const path = group('path');
  const query = group('query');
  const headers = group('header');
  if (path) schemas.params = path;
  if (query) schemas.querystring = query;
  if (headers) schemas.headers = headers;

  const requestBody = op.operation.requestBody as JsonObject | undefined;
  if (requestBody) {
    const resolved = toJsonSchema(requestBody, doc) as JsonObject;
    const content = resolved.content as JsonObject;
    schemas.body = (content['application/json'] as JsonObject).schema as Json;
  }

  for (const [status, responseRaw] of Object.entries(op.operation.responses as JsonObject)) {
    const response = toJsonSchema(responseRaw, doc) as JsonObject;
    const content = response.content as JsonObject | undefined;
    const schema = (content?.['application/json'] as JsonObject | undefined)?.schema;
    if (schema) schemas.response[status] = schema;
  }
  return schemas;
}
