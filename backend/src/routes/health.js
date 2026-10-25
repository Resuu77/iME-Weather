'use strict';

/**
 * GET /api/health
 * Simple liveness probe used by Docker health check and load balancers.
 */
async function healthRoute(app) {
  app.get(
    '/health',
    {
      schema: {
        response: {
          200: {
            type: 'object',
            properties: {
              status: { type: 'string' },
              uptime: { type: 'number' },
              timestamp: { type: 'string' },
            },
          },
        },
      },
    },
    async (_request, reply) => {
      return reply.send({
        status: 'ok',
        uptime: Math.floor(process.uptime()),
        timestamp: new Date().toISOString(),
      });
    },
  );
}

module.exports = healthRoute;
