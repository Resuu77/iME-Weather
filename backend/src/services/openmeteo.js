'use strict';

// node-fetch v3 is ESM-only; use dynamic import wrapper so we stay CJS
let _fetch;
async function getFetch() {
  if (!_fetch) {
    const mod = await import('node-fetch');
    _fetch = mod.default;
  }
  return _fetch;
}

const BASE_URL =
  process.env.OPEN_METEO_BASE_URL || 'https://api.open-meteo.com/v1';

/**
 * Fetch weather forecast from Open-Meteo and transform into our response shape.
 *
 * @param {number} lat   Latitude
 * @param {number} lon   Longitude
 * @returns {Promise<object>} Transformed weather data
 */
async function fetchWeather(lat, lon) {
  const fetch = await getFetch();

  const params = new URLSearchParams({
    latitude: lat,
    longitude: lon,
    current:
      'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
    hourly: 'temperature_2m,weather_code',
    daily:
      'weather_code,temperature_2m_max,temperature_2m_min,uv_index_max',
    wind_speed_unit: 'kmh',
    timezone: 'auto',
    forecast_days: '7',
  });

  const url = `${BASE_URL}/forecast?${params.toString()}`;

  const response = await fetch(url, {
    headers: { Accept: 'application/json' },
    // 10-second timeout via AbortSignal
    signal: AbortSignal.timeout(10_000),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    const err = new Error(`Open-Meteo error ${response.status}: ${body}`);
    err.statusCode = 502;
    throw err;
  }

  const raw = await response.json();
  return transform(raw);
}

/**
 * Transform raw Open-Meteo response into our clean API contract.
 *
 * @param {object} raw - Raw Open-Meteo JSON
 * @returns {object}
 */
function transform(raw) {
  const c = raw.current;
  const h = raw.hourly;
  const d = raw.daily;

  // Build hourly array — 48 entries max, we expose 24
  const hourlyLength = Math.min((h.time || []).length, 24);
  const hourly = Array.from({ length: hourlyLength }, (_, i) => ({
    time: h.time[i],
    temperature: Math.round(h.temperature_2m[i]),
    weatherCode: h.weather_code[i],
  }));

  // Build daily array
  const dailyLength = (d.time || []).length;
  const daily = Array.from({ length: dailyLength }, (_, i) => ({
    date: d.time[i],
    weatherCode: d.weather_code[i],
    tempMax: Math.round(d.temperature_2m_max[i]),
    tempMin: Math.round(d.temperature_2m_min[i]),
    uvIndexMax: d.uv_index_max[i] ?? null,
  }));

  return {
    timezone: raw.timezone,
    current: {
      temperature: Math.round(c.temperature_2m),
      apparentTemperature: Math.round(c.apparent_temperature),
      humidity: c.relative_humidity_2m,
      windSpeed: Math.round(c.wind_speed_10m),
      weatherCode: c.weather_code,
      isDay: c.is_day,
      time: c.time,
    },
    hourly,
    daily,
    fetchedAt: new Date().toISOString(),
  };
}

module.exports = { fetchWeather };
