'use strict';

const { buildKey, get, set, stats } = require('../src/services/cache');

describe('CacheService', () => {
  describe('buildKey()', () => {
    it('rounds to 2 decimal places', () => {
      expect(buildKey(37.9601, 58.3261)).toBe('37.96_58.33');
    });

    it('handles negative coordinates', () => {
      // JS toFixed rounding: -33.865 rounds to -33.87, 151.209 → 151.21
      expect(buildKey(-33.865, 151.209)).toBe('-33.87_151.21');
    });

    it('groups nearby coordinates to the same key', () => {
      // Both round to the same 2-decimal bucket: 37.96 / 58.33
      expect(buildKey(37.9601, 58.3261)).toBe(buildKey(37.9609, 58.3279));
    });
  });

  describe('get() / set()', () => {
    it('returns undefined for unknown key', () => {
      expect(get('nonexistent_key')).toBeUndefined();
    });

    it('stores and retrieves a value', () => {
      const key = buildKey(10.0, 20.0);
      const payload = { temperature: 25, humidity: 60 };
      set(key, payload);
      expect(get(key)).toEqual(payload);
    });
  });

  describe('stats()', () => {
    it('returns an object with keys count and ttlMinutes', () => {
      const s = stats();
      expect(typeof s.keys).toBe('number');
      expect(typeof s.ttlMinutes).toBe('number');
    });
  });
});
