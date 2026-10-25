'use strict';

const Fastify = require('fastify');
const cors = require('@fastify/cors');

const weatherRoute = require('./routes/weather');
const healthRoute = require('./routes/health');

const PORT = parseInt(process.env.PORT || '3000', 10);
const HOST = process.env.HOST || '0.0.0.0';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

/**
 * Build and configure the Fastify application instance.
 * @param {object} opts - Optional Fastify options override (used in tests).
 * @returns {import('fastify').FastifyInstance}
 */
function buildApp(opts = {}) {
  const app = Fastify({
    logger: {
      level: LOG_LEVEL,
      ...(process.env.NODE_ENV !== 'production' && {
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'SYS:standard' },
        },
      }),
    },
    ...opts,
  });

  // ── Plugins ──────────────────────────────────────────────────────────────
  app.register(cors, {
    origin: true, // reflect request origin (restrict in production if needed)
    methods: ['GET', 'OPTIONS'],
  });

  // ── Routes ───────────────────────────────────────────────────────────────
  app.register(healthRoute, { prefix: '/api' });
  app.register(weatherRoute, { prefix: '/api' });

  // ── Global error handler ─────────────────────────────────────────────────
  app.setErrorHandler((error, request, reply) => {
    app.log.error({ err: error, url: request.url }, 'Unhandled error');
    reply.status(error.statusCode || 500).send({
      error: error.message || 'Internal Server Error',
      statusCode: error.statusCode || 500,
    });
  });

  // ── 404 handler ──────────────────────────────────────────────────────────
  app.setNotFoundHandler((request, reply) => {
    reply.status(404).send({ error: 'Route not found', statusCode: 404 });
  });

  return app;
}

// ── Entry point ─────────────────────────────────────────────────────────────
async function start() {
  const app = buildApp();
  try {
    await app.listen({ port: PORT, host: HOST });
    app.log.info(`iME Weather Backend listening on ${HOST}:${PORT}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

// Only start when executed directly (not during tests)
if (require.main === module) {
  start();
}

module.exports = { buildApp };
