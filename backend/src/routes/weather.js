'use strict';

const { fetchWeather } = require('../services/openmeteo');
const cache = require('../services/cache');
const cities = require('../data/cities.json');

// Build a lookup map for fast city-by-id resolution
const cityMap = Object.fromEntries(cities.map((c) => [c.id, c]));

/** Validate and coerce a coordinate string to a float */
function parseCoord(value, name) {
  const n = parseFloat(value);
  if (isNaN(n)) {
    const err = new Error(`Invalid ${name}: "${value}"`);
    err.statusCode = 400;
    throw err;
  }
  return n;
}

/**
 * GET /api/weather
 *
 * Query parameters (one of):
 *   ?city={id}           — city id from cities.json  (e.g. "ashgabat")
 *   ?lat={lat}&lon={lon} — explicit coordinates
 *
 * Caches responses in-memory for CACHE_TTL_MINUTES (default 45 min).
 */
async function weatherRoute(app) {
  app.get(
    '/weather',
    {
      schema: {
        querystring: {
          type: 'object',
          properties: {
            city: { type: 'string' },
            lat: { type: 'string' },
            lon: { type: 'string' },
          },
        },
      },
    },
    async (request, reply) => {
      const { city: cityId, lat: latStr, lon: lonStr } = request.query;

      let lat, lon, cityMeta;

      // ── Resolve coordinates ──────────────────────────────────────────────
      if (cityId) {
        cityMeta = cityMap[cityId.toLowerCase()];
        if (!cityMeta) {
          const available = cities.map((c) => c.id).join(', ');
          return reply.status(400).send({
            error: `Unknown city id "${cityId}". Available: ${available}`,
            statusCode: 400,
          });
        }
        lat = cityMeta.lat;
        lon = cityMeta.lon;
      } else if (latStr && lonStr) {
        lat = parseCoord(latStr, 'lat');
        lon = parseCoord(lonStr, 'lon');
      } else {
        return reply.status(400).send({
          error: 'Provide either ?city={id} or ?lat={lat}&lon={lon}',
          statusCode: 400,
        });
      }

      // ── Cache lookup ─────────────────────────────────────────────────────
      const cacheKey = cache.buildKey(lat, lon);
      const cached = cache.get(cacheKey);
      if (cached) {
        app.log.debug({ cacheKey }, 'Cache hit');
        return reply
          .header('X-Cache', 'HIT')
          .header('X-Cache-Key', cacheKey)
          .send(cached);
      }

      // ── Fetch from Open-Meteo ────────────────────────────────────────────
      app.log.info({ lat, lon, cacheKey }, 'Cache miss — fetching Open-Meteo');
      const weatherData = await fetchWeather(lat, lon);

      // Attach city metadata when resolved by city id
      const payload = {
        city: cityMeta
          ? { id: cityMeta.id, name: cityMeta.name }
          : { id: null, name: null, lat, lon },
        ...weatherData,
      };

      cache.set(cacheKey, payload);

      return reply
        .header('X-Cache', 'MISS')
        .header('X-Cache-Key', cacheKey)
        .send(payload);
    },
  );

  // ── List all available cities ────────────────────────────────────────────
  app.get('/cities', async (_request, reply) => {
    return reply.send(cities);
  });

  // ── Cache stats (debug endpoint) ─────────────────────────────────────────
  app.get('/cache/stats', async (_request, reply) => {
    return reply.send(cache.stats());
  });
}

module.exports = weatherRoute;
