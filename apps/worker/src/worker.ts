import { pino } from 'pino';
import { ConfigError, loadConfig } from './config.js';
import { startWorker } from './runtime.js';

async function main(): Promise<void> {
  let config;
  try {
    config = loadConfig();
  } catch (error) {
    console.error(error instanceof ConfigError ? error.message : error);
    process.exit(1);
  }
  const log = pino({ level: config.logLevel, base: { service: 'worker' } });
  const runtime = await startWorker(config, log);

  const shutdown = async (signal: string) => {
    log.info({ signal }, 'shutting down');
    await runtime.stop();
    process.exit(0);
  };
  process.once('SIGTERM', () => void shutdown('SIGTERM'));
  process.once('SIGINT', () => void shutdown('SIGINT'));
}

main().catch((error: unknown) => {
  console.error('worker failed to start', error);
  process.exit(1);
});
