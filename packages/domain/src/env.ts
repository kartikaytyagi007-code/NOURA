export const APP_ENVS = ['development', 'test', 'staging', 'production'] as const;
export type AppEnv = (typeof APP_ENVS)[number];

/** Staging and production refuse mocks and unreviewed policy configuration. */
export function isDeployedEnv(appEnv: AppEnv): boolean {
  return appEnv === 'staging' || appEnv === 'production';
}
