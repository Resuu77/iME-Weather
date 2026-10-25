'use strict';

const NodeCache = require('node-cache');

const TTL_MINUTES = parseInt(process.env.CACHE_TTL_MINUTES || '45', 10);
const TTL_SECONDS = TTL_MINUTES * 60;

/**
 * Singleton in-memory cache with TTL-based expiry.
 *
 * Key format  : `lat_lon` (e.g. "37.96_58.33")
 * TTL         : CACHE_TTL_MINUTES env var (default 45 min)
 * checkperiod : prune expired entries every 10 minutes
 */
const cache = new NodeCache({
  stdTTL: TTL_SECONDS,
  checkperiod: 600, // 10 minutes
  useClones: false, // store references for performance
});

/**
 * Build a normalised cache key from lat/lon coordinates.
 * Rounds to 2 decimal places to group nearby coordinates.
 *
 * @param {number} lat
 * @param {number} lon
 * @returns {string}
 */
function buildKey(lat, lon) {
  return `${parseFloat(lat).toFixed(2)}_${parseFloat(lon).toFixed(2)}`;
}

/**
 * Retrieve a cached weather response.
 * @param {string} key
 * @returns {object|undefined}
 */
function get(key) {
  return cache.get(key);
}

/**
 * Store a weather response in the cache.
 * @param {string} key
 * @param {object} value
 */
function set(key, value) {
  cache.set(key, value);
}

/**
 * Return cache statistics (hits, misses, keys).
 * @returns {object}
 */
function stats() {
  return {
    ...cache.getStats(),
    keys: cache.keys().length,
    ttlMinutes: TTL_MINUTES,
  };
}

module.exports = { buildKey, get, set, stats };
