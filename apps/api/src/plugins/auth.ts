import { AppError, isUuid } from '@noura/domain';
import type { FastifyRequest } from 'fastify';
import {
  createRemoteJWKSet,
  errors as joseErrors,
  jwtVerify,
  type JWTPayload,
  type JWTVerifyGetKey,
} from 'jose';

export interface AuthContext {
  /** Verified Supabase user id (token subject). The only source of user identity. */
  userId: string;
  /** Token issue time; used later for recent-authentication checks (account deletion). */
  issuedAt: number | null;
  sessionId: string | null;
}

export interface TokenVerifierOptions {
  issuer: string;
  audience: string;
  jwksUrl: string;
  /** Test seam: a local JWKS instead of fetching jwksUrl. */
  keySet?: JWTVerifyGetKey;
}

/** Asymmetric algorithms Supabase signing keys use. Symmetric HS256 is deliberately not accepted. */
const ALGORITHMS = ['ES256', 'RS256', 'EdDSA'];

export type TokenVerifier = (token: string) => Promise<AuthContext>;

/**
 * Verifies Supabase access tokens via JWKS with issuer, audience, expiry and subject checks
 * (blueprint §2). Rejects anonymous-sign-in and non-"authenticated" role tokens.
 */
export function createTokenVerifier(options: TokenVerifierOptions): TokenVerifier {
  const keySet =
    options.keySet ??
    createRemoteJWKSet(new URL(options.jwksUrl), {
      timeoutDuration: 5_000,
      cooldownDuration: 30_000,
      cacheMaxAge: 10 * 60_000,
    });

  return async (token: string) => {
    let payload: JWTPayload;
    try {
      ({ payload } = await jwtVerify(token, keySet, {
        issuer: options.issuer,
        audience: options.audience,
        algorithms: ALGORITHMS,
        requiredClaims: ['sub', 'exp', 'iat'],
        clockTolerance: 5,
      }));
    } catch (error) {
      // JWKS fetch failures (network errors, timeouts, an invalid key set) are infrastructure
      // problems, not bad tokens: report them as retryable unavailability, never as success.
      const infrastructure =
        error instanceof joseErrors.JWKSTimeout ||
        error instanceof joseErrors.JWKSInvalid ||
        !(error instanceof joseErrors.JOSEError);
      if (infrastructure) {
        throw new AppError('PROVIDER_UNAVAILABLE', 'Authentication is temporarily unavailable.', {
          cause: error,
        });
      }
      throw new AppError('UNAUTHENTICATED', 'Authentication required.', { cause: error });
    }
    if (!isUuid(payload.sub)) throw new AppError('UNAUTHENTICATED', 'Authentication required.');
    if (payload.role !== 'authenticated' || payload.is_anonymous === true) {
      throw new AppError('UNAUTHENTICATED', 'Authentication required.');
    }
    return {
      userId: payload.sub,
      issuedAt: typeof payload.iat === 'number' ? payload.iat : null,
      sessionId: typeof payload.session_id === 'string' ? payload.session_id : null,
    };
  };
}

export function bearerToken(request: FastifyRequest): string | null {
  const header = request.headers.authorization;
  if (!header) return null;
  const match = /^Bearer\s+([A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+)$/.exec(header);
  return match?.[1] ?? null;
}

declare module 'fastify' {
  interface FastifyRequest {
    auth: AuthContext | null;
  }
}

export function requireAuth(request: FastifyRequest): AuthContext {
  if (!request.auth) throw new AppError('UNAUTHENTICATED', 'Authentication required.');
  return request.auth;
}
